unit MyComPort;


interface

Uses SysUtils, myutils, dateutils, Classes,
   myThreadUtils,
  cport, // in 'cport\cport.pas',
  cportctl; //in 'cport\cportCtl.pas';


type


  TComPortConf = record
      Name: string;
      BR: string;
      DataBits: string;
      StopBits: string;
      Parity: string;
      FlowCtrl: string;
  end;


  TLockableBuffer = class (TMyLockableObject)
    public
      constructor Create;
      destructor Destroy; override;
    public
      str: string;
  end;

  TComPortThreadSafe = class (TMyLockableObject)
  //special care must be taken to call port.setup (best using SYNCHRONIZE... and when not communicating)
    public
      constructor Create;
      destructor Destroy; override;
    public
      ComPort: TComPort;    //!!!!!!main communication component
    public
      //control
      function OpenPort: boolean;
      procedure ClosePort;
      function IsPortOpen: boolean;
      procedure ShowSetupDialog;    //prepared to be called by synchronize
   public
      //communication
      procedure ClearInputBuffer;
      function SendStringRaw(s: string): boolean;
      function ReadStringRaw(Var s: string): boolean;
      function ReadString(Var s: string; Nchars: longword; timeoutMS: longword): boolean; //reads in cycle until number of chars or timeout
      function ReadStringTermTout(Var s: string; TermStr: string; timeoutMS: longword): boolean; //reads in cycle until number of chars or timeout
      //
      function QueryHighLVLSingleTerm(outs: string; Var reply: string; terminator: string; timeoutMS: longword; Var elapsedMS: longword): boolean;
        //sets receive enabled, sends str a and waits for reply or timeout (waiting for terminator string when receiving)
        //note terminator is NOT automatically appended to outs!
      function QueryHighLvlGetMultiTerminators(outs: string; Var reply: TStringList; TermStr: string; TermCNT: longint; timeoutMS: longword; Var elapsedMS: longword): boolean;
        //sends outs (no terminator added, must be done in caller), then waits for reply or timouts
        //reply is successfull if TermCNT count of "termstr" termitors is received in total, data in between are returned as stringlist (stripped of the terminator)
      //
      procedure AssignLogProc(logproc: TLogProcedureThreadSafe);
      procedure getComPortConf( Var pc: TComPortConf);
      procedure setComPortConf( Var pc: TComPortConf);
    private
      fRecvEnabled: boolean;  //indication to onRxChar that it should process received chars (=synchrolock is enabled)
      fCheckCTS: boolean; //during send - watch HW control - CTS singla
      fUseRTSduringReceive: boolean;
      fRxbuf: TLockableBuffer;  //received data are put into buffer in event handler defined inse Thread owing the com port!!!!!
      fNbuf: longint;
      fDebug: boolean;
      fConfigured: boolean;  //MUST not try open if not configured - set after call to setcomportconf
      fLogProc: TLogProcedureThreadSafe; //helper - assigned from thread to enable logging if enabled
      fSyncMsgLock: TMyLockableObject;  //lock to access fLogProc (in case from other thread by any chance)
    private
      procedure MyComPortRxChar(Sender: TObject; Count: Integer); //if fRecvEnabled then sotre chars else throow them away!
      procedure xLogMsg(s: string);
    public
      property RecvEnabled: boolean read fRecvEnabled write fRecvEnabled;
      property CheckForCTS: boolean read fCheckCTS write fCheckCTS;
      property UseRTSduringReceive: boolean read fUseRTSduringReceive write fUseRTSduringReceive;
      property Debug: boolean read fDebug write fDebug;
  end;


function PortConfToStr( Var pc: TComPortConf): string;
procedure CopyPortConf( Var from: TComPortConf; Var into: TComPortConf );  //COPY the strings - not just aaasignes reference!!!!


implementation

uses StrUtils;







constructor TComPortThreadSafe.Create;
begin
  inherited Create;  //default timeout for lock
  fRxbuf := TLockableBuffer.Create;
  fSyncMsgLock := TLockableBuffer.Create;
  fDebug := false;
  fConfigured := false;
  fNbuf := 0;
  fCheckCTS := false;
  fUseRTSduringReceive := false;
  ComPort := TComPort.Create(nil);
  //assign comport onrxchar  event handler and configure !!!
  if comport<> nil then
    begin
       //new way since 2016-05-10 use SyncMethod =smNone -> that way every time char arrives, the method
       //inside comport object calls directly
       // my EVENT HANDLER -> SO NO NEED TO WAIT FOR ANY DAMN FU**ING MESSAGES anymore
      comport.SyncMethod := smNone;    //!!!!!!!!!!!!!     //!!!!!!!!!!!!!!!!!!
      comport.OnRxChar := MyComPortRxChar;
    end;
end;


destructor TComPortThreadSafe.Destroy;
begin
  Lock;
    ComPort.Destroy;
    fRxBuf.Destroy;
    fSyncMsgLock.Destroy;
  Unlock;
  inherited;
end;


function TComPortThreadSafe.OpenPort: boolean;
begin
  Result := false;
  if (ComPort=nil) or (not fConfigured) then exit;
  Lock;
    if not comPort.Connected then
      begin
        try
          ComPort.Open;
          ComPort.PurgeCommTotal;
        except
          on E: Exception do begin end;
        end;
      end;
    if comPort.Connected then
      begin
        ComPort.SetDTR( true );  //!!!!!!! ABSOLUTELY "DTR" MUST BE SET otherwise partner device generaly will not send anything
        //RTS shoudl be set before transmitting and unset after transmit complete ...
        //ComPort.SetRTS( true );
        Result := true;
      end;
  Unlock;
end;



procedure TComPortThreadSafe.ClosePort;
begin
  if ComPort=nil then exit;
  Lock;
    if comPort.Connected then
      begin
        ComPort.SetDTR(false);
        ComPort.SetRTS(false);
        ComPort.Close;
      end;
  Unlock;
end;


function TComPortThreadSafe.IsPortOpen: boolean;
begin
  if ComPort=nil then exit;
  //Lock;   //let's try non lock ed reading ;)
    Result := comPort.Connected;
  //Unlock;
end;


procedure TComPortThreadSafe.ShowSetupDialog;
//mind! should run in context of main thread - using synchronize
begin
  if ComPort=nil then exit;
  Lock;
    comPort.ShowSetupDialog;
    fConfigured := true;
  Unlock;
end;


procedure TComPortThreadSafe.ClearInputBuffer;
begin
  fNbuf := 0;
  fRxbuf.Lock;
    fRxbuf.str := '';
  fRxbuf.Unlock;
  if ComPort=nil then exit;
  if ComPort.Connected then ComPort.ClearBuffer(true, true);
end;

function TComPortThreadSafe.SendStringRaw(s: string): boolean;
Var
  n: longint;
  sig: TComSignals;
begin
  Result := false;
  if ComPort=nil then exit;
  Lock;
  try
    if not ComPort.Connected then exit;  //unlock!!!
    //shoudl chekt for CTS!!!!  TODO
    sig := ComPort.Signals;   //(csCTS, csDSR, csRing, csRLSD);
    if fCheckCTS and not( csCTS in sig ) then
      begin
        if fDebug then xLogMsg('  SendStringRaw: CTS signal NOT set, aborting ');
        exit;
      end;
    ComPort.SetRTS( true );    //that is nonsense here ComPort.SetRTS( true );
    n := ComPort.WriteStr(s);
   ComPort.SetRTS( false );    //that is nonsense here ComPort.SetRTS( false );
    if n = length(s) then Result := True;
  finally
    Unlock;
  end;
end;


function TComPortThreadSafe.ReadStringRaw(Var s: string): boolean;
//returns data from rxbuf if no adta return false;
//NOTE: DATA ARE put into the buffer by EVENT HANDLER onRxChar
//DOES NOT SIGNAL RTS in case of RTS/CTS handshake
begin
  s := '';
  Result := false;
  Lock;
  try
      if fRxbuf.IsLocked then
        begin
         if fDebug then xLogMsg('  ReadStringRaw: there was lock on rxbuf ');
          //unlock;
         exit;
        end;
      fRxbuf.Lock;
        s := fRxbuf.str + ''; //FORCE COPY
        fRxbuf.str := '';
      fRxbuf.Unlock;
  finally
    Unlock;
  end;
  if fDebug then xLogMsg('  ReadStringRaw: read from rxbuf count:' + IntToStr( Length(s) ) );
  Result := length(s)>0;
end;


function TComPortThreadSafe.ReadString(Var s: string; Nchars: longword; timeoutMS: longword): boolean; //reads in cycle until number of chars or timeout
Var i: integer;
    t0: longword;
    tout: boolean;
    xs: string;
begin
  Result := false;
  s := '';
  Lock;
  try
      if not ComPort.Connected then
        begin
          xLogMsg('  COM-ReadString: port not connected' );
          //Unlock;
          exit;
        end;
      if fRxbuf.IsLocked then
        begin
         if fDebug then xLogMsg(' COM-ReadString: there was lock on rxbuf ');
         //Unlock;
         exit;
        end;
      //
      tout := true;
      t0 := TimeDeltaTICKgetT0;
      if fUseRTSduringReceive then ComPort.SetRTS(true);
      while ( TimeDeltaTICKNowMS(t0)< timeoutMS) and (NChars>0) do
        begin
          fRxbuf.Lock;
            if length( fRxbuf.str)>Nchars then
              begin
                s := s + LeftStr(fRxbuf.str, NChars);
                fRxbuf.str := MidStr(fRxbuf.str, NChars+1, length(fRxbuf.str) );
                Nchars := 0;
              end
            else
              begin
                xs := fRxbuf.str + ''; //FORCE COPY
                Uniquestring( xs );
                fRxbuf.str := '';
                NChars := NChars - length(xs);
                s := s + xs;
              end;
            if Nchars = 0 then tout := false;
          fRxbuf.Unlock;
        end; //while
      if tout then xLogMsg('  COM-ReadString: Timeout!' );
      if fUseRTSduringReceive then ComPort.SetRTS(false);
  finally
    Unlock;
  end;
  Result := NChars = 0;
end;


function TComPortThreadSafe.ReadStringTermTout(Var s: string; TermStr: string; timeoutMS: longword): boolean; //reads in cycle until number of chars or timeout
Var i, pterm: integer;
    t0: longword;
    tout: boolean;
    xs: string;
    nchars: longword;
begin
  Result := false;
  s := '';
  Lock;
  try
       begin
        if not ComPort.Connected then
          begin
            xLogMsg('  COM.ReadStringTermTout: port not connected' );
            //Unlock;
            exit;
          end;
        if fRxbuf.IsLocked then
          begin
           if fDebug then xLogMsg(' COM.ReadStringTermTout: there was lock on rxbuf ');
           //Unlock;
           exit;
          end;
        //
        tout := true;
        t0 := TimeDeltaTICKgetT0;
        if fUseRTSduringReceive then ComPort.SetRTS(true);
        repeat
          begin
             fRxbuf.Lock;
                if length( fRxbuf.str)>0 then
                  begin
                    pTerm := Pos(TermStr, fRxbuf.str);     //string search substring  posex
                       //if not term present - will not read anything - in order not to split possible occurence of terminator string
                       //although this might have worse performance
                    if pTerm>0 then
                      begin
                        if fDebug then xLogMsg(' COM.ReadStringTermTout: pTerm: ' + IntToStr( pterm) + '  |' + BinStrToPrintStrHexa(TermStr));
                        NChars := pTerm-1;
                        if nChars>0 then s := LeftStr(fRxbuf.str, NChars);
                        fRxbuf.str := MidStr(fRxbuf.str, pTerm+Length(TermStr), length(fRxbuf.str) );
                        if fDebug then xLogMsg(' s: ' + s + ' rxbufstr: ' + fRxbuf.str);
                        tout := false;
                      end;
                  end;
             fRxbuf.Unlock;
           if  not(tout) then break;
          end; //while or repeat
        until ( TimeDeltaTICKNowMS(t0)> timeoutMS) or ( not(tout) );
        if tout then xLogMsg('  COM.ReadStringTermTout: Timeout!' );
        Result := (tout = false);
        if fDebug then xLogMsg(' COM.ReadStringTermTout: result: : ' + BoolToStr( result ));
        if fUseRTSduringReceive then ComPort.SetRTS(false);
       end;
 finally
    Unlock;
 end;
end;





function TComPortThreadSafe.QueryHighLVLSingleTerm(outs: string; Var reply: string; terminator: string; timeoutMS: longword; Var elapsedMS: longword): boolean;
//sets receive enabled, sends str a and waits for reply or timeout (waiting for terminator string when receiving)
//note terminator is NOT automatically appended to outs!
Var
  oldrecvenabled: boolean;
  bs, br, bx, isok: boolean;
  xrecv: string;
  t0, t1, dt: longword;
Const
  CdefLen = 2048;
begin
  Result := false;
  reply := '';
  elapsedMS := 0;
  ClearInputBuffer;
  oldrecvenabled := fRecvEnabled;
  fRecvEnabled := true;
  outs := outs + terminator;
  t0 := TimeDeltaTICKgetT0;
  bs := SendStringRaw( outs );
  if not bs then
    begin
      fRecvEnabled := oldrecvenabled;
      exit;
    end;
  br := true;
  isok := false;
  t1 :=  TimeDeltaTICKgetT0;
  bx := ReadStringTermTout(xrecv, terminator, timeoutMS );  //terminator is removed!!
  if fDebug then xLogMsg(' COM.QueryHighLVLSingleTerm: result: ' + BoolToStr( bx ));
  dt := TimeDeltaTICKNowMS( t1 );
  reply := xrecv;
  br := bx;
  isOK := bx;
  //if Pos(terminator, reply)>0 then
   //     begin
    //      isOK := true;
     //     break;  //finsished, success
      //  end;
      //if not finished try wait a little more (maybe there is more in the input buffer
  fRecvEnabled := oldrecvenabled;
  elapsedMS := TimeDeltaTICKNowMS( t0 );
  Result := br;
end;


function TComPortThreadSafe.QueryHighLvlGetMultiTerminators(outs: string; Var reply: TStringList; TermStr: string; TermCNT: longint; timeoutMS: longword; Var elapsedMS: longword): boolean;
  //sends outs (no terminator added, must be done in caller), then waits for reply or timouts
  //reply is successfull if TermCNT count of "termstr" termitors is received in total, data in between are returned as stringlist (stripped of the terminator)
Var
  oldrecvenabled: boolean;
  bs, br, bx, isok, tout: boolean;
  xrecv: string;
  t0, t1, dt, toutMS: longword;
Const
  CdefLen = 2048;
begin
  Result := false;
  if reply=nil then exit;
  reply.Clear;
  elapsedMS := 0;
  ClearInputBuffer;
  oldrecvenabled := fRecvEnabled;
  fRecvEnabled := true;
  // send
  t0 := TimeDeltaTICKgetT0;
  bs := SendStringRaw( outs );
  if not bs then
    begin
      fRecvEnabled := oldrecvenabled;
      exit;
    end;
  //recv
  br := true;
  isok := false;
  tout := false;
  t1 :=  TimeDeltaTICKgetT0;
  toutMS := timeoutMS;
  while TermCNT>0 do
    begin
      bx := ReadStringTermTout(xrecv, TermStr, timeoutMS );  //terminator is already removed!!
      if fDebug then xLogMsg(' COM.QueryHighLvlGetMultiTerminators: i: ' + IntToStr(TermCNT)  + 'part result: ' + BoolToStr( bx ));
      if bx then reply.Add( xrecv );
      br := br and bx;
      dt := TimeDeltaTICKNowMS( t1 );
      if dt > ToutMS then
        begin
          ToutMS := 10;  //give another short try before timeout
          tout := true;
        end
        else ToutMS := toutMS - dt;
      Dec( TermCNT );
    end;
  dt := TimeDeltaTICKNowMS( t1 );
  fRecvEnabled := oldrecvenabled;
  elapsedMS := TimeDeltaTICKNowMS( t0 );
  Result := br and not(tout);
end;




procedure TComPortThreadSafe.MyComPortRxChar(Sender: TObject; Count: Integer);
//if fRecvEnabled then sotre chars else throow them out!
Var
 n: longint;
 s: string;
 en: boolean;
begin
  if comport=nil then exit;
  //assuming this proc is run inside context of aquire thread and so it should be safe to acces comport now
  n := comport.ReadStr(s, Count); //if comport.Connected then n := comport.ReadStr(s, Count);
  if fDebug then xLogMsg('  ComPortRxChar: Count=' + IntToStr( Count) + ' receive enabled: ' + BoolToStr(fRecvEnabled) + ' before in rxbuf: ' + IntToStr(Length(fRxbuf.str)) + ' n recv: ' + IntToStr( n ) + ' myNcnt : ' + IntToStr( fNbuf ) +' recvstr: ' + BinStrToPrintStr(s) );
  //if not enabled the mesage will be forgotten
  en := fRecvEnabled; //.valbool;
  If fDebug and (not en) then  xLogMsg('     ComPortRxChar: flushing this message: ' + BinStrToPrintStr(s) );
  //if fRecvEnabled is true it should be safe to write to rxbuf - because it means the synchro is locked from the thread
  //and the thread is waiting for incoming message - and periodically calling process messages
  //so if the execution is here it means the thread is not accesing the synchro at the moment ...
  if en then
    begin
      fNbuf := fNBuf + n;
      fRxbuf.Lock;        //Actually in Async operation i tseems this event and reading from rxBuf MIGTH be in conflict ocassionally
        fRxbuf.str := fRxBuf.str + s;
      fRxbuf.UnLock;
    end;
end;



procedure TComPortThreadSafe.AssignLogProc(logproc: TLogProcedureThreadSafe);
begin
  fLogProc := logproc;
end;


procedure TComPortThreadSafe.xLogMsg(s: string);
begin
     if fDebug and Assigned( fLogProc ) then
       begin
         fSyncMsgLock.Lock;
           fLogProc(s);
         fSyncMsgLock.Unlock;
       end;
end;


procedure TComPortThreadSafe.getComPortConf( Var pc: TComPortConf);
begin
  if comport=nil then exit;
  pc.Name := comport.Port;
  pc.BR := BaudRateToStr( comport.BaudRate ) ;
  pc.StopBits := StopBitsToStr( comport.StopBits );
  pc.DataBits := DataBitsToStr( comport.DataBits );
  pc.Parity := ParityToStr( comport.Parity.Bits );
  pc.FlowCtrl := FlowControlToStr( comport.FlowControl.FlowControl );
end;


procedure TComPortThreadSafe.setComPortConf( Var pc: TComPortConf);
begin
  if comport=nil then exit;
  comport.Port := pc.Name;
  comport.BaudRate := StrToBaudRate(pc.BR);
  comport.StopBits := StrToStopBits(pc.StopBits);
  comport.DataBits := StrToDataBits(pc.DataBits);
  comport.Parity.Bits := StrToParity(pc.Parity);
  comport.FlowControl.FlowControl := StrToFlowControl( pc.FlowCtrl );
  fConfigured := true;
end;



procedure CopyPortConf( Var from: TComPortConf; Var into: TComPortConf );  //COPY the strings - not just aaasignes reference!!!!
begin
  with into do
    begin
      Name := from.name + '';  //force string copy
      BR := from.BR + '';
      DataBits := from.DataBits + '';
      StopBits := from.StopBits + '';
      Parity := from.Parity + '';
      FlowCtrl := from.FlowCtrl + '';
    end;
end;

function PortConfToStr( Var pc: TComPortConf): string;
begin
  Result := '';
  with pc do
    begin
      StrAdd( Result, '['+Name + ':');
      StrAdd( Result, ';BR=' + BR);
      StrAdd( Result, ';Databits=' + Databits);
      StrAdd( Result, ';StopBits=' + StopBits);
      StrAdd( Result, ';Parity=' + Parity);
      StrAdd( Result, ';FlowCtrl=' + FlowCtrl + ']');
    end;
end;

//**********************


constructor TLockableBuffer.Create;
begin
  inherited create;
end;


destructor TLockableBuffer.Destroy;
begin
  inherited;
end;



end.




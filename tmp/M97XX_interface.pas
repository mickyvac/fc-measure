unit M97XX_interface;

interface

uses Classes, strutils, SysUtils,
     Logger, myutils, MyComPort, MyThreadUtils, MVConversion,
     COnfigManager;

type

TM97XXlowlevelIface = class (TObject)
    public
      constructor Create;
      destructor Destroy; override;
    public
      procedure AssignComPort(Com: TComPortThreadSafe);
      procedure AssignLogObject(log: TLoggerThreadSafeNew);
    public
      function SetModeCC: Boolean;
      function SetModeCV: Boolean;
      function SetModeCCsoftStart: Boolean;
      function SetModeCCwithCVprotection: Boolean;
      function SetInputON: Boolean;
      function SetInputOFF: Boolean;
    public
      function AcquireStatus: Boolean;  //data and status placed into registry
    public
      function SetUfix(ss: single): Boolean;
      function SetIfix(ss: single): Boolean;
      function SetPfix(ss: single): Boolean;
      function SetUCCCV(ss: single): Boolean;
    private
      fComPort: TComPortThreadSafe;
      fLog:  TLoggerThreadSafeNew;
      fTimeoutMS: longword;
      fDevAddr: byte;
      fDataRegistry: TMyRegistryNodeObject;
      fLogComm: boolean;
    public
      property ComTimeout: longword read fTimeoutMS write fTimeoutMS;
      property DevAddr: byte read fDevAddr write fDevAddr;
      property Data: TMyRegistryNodeObject read fDataRegistry;
    public //private
      procedure _logmsg(s: string);
      function M97ReadCoilStatus(Var res: TBytes; Var rescode:byte; addr: byte; startaddr: word; Nbytes: word): boolean; //returns true on success , fills internal bkrxbuf!!!
      function M97SetCoil(Var rescode:byte; devaddr: byte; memaddr: word; state: boolean): boolean;
      function M97ReadRegisters(VAr data: TBytes; Var rescode:byte; devaddr: byte; memaddr: word; nwords: word): boolean;
      function M97WriteRegisters(Var rescode: byte; devaddr: byte; memaddr: word; nwords: word; data:TBytes ): boolean;
    end;



Const
  CregCMD: word = $0A00;
  CregPC1: word = $0500;
  CregPC2: word = $0501;
  CregREMOTE: word = $0503;
  CregISTATE: word = $0510;
  CregIOVER: word = $0520;
  CregUOVER: word = $0521;
  CregPOVER: word = $0522;
  CregHEAT: word = $0523;
  CregREVERSE: word = $0524;

  CregIFIX: word = $0A01;
  CregUFIX: word = $0A03;
  CregPFIX: word = $0A05;
  CregUCCCV: word = $0A1D;
  CregIMAX: word = $0A34;
  CregU: word = $0B00;



  CcmdCC: word = 1;
  CcmdCV: word = 2;
  CcmdCW: word = 3;
  CcmdCR: word = 4;
  CcmdCCSoftStart: word = 20;
  CcmdCCCV: word = 34;
  CcmdInputON: word = 42;
  CcmdInputOFF: word = 43;

  IdM97U: string = 'M97U';
  IdM97I: string = 'M97I';
  IdM97UMAX: string = 'M97UMAX';
  IdM97IMAX: string = 'M97IMAX';
  IdM97PMAX: string = 'M97PMAX';
  IdM97CMD: string = 'M97CMD';
  IdM97IFIX: string = 'IdM97IFIX';
  IdM97UFIX: string = 'IdM97UFIX';
  IdM97PFIX: string = 'IdM97PFIX';
  IdM97RFIX: string = 'IdM97RFIX';
  IdM97TMCCS: string = 'IdM97TMCCS';
  IdM97TMCVS: string = 'IdM97TMCVS';
  IdM97UCCCV: string = 'IdM97UCCCV';
  IdM97SETMODE: string = 'IdM97SETMODE';
  IdM97INPUTMODE: string = 'IdM97INPUTMODE';
  IdM97MODEL: string = 'IdM97MODEL';
  IdM97EDITION: string = 'IdM97EDITION';
  //coils
  IdM97PC1: string = 'IdM97PC1';
  IdM97PC2: string = 'IdM97PC2';
  IdM97REMOTE: string = 'IdM97REMOTE';
  IdM97ISTATE: string = 'IdM97ISTATE';
  IdM97TRACK: string = 'IdM97TRACK';
  IdM97IOVER: string = 'IdM97IOVER';
  IdM97UOVER: string = 'IdM97UOVER';
  IdM97POVER: string = 'IdM97POVER';
  IdM97HEAT: string = 'IdM97HEAT';
  IdM97REVERSE: string = 'IdM97REVERSE';
  //tdstamps
  IdM97IFIXtimestamp: string = 'IdM97IFIXtimestamp';


implementation


constructor TM97XXlowlevelIface.Create;
begin
  inherited;
  fComPort := nil;
  fLog := nil;  
  fTimeoutMS := 500;
  fDevAddr := $01;
  fLogComm := true; //false;
  //
  fDataRegistry := TMyRegistryNodeObject.Create('M97data');
end;


destructor TM97XXlowlevelIface.Destroy;
begin
  fComPort := nil;
  fLog := nil;
  fDataRegistry.Destroy;
  inherited;
end;

procedure TM97XXlowlevelIface.AssignComPort(Com: TComPortThreadSafe);
begin
  fComPort := com;
end;

procedure TM97XXlowlevelIface.AssignLogObject(log: TLoggerThreadSafeNew);
begin
  fLog := log;
end;

function TM97XXlowlevelIface.SetModeCC: Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  ByteArrayFromWordLE(tb, CcmdCC);
  Result := M97WriteRegisters(rc, fDevAddr, CregCMD, 1, tb);
end;


function TM97XXlowlevelIface.SetModeCV: Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  ByteArrayFromWordLE(tb, CcmdCV);
  Result := M97WriteRegisters(rc, fDevAddr, CregCMD, 1, tb);
end;

function TM97XXlowlevelIface.SetModeCCsoftStart: Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  ByteArrayFromWordLE(tb, CcmdCCSoftStart);
  Result := M97WriteRegisters(rc, fDevAddr, CregCMD, 1, tb);
end;

function TM97XXlowlevelIface.SetModeCCwithCVprotection: Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  ByteArrayFromWordLE(tb, CcmdCCCV);
  Result := M97WriteRegisters(rc, fDevAddr, CregCMD, 1, tb);
end;

function TM97XXlowlevelIface.SetInputON: Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  ByteArrayFromWordLE(tb, CcmdInputON);
  Result := M97WriteRegisters(rc, fDevAddr, CregCMD, 1, tb);
end;

function TM97XXlowlevelIface.SetInputOFF: Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  ByteArrayFromWordLE(tb, CcmdInputOFF);
  Result := M97WriteRegisters(rc, fDevAddr, CregCMD, 1, tb);
end;


function TM97XXlowlevelIface.AcquireStatus: Boolean;  //data and status placed into registry
Var
  rc: byte;
  tb: TBytes;
  b1, b2, b3, b4, b5: boolean;
  cmd: word;
  ifix, ufix, pfix, rfix, tmccs, tmcvs: single;
  ucccv, ucrcv, imax, umax, pmax, uu, ii: single;
  setmode, inputmode, model, edition: word;
  pc1, pc2, remote, istate, iover, uover, pover, heat, reverse: byte;
  ts: tDateTime;
  ri : TRegistryItem;
begin
  Result := false;
  //ByteArrayFromWordLE(tb, CcmdInputON);
  b1 := M97ReadRegisters(tb, rc, fDevAddr, CregIFIX, 12);    //ifix, ufix, pFix, Rfix, TMccs, TMcvs ...
  if b1 then
    begin
      ifix := BinToFloatLE( tb, 0);
      ufix := BinToFloatLE( tb, 4);
      pfix := BinToFloatLE( tb, 8);
      rfix := BinToFloatLE( tb, 12);
      tmccs := BinToFloatLE( tb, 16);
      tmcvs := BinToFloatLE( tb, 20);
      ts := Now;
{      cmd: word;}
      fDataRegistry.SetOrCreateItem(IdM97IFIX, ifix);
      fDataRegistry.SetOrCreateItem(IdM97UFIX, ufix);
      fDataRegistry.SetOrCreateItem(IdM97PFIX, pfix);
      fDataRegistry.SetOrCreateItem(IdM97RFIX, rfix);
      fDataRegistry.SetOrCreateItem(IdM97TMCCS, tmccs);
      fDataRegistry.SetOrCreateItem(IdM97TMCVS, tmcvs);
      fDataRegistry.SetOrCreateItem(IdM97IFIXtimestamp, ts);
    end;
  b2 := M97ReadRegisters(tb, rc, fDevAddr, CregUCCCV, 8);    //ucccv, ucrcv ...
  if b2 then
    begin
      ucccv := BinToFloatLE( tb, 0);
      ts := Now;
      fDataRegistry.SetOrCreateItem(IdM97UCCCV, ucccv);
    end;
  b3 := M97ReadRegisters(tb, rc, fDevAddr, CregIMAX, 12);    //imax, umax, pmax ...
  if b3 then
    begin
      imax := BinToFloatLE( tb, 0);
      umax := BinToFloatLE( tb, 4);
      pmax := BinToFloatLE( tb, 8);
      ts := Now;
      fDataRegistry.SetOrCreateItem(IdM97IMAX, imax);
      fDataRegistry.SetOrCreateItem(IdM97UMAX, umax);
      fDataRegistry.SetOrCreateItem(IdM97PMAX, pmax);
    end;
  b4 := M97ReadRegisters(tb, rc, fDevAddr, CregU, 16);    //u, i, setmode, inputmode, model, edition ...
  if b4 then
    begin
      uu := BinToFloatLE( tb, 0);
      ii := BinToFloatLE( tb, 4);
      setmode := BinToUint16LE( tb, 8);
      inputmode := BinToUint16LE( tb, 10);
      model := BinToUint16LE( tb, 12);
      edition := BinToUint16LE( tb, 14);
      ts := Now;
      fDataRegistry.SetOrCreateItem(IdM97U, uu);
      fDataRegistry.SetOrCreateItem(IdM97I, ii);
      fDataRegistry.SetOrCreateItem(IdM97SETMODE, setmode);
      fDataRegistry.SetOrCreateItem(IdM97INPUTMODE, inputmode);
      fDataRegistry.SetOrCreateItem(IdM97MODEL, model);
      fDataRegistry.SetOrCreateItem(IdM97EDITION, edition);
    end;
  b5 := true;
  if  M97ReadCoilStatus(tb, rc, fDevAddr, CregPC1, 8) then
      pc1 := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregPC2, 8) then
      pc2 := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregREMOTE, 8) then
      remote := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregISTATE, 8) then
      istate := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregIOVER, 8) then
      iover := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregUOVER, 8) then
      uover := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregPOVER, 8) then
      pover := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregHEAT, 8) then
      heat := BinToByte(tb, 0) else b5 := false;
  if M97ReadCoilStatus(tb, rc, fDevAddr, CregREVERSE, 8) then
      reverse := BinToByte(tb, 0) else b5 := false;
  if b5 then
    begin
      fDataRegistry.SetOrCreateItem(IdM97PC1, pc1);
      fDataRegistry.SetOrCreateItem(IdM97PC2, pc2);
      fDataRegistry.SetOrCreateItem(IdM97REMOTE, remote);
      fDataRegistry.SetOrCreateItem(IdM97ISTATE, istate);
      fDataRegistry.SetOrCreateItem(IdM97IOVER, iover);
      fDataRegistry.SetOrCreateItem(IdM97UOVER, uover);
      fDataRegistry.SetOrCreateItem(IdM97POVER, pover);
      fDataRegistry.SetOrCreateItem(IdM97HEAT, heat);
      fDataRegistry.SetOrCreateItem(IdM97REVERSE, reverse);
    end;
  //
  Result := b1 and b2 and b3 and b4 and b5;
end;




function TM97XXlowlevelIface.SetUfix(ss: single): Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  SingleToBinArrayLE(ss, tb);
  Result := M97WriteRegisters(rc, fDevAddr, CregUFIX, 2, tb);
end;


function TM97XXlowlevelIface.SetIfix(ss: single): Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  SingleToBinArrayLE(ss, tb);
  Result := M97WriteRegisters(rc, fDevAddr, CregIFIX, 2, tb);
end;


function TM97XXlowlevelIface.SetPfix(ss: single): Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  SingleToBinArrayLE(ss, tb);
  Result := M97WriteRegisters(rc, fDevAddr, CregPFIX, 2, tb);
end;


function TM97XXlowlevelIface.SetUCCCV(ss: single): Boolean;
Var
  rc: byte;
  tb: TBytes;
begin
  SingleToBinArrayLE(ss, tb);
  Result := M97WriteRegisters(rc, fDevAddr, CregUCCCV, 2, tb);
end;


//*******************************************


function ModbusVerifyCrc(s: string; crc: string): boolean;
begin
  Result := CRC16ModbusStrBE(s) = crc;
end;


procedure TM97XXlowlevelIface._logmsg(s: string);
begin
  if fLog=nil then exit;
  fLog.LogMsg(s);
end;

function TM97XXlowlevelIface.M97ReadCoilStatus(Var res: TBytes; Var rescode:byte; addr: byte; startaddr: word; Nbytes: word): boolean; //returns true on success , fills internal bkrxbuf!!!
//returns true on success
Const
  ThisProc = 'ReadCoilStatus ';
Var i: integer;
    b, b2, brest, brest2, brecv, bOK, bNOK: boolean;
    rstr: string;
  cnt: byte;
  s, msg, msgcrc: string;
  repwocrc, r1, r2, repcrc, reply: string;
begin
  Result := false;
  rescode := $FF;
  setlength(res, NBytes);
  for i:=0 to NBytes-1 do res[i] := 0;
  //
  if fComPort=nil then begin _LogMsg(ThisProc + 'Not INITIALIZED'); exit; end;
  if not fComPort.IsPortOpen then
    begin
      _LogMsg(ThisProc + 'Not Connected' );
      exit;
    end;
   //
   MakeSureIsInRange( NBytes, 1, 16 );
   MakeSureIsInRange( addr, 1, 200 );
   //
   msg := Chr(addr) + #1 + MyWordToBinLE(startaddr) + MyWordToBinLE(Nbytes);
   msgcrc := msg + CRC16ModbusStrBE(msg);
   fComPort.ClearInputBuffer;
   fComPort.RecvEnabled := true;
   b := fComPort.SendStringRaw( msgcrc );
   if fLogComm then _LogMsg( 'sending |'+ BinStrToPrintStrHexa( msgcrc ) + '| len=' + IntToStr( length(msgcrc)) + ' res='+ BoolToStr( b) );
   //receive result
   brecv := false;
   bOK := false;
   bNOK := false;
   b2 := fComPort.ReadString( r1, 3, fTimeoutMS);
   reply := r1;
   Assert( (not b2) or (b2 and (Length(reply)=3)) );
   if b2 then
     begin
       if (r1[1] = Chr(addr)) and (r1[2] = #$1) then   //OK
         begin
           cnt := ord(r1[3]);
           Assert( cnt<254);
           //read remaining part
           brest := fComPort.ReadString( r2, cnt+2, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                reply := r1 + r2;
                repwocrc := r1 + leftstr(r2, cnt);
                repcrc := r2[cnt+1] + r2[cnt+2];
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
              end;
           bOK := brecv;
         end
       else if  (r1[1] = Chr(addr)) and (r1[2] = #$81) then  //error
         begin
           rescode := ord( r1[3] );
           brest := fComPort.ReadString( r2, 2, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                repcrc := r2[1] + r2[2];
                reply := r1 + r2;
                repwocrc := r1;
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
              end;
           bNOK := brecv;
         end;
     end
   else //if b2
     begin
       _LogMsg( ThisProc + ' fail during receive - got msg: ' +  BinStrToPrintStrHexa( reply ) );
     end;
  fComPort.RecvEnabled := false;
  if fLogComm then _LogMsg( 'receive |'+ BinStrToPrintStrHexa( reply ) );
  //
  if not brecv then _LogMsg( ThisProc + ' CRC check failed' );
  if bNOK then _LogMsg( ThisProc + ' reply returned with abnormal result - code=' + IntToStr(rescode) );
  //process
  if bOK then
    begin
      setlength( res, cnt);
      for i:= 1 to cnt do res[i-1] := ord( r2[i] );
    end;
  Result := bOK;
  //clear rx buffer
end;


function TM97XXlowlevelIface.M97SetCoil(Var rescode:byte; devaddr: byte; memaddr: word; state: boolean): boolean;
//returns true on success
Const
  ThisProc = 'SetCOIL ';
Var i: integer;
    b1, b2, brest, brest2, brecv, bOK, bNOK, baddr, bdata, bunknown: boolean;
  cnt: byte;
  s, msg, msgcrc, sdata, memaddrstr, tmp: string;
  repwocrc, r1, r2, repcrc, reply: string;
  v1, v2: byte;
begin
  Result := false;
  rescode := $FF;
  MakeSureIsInRange( devaddr, 1, 200 );
  if fComPort=nil then begin _LogMsg(ThisProc + 'Not INITIALIZED'); exit; end;
  if not fComPort.IsPortOpen then
    begin
      _LogMsg(ThisProc + 'Not Connected' );
      exit;
    end;
   //
   sdata := IfThenElse(state, MyWordToBinLE($FF00), MyWordToBinLE($0000) );
   memaddrstr := MyWordToBinLE(memaddr);
   msg := Chr(devaddr) + #5 + memaddrstr + sdata;
   msgcrc := msg + CRC16ModbusStrBE(msg);
   fComPort.ClearInputBuffer;
   fComPort.RecvEnabled := true;
   b1 := fComPort.SendStringRaw( msgcrc );
   if fLogComm then _LogMsg( 'sending |'+ BinStrToPrintStrHexa( msgcrc ) + '| len=' + IntToStr( length(msgcrc)) + ' res='+ BoolToStr( b1) );
   //receive result
   brecv := false;
   baddr := false;
   bdata := false;
   bOK := false;
   bNOK := false;
   b2 := fComPort.ReadString( r1, 2, fTimeoutMS);
   reply := r1;
   tmp := BinStrToPrintStrHexa( reply );
   Assert( (not b2) or (b2 and (Length(reply)=2)) );
   if b2 then
     begin
       bunknown := true;
       v1 := ord(r1[1]);
       v2 := ord(r1[2]);
       if (r1[1] = Chr(devaddr)) and (r1[2] = #$5) then   //OK
         begin
           //read remaining part
           bunknown := false;
           brest := fComPort.ReadString( r2, 6, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                Assert( (Length(r2)=6) );
                reply := r1 + r2;
                repwocrc := r1 + leftstr(r2, 4);
                repcrc := r2[5] + r2[6];
                //check ok
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
                if memaddrstr = (r2[1] + r2[2]) then baddr := true;
                if sdata = (r2[3] + r2[4]) then bdata := true;
                bOK := brecv and baddr and bdata;
                rescode := 0;
              end;
         end;
      if (v1 = devaddr) and (v2 = $85) then  //reply with NOK status
         begin
           bunknown := false;
           brest := fComPort.ReadString( r2, 3, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                rescode := ord( r2[1] );
                repcrc := r2[2] + r2[3];
                reply := r1 + r2;
                repwocrc := r1 + r2[1];
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
              end;
           bNOK := brecv;
         end;
       if bunknown then
         begin
           _LogMsg( ThisProc + ' error undefined state after reply!' + tmp);
         end;
     end
   else //if b2
     begin
       _LogMsg( ThisProc + ' fail during receive - got msg: ' +  BinStrToPrintStrHexa( reply ) );
     end;
  fComPort.RecvEnabled := false;
  if fLogComm then _LogMsg( 'received |'+ BinStrToPrintStrHexa( reply ) );
  //
  if not brecv then _LogMsg( ThisProc + ' CRC check failed' );
  if bNOK then _LogMsg( ThisProc + ' reply returned with abnormal result - code=' + IntToStr(rescode) );
  //process
  Result := b1 and bOK;
end;



function TM97XXlowlevelIface.M97ReadRegisters(VAr data: TBytes; Var rescode:byte; devaddr: byte; memaddr: word; nwords: word): boolean;
//returns true on success
Const
  ThisProc = 'ReadRegisters ';
Var i: integer;
    b1, b2, brest, brest2, brecv, bOK, bNOK, baddr, bdata, bcountOK, bunknown: boolean;
  cnt: byte;
  s, msg, msgcrc, sdata, memaddrstr,  nwstr, tmp: string;
  repwocrc, r1, r2, repcrc, reply: string;
  v1, v2: byte;
begin
  Result := false;
  rescode := $FF;
  MakeSureIsInRange( devaddr, 1, 200 );
  MakeSureIsInRange( nwords, 1, 32 );
  //
  if fComPort=nil then begin _LogMsg(ThisProc + 'Not INITIALIZED'); exit; end;
  if not fComPort.IsPortOpen then
    begin
      _LogMsg(ThisProc + 'Not Connected' );
      exit;
    end;
   //
   SetLenAndZeroBytes(data, nwords*2);
   //
   memaddrstr := MyWordToBinLE(memaddr);
   nwstr :=  MyWordToBinLE(nwords);
   msg := Chr(devaddr) + #$3 + memaddrstr + nwstr;
   msgcrc := msg + CRC16ModbusStrBE(msg);
   //
   fComPort.ClearInputBuffer;
   fComPort.RecvEnabled := true;
   b1 := fComPort.SendStringRaw( msgcrc );
   if fLogComm then _LogMsg( 'sending |'+ BinStrToPrintStrHexa( msgcrc ) + '| len=' + IntToStr( length(msgcrc)) + ' res='+ BoolToStr( b1) );
   //receive result
   brecv := false;
   baddr := false;
   bdata := false;
   bOK := false;
   bNOK := false;
   b2 := fComPort.ReadString( r1, 3, fTimeoutMS);
   reply := r1;
   tmp := BinStrToPrintStrHexa( reply );
   Assert( (not b2) or (b2 and (Length(reply)=3)) );
   if b2 then
     begin
       bunknown := true;
       v1 := ord(r1[1]);
       v2 := ord(r1[2]);
       if (v1 = devaddr) and (v2 = $03) then   //OK
         begin
           //read remaining part
           bunknown := false;
           cnt := Ord(r1[3]);
           brest := fComPort.ReadString( r2, cnt+2, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                Assert( (Length(r2)=cnt+2) );
                reply := r1 + r2;
                repwocrc := r1 + leftstr(r2, cnt);
                repcrc := r2[cnt+1] + r2[cnt+2];
                //check ok
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
                bOK := brecv;
                rescode := 0;
              end;
         end;
      if (v1 = devaddr) and (v2 = $83) then  //reply with NOK status
         begin
           bunknown := false;
           brest := fComPort.ReadString( r2, 2, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                rescode := ord( r1[3] );
                repcrc := r2[1] + r2[2];
                reply := r1 + r2;
                repwocrc := r1;
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
              end;
           bNOK := brecv;
         end;
       if bunknown then
         begin
           _LogMsg( ThisProc + ' error undefined state after reply!' + tmp);
         end;
     end
   else //if b2
     begin
       _LogMsg( ThisProc + ' fail during receive - got msg: ' +  BinStrToPrintStrHexa( reply ) );
     end;
  fComPort.RecvEnabled := false;
  if fLogComm then _LogMsg( 'received |'+ BinStrToPrintStrHexa( reply ) );
  //
  if not brecv then _LogMsg( ThisProc + ' CRC check failed' );
  if bNOK then _LogMsg( ThisProc + ' reply returned with abnormal result - code=' + IntToStr(rescode) );
  //process
  bcountOK := cnt = nwords * 2;
  if not bcountOK then _LogMsg( ThisProc + ' nuymber fo data doesnot match expected count =' + IntToStr(cnt) + ' wanted nwords' + IntToStr(nwords) );
  if bOK then
    begin
      setlength( data, cnt);
      for i:= 1 to cnt do data[i-1] := ord( r2[i] );
    end;
  Result := b1 and bOK and bcountOK;
end;


function TM97XXlowlevelIface.M97WriteRegisters(Var rescode: byte; devaddr: byte; memaddr: word; nwords: word; data:TBytes ): boolean;
//returns true on success
Const
  ThisProc = 'WriteRegisters ';
Var i: integer;
    b1, b2, brest, brest2, brecv, bOK, bNOK, baddr, bdata, bunknown: boolean;
  cnt: byte;
  s, msg, msgcrc, sdata, nwstr, ndatastr, memaddrstr, tmp: string;
  repwocrc, r1, r2, repcrc, reply: string;
  v1, v2: byte;
begin
  Result := false;
  rescode := $FF;
  MakeSureIsInRange( devaddr, 1, 200 );
  MakeSureIsInRange( nwords, 1, 32 );
  If length(data) < nwords * 2 then
    begin
      nwords := length(data) div 2;
      _LogMsg(ThisProc + 'NOT enough data to fill Given number of registers - new Nwords=' + IntToStr(nwords) );
    end;
  //bkrxbuf.len := 0;
  if fComPort=nil then begin _LogMsg(ThisProc + 'Not INITIALIZED'); exit; end;
  if not fComPort.IsPortOpen then
    begin
      _LogMsg(ThisProc + 'Not Connected' );
      exit;
    end;
   //
   memaddrstr := MyWordToBinLE(memaddr);
   nwstr :=  MyWordToBinLE(nwords);
   sdata := '';
   for i:=0 to length(data)-1 do sdata := sdata + chr(data[i]);
   ndatastr := chr( length(data) );
   msg := Chr(devaddr) + #$10 + memaddrstr + nwstr + ndatastr + sdata;
   msgcrc := msg + CRC16ModbusStrBE(msg);
   //
   fComPort.ClearInputBuffer;
   fComPort.RecvEnabled := true;
   b1 := fComPort.SendStringRaw( msgcrc );
   if fLogComm then _LogMsg( 'sending |'+ BinStrToPrintStrHexa( msgcrc ) + '| len=' + IntToStr( length(msgcrc)) + ' res='+ BoolToStr( b1) );
   //receive result
   brecv := false;
   baddr := false;
   bdata := false;
   bOK := false;
   bNOK := false;
   b2 := fComPort.ReadString( r1, 3, fTimeoutMS);
   reply := r1;
   tmp := BinStrToPrintStrHexa( reply );
   Assert( (not b2) or (b2 and (Length(reply)=3)) );
   if b2 then
     begin
       bunknown := true;
       v1 := ord(r1[1]);
       v2 := ord(r1[2]);
       if (v1 = devaddr) and (v2 = $10) then   //OK
         begin
           //read remaining part
           bunknown := false;
           cnt := 3;  //=4-1 ... without crc
           brest := fComPort.ReadString( r2, cnt+2, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                Assert( (Length(r2)=cnt+2) );
                reply := r1 + r2;
                repwocrc := r1 + leftstr(r2, cnt);
                repcrc := r2[cnt+1] + r2[cnt+2];
                //check ok
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
                if memaddrstr = (r1[3] + r2[1]) then baddr := true;
                if nwstr = (r2[2] + r2[3]) then bdata := true;
                bOK := brecv and baddr and bdata;
                rescode := 0;
              end;
         end;
      if (v1 = devaddr) and (v2 = $90) then  //reply with NOK status
         begin
           bunknown := false;
           brest := fComPort.ReadString( r2, 2, fTimeoutMS);
           if brest then   //we have at least cnt+2 chars in reply
              begin
                rescode := ord( r1[3] );
                repcrc := r2[1] + r2[2];
                reply := r1 + r2;
                repwocrc := r1;
                if ModbusVerifyCrc(repwocrc, repcrc) then brecv := true;
              end;
           bNOK := brecv;
         end;
       if bunknown then
         begin
           _LogMsg( ThisProc + ' error undefined state after reply!' + tmp);
         end;
     end
   else //if b2
     begin
       _LogMsg( ThisProc + ' fail during receive - got msg: ' +  BinStrToPrintStrHexa( reply ) );
     end;
  fComPort.RecvEnabled := false;
  if fLogComm then _LogMsg( 'received |'+ BinStrToPrintStrHexa( reply ) );
  //
  if not brecv then _LogMsg( ThisProc + ' CRC check failed' );
  if bNOK then _LogMsg( ThisProc + ' reply returned with abnormal result - code=' + IntToStr(rescode) );
  if not bOK then _LogMsg( ThisProc + ' something was wrong');
  //process
  Result := b1 and bOK;// and bcountOK;
end;






end.

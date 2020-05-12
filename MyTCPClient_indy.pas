unit MyTCPClient_indy;

{

  this unit uses code publish at delphibasics - by Aphex
  *
  http://www.delphibasics.info/home/delphibasicssnippets/socketunitbyaphex
  *

}

{$define VERD2010}

{$ifdef VERD2010}
{$else}
{$endif}



interface

Uses SysUtils, sockets, myutils, dateutils, MyThreadUtils,
  Windows, Winsock, IdTCPClient, IdComponent, IdTCPConnection, ConfigManager;


Const
  CIntBufSize = 8192+1;

type

  TMyIntBuf = array[0..CIntBufSize] of char;

  type

  TMyClientState = (CCSError, CCSInit, CCSResolving, CCSConnectInProgress, CCSOKConnected,
                    CCSDisconnectInProgress, CCSDisconnected, CCSConFailed, CCSConLost);

  TMyOnStatusChange = procedure(nstate: TMyClientState; statusstr: string) of object;

  TMyTCPClientThreadSafe = class (TMyLockableObject)  //(TMultiReadExclusiveWriteSynchronizer)
    public
      constructor Create;
      destructor Destroy; override;
    public
      procedure Open; virtual;   //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
      procedure Close;
      procedure ConfigureTCP( server: string; port: string);
    public
    //comm
      function ClearInputBuffer: longint; //reads and throws out any waiting incoming data (returns number of them)
      function SendStringRaw(s: string): boolean;
      function ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
    //other
      procedure AssignLogProc(logproc: TLogProcedureThreadSafe);
      procedure AssignOnStatusChange( m: TMyOnStatusChange);
    private
      fTCPClient: TIdTCPClient;    //!!!!!!main communication component             //unit sockets
    private
      fConnectionLost: boolean;
      fConfigured: boolean;  //MUST not try open if not configured - set after call to configure
      fReady: TMVVariantThreadSafe; //signal that previous task e.g. configure was completed and communication is allowed
      //
      fDebug: boolean;
      fLogProc: TLogProcedureThreadSafe; //helper - assigned from thread to enable logging if enabled
      fLogMsgLock: TMyLockableObject;  //lock to access fLogProc (in case from other thread by any chance)
      fOnChangeStatusmethod: TMyOnStatusChange;
      //
      fServer: string;
      fPort: string;
      fConectTimeout: longint;
      fReadTimeout: longint;
      fClientState: TMVVariantThreadSafe; //TMyClientState ghgfhhfg;
      fClientStateTXT: TMVVariantThreadSafe; //string;
      function geTMyClientStateTXT: string;
      function fIsReady: boolean;
      function getIsConnected: boolean;
      function getClientState: TMyClientState;
      procedure setClientState(cs: TMyClientState);
    protected
      procedure xLogMsg(s: string);
      procedure xLogError(s: string);
      procedure MyOnConnected(Sender: TObject);
      procedure MyOnDisconnected(Sender: TObject);
      procedure MyOnStatusChange(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    public
      property IsReady: boolean read fIsReady;
      property IsConnected: boolean read getIsConnected;  //access is not locked
      //property ConnectionLost: boolean read fConnectionLost;
      property ConfHost: string read fServer;         //access is not locked
      property ConfPort: string read fPort;           //access is not locked
      property ConectTimeout: longint read fConectTimeout write fConectTimeout;
      property ReadTimeout: longint read fReadTimeout write fReadTimeout;
      property Debug: boolean read fDebug write fDebug;
      property IsConfigured: boolean read fConfigured;        //access is not locked
      property ClientState: TMyClientState read getClientState;
      property ClientStateDescription: string read geTMyClientStateTXT;
    end;





function ClientStateToStr(cs: TMyClientState): string;


implementation

Uses Dialogs, Classes;


constructor TMyTCPClientThreadSafe.Create;
begin
  inherited create;
  fTCPClient := TIdTcpClient.Create(nil);
  fTCPClient.OnDisconnected := MyOnDisconnected;
  fTCPClient.OnConnected := MyOnConnected;
  fTCPClient.OnStatus := MyOnStatusChange;
  //
  fLogMsgLock := TMyLockableObject.Create;
  //
  fConfigured := false;
  fConnectionLost := false;
  fDebug := false;
  fLogProc := nil;
  fServer := 'localhost';
  fPort := '20005';
  fConectTimeout := 1000;
  fReadTimeout := 500;
  //
  fReady := TMVVariantThreadSafe.Create(false);
  fClientState := TMVVariantThreadSafe.Create( Longint(CCSInit) ); //TMyClientState ghgfhhfg;
  fClientStateTXT := TMVVariantThreadSafe.Create( 'Create...' );
end;

destructor TMyTCPClientThreadSafe.Destroy;
begin
  fTCPClient.Destroy;
  //
  fLogMsgLock.Destroy;
  //
  fReady.Destroy;
  fClientState.Destroy;
  fClientStateTXT.Destroy;
  inherited;
end;



procedure TMyTCPClientThreadSafe.Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
begin
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient OPEN');
  if not fConfigured then
    begin
      xLogMsg('TCPClient OPEN: NOT CONFIGURED');
      exit;
    end;
  if isLocked then
    begin
      xLogMsg('TCPClient OPEN: Lock engaged');
      exit;
    end;
  Lock;   //no lock unlock in open (might end up locked on error)
  try
   fReady.valBool := false;
   if fTCPClient.Connected then
    begin
      xLogMsg('TCPClient OPEN: was CONNNECTED! disconnecting first');
      fTCPClient.Disconnect;
    end;
   fConnectionLost := false;
    //fTCPClient.Host := fServer;
    //fTCPClient.Port := StrToIntDef( fPort, 20005 );
    //fTCPClient.IOHandler.ReadTimeout := fRe
   setClientState( CCSConnectInProgress );
    //
{$ifdef VERD2010}
   fTCpClient.ConnectTimeout := fConectTimeout;
   fTCPClient.Connect();  //fTCPClient.Connect( fConectTimeout );
{$else}
    //old version
    fTCPClient.Connect( fConectTimeout );
{$endif}
    //!!! add verifyconnection here
   if fTCPClient.Connected then
     begin
       //setClientState( CCSOKConnected );
       fReady.valBool := true;
     end
   else setClientState( CCSConFailed );
  except
    on Ex: Exception do begin xLogMsg('EXCEPTION ' + Ex.Message); end;
  end;
 Unlock;
  xLogMsg('      result: ' + BoolToStr(fTCPClient.Connected) );
end;

procedure TMyTCPClientThreadSafe.Close;
begin
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient CLOSE');
  fReady.valBool := false;
  Lock;
    try
      if fTCPClient.Connected then fTCPClient.Disconnect;
    except
      on Ex: Exception do begin xLogMsg('EXCEPTION ' + Ex.Message); end;
    end;
  Unlock;
  //fClientState := CCSDisconnected;
end;

function TMyTCPClientThreadSafe.fIsReady: boolean;
begin
  Result := false;
  if fTCPClient=nil then exit;
  Result :=  fTCPClient.Connected and fReady.valBool;
end;


function TMyTCPClientThreadSafe.getIsConnected: boolean;
begin
  Result := false;
  if fTCPClient=nil then exit;
  Result :=  fTCPClient.Connected;
end;


procedure TMyTCPClientThreadSafe.MyOnConnected(Sender: TObject);
begin
  //fConnected := true;
  //fClientState := CCSOKConnected;
end;

procedure TMyTCPClientThreadSafe.MyOnDisconnected(Sender: TObject);
begin
  //fConnected := false;
  fConnectionLost := true;
  //fClientState := CCSDisconnected;
end;

procedure TMyTCPClientThreadSafe.MyOnStatusChange(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
Var
  cs: TMyClientState;
begin
  case AStatus of
    hsResolving: cs := CCSResolving;
    hsConnecting: cs := CCSConnectInProgress;
    hsConnected: cs := CCSOKConnected;
    hsDisconnecting: cs := CCSDisconnectInProgress;
    hsDisconnected: cs := CCSDisconnected;
  end;
  fClientState.valInt := Longint(cs);
  if (AStatus=hsConnecting) or (AStatus=hsConnected) then fClientStateTXT.valStr := AStatusText
  else fClientStateTXT.valStr := ClientStateToStr( cs );
  //
  if (cs = CCSDisconnected) or (cs = CCSDisconnectInProgress) then
    begin
      fReady.valBool := false;
    end;
  //
  if Assigned( fOnChangeStatusmethod ) then
    begin
      try
        fOnChangeStatusmethod(cs, fClientStateTXT.valStr);
      except
        on E: Exception do xlogmsg( 'EXCEPTION TMyTCPClientThreadSafe.MyOnStatusChange: got error during method '+ PointerToStr(@fOnChangeStatusmethod) + ' msg: ' + E.message);
      end;
    end;
end;



procedure TMyTCPClientThreadSafe.ConfigureTCP( server: string; port: string);
begin
  if fTCPClient=nil then exit;
  Lock;
    fServer := server;
    fPort := port;
    try
      fReady.valBool := false;
      if fTCPClient.Connected then fTCPClient.Disconnect;
      fConnectionLost := false;
      fTCPClient.Host := server;
      fTCPClient.Port := StrToIntDef( port, 0);
    except
      on Ex: Exception do begin xLogMsg('EXCEPTION ' + Ex.Message); end;
    end;
    fConfigured := true;
  Unlock;
  xLogMsg('TCPClient configure: ' + fServer + ':' + fPort );
end;

function TMyTCPClientThreadSafe.ClearInputBuffer: longint; //reads and throws out any waiting incoming data (returns number of them)
Var
  buf: TMyIntBuf;
begin
  Result := 0;
  if fTCPClient=nil then exit;
  if IsLocked then exit;
  Lock;
    try
{$ifdef VERD2010}
    fTCPClient.IOHandler.WriteBufferClear;
{$else}
      fTCPClient.ClearWriteBuffer;
{$endif}

    except
      on Ex: Exception do begin xLogMsg('EXCEPTION ' + Ex.Message); end;
    end;
  Unlock;
end;


function TMyTCPClientThreadSafe.SendStringRaw(s: string): boolean;
Var
  t0: longword;
begin
  Result := false;
  t0 := TimeDeltaTICKgetT0;
  if fTCPClient=nil then exit;
  if (not fTCPClient.Connected) or (not fReady.valBool) then
    begin
      xLogMsg('TCPClient SendStringRaw:  Not Connected /s=' + BinStrToPrintStr(s));
      exit;
    end;
  if fDebug then  xLogMsg('ii TCPClientSendStringRaw: ' + BinStrToPrintStr(s));
  Lock;
    try
{$ifdef VERD2010}
      fTCPClient.IOHandler.Write(s);
{$else}
      fTCPClient.Write(s);
{$endif}
    except
      on Ex: Exception do begin xLogMsg('EXCEPTION ' + Ex.Message); end;
    end;
  Unlock;
  Result := true;
  if fDebug then  xLogMsg('     result: ' + BoolToStr(Result) + ' timeMS: '  + IntToStr( TimeDeltaTICKNowMS( t0 ) ) );
end;






function TMyTCPClientThreadSafe.ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
Var
  e, tout,bd: boolean;
  t0: longword;
  emsg, outs: string;
  i, ii:integer;
begin
  Result := false;
  s := '';
  lenout := 0;
  if fTCPClient=nil then exit;
  if (not fTCPClient.Connected) and (not fReady.valBool) then
    begin
      xLogMsg('TCPClientREADStringRaw:  Not Connected');
      if (not fTCPClient.Connected) or (not fReady.valBool) then
        begin
          xLogMsg('TCPClientREADStringRaw:  Try reopen');
          Open;
        end;
      exit;
    end;
  if fDebug then  xLogMsg('ii TCPClientREADStringRaw');
  t0 := TimeDeltaTICKgetT0;
  Lock;                                //HERE
    tout := false;
    emsg := '';
    try
{$ifdef VERD2010}
      bd := fTCPClient.IOHandler.CheckForDataOnSource(fReadTimeout);
      s := fTCPClient.IOHandler.InputBufferAsString;
      if fTCPClient.IOHandler.ReadLnTimedOut then tout := true;
{$else}
      i := fTCPClient.ReadFromStack (false, fReadTimeout, false);
      s := fTCPClient.InputBuffer.Extract(fTCPClient.InputBuffer.Size);
      if fTCPClient.ReadLnTimedOut then tout := true;
{$endif}
    except
      on Exc: exception do begin emsg := Exc.Message; e := true; end;
    end;
  Unlock;
  LenOut := Length(s);
  if tout then xLogMsg('TIMEOUT TCPClientREADStringRaw:  Timeout!');
  if e then xLogMsg('EXCEPTION TCPClientREADStringRaw:  Error: ' + emsg);
  if fDebug then  xLogMsg('     result N: ' + IntToStr(LenOut) + ' elapsed: '+ IntToStr( TimeDeltaTICKNowMS(t0) )   + ' received: ' + BinStrToPrintStr(s) );
  Result := not e;
end;


function TMyTCPClientThreadSafe.geTMyClientStateTXT: string;
begin
  Result := fClientStateTXT.valStr;
end;




function TMyTCPClientThreadSafe.getClientState: TMyClientState;
begin
  Result := TMyClientState( fClientState.valInt );
end;

procedure TMyTCPClientThreadSafe.setClientState(cs: TMyClientState);
begin
  fClientState.valInt := Integer(cs);
end;


procedure TMyTCPClientThreadSafe.AssignLogProc(logproc: TLogProcedureThreadSafe);
begin
  fLogProc := logproc;
end;

procedure TMyTCPClientThreadSafe.AssignOnStatusChange( m: TMyOnStatusChange);
begin
  fOnChangeStatusmethod := m;
end;

procedure TMyTCPClientThreadSafe.xLogMsg(s: string);
begin
     if fDebug and Assigned( fLogProc ) then
       begin
         fLogMsgLock.Lock;
           fLogProc(s);
         fLogMsgLock.Unlock;
       end;
end;

procedure TMyTCPClientThreadSafe.xLogError(s: string);
begin
     if Assigned( fLogProc ) then
       begin
         fLogMsgLock.Lock;
           fLogProc(s);
         fLogMsgLock.Unlock;
       end;
end;


function ClientStateToStr(cs: TMyClientState): string;
//  TMyClientState = (CCSError, CCSInit, CCSResolving, CCSConnectInProgress, CCSOKConnected,
//                    CCSDisconnectInProgress, CCSDisconnected, CCSConFailed, CCSConLost);
begin
  case cs of
    CCSError: Result := 'Error!';
    CCSInit: Result := 'Init...';
    CCSResolving:Result := 'Resolving...';
    CCSConnectInProgress: Result := 'Connecting...';
    CCSOKConnected: Result := 'Connected.';
    CCSDisconnectInProgress: Result := 'Disconnecting...';
    CCSDisconnected: Result := 'Disconnected.';
    CCSConFailed: Result := 'Connection FAILED!';
    CCSConLost: Result := 'Connection LOST!';
    else  Result := 'Unknown error...';
  end;
end;

//  TMyClientState = (CCSError, CCSInit, CCSResolving, CCSConnectInProgress, CCSOKConnected,
//                    CCSDisconnectInProgress, CCSDisconnected, CCSConFailed, CCSConLost);

end.




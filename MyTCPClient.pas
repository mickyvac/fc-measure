unit MyTCPClient;

{
There is a great article describing workings of the TTCpClient.....
- I decided I will be using BLOCKING mode inlcuding connect - because the THREAD will take care of that,
if the connect is taking too long, IT CAN BE INTERRUPTED from the MAIN thread (just by calling disconnect) on the client
Note: reading from sokcet in blocking mode WITHOUT blocking is not a problem - using WAITFORDATA can manage that!!!!!!


http://stackoverflow.com/questions/18473939/tcpclient-custom-timeout-time
http://stackoverflow.com/questions/7780746/how-to-control-the-connect-timeout-with-the-winsock-api/7785340#7785340


stackowerflow - article by JRL

Non-blocking mode

The following function will wait until the connection is successful or the timeout elapses:

function WaitUntilConnected(TcpClient: TTcpClient; Timeout: Integer): Boolean;
var
  writeReady, exceptFlag: Boolean;
begin
  // Select waits until connected or timeout
  TcpClient.Select(nil, @writeReady, @exceptFlag, Timeout);
  Result := writeReady and not exceptFlag;
end;

How to use:

// TcpClient.BlockMode must be bmNonBlocking

TcpClient.Connect; // will return immediately
if WaitUntilConnected(TcpClient, 500) then begin // wait up to 500ms
  ... your code here ...
end;

Also be aware of the following drawbacks/flaws in TTcpClient's non-blocking mode design:

    Several functions will call OnError with SocketError set to WSAEWOULDBLOCK (10035).
    Connected property will be false because is assigned in Connect.

Blocking mode

Connection timeout can be achieved by changing to non-blocking mode after socket is created but before calling Connect, and reverting back to blocking mode after calling it.

This is a bit more complicated because TTcpClient closes the connection and the socket if we change BlockMode, and also there is not direct way of creating the socket separately from connecting it.

To solve this, we need to hook after socket creation but before connection. This can be done using either the DoCreateHandle protected method or the OnCreateHandle event.

The best way is to derive a class from TTcpClient and use DoCreateHandle, but if for any reason you need to use TTcpClient directly without the derived class, the code can be easily rewriten using OnCreateHandle.



type
  TExtendedTcpClient = class(TTcpClient)
  private
    FIsConnected: boolean;
    FNonBlockingModeRequested, FNonBlockingModeSuccess: boolean;
  protected
    procedure Open; override;
    procedure Close; override;
    procedure DoCreateHandle; override;
    function SetBlockModeWithoutClosing(Block: Boolean): Boolean;
    function WaitUntilConnected(Timeout: Integer): Boolean;
  public
    function ConnectWithTimeout(Timeout: Integer): Boolean;
    property IsConnected: boolean read FIsConnected;
  end;

procedure TExtendedTcpClient.Open;
begin
  try
    inherited;
  finally
    FNonBlockingModeRequested := false;
  end;
end;

procedure TExtendedTcpClient.DoCreateHandle;
begin
  inherited;
  // DoCreateHandle is called after WinSock.socket and before WinSock.connect
  if FNonBlockingModeRequested then
    FNonBlockingModeSuccess := SetBlockModeWithoutClosing(false);
end;

procedure TExtendedTcpClient.Close;
begin
  FIsConnected := false;
  inherited;
end;

function TExtendedTcpClient.SetBlockModeWithoutClosing(Block: Boolean): Boolean;
var
  nonBlock: Integer;
begin
  // TTcpClient.SetBlockMode closes the connection and the socket
  nonBlock := Ord(not Block);
  Result := ErrorCheck(ioctlsocket(Handle, FIONBIO, nonBlock)) <> SOCKET_ERROR;
end;

function TExtendedTcpClient.WaitUntilConnected(Timeout: Integer): Boolean;
var
  writeReady, exceptFlag: Boolean;
begin
  // Select waits until connected or timeout
  Select(nil, @writeReady, @exceptFlag, Timeout);
  Result := writeReady and not exceptFlag;
end;

function TExtendedTcpClient.ConnectWithTimeout(Timeout: Integer): Boolean;
begin
  if Connected or FIsConnected then
    Result := true
  else begin
    if BlockMode = bmNonBlocking then begin
      if Connect then // will return immediately, tipically with false
        Result := true
      else
        Result := WaitUntilConnected(Timeout);
    end
    else begin // blocking mode
      // switch to non-blocking before trying to do the real connection
      FNonBlockingModeRequested := true;
      FNonBlockingModeSuccess := false;
      try
        if Connect then // will return immediately, tipically with false
          Result := true
        else begin
          if not FNonBlockingModeSuccess then
            Result := false
          else
            Result := WaitUntilConnected(Timeout);
        end;
      finally
        if FNonBlockingModeSuccess then begin
          // revert back to blocking
          if not SetBlockModeWithoutClosing(true) then begin
            // undesirable state => abort connection
            Close;
            Result := false;
          end;
        end;
      end;
    end;
  end;
  FIsConnected := Result;
end;


How to use:

TcpClient := TExtendedTcpClient.Create(nil);
try
  TcpClient.BlockMode := bmBlocking; // can also be bmNonBlocking

  TcpClient.RemoteHost := 'www.google.com';
  TcpClient.RemotePort := '80';

  if TcpClient.ConnectWithTimeout(500) then begin // wait up to 500ms
    ... your code here ...
  end;
finally
  TcpClient.Free;
end;


As noted before, Connected doesn't work well with non-blocking sockets, so I added a new IsConnected property to overcome this (only works when connecting with ConnectWithTimeout).

Both ConnectWithTimeout and IsConnected will work with both blocking and non-blocking sockets.

}


interface

Uses SysUtils, sockets, myutils, dateutils, myThreadUtils;


Const
  CIntBufSize = 4096;

type

  TMyIntBuf = array[0..CIntBufSize] of char;

type

  TMyExtendedTcpClient = class(TTcpClient)
    //see notes at the beginnig - will use BLOCKING mode - expect to be used inside independent worker thread
  public
    constructor Create;
  public
    //general
    procedure Open; override;   //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
    procedure Close; override;
  private
    FConnectInProgress: boolean;
  public
    property IsConnectInProgress: boolean read FConnectInProgress;
  end;




  TMyTCPClientThreadSafe = class (TMyLockableObject)  //(TMultiReadExclusiveWriteSynchronizer)
    public
      constructor Create;
      destructor Destroy; override;
    public
      procedure Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
      procedure Close;
      function IsOpen: boolean;
      procedure ConfigureTCP( server: string; port: string);
    public
    //comm
      function ClearInputBuffer: longint; //reads and throws out any waiting incoming data (returns number of them)
      function SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
      function ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
    //other
      procedure AssignLogProc(logproc: TLogProcedureThreadSafe);
    private
      fTCPClient: TMyExtendedTcpClient;    //!!!!!!main communication component             //unit sockets
    private
      fConfigured: boolean;  //MUST not try open if not configured - set after call to configure
      fDebug: boolean;
      fLogProc: TLogProcedureThreadSafe; //helper - assigned from thread to enable logging if enabled
      fLogMsgLock: TMyLockableObject;  //lock to access fLogProc (in case from other thread by any chance)
      fServer: string;
      fPort: string;
    protected
      procedure xLogMsg(s: string);
      procedure MyOnDisconnectHandle(Sender: TObject);
    public
      property ConfHost: string read fServer;
      property ConfPort: string read fPort;
      property Debug: boolean read fDebug write fDebug;
      property IsConfigured: boolean read fConfigured;
    end;



implementation

Uses Dialogs;


constructor TMyTCPClientThreadSafe.Create;
begin
  inherited create;
  fTCPClient := TMyExtendedTcpClient.Create;
  fTCPClient.OnDisconnect := MyOnDisconnectHandle;
  fLogMsgLock := TMyLockableObject.Create;
  fConfigured := false;
  fDebug := false;
  fLogProc := nil;
  fServer := 'localhost';
  fPort := '20005';
end;

destructor TMyTCPClientThreadSafe.Destroy;
begin
  fTCPClient.Destroy;
  fLogMsgLock.Destroy;
  inherited;
end;



procedure TMyTCPClientThreadSafe.Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
begin
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient OPEN: start');
  if isLocked then
    begin
      xLogMsg('TCPClient OPEN: Lock engaged');
      exit;
    end;
  if not fConfigured then
    begin
      xLogMsg('TCPClient OPEN: NOT CONFIGURED');
      exit;
    end;
  //no lock unlock in open (might end up locked on error)
  fTCPClient.Open;
  xLogMsg('      result: ' + BoolToStr(fTCPClient.Connected) );
end;

procedure TMyTCPClientThreadSafe.Close;
begin
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient CLOSE');
  Lock;
  fTCPClient.Close;
  Unlock;
end;

function TMyTCPClientThreadSafe.IsOpen: boolean;
begin
  Result := false;
  if fTCPClient=nil then exit;
  Result :=  fTCPClient.Connected;
end;

procedure TMyTCPClientThreadSafe.MyOnDisconnectHandle(Sender: TObject);
begin
  if fTCPClient<>nil then fTCPClient.Close;
end;

procedure TMyTCPClientThreadSafe.ConfigureTCP( server: string; port: string);
begin
  fServer := server;
  fPort := port;
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient configure: ' + fServer + ':' + fPort );
  Lock;
    fTCPClient.remotehost := server;
    fTCPClient.remoteport := port;
  Unlock;
  fConfigured := true;
end;

function TMyTCPClientThreadSafe.ClearInputBuffer: longint; //reads and throws out any waiting incoming data (returns number of them)
Var
  buf: TMyIntBuf;
begin
  Result := 0;
  if fTCPClient=nil then exit;
  if not fTCPClient.Connected then exit;
  Lock;
    while fTCPClient.WaitForData(0) do                       //WSAAsyncSelect(), WSAAsyncEvent(), or select().
      begin
          Result := Result + fTCPClient.ReceiveBuf(buf, CIntBufSize); //clear input buffer  by reading all inside
      end;
  Unlock;
end;


function TMyTCPClientThreadSafe.SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
Var
  n, sent, k: longint;
  t0: longword;
  buf2: TMyIntBuf;
begin
  Result := false;
  elapsedMS := 0;
  if fTCPClient=nil then exit;
  if not fTCPClient.Connected then
    begin
      xLogMsg('TCPClient SendStringRaw:  Not Connected');
      exit;
    end;
  if fDebug then  xLogMsg('ii TCPClientSendStringRaw: ' + BinStrToPrintStr(s));
  Lock;
  //divide into chunks and send
  sent := 0;
  n := length(s);
  if n>CIntBufSize then n := CIntBufSize;
  //setlength(buf2, n);
  for k:=0 to n-1 do buf2[k] := s[k+1];
  t0 := TimeDeltaTICKgetT0;
  //WaitFordata(0);
  sent := fTCPClient.SendBuf(buf2, n);
  elapsedms := TimeDeltaTICKNowMS( t0 );
  if (sent=n) then Result := true;
  Unlock;
  if fDebug then  xLogMsg('     result: ' + BoolToStr(Result) + ' timeMS: '  + IntToStr( elapsedMS ) );
end;






function TMyTCPClientThreadSafe.ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
Var
  i, nbuf: longint;
  buf: TMyIntBuf;
  e, tout: boolean;
  t0: longword;
  emsg: string;
begin
  Result := false;
  s := '';
  lenout := 0;
  if fTCPClient=nil then exit;
  if not fTCPClient.Connected then
    begin
      xLogMsg('TCPClientREADStringRaw:  Not Connected');
      exit;
    end;
  if fDebug then  xLogMsg('ii TCPClientREADStringRaw');
  Lock;
  //!!!CALL WAITFORDATA
  //read all waiting data (within timeout)
  e:= false;
  tout := true;
  emsg := '';
  nbuf := 0;
  t0 := TimeDeltaTICKgetT0;
  if fTCPClient.WaitForData(timeout) then
    begin
        try
          nbuf := fTCPClient.ReceiveBuf(buf, CIntBufSize);
          tout := false;
        except
          on Exc: Exception do
            begin
             emsg := Exc.Message;
             e := true;
             nbuf := 0;
            end;
        end;
        if nbuf>0 then
          begin
            for i:=1 to nbuf do s := s + buf[i-1];
            lenout := nbuf;
          end;
    end;
  Unlock;
  if tout then xLogMsg('TCPClientREADStringRaw:  Timeout!');
  if e then xLogMsg('TCPClientREADStringRaw:  Error: ' + emsg);
  if fDebug then  xLogMsg('     result N: ' + IntToStr( nbuf) + ' received: ' + BinStrToPrintStr(s) );
  Result := not e;
end;


procedure TMyTCPClientThreadSafe.AssignLogProc(logproc: TLogProcedureThreadSafe);
begin
  fLogProc := logproc;
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





//***************************************************************

constructor TMyExtendedTcpClient.Create;
begin
  inherited Create(nil);
  FConnectInProgress := false;
end;


procedure TMyExtendedTcpClient.Open;
begin
  FConnectInProgress := true;
  //Showmessage( 'h:'+remotehost + ' p:' + remoteport);
  try
    inherited Open;
  finally
    FConnectInProgress := false;
  end;
end;


procedure TMyExtendedTcpClient.Close;
begin
  FConnectInProgress := false;
  inherited Close;
end;





end.




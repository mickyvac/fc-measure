unit MyTCPClient_old;

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

Uses SysUtils, sockets, myutils, dateutils, MyThreadUtils;


Const
  CIntBufSize = 4096;

type

  TMyIntBuf = array[0..CIntBufSize] of char;

type

  TMyExtendedTcpClient = class(TTcpClient)
    //will use blocking mode - expect to be used inside worker thread
  public
      constructor Create;
  private
    FConnectInProgress: boolean;
  public
    //general
    procedure Open; override;   //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
    procedure Close; override;
//    function IsOpen: boolean;
    procedure ConfigureTCP( server: string; port: string);
    //comm
    function ClearInputBuffer: longint; //reads and throws out any waiting incoming data (returns number of them)
    function SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
    function ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;

    //other
//    procedure AssignLogProc(logproc: TLogProcedure);
  private
      fConfigured: boolean;  //MUST not try open if not configured - set after call to configure
      fDebug: boolean;
      fLogProc: TLogProcedureThreadSafe; //helper - assigned from thread to enable logging if enabled
      fLogMsgLock: TMyLockableObject;  //lock to access fLogProc (in case from other thread by any chance)
  private
//      procedure xLogMsg(s: string);
  public
    property IsConnectInProgress: boolean read FConnectInProgress;
//    property ConfHost: string read fServer;
//    property ConfPort: string read fPort;
    property Debug: boolean read fDebug write fDebug;
  end;




  TExtTCPClientThreadSafe = class (TMyLockableObject)  //(TMultiReadExclusiveWriteSynchronizer)
    public
      constructor Create;
      destructor Destroy; override;
    public
      fTCPClient: TMyExtendedTcpClient;    //!!!!!!main communication component             //unit sockets
  end;



implementation

Uses Dialogs;

constructor TMyExtendedTcpClient.Create;
begin
  inherited Create(nil);
  fConfigured := false;
  FConnectInProgress := false;
end;


procedure TMyExtendedTcpClient.Open;
begin
  if not fConfigured then
    begin
      exit;
//      xLogMsg('TCPCLient: Open: not configured!');
    end;
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

procedure TMyExtendedTcpClient.ConfigureTCP( server: string; port: string);
begin
  remotehost := server;
  remoteport := port;
  fConfigured := true;
end;

function TMyExtendedTcpClient.ClearInputBuffer: longint; //reads and throws out any waiting incoming data (returns number of them)
Var
  buf: TMyIntBuf;
begin
  Result := 0;
  if not Connected then exit;
  while WaitForData(0) do                       //WSAAsyncSelect(), WSAAsyncEvent(), or select().
    begin
        Result := Result + ReceiveBuf(buf, CIntBufSize); //clear input buffer
    end;
end;


function TMyExtendedTcpClient.SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
Var
  n, sent, k: longint;
  t0: longword;
  buf2: TMyIntBuf;
begin
  Result := false;
  elapsedms := 0;
  if not Connected then exit;
  //divide into chunks and send
  sent := 0;
  n := length(s);
  if n>CIntBufSize then n := CIntBufSize;
  //setlength(buf2, n);
  for k:=0 to n-1 do buf2[k] := s[k+1];
  t0 := TimeDeltaTICKgetT0;
  //WaitFordata(0);
  sent := SendBuf(buf2, n);
  elapsedms := TimeDeltaTICKNowMS( t0 );
  if (sent=n) then Result := true;
end;






function TMyExtendedTcpClient.ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
Var
  i, nbuf: longint;
  buf: TMyIntBuf;
  e: boolean;
  t0: longword;
begin
  Result := false;
  s := '';
  lenout := 0;
  e:= false;
  if not Connected then exit;
  //!!!CALL WAITFORDATA
  //read all waiting data (within timeout)
  t0 := TimeDeltaTICKgetT0;
  while WaitForData(timeout) do
      begin
        try
          nbuf := ReceiveBuf(buf, CIntBufSize);
        except
          e := true;
          nbuf := 0;
          break;
        end;
        if nbuf>0 then
          begin
            for i:=1 to nbuf do s := s + buf[i-1];
            Inc(lenout, nbuf);
          end;
        timeout := timeout - TimeDeltaTICKNowMS( t0);
        if timeout<2 then break;
      end;
  Result := not e;
end;




constructor TExtTCPClientThreadSafe.Create;
begin
  inherited create( 20000 );
  fTCPClient := TMyExtendedTcpClient.Create;
end;

destructor TExtTCPClientThreadSafe.Destroy;
begin
  fTCPClient.Destroy;
  inherited;
end;




end.




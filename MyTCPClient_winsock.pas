unit MyTCPClient_winsock;

{

  this unit uses code publish at delphibasics - by Aphex
  * 
  http://www.delphibasics.info/home/delphibasicssnippets/socketunitbyaphex
  * 

}



interface

Uses SysUtils, sockets, myutils, dateutils, myLockableObject,
  Windows, Winsock;


Const
  CIntBufSize = 4096;

type

  TMyIntBuf = array[0..CIntBufSize] of char;




{
  Delphi Winsock 1.1 Library by Aphex
}

type
  TTransferCallback = procedure(BytesTotal: dword; BytesDone: dword);

  TClientSocket = class(TObject)
  private
    FAddress: pchar;
    FData: pointer;
    FTag: integer;
    FConnected: boolean;
    function GetLocalAddress: string;
    function GetLocalPort: integer;
    function GetRemoteAddress: string;
    function GetRemotePort: integer;
  protected
    FSocket: TSocket;
  public
    procedure Connect(Address: string; Port: integer);
    property Connected: boolean read FConnected;
    property Data: pointer read FData write FData;
    destructor Destroy; override;
    procedure Disconnect;
    function Idle(Seconds: integer): Boolean;
    property LocalAddress: string read GetLocalAddress;
    property LocalPort: integer read GetLocalPort;
    function ReceiveBuffer(var Buffer; BufferSize: integer): integer;
    procedure ReceiveFile(FileName: string; TransferCallback: TTransferCallback);
    function ReceiveLength: integer;
    function ReceiveString: string;
    property RemoteAddress: string read GetRemoteAddress;
    property RemotePort: integer read GetRemotePort;
    function SendBuffer(var Buffer; BufferSize: integer): integer;
    procedure SendFile(FileName: string; TransferCallback: TTransferCallback);
    function SendString(const Buffer: string): integer;
    property Socket: TSocket read FSocket;
    property Tag: integer read FTag write FTag;
  end;

  TServerSocket = class(TObject)
  private
    FListening: boolean;
    function GetLocalAddress: string;
    function GetLocalPort: integer;
  protected
    FSocket: TSocket;
  public
    function Accept: TClientSocket;
    destructor Destroy; override;
    procedure Disconnect;
    procedure Idle;
    procedure Listen(Port: integer);
    property Listening: boolean read FListening;
    property LocalAddress: string read GetLocalAddress;
    property LocalPort: integer read GetLocalPort;
  end;


{
  end Delphi Winsock 1.1 Library by Aphex
}


type



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
      fTCPClient: TClientSocket;    //!!!!!!main communication component             //unit sockets
    private
      fConfigured: boolean;  //MUST not try open if not configured - set after call to configure
      fDebug: boolean;
      fLogProc: TLogProcedureThreadSafe; //helper - assigned from thread to enable logging if enabled
      fLogMsgLock: TMyLockableObject;  //lock to access fLogProc (in case from other thread by any chance)
      fServer: string;
      fPort: string;
      fConnectionLost: boolean;
      fWasConnected: boolean;
    protected
      procedure xLogMsg(s: string);
      procedure MyOnDisconnectHandle(Sender: TObject);
    public
      property ConfHost: string read fServer;
      property ConfPort: string read fPort;
      property Debug: boolean read fDebug write fDebug;
      property IsConfigured: boolean read fConfigured;
      property ConnectionLost: boolean read fConnectionLost;
    end;







var
  WSAData: TWSAData;



implementation

Uses Dialogs;


constructor TMyTCPClientThreadSafe.Create;
begin
  inherited create( 10000 );
  fTCPClient := TClientSocket.Create;
  //fTCPClient.OnDisconnect := MyOnDisconnectHandle;
  fLogMsgLock := TMyLockableObject.Create(10000);
  fConfigured := false;
  fDebug := false;
  fLogProc := nil;
  fServer := 'localhost';
  fPort := '20005';
  fConnectionLost := false;
  fWasConnected := false;
end;

destructor TMyTCPClientThreadSafe.Destroy;
begin
  fTCPClient.Destroy;
  fLogMsgLock.Destroy;
  inherited;
end;



procedure TMyTCPClientThreadSafe.Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
begin
  //fWasConnected := false;
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
  fTCPClient.Connect( fServer, StrToIntDef( fPort, 20005 ) );
  if  fTCPClient.Connected then
    begin
      fWasConnected := true;
      fConnectionLost := false;
    end;
  xLogMsg('      result: ' + BoolToStr(fTCPClient.Connected) );
end;

procedure TMyTCPClientThreadSafe.Close;
begin
  fConnectionLost := false;
  fWasConnected := false;
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient going to CLOSE');
  Lock;
  if fTCPClient.Connected then fTCPClient.Disconnect;
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
  if fTCPClient<>nil then fTCPClient.Disconnect;
end;

procedure TMyTCPClientThreadSafe.ConfigureTCP( server: string; port: string);
begin
  fServer := server;
  fPort := port;
  if fTCPClient=nil then exit;
  xLogMsg('TCPClient configure: ' + fServer + ':' + fPort );
  //Lock;
   //fTCPClient.remotehost := server;
    //fTCPClient.remoteport := port;
 //Unlock;
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
    while fTCPClient.ReceiveLength>0 do                       //WSAAsyncSelect(), WSAAsyncEvent(), or select().
      begin
          Result := Result + fTCPClient.ReceiveBuffer(buf, CIntBufSize); //clear input buffer  by reading all inside
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
      if fWasConnected then
        begin
          fConnectionLost := true;
          xLogMsg('TCPClient SendStringRaw:  Connection LOST!!!');
          exit;
        end
      else xLogMsg('TCPClient SendStringRaw:  Not Connected');
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
  sent := fTCPClient.SendBuffer(buf2, n);
  elapsedms := TimeDeltaTICKNowMS( t0 );
  if (sent=n) then Result := true;
  Unlock;
  if fDebug then  xLogMsg('     result: ' + BoolToStr(Result) + ' timeMS: '  + IntToStr( elapsedMS ) );
end;






function TMyTCPClientThreadSafe.ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
Var
  i, nbuf, reccode: longint;
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
      if fWasConnected then
        begin
          fConnectionLost := true;
          xLogMsg('TCPClient SendStringRaw:  Connection LOST!!!');
          exit;
        end;
      xLogMsg('TCPClientREADStringRaw:  Not Connected');
      Open;
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
   while tout and (TimeDeltaTICKNowMS(t0)<timeout) do
     begin
		   if fTCPClient.ReceiveLength>0 then
		    begin
		        try
		          nbuf := fTCPClient.ReceiveBuffer(buf, CIntBufSize);
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



//***************************************************************



procedure TClientSocket.Connect(Address: string; Port: integer);
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
begin
  Disconnect;
  FAddress := pchar(Address);
  FSocket := Winsock.socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  SockAddrIn.sin_family := AF_INET;
  SockAddrIn.sin_port := htons(Port);
  SockAddrIn.sin_addr.s_addr := inet_addr(FAddress);
  if SockAddrIn.sin_addr.s_addr = INADDR_NONE then
  begin
    HostEnt := gethostbyname(FAddress);
    if HostEnt = nil then
    begin
      Exit;
    end;
    SockAddrIn.sin_addr.s_addr := Longint(PLongint(HostEnt^.h_addr_list^)^);
  end;
  Winsock.Connect(FSocket, SockAddrIn, SizeOf(SockAddrIn));
  FConnected := True;
end;

procedure TClientSocket.Disconnect;
begin
  closesocket(FSocket);
  FConnected := False;
end;

function TClientSocket.GetLocalAddress: string;
var
  SockAddrIn: TSockAddrIn;
  Size: integer;
begin
  Size := sizeof(SockAddrIn);
  getsockname(FSocket, SockAddrIn, Size);
  Result := inet_ntoa(SockAddrIn.sin_addr);
end;

function TClientSocket.GetLocalPort: integer;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Size := sizeof(SockAddrIn);
  getsockname(FSocket, SockAddrIn, Size);
  Result := ntohs(SockAddrIn.sin_port);
end;

function TClientSocket.GetRemoteAddress: string;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Size := sizeof(SockAddrIn);
  getpeername(FSocket, SockAddrIn, Size);
  Result := inet_ntoa(SockAddrIn.sin_addr);
end;

function TClientSocket.GetRemotePort: integer;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Size := sizeof(SockAddrIn);
  getpeername(FSocket, SockAddrIn, Size);
  Result := ntohs(SockAddrIn.sin_port);
end;

function TClientSocket.Idle(Seconds: integer): Boolean;
var
  FDset: TFDset;
  TimeVal: TTimeVal;
begin
  if Seconds = 0 then
  begin
    FD_ZERO(FDSet);
    FD_SET(FSocket, FDSet);
    Result := select(0, @FDset, nil, nil, nil) > 0;
  end
  else
  begin
    TimeVal.tv_sec := Seconds;
    TimeVal.tv_usec := 0;
    FD_ZERO(FDSet);
    FD_SET(FSocket, FDSet);
    Result := select(0, @FDset, nil, nil, @TimeVal) > 0;
  end;
end;

function TClientSocket.ReceiveLength: integer;
begin
  Result := ReceiveBuffer(pointer(nil)^, -1);
end;

function TClientSocket.ReceiveBuffer(var Buffer; BufferSize: integer): integer;
begin
  if BufferSize = -1 then
  begin
    if ioctlsocket(FSocket, FIONREAD, Longint(Result)) = SOCKET_ERROR then
    begin
      Result := SOCKET_ERROR;
      Disconnect;
    end;
  end
  else
  begin
     Result := recv(FSocket, Buffer, BufferSize, 0);
     if Result = 0 then
     begin
       Disconnect;
     end;
     if Result = SOCKET_ERROR then
     begin
       Result := WSAGetLastError;
       if Result = WSAEWOULDBLOCK then
       begin
         Result := 0;
       end
       else
       begin
         Disconnect;
       end;
     end;
  end;
end;

function TClientSocket.ReceiveString: string;
begin
  SetLength(Result, ReceiveBuffer(pointer(nil)^, -1));
  SetLength(Result, ReceiveBuffer(pointer(Result)^, Length(Result)));
end;

procedure TClientSocket.ReceiveFile(FileName: string; TransferCallback: TTransferCallback);
var
  BinaryBuffer: pchar;
  BinaryFile: THandle;
  BinaryFileSize, BytesReceived, BytesWritten, BytesDone: dword;
begin
  BytesDone := 0;
  BinaryFile := CreateFile(pchar(FileName), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  Idle(0);
  ReceiveBuffer(BinaryFileSize, sizeof(BinaryFileSize));
  while BytesDone < BinaryFileSize do
  begin
    Sleep(1);
    BytesReceived := ReceiveLength;
    if BytesReceived > 0 then
    begin
      GetMem(BinaryBuffer, BytesReceived);
      try
        ReceiveBuffer(BinaryBuffer^, BytesReceived);
        WriteFile(BinaryFile, BinaryBuffer^, BytesReceived, BytesWritten, nil);
        Inc(BytesDone, BytesReceived);
        if Assigned(TransferCallback) then TransferCallback(BinaryFileSize, BytesDone);
      finally
        FreeMem(BinaryBuffer);
      end;
    end;
  end;
  CloseHandle(BinaryFile);
end;

procedure TClientSocket.SendFile(FileName: string; TransferCallback: TTransferCallback);
var
  BinaryFile: THandle;
  BinaryBuffer: pchar;
  BinaryFileSize, BytesRead, BytesDone: dword;
begin
  BytesDone := 0;
  BinaryFile := CreateFile(pchar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  BinaryFileSize := GetFileSize(BinaryFile, nil);
  SendBuffer(BinaryFileSize, sizeof(BinaryFileSize));
  GetMem(BinaryBuffer, 2048);
  try
    repeat
      Sleep(1);
      ReadFile(BinaryFile, BinaryBuffer^, 2048, BytesRead, nil);
      Inc(BytesDone, BytesRead);
      repeat
        Sleep(1);
      until SendBuffer(BinaryBuffer^, BytesRead) <> -1;
      if Assigned(TransferCallback) then TransferCallback(BinaryFileSize, BytesDone);
    until BytesRead < 2048;
  finally
    FreeMem(BinaryBuffer);
  end;
  CloseHandle(BinaryFile);
end;

function TClientSocket.SendBuffer(var Buffer; BufferSize: integer): integer;
var
  ErrorCode: integer;
begin
  Result := send(FSocket, Buffer, BufferSize, 0);
  if Result = SOCKET_ERROR then
  begin
    ErrorCode := WSAGetLastError;
    if (ErrorCode = WSAEWOULDBLOCK) then
    begin
      Result := -1;
    end
    else
    begin
      Disconnect;
    end;
  end;
end;

function TClientSocket.SendString(const Buffer: string): integer;
begin
  Result := SendBuffer(pointer(Buffer)^, Length(Buffer));
end;

destructor TClientSocket.Destroy;
begin
  inherited Destroy;
  Disconnect;
end;

procedure TServerSocket.Listen(Port: integer);
var
  SockAddrIn: TSockAddrIn;
begin
  Disconnect;
  FSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  SockAddrIn.sin_family := AF_INET;
  SockAddrIn.sin_addr.s_addr := INADDR_ANY;
  SockAddrIn.sin_port := htons(Port);
  bind(FSocket, SockAddrIn, sizeof(SockAddrIn));
  FListening := True;
  Winsock.listen(FSocket, 5);
end;

function TServerSocket.GetLocalAddress: string;
var
  SockAddrIn: TSockAddrIn;
  Size: integer;
begin
  Size := sizeof(SockAddrIn);
  getsockname(FSocket, SockAddrIn, Size);
  Result := inet_ntoa(SockAddrIn.sin_addr);
end;

function TServerSocket.GetLocalPort: integer;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Size := sizeof(SockAddrIn);
  getsockname(FSocket, SockAddrIn, Size);
  Result := ntohs(SockAddrIn.sin_port);
end;

procedure TServerSocket.Idle;
var
  FDset: TFDset;
begin
  FD_ZERO(FDSet);
  FD_SET(FSocket, FDSet);
  select(0, @FDset, nil, nil, nil);
end;

function TServerSocket.Accept: TClientSocket;
var
  Size: integer;
  SockAddr: TSockAddr;
begin
  Result := TClientSocket.Create;
  Size := sizeof(TSockAddr);
  Result.FSocket := Winsock.accept(FSocket, @SockAddr, @Size);
  if Result.FSocket = INVALID_SOCKET then
  begin
    Disconnect;
  end
  else
  begin
    Result.FConnected := True;
  end;
end;

procedure TServerSocket.Disconnect;
begin
  FListening := False;
  closesocket(FSocket);
end;

destructor TServerSocket.Destroy;
begin
  inherited Destroy;
  Disconnect;
end;

initialization
  WSAStartUp(257, WSAData);

finalization
  WSACleanup;

end.





end.




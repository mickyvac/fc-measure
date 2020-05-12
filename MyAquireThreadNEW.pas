unit MyAquireThreadNEW;

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, Logger, ConfigManager,
  MyTCPClient,  sockets, myThreadUtils, loggerThreadsafe;


type

  TMyExecuteMethod = procedure of object;

  TAquireThreadBaseV2 = class (TThread)       //TMultiReadExclusiveWriteSynchronizer
  //!!!!!NOTE!!!!
  //descendant must define ExecuteInnerLoop; instead of execute;
    public
      constructor Create( Myexm: TMyExecuteMethod);
      destructor Destroy; override;
      procedure Execute; override;  //EExecute is defined here-> !!! Descendat must use EXECUTEINNERLOOP
      procedure ProcessConfigurationRequests; virtual; //here it is empty proc - but in descendant it may handle
                                    //configuration of clients etc. Called from within execute
    public
      procedure SetUserSuspend;
      procedure ResetUserSuspend;
      procedure TerminateAndWaitForExecuteFinish;
      function IsThreadRunning(): boolean;
      function getThreadStatusStr: string;
    protected
      fExecuteMethod: TMyExecuteMethod;
      fLastCycleMS: longword;
      fExecuteFinished: boolean; //signal when exetcute is finished - importatnt : HAVE TO WAIT BEFORE DESTOYING OBJECTS
    private
      fUserSuspendReq: boolean;  //user supension is check in side the CheckAndProcessRequests;
      fFlagSuspend: boolean;
    public
      property LastCycleMS: longword read fLastCycleMS;
      property ExecuteFinished: boolean read fExecuteFinished;
      property UserSuspendActive: boolean read fFlagSuspend;
  end;





//*********************************

implementation

Uses Windows;



constructor TAquireThreadBaseV2.Create( Myexm: TMyExecuteMethod);
begin
  inherited Create(true); //createsuspended=true
  fExecuteMethod := myexm;
  FreeOnTerminate := false;
  fFlagSuspend := false;
  fUserSuspendReq := false;
  fExecuteFinished := false;
end;

destructor TAquireThreadBaseV2.Destroy;
Var
 i: integer;
begin
  //damn !!! this is run from context of main thread - must wait here for thred to terminate - I observed, that the execute was still running
  //even after log was destroyed apparently!!!
  //while not fExecuteFinished do begin sleep(10) end;
  Terminate;
  if not suspended then Waitfor;
  if FatalException<>nil then ShowMessage('THREad - Fatal exception ' + FatalException.ClassName );
  inherited;
end;


procedure TAquireThreadBaseV2.Execute;
Var
  t0, dtMS: longword;
begin
  fExecuteFinished := false;
  if not assigned(fExecuteMethod) then Terminate;
  //
  while not Terminated do
    begin
	    //
      ProcessConfigurationRequests;  
	    while fUserSuspendReq and (not Terminated) do
	      begin
          t0 := TimeDeltaTICKgetT0;
	        fFlagSuspend := true;
          ProcessConfigurationRequests;
	        Sleep(80);
          fLastCycleMS := TimeDeltaTICKNowMS( t0 );
	      end;
	    fFlagSuspend := false;
      //
	    //time metrics
	    t0 := TimeDeltaTICKgetT0;
	    //
      try
	      fExecuteMethod;
      except
          on E: exception do ShowMessage( E.Message );
      end;

	    //
	    fLastCycleMS := TimeDeltaTICKNowMS( t0 );
    end;
  ReturnValue := 0;
  fExecuteFinished := true;
end;


procedure TAquireThreadBaseV2.ProcessConfigurationRequests;
begin
end;

procedure TAquireThreadBaseV2.SetUserSuspend;
begin
  fUserSuspendReq := true;
end;

procedure TAquireThreadBaseV2.ResetUserSuspend;
begin
  fUserSuspendReq := false;
  Resume;  //just in case
end;


procedure TAquireThreadBaseV2.TerminateAndWaitForExecuteFinish;
Var
 i: integer;
begin        //run from context of main thread!
   Terminate;
   //!!! wait to terminate
   i :=200;
   while (not fExecuteFinished) do
      begin
          sleep(100);
          Dec(i);
          if i<1 then break; //force quit waiting if takes too long
      end;
   if i<1 then ShowMessage( 'MyThread:  Wait for execute FINISH failed - timeout');
end;



function TAquireThreadBaseV2.IsThreadRunning(): boolean;
begin
  Result := (not Terminated) and (not Suspended) and (not fFlagSuspend);
end;

function TAquireThreadBaseV2.getThreadStatusStr: string;
begin
  Result := '???';
  if Suspended then Result := 'Suspended';
  if Terminated then Result := 'Terminated';
  if Terminated and Suspended then Result := 'Suspended+Terminated';
  if (not Terminated) and (not Suspended) then Result := 'Running...';
  //uses suspend
  if fFlagSuspend then Result := Result + '/ UserSuspend';
end;


procedure MyThreadProcessMessages;
    //need to process received messages from system, because that is the way how this implementation of serial port works!!!
    //but should not use ApplicationProcessMessages inside a thread -> so I use my own loop fro processing
    //found here:  http://stackoverflow.com/questions/15467263/how-do-i-forcibly-process-messages-inside-a-thread (Remy Lebeau)
var
  Msg: TMsg;
begin
      while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
end;




end.




//*********************************



implementation

Uses Windows;




constructor TTCPAquireThreadBase.Create;
begin
  inherited Create; //createsuspended=true
  fcomsync := TExtTCPClientThreadSafe.Create;
  fThreadId := 'TCPBase';
  fComLock := false;
  fUpdateConfRequested := false;
  fNewServer := 'localhost';
  fNewPort := '20005';
  fCloseComRequested := false;
  fOpenComRequested := false;
end;

procedure TTCPAquireThreadBase.BeforeDestroy;
//in order to disconnect and destroy tcpclient; inside destroy it caused trouble
begin
  if fcomsync<>nil then fcomsync.Destroy;
end;





constructor TTCPAquireThreadBase.Create;
begin
  inherited Create; //createsuspended=true
  fcomsync := TExtTCPClientThreadSafe.Create;
  //fSyncMsgLock := TMyLockableObject.Create(1000);

  fThreadId := 'TCPBase';
  fComLock := false;
  fUpdateConfRequested := false;
  fNewServer := 'localhost';
  fNewPort := '20005';
  fCloseComRequested := false;
  fOpenComRequested := false;
end;

procedure TTCPAquireThreadBase.BeforeDestroy;
//in order to disconnect and destroy tcpclient; inside destroy it caused trouble
begin
  if fcomsync<>nil then fcomsync.Destroy;
  //fSyncMsgLock.Destroy;
end;


destructor TTCPAquireThreadBase.Destroy;
begin
  inherited;
end;


procedure TTCPAquireThreadBase.ProcessConfigurationRequests;
      //this method must be periodically called from withing execute!!!!
      //in order to process requests opening, closing and configuration for TCPClient   !!!!!!!
Var
  com: TMyExtendedTcpClient;
begin
  //when this method executes -> that means receive is not executing (same thread) and access to com synchro is free, no chance of deadlock
  //process in this order: 1) close, 2) reconf/restart 3) open
  if fcomsync=nil then exit;
  com := fcomsync.fTCPClient;
  if com=nil then exit;
  //1)
  if fCLoseComRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient Close...');
      fcomsync.BeginWrite;
        if fTCPConnected then com.Close;
        fTCPConnected := com.Connected;
      fcomsync.EndWrite;
      fCLoseComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
  //2)
  if fUpdateConfRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient UpdateConf...');
      //fcomsync.BeginWrite;
        if com.Connected then com.Close;
        fTCPConnected := com.Connected;
        com.RemoteHost := fNewServer;
        com.RemotePort := fNewPort;
        fTCPserver := fNewServer;
        fTCPport := fNewPort;
        //fOpenComRequested := true;  no - not automatically open
      //fcomsync.EndWrite;
      fUpdateConfRequested := false;
      LeaveLogMsg('  NEW port conf is: ' + fNewServer + ':'+ fNewPort );
    end;
  //3)
  if fOpenComRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient OPEN port...');
      //fcomsync.BeginWrite;
        if not com.Connected then com.Open;
        fComLock := false;
        fTCPConnected := com.Connected;
      //fcomsync.EndWrite;
      fOpenComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
   //*** even if there were no requeste, update current status into cache
   //fcomsync.BeginRead;
        fTCPConnected := com.Connected;
        fTCPserver :=  com.RemoteHost;
        ftcpPort :=  com.RemotePort;
       // fTCPRx :=  com.BytesReceived;
       // fTCPTx :=  com.BytesSent;
   //fcomsync.EndRead;
end;


//    private
//      fcomsync: TExtTCPClientThreadSafe;  //locked access because of possible change of configuration -
                                         //this is only reference to the client object,   //the OBJECT is OWNED by the ROOT INTERFACE
//      function IsEndOfMessage(Const recvbuf: string): boolean; virtual; abstract;  //descendadnt must define this for communication to work
                                                                                   // used by SendReceive
      //
function TTCPAquireThreadBase.SendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //this is defined here
Var
  com: TMyExtendedTcpClient;
  n, i, inbuf: longint;
  bs, br: boolean;
  dtout: TDateTime;
  tout: boolean;
  s, replyprint: string;
  t0, dursendms, durallms: longword;
  intreply: string;
begin
  Result := false;
  if fComLock then     //need to check beacuse using porcessmessages
    begin
     LeaveLogMsg('SendReceive: detected event of reentrance');
     exit;  //that would be signal of reeentry ... (assuming somebody did not forgot to unlock ;)
    end;
  if fcomsync=nil then exit;
  com := fcomsync.fTCPClient;
  if com=nil then exit;
  if not com.Connected then
    begin
      if fDebug then LeaveLogMsg('SendReceive: NOT CONNECTED');
      exit;
    end;
  fComLock := true;
  //do not forget to unlock
  if fDebug then LeaveLogMsg('SendReceive: start');
  if fcomsync.IsLocked then
    begin
      LeaveLogMsg('SendReceive: comsync is locked!!');
      fComLock := false;
      exit;
    end;
  if fDebug then LeaveLogMsg('Sending: '+ BinStrToPrintStr(cmd) );
  //fcomsync.BeginWrite;         //it is not good idea to call synchronize inside critical section in thread, that can also be accessed from the main thread
     if ClearInBuf then
       begin
         inbuf := com.ClearInputBuffer;
       end;
     //send
     try
       bs := Com.SendStringRaw(cmd, 100, dursendms);
     except
       on E: exception do begin LeaveLogMsg('SendReceive: got exc on sendstr: ' + E.message); bs := false; end;
     end;
     //receive
     //MUS NOT USE NOW porbably is not THREAD SAFE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     t0 := TimeDeltaTICKgetT0;
     reply := '';
     intreply := '';
     tout := true;
     //if fDebug then LeaveLogMsg('SendReceive: wait for reply');
     while TimeDeltaTICKNowMS(t0)<timeout do
       begin
         //MyThreadProcessMessages;    //TODO!!!!!!!!!!! Disable it or not?
         try
           br := Com.ReadStringRaw(s, n, 10);    //will try to read every 5ms - that should be enough small delay
         except
           on E: exception do begin LeaveLogMsg('SendReceive: got exc on readstr: ' + E.message); br := false; end;
         end;
         if not br then break;
 //TODO !!!!!!        if fDebug then LeaveLogMsg('SendReceive: Received str: '+ BinStrToPrintStr(s) );
         intreply := intreply + s;
         if IsEndOfMessage( intreply ) then
           begin
             tout := false;
             break;
           end;
       end;
  //fcomsync.EndWrite;
     durallms := TimeDeltaTICKNowMS( t0);
     if fDebug then LeaveLogMsg('Sent in ms: '+ IntToStr( dursendms) + '  receive in ms: ' + IntToStr( durallms));

  fComLock := false;
  replyprint := BinStrToPrintStr(intreply);
  if fDebug then LeaveLogMsg('SendReceive: Finally Received str: '+ replyprint );
  if fDebug and tout then LeaveLogMsg('SendReceive: timeout' );
  if inbuf>0 then LeaveLogMsg('SendReceive: there were some  chars in receive buffer n='+ IntToStr(inbuf) );
  Result := bs and br and (not tout);
  if result then reply := intreply;
end;






procedure TTCPAquireThreadBase.OpenCom;      //called from main thread, must not block
begin
  fOpenComRequested := true;
end;


procedure TTCPAquireThreadBase.CloseCom;               //called from main thread, must not block
begin
  fCloseComRequested := true;
end;

function TTCPAquireThreadBase.isComConnected(): boolean;
begin
    Result := fTCPConnected;
end;


procedure TTCPAquireThreadBase.ResetConnection;
begin
  fUpdateConfRequested := true; //that will make reset with usening current configuration
  fOpenComRequested := true;  //after update this will connect
end;

procedure TTCPAquireThreadBase.ConfigureTCP( server: string; port: string);
//called from main thread,  must not block
begin
   fNewServer := server + '';   //force COPY
   fNewPort := port+ '';
   fUpdateConfRequested := true;
end;


procedure TTCPAquireThreadBase.getTCPConf( Var server: string; Var port: string);
//called from main thread, must not block
begin
  server := fNewServer;
  port := fNewPort;
end;

procedure TTCPAquireThreadBase.ForcedClose;
begin
  if fcomsync=nil then exit;
  if fcomsync.fTCPClient=nil then exit;
  fcomsync.fTCPClient.Close;
end;





destructor TTCPAquireThreadBase.Destroy;
begin
  inherited;
end;


procedure TTCPAquireThreadBase.ProcessConfigurationRequests;
      //this method must be periodically called from withing execute!!!!
      //in order to process requests opening, closing and configuration for TCPClient   !!!!!!!
Var
  com: TMyExtendedTcpClient;
begin
  //when this method executes -> that means receive is not executing (same thread) and access to com synchro is free, no chance of deadlock
  //process in this order: 1) close, 2) reconf/restart 3) open
  if fcomsync=nil then exit;
  com := fcomsync.fTCPClient;
  if com=nil then exit;
  //1)
  if fCLoseComRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient Close...');
      fcomsync.BeginWrite;
        if fTCPConnected then com.Close;
        fTCPConnected := com.Connected;
      fcomsync.EndWrite;
      fCLoseComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
  //2)
  if fUpdateConfRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient UpdateConf...');
      //fcomsync.BeginWrite;
        if com.Connected then com.Close;
        fTCPConnected := com.Connected;
        com.RemoteHost := fNewServer;
        com.RemotePort := fNewPort;
        fTCPserver := fNewServer;
        fTCPport := fNewPort;
        //fOpenComRequested := true;  no - not automatically open
      //fcomsync.EndWrite;
      fUpdateConfRequested := false;
      LeaveLogMsg('  NEW port conf is: ' + fNewServer + ':'+ fNewPort );
    end;
  //3)
  if fOpenComRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient OPEN port...');
      //fcomsync.BeginWrite;
        if not com.Connected then com.Open;
        fComLock := false;
        fTCPConnected := com.Connected;
      //fcomsync.EndWrite;
      fOpenComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
   //*** even if there were no requeste, update current status into cache
   //fcomsync.BeginRead;
        fTCPConnected := com.Connected;
        fTCPserver :=  com.RemoteHost;
        ftcpPort :=  com.RemotePort;
       // fTCPRx :=  com.BytesReceived;
       // fTCPTx :=  com.BytesSent;
   //fcomsync.EndRead;
end;


//    private
//      fcomsync: TExtTCPClientThreadSafe;  //locked access because of possible change of configuration -
                                         //this is only reference to the client object,   //the OBJECT is OWNED by the ROOT INTERFACE
//      function IsEndOfMessage(Const recvbuf: string): boolean; virtual; abstract;  //descendadnt must define this for communication to work
                                                                                   // used by SendReceive
      //
function TTCPAquireThreadBase.SendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //this is defined here
Var
  com: TMyExtendedTcpClient;
  n, i, inbuf: longint;
  bs, br: boolean;
  dtout: TDateTime;
  tout: boolean;
  s, replyprint: string;
  t0: longword;
  intreply: string;
begin
  Result := false;
  if fComLock then     //need to check beacuse using porcessmessages
    begin
     LeaveLogMsg('SendReceive: detected event of reentrance');
     exit;  //that would be signal of reeentry ... (assuming somebody did not forgot to unlock ;)
    end;
  if fcomsync=nil then exit;
  com := fcomsync.fTCPClient;
  if com=nil then exit;
  if not com.Connected then
    begin
      if fDebug then LeaveLogMsg('SendReceive: NOT CONNECTED');
      exit;
    end;
  fComLock := true;
  //do not forget to unlock
  if fDebug then LeaveLogMsg('SendReceive: start');
  if fcomsync.IsLocked then
    begin
      LeaveLogMsg('SendReceive: comsync is locked!!');
      fComLock := false;
      exit;
    end;
  if fDebug then LeaveLogMsg('Sending: '+ BinStrToPrintStr(cmd) );
  //fcomsync.BeginWrite;         //it is not good idea to call synchronize inside critical section in thread, that can also be accessed from the main thread
     if ClearInBuf then
       begin
         inbuf := com.ClearInputBuffer;
       end;
     //send
     try
       bs := Com.SendStringRaw(cmd, 100);
     except
       on E: exception do begin LeaveLogMsg('SendReceive: got exc on sendstr: ' + E.message); bs := false; end;
     end;
     //receive
     //MUS NOT USE NOW porbably is not THREAD SAFE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     t0 := TimeDeltaTICKgetT0;
     reply := '';
     intreply := '';
     tout := true;
     //if fDebug then LeaveLogMsg('SendReceive: wait for reply');
     while TimeDeltaTICKNowMS(t0)<timeout do
       begin
         //MyThreadProcessMessages;    //TODO!!!!!!!!!!! Disable it or not?
         try
           br := Com.ReadStringRaw(s, n, 10);    //will try to read every 5ms - that should be enough small delay
         except
           on E: exception do begin LeaveLogMsg('SendReceive: got exc on readstr: ' + E.message); br := false; end;
         end;
         if not br then break;
 //TODO !!!!!!        if fDebug then LeaveLogMsg('SendReceive: Received str: '+ BinStrToPrintStr(s) );
         intreply := intreply + s;
         if IsEndOfMessage( intreply ) then
           begin
             tout := false;
             break;
           end;
       end;
     //MyThreadProcessMessages;
  //fcomsync.EndWrite;
  fComLock := false;
  replyprint := BinStrToPrintStr(intreply);
  if fDebug then LeaveLogMsg('SendReceive: Finally Received str: '+ replyprint );
  if fDebug and tout then LeaveLogMsg('SendReceive: timeout' );
  if inbuf>0 then LeaveLogMsg('SendReceive: there were some  chars in receive buffer n='+ IntToStr(inbuf) );
  Result := bs and br and (not tout);
  if result then reply := intreply;
end;







procedure TTCPAquireThreadBase.OpenCom;      //called from main thread, must not block
begin
  fOpenComRequested := true;
end;


procedure TTCPAquireThreadBase.CloseCom;               //called from main thread, must not block
begin
  fCloseComRequested := true;
end;

function TTCPAquireThreadBase.isComConnected(): boolean;
begin
    Result := fTCPConnected;
end;


procedure TTCPAquireThreadBase.ResetConnection;
begin
  fUpdateConfRequested := true; //that will make reset with usening current configuration
  fOpenComRequested := true;  //after update this will connect
end;

procedure TTCPAquireThreadBase.ConfigureTCP( server: string; port: string);
//called from main thread,  must not block
begin
   fNewServer := server + '';   //force COPY
   fNewPort := port+ '';
   fUpdateConfRequested := true;
end;


procedure TTCPAquireThreadBase.getTCPConf( Var server: string; Var port: string);
//called from main thread, must not block
begin
  server := fNewServer;
  port := fNewPort;
end;

procedure TTCPAquireThreadBase.ForcedClose;
begin
  if fcomsync=nil then exit;
  if fcomsync.fTCPClient=nil then exit;
  fcomsync.fTCPClient.Close;
end;






// *******************************
//
// *******************************




constructor TRS232AquireThreadBase.Create;
begin
  inherited Create; //createsuspended=true
  fcomsync := TComPortThreadSafe.Create;
  fThreadId := 'RS232Base';
  fComLock := false;
  fUpdateConfRequested := false;
  fCloseComRequested := false;
  fOpenComRequested := false;
  fOpenSetupForm := false;
  if fcomsync<>nil then  fcomsync.AssignLogProc( logProcHelper );
end;

procedure TRS232AquireThreadBase.BeforeDestroy;
//in order to disconnect and destroy tcpclient; inside destroy it caused trouble
begin
  if not Terminated then ShowMessage('TAquireThreadBaseV2: Is Not TERMINATED');
  if fcomsync<>nil then fcomsync.Destroy;
end;


destructor TRS232AquireThreadBase.Destroy;
begin
  inherited;
end;

procedure TRS232AquireThreadBase.ProcessConfigurationRequests;
Var
  com: TComPort;
begin
  //when this method executes -> that means com.receive is not executing (same thread) and access to com synchro is free, no chance of deadlock
  //process in this order: 1) close, 2) reconf/restart 3) open
  if fcomsync=nil then exit;
  com := fcomsync.ComPort;
  if com=nil then exit;
  //verify that comlock is NOT active
  if fComLock then     //need to check beacuse using processmessages
    begin
     LeaveWarningMsg('CheckAndProcessRequests: FAIL - comlock TRUE');
     exit;
    end;
  fComLock := true;
  //
  //1)
  if fCLoseComRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient Close...');
      fcomsync.BeginWrite;
        if com.Connected then
          begin
            com.SetDTR(false);
            com.SetRTS(false);
            com.Close;
          end;
        fPortOpen := false;
      fcomsync.EndWrite;
      fCLoseComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fPortOpen));
    end;
  //2)
  if fUpdateConfRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient UpdateConf...');
      fcomsync.BeginWrite;
       if com.Connected then
          begin
            com.SetDTR(false);
            com.SetRTS(false);
            com.Close;
          end;
        fPortOpen := false;
        setComPortConf;
        getComPortConf;
        //fOpenComRequested := true;  no - not automatically open
      fcomsync.EndWrite;
      fUpdateConfRequested := false;
      LeaveLogMsg('  NEW port conf is: port ' + fPortConf.Name + '  baud ' + fPortConf.BR );
    end;
  //3)
  if fOpenComRequested then
    begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient OPEN port...');
      fcomsync.BeginWrite;
        if not com.Connected then
          begin
            com.Open;
          end;
        fPortOpen := com.Connected;
        if fPortOpen then
          begin
            com.SetDTR(true); //!!!!!!! ABSOLUTELY MUST BE SET otherwise partner device generaly will not send anything
            com.SetRTS(true);
          end;
      fcomsync.EndWrite;
      fOpenComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fPortOpen));
    end;
   //4 fOpenSetupForm
   if fOpenSetupForm then
     begin
      LeaveLogMsg('CheckAndProcessRequestsTCPClient SETUP form request...');
      //use synchronize !!!!
      Synchronize(  syncShowSetupDialog );
      getComPortConf;
      fPortOpen := com.Connected;
      fOpenSetupForm := false;
      LeaveLogMsg('  setup done, new port state is: ' + BoolToStr(fPortOpen));
     end;
   //*** even if there were no requeste, update current status into cache
   fcomsync.BeginRead;
        fPortOpen := com.Connected;
   fcomsync.EndRead;
   fComLock := false;
end;


function TRS232AquireThreadBase.SendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //this is defined here
Var
  n, i: longint;
  bs, br: boolean;
  dtout: TDateTime;
  tout: boolean;
  s: string;
begin
  Result := false;
  if fComLock then     //need to check beacuse using porcessmessages
    begin
     LeaveLogMsg('SendReceive: detected event of reentrance');
     exit;  //that would be signal of reeentry ... (assuming somebody did not forgot to unlock ;)
    end;
  if fcomsync=nil then exit;
  fComLock := true;
  //do not forget to unlock
  fcomsync.BeginWrite;         //it is not good idea to call synchronize inside critical section in thread, that can also be accessed from the main thread
     if ClearInBuf then
       begin
         fcomsync.ClearInputBuffer;
       end;
     //send
     if fDebug then LeaveLogMsg('Sending: '+ BinStrToPrintStr(cmd) );
     //before sending prepare for receiving
     fcomsync.RecvEnabled := true;
     bs := fcomsync.SendStringRaw(cmd);
     //receive
     dtout := Now() + timeout/3600/24/1000;
     reply := '';
     tout := true;
     while Now()<dtout do
       begin
         MyThreadProcessMessages;   //!!!!FOR THE comport it is ABSOLUTELY necessary to processmessages!!!
         br := fcomsync.ReadStringRaw(s);
         if fDebug then LeaveLogMsg('SendReceive: Received str: '+ BinStrToPrintStr(s) );
         reply := reply + s;
         if IsEndOfMessage( reply ) then
           begin
             tout := false;
             break;
           end;
       end;
     if fDebug and tout then LeaveLogMsg('SendReceive: timeout' );
     fcomsync.RecvEnabled := false;   //do not expect any other incoming data     
  fcomsync.EndWrite;
  fComLock := false;
  Result := bs and br and (not tout);
end;



procedure TRS232AquireThreadBase.OpenCom;      //called from main thread, must not block
begin
  fOpenComRequested := true;
end;


procedure TRS232AquireThreadBase.CloseCom;               //called from main thread, must not block
begin
  fCloseComRequested := true;
end;

function TRS232AquireThreadBase.isComConnected(): boolean;
begin
    Result := fPortOpen;
end;


procedure TRS232AquireThreadBase.ResetConnection;
begin
  fUpdateConfRequested := true; //that will make reset with usening current configuration
  fOpenComRequested := true;  //after update this will connect
end;

procedure TRS232AquireThreadBase.OpenComPortSetupForm;  //called from main thread, must not block - open port internal setup form using synchronize!!!!! when not com in progress
begin
  fOpenSetupForm := true;  //after update this will connect
end;



procedure TRS232AquireThreadBase.ConfigurePort( Var conf:TComPortConf );    //called from main thread, must not block
begin
  CopyPortConf(conf, fPortConf);
  fUpdateConfRequested := true;
end;

procedure TRS232AquireThreadBase.getPortConf( Var conf:TComPortConf); //called from main thread, must not block
begin
 //make sure the strings are COPYed!!! not the reference aasigned
  CopyPortConf( fPortConf, conf );
end;


procedure TRS232AquireThreadBase.logProcHelper(s: string);
begin
  if fDebug then LeaveLogMsg( s );
end;


procedure TRS232AquireThreadBase.getComPortConf;
//internal
Var
  com: TComPort;
begin
  if fcomsync=nil then exit;
  com := fcomsync.ComPort;
  if com=nil then exit;
  fcomsync.BeginRead;
    fPortConf.Name := com.Port;
    fPortConf.BR := BaudRateToStr( Com.BaudRate ) ;
    fPortConf.StopBits := StopBitsToStr( Com.StopBits );
    fPortConf.DataBits := DataBitsToStr( Com.DataBits );
    fPortConf.Parity := ParityToStr( Com.Parity.Bits );
    fPortConf.FlowCtrl := FlowControlToStr( Com.FlowControl.FlowControl );
  fcomsync.EndRead;
end;

procedure TRS232AquireThreadBase.setComPortConf;
Var
  com: TComPort;
begin
  if fcomsync=nil then exit;
  com := fcomsync.ComPort;
  if com=nil then exit;
  fcomsync.BeginWrite;
    com.Port := fPortConf.Name;
    com.BaudRate := StrToBaudRate(fPortConf.BR);
    com.StopBits := StrToStopBits(fPortConf.StopBits);
    com.DataBits := StrToDataBits(fPortConf.DataBits);
    com.Parity.Bits := StrToParity(fPortConf.Parity);
    com.FlowControl.FlowControl := StrToFlowControl( fPortConf.FlowCtrl );
  fcomsync.EndWrite;
end;


procedure TRS232AquireThreadBase.syncShowSetupDialog;
//mind! should run in context of main thread
Var
  com: TComPort;
begin
  //do not check for com lock - it should have been done before !!!
  if fcomsync=nil then exit;
  com := fcomsync.ComPort;
  if com=nil then exit;
  fcomsync.BeginWrite;
    com.ShowSetupDialog;
  fcomsync.EndWrite;
end;





// *******************************
//
// *******************************









constructor TAquireThreadBaseV2.Create;
begin
  inherited Create(true); //createsuspended=true
  FreeOnTerminate := false;
  fCntErr := 0;
  fCntOk := 0;
  fThreadId := 'CAncestor';
  fDebug := false;
  fFlagSuspend := false;
  fUserSuspend := false;
end;

destructor TAquireThreadBaseV2.Destroy;
Var
 i: integer;
begin
  if not Terminated then ShowMessage('TAquireThreadBaseV2: Is Not TERMINATED');
  inherited;
end;


procedure TAquireThreadBaseV2.SetUserSuspend;
begin
  fUserSuspend := true;
end;

procedure TAquireThreadBaseV2.ResetUserSuspend;
begin
  fUserSuspend := false;
end;


procedure TAquireThreadBaseV2.CheckAndProcessRequests;
      //this method must be periodically called from withing execute!!!!
      //in order to process requests opening, closing and configuration for TCPClient   !!!!!!!
begin
  //process the com requests during waiting
  ProcessConfigurationRequests;       //at least oonce run it if the while condition would be false
  //
  while fUserSuspend and (not Terminated) do
    begin
      fFlagSuspend := true;
      ProcessConfigurationRequests;   //this is defined in successor class
      Sleep(100);
    end;
  fFlagSuspend := false;
end;


function TAquireThreadBaseV2.IsUserSuspendActive: boolean;
begin
  Result := fFlagSuspend;
end;

function TAquireThreadBaseV2.IsThreadRunning(): boolean;
begin
  Result := (not Terminated) and (not Suspended) and (not fFlagSuspend);
end;

function TAquireThreadBaseV2.getThreadStatusStr: string;
begin
  Result := '???';
  if Suspended then Result := 'Suspended';
  if Terminated then Result := 'Terminated';
  if Terminated and Suspended then Result := 'Suspended+Terminated';
  if (not Terminated) and (not Suspended) then Result := 'Running...';
  //uses suspend
  if fUserSuspend then Result := Result + '/ UserSuspend';
end;


procedure TAquireThreadBaseV2.MyThreadProcessMessages;
    //need to process received messages from system, because that is the way how this implementation of serial port works!!!
    //but should not use ApplicationProcessMessages inside a thread -> so I use my own loop fro processing
    //found here:  http://stackoverflow.com/questions/15467263/how-do-i-forcibly-process-messages-inside-a-thread (Remy Lebeau)
var
  Msg: TMsg;
begin
      while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
end;


procedure TAquireThreadBaseV2.IncErrCnt;
begin
  Inc(fCntErr);
end;

procedure TAquireThreadBaseV2.IncOKCnt;
begin
  Inc(fCntOk);
end;


procedure TAquireThreadBaseV2.ResetCnts;
begin
  fCntErr := 0;
  fCntOk := 0;
end;


procedure TAquireThreadBaseV2.LeaveLogMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  fSyncmsg :='THREAD ' + fThreadId + ': ' + a;
  Synchronize( SyncLeaveLogMsg );
end;

procedure TAquireThreadBaseV2.LeaveWarningMsg(a: string);  //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  fSyncmsg :='THREAD ' + fThreadId + ': ' + a;
  Synchronize( SyncLeaveWarningMsg );
end;

procedure TAquireThreadBaseV2.LeaveErrorMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  fSyncmsg :='THREAD ' + fThreadId + ': ' + a;
  Synchronize( SyncLeaveErrorMsg );
end;


procedure TAquireThreadBaseV2.SyncLeaveLogMsg;     //this will argument to synchronize - used internaly, for log use proc LeaveLogMsg
begin
  LogMsg( fSyncmsg );
end;

procedure TAquireThreadBaseV2.SyncLeaveWarningMsg;  //this will argument to synchronize - used internaly
begin
  LogWarning( fSyncmsg );
end;

procedure TAquireThreadBaseV2.SyncLeaveErrorMsg;   //this will argument to synchronize - used internaly
begin
  LogError( fSyncmsg );
end;












end.

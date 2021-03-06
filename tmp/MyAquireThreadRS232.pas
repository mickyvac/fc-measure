unit MyAquireThreadRS232;

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, Logger, ConfigManager,
  myThreadUtils, MyAquireThreadPrototype,  MyComPort;


type




  TRS232AquireThreadBase = class (TAquireThreadCommonAncestor)       //TMultiReadExclusiveWriteSynchronizer.
  //inside the descendat objects EXECUTE, the method CheckAndProcessRequests must be called periodicaly!!!!!!!!!
  // ...best probably at the beginning of the EXECUTE LOOP
  //...  CheckAndProcessRequests process communication object configuration
  //        AND will call inherited CHECK FOR USER SUSPEND OF EXECUTE LOOP !!!!!! (thread actively waits until flag is reset)
    public
      constructor Create;
      destructor Destroy; override;
    protected
      function IsEndOfMessage(Const recvbuf: string): boolean; virtual; abstract;  //descendadnt must define this for communication to work
                                                                                   // used by SendReceive
      //procedure ExecuteInnerLoop;  virtual; abstract;   //- will be defined in subclass
         //periodically called within execute - must be defined in subclass
         // takes care for e.g. ell device polling for data and processing data
         //does not have to check for terminate!!!
         //just must end after one cycle - will be placed inside a loop, that does check configuration requests and terminate
    protected
      procedure ProcessConfigurationRequests; override;  //here defined
    private
      fcomsync: TComPortThreadSafe;  //locked access because of possible change of configuration -
                                         //this is only reference to the client object,   //the OBJECT is OWNED by the ROOT INTERFACE
      fComLock: boolean;
    public
      //following methods are expected to be called from main thread -> so LOCKING of objectws is NECESASARY
      function SendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;
                       //SendReceive is defined here
    public
      procedure OpenCom;      //called from main thread, must not block
      procedure CloseCom;               //called from main thread, must not block
      procedure ResetConnection;     //called from main thread, must not block
      function isComConnected(): boolean;  //called from main thread, must not block
      procedure OpenComPortSetupForm;  //called from main thread, must not block - open port internal setup form using synchronize!!!!! when not com in progress
      procedure ConfigurePort( Var conf:TComPortConf );    //called from main thread, must not block
      procedure getPortConf( Var conf:TComPortConf); //called from main thread, must not block
    private
      //cached comport status - main thread should not collide with lock on comsynchro
      fPortConfigured: boolean;    //must not try open port that is not configured!!!
      fPortOpen: boolean;
      fPortConf: TComPortConf;
      //update request flags and new config
      fOpenSetupForm: boolean;
      fCloseComRequested: boolean;
      fOpenComRequested: boolean;
      fUpdateConfRequested: boolean;   //signal that parameters of port should change -
      fNewPortConf: TComPortConf;
      //fCloseInProgress: boolean;
      //statistics cache
      fLastQueryDurMS: longword;
      //

      //internal comport interface and helpers!!!
      procedure logProcHelper(s: string);
      procedure getComPortConf;   //fills fPortConfVariable from comport
      procedure setComPortConf;    //sets fPortConfVariable into comport
    public
      property LastQueryDurMS: longword read fLastQueryDurMS;
  end;




implementation

Uses Windows;




constructor TRS232AquireThreadBase.Create;
begin
  inherited Create; //createsuspended=true
  fcomsync := TComPortThreadSafe.Create;
  fThreadId := 'RS232Base';
  fComLock := false;
  fPortConfigured := false;
  fUpdateConfRequested := false;
  fCloseComRequested := false;
  fOpenComRequested := false;
  fOpenSetupForm := false;
  //defaultProtConf(fcomPortCOnf);
  if fcomsync<>nil then  fcomsync.AssignLogProc( logProcHelper );
end;



destructor TRS232AquireThreadBase.Destroy;
begin
  if not Terminated then ShowMessage('RS232: Thread Is Not TERMINATED');
  try
    if fcomsync<>nil then fcomsync.Destroy;
  except
    on E: Exception do ShowMessage(E.message);
  end;
  inherited;
end;


procedure TRS232AquireThreadBase.ProcessConfigurationRequests;
Const
  procident = 'ProcConfReq: ';
begin
  //when this method executes -> that means com.receive is not executing (same thread) and access to com synchro is free, no chance of deadlock
  //process in this order: 1) close, 2) reconf/restart 3) open
  if fcomsync=nil then exit;
  //verify that comlock is NOT active
  if fComLock then     //need to check beacuse using processmessages
    begin
     LeaveLogMsg('CheckAndProcessRequests: FAIL - comlock TRUE');
     exit;
    end;
  fComLock := true;
  //
  //1)
  if fCLoseComRequested then
    begin
      LeaveLogMsg(procident + ' Close port...');
      fcomsync.ClosePort;
      fPortOpen := fcomsync.IsPortOpen;
      fCLoseComRequested := false;
      LeaveLogMsg('  NEW port state is: ' + BoolToStr(fPortOpen));
    end;
  //2)
  if fUpdateConfRequested then
    begin
      LeaveLogMsg(procident + ' UpdateConf...');
      fcomsync.ClosePort;
      setComPortConf;
      getComPortConf;
      //fOpenComRequested := true;  no - not automatically open
      fPortOpen := fcomsync.IsPortOpen;
      fUpdateConfRequested := false;
      LeaveLogMsg('       after update NEW conf is: ' + PortConfToStr( fPortConf ) );
    end;
  //3)
  if fOpenComRequested then
    begin
      LeaveLogMsg(procident + '    OPEN port...');
      fComLock := false;
      fcomsync.OpenPort;
      fPortOpen := fcomsync.IsPortOpen;
      fOpenComRequested := false;
      LeaveLogMsg('     after open NEW port state is: ' + BoolToStr(fPortOpen));
    end;
   //4 fOpenSetupForm
   if fOpenSetupForm then
     begin
      LeaveLogMsg(procident + '  SETUP form request...');
      //use synchronize !!!!
      Synchronize(  fcomsync.ShowSetupDialog );
      getComPortConf;
      setComPortConf;
      fPortOpen := fcomsync.IsPortOpen;
      fOpenSetupForm := false;
      LeaveLogMsg('  after setup via Form: ' + PortConfToStr( fPortConf ) + ' ,new port state is: ' + BoolToStr(fPortOpen));
     end;
   //*** even if there were no requeste, update current status into cache
   fPortOpen := fcomsync.IsPortOpen;
   fcomsync.Debug := fDebug;        //update debug state
   fComLock := false;
end;


function TRS232AquireThreadBase.SendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //this is defined here
Var
  n, i: longint;
  bs, br: boolean;
  //dtout: TDateTime;
  t0: longword;
  tout: boolean;
  s: string;
begin
  Result := false;
  reply := '';
  if fcomsync=nil then exit;
  if not ComEnabled then
   begin
     LeaveLogMsg('SendReceive: NOT ComEnabled');
     exit;  //!!!!!!
   end;
  if fComLock then     //need to check beacuse using porcessmessages
    begin
     LeaveLogMsg('SendReceive: detected event of reentrance (LOCK engaged)');
     exit;  //that would be signal of reeentry ... (assuming somebody did not forgot to unlock ;)
    end;
  if not fcomsync.IsPortOpen then
    begin
     LeaveLogMsg('SendReceive: port NOT open -> exit;');
     exit;
    end;
  //!!!!!!! lock  
  fComLock := true;
  //do not forget to unlock    !!!
  //
  if fDebug then LeaveLogMsg('  RS232AquireThreadBase.SendReceive - sending: '+ BinStrToPrintStr(cmd) );
  fcomsync.Lock;         //it is not good idea to call synchronize inside critical section in thread, that can also be accessed from the main thread
     if ClearInBuf then
       begin
         fcomsync.ClearInputBuffer;
       end;
     //before sending prepare for receiving
     reply := '';
     tout := true;
     fcomsync.RecvEnabled := true;
     t0 := TimeDeltaTICKgetT0;
     //send
     bs := fcomsync.SendStringRaw(cmd);
     //receive
     while TimeDeltaTICKNowMS(t0)< timeout do
       begin
         br := fcomsync.ReadStringRaw(s);
         //if not br then continue;
         reply := reply + s;
         if IsEndOfMessage( reply ) then
           begin
             tout := false;
             break;
           end;
       end;
     fcomsync.RecvEnabled := false;   //do not expect any other incoming data
     fLastQueryDurMS := TimeDeltaTICKNowMS(t0);
  fcomsync.Unlock;
  if fDebug and tout then LeaveLogMsg('  SendReceive: timeout' );
  if fDebug then LeaveLogMsg('  SendReceive: Received str: '+ BinStrToPrintStr(reply) );
  fComLock := false;
  Result := bs and br and (not tout);
end;



procedure TRS232AquireThreadBase.OpenCom;      //called from main thread, must not block
begin
  fOpenComRequested := true;
  fComLock := false;
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
begin
  if fcomsync=nil then exit;
  //fcomsync.Lock;
    fcomsync.getComPortConf( fPortConf );
  //fcomsync.UnLock;
end;

procedure TRS232AquireThreadBase.setComPortConf;
begin
  if fcomsync=nil then exit;
  //fcomsync.Lock;
    fcomsync.setComPortConf( fPortConf );
  //fcomsync.UnLock;
end;






// *******************************
//
// *******************************




end.

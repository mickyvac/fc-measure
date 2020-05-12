unit MyAquireThreadPrototype;

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, Logger, ConfigManager,
  MyTCPClient,  sockets, MyComPort, myThreadUtils, loggerThreadsafe;


type

  TAquireThreadCommonAncestor = class (TThread)       //TMultiReadExclusiveWriteSynchronizer
  //!!!!!NOTE!!!!
  //descendant must define ExecuteInnerLoop; instead of execute;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Execute; override;  //EExecute is defined here-> !!! Descendat must use EXECUTEINNERLOOP
    protected
      //this method will be periodically called from withing execute!!!!
      //    in this ancestor class, this check for USER SUSPEND (active waiting until flag is reset)
      //!!!!!!!!!
      procedure ProcessConfigurationRequests; virtual; abstract; //helper - used in  CheckAndProcessRequests
                                                                 //- must be defined in subclass
      procedure ExecuteInnerLoop;  virtual; abstract;  //periodically called within execute - must be defined in subclass
         // takes care for e.g. ell device polling for data and processing data
         //does not have to check for terminate!!!
         //just must end after one cycle - will be placed inside a loop, that does check configuration requests and terminate
      //!!!!!!!!
    public
      procedure SetUserSuspend;
      procedure ResetUserSuspend;
      procedure TerminateAndWaitForExecuteFinish;
      function IsUserSuspendActive: boolean;
      function IsThreadRunning(): boolean;
      function getThreadStatusStr: string;
      procedure EnableCom;       //only AFTER all init should be the general communication allowed - all com function sould check the bool fComEnabled
      procedure DisableCom;
    protected
      fCntErr: longint;    //counter of send msg/ recv msg errors
      fCntOk: longint;
      fThreadId: string;
      fLastCycleMS: longword;
      fDebug: boolean;
      //fSyncMsgLock: TMyLockableObject;
      fLog: TMyLoggerThreadSafe;
      fComEnabled: boolean;  //!!!! until user enabled - communication should be disabled!!!
      fExecuteFinished: boolean; //signal when exetcute is finished - importatnt : HAVE TO WAIT BEFORE DESTOYING OBJECTS
    public
      property ComEnabled: boolean read fComEnabled;
      property comOkcnt: longint read fCntok;
      property comErrcnt: longint read fCnterr;
      property MythreadID: string read fThreadId;
      property Debug: boolean read fDebug write fDebug;
      property LastCycleMS: longword read fLastCycleMS;
      property ExecuteFinished: boolean read fExecuteFinished;
    protected
      //log - use only when necessary - because uses synchronize call - to execute in main thread
      //DO NOT USE INSIDE LOCKED section - MAY CAUSE DEADLOCK (main thread wating for the locked object)
      procedure LeaveLogMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
      //procedure LeaveWarningMsg(a: string);  //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
      //procedure LeaveErrorMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
    protected
      procedure MyThreadProcessMessages;    //may be helpful,not needed probably, maybe better avoid it!!
      procedure IncErrCnt;
      procedure IncOKCnt;
      procedure ResetCnts;
    private
      fUserSuspend: boolean;  //user supension is check in side the CheckAndProcessRequests;
      fFlagSuspend: boolean;
    private
      //---error reporting and logging fucntion low level helper
      //fSyncmsg: string;
      //procedure SyncLeaveLogMsg;     //this will argument to synchronize - used internaly, for log use proc LeaveLogMsg
     // procedure SyncLeaveWarningMsg;  //this will argument to synchronize - used internaly
     // procedure SyncLeaveErrorMsg;   //this will argument to synchronize - used internaly
  end;





//*********************************

implementation

Uses Windows;



constructor TAquireThreadCommonAncestor.Create;
begin
  inherited Create(true); //createsuspended=true
  FreeOnTerminate := false;
  fLog := TMyLoggerThreadSafe.Create( '!thread_'+ MythreadID, IntToStr( threadID) );       //tthread
  fCntErr := 0;
  fCntOk := 0;
  fThreadId := 'CAncestor';
  fDebug := false;
  fFlagSuspend := false;
  fUserSuspend := false;
  fComEnabled := false;
  fExecuteFinished := false;
end;

destructor TAquireThreadCommonAncestor.Destroy;
Var
 i: integer;
begin
  //damn !!! this is run from context of main thread - must wait here for thred to terminate - I observed, that the execute was still running
  //even after log was destroyed apparently!!!
  while not fExecuteFinished do begin sleep(10) end;
  if FatalException<>nil then ShowMessage('THREad - Fatal exception ' + FatalException.ClassName );
  fLog.Destroy;
  inherited;
end;


procedure TAquireThreadCommonAncestor.Execute;
Var
  t0, dtMS: longword;
begin
  LeaveLogMsg('AquireThread.Execute: started. This is: ' + fThreadId);
  //
  fExecuteFinished := false;
  while not Terminated do
    begin
	    //process the com requests during waiting
      try
	      ProcessConfigurationRequests;       //at least oonce run it if the while condition would be false
      except
        on E: exception do LeaveLogMsg( E.Message );
      end;
	    //
	    while fUserSuspend and (not Terminated) do
	      begin
	        fFlagSuspend := true;
          try
	          ProcessConfigurationRequests;   //this is defined in successor class
          except
             on E: exception do LeaveLogMsg( E.Message );
          end;

	        Sleep(100);
	      end;
	    fFlagSuspend := false;
      //
	    //time metrics
	    t0 := TimeDeltaTICKgetT0;
	    //
      try 
	      ExecuteInnerLoop;
      except
          on E: exception do LeaveLogMsg( E.Message );
      end;

	    //
	    fLastCycleMS := TimeDeltaTICKNowMS( t0 );
    end;
  LeaveLogMsg('AquireThread.Execute: Finished EXECUTE !!! id:' + fThreadId);
  ReturnValue := 0;
  fExecuteFinished := true;
end;


procedure TAquireThreadCommonAncestor.SetUserSuspend;
begin
  fUserSuspend := true;
end;

procedure TAquireThreadCommonAncestor.ResetUserSuspend;
begin
  fUserSuspend := false;
end;


procedure TAquireThreadCommonAncestor.TerminateAndWaitForExecuteFinish;
Var
 i: integer;
begin
   Terminate;
   //!!! wait to terminate
   i :=200;
   while (not fExecuteFinished) do
      begin
          sleep(100);
          Dec(i);
          if i<1 then break; //force quit waiting if takes too long
      end;
   if i<1 then ShowMessage( MythreadID + ' Wait for execute FINISH failed - timeout');
end;


procedure TAquireThreadCommonAncestor.EnableCom;
//only AFTER all init should be the general communication allowed - all com function sould check the bool fComEnabled
begin
  fComEnabled := true;
end;

procedure TAquireThreadCommonAncestor.DisableCom;
begin
  fComEnabled := false;
end;


function TAquireThreadCommonAncestor.IsUserSuspendActive: boolean;
begin
  Result := fFlagSuspend;
end;

function TAquireThreadCommonAncestor.IsThreadRunning(): boolean;
begin
  Result := (not Terminated) and (not Suspended) and (not fFlagSuspend);
end;

function TAquireThreadCommonAncestor.getThreadStatusStr: string;
begin
  Result := '???';
  if Suspended then Result := 'Suspended';
  if Terminated then Result := 'Terminated';
  if Terminated and Suspended then Result := 'Suspended+Terminated';
  if (not Terminated) and (not Suspended) then Result := 'Running...';
  //uses suspend
  if fFlagSuspend then Result := Result + '/ UserSuspend';
end;


procedure TAquireThreadCommonAncestor.MyThreadProcessMessages;
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


procedure TAquireThreadCommonAncestor.IncErrCnt;
begin
  Inc(fCntErr);
end;

procedure TAquireThreadCommonAncestor.IncOKCnt;
begin
  Inc(fCntOk);
end;


procedure TAquireThreadCommonAncestor.ResetCnts;
begin
  fCntErr := 0;
  fCntOk := 0;
end;


procedure TAquireThreadCommonAncestor.LeaveLogMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  fLog.LogMsg( 'THREAD ' + fThreadId + ': ' + a );
end;


end.

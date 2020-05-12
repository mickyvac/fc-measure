unit MyJobThreadSafeManager;

{ shold provide thread safe, milisecond resoluted scheduler with more clever handling than standard timer }
{ timed event object contains reference to procedure which to call, it is executed using synchornize by default
or thread internal-thread-safe handler should be provided
  implemented is double direction linked list of record-objects}

interface


uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  Myutils, MyParseUtils, Logger, ConfigManager,
  MyThreadUtils, loggerThreadsafe, ExtCtrls;


Const
  CMaxTimeEvents = 10000;

type


 TJobType = ( CJDirectCmdStr );
 TJobResult = ( CJNotProcessed, CJOK, CJError, CJNotHandled);

 TJobThreadSafe = class; //forward declaration

 TJobNotifyMethod = procedure ( job: TJobThreadSafe ) of object;
 TGeneralNotifyMethod = procedure ( ptr: Pointer ) of object;  //ptr to payload object - the function has to convert the argument to necessary object type

 TJobThreadSafe = class (TMyLockableObject)
    public
      constructor Create( jobtype: TJobType; OnDoneThreadSafe: TJobNotifyMethod; OnDoneInMainThread: TGeneralNotifyMethod );
      destructor Destroy; override;
      destructor SmartDestroy;
    public
      procedure FinishJob;  //call after assigning a result (in descendant) and all manipulation - marks as finished and calls OnDone Methods
      //procedure OnDoneInMainThread;  //must be executed in context of main thread
    private
      fType: TJobType;
      fOnDoneThreadSafe: TJobNotifyMethod;
      //fOnDoneUsingSynchronize: TJobNotifyMethod; //synchronize
      fOnDoneInMainThread: TGeneralNotifyMethod;
      fFinished: boolean;
      fResultCode: TJobResult;
    private
      function fIsFinished(): boolean;
      function getResultCode(): TJobResult;
      procedure setResultCode (jr: TJobResult);
    public
      property IsFinsihed: boolean read fIsFinished;
      property ResultCode: TJobResult read getResultCode write setResultCode;
  end;


 TJobDirectCommand = class (TJobThreadSafe)
    public
      constructor Create(OnDoneThreadSafe: TJobNotifyMethod; OnDoneInMainThread: TGeneralNotifyMethod);
      destructor Destroy; override;
    public
      Cmd: string;
      Reply: string;
      elapsedMS: longword;
      ReplyHandler: TLogProcedureThreadSafe;
  end;






//------------

TJobRec = class (TObject)
    public
      constructor Create(methodToCall: TGeneralNotifyMethod; argument: TObject);
      destructor Destroy; override;
    public
      fmethodToCall: TGeneralNotifyMethod;
      farg: TObject;
    end;



TJobManagerThreadSafe = class (TObject)
    public
      constructor Create();
      destructor Destroy; override;
    public
      procedure AddJobReport(methodToCall: TGeneralNotifyMethod; argument: Pointer);
    private
      fJQ: TMVQueueThreadSafe;  //object queue
      fTimer: TTimer;
    public
      procedure fOnTimer(Sender: Tobject);
  end;





Var

  MainJobManager: TJobManagerThreadSafe;   //!!!!!!!!!!!!!!!


//*********************************




implementation

Uses Windows;


constructor TJobThreadSafe.Create( jobtype: TJobType; OnDoneThreadSafe: TJobNotifyMethod; OnDoneInMainThread: TGeneralNotifyMethod );
begin
  inherited Create;
  fType := jobtype;
  fOnDoneThreadSafe := OnDoneThreadSafe;
  fOnDoneInMainThread := OnDoneInMainThread;
  fFinished := false;
  fResultCode := CJNotProcessed;
end;

destructor TJobThreadSafe.Destroy;
begin
  inherited;
end;

destructor TJobThreadSafe.SmartDestroy;
begin
  //TODO!!!!!!!!!!!!!!!
end;


procedure TJobThreadSafe.FinishJob;  //call after assigning a result (in descendant) and all manipulation - marks as finished and calls OnDone Methods
begin
  //!! must not lock as handling methods using self (and locking self) will be called;
      fFinished := true;
      //run ondonethredsafe immediately
      if Assigned( fOnDoneThreadSafe) then fOnDoneThreadSafe( self ); //this
      //check if requested immediate call using synchronize (as main thread - must check, if actuall thread is not the maintherad)
     { if Assigned( fOnDoneUsingSynchronize) then
        begin
            if GetCurrentThreadId = MainThreadID then
              begin
                fOnDoneUsingSynchronize( self );
              end
            else
              begin

              Synchronize(
                procedure
                begin
                  fOnDoneUsingSynchronize( self );
                end
                         );

              end;
        end;
      }
      //schedule running OnDOneInMaint thres
      if Assigned( fOnDoneInMainThread ) then MainJobManager.AddJobReport( fOnDoneInMainThread, self );
end;


function TJobThreadSafe.fIsFinished(): boolean;
begin
  Lock;
  try
    begin
      Result := fFinished;
    end;
  finally
    Unlock;
  end;
end;

function TJobThreadSafe.getResultCode(): TJobResult;
begin
  Lock;
  try
    begin
      Result := fResultCode;
    end;
  finally
    Unlock;
  end;
end;

procedure TJobThreadSafe.setResultCode (jr: TJobResult);
begin
  Lock;
  try
    begin
      fResultCode := jr;
    end;
  finally
    Unlock;
  end;
end;



//-----------------------



constructor TJobDirectCommand.Create(OnDoneThreadSafe: TJobNotifyMethod; OnDoneInMainThread: TGeneralNotifyMethod);
begin
  inherited Create(CJDirectCmdStr, OnDoneThreadSafe, OnDoneInMainThread);
  Cmd := '';
  Reply := '';
end;

destructor TJobDirectCommand.Destroy;
begin
  inherited;
end;



//-----------------------



constructor TJobRec.Create(methodToCall: TGeneralNotifyMethod; argument: TObject);
begin
  inherited Create();
  fmethodToCall := methodToCall;
  farg := argument;
end;

destructor TJobRec.Destroy;
begin
  inherited;
end;




//-----------------------




constructor TJobManagerThreadSafe.Create();
begin
  inherited Create;
  fTimer := TTimer.Create( nil );
  fTimer.Enabled := false;
  fTimer.Interval := 500;
  fTimer.OnTimer := fOnTimer;
  //
  fJQ := TMVQueueThreadSafe.Create;
end;


destructor TJobManagerThreadSafe.Destroy;
begin
  fTimer.enabled := false;
  //!!!!!!! fuck Ttimer, there can still be waiting unprossed timer events
  MyDestroyAndNil( fTimer );
  fJQ.Clear;  //forget about eny remaining job finich events
  MyDestroyAndNil( fJQ );
  inherited;
end;


procedure TJobManagerThreadSafe.AddJobReport(methodToCall: TGeneralNotifyMethod; argument: Pointer);
Var
  jr: TJobRec;
begin
  jr := TJobRec.Create(methodToCall, argument);
  fJQ.Add( jr );
end;


procedure TJobManagerThreadSafe.fOnTimer(Sender: Tobject);
Var
  j: TJobThreadSafe;
  olde: boolean;
  p: pointer;
  jr: TJobRec;
begin
 olde := fTimer.Enabled;
 if not olde then exit;
 fTimer.Enabled := false;
  while fJQ.Count>0 do
    begin
      jr := TJobRec( fJQ.Pop );
      if jr<>nil then
        begin
          if Assigned( jr.fmethodToCall) then jr.fmethodToCall( TObject( jr.farg) );
          jr.Destroy;
        end;
    end;
 fTimer.Enabled := olde;
end;




initialization

  MainJobManager := TJobManagerThreadSafe.Create;   //!!!!!!!!!!!!!!!
  MainJobManager.fTimer.Enabled := true;

finalization
  if MainJobManager<>nil then MainJobManager.fTimer.Enabled := false;

  MyDestroyAndNil( MainJobManager );   //!!!!!!!!!!!!!!!

end.

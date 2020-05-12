unit MyScheduler;

{ shold provide thread safe, milisecond resoluted scheduler with more clever handling than standard timer }
{ timed event object contains reference to procedure which to call, it is executed using synchornize by default
or thread internal-thread-safe handler should be provided
  implemented is double direction linked list of record-objects}

interface

implementation

end.

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, Logger, ConfigManager,
  MyTCPClient_indy,  sockets, MyLockableObject, loggerThreadsafe,
  MyAquireThreadNEW;


Const
  CMaxTimeEvents = 10000;

type

  TMyOnTimerMethod = procedure of object;

  TMyTimerRec = class (TObject)
    public
//      constructor Create( m: TMyOnTimerMethod; waitMS: longint; forever: boolean = false; callbysynchronize: boolean = true );
    public
	    when: longint;
	    m: TMyOnTimerMethod;
	    id: longint;
	    forever: boolean;
	    usesynchro: boolean;
	    nextrec: TMyTimerRec;
	    prevrec: TMyTimerRec;
  end;


  TScheduler = class (TThread)
    public
      constructor Create( Var logger: TMyLoggerThreadSafe);
      destructor Destroy; override;
    public
      function AddTimedCall( m: TMyOnTimerMethod; waitMS: longint; forever: boolean = false; callbysynchronize: boolean = true): longint;
      procedure ClearAll;
      procedure ClearSpecific(id: longint);
    public
      procedure TerminateAndWaitForFinished;
    private
      fFinished: boolean;
      fCount: longword;
      fIdcnt: longint;
      fLog: TMyLoggerThreadSafe;
      //LogStr(s: string);
    private
      procedure Execute; override;
    private
      zeroRec: TMyTimerRec;       //start of time SORTED linked list
//      timearray: array of TMyTimerRec; //time in ms since given reference, when should an event be executed
                                       //
                                       //!!! SORTED array
      function FindInsertPos(time: longint): TMyTimerRec;  //finds correct position to insert new record into timearray
      function FindById(id: longint): TMyTimerRec;
      procedure InsertAfter(Var predecessor: TMyTimerRec; newobj: TMyTimerRec);
      procedure Delete(Var predecessor: TMyTimerRec; delobj: TMyTimerRec);
  end;



 TJobType = ( CJDirectCmdStr );
 TJobResult = ( CJNotProcessed, CJOK, CJNotHandled);

 TJobThreadSafe = class (TMyLockableObject); //forward declaration


 TJobNotifyMethod = procedure ( job: TJobThreadSafe ) of object;


 TJobThreadSafe = class (TMyLockableObject)
    public
      constructor Create( jobtype: TJobType; OnDoneThreadSafe: TJobNotifyMethod; OnDoneInMainThread: TJobNotifyMethod );
      destructor Destroy; override;
    private
      fType: TJobType;
      fOnDoneThreadSafe: TJobNotifyMethod;
      fOnDoneInMainThread: TJobNotifyMethod;
      fFinished: boolean;
      fResultCode: TJobResult;
      fCount: longword;
      fIdcnt: longint;
      fLog: TMyLoggerThreadSafe;
      //LogStr(s: string);
    private
      procedure Execute; override;
    private
      zeroRec: TMyTimerRec;       //start of time SORTED linked list
//      timearray: array of TMyTimerRec; //time in ms since given reference, when should an event be executed
                                       //
                                       //!!! SORTED array
      function FindInsertPos(time: longint): TMyTimerRec;  //finds correct position to insert new record into timearray
      function FindById(id: longint): TMyTimerRec;
      procedure InsertAfter(Var predecessor: TMyTimerRec; newobj: TMyTimerRec);
      procedure Delete(Var predecessor: TMyTimerRec; delobj: TMyTimerRec);
  end;


 TJobDirectCommand = class (TJobThreadSafe)
    public
      constructor Create(OnDoneThreadSafe: TJobNotifyMethod; OnDoneInMainThread: TJobNotifyMethod; cmd: string);
      destructor Destroy; override;
    public
      fCmd: string;
      fReply: string;
  end;





 TJobManagerThreadSafe = class (TObject)
    public
      constructor Create( Var logger: TMyLoggerThreadSafe);
      destructor Destroy; override;
    public
      function AddTimedCall( m: TMyOnTimerMethod; waitMS: longint; forever: boolean = false; callbysynchronize: boolean = true): longint;
      procedure ClearAll;
      procedure ClearSpecific(id: longint);
    public
      procedure TerminateAndWaitForFinished;
    private
      fFinished: boolean;
      fCount: longword;
      fIdcnt: longint;
      fLog: TMyLoggerThreadSafe;
      //LogStr(s: string);
    private
      procedure Execute; override;
    private
      zeroRec: TMyTimerRec;       //start of time SORTED linked list
//      timearray: array of TMyTimerRec; //time in ms since given reference, when should an event be executed
                                       //
                                       //!!! SORTED array
      function FindInsertPos(time: longint): TMyTimerRec;  //finds correct position to insert new record into timearray
      function FindById(id: longint): TMyTimerRec;
      procedure InsertAfter(Var predecessor: TMyTimerRec; newobj: TMyTimerRec);
      procedure Delete(Var predecessor: TMyTimerRec; delobj: TMyTimerRec);
  end;







//*********************************

implementation

Uses Windows;


TScheduler. = class (TThread)
public
constructor TScheduler.Create( Var logger: TMyLoggerThreadSafe);
destructor TScheduler.Destroy; override;
public
function TScheduler.AddTimedCall( m: TMyOnTimerMethod; waitMS: longint; forever: boolean = false; callbysynchronize: boolean = true): longint;
procedure TScheduler.ClearAll;
procedure TScheduler.ClearSpecific(id: longint);
public
procedure TScheduler.TerminateAndWaitForFinished;
private
fFinished: boolean;
fCount: longword;
fIdcnt: longint;
fLog: TMyLoggerThreadSafe;
//LogStr(s: string);
private
procedure TScheduler.Execute;
private
zeroRec: TMyTimerRec;       //start of time SORTED linked list
//      timearray: array of TMyTimerRec; //time in ms since given reference, when should an event be executed
							   //
							   //!!! SORTED array
function TScheduler.FindInsertPos(time: longint): TMyTimerRec;  //finds correct position to insert new record into timearray
function TScheduler.FindById(id: longint): TMyTimerRec;
procedure TScheduler.InsertAfter(Var predecessor: TMyTimerRec; newobj: TMyTimerRec);
procedure TScheduler.Delete(Var predecessor: TMyTimerRec; delobj: TMyTimerRec);




















constructor TAquireThreadV2_TCPIP.create( Myexm: TMyExecuteMethod; client: TMyTCPClientThreadSafe);
begin
  inherited Create(Myexm);
  fClient := client;
end;


destructor TAquireThreadV2_TCPIP.Destroy;
begin
  inherited;
end;


procedure TAquireThreadV2_TCPIP.ProcessConfigurationRequests;
begin
  if fclient=nil then exit;
  //1)
  if fCloseComRequested then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient Close...');
      if fclient.IsOpen then
         fclient.Close;
      fCloseComRequested := false;
      //LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
  //2)
  if fUpdateConfRequested then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient UpdateConf...');
        if fclient.IsOpen then fclient.Close;
        fclient.ConfigureTCP(fNewServer, fNewPort);
        //fOpenfclientRequested := true;  no - not automatically open
      fUpdateConfRequested := false;
     // LeaveLogMsg('  NEW port conf is: ' + fNewServer + ':'+ fNewPort );
    end;
  //3)
  if fOpenComRequested then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient OPEN port...');
      if not fclient.IsOpen then
         fclient.Open;  //may block for some time!!!!
      fOpenComRequested := false;
      //LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
end;


procedure TAquireThreadV2_TCPIP.OpenTCP;      //called from main thread, must not block
begin
  fOpenComRequested := true;
end;


procedure TAquireThreadV2_TCPIP.CloseTCP;               //called from main thread, must not block
begin
  fCloseComRequested := true;
end;


procedure TAquireThreadV2_TCPIP.ResetConnection;
begin
  fCloseComRequested := true; //that will make reset with usening current configuration
  fOpenComRequested := true;  //after update this will connect
end;

procedure TAquireThreadV2_TCPIP.ConfigureTCP( server: string; port: string);
//called from main thread,  must not block
begin
   fNewServer := server + '';   //force COPY
   fNewPort := port+ '';
   fUpdateConfRequested := true;
end;



end.

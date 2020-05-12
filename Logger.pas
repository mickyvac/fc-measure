unit Logger;

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, MyThreadUtils, MyUtils, Windows;

const
  //CDefaultfname = 'log';                             //TStringList
  Capplogfilenamepref = '!app_log_';
  Capplogfilenamesuf = '.txt';

type
   TMsgProc = procedure(a:string) of object;
   PMsgProc = ^TMsgProc;

  TLoggerOld = class  //main app log
  public
    constructor Create;
    destructor Destroy; override;
    { Public declarations }
    procedure LogMsgStr(a:String);
    procedure LogWarningStr(a:String);
    procedure LogErrorStr(a:String);
    procedure AssignLogProc(msgproc: TMsgProc);
    procedure AssignWarningProc(msgproc: TMsgProc);
    procedure AssignErrorProc(msgproc: TMsgProc);
    procedure ResetLog(forcerewrite:boolean = false);
    procedure AssignLogFile(prefix, suffix: string);
  private
    { Private declarations }
    logfile: TextFile;
    logopen: boolean;
    synchro: TMultiReadExclusiveWriteSynchronizer;  //!!! important when logging from multiple threads
    Plogproc: TMsgProc;
    Pwarningproc: TMsgProc;
    Perrorproc: TMsgProc;
    FDataPath: string;
    FormatSettings: TFormatSettings;
    verbose: boolean;
  private
    function LoggerNowString: string;  //returns actual datetime up to miliseconds to be put at begginning of line
  public
    property DataPath: string read FDataPath write FDataPath;
  end;

//***** time metric object
// use is to measere time between two events
// make start call and save ID .... then later get time difference between now and then (in miliseconds)
// uses tlist to store tdatetime marks

TTimeMetricObject = class
  public

  private

end;



TLogOutput = class (TMyLockableObject)
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure WriteSList(const sl: TStringList);
    procedure Writestr(const s: String);
    procedure Init(fullfname: string);
    procedure Close;
  private
    fFile: Text;
    //fPath: string;
    fInited: boolean;
end;





TLogWorkThread = class (TThread)
  public
    constructor Create(logout: TLogOutput; queue: TMVStringQueueThreadSafe; CommitEveryMS: longint = 60000; WakeupEveryMS: longint = 1000; ForceDumpIfN: longint = 100);
    destructor Destroy; override;
  public
    procedure Execute; override;
  private
    fOut: TLogOutput;
    fQ: TMVStringQueueThreadSafe;
    fCommitEveryMS: longword;
    fWakeupEveryMS: longword;
    fForceDumpOnN: longword;
    fForceDumpBool: TMVVariantThreadSafe;
    fLastWrite: longword;
    fsl: TStringList;
  public
    procedure ForceDump;
end;




TLoggerThreadSafeNew = class (TObject) //main app log
  public
    constructor Create;
    destructor Destroy; override;
    { Public declarations }
    function LogMsg(a:String; addTimestamp: boolean = true): string; //returns the string to be written into log
    procedure StartLogFilePrefix(prefix, suffix: string; dir: string = '');
    procedure StartLogFileName(fullname: string);
    procedure CloseLog;
    procedure ResetLog(forcerewrite:boolean = false);
  private
    fWorkThread: TLogWorkThread;
    fOutputObj: TLogOutput;
    fQueue: TMVStringQueueThreadSafe;
    fLogPath: string;
    fFormatSet: TFormatSettings;
    fLastExitCode: longword;
  public
    function GenTimestampStr: string;  //returns actual datetime up to miliseconds to be put at begginning of line
  public
    property DataPath: string read fLogPath;
    property FormatSettings: TFormatSettings read fFormatSet write fFormatSet;
    property LastExitCode: longword read fLastExitCode;
  end;












//********
//main logging procedure!!!
//********

procedure LogMsg(a:String);        //logs to APP log only
procedure LogWarning(a:String);   //add WARNING label and also loggs into project log
procedure LogError(a:String);     //add ERROR label and also loggs into project log

procedure LogProjectEvent(a:String);     //logs into project log + copy to applog
procedure LogReport(a:String);   //FOR STORING RESULTS

//********


procedure LoggerInit(dir: string='');       //call after app start; dir=without last slash
procedure LoggerFinish;     //call before app closes to destroy objects


//function TimeDeltaTICKMS( t0: longword): longword;



var
  __defaultLogDir: string;

  //LogMain: TLogger;     //store app messages, errors, should be in app directory
  //LoggerProject: TLogger;  //Stores project related messages - created, initialized and destroyed from elsewhere (project control)
  //LoggerReport: TLogger;  //Stores RESULTS - created, initialized and destroyed from elsewhere (project control)

  LogObjectMain: TLoggerThreadSafeNew;
  LoggerProject: TLoggerThreadSafeNew;  //Stores project related messages - initialized from elsewhere (project control)
  LoggerReport: TLoggerThreadSafeNew;  //Stores RESULTS - initialized  from elsewhere (project control)

  //MsgListWarnings: TMVStringListThreadSafe;
  //MsgListErrors: TMVStringListThreadSafe;
  MsgQueueWarnings: TMVStringQueueThreadSafe;
  MsgQueueErrors: TMVStringQueueThreadSafe;
  MsgQueueProjectEvents: TMVStringQueueThreadSafe;
  MsgQueueResults: TMVStringQueueThreadSafe;


implementation



function TimeDeltaTICKMS( t0: longword): longword;
begin
  Result := GetTickCount;
  if Result>t0 then Result := Result - t0 else Result := 0;
end;


procedure LogMsg(a:String);  //logs to APP log only
begin
  if LogObjectMain=nil then ShowMessage('logmain not initialized - msg is: "' + a + '"');
  //LogMain.LogMsgStr(a);
  if LogObjectMain<>nil then LogObjectMain.LogMsg('      ' + a);
end;


procedure LogWarning(a:String); //add WARNING label and also loggs into project log
begin
  if LogObjectMain=nil then ShowMessage('logmain not initialized - msg is: "' + a + '"');
  //LogMain.LogWarningStr(a);
  if LogObjectMain<>nil then LogObjectMain.LogMsg('WARNING: ' + a);  //timestamp will be included in s
  if MsgQueueWarnings<>nil then MsgQueueWarnings.PushMsg(a);
end;

procedure LogError(a:String); //add ERROR label and also loggs into project log
begin
  if LogObjectMain=nil then ShowMessage('logmain not initialized - msg is: "' + a + '"');
  //LogMain.LogErrorStr(s);
  if LogObjectMain<>nil then LogObjectMain.LogMsg('ERROR: ' + a);
  if MsgQueueErrors<>nil then MsgQueueErrors.PushMsg(a);
end;


procedure LogProjectEvent(a:String);     //logs into project log + copy to applog
begin
  if LoggerProject=nil then logmsg('LogProject: not initialized - msg is: "' + a + '"');
  LoggerProject.LogMsg(a);
  //if LogObjectMain<>nil then ts := LogObjectMain.GenTimestampStr else ts := '';
  if LogObjectMain<>nil then LogObjectMain.LogMsg('PROJECTEVENT: ' + a);
  if MsgQueueProjectEvents<>nil then MsgQueueProjectEvents.PushMsg(a);
end;


procedure LogReport(a:String);   //FOR STORING RESULTS
begin
  if LoggerReport=nil then logmsg('LogProject: not initialized - msg is: "' + a + '"');
  //if LogObjectMain<>nil then ts := LogObjectMain.GenTimestampStr else ts := '';
  if LoggerReport<>nil then LoggerReport.LogMsg(a);
  if LogObjectMain<>nil then LogObjectMain.LogMsg('REPORT: ' + a);
  if MsgQueueResults<>nil then MsgQueueResults.PushMsg(a);
end;

//**************


procedure LoggerInit(dir: string='');       //call after app start
begin
   if dir<>'' then __defaultLogDir := dir;  
   if LogObjectMain<>nil then LogObjectMain.StartLogFilePrefix(Capplogfilenamepref, Capplogfilenamesuf);
   LogMsg('LogInit: done.');
end;


procedure LoggerFinish;     //call before app closes to destroy objects
begin
  LogMsg('LoggerFinish: Application is going to terminate... WILL CLOSE LOGS');
end;


//--------------


constructor TLoggerOld.Create;
begin
  //inherited;
  logopen := false;
  PlogProc := nil;
  PWarningProc := nil;
  PErrorProc := nil;
  verbose := false;
  GetLocaleFormatSettings(0, FormatSettings);
  //create synchronize object (safe access from mutliple threads)
  synchro := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TLoggerOld.Destroy;
begin
  FreeAndNil( synchro );
  inherited;
end;


function TLoggerOld.LoggerNowString: string;  //returns actual datetime up to miliseconds to be put at begginning of line
begin
  DateTimeToString(Result, 'yyyy-mm-dd_hh:nn:ss.zzz', Now(), formatsettings);    // DateTimeToStr(Time);    //datetimetostring     DateTimeToString
end;


procedure TLoggerOld.LogMsgStr(a:String);
begin
  //lock access
  if Synchro<>nil then Synchro.beginWrite;
  //external log proc
  try
     if assigned(PLogProc) then PLogProc(a);    //TODO: CHECK if it is neccesary to use SYNCHrONIZE  //TApplication
  except
    on E:Exception do ShowMessage( 'TLoggerOld.LogMsgStr: Exception when call assigned proc: ' + E.message);
  end;

  //
  if not logopen then ResetLog;
  if not logopen then
    begin
    if verbose then ShowMessage('Log file not working!');
    exit;
    end;
  {$I-}
  Append(logfile);
  if (IoResult <> 0) then
    begin
    logopen := false;
    if verbose then ShowMessage('TLoggerOld.LogMsgStr: Error appending!');
    exit;
    end;
  {$I+}
  Writeln(logfile, LoggerNowString + ' ' + a);
  closeFile(logfile);
  //unlock
  if Synchro<>nil then Synchro.endWrite;
end;


procedure TLoggerOld.LogWarningStr(a:String);
Var
 s: string;
begin
  s := 'WW: ' + a;
  LogMsgStr(s);
  try
    if assigned(PWarningProc) then PWarningProc(a);
  except
    on E:Exception do ShowMessage( 'TLoggerOld.LogWarningStr: Exception when call assigned proc: ' + E.message);
  end;
end;

procedure TLoggerOld.LogErrorStr(a:String);
Var
 s: string;
begin
  s := 'EEEE: ' + a;
  LogMsgStr(s);
  try
     if assigned(PErrorProc) then PErrorProc(a);
  except
    on E:Exception do ShowMessage( 'TLoggerOld.LogErrorStr: Exception when call assigned proc: ' + E.message);
  end;
end;


procedure TLoggerOld.AssignLogProc(msgproc: TMsgProc);
begin
  PlogProc := msgproc;
end;


procedure TLoggerOld.AssignWarningProc(msgproc: TMsgProc);
begin
  PWarningProc := msgproc;
end;


procedure TLoggerOld.AssignErrorProc(msgproc: TMsgProc);
begin
  PErrorProc := msgproc;
end;


procedure TLoggerOld.ResetLog(forcerewrite:boolean = false);
begin
  //AssignLogFile;
  {$I-}
  //check if file exists
  Append( logfile );
  if (IoResult = 0) then
    begin
    Writeln(logfile);
    Writeln(logfile, '=================== Reset ' + DateTimeToStr( Now() ) + ' ====================');
    Writeln(logfile);
    Closefile(logfile);
    logopen := true;
    end;
  if (not logopen) or (forcerewrite)  then
    begin
    ReWrite(logfile);
    if (IoResult = 0) then
      begin
      logopen := true;
      end;
    end;
  if not logopen then
    begin
    if verbose then ShowMessage('RESET LOG: rewrite failed');
   //LogMsg('LOG: rewrite failed'); WILL LOOP !!
    end;
  {$I+}
end;

procedure TLoggerOld.AssignLogFile(prefix, suffix: string);
Var
  fnstr, tstr: string;
begin
  //generate app log filename
  //GetLocaleFormatSettings(0, LogMain.FormatSettings);
  DateTimeToString(tstr, 'yyyy-mm-dd-hh-nn-ss', Now(), FormatSettings);
  fnstr := prefix + tstr + suffix;
  {$I-}
  AssignFile(logfile, DataPath + fnstr );
  MkDir(DataPath);  //TODO: make sure dir exists
  IOresult;
  //if (IoResult <> 0) then ShowMessage('LOG: MKDIR failed');
  {$I+}
end;






//****************************************




constructor TLogOutput.Create;
begin
  inherited Create;
  fInited := false;
end;

destructor TLogOutput.Destroy;
begin
  inherited;
end;

procedure TLogOutput.WriteSList(const sl: TStringList);
Var
 i: longint;
begin
  if not fInited then exit;
  if sl=nil then exit;
  Lock;
    try
      begin
       {$I-}
        Append(fFile);
        if (IoResult = 0) then
          begin
             try
               begin
                 for i:=0 to sl.Count -1 do
                   begin
                     Writeln(fFile, sl[i]);
                   end;
               end;
             finally
               CloseFile(fFile);
             end;
          END;
        {$I+}
      end;
    finally
     Unlock;
    end;
end;

procedure TLogOutput.Writestr(const s: String);
begin
  if not fInited then exit;
  Lock;
    try
     begin
       Append(fFile);
       Writeln(fFile, s);
     end;
    finally
     CloseFile(fFile);
    end;
  Unlock;
end;


procedure TLogOutput.Init(fullfname: string);
Var dir: string;
    b1, fexst: boolean;
begin
  Lock;
    fInited := false;
    dir := ExtractFileDir(fullfname);
    b1 := MakeSureDirExist( dir );
    if (dir<>'') and (not b1) then
      begin
        Unlock;
        exit;
      end;
    fexst := false;
   {$I-}
    Assign(fFile, fullfname+'');
    //check if file exists
    Append( fFile );
    if (IoResult = 0) then
      begin
        fexst := true;
        CloseFile( fFile);
      end;
     if not fexst then
       begin
         //try rewrite
         ReWrite(fFile);
         if (IoResult = 0) then
           begin
             fexst := true;
             CloseFile( fFile);
           end;
       end;
    {$I+}
    fInited := fexst;
  Unlock;
end;


procedure TLogOutput.Close;
begin
  Lock;
    fInited := false;
  Unlock;
end;





constructor TLogWorkThread.Create(logout: TLogOutput; queue: TMVStringQueueThreadSafe; CommitEveryMS: longint = 60000; WakeupEveryMS: longint = 1000; ForceDumpIfN: longint = 100);
begin
  inherited Create(true);
  FreeOnTerminate := false;
  fOut := logout;
  fQ := queue;
  fCommitEveryMS := CommitEveryMS;
  fWakeupEveryMS := WakeupEveryMS;
  fForceDumpOnN := ForceDumpIfN;
  fForceDumpBool := TMVVariantThreadSafe.Create( false);
  fsl := TStringList.Create;
end;

destructor TLogWorkThread.Destroy;
begin
  fForceDumpBool.valBool := true;
  Terminate;
  WaitFor;
  fForceDumpBool.Destroy;
  fsl.Destroy;
  inherited;
end;





procedure TLogWorkThread.Execute;
begin
  if (fQ=nil) or (fOut=nil) then exit;
  fLastWrite := GetTickCount; //fCommitEveryMS + 1;
  //write initial msg
  fOut.Writestr(DateTimeToStr(Now)+': #init');
  //main loop
  while true do
    begin
      if (fCommitEveryMS>TimeDeltaTICKMS( fLastWrite ))
         or (fForceDumpOnN < fQ.Count) or (fForceDumpBool.valBool) then
        begin
          fsl.Clear;
          while not fQ.IsEmpty do
              fsl.Add( fQ.PopMsg );
          fOut.WriteSList( fsl );
          fLastWrite := GetTickCount;
        end;
      if Terminated then break;
      sleep(fWakeupEveryMS);
    end;
  //dump remaining lines
  fsl.Clear;
  while not fQ.IsEmpty do fsl.Add( fQ.PopMsg );
  fOut.WriteSList( fsl );
  //write termianting msg
  fOut.Writestr(DateTimeToStr(Now)+': #terminated');
end;



procedure TLogWorkThread.ForceDump;
begin
  fForceDumpBool.valBool := true;
end;


//%%%%%%%%%%%%%%%%%%%%%%%%%


constructor TLoggerThreadSafeNew.Create;
begin
  inherited Create;
  fOutputObj := TLogOutput.Create;
  fQueue := TMVStringQueueThreadSafe.Create;
  fWorkThread := nil;
  fLogPath := '';
  fLastExitCode := 0;
  GetLocaleFormatSettings(0, fFormatSet);
  fFormatSet.DecimalSeparator := '.';
end;


destructor TLoggerThreadSafeNew.Destroy;
begin
    if fWorkThread<>nil then CloseLog;
    fOutputObj.Destroy;
    fQueue.Destroy;
    inherited;
end;


function TLoggerThreadSafeNew.LogMsg(a:String; addTimestamp: boolean = true): string;
begin
  if addTimestamp then  Result := GenTimestampStr+' ' + a
  else Result := a;
  if fQueue<>nil then fQueue.PushMsg( Result );
end;



procedure TLoggerThreadSafeNew.StartLogFilePrefix(prefix, suffix: string; dir: string = '');
Var s, tstr: string;
begin
  DateTimeToString(tstr, 'yyyy-mm-dd-hh-nn-ss', Now(), fFormatSet);
  if dir='' then dir := __defaultLogDir;
  s := dir + Backslash + prefix + tstr + suffix;
  StartLogFileName(s);
end;

procedure TLoggerThreadSafeNew.StartLogFileName(fullname: string);
begin
  fOutputObj.Init( fullname );
  fWorkThread := TLogWorkThread.Create( fOutputObj, fQueue);
  //NOOOO fWorkThread.FreeOnTerminate := true;
  fWorkThread.Resume;
end;



procedure TLoggerThreadSafeNew.CloseLog;
begin
  if fWorkThread<>nil then
    begin
      fWorkThread.Destroy; //!!! terminate is called inside the destroy  - this is modified class, not TThread directly!!!
      fWorkThread := nil; //!!! indication o ffinished work
    end;
  fOutputObj.Close;
end;

procedure TLoggerThreadSafeNew.ResetLog(forcerewrite:boolean = false);
begin
  CloseLog;
  StartLogFileName(fLogPath);
end;



function TLoggerThreadSafeNew.GenTimestampStr: string;
begin
  DateTimeToString(Result, 'yyyy-mm-dd_hh:nn:ss.zzz', Now(), fFormatSet);    // DateTimeToStr(Time);    //datetimetostring     DateTimeToString
end;



initialization

  __defaultLogDir := GetCurrentDir + Backslash + 'log';
  //
  LogObjectMain := TLoggerThreadSafeNew.Create;
  LoggerProject := TLoggerThreadSafeNew.Create;  //Stores project related messages - initialized from elsewhere (project control)
  LoggerReport := TLoggerThreadSafeNew.Create;
  //
  //MsgListWarnings := TMVStringListThreadSafe.Create;
  //MsgListErrors := TMVStringListThreadSafe.Create;
  MsgQueueWarnings := TMVStringQueueThreadSafe.Create;
  MsgQueueErrors := TMVStringQueueThreadSafe.Create;
  MsgQueueProjectEvents := TMVStringQueueThreadSafe.Create;
  MsgQueueResults := TMVStringQueueThreadSafe.Create;

  finalization

  if LogObjectMain<> nil then LogObjectMain.Destroy;
  if LoggerProject<> nil then  LoggerProject.Destroy;
  if LoggerReport<> nil then LoggerReport.Destroy;
  //
  if MsgQueueWarnings<> nil then MsgQueueWarnings.Destroy;
  if MsgQueueErrors<> nil then MsgQueueErrors.Destroy;
  if MsgQueueProjectEvents<> nil then MsgQueueProjectEvents.Destroy;
  if MsgQueueResults<> nil then MsgQueueResults.Destroy;
end.

unit LoggerFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  Logger, FormGlobalConfig;

type
  TLoggerForm = class(TForm)
    PCLog: TPageControl;
    TabProjectLog: TTabSheet;
    TabWarningLog: TTabSheet;
    TabErrorLog: TTabSheet;
    MeProjLog: TMemo;
    Button2: TButton;
    BuClearProj: TButton;
    Panel1: TPanel;
    MeERRORlog: TMemo;
    Panel2: TPanel;
    MeWarningLog: TMemo;
    BuClearWarning: TButton;
    BuClearError: TButton;
    BuResetWarning: TButton;
    PanWarningCount: TPanel;
    PanErrorCount: TPanel;
    BuResetError: TButton;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    BuHide: TButton;
    Button7: TButton;
    Button8: TButton;
    TabReport: TTabSheet;
    Button6: TButton;
    Button9: TButton;
    MeReport: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Init;
    procedure Button2Click(Sender: TObject);
    procedure BuHideClick(Sender: TObject);
    procedure BuClearProjClick(Sender: TObject);
    procedure BuClearWarningClick(Sender: TObject);
    procedure BuClearErrorClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BuResetWarningClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BuResetErrorClick(Sender: TObject);
  public //logging functions
    procedure ProcessWarningErrorEventsLogMesages;
    procedure LogProjectMsg(s: string);
    procedure LogWarningMsg(s: string);
    procedure LogErrorMsg(s: string);
    procedure LogReportMsg(s: string);
  private
    { Private declarations }
    procedure UpdateDir;
    procedure UpdateWarningCnt(n: longint);
    procedure UpdateErrorCnt(n: longint);
    function NowString: string;  //returns actual datetime up to miliseconds
  private
    fWarningCnt: longint;
    fErrorCnt: longint;
  public
    { Public declarations }
    property WarningCount: longint read fWarningCnt write UpdateWarningCnt;
    property ErrorCount: longint read fErrorCnt write UpdateErrorCnt;
  end;

var
  LoggerForm: TLoggerForm;

implementation

uses FormProjectControl;

{$R *.dfm}

procedure TLoggerForm.FormCreate(Sender: TObject);
begin
  LogMsg('TLoggerForm.FormCreate DONE.');
end;

procedure TLoggerForm.ProcessWarningErrorEventsLogMesages;
begin
   if MsgQueueWarnings<>nil then
       while not MsgQueueWarnings.IsEmpty do
           LoggerForm.LogWarningMsg( MsgQueueWarnings.PopMsg );
  //
  if MsgQueueErrors<>nil then
       while not  MsgQueueErrors.IsEmpty do
            LoggerForm.LogErrorMsg(  MsgQueueErrors.PopMsg );
  //
  if MsgQueueProjectEvents<>nil then
       while not  MsgQueueProjectEvents.IsEmpty do
         LoggerForm.LogProjectMsg(  MsgQueueProjectEvents.PopMsg );
  //
  if MsgQueueResults<>nil then
       while not  MsgQueueResults.IsEmpty do
         LoggerForm.LogReportMsg(  MsgQueueResults.PopMsg );
end;



procedure TLoggerForm.Init;
Var
  Pproc: TMsgProc;
begin
  fWarningCnt := 0;
  fErrorCnt := 0;
  Panel2.Color := clOrange;
  if ProjectControl = nil then exit;
  ProjectControl.RegOnProjectUpdateMethod( UpdateDir );
  UpdateDir;
  LogMsg('TLoggerForm.Init DONE.');
end;

procedure TLoggerForm.UpdateDir;
Const
  CprefProj = '!log_project_';
  CprefReport = '!log_RESULTS_';
  Csuff = '.txt';
Var
  dir: string;
begin
  if ProjectControl = nil then exit;
  dir := ProjectControl.getProjPath;    //placed in project directory
  logmsg('TLoggerForm.UpdateDir - changing DIR, new dir is: '+ dir);
  if LoggerProject<>nil then
    begin
      LoggerProject.LogMsg('will restart log - new dir is: ' + dir);
      LoggerProject.CloseLog;
      LoggerProject.StartLogFilePrefix( CprefProj, Csuff, dir);   //placed in project directory
    end;
  //
  if LoggerReport<>nil then
    begin
      LoggerReport.LogMsg('will restart log - new dir is: ' + dir);
      LoggerReport.CloseLog;
      LoggerReport.StartLogFilePrefix(CprefReport, Csuff, dir); //placed in project directory
    end;
  LogMsg('TLoggerForm.UpdateDir DONE.');
end;


procedure TLoggerForm.UpdateWarningCnt(n: longint);
begin
  fWarningCnt := n;
  PanWarningCount.Caption := IntToStr( n );
end;

procedure TLoggerForm.UpdateErrorCnt;
begin
  fErrorCnt := n;
  PanErrorCount.Caption := IntToStr( n );
end;


procedure TLoggerForm.LogProjectMsg(s: string);
begin
  MeProjLog.Lines.Add( NowString + ' ' + s );
end;

procedure TLoggerForm.LogWarningMsg(s: string);
begin
  MeWarningLog.Lines.Add( NowString + ' ' + s );
  WarningCount := WarningCount + 1;
end;

procedure TLoggerForm.LogErrorMsg(s: string);
begin
  MeErrorLog.Lines.Add( NowString + ' ' + s );
  ErrorCount := ErrorCount + 1;
end;

procedure TLoggerForm.LogReportMsg(s: string);
begin
  MeReport.Lines.Add( NowString + ' ' + s );
end;


function TLoggerForm.NowString: string;  //returns actual datetime up to miliseconds
begin
  DateTimeToString(Result, '[yyyy-mm-dd_hh:nn:ss.zzz]', Now());    // DateTimeToStr(Time);    //datetimetostring     DateTimeToString
end;


procedure TLoggerForm.Button2Click(Sender: TObject);
begin
  LogProjectEvent('Test');
end;

procedure TLoggerForm.BuHideClick(Sender: TObject);
begin
  LoggerForm.Hide;
end;

procedure TLoggerForm.BuClearProjClick(Sender: TObject);
begin
  MeProjLog.Lines.Clear;
end;

procedure TLoggerForm.BuClearWarningClick(Sender: TObject);
begin
  MeWarningLog.Lines.Clear;
  LogWarningMsg('*** Log Cleared and Counter Reset ***');
  WarningCount := 0;
end;

procedure TLoggerForm.BuClearErrorClick(Sender: TObject);
begin
  MeERRORlog.Lines.Clear;
  LogErrorMsg('*** Log Cleared and Counter Reset ***');
  ErrorCount := 0;
end;




procedure TLoggerForm.Button1Click(Sender: TObject);
begin
  LogWarningMsg('test');
end;

procedure TLoggerForm.Button3Click(Sender: TObject);
begin
  LogErrorMsg('test');
end;

procedure TLoggerForm.BuResetWarningClick(Sender: TObject);
begin
  LogWarningMsg('*** Reseting Warning counter...');
  WarningCount := 0;
end;

procedure TLoggerForm.Button4Click(Sender: TObject);
begin
   LogError('simul error');
end;

procedure TLoggerForm.BuResetErrorClick(Sender: TObject);
begin
  LogErrorMsg('*** Reseting Error counter...');
  ErrorCount := 0;
end;

end.

unit main;
//{$I VAcharakteristikaOptions.inc}

interface                                                                  //TApplication
                                                                           // TApplicationEvents
uses
{$ifdef FastMM4Add}
  FastMMUsageTracker,
{$endif}
  Windows, psAPI, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Buttons,
  Dialogs, StdCtrls, OleCtrls, ExtCtrls, ActnList, Gauges, ComCtrls, DateUtils,
  TeEngine, Series, TeeProcs, Chart, Spin,
  //
  //jclDebugExpert,
  //
  debug, myutils, Logger, LoggerFormUnit, DataStorage, MyChartModule,
  HWAbstractDevicesV3, HWinterface,
  FormGlobalConfig, FormProjectControl,
  FormHWAccessControlUnit,
  FormPTCHardwareUnit, FormFlowHardwareUnit,
  FormNewProjectUnit, FormAdvancedPlotUnit, FormStatusUnit,
  module_simple, Module_VAchar, ModuleCVUnit, ModuleEISunit, module_batch, FormModuleBatchRomanUnit,
  FormDebugUnit, FormValveControlUnit, FlowInterface_FCS_TCPIP, testloadgui,

  jclDebug;


//inside today.inc are definitions of present day that are to be used when displaying info
// to update the file -> compile twice like in Tex ;-) ! in formcreate is called proc 'update_today.inc'
{$I today.inc}


const
    CMonAnimationPhases = 255;

    CForceAquireTimeMs = 1000;

type

  TFormMain = class(TForm)
    PanMonitor: TPanel;
    LaTemp: TLabel;
    Label73: TLabel;
    LaWarningMsgInfo: TLabel;
    PanProject: TPanel;
    Label23: TLabel;
    BuProjNew: TButton;
    BuProjResume: TButton;
    BuProjEdit: TButton;
    Label9: TLabel;
    Label12: TLabel;
    Label15: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    PanHW: TPanel;
    BuHWFormOpen: TButton;
    PanPTCStatus: TPanel;
    LaPTCName: TLabel;
    LaPTCStatus: TLabel;
    MonTimer: TTimer;
    Label35: TLabel;
    Label37: TLabel;
    Label40: TLabel;
    LaProjName: TLabel;
    PanPlot: TPanel;
    MainChart: TChart;
    Series1: TFastLineSeries;
    CBplotSelData: TComboBox;
    Label33: TLabel;
    PanModules: TPanel;
    BuTaskRequestStop: TButton;
    Label2: TLabel;
    BuFlowControlOpen: TButton;
    CBInvVoltage: TCheckBox;
    CBInvCurrent: TCheckBox;
    BuProjClose: TButton;
    LaLastMsg: TLabel;
    PanCellArea: TPanel;
    PanProjPath: TPanel;
    PanProjDescript: TPanel;
    PanFlowStatus: TPanel;
    LaFlowName: TLabel;
    LaFlowStatus: TLabel;
    BuConnectAll: TButton;
    PanAnLoading: TPanel;
    PanAnStoich: TPanel;
    PanAnodeMat: TPanel;
    PanMEAprep: TPanel;
    PanMembrane: TPanel;
    PanAnodeGDL: TPanel;
    PanCathMat: TPanel;
    PanCathGDL: TPanel;
    Label16: TLabel;
    PanCathLoading: TPanel;
    Label22: TLabel;
    PanCathStoich: TPanel;
    CBFlowTracking: TCheckBox;
    PanCurrMinLim: TPanel;
    PanCurrMaxLim: TPanel;
    PanVoltMinLim: TPanel;
    PanVoltMaxLim: TPanel;
    Label36: TLabel;
    Label44: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    PanGlobConf: TPanel;
    Label38: TLabel;
    PanStationID: TPanel;
    Label1: TLabel;
    PanFileCnt: TPanel;
    BuEditGlobConf: TButton;
    ProjOpenDialog: TOpenDialog;
    LaPress: TLabel;
    BuTaskOpenModSimple: TButton;
    BuTaskOpenModVAChar: TButton;
    BuTaskOpenModBatch: TButton;
    BuTaskOpenCv: TButton;
    BuTaskOpenEIS: TButton;
    PanHWAccess: TPanel;
    LaTaskName: TLabel;
    LaTaskProgress: TLabel;
    BuPTCConnect: TButton;
    BuPTCDiscon: TButton;
    LaHWWarning: TLabel;
    BuTaskOpenModBatch2: TButton;
    Label24: TLabel;
    StatusBar1: TStatusBar;
    BuFlowInit: TButton;
    CBPlotSelTimeScale: TComboBox;
    Series2: TFastLineSeries;
    Series3: TFastLineSeries;
    Series4: TFastLineSeries;
    TBMainChartPos: TTrackBar;
    BuMainChartLeft: TButton;
    BuMainChartRight: TButton;
    BuMainChartReset: TButton;
    PanReport: TPanel;
    BuReport: TButton;
    BuAdvancePlot: TButton;
    BuShowDebug: TButton;
    BuShowLog: TButton;
    PanValvesStatus: TPanel;
    LaValvesName: TLabel;
    LaValvesStatus: TLabel;
    BuValvesInit: TButton;
    Button2: TButton;
    LaErrorMsgInfo: TLabel;
    Button1: TButton;
    HWIniTimer: TTimer;
    Button3: TButton;
    TimChkSynchronize: TTimer;
    MonMemProgrBar: TProgressBar;
    Label6: TLabel;
    LaMonHistInfo: TLabel;
    BuMonReleaseMem: TButton;
    BuMainCHartPlus: TButton;
    BuMainCHartMinus: TButton;
    BuFlowFinal: TButton;
    BuValvesFin: TButton;
    LaTaskProgress2: TLabel;
    Button4: TButton;
    chkAutoStartMeasure: TCheckBox;
    ComboBox1: TComboBox;
    TimerBatchAutoStart: TTimer;
    PanMonPTC: TPanel;
    LaMonVolt: TLabel;
    LaMonCurr: TLabel;
    LaMonPow: TLabel;
    LaMonVref: TLabel;
    PanPTCFuse: TPanel;
    PanPTCSafeRange: TPanel;
    PanPTCoutput: TPanel;
    PanMonFlow: TPanel;
    LaFlow4T: TLabel;
    LaFlow4M: TLabel;
    LaFlow4B: TLabel;
    LaFlow3T: TLabel;
    LaFlow3M: TLabel;
    LaFlow3B: TLabel;
    LaFlow2T: TLabel;
    LaFlow2M: TLabel;
    LaFlow2B: TLabel;
    LaFlow1T: TLabel;
    LaFlow1M: TLabel;
    LaFlow1B: TLabel;
    PanPtcMode: TPanel;
    PanPTCV4SafeRange: TPanel;
    PanPTCIrange: TPanel;
    PanPTCIraw: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button5: TButton;
    Button6: TButton;
    PanPTCsp: TPanel;
    Button7: TButton;
    PanPTCUraw: TPanel;
    Button8: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MonTimerTimer(Sender: TObject);
    procedure BuProjNewClick(Sender: TObject);

    procedure LabelRHMouseEnter(Sender: TObject);
    procedure LabelRHMouseLeave(Sender: TObject);
    procedure LabelRHClick(Sender: TObject);
    procedure LabelRHLabClick(Sender: TObject);
    procedure LabelRHLabMouseEnter(Sender: TObject);
    procedure LabelRHLabMouseLeave(Sender: TObject);
    procedure BuPTCConnectClick(Sender: TObject);
    procedure BuTaskOpenModSimpleClick(Sender: TObject);
    procedure BuTaskOpenModVACharClick(Sender: TObject);
    procedure BuTaskOpenModBatchClick(Sender: TObject);
    procedure BuHWFormOpenClick(Sender: TObject);
    procedure BuPTCDisconClick(Sender: TObject);
    procedure BuShowLogClick(Sender: TObject);
    procedure BuProjEditClick(Sender: TObject);
    procedure PanProjPathClick(Sender: TObject);
    procedure BuProjCloseClick(Sender: TObject);
    procedure PanMonitorResize(Sender: TObject);
    procedure BuEditGlobConfClick(Sender: TObject);
    procedure BuProjResumeClick(Sender: TObject);
    procedure BuMonReleaseMemClick(Sender: TObject);
    procedure BuAdvancePlotClick(Sender: TObject);
    procedure BuTaskOpenModBatch2Click(Sender: TObject);
    procedure CBPlotSelTimeScaleChange(Sender: TObject);
    procedure MainChartResize(Sender: TObject);
    procedure CBplotSelDataChange(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure BuMainChartLeftClick(Sender: TObject);
    procedure BuMainChartRightClick(Sender: TObject);
    procedure BuFlowControlOpenClick(Sender: TObject);
    procedure MainChartZoom(Sender: TObject);
    procedure MainChartUndoZoom(Sender: TObject);
    procedure MainChartScroll(Sender: TObject);
    procedure BuMainChartResetClick(Sender: TObject);
    procedure BuShowDebugClick(Sender: TObject);
    procedure LaWarningMsgInfoClick(Sender: TObject);
    procedure LaErrorMsgInfoClick(Sender: TObject);
    procedure HWIniTimerTimer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TimChkSynchronizeTimer(Sender: TObject);
    procedure LaFlow1MClick(Sender: TObject);
    procedure BuReportClick(Sender: TObject);
    procedure BuFlowFinalClick(Sender: TObject);
    procedure BuFlowInitClick(Sender: TObject);
    procedure BuMainCHartPlusClick(Sender: TObject);
    procedure BuMainCHartMinusClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BuTaskRequestStopClick(Sender: TObject);
    procedure BuValvesInitClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure TimerBatchAutoStartTimer(Sender: TObject);
    procedure BuValvesFinClick(Sender: TObject);
    procedure PanPTCV4SafeRangeClick(Sender: TObject);
    procedure PanProjectClick(Sender: TObject);
    procedure PanVoltMinLimClick(Sender: TObject);
    procedure PanVoltMaxLimClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure BuTaskOpenCvClick(Sender: TObject);
    procedure BuTaskOpenEISClick(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
    monitortoken : THWAccessToken;
    //
    MonitorLock: boolean;
    MonAnimationStep: byte;  //controls phase of animation for some graphic features
    MonBlinkEnabled: boolean;
    mainchartlock: boolean;
    maincharttmpdata: TMainChartTmpData;  //dynamic array
    mainchartselection: TSeriesSelection;
    mainchartdata: TChartDatapack;
    //
    fwindowLoadPosition: boolean;
    fModuleName: string;
    fMonHWErrorMessages: string;
    //
    fblinkRedbgcolor: TColor;
    fblinkRedfgcolor: TColor;
    fblinkOrangebgcolor: TColor;
    fblinkOrangefgcolor: TColor;
    fAnimsymbolcolor: TColor;
    fAnimSymbol: string;
    //
    fLastMswCtrlVal: integer;

    fThisProcPID: DWORD;
    fThisProcHandle: DWORD;

  public
    maingrconf: TGraphConf;  //configuration of the plot in the main window

  public
    {general public methods}
    procedure Inicializace;
    function GetMemUsage: longint;  //in kB
    procedure RefreshMonitor;
    procedure RefreshHWAccessPanel;
    procedure RefreshProjectInfoBox;
    procedure RefreshHWInfoPanel;
    procedure RefreshMonPTCPanel( aquired: boolean; Var datarec: TMonitorRec);
    procedure UpdateAnimatedObjects;
    procedure UpdateMonitorFlowDev( dev: TFlowDevices; Var flowdata: TFlowData; TCapt, MCapt, BCapt: TLabel);
    procedure ChartFill(chart: TChart; Var grconf: TGraphConf; data: TMonitorMemDataStorage);
    procedure MainChartRepaint;
    procedure MainChartInit;
    procedure UpdateMainCHartConf;
    procedure updateTodayinc;

  end;

//---------------------------------------

var
  FormMain: TFormMain;


//********************************************************************




implementation

uses  math, PTCCalibUsingBK8500Form, Debug_RegView;

{$ifdef FastMM4Add}
uses  FastMM4;
{$endif}

{$R *.dfm}


procedure TFormMain.FormCreate(Sender: TObject);              //tapplication
{$ifdef FastMM4Add}
var
  ms: TMemoryStream;
{$endif}
Var
  s: string;
begin
  //memory management and leak detection
  {$ifdef FastMM4Add}
  ms := TMemoryStream.Create;
  ms.LoadFromFile(Application.ExeName);
  RegisterExpectedMemoryLeak(ms);
  ms.Size := 0;
  {$endif}
  //updates file with present day definition to be included into the compilation
  updateTodayinc; // (to show real compilation time, date) -> compile twice like in Tex ! ;-)
  //
  //Logger must be initialized EARLY- it was done when LoggerForm is created BUT HERE iS BETTER
  s := ExtractFilePath( Application.ExeName );
  LoggerInit( s + CPathSlash +'log' );
  logmsg('This is >>>' + Application.ExeName + '<<<');
  logmsg('+In TFormMain.FormCreate...');
  //
  // *** Inicializace; //!!! udela se v hlavni smycce aplikace po vytvoreni Form1 and other necessary forms
  //the initialization procedure is called from main program AFTER ALL FORMS are created !!!!!
  //
  fwindowLoadPosition := false;
  fModuleName := 'MainForm';
  //
  MonAnimationStep := 0;
  s := 'FC Control v2017-beta';
{$IFDEF TODAYINC}
  s := s + ' build ' + DateTimeToStr( _builddatetime) + ' - ' + IntToStr( _buildcnt );
{$ENDIF}
  FormMain.Caption := s;
  //

  fLastMswCtrlVal := -1;

  fThisProcPID := GetCurrentProcessId;
  fThisProcHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, fThisProcPID);

  logmsg('   Current Process ID: ' + IntToStr( GetCurrentProcessID ));

  Randomize;

  logmsg('-TFormMain.FormCreate done.');
end;


procedure TFormMain.FormDestroy(Sender: TObject);
begin
  {$ifdef AddHumiForm}
  DestructorHumidificationSenzors();
  {$endif}
  {$ifdef FastMM4Add}
  ms.Free;
  {$endif}
end;


procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  buttonSelected : Integer;
begin
  buttonSelected := MessageDlg('Are you SURE to close PTC-Control? ',mtConfirmation, mbOKCancel, 0);
  // Show the button type selected
  if buttonSelected <> mrOK  then
  begin
    Action := caNone;
    exit;
  end;

  //disable refresh monitor
  MonTimer.Enabled := false;
  //send signal to save config to all registered modules
  //
  GlobalConfig.RunSaveTerminateSequence;
  //
  GlobalConfig.BroadCastSignal( CSigGoingTerminate );
  GlobalConfig.BroadCastSignal( CSigDestroy );    //especially meant for hardware interfaces - destroy threads antc..
  try
  //
  //MainChartFinish;
  //HW turnoff
  //TODO: consider alternative procedure for turning off (e.g. continue working?)
  //MainHWInterface.TerminateAll;
  //
  //
  GlobalConfig.SaveConfig;
  ProjectControl.CloseProject; //(false);
  //
  MonitorToken.Destroy;
  //
  HWInterfaceDestroy;
  LoggerFinish;
  except
    on E: Exception do ShowMessage('Got EXCEPTION during EXIT: ' + E.message);
  end;
  CloseHandle( fThisProcHandle );
  //ShowMessage('h6');
end;


procedure TFormMain.Inicializace;
Var
  rec: TFormPositionRec;
  sl: Tstringlist;
begin
  logmsg('--TFormMain.Inicializace start.');
  logmsg('IIIII '+ FormMain.Caption );

   //global config decimal separator
  if GlobalConfig.GlobalRegistrySection <> nil then
    begin
      if  GlobalConfig.GlobalRegistrySection.valBool[IdForceEnglishDecimalSeparatorSetting] then
         begin
           Application.UpdateFormatSettings := false;
           DecimalSeparator := '.';
           ThousandSeparator := ',';
         end;
    end;



  //main HW interface
  HWInterfaceInit;   //MainPTCInterface also make it ready early  but depends of HWACCESS CONTROL FORM!!!

  //register vars for restoring from position
  GlobalConfig.RegisterFormPositionRec(fModuleName, FormMain);
  GlobalConfig.GlobalRegistrySection.valstr[ IdAppVersionStr ] := FormMain.Caption;

  //PanReport.Color := clDarkOrange;
  PanGlobConf.Color := clDarkOrange;
  //
  monitortoken := THWAccessToken.Create;
  monitortoken.tokenname := 'Main Form';
  monitortoken.statusmsg := '-----';
  FormHWAccessControl.RegisterRootToken( monitortoken );

  
  // !!
  GlobalConfig.Initialize;
  GlobalConfig.LoadConfig;

  sl := Tstringlist.Create;
  //globalconfig.Registry.DumpIntoStringList( sl );
  globalconfig.Registry.DumpIntoStringList( sl );  //tlistbox  //tmemo //tcombobox
  FormDebug.ListBox1.Items.AddStrings( sl );
  sl.Destroy;


  GlobalConfig.InitFlag := true;
  //
  //monitorMemHisotry must be initialized - in DataStorageInit;
  DataStorageInittt;    //  MonitorMemHistory := TMonitorMemDataStorage.Create;
  if MonitorMemHistory<>nil then MonitorMemHistory.setMemLimitMB( 800 );



  GlobalConfig.RunStartupSequence;  //!!! new way of calling initialize - ofr all registered modules
   //     will send SigInit, SigLoadConf and SigAfterLoadConf to all registered modules
  //           old way is kept for now for backward compatibiilty

  //
  //ProjectControl.OpenDefaultProject;
  ProjectControl.RestoreLastProject;
  //
  LoggerForm.Init;
  //
  NewProjectForm.Initialize;
  //HW FORMs INIT !!!!

  //FormPTCHardware.Initialize;
  //FormFlowHardware.Initialize;

  //monitor init
  if MainHWInterface<>nil then MainHWInterface.MinLogInterval := 990;
  //other forms ini
  NewProjectForm.Initialize;
  //Batch Ini
  FormModuleBatchRoman.Inicializace;
  //chart
  //

  HWIniTimer.Enabled := true;  //do post ini delayed HW initialize (this method is called before app.run but e.g. for
                               //kolPTC it seems  it is necessary to wait for the dll form to start first and thats done after main form starts

  MainChartInit;
  CBPlotSelTimeScale.ItemIndex := 0; //default 2mins
  UpdateMainCHartConf;

  //form position and state

  Position := poDesigned;

  GlobalConfig.UseFormPositionRec(fModuleName, FormMain);

  //pre init PTC (need for kolptc with dll, which takes timne to load interface, and works after second init)
  //MainHWInterface.PTCinit;

  logmsg('--TFormMain.Inicializace done.');
  //at the end : start refresh monitor timer
  MonitorLock := false;
  //GlobalConfig.InitFlag := false;
  MonTimer.Enabled := true;
end;


procedure TFormMain.HWIniTimerTimer(Sender: TObject);
begin
  if HWIniTimer.Enabled = false then exit; //ahh this is  multiple call of event handler
  HWIniTimer.Enabled := false;
  //send  ini signal
  GlobalConfig.BroadCastSignal( CSigStartInitializeDevices );
  GlobalConfig.InitFlag := false;
end;


function TFormMain.GetMemUsage: longint;  //in MB
var
  pmc: TProcessMemoryCounters;
  cb: longint;
  hProc: Cardinal;
begin
  cb := SizeOf(_PROCESS_MEMORY_COUNTERS);
  pmc.cb := SizeOf(pmc);
  //  hProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, fThisProcPID);
  if GetProcessMemoryInfo(fThisProcHandle, @pmc, SizeOf(pmc)) then
    Result := pmc.WorkingSetSize div 1000
  else
    Result := -1;
  //closehandle( hProc);
end;


procedure TFormMain.MainChartInit;
begin
  //not dyunamic array now //setlength( maincharttmpdata, CMAinChartMaxTmpRecs );
  mainchartlock := false;
  maingrconf.maximized := true;
  maingrconf.userpos := false;
  maingrconf.deltat :=  10.0/(60*24); //10min default
  maingrconf.xincrement := dtThirtySeconds;       //30 secs
  maingrconf.maxpoints := 300;
  maingrconf.enabled := true;

  //initial selection of series
  mainchartselection.nseries := 0;
  mainchartdata.nseries := 0;
end;


//
//************************
//   Refresh Monitor
//*************************
//

procedure TFormMain.RefreshProjectInfoBox;
begin
//Refresh Project Info box
   //********************
   PanStationID.Caption := GlobalConfig.GlobStationIDStr;
   PanFileCnt.Caption := IntToStr( GlobalConfig.GlobFileCnt );
   //---
   LaProjName.Caption := ProjectControl.ProjName;
   PanProjPath.Caption := ProjectControl.ProjDir;
   PanProjDescript.Caption := ProjectControl.ProjDesc;
   PanCellArea.Caption := FloatToStrF( ProjectControl.ProjCellArea, ffFixed,4,2) + ' cm-2';
   CBInvCurrent.Checked :=  ProjectControl.ProjInvertCurrent;
   CBInvVoltage.Checked :=  ProjectControl.ProjInvertVoltage;
   CBFlowTracking.Checked :=  ProjectControl.ProjFlowTracking;
   PanAnodeMat.Caption := ProjectControl.ProjAnodeDescr;
   PanAnodeGDL.Caption := ProjectControl.ProjAnodeGDL;
   PanAnLoading.Caption := FloatToStrF( ProjectControl.ProjAnodeLoading, ffFixed,4,2) ;
   PanAnStoich.Caption := FloatToStrF( ProjectControl.ProjAnodeStoich, ffFixed,4,2) + '/' + FloatToStrF( ProjectControl.ProjAnodeMinFlow, ffFixed,4,0);
   PanCathMat.Caption := ProjectControl.ProjCathodeDescr;
   PanCathGDL.Caption := ProjectControl.ProjCathodeGDL;
   PanCathLoading.Caption := FloatToStrF( ProjectControl.ProjCathodeLoading, ffFixed,4,2) ;
   PanCathStoich.Caption := FloatToStrF( ProjectControl.ProjCathodeStoich, ffFixed,4,2) + '/' + FloatToStrF( ProjectControl.ProjCathodeMinFlow, ffFixed,4,0);
   PanMembrane.Caption :=  ProjectControl.ProjMembrane;
   PanMEAprep.Caption :=  ProjectControl.ProjMEApreparation;
   PanCurrMaxLim.Caption := FloatToStrF( ProjectControl.ProjMaxCurrent, ffFixed,4,2) + ' A';
   PanCurrMinLim.Caption := FloatToStrF( ProjectControl.ProjMinCurrent, ffFixed,4,2) + ' A';
   PanVoltMaxLim.Caption := FloatToStrF( ProjectControl.ProjMaxVoltage, ffFixed,4,2) + ' V';
   PanVoltMinLim.Caption := FloatToStrF( ProjectControl.ProjMinVoltage, ffFixed,4,2) + ' V';
end;



procedure TFormMain.RefreshHWAccessPanel;
begin

   if FormHWAccessControl.islocked then
     begin
      PanHWAccess.Color := clYellow;
      if FormHWAccessControl.stoprequested then
        PanHWAccess.Color := clRed;
      LaTaskName.Caption := FormHWAccessControl.gettaskname;
      LaTaskProgress.Caption := FormHWAccessControl.gettaskstatus;
      LaTaskProgress2.Caption := FormHWAccessControl.gettaskstatus2;
     end
   else
     begin
       PanHWAccess.Color := clSkyBlue;
       LaTaskName.Caption := 'Idle';
       LaTaskProgress.Caption := '---';
       LaTaskProgress2.Caption := '---';
     end;
end;



procedure TFormMain.RefreshHWInfoPanel;
Var
  PTC: TPotentiostatObject;
  FLOW: TFlowControllerObject;
  VTP: TVTPControllerObject;
  ready: boolean;
  namestr, DummyHWstr, labstr: string;
  pancolor: TColor;
begin
   DummyHWstr := '';
   if MainHWInterface= nil then exit;
   //use  MainIface.PTCStatus
   PTC := MainHWInterface.PTCControl.ControlObj;
   Flow := MainHWInterface.FlowControl.ControlObj;
   VTP := MainHWInterface.VTPControl.ControlObj;
   //ptc
   if PTC=nil then
     begin
       ready := false;
       namestr := 'NOT ASSIGNED';
     end
   else
     begin
      namestr := PTC.DevName;
      ready := PTC.IsReady;
      if PTC.IsDummy then DummyHWStr := DummyHWStr + 'PTC is VIRTUAL! ';
     end;
   if ready then
   begin
     labstr := 'PTC ready';
     pancolor := clGreen;
   end
   else
   begin
     labstr := 'PTC NOT ready';
     pancolor := clRed;
   end;
   LAPTCName.Caption := namestr;
   LAPTCStatus.Caption := labstr;
   PanPTCStatus.Color := pancolor;
   //
   //flow
   if Flow=nil then
     begin
       ready := false;
       namestr := 'NOT ASSIGNED';
     end
   else
     begin
      namestr := FLOW.DevName;
      ready := FLOW.IsReady;
      if FLOW.IsDummy then DummyHWStr := DummyHWStr + 'FlowControl is VIRTUAL! ';
     end;
   if ready then
   begin
     labstr := 'FlowCtrl is ready';
     pancolor := clGreen;
   end
   else
   begin
     labstr := 'FlowCtrl NOT ready';
     pancolor  := clRed;
   end;
   LAFlowName.Caption := namestr;
   LAFlowStatus.Caption := labstr;
   PanFlowStatus.Color := pancolor;
   //
   //valves temperature, pressures
   if VTP=nil then
     begin
       ready := false;
       namestr := 'NOT ASSIGNED';
     end
   else
     begin
      namestr := VTP.DevName;
      ready := VTP.IsReady;
      if VTP.IsDummy then DummyHWStr := DummyHWStr + 'VTPctrl is VIRTUAL! ';
     end;
   if ready then
   begin
     labstr := 'VTPCtrl ready';
     pancolor := clGreen;
   end
   else
   begin
     labstr := 'VTPCtrl NOT ready';
     pancolor  := clRed;
   end;
   LaValvesName.Caption := namestr;
   LaValvesStatus.Caption := labstr;
   PanValvesStatus.Color := pancolor;
   //
   fMonHWErrorMessages := fMonHWErrorMessages + DummyHWStr;
end;

procedure TFormMain.UpdateAnimatedObjects;
Var
  anisymbol: char;
  anisymbolcolor : TColor;
begin
  anisymbol := #32;
  Inc(MonAnimationStep);
   if MonAnimationStep>=CMonAnimationPhases then MonAnimationStep := 0;
   //determine blink state
   if (MonAnimationStep mod 2) = 0 then
     begin
       fblinkredbgcolor := clBlinkRed0bg;
       fblinkredfgcolor := clBlinkRed0fg;
       fblinkorangebgcolor := clBlinkOrange1bg;
       fblinkorangefgcolor := clBlinkOrange1fg;
     end
   else
     begin
       fblinkredbgcolor := clBlinkRed1bg;
       fblinkredfgcolor := clBlinkRed1fg;
       fblinkorangebgcolor := clBlinkOrange0bg;
       fblinkorangefgcolor := clBlinkOrange0fg;
     end;
   //animated symbol - work in progress
   case (MonAnimationStep mod 6) of
     0: begin fAnimSymbol := '[|---]'; end;
     1: begin fAnimSymbol := '[-|--]'; end;
     2: begin fAnimSymbol := '[--|-]'; end;
     3: begin fAnimSymbol := '[---|]'; end;
     4: begin fAnimSymbol := '[--|-]'; end;
     5: begin fAnimSymbol := '[-|--]'; end;
   end;
   case (MonAnimationStep mod 8) of
     0: begin fAnimSymbol := '[O]'; end;
     1: begin fAnimSymbol := '[OO]'; end;
     2: begin fAnimSymbol := '[OOO]'; end;
     3: begin fAnimSymbol := '[OOOO]'; end;
     4: begin fAnimSymbol := '[OOO]'; end;
     5: begin fAnimSymbol := '[OO]'; end;
     6: begin fAnimSymbol := '[O]'; end;
     7: begin fAnimSymbol := '[]'; end;
   end;

   MonBlinkEnabled := true;
   //if MonBlinkEnabled then
   //  begin
   //    Label7.Color := blinkRedbgcolor;
   //    Label7.Font.Color := blinkRedfgcolor;
   //    Label8.Color := blinkOrangebgcolor;
   //    Label8.Font.Color := blinkOrangefgcolor;
   //  end;
   //
   //Animation
   fAnimsymbolcolor := GenerateRainbowColor( MonAnimationStep, CMonAnimationPhases);
   //
   //
   //new error messages
   if LoggerForm.WarningCount > 0 then
     begin
       LaWarningMsgInfo.Color := clBlinkOrange1bg; //blinkOrangebgcolor;
       LaWarningMsgInfo.Font.COlor := clBlinkOrange1fg; //blinkOrangefgcolor;
       LaWarningMsgInfo.Caption := 'New Warning messages: '+ IntToStr(LoggerForm.WarningCount);
     end
   else
     begin
       LaWarningMsgInfo.ParentColor := true;
       LaWarningMsgInfo.Font.COlor := clGray;
       LaWarningMsgInfo.Caption := 'no new warnings';
     end;
   //
   if LoggerForm.ErrorCount > 0 then
     begin
       LaErrorMsgInfo.Color := clBlinkRed0bg;  //blinkRedbgcolor;
       LaErrorMsgInfo.Font.COlor := clBlinkRed0fg; //blinkRedfgcolor;
       LaErrorMsgInfo.Caption := 'New ERROR messages: '+ IntToStr(LoggerForm.ErrorCount);
     end
   else
     begin
       LaErrorMsgInfo.ParentColor := true;
       LaErrorMsgInfo.Font.COlor := clGray;
       LaErrorMsgInfo.Caption := 'no new error messages';
     end;
   //
end;



procedure TFormMain.RefreshMonPTCPanel( aquired: boolean; Var datarec: TMonitorRec);
  function PTCModeToColor( m: TPotentioMode ): TColor;
  begin
    case m of
      CPotCC: Result := clLime;
      CPotCV: Result := clRed;
      else Result := clGray;
    end;
  end;
Var
  strV, strI, strP, strVref, strInfo1, strInfo2, strInfo3, strInfo3u, strm, strSetp: string;
  bOut, bSwLim, bHWFuse: TTriState;
  modecol: TColor;
  ptcrec:TPotentioRec;
  ptcstatus: TPotentioStatus;
  ptcprocdata: TPTCProcessedData;
Const
  strXX = '---';
begin
   if not aquired then
   begin
     strV := 'PTC NOT Ready';
     strI := strXX;
     strP := strXX;
     strVref := strXX;
     strInfo1 := strXX;
     strInfo2 := strXX;
     strInfo3 := strXX;
     modecol := clGray;
     strm := strXX;
     strSetp := strXX;
     bOut:= CTriUndef;
     bSwLim:= CTriUndef;
     bHWFuse:= CTriUndef;
   end
   else
   begin
     ptcrec := DataRec.PTCrec;
     ptcstatus := DataRec.PTCStatus;
     strV := FloatToStrF( datarec.Unorm ,ffFixed,7,3) + ' V';;
     strI := FloatToStrF( datarec.Inorm*1000 ,ffFixed,8,1) + ' mA.cm-2';
     if not ptcstatus.isLoadConnected then strI := 'Open circuit (' + FloatToStrF( datarec.Inorm*1000 ,ffFixed,3,1) + ')';
     strP := FloatToStrF(datarec.Pnorm * 1000,ffFixed,8,1) + ' mW.cm-2';
     if not ptcstatus.isLoadConnected then strp := '( 0 mW.cm-2 )';
     strVref := FloatToStrF(datarec.Uref * 1000 , ffFixed,4, 0 ) + ' mV';;
     modecol := PTCModeToColor( ptcstatus.mode );
     strm := ptcmodetostr( ptcstatus.mode );
     strSetp := FloatToStrF(datarec.PTCStatus.setpoint, ffFixed, 4, 3 );
     strInfo1 := PTCRangeRecordToStr( ptcstatus.rngV4hard );
     strInfo2 := PTCRangeRecordToStr( ptcstatus.rangeCurrent );
     strInfo3 := FloatToStrF(datarec.Iraw , ffFixed, 6, 3 ) + ' A';
     strInfo3u := FloatToStrF(datarec.Uraw , ffFixed, 6, 3 ) + ' V';
     //
     bOut:= BoolToTriState( ptcstatus.isLoadConnected ) ;
     bSwLim:= BoolToTriState( FlagIsSet(ptcstatus.flagSet, CPtcSoftLimitationActive ) );
     bHWFuse:= BoolToTriState( FlagIsSet(ptcstatus.flagSet, CPtcHardFuseActivated ) );

   end;
   //repaint
       LaMonVolt.Caption := strV;
       LaMonCurr.Caption := strI;
       LaMonPow.Caption :=  strP;
       LAMonVref.Caption := strVref;
       //
       if bSwLim=CTriOn then LaMonCurr.Color := clYellow else  LaMonCurr.Color := clBlack;
       if bHWFuse=CTriOn then PanMonPTC.Color := clRed else  PanMonPTC.Color := clBlack;
       //
       PanPTCV4SafeRange.Caption := strInfo1;
       PanPTCIrange.Caption := strInfo2;
       PanPTCIraw.Caption := strInfo3;
       PanPTCUraw.Caption := strInfo3u;
       PanPTCoutput.Color := IndicatorColorOrange( bOut );
       PanPTCSafeRange.Color := IndicatorColorOrange( bSwLim );
       PanPTCFuse.Color := IndicatorColorRed( bHWFuse );
       PanPtcMode.Caption := strm;
       PanPTCsp.Caption :=  strSetp;
       PanPtcMode.Font.Color := modecol;
       PanPTCsp.Font.Color := modecol;
end;




procedure TFormMain.RefreshMonitor;
Var
  s,s2, ptcmodestr, relaystr, curstr: string;
  willaquire, HWaquired, ptcwasready, flowwasready, vptwasready: boolean;
  timerlaststate : boolean;
  dt1: Cardinal;
  //PTC: TPotentiostatObject;
  //FlowCtrl: TFlowControllerObject;

  DummyHWstr: string;
  //PTCobj: TPTCInterfaceObject;
  PTCFlags : TPotentioFlagSet;
  FlowFlags: TCommDevFlagSet;
  flowdev: TFlowDevices;

  datarec : TMonitorRec;
  flowData: TFlowData;
  flowStatus: TCommDevFlagSet;
  aquireres: boolean;
  ElapsedSinceLastAquireMS: longword;
  newstatus: integer;
  oklock: boolean;

begin
   fMonHWErrorMessages := '';
   if MonitorLock then exit;
   //
   if MainHWInterface=nil then
     begin
       ShowMessage('MainPTCiface=nil');
       exit;
     end;
   MonitorLock := true;
   //
   timerlaststate := MonTimer.Enabled;
   MonTimer.Enabled := false;

   dt1 := GetTickCount();
   //-----
   //AQUIRE!!!!!  if no task is using PTC and other hardware, it is role of this monitor to aquire
   //              new data !!!
   //
   //Project control panel
   //********************
   RefreshProjectInfoBox;
   //
   //Measurement Access control panel
   //********************
   RefreshHWAccessPanel;
   if GlobalConfig.dbgMeasureTime then logmsg('Refresh monitor seq2 time: ' + IntToStr( GetTickCount() - dt1 ) );
   dt1 := GetTickCount();
   //
   //HARDWARE Control panel
   //*******************************
   try
     RefreshHWInfoPanel;
   except
     on E: Exception do LogError(E.Message);
   end;
   //
   //Warning and Error lgo messages
   //*******************************
   LoggerForm.ProcessWarningErrorEventsLogMesages;
   //

   //
   //***********************
   //ANimated/blinking text - for some captions and objects
   UpdateAnimatedObjects;

   //
   DummyHWstr := '';
   Label73.Caption :='';
   HWAquired := false;
   willaquire := false;
   MonitorRecFillNaN( datarec );

   if not FormHWAccessControl.islocked then willaquire := true;
   ElapsedSinceLastAquireMS := TimeDeltaNowMS( MainHWInterface.LastAquireTime );
   if ElapsedSinceLastAquireMS > CForceAquireTimeMs then
     begin
       willaquire := true;
     end;
//   if not willaquire then Label73.Caption := 'Mon Aquire disabled because task is running';
   //CHECK
   if  willaquire then
    begin
      try
        monitortoken.getLock;  //oklock :=
          aquireres := MainHWInterface.AquireAll( monitortoken );
          ptcwasready := MainHWInterface.PTCwasReady;
          flowwasready := MainHWInterface.FlowwasReady;
          vptwasready := MainHWInterface.VTPwasReady;
          //
          DataRec := MainHWInterface.DataRec;
          //
          HWAquired := true;
        monitortoken.unlock;
      except
        on E:exception do logerror('TFormMain.RefreshMonitor Aquire gave exception ' + E.message );
      end;
      ///...? other HW - flow? ...    TODO:!!!!!
    end;

   if GlobalConfig.dbgMeasureTime then logmsg('Refresh monitor seq1 time: ' + IntToStr( GetTickCount() - dt1 ) );
   dt1 := GetTickCount();


   //
   //  Warnings and Anim - running indicator
   // *************************************
  //STATUS end ERROR/WARNING MESSAGES
   //Panel with Electric values & status
   //***********************************
   //to get processed values, use MainPTCiface and its variables
   //specifically, for Voltage and Current use functions:  Uprocessed, Iprocessed, InormProcessed
   //which process values according to project settings (for example "invertcurrent")
   //
   //
   // done aquire, now update status panel
   //
   //
   // ptc status
   RefreshMonPTCPanel( ptcwasready, datarec );

     //**************FLAGS **********************
       PTCflags := datarec.PTCStatus.flagSet;
       if FlagIsSet(PTCFlags, CPtcHardFuseActivated ) then DummyHWStr := DummyHWStr + ' PTC-FUSE Activated!';
   //
  //
  //FLOW STATUS
  //
  //resize  is done in ... (elsewhere)
  //aquire
  LaFlow1T.Caption := FlowDevToStr( CFlowAnode );
  LaFlow2T.Caption := FlowDevToStr( CFlowN2 );
  LaFlow3T.Caption := FlowDevToStr( CFlowCathode );
  LaFlow4T.Caption := FlowDevToStr( CFlowRes );
  //
  FlowFlags := datarec.FlowFlags;
  if flowwasready and (CCSConnectionLost in FlowFlags) then DummyHWStr := DummyHWStr + ' FlowDev Connection Lost!';
  if flowwasready then
         begin
           for flowdev:= low(TFlowDevices) to high(TFlowDevices) do
             begin
               if (CFlowSetpointDiffersFromFlow in datarec.FlowData[flowdev].flagSet) then
                   DummyHWStr := DummyHWStr + ' ' + FlowDevToStr(flowdev)+ ' FLOW!=SETPOINT';
             end;
         end;



  if not flowwasready then
    begin
     s := 'Not Ready';
     LaFlow1M.Caption := s;
     LaFlow2M.Caption := s;
     LaFlow3M.Caption := s;
     LaFlow4M.Caption := s;
     LaFlow1B.Caption := s;
     LaFlow2B.Caption := s;
     LaFlow3B.Caption := s;
     LaFlow4B.Caption := s;
    end
  else
    begin
      flowData := MainHWInterface.DataRec.FlowData;
      UpdateMonitorFlowDev( CFlowAnode, flowdata, LaFlow1T, LaFlow1M, LaFlow1B);
      UpdateMonitorFlowDev( CFlowN2, flowdata, LaFlow2T, LaFlow2M, LaFlow2B);
      UpdateMonitorFlowDev( CFlowCathode, flowdata, LaFlow3T, LaFlow3M, LaFlow3B);
      UpdateMonitorFlowDev( CFlowRes, flowdata, LaFlow4T, LaFlow4M, LaFlow4B);
    end;

  //*****************************
  //VTP SATUS

  LaPress.Caption := 'A: ' + FloatToStrF(datarec.SensorData[CpAnode].val,ffFixed,4,2) + ' bar ' +
                     ' C: ' + FloatToStrF(datarec.SensorData[CpCathode].val,ffFixed,4,2) + ' bar '
                     + '  piston: ' + FloatToStrF(datarec.SensorData[CpPiston].val,ffFixed,4,1) + ' bar';



  LaTemp.Caption := 'A-H2O: ' + FloatToStrF( datarec.SensorData[CTBubH2].val,ffFixed,5,1) + ' °C'
  + ' Cell: '   + FloatToStrF( datarec.SensorData[CTCellBot].val,ffFixed,5,1)
  + ' / '+ FloatToStrF( datarec.SensorData[CTCellTop].val, ffFixed,5,1)
  +' °C  C-H2O '
  + FloatToStrF( datarec.SensorData[CTBubO2].val, ffFixed,5,1)  +' °C';
  //Label64.Caption := FloatToStrF( Mon.ColdEndTemp, ffFixed, 5, 1) + ' °C';
  //

  //OTHER ERRORS
   if ProjectControl<>nil then if ProjectControl.logmonitornotworking then DummyHWStr := DummyHWStr + ' LOGFILE NOT WORKING ';


  MainHWInterface.fFCSInterlok := (MainHWInterface.fMSWCtrlStatus = 10);
  FormHWAccessControl.fSWInterlok := MainHWInterface.fFCSInterlok;
  //
  if MainHWInterface.fFCSInterlok then
      StrAdd( fMonHWErrorMessages, 'SW INTERLOCK ENGAGED (FCSControl)');

  if not MainHWInterface.fFCSInterlok then
    begin

     //FCS CONTROL INTERCONNECTION - send status - only if not locked
       //if locked - otherwise I want to keep the 2 value
      if FormHWAccessControl.islocked then
        begin
        MainHWInterface.VTPsetDevice( CMswStatus, 1, monitortoken );
       end
       else
       begin
         MainHWInterface.VTPsetDevice( CMswStatus, 0, monitortoken );
       end;

    end;

    //detect transition in mswctrl
    newstatus := MainHWInterface.fMSWCtrlStatus;
    if  newstatus <> fLastMswCtrlVal then
    begin
      if newstatus = 1 then
        begin
          //disable lock, start measurement
          logmsg('scheduling batch run');
          TimerBatchAutoStart.Enabled := true;
        end;

        if newstatus = 0 then
        begin
          //stop measurement, enable SW interlok, send singnal
          FormModuleBatchRoman.Button2Click(nil);
          MainHWInterface.VTPsetDevice( CMswStatus, 2, monitortoken );
        end;



    end;
    fLastMswCtrlVal := MainHWInterface.fMSWCtrlStatus;



   StrAdd( fMonHWErrorMessages, DummyHWstr);

   //HW ERRORS and dummy interface check !!!! WARN USER
   if length(fMonHWErrorMessages) > 0 then
     begin
       LaHWWarning.Visible := true;
       LaHWWarning.Color := fblinkRedbgcolor;
       LaHWWarning.Font.COlor := fblinkRedfgcolor;
       LaHWWarning.Caption := fMonHWErrorMessages;
     end
   else
     begin
       LaHWWarning.ParentColor := true;
       LaHWWarning.Font.COlor := clGray;
       LaHWWarning.Caption := 'no HW problems detected';
     end;

//
  StatusBar1.Panels[0].Text := 'FCS Control: ' + IntToStr( MainHWInterface.fMSWCtrlStatus );


//


   if GlobalConfig.dbgMeasureTime then logmsg('Refresh monitor seq3 time: ' + IntToStr( GetTickCount() - dt1 ) );
   dt1 := GetTickCount();
  //Other
  //
  //monitor memory usage display
  MonMemProgrBar.Position := MonitorMemHistory.MemUsageProcent;
  LaMonHistInfo.Caption := 'Monitor stored points: ' + IntToStr( MonitorMemHistory.CountTotal ) + '   Mem size: ' + IntToStr(MonitorMemHistory.MemUsageMB) + ' MB' ;
  //automaticallyl throw out some old data if memory limit is close to full
  if MonitorMemHistory.MemUsageProcent > 90 then
      begin
       // MonitorMemHistory.MakeSpaceProcents(20);
       // logmsg('Refresh monitor:  monitor buffer was 90% full - relesing 20% of oldest data stored in memory!');
      end;
  //test dummy
  //Memo1.Lines.Add( IntToStr( ii ) );     //@monrec
     // for ii:=1 to 30999 do MonitorMemHistory.AddRec( nil );


   if GlobalConfig.dbgMeasureTime then logmsg('Refresh monitor seq4 time: ' + IntToStr( GetTickCount() - dt1 ) );
   dt1 := GetTickCount();


  //***********************************
  //Plot Panel
  //
  //prepare/update data for graph

  //repaint
   try
       MainChartRepaint;
   except
     on E: Exception do
       begin
         logmsg('in Mainchartreapint - got exception: ' + E.Message );
         mainchartlock := false;
       end;
   end;


   if GlobalConfig.dbgMeasureTime then logmsg('Refresh monitor seq6 time: ' + IntToStr( GetTickCount() - dt1 ) );
   dt1 := GetTickCount();


   //***STATUSBAR****

   StatusBar1.Panels[1].Text := 'AquireDuration(ms) total: ' + IntToStr( MainHWInterface.LastAquireDuration ) +
         '   PTC: '+ IntToStr( MainHWInterface.PTCControl.LastAquireTimeMS ) +
         '   FlowCtrl: ' + IntToStr( MainHWInterface.FlowControl.LastAquireTimeMS ) +
         '   VTP: ' + IntToStr( MainHWInterface.VTPControl.LastAquireTimeMS );


   StatusBar1.Canvas.Font.Color := fAnimsymbolcolor;
   StatusBar1.Panels[2].Text := 'PID: ' +  IntToStr( fThisProcPID ) +  ' Mem(kB): '+ IntToStr(  GetMemUsage )
                                + '   ' + fAnimSymbol ;


  //---------------------------------
  //enable timer
  MonTimer.Enabled := timerlaststate;
  //FormMain.Enabled := true;
  MonitorLock := false;
end;  //RefreshMonitor



procedure TFormMain.UpdateMonitorFlowDev( dev: TFlowDevices; Var flowdata: TFlowData; TCapt, MCapt, BCapt: TLabel);
Var
  us: string;
  flobj: TFlowControllerObject;
  flfcs: TFlowControlFCS_TCPIP;
begin
  TCapt.Caption := TCapt.Caption + ' (' +  FlowGasTypeToStr( flowData[dev].gastype ) + ')';            //TCaption

  if CFlowDevNotResponding in flowdata[dev].flagSet then
    MCapt.Caption := 'not responding'
  else if CFlowDevDisabled in flowdata[dev].flagSet then
    MCapt.Caption := '<disabled>'
  else
    us := 'sccm';
    flobj := MainHWInterface.FlowControl.ControlObj;
    if flobj is TFlowControlFCS_TCPIP then
      begin
       flfcs := TFlowControlFCS_TCPIP(flobj);
       us := flfcs.fdevarray[dev].units;
      end;
    MCapt.Caption := FloatToStrF( flowData[ dev].massflow , ffFixed, 4,1) + ' ' + us;
  BCapt.Caption := 'sp=' + FloatToStrF( flowData[ dev].setpoint, ffFixed, 4,1 ) + '  p=' + FloatToStrF( flowData[ dev].pressure, ffFixed, 4,2) + ' bar';
end;

//-----------------------------------------------------


procedure TFormMain.ChartFill(chart: TChart; Var grconf: TGraphConf; data: TMonitorMemDataStorage);
begin

end;

procedure TFormMain.UpdateMainCHartConf;

  procedure PredefinedVoltPowCur;
	    Var
	     n: byte;
	  begin
	  n := 3;       //4 for now I will disable Uref
	  if mainchartselection.nseries <> n then
	    begin
	      logmsg('CHART TFormMain.UpdateMainCHartConf setting number of series: ' + IntToStr( n ) );
	      mainchartselection.nseries := n;
	      setlength( mainchartselection.serconf, n);
	      //
	      mainchartdata.nseries := n;
	      setlength(  mainchartdata.serdata, n);
	    end;
	  //selection from comboboxes
	  with mainchartselection.serconf[0] do
	    begin
	      stype := CSeriesVoltage;
	      sunit := 'Voltage(V)';
	      saxis := CSeriesAxLeft;
	    end;
	  with mainchartselection.serconf[1] do
	    begin
	      stype := CSeriesCurrent;
	      sunit := 'Current(A.cm-2)';
	      saxis := CSeriesAxRight;
	    end;
	  with mainchartselection.serconf[2] do
	    begin
	      stype := CSeriesPower;
	      sunit := 'Power(W.cm-2)';
	      saxis := CSeriesAxLeft;
	    end;
	{  with mainchartselection.serconf[3] do
	    begin
	      stype := CSeriesRefVoltage;
	      sunit := 'Ref(V)';
	      saxis := CSeriesAxLeft;
	    end;}

  end;

  procedure PredefinedFlow;
	    Var
	     n: byte;
  begin
	  n := 4;       //4 for now I will disable Uref
	  if mainchartselection.nseries <> n then
	    begin
	      logmsg('CHART TFormMain.UpdateMainCHartConf setting number of series: ' + IntToStr( n ) );
	      mainchartselection.nseries := n;
	      setlength( mainchartselection.serconf, n);
	      //
	      mainchartdata.nseries := n;
	      setlength(  mainchartdata.serdata, n);
	    end;
	  //selection from comboboxes
	  with mainchartselection.serconf[0] do
	    begin
	      stype := CSeriesFlowA;
	      sunit := 'flowAnode(sccm)';
	      saxis := CSeriesAxLeft;
	    end;
	  with mainchartselection.serconf[1] do
	    begin
	      stype := CSeriesFlowC;
	      sunit := 'flowCathode(sccm)';
	      saxis := CSeriesAxLeft;
	    end;
	  with mainchartselection.serconf[2] do
	    begin
	      stype := CSeriesFLowN;
	      sunit := 'flowN2(sccm)';
	      saxis := CSeriesAxLeft;
	    end;
	  //
	  with mainchartselection.serconf[3] do
	    begin
	      stype := CSeriesCurrent;
	      sunit := 'Current(A.cm-2)';
	      saxis := CSeriesAxRight;
	    end;
  end;

  procedure PredefinedTemp;
    Var
     n: byte;
  begin
		  n := 4;       //4 for now I will disable Uref
		  if mainchartselection.nseries <> n then
		    begin
		      logmsg('CHART TFormMain.UpdateMainCHartConf setting number of series: ' + IntToStr( n ) );
		      mainchartselection.nseries := n;
		      setlength( mainchartselection.serconf, n);
		      //
		      mainchartdata.nseries := n;
		      setlength(  mainchartdata.serdata, n);
		    end;
		  //selection from comboboxes
		  with mainchartselection.serconf[0] do
		    begin
		      stype := CSeriesTempCellTop;
		      sunit := 'TcellTop(C)';
		      saxis := CSeriesAxLeft;
		    end;
		  with mainchartselection.serconf[1] do
		    begin
		      stype := CSeriesTempCellBot;
		      sunit := 'TcellBot(C)';
		      saxis := CSeriesAxLeft;
		    end;
		  with mainchartselection.serconf[2] do
		    begin
		      stype := CSeriesTempbH;
		      sunit := 'TbubH2(C)';
		      saxis := CSeriesAxLeft;
		    end;
		  //
		  with mainchartselection.serconf[3] do
		    begin
		      stype := CSeriesTempbO;
		      sunit := 'TbubO2(C)';
		      saxis := CSeriesAxRight;
		    end;
  end;

  procedure PredefinedPress;
    Var
     n: byte;
  begin
	  n := 4;       //4 for now I will disable Uref
	  if mainchartselection.nseries <> n then
	    begin
	      logmsg('CHART TFormMain.UpdateMainCHartConf setting number of series: ' + IntToStr( n ) );
	      mainchartselection.nseries := n;
	      setlength( mainchartselection.serconf, n);
	      //
	      mainchartdata.nseries := n;
	      setlength(  mainchartdata.serdata, n);
	    end;
	  //selection from comboboxes
	  with mainchartselection.serconf[0] do
	    begin
	      stype := CSeriespA;
	      sunit := 'pAnode(bar)';
	      saxis := CSeriesAxLeft;
	    end;
	  with mainchartselection.serconf[1] do
	    begin
	      stype := CSeriespC;
	      sunit := 'pCathode(bar)';
	      saxis := CSeriesAxLeft;
	    end;
	  with mainchartselection.serconf[2] do
	    begin
	      stype := CSeriespBPsp;
	      sunit := 'pBPsetp(bar)';
	      saxis := CSeriesAxLeft;
	    end;
	  //
	  with mainchartselection.serconf[3] do
	    begin
	      stype := CSeriespPiston;
	      sunit := 'pPiston(bar)';
	      saxis := CSeriesAxRight;
	    end;

  end;

  procedure PredefinedFuseStatus;
    Var
     n: byte;
  begin
		  n := 4;       //4 for now I will disable Uref
		  if mainchartselection.nseries <> n then
		    begin
		      logmsg('CHART TFormMain.UpdateMainCHartConf setting number of series: ' + IntToStr( n ) );
		      mainchartselection.nseries := n;
		      setlength( mainchartselection.serconf, n);
		      //
		      mainchartdata.nseries := n;
		      setlength(  mainchartdata.serdata, n);
		    end;
		  //selection from comboboxes
		  with mainchartselection.serconf[0] do
		    begin
		      stype := CSeriesOutputOn;
		      sunit := 'OutputRelay';
		      saxis := CSeriesAxLeft;
		    end;
		  with mainchartselection.serconf[1] do
		    begin
		      stype := CSeriesFuseSWOn;
		      sunit := 'Soft Fuse';
		      saxis := CSeriesAxLeft;
		    end;
		  with mainchartselection.serconf[2] do
		    begin
		      stype := CSeriesFuseHardOn;
		      sunit := 'Hard Fuse';
		      saxis := CSeriesAxLeft;
		    end;
		  //
		  with mainchartselection.serconf[3] do
		    begin
		      stype := CSeriesCurrent;
		      sunit := 'Current(A.cm-2)';
		      saxis := CSeriesAxRight;
		    end;
  end;



Var
  tdt : TDateTime;
  tickinc : TDateTimeStep;
  cbtime: integer;
  n: byte;
begin
  if mainchartlock then //chart settings should not be updated at the moment
    begin
      logmsg('CHART TFormMain.UpdateMainCHartConf: chart is locked - exiting');
      exit;
    end;
  mainchartlock := true;
  maingrconf.whatdata := CBPlotSelData.ItemIndex;
  //for now there is fixed selection of series - voltage, current, power and vref

  case maingrconf.whatdata of
    0: PredefinedVoltPowCur;
    1: PredefinedTemp;
    2: PredefinedFlow;
    3: PredefinedPress;
    4: PredefinedFuseStatus;
    else PredefinedVoltPowCur;
  end;

  //recalculate graph visible content - mainly update deltat and recalculate min and max on y axes
  cbtime := CBPlotSelTimeScale.ItemIndex;
  //default
  //TDateTimeStep = (dtOneSecond, dtFiveSeconds, dtTenSeconds, dtFifteenSeconds, dtThirtySeconds, dtOneMinute, dtFiveMinutes, dtTenMinutes, dtFifteenMinutes, dtThirtyMinutes, dtOneHour, dtTwoHours, dtSixHours, dtTwelveHours,
  // dtOneDay, dtTwoDays, dtThreeDays, dtOneWeek, dtHalfMonth, dtOneMonth, dtTwoMonths, dtSixMonths, dtOneYear);

  tdt :=  10.0/(60*24); //10min default
  tickinc := dtThirtySeconds;       //30 secs
  case cbtime of
    0: begin
        tdt := 2.0/(60*24);    //2min
        tickinc := dtTenSeconds;       //10sec
       end;
    1: begin
        tdt := 10.0/(60*24);    //10min //TDateTime
        tickinc := dtThirtySeconds;       //30 secs
       end;
    2: begin
         tdt := 1.0/24;                        //1 hod
         tickinc := dtFiveMinutes;       //  5 min
       end;
    3:  begin
          tdt := 1;                            //1 day
          tickinc := dtOneHour;       //1 hod
       end;
    4:  begin
          tdt := 7;                              //1 week
          tickinc := dtTwelveHours;       // 12 hod
       end;
    5:  begin                         //maximum
          tdt := 365;
          tickinc := dtOneDay;
        end;
    6:  begin                         //30min
          tdt :=1.0/48;
          tickinc := dtFiveMinutes;
        end;
    7:  begin                        //2h
          tdt := 1.0/12;
          tickinc := dtFiveMinutes;
        end;
    8:  begin                         //4h
          tdt := 1.0/6;
          tickinc := dtTenMinutes;
        end;
    9:  begin                        //6h
          tdt := 1.0/4;
          tickinc := dtTenMinutes;
        end;
    end; //case
  maingrconf.deltat := tdt;
  maingrconf.xincrement := tickinc;
  maingrconf.maxpoints := MainChart.Width div 3;
  if maingrconf.maxpoints>300 then maingrconf.maxpoints := 300;   //total maximum number of points =maxpoints*3 ... because of limiting time to redraw
  //
  mainchartlock := false;
end;



procedure TFormMain.MainChartRepaint;
Var
  ii, i, k, kto, cnt: longint;
  s,s2, ptcmodestr, relaystr, curstr: string;
  monrec : TMonitorRec;
  pmonrec: PMonitorRec;
  willaquire: boolean;
  cbwhat, cbtime : integer;
  tfrom, tto, grtfrom, grtto, tfromdata, ttodata, t0, tlast, tdelta, tmindata, tmaxdata: TDateTime;
  nfrom, nto, nfromdata, ntodata, nrecs, nn, dn, limn, nred, navg, newstartn: longint;
  tdt, tx, delta, mark: TDateTime; //delta time in hours
  xfact, xval, yval, yval1, yval2: double;
  xvalstr: string;
  dt, nx: double;
  y1, y2, y3, y4, ylmin, ylmax, yrmin, yrmax, xmin, f: double;
  dataymin, dataymax: double;
  autoscale, maximized, userpos: boolean;
  tbmax, tbmin, tbfracdelta, tbdelta, tbfrom, tbpos, tbrelpos, tbsel, tblpos, tbrpos: integer;
  ChartDataddd: TMonitorMemDataStorage;
  minr, maxr, avgr: TMonitorRec;
  arraypos: longint;
  kl1, kl2, kl3, kr1: integer;
  grxmax, grxmin, xdelta, xtickinc, deltax,
  axeymax, axeymin, dy, ytickinc: double;
  dtformat: string;

//There are only two main states:
//  1) Maximized - x interval is predefined by mainchartconf
//  2) User Size - x interval is defined from actual visible area in chart
//
//  state 1) has two sub states:
//    1a) latest data lock - end of visible area is at NOW position and shifts with time
//    1b) maximized user pos - center of x interval is at user position, but length is defined by mainchartconf
//  trackbar only gives information, where the visible are is reltive to available data
//for user move, there buttons left, right and zoom+, zoom-, show latest (default - reset), maximize

begin
  if not maingrconf.enabled then exit;  //debug - do not update chart
  if MonitorMemHistory=nil then exit;
  if not mainchartlock then mainchartlock := true   //prevent reentry (note - we need to uses application.processmessages someplaces...)
  else begin logmsg('MainChartLock was true!!!! and should not be'); exit; end;
  //
  nrecs := MonitorMemHistory.CountTotal;
  if nrecs <=0 then begin mainchartlock := false; exit; end;   //do not forget Turn off lock!!! nothing to display
  // determine time interval to display according to conf and trackbar
  // if the position is in between determine the first record acording to nrecords and the last record acording to time interval!!!
  //
  //
  mark := Now();
  // get and update plot config
  //autoscale := GlobalConfig.vAppChartYautoscale;
  //ranges for displayed records
  //
  maximized :=  maingrconf.maximized;
  userpos :=  maingrconf.userpos;
  xdelta := maingrconf.deltat;
  //determine visible X RANGE
  if maximized then
    begin
      if not userpos then
        begin //left pos of x ends on NOW
          grxmax := Now();
          grxmin := grxmax - xdelta;
        end
      else
        begin //show area aroung xcenter
          grxmax :=  maingrconf.userxcenter + xdelta/2;
          grxmin := grxmax - xdelta;
        end;
    end
  else
    begin //userpos - use lastly defined userxmax, userxmin
      grxmax := maingrconf.userxmax;
      grxmin := maingrconf.userxmin;
    end;
  if grxmin>=grxmax then       //assert
    begin
     grxmax := Now();
     grxmin := grxmax - 1/3600;
     logwarning('CHART mainchart: grxmin>=grxmax and should not be');
    end;
  //update maingrconf with new x range data
  maingrconf.userxmin := grxmin;
  maingrconf.userxmax := grxmax;
  maingrconf.userxcenter := (grxmin + grxmax)/2;
  //
  //NOW I know, which X range will be displayed - update tracbar position and
  //grxmin to grxmax
  pmonrec := MonitorMemHistory.GetRec( 0 );
  if pmonrec<>nil then tmindata := pmonrec^.PTCrec.timestamp;
  pmonrec := MonitorMemHistory.GetRec( nrecs - 1  );
  if pmonrec<>nil then tmaxdata := pmonrec^.PTCrec.timestamp;
  tdelta := tmaxdata - tmindata;
  tbmin := TBMainChartPos.Min;
  tbmax := TBMainChartPos.Max;
  tbdelta := tbmax - tbmin;
  try
    if IsNan( tdelta) or (tdelta=0) then
      begin
       tblpos := tbmin;
       tbrpos := tbmax;
      end
    else
      begin
        tblpos := tbmin + Round( (grxmin - tmindata)/ tdelta * tbdelta );
        tbrpos := tbmin + Round( (grxmax - tmindata)/ tdelta * tbdelta );
      end;
  except
    tblpos := tbmin;
    tbrpos := tbmax;
    logmsg('DBG in MainChartReapint: got exception calc tbpos');
  end;
  TBMainChartPos.SelStart := tblpos;
  TBMainChartPos.SelEnd := tbrpos;
  //
  //the time interval on x is defined - now find corresponding records to display
  //grxmin to grxmax
  //logmsg('DBG in MainChartReapint: got here 0');

  nfrom := MonitorMemHistory.FindRecByTime ( grxmin );
  nto := MonitorMemHistory.FindRecByTime ( grxmax );
  if nfrom<0 then nfrom := 0;
  if nto<nfrom then nto := nrecs;
  FormDebug.Label2.Caption := 'Plot grxmin: ' + FloatToStr(grxmin) + ' grxmax: ' + FloatToStr(grxmax) +  ' nfrom: ' + IntToStr(nfrom) +  ' nto: ' + IntToStr(nto);

  //
  MakeSureIsInRange( nto, nfrom, nrecs-1);
  MakeSureIsInRange( nfrom, 0, nto);
  //logmsg('DBG: mainchartrepaint: before pmonrec');

  tfrom := NaN;
  tto := NaN;
  pmonrec := MonitorMemHistory.GetRec( nfrom );
  if pmonrec<>nil then tfrom := pmonrec^.PTCrec.timestamp;
  pmonrec := MonitorMemHistory.GetRec( nto );
  if pmonrec<>nil then tto := pmonrec^.PTCrec.timestamp;
  //
  dn := nto - nfrom + 1;
  if (nto<0) or (nfrom<0) then dn := 0;
  //update maingrconf with new values
//  maingrconf.deltan := dn;
  FormDebug.LaMainChartMsg.Caption := 'Plot nfrom: ' + IntToStr(nfrom) + ' nto: ' + IntToStr(nto) +  ' dn: ' + IntToStr(dn) +  ' tfrom: ' + FloatToStr(tfrom) + ' tto: ' + FloatToStr(tto);


  //assert nto>nfrom
  //debug msg
  //
  //...going to copy data from history into plot series
  //reduction of number of records so there are not so many points in chart
  //idea: have to have at least 2x more data than target points  this ration is 'nred'
  //      - variant a) from nred datapoints generate two numbers - min and max value and plot these two values
  //      ... this way the eventual peaks will be diplayed in "zoomed-out" graph
  //      - variant b) calclate just average from nred points of data

  //do not to create dynamic store - will use static array MainChartTmpData!!!!!!
  //max number of points is CMAinChartMaxTmpRecs
  //ChartData := TMonitorMemDataStorage.Create;
  //if ChartData=nil then
  //  begin
  //    logmsg('MainChartRepaint: unable to create temporary data storage');
  //    mainchartlock := false;
  //    exit;
  //  end;
  limn := maingrconf.maxpoints;
  //how many points will be reduced to one set of 4
  nred := 1;
  if dn < limn * 4 then nred := 1  //no reduction make sense
  else
    nred := dn div limn;
  Assert((nred=1) or (nred>=4) );
  //assert nred is 1 or >=4
  //
  //now walk through and calculate min max, average for every nred records -
  //this is done in special function ExtractData
  try
    ExtractData(  mainchartselection, mainchartdata, MonitorMemHistory, nfrom, nto, nred);
  except
    on E: Exception do logmsg('EX in mainchartrepaint Extractdata EXCEPTION: ' + E.message);
  end;
  //now in mainchartdata there should be all data to display (all valid only)
  //
  FormDebug.LaMainChartMsg2.Caption := 'nred: ' + IntToStr(nred) +  ' arraypos ' + IntToStr(arraypos);        //' chartadat.n ' + IntToStr(ChartData.NPoints)
  //
  //start filling data

  //logmsg('DBG in MainChartReapint: got here 1');

  MainChart.AutoRepaint := false;

  Series1.Clear; //volt - left axis
  Series2.Clear; //curr   right axis
  Series3.Clear; //pow    left axis
  Series4.Clear; //uref   left axis
  //TODO:
  //now I will plot just first three left series to the left axis and first right series to the right axis
  kl1 :=-1;
  kl2 :=-1;
  kl3 :=-1;
  kr1 :=-1;
  k := 0;
  while k<mainchartdata.nseries do
    begin
    if mainchartselection.serconf[k].saxis = CSeriesAxLeft  then begin kl1 := k; Inc(k); break; end;
    Inc(k);
    end;
  while k<mainchartdata.nseries do
    begin
    if mainchartselection.serconf[k].saxis = CSeriesAxLeft  then begin  kl2 := k; Inc(k); break; end;
    Inc(k);
    end;
  while k<mainchartdata.nseries do
    begin
    if mainchartselection.serconf[k].saxis = CSeriesAxLeft  then begin kl3 := k; Inc(k); break; end;
    Inc(k);
    end;
  k := 0;
  while k<mainchartdata.nseries do
    begin
    if mainchartselection.serconf[k].saxis = CSeriesAxRight  then begin kr1 := k; Inc(k); break; end;
    Inc(k);
    end;
  //check k...
  //axis caption
  //MainChart.LeftAxis.Title.Caption := 'Voltage [V], Power [W.cm-2], Uref [V]';
  //MainChart.RightAxis.Title.Caption := 'Current [A.cm-2]';
  s := '';
  if kl1>=0 then s:= s + mainchartselection.serconf[kl1].sunit;
  if kl2>=0 then s:= s + ', ' + mainchartselection.serconf[kl2].sunit;
  if kl3>=0 then s:= s + ', ' + mainchartselection.serconf[kl3].sunit;
  MainChart.LeftAxis.Title.Caption := s;
  s := '';
  if kr1>=0 then s:= s + mainchartselection.serconf[kr1].sunit;
  MainChart.RightAxis.Title.Caption := s;
  //
  ylmin := NAN;
  ylmax := NAN;
  yrmin := NAN;
  yrmax := NAN;
  xmin := NAN;
  //logmsg('hartData.NPoints ' + IntToStr(ChartData.NPoints) );
  //add data to series
  //1st left
  if kl1>=0 then
  begin
    k := kl1;
    for ii := 0 to mainchartdata.serdata[k].ndata -1 do
      begin
        xval := mainchartdata.serdata[k].x[ii];
        yval := mainchartdata.serdata[k].y[ii];
        if (not isnan(yval)) and (not isnan(xval)) then  Series1.AddXY(xval, yval, '', clTeeColor);
        ylmin := mymin(ylmin, yval);
        ylmax := mymax(ylmax, yval);
        xmin :=  mymin(xmin, xval);
      end;
  end;
  //2nd left
  if kl2>=0 then
  begin
    k := kl2;
    for ii := 0 to mainchartdata.serdata[k].ndata -1 do
      begin
        xval := mainchartdata.serdata[k].x[ii];
        yval := mainchartdata.serdata[k].y[ii];
        if (not isnan(yval)) and (not isnan(xval)) then  Series3.AddXY(xval, yval, '', clTeeColor);
        ylmin := mymin(ylmin, yval);
        ylmax := mymax(ylmax, yval);
        xmin :=  mymin(xmin, xval);
      end;
  end;
  //3rd left
  if kl3>=0 then
  begin
    k := kl3;
    for ii := 0 to mainchartdata.serdata[k].ndata -1 do
      begin
        xval := mainchartdata.serdata[k].x[ii];
        yval := mainchartdata.serdata[k].y[ii];
        if (not isnan(yval)) and (not isnan(xval)) then  Series4.AddXY(xval, yval, '', clTeeColor);
        ylmin := mymin(ylmin, yval);
        ylmax := mymax(ylmax, yval);
        xmin :=  mymin(xmin, xval);
      end;
  end
  else Series4.AddXY(0, 0, '', clTeeColor);
  //1st RIGHT
  if kr1>=0 then
  begin
    k := kr1;
    for ii := 0 to mainchartdata.serdata[k].ndata -1 do
      begin
        xval := mainchartdata.serdata[k].x[ii];
        yval := mainchartdata.serdata[k].y[ii];
        if (not isnan(yval)) and (not isnan(xval)) then  Series2.AddXY(xval, yval, '', clTeeColor);
        yrmin := mymin(yrmin, yval);
        yrmax := mymax(yrmax, yval);
        xmin :=  mymin(xmin, xval);
      end;
  end;
  //
  FormDebug.LaMainChartMsg3.Caption := 'kl1: ' + IntToStr(kl1) +  ' kl2: ' + IntToStr(kl2) + ' kl3: ' + IntToStr(kl3) +
                                        ' kr1: ' + IntToStr(kr1);
  FormDebug.MeChart.Lines.Clear;
  for i:=0 to  mainchartdata.nseries -1 do
    begin
      FormDebug.MeChart.Lines.Add('k: ' + IntToStr(i) + ' ndata: ' + IntToStr( mainchartdata.serdata[i].ndata ) );
    end;
  if FormDebug.chkChartDump.checked then
    begin
    FormDebug.MeChart2.Lines.Clear;
    FormDebug.MeChart2.Lines.Add('dump series 0');
    for ii:=0 to mainchartdata.serdata[0].ndata -1 do
      begin
        FormDebug.MeChart2.Lines.Add('  x: ' + FloatToStr( mainchartdata.serdata[0].x[ii] )+ ' y: ' + FloatToStr( mainchartdata.serdata[0].y[ii] ) );
      end;
    FormDebug.MeChart2.Lines.Add('-------------------------');
    FormDebug.MeChart2.Lines.Add('dump series 1');
    for ii:=0 to mainchartdata.serdata[1].ndata -1 do
      begin
        FormDebug.MeChart2.Lines.Add('  x: ' + FloatToStr( mainchartdata.serdata[1].x[ii] )+ ' y: ' + FloatToStr( mainchartdata.serdata[1].y[ii] ) );
      end;
    FormDebug.MeChart2.Lines.Add('-------------------------');
    FormDebug.MeChart2.Lines.Add('dump series 3');
    for ii:=0 to mainchartdata.serdata[3].ndata -1 do
      begin
        FormDebug.MeChart2.Lines.Add('  x: ' + FloatToStr( mainchartdata.serdata[3].x[ii] )+ ' y: ' + FloatToStr( mainchartdata.serdata[3].y[ii] ) );
      end;
    end;

  //finsihed laoding data into series
  //optimize min/max values of series - add 10% in y y to each direction
  //adding 10% here compared to 5% so the scale is little different from the left axis so it will not overlapp so oftern
  //set ymin 0 if more than 0
  //0)  X AXIS
    //if tfrom>tto it raises exception!!!
  //logmsg('MM in MainChartReapint: got here 2');
  //logmsg('  tfrom tto ' + FloatToStr(tfrom) + ' ' + FloatToStr(tto) );
  //logmsg('  grtfrom grtto ' + FloatToStr(grtfrom) + ' ' + FloatToStr(grtto) );
  //

   //set axis x limits
  //Xincrement
  //if zoomed (userpos) then recalculate apropriate xincrement

  //if preselect x scale is bigger than data, zoom to display data (so there is no blank on the left - which is not useful)
  //howeever, will keep tickinc for the maximized area
    if maximized then
    begin
      if not IsNAN(tfrom) then
        if (tfrom>grxmin) then grxmin := tfrom;
    end;
  //check ticks
  deltax := Abs( grxmax- grxmin);
  xtickinc := DateTimeStep [ maingrconf.xincrement ];
  f := round( 4 * xtickinc / deltax);
  if xtickinc > (deltax / 4) then xtickinc := xtickinc / f;
  //else xtickinc := deltax / 10;


  //store values
  maingrconf.userXmax := grxmax;
  maingrconf.userXmin := grxmin;


  //
  MainChart.BottomAxis.Automatic := false;
  MainChart.BottomAxis.DateTimeFormat := '';
  //IN ORDER to NOT GET min Max exception!!!
  if ( MainChart.BottomAxis.Minimum >= grxmax ) then   MainChart.BottomAxis.Minimum := grxmax - 1;
  MainChart.BottomAxis.Maximum := grxmax;  //first MUST set MAX, or will get exception
  MainChart.BottomAxis.Minimum := grxmin;
  MainChart.BottomAxis.Increment := xtickinc;
  //datetimeformat  //datetimeToString     Date-Time Format Strings
  dtformat := MainChart.BottomAxis.DateTimeFormat;
  if xtickinc < 1.0 / 24 / 60 then   //less than one min -> show secs it does not automatically!!!
    begin
      dtformat := 'h:nn:ss';
      MainChart.BottomAxis.DateTimeFormat := dtformat;
    end;


  //
  //visible range for Y axes -> depends if maximized or not, if yes then use min max from data otherwise, used user values
  //1) left Y axis
  dy := ylmax - ylmin;
  if not isNAN(dy) then
    begin
     dataymax := ylmax + dy * 0.1;
     dataymin := ylmin - dy * 0.1;
     //check sane range
      if not isnan(axeymin) then
        if dataymin>-0.05 then dataymin :=-0.05;
      if not isnan(axeymax) then
        if dataymax<0.1 then dataymax := 0.1;
    end
  else
    begin
         dataymax := 1.2;
         dataymin :=-0.05;
    end;
  if maximized then //uses min, max from data
    begin
      axeymax := dataymax;
      axeymin := dataymin;
      ytickinc := 0.1;  //default     //TODO
    end
  else //userpos
    begin
      axeymax := maingrconf.userlymax;
      axeymin := maingrconf.userlymin;
      dy := (axeymax - axeymin);
      ytickinc := dy / 10;
    end;
  //store new values as user for next time
  maingrconf.userlymin := axeymin;
  maingrconf.userlymax := axeymax;
  //set axis min max
  MainChart.LeftAxis.Automatic := false;
  //in order to NOT GET min Max exception!!!
  if (MainChart.LeftAxis.Minimum >= axeymax ) then   MainChart.LeftAxis.Minimum := axeymax - 1;
  MainChart.LeftAxis.Maximum := axeymax;   //first MUST set MAX, or will get exception
  MainChart.LeftAxis.Minimum := axeymin;
  MainChart.LeftAxis.Increment := ytickinc;
  //
  //
  //2) and the same for right  Y axis
  dy := yrmax - yrmin;
  if not isNAN(dy) then
    begin
     dataymax := yrmax + dy * 0.1;
     dataymin := yrmin - dy * 0.1;
     //check sane range
      if not isnan(axeymin) then
        if dataymin>-0.05 then dataymin :=-0.05;
      if not isnan(axeymax) then
        if dataymax<0.1 then dataymax := 0.1;
    end
  else
    begin
         dataymax := 1.2;
         dataymin :=-0.05;
    end;
  if maximized then //uses min, max from data
    begin
      axeymax := dataymax;
      axeymin := dataymin;
      ytickinc := 0.1;  //default     //TODO
    end
  else //userpos
    begin
      axeymax := maingrconf.userRymax;
      axeymin := maingrconf.userRymin;
      dy := (axeymax - axeymin);
      ytickinc := dy / 10;
    end;
  //store new values as user for next time
  maingrconf.userRymin := axeymin;
  maingrconf.userRymax := axeymax;
  //set axis min max
  MainChart.RightAxis.Automatic := false;
  //in order to NOT GET min Max exception!!!
  if (MainChart.RightAxis.Minimum >= axeymax ) then   MainChart.RightAxis.Minimum := axeymax - 1;
  MainChart.RightAxis.Maximum := axeymax;      //first MUST set MAX, or will get exception
  MainChart.RightAxis.Minimum := axeymin;
  MainChart.RightAxis.Increment := ytickinc;

  //release chartdata
  //ChartData.RemoveAllData;
  //freeandnil(ChartData);
  //freeandnil
  //logmsg('MM in MainChartReapint: got here 3');
  MainChart.AutoRepaint := true;
  MainChart.Repaint;
  //logmsg('MM in MainChartReapint: got here 4');
  FormDebug.LaChartTime.Caption := 'Last Repaint took (ms): ' + IntToStr( MilliSecondsBetween( Now(), mark ) );
  mainchartlock := false;
end;   //ManiChartRepaint




//-----------------------------------------------------


procedure TFormMain.MonTimerTimer(Sender: TObject);
//refresh monitor timer
begin
  if MonTimer=nil then exit;
  if not (MonTimer.Enabled) then exit;  //happens e.g. when going to close app or for some reason there comes second timer events from system sooner before execute finished
  MonTimer.Enabled := false;
  //RefreshMonitor;
  try
    RefreshMonitor;
  except
    on E: Exception do begin logmsg('TFormMain.MonTimerTimer: exception: '+ E.Message );  end;
  end;
  MonTimer.Enabled := true;
end;


procedure TFormMain.updateTodayinc;
Var
 f: TextFile;
 fs: TFormatSettings;
{$IFNDEF TODAYINC}
const
   _builddatetime: TDateTime = 0;
   _buildcnt: longint = 1000;
{$ENDIF}
begin
  GetLocaleFormatSettings(0, fs); //need to write number in english format
  fs.DecimalSeparator := '.';
  AssignFile(f, 'today.inc');
  {$I-}
  ReWrite(f);
  if (IoResult <> 0) then exit;
  Writeln(f, '// include file "today.inc"');
  Writeln(f, '{$DEFINE TODAYINC}');
  Writeln(f, 'const');

  Writeln(f, '  _builddatetime: TDateTime = ' + FloatToStr( Now, fs ) + ';' );            //TDateTime  //Year        TDAteTimeToStr
  Writeln(f, '  _buildcnt: longint = ' + IntToStr(_buildcnt + 1)+ ';' );
  closefile(f);
  if (IoResult <> 0) then logmsg('updateTodainc: failed!!!');
  {$I+}
  // include file "today.inc"
end;

//-----------------------------------------------------



procedure TFormMain.BuProjNewClick(Sender: TObject);
begin
  RestoreFormWindow( NewProjectForm );
end;


procedure TFormMain.LabelRHMouseEnter(Sender: TObject);
begin
  //LabelRH.Font.Style := LabelRH.Font.Style + [fsBold];
  //LabelRHLab.Font.Style := LabelRHLab.Font.Style + [fsBold];
end;

procedure TFormMain.LabelRHMouseLeave(Sender: TObject);
begin
  //LabelRH.Font.Style := LabelRH.Font.Style - [fsBold];
  //LabelRHLab.Font.Style := LabelRHLab.Font.Style - [fsBold];
end;

procedure TFormMain.LabelRHLabMouseEnter(Sender: TObject);
begin
  //LabelRH.Font.Style := LabelRH.Font.Style + [fsBold];
  //LabelRHLab.Font.Style := LabelRHLab.Font.Style + [fsBold];
end;

procedure TFormMain.LabelRHLabMouseLeave(Sender: TObject);
begin
  //LabelRH.Font.Style := LabelRH.Font.Style - [fsBold];
  //LabelRHLab.Font.Style := LabelRHLab.Font.Style - [fsBold];
end;

procedure TFormMain.LabelRHClick(Sender: TObject);
//var  HumidificationForm : THumidificationForm;
begin
  {$ifdef AddHumiForm}
  HumidificationForm := THumidificationForm.Create(Application);
  HumidificationForm.Parent := HumidificationForm;
  //Application.CreateForm(THumidificationForm, HumidificationForm);
  {$Else}
  ShowMessage('Humidification form wasnt included. See "VAcharakteristiaOptions.inc". For selecting of humidifocation senzor see "config-humidificationsenzors.txt"');
  {$endif}
end;

procedure TFormMain.LabelRHLabClick(Sender: TObject);
begin
  {$ifdef AddHumiForm}
  HumidificationForm := THumidificationForm.Create(Application);
  //Application.CreateForm(THumidificationForm, HumidificationForm);
  {$Else}
    ShowMessage('Humidification form wasnt included. See "VAcharakteristiaOptions.inc". For selecting of humidifocation senzor see "config-humidificationsenzors.txt"');
  {$endif}
end;


procedure TFormMain.BuPTCConnectClick(Sender: TObject);
begin
  MainHWInterface.PTCInit;
  //FormPTCHardware.ButKolInitClick(nil);
end;

procedure TFormMain.BuTaskOpenModSimpleClick(Sender: TObject);
begin
  RestoreFormWindow( FormSimpleModule );
end;

procedure TFormMain.BuTaskOpenModVACharClick(Sender: TObject);
begin
  RestoreFormWindow( FormVAchar );
end;

procedure TFormMain.BuTaskOpenModBatchClick(Sender: TObject);
begin
   RestoreFormWindow( FormBatch );
end;

procedure TFormMain.BuHWFormOpenClick(Sender: TObject);
begin
  RestoreFormWindow( FormPTCHardware );
end;

procedure TFormMain.BuPTCDisconClick(Sender: TObject);
begin
  if FormPTCHardware.PTC <> nil then FormPTCHardware.PTC.Finalize;
end;

procedure TFormMain.BuShowLogClick(Sender: TObject);
begin
  LoggerForm.PCLog.ActivePageIndex := 0;
  RestoreFormWindow( LoggerForm );
end;

procedure TFormMain.BuProjEditClick(Sender: TObject);
begin
  //ProjectControl.RefreshContent;
  RestoreFormWindow( ProjectControl );
end;

procedure TFormMain.PanProjPathClick(Sender: TObject);
begin
  RestoreFormWindow( ProjectControl );
end;

procedure TFormMain.BuProjCloseClick(Sender: TObject);
var
  buttonSelected : Integer;
begin
  buttonSelected := MessageDlg('Are you SURE to close actual project?',mtConfirmation, mbOKCancel, 0);
  // Show the button type selected
  if buttonSelected = mrOK     then
  begin
    ProjectControl.CloseProject;
  end;
end;

procedure TFormMain.PanMonitorResize(Sender: TObject);
Var
  w, w2, wrest, wf: integer;
  spc, left: integer;
begin
  PanMonPTC.Color := clBlack;
  //
  w := PanMonitor.Width;
  spc := 5;
  w2 := (w - 2* spc ) div 2;
  wrest := w - 2* spc - w2;
  //
  left := w2 + 1* spc;
  //LaMonPow.Width := w2;
  //LamonVref.Width := w2;
  //LaPTCInfo1.Width := wrest;
  //LaPTCInfo2.Width := wrest;
  //LaPTCInfo3.Width := wrest;
 // LaPTCInfo1.Left := left;
 // LaPTCInfo2.Left := left;
  //LaPTCInfo3.Left := left;

  //LamonVref.Left := left;
  //
  LaWarningMsgInfo.Width := w2;
  LaErrorMsgInfo.Width := wrest;
  LaErrorMsgInfo.Left := left;
  //
  //FLOW
  w := PanMonFlow.Width;
  wf := (w - 3*spc) div 4;
  wrest := w - 3* spc - 3 * wf;
  LaFlow1T.Width := wf;
  LaFlow2T.Width := wf;
  LaFlow3T.Width := wf;
  LaFlow4T.Width := wrest;
  LaFlow1M.Width := wf;
  LaFlow2M.Width := wf;
  LaFlow3M.Width := wf;
  LaFlow4M.Width := wrest;
  LaFlow1B.Width := wf;
  LaFlow2B.Width := wf;
  LaFlow3B.Width := wf;
  LaFlow4B.Width := wrest;
  //
  left := wf + 1*spc;
  LaFlow2T.Left := left;
  LaFlow2M.Left := left;
  LaFlow2B.Left := left;
  left := 2*wf + 2*spc;
  LaFlow3T.Left := left;
  LaFlow3M.Left := left;
  LaFlow3B.Left := left;
  left := 3*wf + 3*spc;
  LaFlow4T.Left := left;
  LaFlow4M.Left := left;
  LaFlow4B.Left := left;
end;

procedure TFormMain.BuEditGlobConfClick(Sender: TObject);
begin
  RestoreFormWindow( GlobalConfig );
end;


procedure TFormMain.BuProjResumeClick(Sender: TObject);
Var
 old: string;
 b: boolean;
begin
  //see rules for open dialog initial dir in new windows >=7: find section for IpstrInitialDir
  //https://msdn.microsoft.com/en-us/library/ms646839.aspx
  //
  old := ProjectControl.ProjDir;
  ProjOpenDialog.InitialDir := 'blabla';
  ProjOpenDialog.FileName := '';
  ProjOpenDialog.InitialDir := old;
  if ProjOpenDialog.Execute then
    begin
      //ProjectControl.CloseProject;
      b := ProjectControl.OpenProject( ProjOpenDialog.FileName );
      if not b then
        begin
          ShowMessage('Opening of selected project failed - trying to reload last one');
          ProjectControl.OpenProject( old );
        end;
    end;
end;

procedure TFormMain.BuMonReleaseMemClick(Sender: TObject);
begin
   MonitorMemHistory.MakeSpaceProcents(20);
end;

procedure TFormMain.BuAdvancePlotClick(Sender: TObject);
begin
  RestoreFormWindow( FormAdvancedPlot );
end;

procedure TFormMain.BuTaskOpenModBatch2Click(Sender: TObject);
begin
  RestoreFormWindow( FormModuleBatchRoman );
end;

procedure TFormMain.CBPlotSelTimeScaleChange(Sender: TObject);
begin
  UpdateMainCHartConf;
  maingrconf.maximized := true;
end;

procedure TFormMain.MainChartResize(Sender: TObject);
begin
  UpdateMainCHartConf;
end;

procedure TFormMain.CBplotSelDataChange(Sender: TObject);
begin
  UpdateMainCHartConf;
   //showmessage('ahoj');
end;

procedure TFormMain.CheckBox2Click(Sender: TObject);
begin
end;
                                                                                 //Tform

procedure TFormMain.BuMainChartLeftClick(Sender: TObject);
//will shift curent starting record by half of displayed number of records
Var
 dx : double;
begin
  if mainchartlock then exit;
  mainchartlock := true;
  dx := (maingrconf.userXmax - maingrconf.userXmin) * 0.8;  //shift by 80% of visible x    //last dispalyed range values
  if not isnan(dx) then
    begin
		  with maingrconf do
		    begin
          maximized :=false;
		      userpos := true;
		      userXcenter := userXcenter - dx;
          userXmax := userXmax - dx;
          userXmin := userXmin - dx;
		    end;
    end;
  mainchartlock := false;
end;

procedure TFormMain.BuMainChartRightClick(Sender: TObject);
//will shift curent starting record by half of displayed number of records
Var
  dx : double;
begin
  if mainchartlock then exit;
  mainchartlock := true;
  if maingrconf.userpos then dx := (maingrconf.userXmax - maingrconf.userXmin) * 0.8   //shift by 80% of visible x    //last dispalyed range values
  else
     dx := (maingrconf.deltat) * 0.8;
  if not isnan(dx) then
    begin
		  with maingrconf do
		    begin
          maximized :=false;
		      userpos := true;
		      userXcenter := userXcenter + dx;
          userXmax := userXmax + dx;
          userXmin := userXmin + dx;
		    end;
    end;
  mainchartlock := false;
end;



procedure TFormMain.MainChartZoom(Sender: TObject);
begin
  if mainchartlock then exit;   //should not happen
  mainchartlock := true;
  with maingrconf do
    begin
      //userpos := true;
      maximized := false;
      userLymax := MainChart.LeftAxis.Maximum;
      userLymin := MainChart.LeftAxis.Minimum;
      userRymax := MainChart.RightAxis.Maximum;
      userRymin := MainChart.RightAxis.Minimum;
      userXmax := MainChart.BottomAxis.Maximum;
      userXmin := MainChart.BottomAxis.Minimum;
      userXcenter := (userXmax + userXmin) / 2;
      userXinterval := userXmax - userXmin;
      //xincrement
    end;
  mainchartlock := false;
end;

procedure TFormMain.MainChartUndoZoom(Sender: TObject);
begin
  maingrconf.maximized := true;
  //maingrconf.userpos := false;   //do not change userpos - return to last state
end;

procedure TFormMain.MainChartScroll(Sender: TObject);
begin
  if mainchartlock then exit;   //should not happen
  mainchartlock := true;
  //SET USERPOS but do not change MAXIMIZED
  with maingrconf do
    begin
      userpos := true;
      maximized := false;
      //do not change Y pos
      userXmax := MainChart.BottomAxis.Maximum;
      userXmin := MainChart.BottomAxis.Minimum;
      userLymax := MainChart.LeftAxis.Maximum;
      userLymin := MainChart.LeftAxis.Minimum;
      userRymax := MainChart.RightAxis.Maximum;
      userRymin := MainChart.RightAxis.Minimum;
      userXcenter := (userXmax + userXmin) / 2;
      userXinterval := userXmax - userXmin;
    end;
  mainchartlock := false;
end;

procedure TFormMain.BuMainChartResetClick(Sender: TObject);
begin
  maingrconf.maximized := true;
  maingrconf.userpos := false;
end;


procedure TFormMain.BuFlowControlOpenClick(Sender: TObject);
begin
  RestoreFormWindow( FormFlowHardware );
end;

procedure TFormMain.BuShowDebugClick(Sender: TObject);
begin
   RestoreFormWindow( FormDebug );
end;

procedure TFormMain.LaWarningMsgInfoClick(Sender: TObject);
begin
  LoggerForm.PCLog.ActivePageIndex := 1;
  RestoreFormWindow( LoggerForm );
end;

procedure TFormMain.LaErrorMsgInfoClick(Sender: TObject);
begin
  LoggerForm.PCLog.ActivePageIndex := 2;
  RestoreFormWindow( LoggerForm );
end;



procedure TFormMain.Button3Click(Sender: TObject);
begin
  FormPTCHardware.SetBounds(0,0, 900, 790);
  FormSimpleModule.SetBounds(100, 100, 500, 500);
end;

procedure TFormMain.TimChkSynchronizeTimer(Sender: TObject);
begin
  CheckSynchronize(1);
end;

procedure TFormMain.LaFlow1MClick(Sender: TObject);
begin
    RestoreFormWindow( FormFlowHardware );
end;

procedure TFormMain.BuReportClick(Sender: TObject);
begin
    LoggerForm.PCLog.ActivePageIndex := 3;
  RestoreFormWindow( LoggerForm );
end;

//variant

procedure TFormMain.BuFlowFinalClick(Sender: TObject);
begin
    MainHWInterface.FlowFinalize(true);
end;

procedure TFormMain.BuFlowInitClick(Sender: TObject);
begin
  MainHWInterface.FlowInit;
end;



procedure TFormMain.BuMainCHartPlusClick(Sender: TObject);
var
  cy, dy: double;
begin
  if mainchartlock then exit;   //should not happen
  with maingrconf do
    begin
      userpos := true;
      maximized := false;
      userXcenter := (userXmax + userXmin) / 2;
      userXinterval := userXmax - userXmin;
      //x *2 zoom
      userXmax := userXcenter + userXinterval/4;
      userXmin := userXcenter - userXinterval/4;
      userXinterval := userXinterval/2;
      //y *2 zoom
      cy := (userLymax + userLymin) / 2;
      dy :=  (userLymax - userLymin);
      userLymax := cy + dy/4;
      userLymin := cy - dy/4;
      cy := (userRymax + userRymin) / 2;
      dy :=  (userRymax - userRymin);
      userRymax := cy + dy/4;
      userRymin := cy - dy/4;
    end;
end;

procedure TFormMain.BuMainCHartMinusClick(Sender: TObject);
var
  cy, dy: double;
begin
  if mainchartlock then exit;   //should not happen
  with maingrconf do
    begin
      userpos := true;
      maximized := false;
      userXcenter := (userXmax + userXmin) / 2;
      userXinterval := userXmax - userXmin;
      //x *2 zoom
      userXmax := userXcenter + userXinterval;
      userXmin := userXcenter - userXinterval;
      userXinterval := 2 * userXinterval;
      //y *2 zoom
      cy := (userLymax + userLymin) / 2;
      dy :=  (userLymax - userLymin);
      userLymax := cy + dy;
      userLymin := cy - dy;
      cy := (userRymax + userRymin) / 2;
      dy :=  (userRymax - userRymin);
      userRymax := cy + dy;
      userRymin := cy - dy;
    end;
end;


procedure TFormMain.Button2Click(Sender: TObject);
begin
  RestoreFormWindow( FormValveControl );
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
  ShowMessage( IntToHex( 120, 8) );
end;

procedure TFormMain.BuTaskRequestStopClick(Sender: TObject);
begin
  if MessageDlg('Are you SURE to STOP current running TASK? ',mtConfirmation, mbOKCancel, 0) <> mrOK  then exit;
  //
  GlobalConfig.BroadCastSignal(CsigStopRequest);
end;

procedure TFormMain.BuValvesInitClick(Sender: TObject);
begin
  FormValveControl.BuMainConnectClick(nil);
end;

procedure TFormMain.ComboBox1Change(Sender: TObject);
begin
  if MainHWInterface=nil then exit;
  MainHWInterface.fMSWCtrlStatus := ComboBox1.ItemIndex;
end;

procedure TFormMain.TimerBatchAutoStartTimer(Sender: TObject);
begin
  if not TimerBatchAutoStart.Enabled then exit;
  TimerBatchAutoStart.Enabled := false;
  if chkAutoStartMeasure.Checked then FormModuleBatchRoman.Button1Click(nil);
end;

procedure TFormMain.BuValvesFinClick(Sender: TObject);
begin
  if MainHWInterface.VTPControl.ControlObj <> nil then MainHWInterface.VTPControl.ControlObj.Finalize;
end;

procedure TFormMain.PanPTCV4SafeRangeClick(Sender: TObject);
begin
    RestoreFormWindow( ProjectControl );
end;

procedure TFormMain.PanProjectClick(Sender: TObject);
begin
  RestoreFormWindow( ProjectControl );
end;

procedure TFormMain.PanVoltMinLimClick(Sender: TObject);
begin
  RestoreFormWindow( ProjectControl );
end;

procedure TFormMain.PanVoltMaxLimClick(Sender: TObject);
begin
  RestoreFormWindow( ProjectControl );
end;

procedure TFormMain.Button6Click(Sender: TObject);
begin
  PTCCalibForm.Show;
end;

procedure TFormMain.Button7Click(Sender: TObject);
begin
  //ShowMessage( IntTOStr( GetCurrentProcessID ) );
  FormRegView.Show;
end;

procedure TFormMain.Button8Click(Sender: TObject);
begin
  Form4.Show;
end;

procedure TFormMain.BuTaskOpenCvClick(Sender: TObject);
begin
  RestoreFormWindow( FormCV );
end;

procedure TFormMain.BuTaskOpenEISClick(Sender: TObject);
begin
  RestoreFormWindow( FormEIS );
end;

initialization
  // Enable raw mode (default mode uses stack frames which aren't always generated by the compiler)
  Include(JclStackTrackingOptions, stRawMode);
  // Disable stack tracking in dynamically loaded modules (it makes stack tracking code a bit faster)
  Include(JclStackTrackingOptions, stStaticModuleList);
  // Initialize Exception tracking
  JclStartExceptionTracking;
finalization
  JclStopExceptionTracking;



end.

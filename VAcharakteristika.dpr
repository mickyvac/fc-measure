// JCL_DEBUG_EXPERT_INSERTJDBG ON
// JCL_DEBUG_EXPERT_GENERATEJDBG ON
program VAcharakteristika;

{$R 'myicons.res' 'myicons.rc'}

uses
  FastMM4,
  Forms,
  main in 'main.pas' {FormMain},
  LoggerFormUnit in 'LoggerFormUnit.pas' {LoggerForm},
  debug in 'debug.pas' {Form3},
  datastorage in 'datastorage.pas',
  myutils in 'myutils.pas',
  SetData in 'SetData.pas' {Batch},
  SetData_Help in 'SetData_Help.pas' {BatchHelp},
  FormstatusUnit in 'FormstatusUnit.pas' {FormStatus},
  Module_VAchar in 'Module_VAchar.pas' {FormVAchar},
  module_simple in 'module_simple.pas' {FormSimpleModule},
  module_batch in 'module_batch.pas' {FormBatch},
  FormHWAccessControlUnit in 'FormHWAccessControlUnit.pas' {FormHWAccessControl},
  FormPTCHardwareUnit in 'FormPTCHardwareUnit.pas' {FormPTCHardware},
  FormFlowHardwareUnit in 'FormFlowHardwareUnit.pas' {FormFlowHardware},
  FormProjectControl in 'FormProjectControl.pas' {ProjectControl},
  FormNewProjectUnit in 'FormNewProjectUnit.pas' {NewProjectForm},
  FormGlobalConfig in 'FormGlobalConfig.pas' {GlobalConfig},
  FormAdvancedPlotUnit in 'FormAdvancedPlotUnit.pas' {FormAdvancedPlot},
  FormModuleBatchRomanUnit in 'FormModuleBatchRomanUnit.pas' {FormModuleBatchRoman},
  CPort in 'cport\CPort.pas',
  CPortAbout in 'cport\CPortAbout.pas' {AboutBox},
  CPortCtl in 'cport\CPortCtl.pas',
  CPortEsc in 'cport\CPortEsc.pas',
  CPortSetup in 'cport\CPortSetup.pas',
  FormDebugUnit in 'FormDebugUnit.pas' {FormDebug},
  MyParseUtils in 'MyParseUtils.pas',
  MyChartModule in 'MyChartModule.pas',
  FormValveControlUnit in 'FormValveControlUnit.pas' {FormValveControl},
  MyComPort in 'MyComPort.pas',
  MyThreadUtils in 'MyThreadUtils.pas',
  LoggerThreadSafe in 'LoggerThreadSafe.pas',
  PTCCalibUsingBK8500Form in 'PTCCalibUsingBK8500Form.pas' {PTCCalibForm},
  MyDataUtils in 'MyDataUtils.pas',
  ModuleCVunit in 'ModuleCVunit.pas' {FormCV},
  MyContainers in 'MyContainers.pas',
  MyImportKolData in 'MyImportKolData.pas',
  processinfo_winapi in 'processinfo_winapi.pas',
  MyPSUtils_winapi in 'MyPSUtils_winapi.pas',
  ModuleEISunit in 'ModuleEISunit.pas' {FormEIS},
  StreamIO in 'StreamIO.pas',
  MyStreamReader in 'MyStreamReader.pas',
  MyAquireThreadNEW_TCPIP in 'MyAquireThreadNEW_TCPIP.pas',
  MyStringHelpers in 'MyStringHelpers.pas',
  FlowInterface_FCS_TCPIP in 'FlowInterface_FCS_TCPIP.pas',
  VTPInterface_TCPIP_new in 'VTPInterface_TCPIP_new.pas',
  DataStorageV2 in 'DataStorageV2.pas',
  MyFileUtils in 'MyFileUtils.pas',
  CPortTrmSet in 'cport\CPortTrmSet.pas' {ComTrmSetForm},
  PTCInterface_ZS1806 in 'PTCInterface_ZS1806.pas',
  MyAcquireThreadNEW_RS232 in 'MyAcquireThreadNEW_RS232.pas',
  Debug_RegView in 'Debug_RegView.pas' {FormRegView},
  MyEditInterfaceHelper in 'MyEditInterfaceHelper.pas',
  MyJobThreadSafeManager in 'MyJobThreadSafeManager.pas',
  PTCinterface_Dummy in 'PTCinterface_Dummy.pas',
  PTCInterface_KolPTC_TCPIP_new in 'PTCInterface_KolPTC_TCPIP_new.pas',
  PTCInterface_M97XX in 'PTCInterface_M97XX.pas',
  PLIxx_LowLevel_Interface in 'PLIxx_LowLevel_Interface.pas',
  HWAbstractdevicesV3 in 'HWAbstractdevicesV3.pas',
  HWinterface in 'HWinterface.pas',
  FormPressureTestUnit in 'FormPressureTestUnit.pas' {PressureTest},
  PTCInterface_BK8500 in 'PTCInterface_BK8500.pas',
  unitException in 'unitException.pas' {ExceptionDialog},
  TestPlotFormUnit in 'TestPlotFormUnit.pas' {Form1},
  PTCInterface_PLI in 'PTCInterface_PLI.pas',
  Unit2 in 'Unit2.pas' {Form2},
  MVvariant_DataObjects in 'MVvariant_DataObjects.pas',
  ConfigManager in 'ConfigManager.pas',
  testloadgui in 'testloadgui.pas' {Form4},
  dummydfm in 'dummydfm.pas' {Form5},
  FlowInterface_Alicat_new3 in 'FlowInterface_Alicat_new3.pas';

//MyScheduler in 'MyScheduler.pas';

{$ifdef AddHumiForm}
  Humidification in 'Humidification.pas' {HumidificationForm},
  {$endif}
{$ifdef FastMM4Add}
  //FastMMUsageTracker in 'FastMMUsageTracker.pas' {fFastMMUsageTracker};
  // // /// //FastMMUsageTracker in 'E:\Soft\FastMM4991\FastMM\Demos\Usage Tracker\FastMMUsageTracker.pas' {fFastMMUsageTracker};
{$endif}

{$R *.res}

begin
  Application.Initialize;
  //!!! Form1.Inicializace must be called after all other forms are created first
  Application.Title := 'FC control v2015';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TLoggerForm, LoggerForm);
  Application.CreateForm(TFormRegView, FormRegView);
  Application.CreateForm(TPressureTest, PressureTest);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  //logger is needed from beginning, so it has to be initialized extra early //will initialize Logger object during "formcreate"
  Application.CreateForm(TGlobalConfig, GlobalConfig);
  Application.CreateForm(TProjectControl, ProjectControl);
  Application.CreateForm(TFormHWAccessControl, FormHWAccessControl);
  Application.CreateForm(TFormPTCHardware, FormPTCHardware);
  Application.CreateForm(TFormFlowHardware, FormFlowHardware);
  Application.CreateForm(TFormValveControl, FormValveControl);
  Application.CreateForm(TFormSimpleModule, FormSimpleModule);
  Application.CreateForm(TFormVAchar, FormVAchar);
  Application.CreateForm(TFormBatch, FormBatch);
  Application.CreateForm(TFormModuleBatchRoman, FormModuleBatchRoman);
  Application.CreateForm(TFormStatus, FormStatus);
  Application.CreateForm(TNewProjectForm, NewProjectForm);
  Application.CreateForm(TFormAdvancedPlot, FormAdvancedPlot);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TFormDebug, FormDebug);
  Application.CreateForm(TSetDataForm, SetDataForm);
  Application.CreateForm(TSetData_Help, SetData_Hlp);
  Application.CreateForm(TPTCCalibForm, PTCCalibForm);
  Application.CreateForm(TFormCV, FormCV);
  Application.CreateForm(TFormEIS, FormEIS);
  //main initialization routine (will call other form initialization)
  FormMain.Inicializace;
{$ifdef AddHumiForm}
  //Application.CreateForm(THumidificationForm, HumidificationForm);
  //No it is creating dynamicaly by button
{$endif}
  //RUN
  Application.Run;
end.

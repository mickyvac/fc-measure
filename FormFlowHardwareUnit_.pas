unit FormFlowHardwareUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, ExtCtrls,
  IniFiles, Logger, FormGlobalConfig, ConfigManager, myUtils,
  HWabstractDevicesNew2,  HWinterface,
  FlowINterface_dummy,
  FlowInterface_Alicat_old;



 Const
  CFlowFormconfigfile = 'config-flowform.txt';
  //CFlowFormComPortconfigfile = 'config-comport-alicat.txt';
  CAlicatComPortconfigfile = 'config-comport-alicat.txt';

type

  PFlowControllerObject = ^TFlowControllerObject;

  TFormFlowHardware = class(TForm)
    Label7: TLabel;
    CBSelectFlow: TComboBox;
    GroupBox2: TGroupBox;
    ButtonHide: TButton;
    ChkAutoRefresh: TCheckBox;
    HWFormRefreshIntv: TEdit;
    Label1: TLabel;
    RefreshTimer: TTimer;
    ChkFlowReady: TCheckBox;
    BuFlowCon: TButton;
    BuFlowDiscon: TButton;
    Button2: TButton;
    Label5: TLabel;
    BuFlowSPA: TButton;
    EFlowSPA: TEdit;
    BuFlowCloseA: TButton;
    CBFlowGasA: TComboBox;
    Label6: TLabel;
    SGDummy: TStringGrid;
    Label9: TLabel;
    EFlowSPN: TEdit;
    BuFlowSPN: TButton;
    BuFlowCloseN: TButton;
    CBFlowGasN: TComboBox;
    EFlowSPC: TEdit;
    BuFlowSPC: TButton;
    BuFlowCloseC: TButton;
    CBFlowGasC: TComboBox;
    EFlowSPR: TEdit;
    BuFlowSPR: TButton;
    BuFlowCloseD: TButton;
    CBFlowGasR: TComboBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label12: TLabel;
    Label16: TLabel;
    LaAlistatus: TLabel;
    Label22: TLabel;
    Label2: TLabel;
    ChkAliPortOpened: TCheckBox;
    buAliConfPort: TButton;
    buAliCloseport: TButton;
    buAliOpenPort: TButton;
    BuAliping: TButton;
    EAliUserCmdReply: TEdit;
    EAliUserCmd: TEdit;
    chkAlidebug: TCheckBox;
    buAliResetCnt: TButton;
    TabSheet2: TTabSheet;
    chkDumNoise: TCheckBox;
    Label15: TLabel;
    Label17: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    GroupBox4: TGroupBox;
    Pan1: TPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    EAliAddrR: TEdit;
    EAliAddrC: TEdit;
    EAliAddrN: TEdit;
    EAliAddrA: TEdit;
    ChkAliDisableA: TCheckBox;
    ChkAliDisableN: TCheckBox;
    ChkAliDisableC: TCheckBox;
    ChkAliDisableR: TCheckBox;
    CBAliRngR: TComboBox;
    CheckBox8: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox1: TCheckBox;
    CBAliRngA: TComboBox;
    CBAliRngN: TComboBox;
    CBAliRngC: TComboBox;
    Label14: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    ChkFLowIsDummy: TCheckBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    Label13: TLabel;
    BuAliThreadStart: TButton;
    BuAliThreadStop: TButton;
    BuAliUpdateA: TButton;
    Label10: TLabel;
    PanAliStatusA: TPanel;
    PanAliStatusN2: TPanel;
    PanAliStatusC: TPanel;
    PanAliStatusR: TPanel;
    BuAliUpdateN2: TButton;
    BuAliUpdateC: TButton;
    BuAliUpdateR: TButton;
    PanAliThreadStatus: TPanel;
    PanFlowName: TPanel;
    Label20: TLabel;
    PanAliPort: TPanel;
    PanAliBaudRate: TPanel;
    Label21: TLabel;
    PanAliOKCnt: TPanel;
    PanAliErrCnt: TPanel;
    Label23: TLabel;
    PanAliNDevs: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    BuAliCloseAll: TButton;
    LaAliUserCmdTime: TLabel;
    ChkAliSetpCompatibMode: TCheckBox;
    procedure ButtonHideClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Initialize; //call at beginning    
    procedure CBSelectFlowChange(Sender: TObject);
    procedure HWFormRefreshIntvChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure ChkAutoRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BuFlowDisconClick(Sender: TObject);
    procedure BuFlowConClick(Sender: TObject);
    procedure ChkDumNoiseClick(Sender: TObject);
    procedure CBDummyDieOutClick(Sender: TObject);
    procedure buAliResetCntClick(Sender: TObject);
    procedure buAliConfPortClick(Sender: TObject);
    procedure buAliOpenPortClick(Sender: TObject);
    procedure buAliCloseportClick(Sender: TObject);
    procedure chkAlidebugClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BuAlipingClick(Sender: TObject);
    procedure BuAliThreadStartClick(Sender: TObject);
    procedure BuAliThreadStopClick(Sender: TObject);
    procedure BuAliUpdateAClick(Sender: TObject);
    procedure ChkAliDisableAClick(Sender: TObject);
    procedure ChkAliDisableNClick(Sender: TObject);
    procedure ChkAliDisableCClick(Sender: TObject);
    procedure ChkAliDisableRClick(Sender: TObject);
    procedure BuAliUpdateN2Click(Sender: TObject);
    procedure BuAliUpdateCClick(Sender: TObject);
    procedure BuAliUpdateRClick(Sender: TObject);
    procedure BuFlowSPAClick(Sender: TObject);
    procedure BuFlowSPNClick(Sender: TObject);
    procedure BuFlowSPCClick(Sender: TObject);
    procedure BuFlowSPRClick(Sender: TObject);
    procedure BuFlowCloseAClick(Sender: TObject);
    procedure BuFlowCloseNClick(Sender: TObject);
    procedure BuFlowCloseCClick(Sender: TObject);
    procedure BuFlowCloseDClick(Sender: TObject);
    procedure BuAliCloseAllClick(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure CBFlowGasAChange(Sender: TObject);
    procedure CBFlowGasNChange(Sender: TObject);
    procedure CBFlowGasCChange(Sender: TObject);
    procedure CBFlowGasRChange(Sender: TObject);
    procedure ChkAliSetpCompatibModeClick(Sender: TObject);
  private      { Private declarations }
    //Flow ctrl objects
    DummyFlow: TDummyFlowControl;
    AlicatRS232Flow: TAlicatFlowControl;
    procedure RefreshAlicatStatus;
    procedure RefreshDummyStatus;
    procedure RefreshFlowData;
  private
    //form configuration HELPERS
    fLocalConfManager: TLoadSaveConfigManager;    //configuration load/save helper
    fConfigManId: longint;
    procedure SetupConfigManager;   //associates internal variables, that or to be filled to/from ini file
  private
    //form configuration fields
    //rerfresh, redraw
    fRefreshInt: longint;
    fAutorefresh: boolean;
    fFlowDevSelIndex: integer;
    //window
    fwindowtop: integer;
    fwindowheight: integer;
    fwindowleft: integer;
    fwindowwidth: integer;
    fwindowSetBounds: boolean;
    //flow general
    fFlowEditSPA: string;
    fFlowEditSPN: string;
    fFlowEditSPC: string;
    fFlowEditSPR: string;
    fCBGasIndexA: integer;
    fCBGasIndexN: integer;
    fCBGasIndexC: integer;
    fCBGasIndexR: integer;
    //Alicat tab setup
    fDebug: boolean;
    fportbr: string;
    fportname: string;
    fAliDisabledA: boolean;
    fAliDisabledN: boolean;
    fAliDisabledC: boolean;
    fAliDisabledR: boolean;
    fAliAddrA: string;
    fAliAddrN: string;
    fAliAddrC: string;
    fAliAddrR: string;
    fAliRangeIndexA: integer;
    fAliRangeIndexN: integer;
    fAliRangeIndexC: integer;
    fAliRangeIndexR: integer;
    //dummy
    fDumNoiseEnabled: boolean;
    //
    procedure UpdateAlicatConf;  //updates devices conf using values in internal fielads (e.g. after change from UI)
  private
    //
    procedure PrepareDummyStringGrid;
    procedure ManualSetpoint( dev: TFlowDevices; sp: double );
    procedure ManualSelGas( dev: TFlowDevices; gas: TFlowGasType );
  public
    //procedure WMExitSizeMove(var Message: TMessage) ; message WM_EXITSIZEMOVE;  //detect move, resize
  public
    { Public declarations }
    procedure ConfigLoad;
    procedure ConfigSave;
  public
    //ACTIVE FLOCONTrol Object
    FlowControl: TFlowControllerObject;
  end;

var
  FormFlowHardware: TFormFlowHardware;


// Synchronize

implementation


{$R *.dfm}

procedure TFormFlowHardware.FormCreate(Sender: TObject);
begin
   //config manager
   fLocalConfManager := TLoadSaveConfigManager.Create;
   //
   FlowControl := nil;
   DummyFlow := TDummyFlowControl.Create;
   AlicatRS232Flow := TAlicatFlowControl.Create;
   //
   fwindowSetBounds := true; //restore position on first show        //!!! Form position must be set to poDesigned!!!
   Position := poDesigned;
   logmsg('TFormFlowHardware.FormCreate done.');
end;

procedure TFormFlowHardware.FormDestroy(Sender: TObject);
begin
  ConfigSave;
  //
  DummyFLow.Destroy;
  AlicatRS232Flow.Destroy;
  //confign manager should be destroyed last (because of other objects may call it in during destruction)
  fLocalConfManager.Destroy;
end;

procedure TFormFlowHardware.Initialize;
begin
   //load configuration
   logmsg('TFormFlowHardware.Initialize: config load start');
   SetupConfigManager;
   try
     ConfigLoad;
   except
     on E: Exception do begin ShowMessage(' TFormFlowHardware.Initialize config load exception: ' + E.Message) end;
   end;
   logmsg('TFormFlowHardware.Initialize: config load done');
   //form prep
   PrepareDummyStringGrid;
   //
   //try initialize on lastly selected flowctrl device
   UpdateAlicatConf;

   CBSelectFlowChange(nil);
   logmsg('TFormFlowHardware.Initialize done');
end;


procedure TFormFlowHardware.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //
end;


procedure TFormFlowHardware.FormShow(Sender: TObject);
begin
  RefreshTimer.Enabled := ChkAutoRefresh.Checked;
  if fwindowSetBounds then   //only at start/first show
    begin
      FormFlowHardware.SetBounds( fwindowleft, fwindowtop, fwindowwidth, fwindowheight);
      fwindowSetBounds := false;
    end;
end;

procedure TFormFlowHardware.FormHide(Sender: TObject);
begin
  RefreshTimer.Enabled := False;
end;


procedure TFormFlowHardware.ButtonHideClick(Sender: TObject);
begin
  RefreshTimer.Enabled := false;
  FormFlowHardware.Hide;
end;


//config manager

procedure TFormFlowHardware.SetupConfigManager;
Var
  Section : string;
begin
  if fLocalConfManager=nil then
    begin
      logerror('TFormFlowHardware.SetupConfigManager:  fLocalConfManager=nil');
      exit;
    end;
  fConfigManId := fLocalConfManager.genNewID;
  Section := 'FormFLOWHardware';
  //
  fLocalConfManager.RegVariableLongInt(fConfigManId, @fRefreshInt, 'RefreshInt', 1000, Section);
  fLocalConfManager.RegVariableBool(fConfigManId, @fAutorefresh, 'Autorefresh', true, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fFlowDevSelIndex, 'PTCSelIndex', 0, Section);
  //window pos
  fLocalConfManager.RegVariableInteger(fConfigManId, @fwindowtop, 'fwindowtop', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fwindowheight, 'fwindowheight', 790, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fwindowleft, 'fwindowleft', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fwindowwidth, 'fwindowwidth', 900, Section);
  //general flow ctrl
  fLocalConfManager.RegVariableStr(fConfigManId, @fFlowEditSPA, 'fFlowEditSPA', '0', Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fFlowEditSPN, 'fFlowEditSPN', '0', Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fFlowEditSPC, 'fFlowEditSPC', '0', Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fFlowEditSPR, 'fFlowEditSPR', '0', Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fCBGasIndexA, 'fCBGasIndexA', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fCBGasIndexN, 'fCBGasIndexN', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fCBGasIndexC, 'fCBGasIndexC', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fCBGasIndexR, 'fCBGasIndexR', 0, Section);
  //Alicat tab
  Section := 'FormPTCHardware_AlicatRS232Tab';
  fLocalConfManager.RegVariableBool(fConfigManId, @fAliDisabledA, 'fAliDisabledA', false, Section);
  fLocalConfManager.RegVariableBool(fConfigManId, @fAliDisabledN, 'fAliDisabledN', false, Section);
  fLocalConfManager.RegVariableBool(fConfigManId, @fAliDisabledC, 'fAliDisabledC', false, Section);
  fLocalConfManager.RegVariableBool(fConfigManId, @fAliDisabledR, 'fAliDisabledR', false, Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fAliAddrA, 'fAliAddrA', 'A', Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fAliAddrN, 'fAliAddrN', 'B', Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fAliAddrC, 'fAliAddrC', 'C', Section);
  fLocalConfManager.RegVariableStr(fConfigManId, @fAliAddrR, 'fAliAddrR', 'D', Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fAliRangeIndexA, 'fAliRangeIndexA', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fAliRangeIndexN, 'fAliRangeIndexN', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fAliRangeIndexC, 'fAliRangeIndexC', 0, Section);
  fLocalConfManager.RegVariableInteger(fConfigManId, @fAliRangeIndexR, 'fAliRangeIndexR', 0, Section);
  //fLocalConfManager.RegVariableBool(fConfigManId, @fDebug, 'fDebug', false, Section);
  //dummy tab
  Section := 'FormPTCHardware_Dummy_Tab';
  fLocalConfManager.RegVariableBool(fConfigManId, @fDumNoiseEnabled, 'fDumNoiseEnabled', true, Section);
end;


procedure TFormFlowHardware.ConfigLoad;
Var
 ini: TIniFile;
 AppPath, brstr: string;
begin
   logmsg('iiii TFormFlowHardware.ConfigLoad: Start');
   if GlobalConfig<>nil then AppPath :=  GlobalConfig.getAppPath
   else AppPath := '.\';
   //ConfigDefault;
   INI :=  TINIFile.Create(AppPath + CFlowFormconfigfile);
   if INI = nil then
   begin
     logmsg('TFormFlowHardware.ConfigLoad: INI file assign/create failed');
     exit;
   end;
   //
   //use config manager to load data using prepared inifile
   if fLocalConfManager = nil then
   begin
     logmsg('TFormFlowHardware.ConfigLoad: fLocalConfManager = nil -> cannot load -> exit');
     exit;
   end;
   if AlicatRS232Flow<>nil then AlicatRS232Flow.LoadConfig;

   fLocalConfManager.LoadUsingIni( INI );
   //
   //com port conf
   //save com port conf
   //   if bk8500PTC<>nil then bk8500PTC.LoadComPortConf( AppDir + '\' + CHWFormComPortconfigfile);
   //!!!
   //do after load assignment - //need to UPDATE form after load conf from fields
   //FORM general
    HWFormRefreshIntv.Text := IntToStr( fRefreshInt );
    ChkAutoRefresh.Checked :=  fAutorefresh;
    CBSelectFlow.ItemIndex :=  fFlowDevSelIndex;
    //form window position restore
    FormFlowHardware.SetBounds(fwindowleft, fwindowtop,fwindowwidth, fwindowheight);
    //Flow control
    EFlowSPA.Text := fFlowEditSPA;
    EFlowSPN.Text := fFlowEditSPN;
    EFlowSPC.Text := fFlowEditSPC;
    EFlowSPR.Text := fFlowEditSPR;
    CBFlowGasA.ItemIndex := fCBGasIndexA;
    CBFlowGasN.ItemIndex := fCBGasIndexN;
    CBFlowGasC.ItemIndex := fCBGasIndexC;
    CBFlowGasR.ItemIndex := fCBGasIndexR;
    //Alicat RS232TAB
    ChkAliDisableA.Checked := fAliDisabledA;
    ChkAliDisableN.Checked := fAliDisabledN;
    ChkAliDisableC.Checked := fAliDisabledC;
    ChkAliDisableR.Checked := fAliDisabledR;
    EAliAddrA.Text := fAliAddrA;
    EAliAddrN.Text := fAliAddrN;
    EAliAddrC.Text := fAliAddrC;
    EAliAddrR.Text := fAliAddrR;
    CBAliRngA.ItemIndex := fAliRangeIndexA;
    CBAliRngN.ItemIndex := fAliRangeIndexN;
    CBAliRngC.ItemIndex := fAliRangeIndexC;
    CBAliRngR.ItemIndex := fAliRangeIndexR;
    //chkAlidebug.Checked := fDebug;
   //
   //dummy TAB
   ChkDumNoise.Checked := fDumNoiseEnabled;
   //
   //trigger other after load methods
   if AlicatRS232Flow<> nil then AlicatRS232Flow.DoAfterLoad;
   // fill form objects from internal fields after loading for alicat
   UpdateAlicatConf;
   //done
   INI.Destroy;
   INI := nil;
   //
   logmsg('iiii TFormFlowHardware.ConfigLoad: Finish');
end;


procedure TFormFlowHardware.ConfigSave;
Var
 iptcsel, ikolvoltfb, ikolcurrfb, ikolrng, iautoref: integer;
 ini: TIniFile;
 AppPath: string;
begin
      if AlicatRS232Flow<>nil then AlicatRS232Flow.SaveConfig;

   if GlobalConfig<>nil then AppPath :=  GlobalConfig.getAppPath
   else AppPath := '.\';
   //!!!! apparently the parametr is WHOLE to the config file otherwise it uses "root/WINDOWS"
   ini :=  TINIFile.Create(AppPath + CFlowFormconfigfile);
   if INI = nil then
   begin
     logmsg('HWForm: save: INI file assign/create failed');
     exit;
   end;
   if fLocalConfManager = nil then exit;
   ///before calling configmanager >> must update couple of variables first
   // form position
    fwindowtop := FormFlowHardware.Top;
    fwindowheight := FormFlowHardware.Height;
    fwindowleft := FormFlowHardware.Left;
    fwindowwidth := FormFlowHardware.Width;
   // main config
    fRefreshInt := StrToIntDef(  HWFormRefreshIntv.Text, 1000 );
    fAutorefresh := ChkAutoRefresh.Checked;
    fFlowDevSelIndex := CBSelectFlow.ItemIndex;
   //general flow
    fFlowEditSPA := EFlowSPA.Text;
    fFlowEditSPN := EFlowSPN.Text;
    fFlowEditSPC := EFlowSPC.Text;
    fFlowEditSPR := EFlowSPR.Text;
   //other variables have been update during events handling 
   // other modules trigger before save
   //if AlicatRS232Flow<>nil then AlicatRS232Flow.DoBeforeSavingConf;
   //save using config manager
   fLocalConfManager.SaveUsingIni( INI );
   //DO other SAVING
   //dispose
   INI.Destroy;
   INI := nil;
end;






procedure TFormFlowHardware.CBSelectFlowChange(Sender: TObject);
Var
  i:integer;
  b: boolean;
begin
  if fDebug then logmsg('ii TFormFlowHardware.CBSelectFlowChange');
  //update reference to active PTC
  i := CBSelectFlow.ItemIndex;
  if i = 0 then FlowControl := AlicatRS232Flow;
  if i = 1 then FlowControl := DummyFlow;
  //
  //initiali
  if FlowControl=nil then logerror('EEEE TFormFlowHardware.CBSelectFlowChange NIL');
  if FlowControl<>nil then
    begin
      b := FlowControl.Initialize;
    end
  else
    b := false;
  //Assign to MAIN FLOW INTERFACE
  if MainHWInterface=nil then
    begin
      logerror('TFormPTCHardware.CBSelectPTCChange: nekde je chybka - MainHWInterface=nil');
      exit;
    end;
  MainHWInterface.FlowDeviceAssign( FlowControl );
  //
  if b then logmsg('ii TFormFlowHardware.CBSelectFlowChange init true') else logmsg('ii  TFormFlowHardware.CBSelectFlowChange init false');
end;


procedure TFormFlowHardware.HWFormRefreshIntvChange(Sender: TObject);
begin
  RefreshTimer.Interval :=  StrToIntDef( HWFormRefreshIntv.Text, 1000);
end;

procedure TFormFlowHardware.ChkAutoRefreshClick(Sender: TObject);
begin
  RefreshTimer.Enabled := ChkAutoRefresh.Checked;
end;


procedure TFormFlowHardware.RefreshTimerTimer(Sender: TObject);
Var
  s: string;
  b: boolean;
begin
   if not FormFlowHardware.Visible then exit;
   //refresh main form
   if FlowControl=nil then  s := 'NIL' else s := FlowControl.Name;
   PanFlowName.Caption := s;
   if FlowControl=nil then b:= false else b :=  FlowControl.IsReady;
   ChkFlowReady.Checked := b;
   if FlowControl=nil then b:= false else b :=  FlowControl.IsDummy;
   ChkFlowIsDummy.Checked := b;
   //refresh global flow tab
   RefreshFlowData;
   //refresh modules
   RefreshAlicatStatus;
   RefreshDummyStatus;
end;

procedure TFormFlowHardware.PrepareDummyStringGrid;
begin
  with SGDummy do               //TStringGrid
    begin
      rows[0].Strings[0] := 'Device';
      rows[0].Strings[1] := 'Gas';
      rows[0].Strings[2] := 'Setpoint';
      rows[0].Strings[3] := 'Actual Flow';
      rows[0].Strings[4] := 'other data';
      //set size
      ColWidths[4] := 200;
    end;
end;

procedure TFormFlowHardware.RefreshFlowData;
Var
  fData : TFlowData;
  fStatus: TCommDevFlagSet;
  dev: TFlowDevices;
  n: byte;
begin
  if FlowControl=nil then
    begin
      SGDummy.rows[1].Strings[4] := 'NIL';
      SGDummy.rows[2].Strings[4] := 'NIL';
      SGDummy.rows[3].Strings[4] := 'NIL';
      SGDummy.rows[4].Strings[4] := 'NIL';
      exit;
    end;
  if not FlowControl.IsReady then
    begin
      SGDummy.rows[1].Strings[4] := 'not ready';
      SGDummy.rows[2].Strings[4] := 'not ready';
      SGDummy.rows[3].Strings[4] := 'not ready';
      SGDummy.rows[4].Strings[4] := 'not ready';
      exit;
    end;
  FlowControl.Aquire( fData, fStatus );
  n := 1;
  for dev := low(TFlowDevices) to high(TFlowDevices) do
    begin
      SGDummy.rows[n].Strings[0] :=  FlowDevToStr( dev );
      SGDummy.rows[n].Strings[1] :=  FlowGasTypeToStr( fdata[dev].gastype );
      SGDummy.rows[n].Strings[2] :=  FloatToStr( fdata[dev].setpoint );
      SGDummy.rows[n].Strings[3] :=  FloatToStr( fdata[dev].massflow );
      SGDummy.rows[n].Strings[4] :=  FloatToStr( fdata[dev].pressure ) + ' psi  ' + FloatToStr( fdata[dev].temp ) + ' C';
      Inc(n);
    end;
end;


procedure TFormFlowHardware.RefreshAlicatStatus;
begin
  if AlicatRS232Flow=nil then
    begin
      LaAlistatus.Caption := 'NIL';
      exit;
    end;
  LaAlistatus.Caption := '';
  //port
  PanAliPort.Caption :=  AlicatRS232Flow.getPortName;
  PanAliBaudRate.Caption :=  AlicatRS232Flow.getBaudRate;
  ChkAliPortOpened.Checked := AlicatRS232Flow.isPortOpen;
  //config
  ChkAliSetpCompatibMode.Checked := AlicatRS232Flow.SetpCompatibMode;
  //thread
  PanAliThreadStatus.Caption := AlicatRS232Flow.getThreadStatus; //AlicatThreadStatusToStr( AlicatRS232Flow.getThreadStatus );
  PanAliNDevs.Caption := IntToStr( AlicatRS232Flow.GetNDevsInThread );
  //statistic
  PanAliOKCnt.Caption := IntToStr( AlicatRS232Flow.getOKCount );
  PanAliErrCnt.Caption := IntToStr( AlicatRS232Flow.getErrCount );
  //flowctrl conf
  PanAliStatusA.Caption := AlicateRecStatusToStr( AlicatRS232Flow.fdevarray[ CFlowAnode ] );
  PanAliStatusN2.Caption := AlicateRecStatusToStr( AlicatRS232Flow.fdevarray[ CFlowN2 ] );
  PanAliStatusC.Caption := AlicateRecStatusToStr( AlicatRS232Flow.fdevarray[ CFlowCathode ] );
  PanAliStatusR.Caption := AlicateRecStatusToStr( AlicatRS232Flow.fdevarray[ CFlowRes ] );
  //reply to User Cmd
  if AlicatRS232Flow.fUserCmdReplyIsNew then
    begin
      LaAliUserCmdTime.Caption := DateTimeToStr(AlicatRS232Flow.fUserCmdReplyTime );
      EAliUserCmdReply.Text  :=  BinStrToPrintStr( AlicatRS232Flow.fUserCmdReplyS );
    end;
end;


procedure TFormFlowHardware.RefreshDummyStatus;
begin
  chkDumNoise.Checked := DummyFlow.NoiseEnabled;
end;


procedure TFormFlowHardware.BuFlowDisconClick(Sender: TObject);
begin
  if FlowControl=nil then
    begin
      ShowMessage('FlowControl is NIL');
    end;
  FlowControl.Finalize;
end;

procedure TFormFlowHardware.BuFlowConClick(Sender: TObject);
begin
  if FlowControl=nil then
    begin
      ShowMessage('FlowControl is NIL');
      exit;
    end;
  if not FlowControl.Initialize then ShowMessage('Initialize treturned FALSE');
end;

procedure TFormFlowHardware.ChkDumNoiseClick(Sender: TObject);
begin
  fDumNoiseEnabled := chkDumNoise.Checked;
end;

procedure TFormFlowHardware.CBDummyDieOutClick(Sender: TObject);
begin
  //dummyPtc.DieoutEnabled := CBDummyDieOut.Checked;
end;

procedure TFormFlowHardware.buAliResetCntClick(Sender: TObject);
begin
  AlicatRS232Flow.resetErrOKCounters;
end;

procedure TFormFlowHardware.buAliConfPortClick(Sender: TObject);
begin
  if AlicatRS232Flow=nil then exit;
  AlicatRS232Flow.SetupComPort;
end;

procedure TFormFlowHardware.buAliOpenPortClick(Sender: TObject);
begin
  if AlicatRS232Flow=nil then exit;
  AlicatRS232Flow.OpenComPort;
end;

procedure TFormFlowHardware.buAliCloseportClick(Sender: TObject);
begin
  if AlicatRS232Flow=nil then exit;
  AlicatRS232Flow.CloseComPort;
end;

procedure TFormFlowHardware.chkAlidebugClick(Sender: TObject);
begin
 fDebug := chkAlidebug.Checked;
 if AlicatRS232Flow=nil then exit;
 AlicatRS232Flow.Debug := fDebug;
end;

procedure TFormFlowHardware.Button3Click(Sender: TObject);
begin
 PrepareDummyStringGrid;
end;

procedure TFormFlowHardware.BuAlipingClick(Sender: TObject);
Var
  s: string;
begin
 s := EAliUserCmd.Text;
 if AlicatRS232Flow=nil then exit;
 AlicatRS232Flow.SendUserCmd( s );
end;

procedure TFormFlowHardware.BuAliThreadStartClick(Sender: TObject);
begin
  if AlicatRS232Flow=nil then exit;
  AlicatRS232Flow.ThreadStart;
end;

procedure TFormFlowHardware.BuAliThreadStopClick(Sender: TObject);
begin
  if AlicatRS232Flow=nil then exit;
  AlicatRS232Flow.ThreadStop;
end;

procedure TFormFlowHardware.ChkAliDisableAClick(Sender: TObject);
begin
  fAliDisabledA := ChkAliDisableA.Checked;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.ChkAliDisableNClick(Sender: TObject);
begin
  fAliDisabledN := ChkAliDisableN.Checked;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.ChkAliDisableCClick(Sender: TObject);
begin
  fAliDisabledC := ChkAliDisableC.Checked;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.ChkAliDisableRClick(Sender: TObject);
begin
  fAliDisabledR := ChkAliDisableR.Checked;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateAClick(Sender: TObject);
begin
  fAliAddrA := EAliAddrA.Text[1];
  fAliRangeIndexA := CBAliRngA.ItemIndex;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateN2Click(Sender: TObject);
begin
  fAliAddrN := EAliAddrN.Text[1];
  fAliRangeIndexN := CBAliRngN.ItemIndex;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateCClick(Sender: TObject);
begin
  fAliAddrC := EAliAddrC.Text[1];
  fAliRangeIndexC := CBAliRngC.ItemIndex;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateRClick(Sender: TObject);
begin
  fAliAddrR := EAliAddrR.Text[1];
  fAliRangeIndexR := CBAliRngR.ItemIndex;
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.UpdateAlicatConf;  //updates devices conf using values in internal fielads (e.g. after change from UI)
// helpers
  function AliRngItemIndexToRngmin( i: integer): double; //helper
  begin
    Result := 0;
    case i of
      0..4: Result := 0;
    end;
  end;
//
  function AliRngItemIndexToRngMAX( i: integer): double; //helper
  begin
    Result := 0;
    case i of
      0: Result := 100;
      1: Result := 500;
      2: Result := 50;
    end;
  end;
//
begin
  if AlicatRS232Flow = nil then exit;
  AlicatRS232Flow.UpdateDev(CFlowAnode,   not fAliDisabledA, GetCharFromStrSafe(fAliAddrA,1), AliRngItemIndexToRngmin(fAliRangeIndexA), AliRngItemIndexToRngMAX(fAliRangeIndexA));
  AlicatRS232Flow.UpdateDev(CFlowN2,      not fAliDisabledN, GetCharFromStrSafe(fAliAddrN,1), AliRngItemIndexToRngmin(fAliRangeIndexN), AliRngItemIndexToRngMAX(fAliRangeIndexN));
  AlicatRS232Flow.UpdateDev(CFlowCathode, not fAliDisabledC, GetCharFromStrSafe(fAliAddrC,1), AliRngItemIndexToRngmin(fAliRangeIndexC), AliRngItemIndexToRngMAX(fAliRangeIndexC));
  AlicatRS232Flow.UpdateDev(CFlowRes,     not fAliDisabledR, GetCharFromStrSafe(fAliAddrR,1), AliRngItemIndexToRngmin(fAliRangeIndexR), AliRngItemIndexToRngMAX(fAliRangeIndexR));
  AlicatRS232Flow.UpdateDevicesInThread;
end;

procedure TFormFlowHardware.ManualSetpoint( dev: TFlowDevices; sp: double );
Var
  b: boolean;
  s: string;
begin
  if FlowControl=nil then
    begin
      ShowMessage('FLOW: FlowControl=nil cannot change setpoint');
      exit;
    end;
  LogProject('FLOW: Setting manualy setpoint on >>' + FlowDevToStr(dev) + '<< to ' + FloatToStr( sp ));
  b := FlowControl.SetSetp(dev, sp);
  if not b then
    begin
      s := 'FLOW: manual Setpoint change FAILED';
      LogProject(s);
      ShowMessage(s);
    end;
end;


procedure TFormFlowHardware.ManualSelGas( dev: TFlowDevices; gas: TFlowGasType );
Var
  b: boolean;
  s: string;
begin
  if FlowControl=nil then
    begin
      ShowMessage('FLOW: FlowControl=nil cannot change setpoint');
      exit;
    end;
  LogProject('FLOW: Setting manualy Gas on >>' + FlowDevToStr(dev) + '<< to ' + FlowGasTypeToStr(gas) );
  b := FlowControl.SetGas(dev, gas);
  if not b then
    begin
      s := 'FLOW: Gas change FAILED';
      LogProject(s);
      ShowMessage(s);
    end;
end;


procedure TFormFlowHardware.BuFlowSPAClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := StrToFloatDef( EFlowSPA.Text, 0 );
  dev := CFlowAnode;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowSPNClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := StrToFloatDef( EFlowSPN.Text, 0 );
  dev := CFlowN2;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowSPCClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := StrToFloatDef( EFlowSPC.Text, 0 );
  dev := CFlowCathode;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowSPRClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := StrToFloatDef( EFlowSPR.Text, 0 );
  dev := CFlowRes;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowCloseAClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := 0.0;
  dev := CFlowAnode;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowCloseNClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := 0.0;
  dev := CFlowN2;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowCloseCClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := 0.0;
  dev := CFlowCathode;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowCloseDClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := 0.0;
  dev := CFlowRes;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuAliCloseAllClick(Sender: TObject);
begin
  ManualSetpoint( CFlowAnode, 0.0 );
  ManualSetpoint( CFlowN2, 0.0 );
  ManualSetpoint( CFlowCathode, 0.0 );
  ManualSetpoint( CFlowRes, 0.0 );
end;

procedure TFormFlowHardware.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  
  Resize := true;
end;

procedure TFormFlowHardware.CBFlowGasAChange(Sender: TObject);
Var
  gas: TFlowGasType;
  dev: TFlowDevices;
begin
  gas :=  AlicatGasStrToType(  CBFlowGasA.Text );
  if gas = CGasUnknown then exit;
  dev := CFlowAnode;
  ManualSelGas( dev, gas );
end;

procedure TFormFlowHardware.CBFlowGasNChange(Sender: TObject);
Var
  gas: TFlowGasType;
  dev: TFlowDevices;
begin
  gas :=  AlicatGasStrToType(  CBFlowGasN.Text );
  if gas = CGasUnknown then exit;
  dev := CFlowN2;
  ManualSelGas( dev, gas );
end;

procedure TFormFlowHardware.CBFlowGasCChange(Sender: TObject);
Var
  gas: TFlowGasType;
  dev: TFlowDevices;
begin
  gas :=  AlicatGasStrToType(  CBFlowGasC.Text );
  if gas = CGasUnknown then exit;
  dev := CFlowCathode;
  ManualSelGas( dev, gas );
end;

procedure TFormFlowHardware.CBFlowGasRChange(Sender: TObject);
Var
  gas: TFlowGasType;
  dev: TFlowDevices;
begin
  gas :=  AlicatGasStrToType(  CBFlowGasR.Text );
  if gas = CGasUnknown then exit;
  dev := CFlowRes;
  ManualSelGas( dev, gas );
end;


procedure TFormFlowHardware.ChkAliSetpCompatibModeClick(Sender: TObject);
begin
 if AlicatRS232Flow=nil then exit;
 AlicatRS232Flow.SetpCompatibMode := TCheckBox(Sender).Checked;
 //ShowMessage( BoolToStr( AlicatRS232Flow.SetpCompatibMode ) );
end;

end.




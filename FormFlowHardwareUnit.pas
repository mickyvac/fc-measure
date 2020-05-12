unit FormFlowHardwareUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, ExtCtrls,
  IniFiles, Logger, FormGlobalConfig, myUtils, MVConversion, ConfigManager,
  HWabstractDevicesV3,  HWinterface,
  FlowINterface_dummy,
  FlowInterface_FCS_TCPIP, FlowInterface_Alicat_new3; //FlowInterface_Alicat_new3;



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
    Label3: TLabel;
    TabSheet3: TTabSheet;
    PanelSheet3: TPanel;
    chkDebug: TCheckBox;
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
    procedure chkDebugClick(Sender: TObject);
  private      { Private declarations }
    //Flow ctrl objects
    DummyFlow: TDummyFlowControl;
    AlicatRS232Flow: TAlicatFlowControl;
    FlowFCSTCPIP: TFlowControlFCS_TCPIP;
    //
    procedure RefreshAlicatStatus;
    procedure RefreshDummyStatus;
    procedure RefreshMFCTCPIP;
    procedure RefreshFlowData;
  private
    fModuleName: string;
    fConfClient: TConfigClient;
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
    fwindowLoadPosition: boolean;
    //flow general
    fCBGasIndexA: integer;
    fCBGasIndexN: integer;
    fCBGasIndexC: integer;
    fCBGasIndexR: integer;
    //Alicat tab setup
    fDebug: boolean;
    fportbr: string;
    fportname: string;
    //dummy
    fDumNoiseEnabled: boolean;
    //
    procedure UpdateAlicatConf;  //updates devices conf using values in internal fielads (e.g. after change from UI)
  private
    //
    procedure CreateInterfaces;
    procedure DestroyInterfaces;
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
  public
     fInitialized : boolean;
     procedure HandleBroadcastSignals(sig: TMySignal);
  public
    { Public declarations }
    procedure AfterLoad;
    procedure ConfigDefault;
  end;

var
  FormFlowHardware: TFormFlowHardware;


// Synchronize

implementation


{$R *.dfm}

procedure TFormFlowHardware.FormCreate(Sender: TObject);
begin
  fModuleName := 'FormFLOWControl';
  Position := poDesigned;
  fwindowLoadPosition := true;
  GlobalConfig.RegisterFormPositionRec(fModuleName+'', FormFlowHardware);

   //config manager
   fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, fModuleName );
   //
   FlowControl := nil;
   DummyFlow := nil;
   AlicatRS232Flow := nil;
   FlowFCSTCPIP := nil;
   //
   GlobalConfig.RegisterForBroadcastSignals( HandleBroadcastSignals );
   //
   fInitialized := false;
   SGDummy.Color := clDesaturatedYellow;
   //


   logmsg('TFormFlowHardware.FormCreate done.');
end;

procedure TFormFlowHardware.FormDestroy(Sender: TObject);
begin
  DestroyInterfaces;
  //confign manager should be destroyed last (because of other objects may call it in during destruction)
  fConfClient.Destroy;
end;

procedure TFormFlowHardware.CreateInterfaces;
begin
   //DummyFlow := TDummyFlowControl.Create;
   AlicatRS232Flow := nil;//AlicatRS232Flow := TAlicatFlowControl.Create;
end;

procedure TFormFlowHardware.DestroyInterfaces;
begin
   if DummyFLow<>nil then
     begin
       DummyFlow.Destroy;
       DummyFlow := nil;
     end;
   if AlicatRS232Flow<>nil then
     begin
       AlicatRS232Flow.Finalize;
       AlicatRS232Flow.Destroy;
       AlicatRS232Flow := nil;
     end;
   if FlowFCSTCPIP<>nil then
     begin
       FlowFCSTCPIP.Finalize;
       FlowFCSTCPIP.Destroy;
       FlowFCSTCPIP := nil;
     end;
   LogMsg( 'TFormFlowHardware.DestroyInterfaces done.' );
end;



procedure TFormFlowHardware.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //
  //fInitialized := false;
end;

procedure TFormFlowHardware.FormShow(Sender: TObject);
begin
  RefreshTimer.Enabled := ChkAutoRefresh.Checked;
  if fwindowLoadPosition then   //only at start/first show
    begin
      GlobalConfig.UseFormPositionRec(fModuleName,FormFlowHardware);
      fwindowLoadPosition := false;
    end;
end;

procedure TFormFlowHardware.FormHide(Sender: TObject);
begin
  RefreshTimer.Enabled := False;
end;





procedure TFormFlowHardware.HandleBroadcastSignals(sig: TMySignal);
begin
  case sig of
    // init + create interfaces
    CsigInit0Init:
       begin
         if not fInitialized then Initialize;
       end;
    //destroy interfaces
    CSigDestroy:
       begin
         DestroyInterfaces;    //!!!!!!!!!  need to destroy before other essential modules are destroyed (logger, global-config)
       end;
    //
    CsigInit1LoadConfig:
       begin
         try
          ConfigLoad;
         except
            on E: Exception do begin ShowMessage(' TFormFlowHardware.Initialize config load exception: ' + E.Message) end;
         end;
       end;
    CSigInit2AfterLoad:
       begin
         AfterLoad;
       end;
    CSigSaveConfig:
       begin
         ConfigSave;
       end;
    CSigStartInitializeDevices:
       begin
         //if GlobalConfig.AutoInitDevices then if FlowControl<>nil then FlowControl.Initialize;
         //if MainHWInterface<>nil then  MainHWInterface.FlowDeviceAssign(FlowControl);  //!!!! necessary to update reference !!!!!
       end;
    CSigGoingTerminate:
      begin
        if AlicatRS232Flow<>nil then
          begin
            AlicatRS232Flow.CloseComPort;
            AlicatRS232Flow.ThreadStop;
          end;
        if FlowControl<>nil then FlowControl.Finalize;
      end;
    CSigDisconnectDevices:
       begin
         if FlowControl<>nil then FlowControl.Finalize;
       end;
  end; //case
end;





//---=====================


procedure TFormFlowHardware.Initialize;
begin
   //!!!!!
   //CreateInterfaces;
   //load configuration
   //form prep
   PrepareDummyStringGrid;
   //
   //try initialize on lastly selected flowctrl device
   fInitialized := true;
   logmsg('TFormFlowHardware.Initialize done');
end;









procedure TFormFlowHardware.ButtonHideClick(Sender: TObject);
begin
  FormFlowHardware.Hide;
end;


procedure TFormFlowHardware.ConfigDefault;
begin
end;


procedure TFormFlowHardware.AfterLoad;
begin
   //FORM general
   UpdateAlicatConf;
   //form window position restore
   TForm(self).SetBounds(fwindowleft, fwindowtop, fwindowwidth, fwindowheight);
   HWFormRefreshIntvChange(nil);
   CBSelectFlowChange(nil);
   ChkAliSetpCompatibModeClick(nil);
end;


procedure TFormFlowHardware.ConfigLoad;
Var
 ini: TIniFile;
 AppPath, brstr: string;
begin
   logmsg('iiii TFormFlowHardware.ConfigLoad: Start');

   HWFormRefreshIntv.Text := fConfClient.Load('RefreshInt', '1003');
   ChkAutoRefresh.Checked :=  fConfClient.Load('Autorefresh', true);
   CBSelectFlow.ItemIndex :=  fConfClient.Load('ControlSelIndex', 0);
  //window pos
  fwindowtop := fConfClient.Load( 'fwindowtop', 0 );
  fwindowheight := fConfClient.Load(  'fwindowheight', 790 );
  fwindowleft  := fConfClient.Load(  'fwindowleft', 0 );
  fwindowwidth := fConfClient.Load(  'fwindowwidth', 900 );
  //general flow ctrl
    //Flow control
    EFlowSPA.Text := fConfClient.Load( 'fFlowEditSPA', '0' );
    EFlowSPN.Text := fConfClient.Load( 'fFlowEditSPN', '0' );
    EFlowSPC.Text := fConfClient.Load( 'fFlowEditSPC', '0' );
    EFlowSPR.Text := fConfClient.Load( 'fFlowEditSPR', '0' );

    CBFlowGasA.ItemIndex := fConfClient.Load( 'fCBGasIndexA', 0 );
    CBFlowGasN.ItemIndex := fConfClient.Load( 'fCBGasIndexN', 0 );
    CBFlowGasC.ItemIndex := fConfClient.Load( 'fCBGasIndexC', 0 );
    CBFlowGasR.ItemIndex := fConfClient.Load( 'fCBGasIndexR', 0 );

    //Alicat RS232TAB
    ChkAliDisableA.Checked := fConfClient.Load( 'fAliDisabledA', false );
    ChkAliDisableN.Checked := fConfClient.Load( 'fAliDisabledN', false );
    ChkAliDisableC.Checked := fConfClient.Load( 'fAliDisabledC', false );
    ChkAliDisableR.Checked := fConfClient.Load( 'fAliDisabledR', false );
    EAliAddrA.Text := fConfClient.Load( 'fAliAddrA', 'A' );
    EAliAddrN.Text := fConfClient.Load(  'fAliAddrN', 'B' );
    EAliAddrC.Text := fConfClient.Load( 'fAliAddrC', 'C' );
    EAliAddrR.Text := fConfClient.Load( 'fAliAddrR', 'D' );
    CBAliRngA.ItemIndex := fConfClient.Load( 'fAliRangeIndexA', 0 );
    CBAliRngN.ItemIndex := fConfClient.Load( 'fAliRangeIndexN', 0 );
    CBAliRngC.ItemIndex := fConfClient.Load( 'fAliRangeIndexC', 0 );
    CBAliRngR.ItemIndex := fConfClient.Load( 'fAliRangeIndexR', 0 );
    ChkAliSetpCompatibMode.Checked := fConfClient.Load( 'AliSetpCompatibMode', true );
   //
   //dummy TAB
   ChkDumNoise.Checked := fConfClient.Load( 'fDumNoiseEnabled', true );
   //
   if AlicatRS232Flow<>nil then AlicatRS232Flow.LoadConfig;
   if FlowFCSTCPIP<>nil then FlowFCSTCPIP.LoadConfig;
   logmsg('iiii TFormFlowHardware.ConfigLoad: Finish');
end;


procedure TFormFlowHardware.ConfigSave;
Var
 frm: TForm;
begin
  logmsg('  VTPControl Form ConfigSAVE: start.');
 //general form variable
  fConfClient.Save('RefreshInt', HWFormRefreshIntv.Text);
  fConfClient.Save('Autorefresh', ChkAutoRefresh.Checked);
  fConfClient.Save('ControlSelIndex', CBSelectFlow.ItemIndex);
  //
  fConfClient.Save('fFlowEditSPA', EFlowSPA.Text);
  fConfClient.Save('fFlowEditSPN', EFlowSPN.Text);
  fConfClient.Save('fFlowEditSPC', EFlowSPC.Text);
  fConfClient.Save('fFlowEditSPR', EFlowSPR.Text);
   //other variables have been update during events handling
   // other modules trigger before save
  //window pos
  frm:= TForm(self);
  fConfClient.Save( 'fwindowtop', frm.Top );
  fConfClient.Save(  'fwindowheight', frm.Height );
  fConfClient.Save(  'fwindowleft', frm.Left );
  fConfClient.Save(  'fwindowwidth',frm.Width );
    //Alicat RS232TAB
  fConfClient.Save( 'fAliDisabledA', ChkAliDisableA.Checked );
  fConfClient.Save( 'fAliDisabledN', ChkAliDisableN.Checked);
  fConfClient.Save( 'fAliDisabledC' , ChkAliDisableC.Checked);
  fConfClient.Save( 'fAliDisabledR', ChkAliDisableR.Checked);
  fConfClient.Save('fAliAddrA', EAliAddrA.Text);
  fConfClient.Save('fAliAddrN', EAliAddrN.Text);
  fConfClient.Save('fAliAddrC', EAliAddrC.Text);
  fConfClient.Save('fAliAddrR', EAliAddrR.Text);
  fConfClient.Save('fAliRangeIndexA', CBAliRngA.ItemIndex);
  fConfClient.Save('fAliRangeIndexN', CBAliRngN.ItemIndex);
  fConfClient.Save('fAliRangeIndexC', CBAliRngC.ItemIndex);
  fConfClient.Save('fAliRangeIndexR', CBAliRngR.ItemIndex);
  fConfClient.Save('AliSetpCompatibMode', ChkAliSetpCompatibMode.Checked);
   //dummy TAB
  fConfClient.Save('fDumNoiseEnabled', ChkDumNoise.Checked);
  //
   //save embeded objects
   if AlicatRS232Flow<>nil then AlicatRS232Flow.SaveConfig;
   if FlowFCSTCPIP<>nil then FlowFCSTCPIP.SaveConfig;
end;






procedure TFormFlowHardware.CBSelectFlowChange(Sender: TObject);
Var
  i:integer;
  b: boolean;
begin
  if fDebug then logmsg('ii TFormFlowHardware.CBSelectFlowChange');
  //update reference to active PTC
  i := CBSelectFlow.ItemIndex;
  if i = 0 then  //alicat
    begin
      if AlicatRS232Flow=nil then AlicatRS232Flow := TAlicatFlowControl.Create;
      FlowControl := AlicatRS232Flow;
    end;
  if i = 1 then       //dummy
    begin
      if DummyFlow=nil then DummyFlow := TDummyFlowControl.Create;
      FlowControl := DummyFlow;
    end;
  if i = 2 then
    begin
      if FlowFCSTCPIP=nil then FlowFCSTCPIP := TFlowControlFCS_TCPIP.Create( PanelSheet3, 'FlowViaFCS-TCPIP' );
      FlowControl := FlowFCSTCPIP;
    end;
  //
  //Assign to MAIN FLOW INTERFACE
  if MainHWInterface=nil then
    begin
      logerror('TFormPTCHardware.CBSelectPTCChange: nekde je chybka - MainHWInterface=nil');
      exit;
    end;
  MainHWInterface.FlowDeviceAssign( FlowControl );
  //
  //initiali
  b := false;
  if FlowControl=nil then logerror('EEEE TFormFlowHardware.CBSelectFlowChange NIL');
  if FlowControl<>nil then
    begin
      if GlobalConfig.AutoInitDevices then
        if not FLowControl.IsReady then b := FlowControl.Initialize;
    end
  else
    b := false;
  if b then logmsg('ii TFormFlowHardware.CBSelectFlowChange init true') else logmsg('ii  TFormFlowHardware.CBSelectFlowChange init false');
end;


procedure TFormFlowHardware.chkDebugClick(Sender: TObject);
begin
  FlowControl.Debug := chkDebug.Checked;
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
   if FlowControl=nil then  s := 'NIL' else s := FlowControl.DevName;
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
   RefreshMFCTCPIP;
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
  LaAlistatus.Caption := 'Alicat interface';
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
  if DummyFlow=nil then exit;
  chkDumNoise.Checked := DummyFlow.NoiseEnabled;
end;

procedure TFormFlowHardware.RefreshMFCTCPIP;
begin
  if FlowFCSTCPIP=nil then exit;
  FlowFCSTCPIP.UpdatePanelIface;
end;

procedure TFormFlowHardware.BuFlowDisconClick(Sender: TObject);
begin
  if FlowControl=nil then exit;
  FlowControl.Finalize;
end;

procedure TFormFlowHardware.BuFlowConClick(Sender: TObject);
begin
  if FlowControl=nil then begin ShowMessage('FlowControl is NIL'); exit;  end;
  if not FlowControl.Initialize then logerror('Initialize treturned FALSE');
end;

procedure TFormFlowHardware.ChkDumNoiseClick(Sender: TObject);
begin
  if DummyFlow=nil then exit;
  DummyFlow.NoiseEnabled := chkDumNoise.Checked;
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
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.ChkAliDisableNClick(Sender: TObject);
begin
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.ChkAliDisableCClick(Sender: TObject);
begin
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.ChkAliDisableRClick(Sender: TObject);
begin
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateAClick(Sender: TObject);
begin
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateN2Click(Sender: TObject);
begin
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateCClick(Sender: TObject);
begin
  UpdateAlicatConf;
end;

procedure TFormFlowHardware.BuAliUpdateRClick(Sender: TObject);
begin
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
{  function AliRngItemIndexToRngMAX( i: integer; ): double; //helper
  Var rr: integer;
  begin
    Result := 0;

    case i of
      0: Result := 100;
      1: Result := 500;
      2: Result := 50;
    end;
  end;

          }
  function AliRngItemIndexToRngMAX( i: integer; s: string): double; //helper
  begin
    Result := 0;
    case i of
      0: Result := 100;
      1: Result := 500;
      2: Result := 50;
      3: Result := 1000;
      4: Result := 5000;
      else
        begin
          Result := StrToIntDef( s, 0);
          if Result<0 then Result:= 0;
        end;
    end;
  end;
//
Var
  dis: boolean;
  adr: char;
  rngmax, rngmin: double;
begin
  if AlicatRS232Flow = nil then exit;
  //A
  dis := ChkAliDisableA.Checked;
  adr := GetCharFromStrSafe( EAliAddrA.Text ,1);
  rngmin := AliRngItemIndexToRngmin( CBAliRngA.ItemIndex );
  rngmax := AliRngItemIndexToRngMAX( CBAliRngA.ItemIndex, CBAliRngA.Text );
  AlicatRS232Flow.UpdateDev(CFlowAnode, not dis, adr, rngmin , rngmax);
  //N
  dis := ChkAliDisableN.Checked;
  adr := GetCharFromStrSafe( EAliAddrN.Text ,1);
  rngmin := AliRngItemIndexToRngmin( CBAliRngN.ItemIndex );
  rngmax := AliRngItemIndexToRngMAX( CBAliRngN.ItemIndex, CBAliRngN.Text );
  AlicatRS232Flow.UpdateDev(CFlowN2,   not dis, adr, rngmin , rngmax);
  //C
  dis := ChkAliDisableC.Checked;
  adr := GetCharFromStrSafe( EAliAddrC.Text, 1);
  rngmin := AliRngItemIndexToRngmin( CBAliRngC.ItemIndex );
  rngmax := AliRngItemIndexToRngMAX( CBAliRngC.ItemIndex, CBAliRngC.Text );
  AlicatRS232Flow.UpdateDev(CFlowCathode,   not dis, adr, rngmin , rngmax);
  //R
  dis := ChkAliDisableR.Checked;
  adr := GetCharFromStrSafe( EAliAddrR.Text ,1);
  rngmin := AliRngItemIndexToRngmin( CBAliRngR.ItemIndex );
  rngmax := AliRngItemIndexToRngMAX( CBAliRngR.ItemIndex, CBAliRngR.Text );
  AlicatRS232Flow.UpdateDev(CFlowRes,   not dis, adr, rngmin , rngmax);
  //
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
  LogProjectEvent('FLOW: Setting manualy setpoint on >>' + FlowDevToStr(dev) + '<< to ' + FloatToStr( sp ));
  b := FlowControl.SetSetp(dev, sp);
  if not b then
    begin
      s := 'FLOW: manual Setpoint change FAILED';
      LogProjectEvent(s);
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
  LogProjectEvent('FLOW: Setting manualy Gas on >>' + FlowDevToStr(dev) + '<< to ' + FlowGasTypeToStr(gas) );
  b := FlowControl.SetGas(dev, gas);
  if not b then
    begin
      s := 'FLOW: Gas change FAILED';
      LogProjectEvent(s);
      ShowMessage(s);
    end;
end;


procedure TFormFlowHardware.BuFlowSPAClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := MyStrToFloatDef( EFlowSPA.Text, 0 );
  dev := CFlowAnode;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowSPNClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := MyStrToFloatDef( EFlowSPN.Text, 0 );
  dev := CFlowN2;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowSPCClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := MyStrToFloatDef( EFlowSPC.Text, 0 );
  dev := CFlowCathode;
  ManualSetpoint( dev, sp );
end;

procedure TFormFlowHardware.BuFlowSPRClick(Sender: TObject);
Var
  sp: double;
  dev: TFlowDevices;
begin
  sp := MyStrToFloatDef( EFlowSPR.Text, 0 );
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
 AlicatRS232Flow.SetpCompatibMode := ChkAliSetpCompatibMode.Checked;
 //ShowMessage( BoolToStr( AlicatRS232Flow.SetpCompatibMode ) );
end;


{
procedure TKolPTCObject.ReinitComPort;
Var
  conf: TComPortConf;
begin
  conf.Name := fComPortHelprName;
  conf.BR := '1Mbps';
  conf.DataBits := '8';
  conf.StopBits := '1';
  conf.Parity := 'None';
  conf.FlowCtrl := 'None';
  fComPortHelper.setComPortConf( conf);
  fComPortHelper.OpenPort;
  fComPortHelper.ClosePort;
end;
}


end.




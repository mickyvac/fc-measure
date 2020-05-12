unit FormValveControlUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Grids, StdCtrls,
  IniFiles, Logger, FormGlobalConfig, ConfigManager, myUtils,
  HWabstractDevicesV3,  HWinterface,
  VTPInterface_TCPIP_new;


Const
  CDebug = true;

type
  TFormValveControl = class(TForm)
    Label7: TLabel;
    Label1: TLabel;
    CBSelectControl: TComboBox;
    GroupBox2: TGroupBox;
    Label20: TLabel;
    ChkControlReady: TCheckBox;
    BuMainConnect: TButton;
    BuMainDiscon: TButton;
    SGDevices: TStringGrid;
    ChkControlDummy: TCheckBox;
    PanControlName: TPanel;
    ButtonHide: TButton;
    ChkAutoRefresh: TCheckBox;
    ERefreshIntv: TEdit;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    Label13: TLabel;
    Label23: TLabel;
    BuFCSThreadStart: TButton;
    BuFCSThreadStop: TButton;
    PanFCSThreadStatus: TPanel;
    PanFCSNDevs: TPanel;
    TabSheet2: TTabSheet;
    chkDumNoise: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    RefreshTimer: TTimer;
    GroupBox3: TGroupBox;
    Label12: TLabel;
    EFCSserver: TEdit;
    Label16: TLabel;
    EFCSport: TEdit;
    BuFCSUpdate: TButton;
    ChkFCSPortOpened: TCheckBox;
    buFCSOpenPort: TButton;
    buFCSCloseport: TButton;
    GroupBox4: TGroupBox;
    Label15: TLabel;
    EFCSUserCmd: TEdit;
    BuFCSSendCMD: TButton;
    EFCSUserCmdReply: TEdit;
    Label17: TLabel;
    chkFCSdebug: TCheckBox;
    LaFCSstatus: TLabel;
    Label2: TLabel;
    PanFCSErrCnt: TPanel;
    PanFCSOKCnt: TPanel;
    Label22: TLabel;
    buFCSResetCnt: TButton;
    GroupBox5: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    EMainR1SetP: TEdit;
    BuMainR1Setp: TButton;
    BuMainR1SetZero: TButton;
    LaFCSUserCmdTime: TLabel;
    Button1: TButton;
    Label11: TLabel;
    PanControlTimeAq: TPanel;
    Label5: TLabel;
    PanFCSLastAq: TPanel;
    Button3: TButton;
    Button7: TButton;
    chkEnableSendMFC: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BuMainConnectClick(Sender: TObject);
    procedure BuMainDisconClick(Sender: TObject);
    procedure BuFCSSendCMDClick(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure BuFCSThreadStartClick(Sender: TObject);
    procedure buFCSOpenPortClick(Sender: TObject);
    procedure buFCSCloseportClick(Sender: TObject);
    procedure EFCSserverChange(Sender: TObject);
    procedure EFCSportChange(Sender: TObject);
    procedure BuFCSUpdateClick(Sender: TObject);
    procedure buFCSResetCntClick(Sender: TObject);
    procedure BuFCSThreadStopClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure chkFCSdebugClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure BuMainR1SetpClick(Sender: TObject);
    procedure chkEnableSendMFCClick(Sender: TObject);
    procedure ButtonHideClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
    fTCPserver: string;
    fTCPport: string;
    fConfClient: TConfigClient;
    fInitialized: boolean;
    //
    //window position
    fwindowtop: integer;
    fwindowheight: integer;
    fwindowleft: integer;
    fwindowwidth: integer;
  public
    { Public declarations }
    VTPControl: TVTPControl_TCP_FCSControl;
    procedure RefreshData;
    procedure WriteGridRow( actrow: integer; Dname: string; Dvalue: string; en: boolean; other:string );
    procedure WriteGridHeader( actrow: integer; lab: string);
    procedure RefreshTCPFCSControl;
    procedure PrepareHeaderAndClear;
  public
     procedure HandleBroadcastSignals(sig: TMySignal);
  public
    { Public declarations }
    procedure Initialize;
    procedure ConfigLoad;
    procedure AfterLoad;
    procedure ConfigSave;
    procedure ConfigDefault;
  end;

var
  FormValveControl: TFormValveControl;

implementation

{$R *.dfm}

procedure TFormValveControl.FormCreate(Sender: TObject);
begin
  fInitialized := false;
  VTPControl := TVTPControl_TCP_FCSControl.Create;
  fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, 'FormVTPControl' );
  //!!!
  GlobalConfig.RegisterForBroadcastSignals( HandleBroadcastSignals );
end;

procedure TFormValveControl.FormDestroy(Sender: TObject);
begin
  if VTPControl<>nil then begin
    VTPControl.Finalize;
    VTPControl.Destroy;
    end;
  if fConfClient<>nil then fConfClient.Destroy;
end;


procedure TFormValveControl.HandleBroadcastSignals(sig: TMySignal);
begin
  case sig of
    //
    CsigInit0Init:
       begin
         if not fInitialized then Initialize;
       end;
    CsigInit1LoadConfig:
       begin
         ConfigLoad;
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
         if MainHWInterface<>nil then  MainHWInterface.VTPDeviceAssign(VTPControl);  //!!!! necessary to update reference !!!!!
         if GlobalConfig.AutoInitDevices then if VTPControl<>nil then VTPControl.Initialize;
         //!!!!!!!!!!!!!!!
         Button7Click(nil);
       end;
    CSigDisconnectDevices:
       begin
         if VTPControl<>nil then VTPControl.Finalize;
       end;
  end; //case
end;

procedure TFormValveControl.Initialize;
begin
   if CDebug then logmsg('TFormPTCHardware.Initialize: start');
   //initialize
   if VTPControl<> nil then
     begin
      VTPControl.Debug := false;
      //VTPControl.ThreadStart;
      //VTPControl.SetupCom(localhost, '20005');
     end;
   fInitialized := true;
   //MainHWInterface.fEnableSendMFC := false;
   //chkEnableSendMFCClick(nil);     //fuck this was nasty to find and disable
 if CDebug then logmsg('TFormPTCHardware.Initialize: done.');
end;

procedure TFormValveControl.ConfigDefault;
begin
end;


procedure TFormValveControl.ConfigLoad;
begin
  if CDebug then logmsg('  VTPControl Form ConfigLoad: start.');
  //general form variable
  ERefreshIntv.Text := fConfClient.Load('RefreshInt', '1003');
  ChkAutoRefresh.Checked := fConfClient.Load('Autorefresh', true);
  CBSelectControl.ItemIndex := fConfClient.Load('CBSelectControlItemIndex', 0 );
  EMainR1SetP.Text := fConfClient.Load('Reg1Setpoint', '0.0');
  //VTPControl TCPIP
  fTCPserver := fConfClient.Load('TCP-server', 'localhost');
  fTCPport := fConfClient.Load('TCP-port', '20005');
  //window pos
  fwindowtop := fConfClient.Load( 'fwindowtop', 0 );
  fwindowheight := fConfClient.Load(  'fwindowheight', 790 );
  fwindowleft  := fConfClient.Load(  'fwindowleft', 0 );
  fwindowwidth := fConfClient.Load(  'fwindowwidth', 900 );

  // VTPControl.LoadConfig
  if VTPControl<>nil then VTPControl.LoadConfig;

  if CDebug then logmsg('  VTPControl Form ConfigLoad: done.');
end;


procedure TFormValveControl.AfterLoad;
begin
   if CDebug then logmsg('  VTPControl Form After load.');
  if VTPControl<>nil then VTPControl.GetComConf(fTCPserver, fTCpPort);
  EFCSserver.Text := fTCPserver;
  EFCSport.Text := fTCPport;
  //if VTPControl<>nil then VTPControl.SetupCom(fTCPserver, fTCPport);
  //ptcform window position restore
  TForm(Self).SetBounds(fwindowleft, fwindowtop, fwindowwidth, fwindowheight);
end;


procedure TFormValveControl.ConfigSave;
Var
  frm: TForm;
begin
  if CDebug then logmsg('  VTPControl Form ConfigSAVE: start.');
 //general form variable
  fConfClient.Save('RefreshInt', ERefreshIntv.Text);
  fConfClient.Save('Autorefresh', ChkAutoRefresh.Checked);
  //Control sel
  fConfClient.Save( 'CBSelectControlItemIndex', CBSelectControl.ItemIndex   );
  fConfClient.Save( 'Reg1Setpoint', EMainR1SetP.Text   );
  //VTPControl TCPIP
  fConfClient.Save( 'TCP-server', EFCSserver.Text   );
  fConfClient.Save( 'TCP-port', EFCSport.Text   );
  //window pos
  frm:= TForm(self);
  fConfClient.Save( 'fwindowtop', frm.Top );
  fConfClient.Save(  'fwindowheight', frm.Height );
   fConfClient.Save(  'fwindowleft', frm.Left );
  fConfClient.Save(  'fwindowwidth',frm.Width );
   //save embeded objects
  if VTPControl<>nil then VTPControl.SaveConfig;
end;









procedure TFormValveControl.BuMainConnectClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.SetupCom( fTCPserver, fTCPport);
  VTPControl.Initialize;
end;


procedure TFormValveControl.BuMainDisconClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.Finalize;
end;

procedure TFormValveControl.BuFCSSendCMDClick(Sender: TObject);
Var
  s: string;
begin
 s := EFCSUserCmd.Text;
 if VTPControl=nil then exit;
 VTPControl.SendUserCmd( s );
end;

procedure TFormValveControl.RefreshTimerTimer(Sender: TObject);
Var
  s: string;
  b: boolean;
begin
   if not FormValveControl.Visible then exit;
   //refresh main form
   if VTPControl=nil then  s := 'NIL' else s := VTPControl.DevName;
   PanControlName.Caption := s;
   if VTPControl=nil then b:= false else b :=  VTPControl.IsReady;
   ChkControlReady.Checked := b;
   if VTPControl=nil then b:= false else b :=  VTPControl.IsDummy;
   ChkControlDummy.Checked := b;
   //refresh global flow tab
   RefreshData;
   //refresh modules
   RefreshTCPFCSControl;
end;

procedure TFormValveControl.RefreshTCPFCSControl;
Var
  s, srv, prt: string;
  c: boolean;
begin
  if VTPControl=nil then exit;
  //logmsg( 'TFormValveControl.RefreshTCPFCSControl START');
  c := VTPControl.isComConnected;
  ChkFCSPortOpened.Checked := c;
  if not c then LaFCSstatus.Caption := 'Disconnected';
  if c then
    begin
      //logmsg( 'getcomconf');
      VTPControl.GetComConf(srv, prt);
      LaFCSstatus.Caption := 'Connected to '+srv+':'+prt;
    end;
  PanFCSNDevs.Caption := IntToStr( VTPControl.GetNDevsInThread );
  PanFCSLastAq.Caption := DateTimeToStrMV( VTPControl.getLastAquireTime() );
  PanFCSErrCnt.Caption := '-';
  PanFCSOKCnt.Caption := '-';
  PanFCSThreadStatus.Caption := VTPControl.getThreadStatus;
  PanFCSNDevs.Caption := IntToStr( VTPControl.GetNDevsInThread );
  //
    if VTPControl.fUserCmdReplyIsNew then
    begin
      LaFCSUserCmdTime.Caption := DateTimeToStr(VTPControl.fUserCmdReplyTime ); //+ IntTOStr(VTPControl.;
      EFCSUserCmdReply.Text  :=  BinStrToPrintStr( VTPControl.fUserCmdReplyS );
      VTPControl.fUserCmdReplyIsNew := false;
    end;
   //logmsg( 'TFormValveControl.RefreshTCPFCSControl END');
end;


procedure TFormValveControl.PrepareHeaderAndClear;
begin
  with SGDevices do               //TStringGrid
    begin
  Cols[1].Clear;
  Cols[2].Clear;
  Cols[3].Clear;
  Cols[4].Clear;
      //
      rows[0].Strings[0] := 'DevName';
      rows[0].Strings[1] := 'DevIdStr';
      rows[0].Strings[2] := 'Enabled';
      rows[0].Strings[3] := 'Timestamp';
      rows[0].Strings[4] := 'Value';
      //set size
      ColWidths[0] := 60;
      ColWidths[1] := 100;
      ColWidths[2] := 100;
      ColWidths[3] := 150;
      ColWidths[4] := 200;
    end;
end;

procedure TFormValveControl.RefreshData;
Var
  devV: TValveDevices;
  devS: TSensorDevices;
  devR: TRegDevices;
  //
  dataV: TValveData;
  dataS: TSensorData;
  dataR: TRegData;
  //
  baseparam: TDeviceBaseRec;
  paramV: TDevValveParamRec;
  paramS: TDevSensorParamRec;
  paramR: TDevRegParamRec;
  //
  actrow: integer;
  //
  devobj: TVTPDeviceBase;
  baserec: TDeviceBaseRec;
  basevalstr: string;

  name: string;
  value: string;
  info: string;
  en, res: boolean;
  i, n: integer;
begin
  PrepareHeaderAndClear;
  if VTPControl=nil then
    begin
      SGDevices.rows[1].Strings[1] := 'NIL';
      SGDevices.rows[1].Strings[2] := 'NIL';
      SGDevices.rows[1].Strings[3] := 'NIL';
      SGDevices.rows[1].Strings[4] := 'NIL';
      exit;
    end;
  if not VTPControl.IsReady then
    begin
      SGDevices.rows[1].Strings[1] := 'not ready';
      SGDevices.rows[1].Strings[2] := 'not ready';
      SGDevices.rows[1].Strings[3] := 'not ready';
      SGDevices.rows[1].Strings[4] := 'not ready';
      exit;
    end;
  //aquire and fill data
  VTPControl.Aquire(dataV, dataS, dataR);
  actrow := 1;
  n := VTPControl.getBaseDevCount;
  SGDevices.RowCount := n+1;
  for i := 0 to n-1 do
    begin
      try
        res := VTPControl.getBaseDevParamById(i, baserec, basevalstr);
        //devobj := VTPControl.
      except
        on E:exception do ShowMessage( E.message);
      end;
      if not res then continue; //!!!!
      //write line
      name := IntToStr(i) + ') ' + baserec.name;
      value := basevalstr;
      en := baserec.enabled;
      info := baserec.idstr;
      WriteGridRow( actrow, name, info, en, value);
      Inc( actrow);
    end;
 //thread
end;



procedure TFormValveControl.WriteGridRow( actrow: integer; Dname: string; Dvalue: string; en: boolean; other:string );
begin
  if (actrow<1) or (actrow>SGDevices.RowCount) then exit;
  SGDevices.rows[actrow].Strings[0] := DName;
  SGDevices.rows[actrow].Strings[1] := DValue;
  SGDevices.rows[actrow].Strings[2] := BoolToStr( en );
  //color according to enabled???
  //if en then SGDevices.rows[actrow].
  SGDevices.rows[actrow].Strings[3] := other;
  SGDevices.rows[actrow].Strings[4] := '';
end;

procedure TFormValveControl.WriteGridHeader( actrow: integer; lab: string);
begin
  if (actrow<1) or (actrow>SGDevices.RowCount) then exit;
  SGDevices.rows[actrow].Strings[0] := lab;
  SGDevices.rows[actrow].Strings[1] := '';
  SGDevices.rows[actrow].Strings[2] := '';
  SGDevices.rows[actrow].Strings[3] := '';
  SGDevices.rows[actrow].Strings[4] := '';
end;



procedure TFormValveControl.BuFCSThreadStartClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.ThreadStart;
end;

procedure TFormValveControl.BuFCSThreadStopClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.ThreadStop;
end;

procedure TFormValveControl.buFCSOpenPortClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.OpenCom;
end;

procedure TFormValveControl.buFCSCloseportClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.CloseCom;
end;

procedure TFormValveControl.EFCSserverChange(Sender: TObject);
begin
  fTCPserver := EFCSServer.Text;
end;

procedure TFormValveControl.EFCSportChange(Sender: TObject);
begin
  fTCPport := EFCSport.Text;
end;

procedure TFormValveControl.BuFCSUpdateClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
  VTPControl.CloseCom;
  VTPControl.SetupCom( fTCPserver, fTCPport);
  VTPControl.OpenCom;
  RefreshTCPFCSControl;
end;

procedure TFormValveControl.buFCSResetCntClick(Sender: TObject);
begin
  if VTPControl=nil then exit;
end;



procedure TFormValveControl.Button1Click(Sender: TObject);
Var
 baserec: TDeviceBaseRec;
 i, n: longint;
 basevalstr:  string;
 res: boolean;
begin
  n := VTPControl.getBaseDevCount;
  for i := 0 to n-1 do
    begin
      res := VTPControl.getBaseDevParamById(i, baserec, basevalstr);
      if not res then continue; //!!!!
      //write line
      baserec.enabled := true;
      VTPControl.setBaseDevParamById(i, baserec);
    end;
end;

procedure TFormValveControl.chkFCSdebugClick(Sender: TObject);
begin
  if VTPControl = nil then exit;
  VTPControl.Debug := TCheckBox( Sender ).Checked;
end;

procedure TFormValveControl.Button3Click(Sender: TObject);
Var
 baserec: TDeviceBaseRec;
 i, n: longint;
 basevalstr:  string;
 res: boolean;
begin
  n := VTPControl.getBaseDevCount;
  for i := 0 to n-1 do
    begin
      res := VTPControl.getBaseDevParamById(i, baserec, basevalstr);
      if not res then continue; //!!!!
      //write line
      baserec.enabled := false;
      VTPControl.setBaseDevParamById(i, baserec);
    end;
end;

procedure TFormValveControl.Button7Click(Sender: TObject);
Var
 baserec: TDeviceBaseRec;
 dpS: TSensorDevices;
 parPS: TDevSensorParamRec;
 i, n: longint;
 basevalstr:  string;
 res: boolean;
begin
  for dPS := Low( TSensorDevices) to High( TSensorDevices) do
    begin
      VTPControl.getDevParam(dPS, parPS, baserec);
      baserec.enabled := true;
      VTPControl.setDevParam(dPS, parPS, baserec);
    end;
end;

procedure TFormValveControl.BuMainR1SetpClick(Sender: TObject);
Var
  val: double;
begin
  val := StrToFLoatDef( EMainR1SetP.Text, 0);
  VTPControl.SetRegSetp(CpRegBackpress, val );
end;

procedure TFormValveControl.chkEnableSendMFCClick(Sender: TObject);
begin
  MainHWInterface.EnableSendMFC := chkEnableSendMFC.Checked;
end;

procedure TFormValveControl.ButtonHideClick(Sender: TObject);
begin
  TForm(self).Hide;
end;

procedure TFormValveControl.Button6Click(Sender: TObject);
begin
  TForm(self).Hide;
end;

procedure TFormValveControl.Button4Click(Sender: TObject);
begin
    TForm(self).Hide;
end;

procedure TFormValveControl.Button2Click(Sender: TObject);
begin
    TForm(self).Hide;
end;

procedure TFormValveControl.Button5Click(Sender: TObject);
begin
    TForm(self).Hide;
end;

end.

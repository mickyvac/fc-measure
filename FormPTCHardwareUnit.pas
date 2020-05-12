unit FormPTCHardwareUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  IniFiles, Logger, FormGlobalConfig, ConfigManager, myUtils, MVConversion,
  HWabstractDevicesV3,  HWinterface,
  PTCInterface_KolPTC_TCPIP_new,
  PTCinterface_Dummy,
  PTCInterface_BK8500,
  PTCInterface_M97XX,
  PTCInterface_ZS1806,
  PTCInterface_PLI,
  ComCtrls;

Const
  CDebug = true;

type

  TFormPTCConfig = record
     //main form
     MainPtcSelIndex: integer;
     //kolptc
     KolUFBIndex: integer;
     KolIFBIndex: integer;
       //registers

       //channels



  end;

  PPotentiostatObject = ^TPotentiostatObject;

  TFormPTCHardware = class(TForm)
    Label7: TLabel;
    CBSelectPTC: TComboBox;
    ButtonHide: TButton;
    ChkAutoRefresh: TCheckBox;
    HWFormRefreshIntv: TEdit;
    Label1: TLabel;
    HWFormTimer: TTimer;
    BuHWCalib: TButton;
    PageControlPTC: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label21: TLabel;
    LaBKstatus: TLabel;
    Label26: TLabel;
    Label25: TLabel;
    Label24: TLabel;
    Label23: TLabel;
    Label22: TLabel;
    Label2: TLabel;
    Label16: TLabel;
    Label15: TLabel;
    Label12: TLabel;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    EBKTimeout: TEdit;
    EBKPort: TEdit;
    EBKPing: TEdit;
    EBKOKCnt: TEdit;
    EBKLastU: TEdit;
    EBKLastSetp: TEdit;
    EBKLastMode: TEdit;
    EBKLastI: TEdit;
    EBKErrCnt: TEdit;
    EBKBaudrate: TEdit;
    cbBKremotesense: TCheckBox;
    CbBKPortOpened: TCheckBox;
    cbBKOutputOn: TCheckBox;
    cbBKdebug: TCheckBox;
    Button1: TButton;
    buBKResetCnt: TButton;
    BuBKping: TButton;
    buBKopenPort: TButton;
    buBKConfPort: TButton;
    buBKcloseport: TButton;
    GroupBox2: TGroupBox;
    Label33: TLabel;
    PanKolV4R: TPanel;
    BuKolV4R: TButton;
    EKolV4R: TEdit;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    PanKolRelOn: TPanel;
    EKolRelOn: TEdit;
    BuKolRelOn: TButton;
    Label38: TLabel;
    PanKolSetp: TPanel;
    EKolSetp: TEdit;
    BuKolSetp: TButton;
    Label39: TLabel;
    PanKolProtect: TPanel;
    EKolProtect: TEdit;
    BuKolProtect: TButton;
    Label40: TLabel;
    Label41: TLabel;
    PanKolPROTcmd: TPanel;
    EKolProtCMD: TEdit;
    BuKolProtCMD: TButton;
    GroupBox3: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    PanKolChV4: TPanel;
    Label10: TLabel;
    Label13: TLabel;
    EKolChV4: TEdit;
    BuKolChV4: TButton;
    Label14: TLabel;
    PanKolChVref: TPanel;
    EKolChVref: TEdit;
    BuKolChVref: TButton;
    Label17: TLabel;
    PanKolChV2: TPanel;
    EKolChV2: TEdit;
    BuKolChV2: TButton;
    Label18: TLabel;
    PanKolChI: TPanel;
    EKolChI: TEdit;
    BuKolChI: TButton;
    Label28: TLabel;
    PanKolChI10: TPanel;
    EKolChI10: TEdit;
    BuKolChI10: TButton;
    Label42: TLabel;
    PanKolChSP: TPanel;
    EKolChSP: TEdit;
    BuKolChSP: TButton;
    GroupBox5: TGroupBox;
    ChkKolPTCBufferedRead: TCheckBox;
    CheckBox3: TCheckBox;
    ChkBKolPTCAutoRange: TCheckBox;
    Label32: TLabel;
    PanKolConstUFB: TPanel;
    CBKolPTCUFB: TComboBox;
    CBKolPTCIFB: TComboBox;
    PanKolConstIFB: TPanel;
    Label3: TLabel;
    GroupBox6: TGroupBox;
    Label11: TLabel;
    PanKolIRange: TPanel;
    Label5: TLabel;
    PanKolVRange: TPanel;
    PanKolLastOCV: TPanel;
    Label27: TLabel;
    GroupBox7: TGroupBox;
    BuKolPTCTurnON: TButton;
    BuKolPTCTurnOFF: TButton;
    Label37: TLabel;
    CBKolPTCRng: TComboBox;
    Label45: TLabel;
    CBKolSelectFB: TComboBox;
    Label30: TLabel;
    EKolPTCV4RngMin: TEdit;
    EKolPTCV4RngMax: TEdit;
    BuKolPTCSetV4Rng: TButton;
    Label6: TLabel;
    EKolNewSetp: TEdit;
    BuKolPTCSetSP: TButton;
    BuKolPTCResFuse: TButton;
    BuKolSetConstU: TButton;
    BuKolSetConstI: TButton;
    Label43: TLabel;
    PanKolRetryCnt: TPanel;
    EKolRetryCnt: TEdit;
    BuKolSetRetry: TButton;
    GroupBox8: TGroupBox;
    LKolptcHWstr: TLabel;
    ChkKolAvailable: TCheckBox;
    ChkKolReady: TCheckBox;
    ChkKolConfigured: TCheckBox;
    ChkKolDllloaded: TCheckBox;
    ButKolInit: TButton;
    ButKolFinal: TButton;
    BuKolLoadDLL: TButton;
    LaKolIfaceInfo: TLabel;
    GroupBox1: TGroupBox;
    MeKolChannels: TMemo;
    Label4: TLabel;
    Label20: TLabel;
    PanKolAquireTime: TPanel;
    Label44: TLabel;
    PanKolCommErr: TPanel;
    Label46: TLabel;
    PanKolCommErrNotFixed: TPanel;
    ChkKolOverrange: TCheckBox;
    Label47: TLabel;
    PanKolCommCnt: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ChkKolFuse: TCheckBox;
    ChkKolRelayOn: TCheckBox;
    GBoxKolPTCShowRange: TGroupBox;
    RBKolPTCr2: TRadioButton;
    RBKolPTCr1: TRadioButton;
    GBox5: TGroupBox;
    RBKolPTCV2: TRadioButton;
    RBKolPTCV4: TRadioButton;
    RBKolPTCVRef: TRadioButton;
    RBKolPTCI: TRadioButton;
    RBKolPTCIx10: TRadioButton;
    PanKolSetpoint: TPanel;
    Label19: TLabel;
    Label29: TLabel;
    PanKolProtV4Rng: TPanel;
    Label31: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label50: TLabel;
    GroupBox9: TGroupBox;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    ChkDummyDieOut: TCheckBox;
    ChkDummyNoise: TCheckBox;
    PanDumOCV: TPanel;
    EDumOCV: TEdit;
    BuDumOCV: TButton;
    ChkDummyCommError: TCheckBox;
    ChkDumFuse: TCheckBox;
    PanDumiR: TPanel;
    EDumiR: TEdit;
    BuDumiR: TButton;
    PanDumXOver: TPanel;
    EDumXOver: TEdit;
    BuDumXOver: TButton;
    PanDumTafel: TPanel;
    EDumTafel: TEdit;
    BuDumTafel: TButton;
    PanDumMA: TPanel;
    EDumMA: TEdit;
    BuDumMA: TButton;
    PanDumSinDistAmp: TPanel;
    ESinDistAmp: TEdit;
    BuSinDistAmp: TButton;
    PanDumRndNoiseAmp: TPanel;
    ERndNoiseAmp: TEdit;
    BuRndNoiseAmp: TButton;
    PanDumDieOutRatio: TPanel;
    EDumDieOutRatio: TEdit;
    BuDumDieOutRatio: TButton;
    GroupBox10: TGroupBox;
    ChkDumAvail: TCheckBox;
    ChkDumConf: TCheckBox;
    ChkDumReady: TCheckBox;
    GroupBox4: TGroupBox;
    RBDummyFBV: TRadioButton;
    RBDummyFBI: TRadioButton;
    ChkDummyOuput: TCheckBox;
    PanDumVolt: TPanel;
    LDummyV: TLabel;
    LDumyI: TLabel;
    PanDumCurr: TPanel;
    BuDummyCon: TButton;
    BuDummyDiscon: TButton;
    Label61: TLabel;
    PanDumExC: TPanel;
    Label62: TLabel;
    PanKolFuseSafe: TPanel;
    EKolFuseSoft: TEdit;
    BuKolFuseSoft: TButton;
    Label63: TLabel;
    PanKolFuseHard: TPanel;
    EKolFuseHard: TEdit;
    BuKolFuseHard: TButton;
    PanKolProtStat: TPanel;
    ChkKolDebug: TCheckBox;
    Label64: TLabel;
    PanKolRegADC: TPanel;
    EKolRegADC: TEdit;
    BuKolRegADC: TButton;
    PanKolShowFuseHard: TPanel;
    PanKolShowFuseSafe: TPanel;
    PanKolFwId: TPanel;
    Label65: TLabel;
    EKolFWVer: TEdit;
    Button5: TButton;
    Label66: TLabel;
    Label67: TLabel;
    PanKolRegSWFB: TPanel;
    EKolRegSWFB: TEdit;
    BuKolRegSWFB: TButton;
    chkDumEnSwLIM: TCheckBox;
    chkDumEnFuse: TCheckBox;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    ChkKolUseVrefInsteadOfV4: TCheckBox;
    Button11: TButton;
    M97XX: TTabSheet;
    PanM97XX: TPanel;
    TabSheet5: TTabSheet;
    PanZS1806: TPanel;
    PLIseries: TTabSheet;
    PanPLIseries: TPanel;
    procedure ButtonHideClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Initialize; //call at beginning    
    procedure CBSelectPTCChange(Sender: TObject);
    procedure HWFormRefreshIntvChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure HWFormTimerTimer(Sender: TObject);
    procedure ButKolInitClick(Sender: TObject);
    procedure CBKolPTCUFBChange(Sender: TObject);
    procedure CBKolPTCIFBChange(Sender: TObject);
    procedure CBKolPTCRngChange(Sender: TObject);
    procedure ButKolFinalClick(Sender: TObject);
    procedure BuKolPTCTurnONClick(Sender: TObject);
    procedure BuKolPTCTurnOFFClick(Sender: TObject);
    procedure BuKolPTCSetSPClick(Sender: TObject);
    procedure BuKolPTCResFuseClick(Sender: TObject);
    procedure ChkAutoRefreshClick(Sender: TObject);
    procedure BuDummyDisconClick(Sender: TObject);
    procedure BuDummyConClick(Sender: TObject);
    procedure ChkDummyNoiseClick(Sender: TObject);
    procedure ChkDummyDieOutClick(Sender: TObject);
    procedure buBKResetCntClick(Sender: TObject);
    procedure buBKConfPortClick(Sender: TObject);
    procedure buBKopenPortClick(Sender: TObject);
    procedure buBKcloseportClick(Sender: TObject);
    procedure cbBKremotesenseClick(Sender: TObject);
    procedure cbBKdebugClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure EBKTimeoutChange(Sender: TObject);
    procedure BuBKpingClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ChkKolPTCBufferedReadClick(Sender: TObject);
    procedure BuKolPTCSetV4RngClick(Sender: TObject);
    procedure BuKolV4RClick(Sender: TObject);
    procedure BuKolRelOnClick(Sender: TObject);
    procedure BuKolSetpClick(Sender: TObject);
    procedure BuKolProtectClick(Sender: TObject);
    procedure BuKolProtCMDClick(Sender: TObject);
    procedure BuKolChV4Click(Sender: TObject);
    procedure BuKolChVrefClick(Sender: TObject);
    procedure BuKolChV2Click(Sender: TObject);
    procedure BuKolChIClick(Sender: TObject);
    procedure BuKolChI10Click(Sender: TObject);
    procedure BuKolChSPClick(Sender: TObject);
    procedure BuKolLoadDLLClick(Sender: TObject);
    procedure BuKolSetConstUClick(Sender: TObject);
    procedure BuKolSetConstIClick(Sender: TObject);
    procedure CBKolSelectFBChange(Sender: TObject);
    procedure BuKolSetRetryClick(Sender: TObject);
    procedure EKolRetryCntChange(Sender: TObject);
    procedure EKolNewSetpChange(Sender: TObject);
    procedure EKolPTCV4RngMinChange(Sender: TObject);
    procedure EKolPTCV4RngMaxChange(Sender: TObject);
    procedure ChkKolDebugClick(Sender: TObject);
    procedure BuKolFuseSoftClick(Sender: TObject);
    procedure BuKolFuseHardClick(Sender: TObject);
    procedure BuKolRegADCClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure BuKolRegSWFBClick(Sender: TObject);
    procedure chkDumEnFuseClick(Sender: TObject);
    procedure chkDumEnSwLIMClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure ChkKolUseVrefInsteadOfV4Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
  private
    { Private declarations }
    kolPTC: TKolPTCObject;
    dummyPTC: TDummyPotentio;//TDummyPotentio;
    bk8500PTC: TBK8500Potentio;
    M97xxLOAD: TM97XX_PTCInterface;
    ZS1806LOAD: TZS1806_PTCInterface;
    PLILOAD: TPLIseries_PTCInterface;
    //
    procedure RefreshKolPTCStatus;
    procedure RefreshDummyPTCStatus;
    procedure RefreshBK8500PTCStatus;
    procedure RefreshM97xx;
    procedure RefreshZS1806;
    procedure RefreshPLILOAD;
    //BK8500PTC: TBK8500Potentio;
  public
     procedure HandleBroadcastSignals(sig: TMySignal);
  private
    //form configuration HELPERS
    fInitialized: boolean;
    fConfClient: TConfigClient;
    //procedure SetupConfigManager;   //associates internal variables, that or to be filled to/from ini file
    //
  private
    //form configuration fields
    fRefreshInt: longint;
    fAutorefresh: boolean;
    fPTCSelIndex: integer;
    //window position
    fwindowtop: integer;
    fwindowheight: integer;
    fwindowleft: integer;
    fwindowwidth: integer;
    //KolPTCsetup tab
    fIFBitemindex: integer;
    fUFBitemindex: integer;
    fRangeitemindex: integer;
    fSelFBitemindex: integer;
    fKolRetryCntText: string;
    fKolNewSetpText: string;
    fKolV4RngMinText: string;
    fKolV4RngMaxText: string;
  public
    { Public declarations }
    procedure AfterLoad;
    procedure ConfigLoad;
    procedure ConfigSave;
    procedure ConfigDefault;
  public
    PTC: TPotentiostatObject;
  public
    procedure WMExitSizeMove(var Message: TMessage) ; message WM_EXITSIZEMOVE;  //detect move, resize
  end;

var
  FormPTCHardware: TFormPTCHardware;

implementation

{$R *.dfm}

procedure TFormPTCHardware.FormCreate(Sender: TObject);
begin
   PTC := nil;
   kolPTC := nil;
   dummyPTC := nil;
   bk8500PTC := nil;
   fConfClient := nil;
   fInitialized := false;
   //config manager
   //fLocalConfManager := TLoadSaveConfigManager.Create;
   fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, 'FormPTCHardware' );
   //register receive signals
   GlobalConfig.RegisterForBroadcastSignals( HandleBroadcastSignals );
   logmsg('TFormPTCHardware.FormCreate done.');
end;


procedure TFormPTCHardware.FormDestroy(Sender: TObject);
begin
  //!!config save seems to must be done from form1 when closing ...
  try
    ConfigSave;
  except
    ShowMessage(' EXCEPT destroy');
  end;
  if dummyPTC<>nil then dummyPTC.Destroy;
  if bk8500PTC<>nil then bk8500PTC.Destroy;
  if kolPTC<>nil then
    begin
      KolPTC.Finalize;
      kolPTC.Destroy;
    end;
  //config manager
  if M97xxLOAD<>nil then
    begin
      M97xxLOAD.Finalize;
      M97xxLOAD.Destroy;
    end;
  if ZS1806LOAD<>nil then
    begin
      ZS1806LOAD.Finalize;
      ZS1806LOAD.Destroy;
    end;
  if PLILOAD<>nil then
    begin
      PLILOAD.Finalize;
      PLILOAD.Destroy;
    end;


  if fConfClient<>nil then fConfClient.Destroy;
  //if fLocalConfManager<>nil then fLocalConfManager.Destroy;
end;




procedure TFormPTCHardware.HandleBroadcastSignals(sig: TMySignal);
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
         if GlobalConfig.AutoInitDevices then if  PTC<>nil then PTC.Initialize;
       end;
    CSigDisconnectDevices:
       begin
         if (kolPTC<>nil) then kolPTC.Finalize;
         if (DummyPTC<>nil) then DummyPTC.Finalize;
         if (bk8500PTC<>nil) then bk8500PTC.Finalize;
       end;
  end; //case
end;




procedure TFormPTCHardware.Initialize;
Var
  kolregs: TKolPTCRegisterConfig;
begin
   if CDebug then logmsg('TFormPTCHardware.Initialize: start');

   //initialize each PTC
   if CDebug then logmsg('TFormPTCHardware.Initialize: creating kolptc');
   kolPTC := TKolPTCObject.Create;
   if CDebug then logmsg('TFormPTCHardware.Initialize: creating dummyptc');
   dummyPTC := TDummyPotentio.Create;
   if CDebug then logmsg('TFormPTCHardware.Initialize: creating bk8500');
   //bk8500PTC := TBK8500Potentio.Create;

   if CDebug then logmsg('TFormPTCHardware.Initialize: creating M97XX');
   M97xxLOAD := TM97XX_PTCInterface.Create;
   if M97xxLOAD<>nil then M97xxLOAD.CreateGUI( PanM97XX );
   ZS1806LOAD := TZS1806_PTCInterface.Create;
   if ZS1806LOAD<>nil then ZS1806LOAD.CreateGUI( PanZS1806 );
   PLILOAD := TPLIseries_PTCInterface.Create;
   if PLILOAD<>nil then PLILOAD.CreateGUI( PanPLIseries );
   if CDebug then logmsg('TFormPTCHardware.Initialize: done.');
end;


procedure TFormPTCHardware.AfterLoad;
begin
   //update potentio selection  = will do init
   CBSelectPTC.OnChange(nil);
   fInitialized := true;
   if CDebug then logmsg('TFormPTCHardware.AfterLoad: done.');
end;



procedure TFormPTCHardware.ConfigLoad;
Var
 brstr: string;
 kolregs: TKolPTCRegisterConfig;
 kolchans: TKolPTCChannelConfig;

begin
  logmsg('  TFormPTCHardware.ConfigLoad: start.');
 //general form variable
  HWFormRefreshIntv.Text := IntToStr( fConfClient.Load('RefreshInt', 1001) );
  ChkAutoRefresh.Checked := fConfClient.Load('Autorefresh', true);

  //kolptc

  CBKolPTCUFB.ItemIndex := fConfClient.Load('fUFBitemindex', 0 );
  CBKolPTCIFB.ItemIndex := fConfClient.Load('fIFBitemindex', 0 );
   CBKolPTCRng.ItemIndex := fConfClient.Load('fRangeitemindex', 0 );
   CBKolSelectFB.ItemIndex := fConfClient.Load('fSelFBitemindex', 0 );
   EKolRetryCnt.Text := fConfClient.Load('fKolRetryCntText', '' );
   EKolNewSetp.Text := fConfClient.Load('fKolNewSetpText', '' );
   EKolPTCV4RngMin.Text := fConfClient.Load('fKolV4RngMinText', '' );
   EKolPTCV4RngMax.Text := fConfClient.Load('fKolV4RngMaxText', '' );
  //PTC sel
   CBSelectPTC.ItemIndex := fConfClient.Load( 'PTCSelIndex', 0   );
  //window pos
  fwindowtop := fConfClient.Load( 'fwindowtop', 0 );
  fwindowheight := fConfClient.Load(  'fwindowheight', 790 );
  fwindowleft  := fConfClient.Load(  'fwindowleft', 0 );
  fwindowwidth := fConfClient.Load(  'fwindowwidth', 900 );


   //
   //ptcform window position restore
    FormPTCHardware.SetBounds(fwindowleft, fwindowtop, fwindowwidth, fwindowheight);



   if CDebug then logmsg('    readkolptc');
   if KolPTC<>nil then
     begin
       //ShowMessage( 'KolPTC? ' + PointerToStr(kolPTC) );
       ChkKolPTCBufferedRead.checked := true; //kolPTC.BufferedRead;
       //ShowMessage( 'KolPTC after');
     end;
   //
   if CDebug then logmsg('   load ini for owned objects');
   if KolPTC<>nil then kolPTC.LoadConfig;
   if DummyPTC<>nil then DummyPTC.LoadConfig;
   if bk8500PTC<>nil then bk8500PTC.LoadConfig;
   if M97xxLOAD<>nil then M97xxLOAD.LoadConfig;
   if ZS1806LOAD<>nil then ZS1806LOAD.LoadConfig;
   if PLILOAD<>nil then PLILOAD.LoadConfig;

   //
   //FILL EDIT boxes
   //kolptcregisters
   if KolPTC<>nil then
     begin
        if CDebug then logmsg('    readREG');
      kolregs := kolPTC.ConfigRegisters;
      kolchans := kolPTC.ConfigChannels;
       //config crc version
         if CDebug then logmsg('    readCRC');
      EKolFWVer.Text := KolPTC.FWVersionCRC;
     end;
   if CDebug then logmsg('    end readkolptc');
   EKolRegADC.Text := IntToStr( kolregs[CRegADC] );
   EKolV4R.Text := IntToStr( kolregs[CRegV4Range] );
   EKolRelOn.Text := IntToStr( kolregs[CRegRelayON] );
   EKolSetp.Text := IntToStr( kolregs[CRegSetpoint] );
   EKolRegSWFB.Text := IntToStr( kolregs[CRegSwFeedback] );
   EKolProtect.Text := IntToStr( kolregs[CRegProtectStatus] );
   EKolProtCMD.Text := IntToStr( kolregs[CRegProtectCmd] );
   EKolFuseSoft.Text := IntToStr( kolregs[CRegLimSafe] );
   EKolFusehard.Text := IntToStr( kolregs[CRegLimHard] );
   //cahnnels
   EKolChV4.Text := IntToStr( kolchans[CChV4] );
   EKolChVref.Text := IntToStr( kolchans[CChVref] );
   EKolChV2.Text := IntToStr( kolchans[CChV2] );
   EKolChI.Text := IntToStr( kolchans[CChI] );
   EKolChI10.Text := IntToStr( kolchans[CChI10] );
   EKolChSP.Text := IntToStr( kolchans[CChSP] );

   //kolPTC - mark as CONFIGURED!!!
   if not (kolPTC=nil) then kolPTC.MarkAsConfigured;

   // kolregs := kolPTC.ConfigRegisters;
  //  ShowMessage( IntToStr( kolregs[CRegCRC] ) + ' |  ' + POinterToStr( @kolregs[CRegCRC] ) );
   logmsg('  TFormPTCHardware.ConfigLoad: done.');
end;


procedure TFormPTCHardware.ConfigSave;
Var
 iptcsel, ikolvoltfb, ikolcurrfb, ikolrng, iautoref: integer;
begin
 //general form variable
  fConfClient.Save('RefreshInt', StrToIntDef( HWFormRefreshIntv.Text, 1001) );
  fConfClient.Save('Autorefresh', ChkAutoRefresh.Checked);
  fConfClient.Save('fUFBitemindex',CBKolPTCUFB.ItemIndex );
 fConfClient.Save('fIFBitemindex',  CBKolPTCIFB.ItemIndex );
   fConfClient.Save('fRangeitemindex', CBKolPTCRng.ItemIndex);
   fConfClient.Save('fSelFBitemindex', CBKolSelectFB.ItemIndex );
   fConfClient.Save('fKolRetryCntText', EKolRetryCnt.Text );
  fConfClient.Save('fKolNewSetpText', EKolNewSetp.Text  );
   fConfClient.Save('fKolV4RngMinText', EKolPTCV4RngMin.Text );
   fConfClient.Save('fKolV4RngMaxText', EKolPTCV4RngMax.Text );
  //PTC sel
   fConfClient.Save( 'PTCSelIndex', CBSelectPTC.ItemIndex   );
  //window pos
  fConfClient.Save( 'fwindowtop', fwindowtop );
  fConfClient.Save(  'fwindowheight',fwindowheight );
   fConfClient.Save(  'fwindowleft', fwindowleft );
  fConfClient.Save(  'fwindowwidth',fwindowwidth );

   //save embeded objects
   if KolPTC<>nil then kolPTC.SaveConfig;
   if DummyPTC<>nil then DummyPTC.SaveConfig;
   if bk8500PTC<>nil then bk8500PTC.SaveConfig;
   if M97xxLOAD<>nil then M97xxLOAD.SaveConfig;
   if ZS1806LOAD<>nil then ZS1806LOAD.SaveConfig;
   if PLILOAD<>nil then PLILOAD.SaveConfig;


end;


procedure TFormPTCHardware.ConfigDefault;
begin
   CBSelectPTC.ItemIndex := 1;
   CBKolPTCUFB.ItemIndex := 0;
   CBKolPTCIFB.ItemIndex := 0;
   CBKolPTCRng.ItemIndex := 0;
   ChkAutoRefresh.Checked := true;
   CBBKRemoteSense.Checked := true;
end;





procedure TFormPTCHardware.ButtonHideClick(Sender: TObject);
begin
  FormPTCHardware.Hide;
  HWFormTimer.Enabled := false;
end;



procedure TFormPTCHardware.CBSelectPTCChange(Sender: TObject);
Var
  i:integer;
  b: boolean;
begin
  if CDebug then logmsg('THardwareForm in PTC change');
  //update reference to active PTC
  i := CBSelectPTC.ItemIndex;
  if i = 0 then PTC := kolPTC;
  if i = 1 then PTC := dummyPTC;
  if i = 2 then PTC := bk8500PTC;
  if i = 3 then
    begin
       if M97xxLOAD=nil then M97xxLOAD := TM97XX_PTCInterface.Create;
       PTC := M97xxLOAD;
    end;
  if i = 4 then
    begin
       if ZS1806LOAD=nil then ZS1806LOAD := TZS1806_PTCInterface.Create;
       PTC := ZS1806LOAD;
    end;
  if i = 5 then
    begin
       if PLILOAD=nil then PLILOAD := TPLIseries_PTCInterface.Create;
       PTC := PLILOAD;
    end;

  //!!!!!!!!!!!  INITIALIZE PTC if not yet done
  if pTC=nil then
    begin
      ShowMessage('PTC nema byt nil');
      logerror('PTC nema byt nil');
      exit;
    end;
   //  !!!important
  if MainHWInterface=nil then
    begin
      logerror('TFormPTCHardware.CBSelectPTCChange: nekde je chybka - MainHWInterface=nil');
      exit;
    end;
  MainHWInterface.PtcDevAssign(PTC);  //!!!! necessary to update reference !!!!!
  //kolPTC specific PREinitialize!!!
   if i=0 then
     begin
       //kolPTC.V4RngRegister := StrToIntDef( EKolPTCV4Reg.Text, 47);
     end;
   //
   try
     //if (not PTC.IsReady) then  b := PTC.Initialize;
   except
     on E: Exception do begin ShowMessage('PTC exception in initialize ' + E.message) end;
   end;
   ////KolPTC specific initialize
   if i=0 then
     begin
     //KolPTC specific
       if (kolPTC.IsReady) then
         begin
          CBKolPTCUFB.OnChange(nil);
          CBKolPTCIFB.OnChange(nil);
          CBKolPTCRng.OnChange(nil);
         end;
     end;

  if b then logmsg('THardwareForm init true') else logmsg('THardwareForm init false');
  //if CDebug then ShowMessage('tu PTCChange');
end;

procedure TFormPTCHardware.HWFormRefreshIntvChange(Sender: TObject);
begin
  HWFormTimer.Interval :=  StrToIntDef( HWFormRefreshIntv.Text, 1000);
end;

procedure TFormPTCHardware.FormShow(Sender: TObject);
begin
  HWFormTimer.Enabled := ChkAutoRefresh.Checked;
  //ptcform window position restore
  FormPTCHardware.SetBounds(fwindowleft, fwindowtop, fwindowwidth, fwindowheight);
end;

procedure TFormPTCHardware.FormHide(Sender: TObject);
begin
  HWFormTimer.Enabled := False;
end;

procedure TFormPTCHardware.HWFormTimerTimer(Sender: TObject);
begin
   if not FormPTCHardware.Visible then exit;
   try
     RefreshKolPTCStatus;
     //logmsg('timer: call dummy refresh status');
     RefreshDummyPTCStatus;
     //logmsg('timer: out dummy refresh status');
     RefreshBK8500PTCStatus;
     //logmsg('timer: out bk8500 refresh status');
     RefreshM97xx;

     RefreshZS1806;

     RefreshPLILOAD;
   except
     on E: exception do begin logmsg('Got exception during ptc refresh ' + E.message); end;
   end;
end;

procedure TFormPTCHardware.ButKolInitClick(Sender: TObject);
begin
  KolPTC.Initialize;
  CBKolPTCUFB.OnChange(Sender);
  CBKolPTCIFB.OnChange(Sender);
  CBKolPTCRng.OnChange(Sender);
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.ButKolFinalClick(Sender: TObject);
begin
  KolPTC.Finalize;
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.BuKolLoadDLLClick(Sender: TObject);
begin
  kolPTC.Connect;
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.CBKolPTCUFBChange(Sender: TObject);
begin
  fUFBitemindex := CBKolPTCUFB.ItemIndex;
  kolPTC.ConstUFeedback := TkolPTCFeedback( fUFBitemindex);
//  if fUFBitemindex = 0 then kolPTC.ConstUFeedback := CPTCFbV2;
//  if fUFBitemindex = 1 then kolPTC.ConstUFeedback := CPTCFbV4;
//  if fUFBitemindex = 2 then kolPTC.ConstUFeedback := CPTCFbVRef;
//  if fUFBitemindex = 3 then kolPTC.ConstUFeedback := TkolPTCFeedback(3);
//  if fUFBitemindex = 4 then kolPTC.ConstUFeedback := TkolPTCFeedback(4);
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.CBKolPTCIFBChange(Sender: TObject);
begin
  fIFBitemindex := CBKolPTCIFB.ItemIndex;
  kolPTC.ConstIFeedback := TkolPTCFeedback(fIFBitemindex);
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.CBKolSelectFBChange(Sender: TObject);
begin
  fSelFBitemindex := CBKolSelectFB.ItemIndex;
  if fSelFBitemindex = 0 then kolPTC.SetFeedback( CPTCFbV2 );
  if fSelFBitemindex = 1 then kolPTC.SetFeedback( CPTCFbV4 );
  if fSelFBitemindex = 2 then kolPTC.SetFeedback( CPTCFbVRef );
  if fSelFBitemindex = 3 then kolPTC.SetFeedback( CPTCFbI );
  if fSelFBitemindex = 4 then kolPTC.SetFeedback( CPTCFbIx10 );
  RefreshKolPTCStatus;
end;


procedure TFormPTCHardware.CBKolPTCRngChange(Sender: TObject);
begin
  fRangeitemindex := CBKolPTCRng.ItemIndex;
  if fRangeitemindex = 0 then kolPTC.SetRange( CPTCRng15A );
  if fRangeitemindex = 1 then kolPTC.SetRange( CPTCRng500mA );
  RefreshKolPTCStatus;
end;


procedure TFormPTCHardware.BuKolPTCSetSPClick(Sender: TObject);
Var
    d: double;
begin
  d := MyStrToFloatDef( EKolNewSetp.Text, 0.0);
  KolPTC.SetSetpoint(d);
  RefreshKolPTCStatus;
end;


procedure TFormPTCHardware.BuKolPTCResFuseClick(Sender: TObject);
begin
  KolPTC.ResetFuse;
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.BuKolPTCTurnONClick(Sender: TObject);
begin
  KolPTC.TurnLoadON;
  RefreshKolPTCStatus;
end;


procedure TFormPTCHardware.BuKolPTCTurnOFFClick(Sender: TObject);
begin
  KolPTC.TurnLoadOFF;
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.ChkKolPTCBufferedReadClick(Sender: TObject);
begin
  kolPTC.BufferedRead :=  ChkKolPTCBufferedRead.Checked ;
  RefreshKolPTCStatus;
end;


procedure TFormPTCHardware.RefreshKolPTCStatus;
Var
  fb: TKolPTCFeedback;
  rng: TKolPTCRange;
  kolregs: TKolPTCRegisterConfig;
  kolchans: TKolPTCChannelConfig;
  rrec: TPotentioRangeRecord;
  b: boolean;
  kolchdata: TKolPTCChannelData;
  kolst: TKolPTCStatus;
  kolexst: TKolPTCEXtendedStatus;
  i: integer;
  t0: TDateTime;
  flags: TPotentioFlagSet;
  ff: TPotentioFlags;
  protstatr: byte;
  HWcrc: string;
begin
    //logmsg('in refresh kolptc status');
   //beginupdate
    //kolPTC -------------------
    LaKolIfaceInfo.Caption := CKolPtcIfaceVerLong;
    //default vals
    ChkKolAvailable.Checked := false;
    ChkKolReady.Checked := false;
    ChkKolRelayOn.Checked := false; ChkKolRelayOn.Enabled := false;
    ChkKolFuse.Checked := false; ChkKolFuse.Enabled := false;
    PanKolLastOCV.Caption := '---';
    PanKolSetpoint.Caption := '---';
    PanKolProtV4Rng.Caption := '---';
    RBKolPTCr1.Checked := false;
    RBKolPTCr2.Checked := false;
    RBKolPTCV2.Checked := false;
    RBKolPTCV4.Checked := false;
    RBKolPTCVRef.Checked := false;
    RBKolPTCI.Checked := false;
    RBKolPTCIx10.Checked := false;
    MeKolChannels.Lines.Clear;
    PanKolAquireTime.Caption := '---';
  if kolPTC = nil then
    begin
      LKolptcHWstr.Caption := 'KolPTC=nil!!!';
      exit;
    end;
  ChkKolConfigured.Checked := KolPTC.IsRegConfigured;
  ChkKolDllloaded.Checked := KolPTC.IsTCPConfigured;
  //update interface status
  HWcrc := '';
  b := KolPTC.ReadRegCRC(HWcrc);      //!!!!!TODO
  if not b then HWcrc := 'FAIL';
  PanKolFwId.Caption := HWcrc;
  //
  kolregs := kolPTC.ConfigRegisters;
  kolchans := kolPTC.ConfigChannels;
  PanKolLastOCV.Caption := FloatToStrF(kolPTC.LastOCV, ffFixed,7,3);
  rrec := kolPTC.RngVoltageRec;
  PanKolVRange.Caption := PTCRangeRecordToStr( rrec , 'V');
  rrec := kolPTC.RngCurrentRec;
  PanKolIRange.Caption := PTCRangeRecordToStr( rrec, 'A');
  ChkKolPTCBufferedRead.checked := kolPTC.BufferedRead;
  PanKolConstUFB.Caption :=  kolPTC.KolFBToStr( KolPTC.ConstUFeedback );
  PanKolConstIFB.Caption :=  kolPTC.KolFBToStr( KolPTC.ConstIFeedback );
  PanKolRetryCnt.Caption :=  IntToStr( KolPTC.RetryCount );
  ChkKolUseVrefInsteadOfV4.Checked := kolPTC.UseVrefInsteadOfV4;

  //
  EKolFWVer.Text := kolPTC.FWVersionCRC;
  PanKolRegADC.Caption := IntToStr( kolregs[CRegADC] );
  PanKolV4R.Caption := IntToStr( kolregs[CRegV4Range] );
  PanKolRelOn.Caption := IntToStr( kolregs[CRegRelayON] );
  PanKolSetp.Caption := IntToStr( kolregs[CRegSetpoint] );
  PanKolRegSWFB.Caption := IntToStr( kolregs[CRegSwFeedback] );
  PanKolProtect.Caption := IntToStr( kolregs[CRegProtectStatus] );
  PanKolFuseSafe.Caption := IntToStr( kolregs[CRegLImSafe] );
  PanKolFuseHard.Caption := IntToStr( kolregs[CRegLimHard] );
  PanKolPROTcmd.Caption := IntToStr( kolregs[CRegProtectCmd] );
  PanKolChV4.Caption :=  IntToStr( kolchans[CChV4] );
  PanKolChVref.Caption :=  IntToStr( kolchans[CChVref] );
  PanKolChV2.Caption :=  IntToStr( kolchans[CChV2] );
  PanKolChI.Caption :=  IntToStr( kolchans[CChI] );
  PanKolChI10.Caption := IntToStr( kolchans[CChI10] );
  PanKolChSP.Caption := IntToStr( kolchans[CChSP] );
  //comm err counters
  PanKolCommCnt.Caption := IntToStr( kolPTC.CommCntTotal );
  PanKolCommErr.Caption := IntToStr( kolPTC.CommCntErrCorrected );
  PanKolCommErrNotFixed.Caption := IntToStr( kolPTC.CommCntErrNotCorr );
  //list any active flags
  flags := kolPTC.Flags;
  if flags<>[] then MeKolChannels.Lines.Add('Activated flags: ');
  for ff := low( TPotentioFlags) to high( TPotentioFlags) do
    if ff in flags then MeKolChannels.Lines.Add('Flag' + IntToStr( Ord(ff) ) );
  //
  //update PTC hardware status
  if not kolPTC.IsAvailable() then
  begin
    LKolptcHWstr.Caption := 'PTC not AVAILABLE!!!';
    exit;
  end;
  ChkKolAvailable.Checked := true;
  LKolptcHWstr.Caption := KolPTC.GetHWIdstr;
  //
  if not kolPTC.IsReady then
  begin
    MeKolChannels.Lines.Add(' PTC NOT READY ');
    exit;
  end;
  ChkKolReady.Checked := true;
  //ptc is ready, so can aquire
  //aquire data and extended status
  t0 := Now;
  b := KolPTC.ReadPTCServer(kolchdata, kolst);
  if not b then MeKolChannels.Lines.Add('Failed call: KolPTC.ReadPTCServer');
  b :=  KolPTC.ReadPTCStatusExtended(kolexst);
  if not b then MeKolChannels.Lines.Add('Failed call: KolPTC.ReadPTCStatusExtended');
  //b :=  KolPTC.ReadRegFuse(protstatr);
  //if not b then MeKolChannels.Lines.Add('Failed call: KolPTC.ReadRegFuse');
  //logmsg('in refresh kolptc status get data finished');
  //
  PanKolAquireTime.Caption := DateTimeMStoStr( TimeDeltaNow( t0 ) );
  ChkKolRelayOn.Checked := kolst.OutputOn;
   if kolst.OutputOn then ChkKolRelayOn.Enabled := true;
  ChkKolFuse.Checked := kolst.HWFuseActive;
  if kolst.HWFuseActive then ChkKolFuse.Enabled := true;
  PanKolSetpoint.Caption := FloatToStrF(kolst.setpoint, ffFixed,7,3);
  PanKolProtV4Rng.Caption := PTCRangeRecordToStr( kolexst.v4range );
  PanKolProtStat.Caption :=  IntToStr( kolexst.RegProtectStat );
  PanKolShowFuseSafe.Caption := DynArrayToStr( kolexst.RegFuse_safe );
  PanKolShowFuseHard.Caption := DynArrayToStr( kolexst.RegFuse_hard );
  //range, fb
  rng := KolPTC.InternalRngToKol( kolst.RangeRaw );
  fb :=  kolPTC.InternalFBToKol( kolst.FeedbackRaw );
  if rng = CPTCRng15A then  RBKolPTCr1.Checked := true;
  if rng = CPTCRng500mA then  RBKolPTCr2.Checked := true;
  if fb=CPTCFbV2 then RBKolPTCV2.Checked := true;
  if fb=CPTCFbV4 then RBKolPTCV4.Checked := true;
  if fb=CPTCFbVref then RBKolPTCVref.Checked := true;
  if fb=CPTCFbI then RBKolPTCI.Checked := true;
  if fb=CPTCFbIx10 then RBKolPTCIx10.Checked := true;
  //channels
{  for i:=0 to kolchdata.nAin -1 do
    begin
      MeKolChannels.Lines.Add( 'Ain'+ IntToStr( i ) + ': '+ FloatToStrF(kolchdata.Ain[i], ffFixed,7,3) + '(V)');
    end;
  for i:=0 to kolchdata.nAout -1 do
    begin
      MeKolChannels.Lines.Add( 'Aout'+ IntToStr( i ) + ': '+ FloatToStrF(kolchdata.Aout[i], ffFixed,7,3) + '(V)');
    end;
  }
  //logmsg('out refresh kolptc status');
end;


procedure TFormPTCHardware.RefreshDummyPTCStatus;
  procedure FillNaN;
  begin


  end;

Var
  rec: TPotentioRec;
  st: TPotentioStatus;
  b: boolean;
begin
  if DummyPTC = nil then
    begin
      ChkDumConf.Checked := false;
      exit;
    end;
  ChkDumConf.Checked := true;
  ChkDumAvail.Checked := DummyPTC.IsAvailable;
  ChkDumReady.Checked := DummyPTC.IsReady;
  //
  //parameters
  PanDumOCV.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumiR.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumXOver.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumTafel.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumMA.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumExC.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumSinDistAmp.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumRndNoiseAmp.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumDieOutRatio.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  //
  ChkDummyNoise.Checked := DummyPTC.fNoiseEnabled;
  ChkDummyDieOut.Checked := DummyPTC.fDieoutEnabled;
  ChkDummyCommError.Checked := DummyPTC.fCommErrorSimul;
  ChkDumFuse.Checked := DummyPTC.fFuseSimul;
 // data
  if not DummyPTC.IsReady then
    //fill nans and exit
    begin
    PanDumVolt.Caption := 'Not Ready';
    PanDumCurr.Caption := 'Not Ready';
    ChkDummyOuput.Checked := false;
    RBDummyFBV.Checked := false;
    RBDummyFBI.Checked := false;
    exit;
    end;
  //aquire
  DummyPTC.AquireDataStatus(rec, st);
  ChkDummyOuput.Checked := st.isLoadConnected;
  PanDumVolt.Caption := FloatToStrF( rec.U, ffFixed, 5,4);
  PanDumCurr.Caption := FloatToStrF( rec.I, ffFixed, 5,4);
  if st.mode = CPOtCC then b:= true else b:= false;
  RBDummyFBI.Checked := b;
  if st.mode = CPOtCV then b:= true else b:= false;
  RBDummyFBV.Checked := b;
end;



procedure TFormPTCHardware.RefreshBK8500PTCStatus;
begin
  if bk8500PTC=nil then
  begin
    EBKPort.Text := 'Not Initialized - NIL';
    exit;
  end;
  EBKPort.Text := bk8500PTC.getPortName;
  EBKBaudrate.Text := bk8500PTC.getBaudRate;
  CbBKPortOpened.Checked := bk8500PTC.isPortOpen;
  cbBKremotesense.Checked := bk8500PTC.BKremoteSenseOn;
  EBKTimeout.Text := IntToStr( bk8500PTC.BKtimeout );
  EBKErrCnt.Text := IntToStr( bk8500PTC.getErrCount );
  EBKOKCnt.Text := IntToStr( bk8500PTC.getOKCount );
  EBKLastSetp.Text := FloatToStr( bk8500PTC.getLastSp() );
  EBKLastMode.Text := PTCmodeToStr( bk8500PTC.GetLastMode );
  EBKLastU.Text := FloatToStr( bk8500PTC.lastU );
  EBKLastI.Text := FloatToStr( bk8500PTC.lastI );
  //
  if bk8500PTC.isReady then
   LaBKstatus.Caption :=' Ready'
  else
   LaBKstatus.Caption :=' not Ready';
  //error reporting
  //TODO:
end;

procedure TFormPTCHardware.RefreshM97xx;
begin
  if M97xxLOAD=nil then exit;
  M97xxLOAD.RefreshGUI;
end;

procedure TFormPTCHardware.RefreshZS1806;
begin
  if ZS1806LOAD=nil then exit;
  ZS1806LOAD.RefreshGUI;
end;

procedure TFormPTCHardware.RefreshPLILOAD;
begin
  if PLILOAD=nil then exit;
  PLILOAD.RefreshGUI;
end;


procedure TFormPTCHardware.WMExitSizeMove(var Message: TMessage);   //detect move, resize
begin
    fwindowtop := FormPTCHardware.Top;
    fwindowheight := FormPTCHardware.Height;
    fwindowleft := FormPTCHardware.Left;
    fwindowwidth := FormPTCHardware.Width;
end;



procedure TFormPTCHardware.ChkAutoRefreshClick(Sender: TObject);
begin
  HWFormTimer.Enabled := ChkAutoRefresh.Checked;
end;



procedure TFormPTCHardware.BuDummyDisconClick(Sender: TObject);
begin
//  dummyPTC.Disconnect;
end;

procedure TFormPTCHardware.BuDummyConClick(Sender: TObject);
begin
  dummyPTC.Initialize;
end;

procedure TFormPTCHardware.ChkDummyNoiseClick(Sender: TObject);
begin
  dummyPtc.fNoiseEnabled := ChkDummyNoise.Checked;
end;

procedure TFormPTCHardware.ChkDummyDieOutClick(Sender: TObject);
begin
  dummyPtc.fDieoutEnabled := ChkDummyDieOut.Checked;
end;

procedure TFormPTCHardware.buBKResetCntClick(Sender: TObject);
begin
  bk8500PTC.resetErrOKCounters;
end;

procedure TFormPTCHardware.buBKConfPortClick(Sender: TObject);
begin
   bk8500PTC.SetupComPort;
end;

procedure TFormPTCHardware.buBKopenPortClick(Sender: TObject);
begin
  bk8500PTC.OpenComPort;
end;

procedure TFormPTCHardware.buBKcloseportClick(Sender: TObject);
begin
  bk8500PTC.CloseComPort;
end;

procedure TFormPTCHardware.cbBKremotesenseClick(Sender: TObject);
begin
  bk8500PTC.BKremoteSenseOn := cbBKremotesense.Checked;
end;

procedure TFormPTCHardware.cbBKdebugClick(Sender: TObject);
begin
  bk8500PTC.Debug := cbBKdebug.Checked;
end;

procedure TFormPTCHardware.Button3Click(Sender: TObject);
Var
 AppDir: string;
begin
//   if GlobalConfig<>nil then AppDir :=  GlobalConfig.GlobAppDir
//   else AppDir := '.';
//   bk8500PTC.SaveComPortConf( AppDir + '\' + CHWFormComPortconfigfile );
end;

procedure TFormPTCHardware.EBKTimeoutChange(Sender: TObject);
begin
  //bk8500PTC.BKtimeout := StrToIntDef( EBKTimeout.Text, 0);
  //bk8500PTC.ComPortsetTimeouts( bk8500PTC.BKtimeout );
end;

procedure TFormPTCHardware.BuBKpingClick(Sender: TObject);
Var
  s, s2 : string;
begin
//  s := bk8500PTC.bkPing;
//  EBKPing.Text := DateTimeToStr(Now)+ ' | ' + s;
end;

procedure TFormPTCHardware.Button1Click(Sender: TObject);
begin
//  ShowMessage( bk8500PTC.getporttimeouts );
end;



procedure TFormPTCHardware.BuKolPTCSetV4RngClick(Sender: TObject);
Var
  d1, d2: double;
begin
  d1 := MyStrToFloatDef( EKolPTCV4RngMin.Text, 0.0);
  d2 := MyStrToFloatDef( EKolPTCV4RngMax.Text, 0.0);
  KolPTC.SetSafetyRangeV4( d1, d2);
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.BuKolV4RClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegV4Range, StrToIntDef( EKolV4R.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolRelOnClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegRelayON, StrToIntDef( EKolRelOn.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolSetpClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegSetpoint, StrToIntDef( EKolSetp.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolProtectClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegProtectStatus, StrToIntDef( EKolProtect.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolProtCMDClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegProtectCmd, StrToIntDef( EKolProtCMD.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolChV4Click(Sender: TObject);
begin
  kolPTC.setupChannelConfig( CChV4, StrToIntDef( EKolChV4.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolChVrefClick(Sender: TObject);
begin
  kolPTC.setupChannelConfig( CChVref, StrToIntDef( EKolChVref.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolChV2Click(Sender: TObject);
begin
  kolPTC.setupChannelConfig( CChV2, StrToIntDef( EKolChV2.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolChIClick(Sender: TObject);
begin
  kolPTC.setupChannelConfig( CChI, StrToIntDef( EKolChI.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolChI10Click(Sender: TObject);
begin
  kolPTC.setupChannelConfig( CChI10, StrToIntDef( EKolChI10.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolChSPClick(Sender: TObject);
begin
  kolPTC.setupChannelConfig( CChSp, StrToIntDef( EKolChSp.Text, 0 ) );
end;



procedure TFormPTCHardware.BuKolSetConstUClick(Sender: TObject);
begin
  KolPTC.SetFeedback( KolPTC.ConstUFeedback );
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.BuKolSetConstIClick(Sender: TObject);
begin
  KolPTC.SetFeedback( KolPTC.ConstIFeedback );
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.BuKolSetRetryClick(Sender: TObject);
Var
  i: integer;
begin
  i := StrToIntDef( EKolRetryCnt.Text, 1);
  KolPTC.RetryCount := i;
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.EKolRetryCntChange(Sender: TObject);
begin
  fKolRetryCntText := EKolRetryCnt.Text;
end;

procedure TFormPTCHardware.EKolNewSetpChange(Sender: TObject);
begin
  fKolNewSetpText := EKolNewSetp.Text;
end;

procedure TFormPTCHardware.EKolPTCV4RngMinChange(Sender: TObject);
begin
  fKolV4RngMinText := EKolPTCV4RngMin.Text;
end;

procedure TFormPTCHardware.EKolPTCV4RngMaxChange(Sender: TObject);
begin
  fKolV4RngMaxText := EKolPTCV4RngMax.Text;
end;

procedure TFormPTCHardware.ChkKolDebugClick(Sender: TObject);
begin
  KolPTC.DebugEnabled := ChkKolDebug.Checked;
end;

procedure TFormPTCHardware.BuKolFuseSoftClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegLimSafe, StrToIntDef( EKolFuseSoft.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolFuseHardClick(Sender: TObject);
begin
    kolPTC.setupRegConfig( CRegLimHard, StrToIntDef( EKolFuseHard.Text, 0 ) );
end;

procedure TFormPTCHardware.BuKolRegADCClick(Sender: TObject);
begin
    kolPTC.setupRegConfig( CRegADC, StrToIntDef( EKolRegADC.Text, 0 ) );
end;

procedure TFormPTCHardware.Button5Click(Sender: TObject);
begin
   kolPTC.FWVersionCRC := PanKolFWId.Caption;
end;

procedure TFormPTCHardware.BuKolRegSWFBClick(Sender: TObject);
begin
  kolPTC.setupRegConfig( CRegSwFeedback, StrToIntDef( EKolRegSWFB.Text, 0 ) );
end;

procedure TFormPTCHardware.chkDumEnFuseClick(Sender: TObject);
begin
  dummyPTC.fFuseSimul := TCheckBox( Sender ).checked;
end;

procedure TFormPTCHardware.chkDumEnSwLIMClick(Sender: TObject);
begin
  dummyPTC.fSoftLimSimul := TCheckBox( Sender ).checked;
end;

procedure TFormPTCHardware.Button6Click(Sender: TObject);
begin
   kolPTC.StartPTCServer;
end;

procedure TFormPTCHardware.Button7Click(Sender: TObject);
begin
   kolPTC.KillPTCServer;
end;

procedure TFormPTCHardware.Button8Click(Sender: TObject);
begin
  ShowMessage( IntToStr( kolPTC.GetPTCServerPID )) ;
end;

procedure TFormPTCHardware.Button9Click(Sender: TObject);
begin
   kolPTC.RequestRestartServer := true;
end;

procedure TFormPTCHardware.Button10Click(Sender: TObject);
begin
  ShowMessage( kolPTC.GetPTCServerAppPath ) ;
end;

procedure TFormPTCHardware.ChkKolUseVrefInsteadOfV4Click(Sender: TObject);
begin
  kolPTC.UseVrefInsteadOfV4 :=  ChkKolUseVrefInsteadOfV4.Checked ;
  RefreshKolPTCStatus;
end;

procedure TFormPTCHardware.Button11Click(Sender: TObject);
Var
  pid , c: longword;
  pn: string;
begin
  pid := kolPTC.GetPTCServerPID;
  pn := kolPTC.GetPTCServerAppPath;
  ShowMessage( IntToStr( pid) + ' ' + INtToStr(c) + ': ' + pn );
end;

end.





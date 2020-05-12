unit FormGlobalConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  MyThreadUtils, myutils, Logger, Inifiles, ConfigManager;


Const
  CDefaultGlobalConfigFile = 'config-global.ini';
  CGlobalSectionID = 'GlobalConfig';
  CHWConfigFile = 'config-HW.ini';
  CHWConfigFileV2 = 'config-HW-v2.ini';
  CGeneralConfigFile = 'config-general.ini';
  CNumberDigitsCnt = 5;
  CPathSlash = '\';

  CNewLine = #13#10;

Type

  TMySignal = (CsigInit0Init, CsigInit1LoadConfig, CSigInit2AfterLoad,
              CSigBeforeSaveConfig, CSigSaveConfig, CSigGoingTerminate,
              CSigStartInitializeDevices, CSigDisconnectDevices,
              CSigProjectConfUpdated,
              CsigStopRequest,
              CSigDestroy=255);

  //the flow of events should be like this:
  //    0) Program starts, all objectgs are created with default ini setup, everything is disconnected, waiting
  //    1) signal to load configuration - every module loads config - after this, it should be able to provide services to other modules
  //    2) after load conf - to do interconnections between objects, hw is still in standby
  //    3)  CSigStartInitializeDevices - all devices shoudl try to become online
  //    RUN)  RUN, runtime signals
  //    4) when going to terminate, first sig before save config
  //     5) saveconfig
  //     end) program terinates

  // runtime signals
  //      projectupdate  = configuration has changed (after e.g. load project, or new project)


  //FORM GLobal config SHALL be created as the FIRST one, so overy other form can already register for broadcast signals during its CREATE!!!

  TBroadCastReceiveMethod = procedure(sig: TMySignal) of object;

  TTriState = (CTriOn, CTriOff, CTriUndef);

  TFormPositionRec = record   //
      //firstshow: boolean; //this is not stored into ini - but set to true on start
      vleft: TRegistryItem; //integer;
      vtop:  TRegistryItem;
      vwidth: TRegistryItem;
      vheight: TRegistryItem;
      vwindowstate: TRegistryItem;
      defleft: integer; //default will be set automatically according to "designed values"
      deftop: integer;
      defwidth: integer;
      defheight: integer;
      frmname: string;
      FormRef: TForm;   //use when saving conf to get parameters from the form
    end;


type
  TGlobalConfig = class(TForm)
    Label38: TLabel;
    Label1: TLabel;
    BuCancel: TButton;
    BuSaveFileCnt: TButton;
    Timer1: TTimer;
    LaGlobPath: TLabel;
    PanGlobAppDir: TPanel;
    ENewFileCnt: TEdit;
    EnewStaid: TEdit;
    Label2: TLabel;
    PanStaId: TPanel;
    PanGlobFileCnt: TPanel;
    BuSaveHomeDir: TButton;
    Label3: TLabel;
    PanAppPath: TPanel;
    Label4: TLabel;
    PanglobDataDir: TPanel;
    ENewDataDir: TEdit;
    BuSaveId: TButton;
    chkAutoInit: TCheckBox;
    chkTurnPTCOffZeroI: TCheckBox;
    chkReopenLastProj: TCheckBox;
    Button1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure BuSaveFileCntClick(Sender: TObject);
    procedure BuCancelClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure BuSaveHomeDirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BuSaveIdClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkAutoInitClick(Sender: TObject);
    procedure chkReopenLastProjClick(Sender: TObject);
    procedure chkTurnPTCOffZeroIClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  public
    function getGlobAppDir(): string;
    procedure setGlobAppDir( newdir: string);
    function getGlobDataDir(): string;
    procedure setGlobDataDir( newdir: string);
    function getGlobStationIDStr(): string;
    procedure setGlobStationIDStr( newdir: string);
    function getGlobFileCnt: longint;
    procedure setGlobFileCnt(cnt: longint);
  public
    //global signals - broadcasing - registration MAIN METHOD !!!!!!!!!!!
    function RegisterForBroadcastSignals(M: TBroadCastReceiveMethod): boolean;
    //
    //signal control methods
    procedure BroadCastSignal(sig: TMySignal);
    procedure RunStartupSequence; //menat to be called from main form/app modeule after all forms are created - it will signal load conf and initialize
    procedure BroadCastProjectUpdate;  //for each registred token, calls  "onprojectupdateproc" procedure;
    procedure RunSaveTerminateSequence;
  private
    //configuration INI manager
    fRegistry: TMyRegistryRootObject;
    //
    fConfigServerHW: TConfigServer;
    fConfigServerGeneral: TConfigServer;
    fConfigServerGlobalConfig: TConfigServer;
    //fConfigClient: TConfigClient;
    fFormatSettings: TFormatSettings;
    //
  private
    { Private declarations }
    fInitFlag: TMVVariantThreadSafe;
    //
    fGlobAppDir: string;
    fGlobDataDir: TRegistryItem;
    fGlobFileCnt: TRegistryItem; //fGlobFileCnt: longint;
    fGlobStationIDStr: TRegistryItem; //fGlobStationIDStr: string;
    fAutoInitDevices: TRegistryItem;
    fOnZeroCurrentTurnPTCOff: TRegistryItem;
  private
    function getMainRegSection: TMyRegistryNodeObject;
    function getInitflag: boolean;
    procedure setInitflag(b:  boolean);
    function getAutoInitDevices: boolean;
    function getReopenLastProject: boolean;
    function getAppVersionStr: string;
    function getLastProjectPath: string;
    procedure setLastProjectPath(s:  string);
    function getOnZeroCurrentTurnPTCOff: boolean;
    procedure setOnZeroCurrentTurnPTCOff(b:  boolean);
  public
    //REGISTRY!!!!
    property Registry: TMyRegistryRootObject read fRegistry;
    property GlobalRegistrySection: TMyRegistryNodeObject read getMainRegSection;
    property ConfigServerHW: TConfigServer read fConfigServerHW;
    property ConfigServerGeneral: TConfigServer read fConfigServerGeneral;
    //
    property FormatSettings: TFormatSettings read fFormatSettings;
    //
    //general configuration variables with aspect for whole application
    property globAppDir: string read getGlobAppDir write setGlobAppDir; //this variable will store path,
                         //where the application has been started (use for storing config files)
                        //should be set up after init of app by calling initialize method
    property globDataDir: string read getGlobDataDir write setGlobDataDir;
                         //dir, where new project directories should be created
    property globStationIDStr: string read getGlobStationIDStr write setGlobStationIDStr;
                 //1-3 letters identifying station - it is added to every file name as prefix
    property globFileCnt: longint read getGlobFileCnt write setGlobFileCnt;
    //
    property InitFlag: boolean read getInitflag write setInitflag;  //during program initialization - want to have different error handling
    //
    //
    property AutoInitDevices: boolean read  getAutoInitDevices;
    property ReopenLastProject: boolean read getReopenLastProject;
    property AppVersionStr: string read getAppVersionStr;
    //
    property LastProjectPath: string read getLastProjectPath write setLastProjectPath;
    property OnZeroCurrentTurnPTCOff: boolean read getOnZeroCurrentTurnPTCOff write setOnZeroCurrentTurnPTCOff;
    //property MakeSureLoadIsON: boolean read getMakeSureLoadIsON write setMakeSureLoadIsON;
    //
  public
  // general settings, NOT STORED into config file, mainly debug config
    dbgMeasureTime: boolean;
  public
    {File name generators!!!}
    //file name PREFIX is important to distinguis files from different stations + including file counter
    //(even in different projects from same staions, it is good idea to have uniqe file name for each of them
     //the file counter can be reset e.g. every new year, expect max about 10000 files per year
    function getNewFilePrefix: string;            //use this to 'peek' at curernt prefix with counter
    function getNewFilePrefixAndIncCnt: string;     //use this when creating new file - the global counter will be updated
    // IMportatnt these "getPath" functions returns path and not dir - result has appended backslash at the end!!!
    function getAppPath: string;
    function getDataPath: string;
  public
    { Public declarations }
    procedure Initialize;
    procedure SetUpAliases( RegObj: TMyRegistryRootObject; SecAliases: string; SecDevices: string);
    procedure LoadConfig;
    procedure SaveConfig;
    procedure RegisterFormPositionRec(frmname: string; frmref: TForm);
    function GetFormPositionRec(frmname: string; Var rec: TFormPositionRec): boolean;
    procedure UpdateFormPositionRec(frmname: string); //uses stored Form reference to update parameter values

    procedure UseFormPositionRec(modname: string; frm: TForm);  //tries to update given form parameters with stored values

  private
    //brodcasting signals storage
    fBroadcastList: array of TBroadCastReceiveMethod;
    fBroadcastListCount: longint;
    //
    //config manager for general use - user manualy defined configuration will be loaded at startup (inititlaize)
    // and stored before destruction of form - for now, there is only this simple static solution

    fFormNameList: TStringList;             //IndexOf
    fFormPositions: array[0..99] of TFormPositionRec;
    fFormPosItemsCount: longint;
    procedure ConfRegPositionRec(ind: integer);  //helper
    procedure UpdateFormPositionRecInd(ind: integer); //helper

  private
    procedure DefaultConfig;
    procedure RefreshForm;
  end;



procedure RestoreFormWindow( frm: TForm );


function IndicatorColorOrange( st: TTriState): TColor;
function IndicatorColorRed( st: TTriState): TColor;
function BoolToTriState(b: boolean): TTriState;



Const
//some user colors
  clOrange = $0000A5FF;   //TColor   $00BBGGRR
  clDarkOrange = $00008CFF;

//blinking user colors
  clBlinkRed0bg = clBtnFace;
  clBlinkRed0fg = clRed;
  clBlinkRed1bg = clRed;
  clBlinkRed1fg = clBlack;
  clBlinkOrange0bg = clBtnFace;
  clBlinkOrange0fg = clOrange;
  clBlinkOrange1bg = clOrange;
  clBlinkOrange1fg = clBlack;
  clBlinkGreen0bg = clBtnFace;
  clBlinkGreen0fg = clGreen;
  clBlinkGreen1bg = clGreen;
  clBlinkGreen1fg = clBlack;




var
  GlobalConfig: TGlobalConfig;

  RegistryHW: TMyRegistryRootObject;
  RegistryMainConfig: TMyRegistryNodeObject;
  //RegistryAliases: TMyRegistryRootObject;

  SecIdDevices: string = '__Devices';
  SecIdAliases: string = 'HWAliases';

  IdGlobFileCnt: string = 'GlobFileCnt';
  IdGlobDataHomeDir: string = 'GlobDataDir';
  IdGlobStationIDStr: string = 'GlobStationIDStr';
  IdAutoInitDevices: string = 'AutoInitDevices';
  IdOnZeroCurrentTurnPTCOff: string = 'OnZeroCurrentTurnPTCOff';
  IdMakeSureLoadIsON: string = 'MakeSureLoadIsON';
  IdReopenLastProject: string = 'ReopenLastProject';
  IdLastProjectPath: string = 'LastProjectPath';
  IdAppVersionStr: string = 'AppVersionStr';
  IdFormBatchBFleNameText: string = 'vFormBatchBFleNameText';
  IdForceEnglishDecimalSeparatorSetting: string = 'ForceEnglishDecimalSeparatorSetting';

  IdNormStackVoltageByNoOfCells: string = 'NormalizeStackVoltageByNoOfCells';
  IdNumberOfCellsInStack: string = 'NumberOfCellsInStack';

implementation

{$R *.dfm}



procedure TGlobalConfig.FormCreate;
begin
   GlobAppDir := GetCurrentDir +'';
   //
   fRegistry := TMyRegistryRootObject.Create;
   //
   fInitFlag := TMVVariantThreadSafe.Create( true );
   //
   fGlobDataDir := fRegistry.NewItemDef(CGlobalSectionID, IdGlobDataHomeDir, GlobAppDir);
   fGlobFileCnt := fRegistry.NewItemDef(CGlobalSectionID, IdGlobFileCnt, 1000);
   fGlobStationIDStr := fRegistry.NewItemDef(CGlobalSectionID, IdGlobStationIDStr, 'FCx');
   fAutoInitDevices := fRegistry.NewItemDef(CGlobalSectionID, IdAutoInitDevices, true);
   fOnZeroCurrentTurnPTCOff := fRegistry.NewItemDef(CGlobalSectionID, IdOnZeroCurrentTurnPTCOff, false);
   //
   DefaultConfig;
   //
   fFormPosItemsCount := 0;
   fFormNameList := TStringList.Create;
   fConfigServerHW := TConfigServer.Create;
   fConfigServerGeneral := TConfigServer.Create;
   fConfigServerGlobalConfig := TConfigServer.Create;
   //
   //internal config client
   //fConfigClient := TConfigClient.Create( fConfigServerGeneral, 'GlobalConfig');
   //
   GetLocaleFormatSettings(0, fFormatSettings);
   fFormatSettings.DecimalSeparator := '.';
   //
   SetLength( fBroadcastList, 100); //intial size
   fBroadcastListCount := 0;
   logmsg('TGlobalConfig.FormCreate done.');
end;

procedure TGlobalConfig.FormDestroy(Sender: TObject);
begin
   Timer1.Enabled := false;

   fGlobDataDir := nil;
   fGlobFileCnt := nil;
   fGlobStationIDStr := nil;
   fAutoInitDevices := nil;
   fOnZeroCurrentTurnPTCOff := nil;


  SetLength( fBroadcastList, 0);
  //
  //fConfigClient.Destroy;
  //
  fFormNameList.Destroy;
  //
  fConfigServerHW.Destroy;
  fConfigServerGeneral.Destroy;
  fConfigServerGlobalConfig.Destroy;
  //
  fRegistry.Destroy;
  fInitFlag.Destroy;
  //
  RegistryHW.SaveAllToIni; //!!!!!!!!!!!!
end;


procedure TGlobalConfig.DefaultConfig;
begin
  fRegistry.NewItemDef(CGlobalSectionID, IdAppVersionStr, 'FC Control v2017 beta');
  fRegistry.NewItemDef(CGlobalSectionID, IdMakeSureLoadIsON, false);
  fRegistry.NewItemDef(CGlobalSectionID, IdReopenLastProject, true);
  fRegistry.NewItemDef(CGlobalSectionID, IdLastProjectPath, '');
  fRegistry.NewItemDef(CGlobalSectionID, IdFormBatchBFleNameText, '');
  fRegistry.NewItemDef(CGlobalSectionID, IdLastProjectPath, '');
  fRegistry.NewItemDef(CGlobalSectionID, IdForceEnglishDecimalSeparatorSetting, true);
  //
  //other config variables
  dbgMeasureTime := false;
end;




procedure TGlobalConfig.SetUpAliases( RegObj: TMyRegistryRootObject; SecAliases: string; SecDevices: string);
Var
  secAli: TMyRegistryNodeObject;
  secDevs: TMyRegistryNodeObject;
  i: longint;
  RI: TRegistryItem;
  newa: string;
begin
  if RegObj=nil then exit;
  secAli := RegObj.SectionExist(secAliases);
  secDevs := RegObj.GetOrCreateSection(secDevices);
  if (secAli=nil) or (secDevs=nil) then exit;
  for i := 0 to secAli.Count - 1 do
    begin
      RI := secAli.getItemById(i);
      if RI<>nil then secDevs.CreateAliasItem( RI.valStr, RI.Name); //???reversed registration !!!!!!!!!!
    end;
end;




procedure TGlobalConfig.Initialize;
begin
  fConfigServerHW.InitializeIni(getAppPath + CHWConfigFile );
  fConfigServerGeneral.InitializeIni( getAppPath + CGeneralConfigFile );
  fConfigServerGlobalConfig.InitializeIni(getAppPath + CDefaultGlobalConfigFile);
  if RegistryHW<>nil then
    begin
      RegistryHW.InitializeIni( getAppPath + CHWConfigFileV2 );
      SetUpAliases( RegistryHW, SecIdAliases, SecIdDevices);
    end;
  //if RegistryAliases<>nil then RegistryAliases.InitializeIni( getAppPath + CHWConfigFileV2 );
end;




procedure TGlobalConfig.LoadConfig;
Var
 Ini: TIniFile;
 s, p: string;
 bini: boolean;
 but: integer;
begin
   //
   s := getAppPath + CDefaultGlobalConfigFile;
   if fRegistry = nil then
   begin
     logmsg('GlobalConfig: LoadConfig: fConfigRegistry = nil');
     exit;
   end;
   //
   bini := fRegistry.InitializeIni(s);
   if not bini then
   begin
     logmsg('GlobalConfig: LoadConfig: INI file assign/create failed');
   end;
  //
  fRegistry.LoadAllfromIni;
  //
  chkAutoInit.Checked := getAutoInitDevices;
  chkTurnPTCOffZeroI.Checked := getOnZeroCurrentTurnPTCOff;
  chkReopenLastProj.Checked := getReopenLastProject;

  //check data dir exist and offer create

  if not DirectoryExists( globDataDir ) then
    begin
      but := messagedlg('DATA directory does not exist, create?', mtConfirmation, mbOKCancel, 0);
      // Show the button type selected
      if but = mrOK then
        begin
          MakeSureDirExist( globDataDir );
        end;
    end;
end;


procedure TGlobalConfig.SaveConfig;
Var
 Ini: TIniFile;
 i: integer;
begin
   //take care of storing form positon info
   //update actuall values to be stored
   for i:=0 to fFormPosItemsCount-1 do
   begin
     UpdateFormPositionRecInd( i );
   end;
   //
   //REGISTRY SAVE!!!
   if fRegistry<>nil then fRegistry.SaveAllToIni;
end;



function TGlobalConfig.RegisterForBroadcastSignals(M: TBroadCastReceiveMethod): boolean;
begin
  Result := false;
  if fBroadcastListCount >= length( fBroadcastList ) then
    begin
      setlength( fBroadcastList, length( fBroadcastList ) + 100 );
    end;
  //if resize failed
  if fBroadcastListCount >= length( fBroadcastList ) then
    begin
      logerror('TGlobalConfig.RegisterForBroadcastSignals: no more space');
      exit;
    end;
  fBroadcastList[ fBroadcastListCount ] := M;
  inc( fBroadcastListCount );
  logmsg( '  TGlobalConfig.RegisterForBroadcastSignals: new method registered ' + PointerToStr(@M) + ' now count ' + IntToStr(fBroadcastListCount) );
  Result := true;
end;


    //
    //signal control methods

procedure TGlobalConfig.BroadCastSignal(sig: TMySignal);
var i: longint;
begin
  logmsg( ' TGlobalConfig.BroadCastSignal: ' + IntToStr( ord (sig) ));
  if fBroadcastListCount<1 then exit;
  for i:=0 to fBroadcastListCount-1 do if assigned( fBroadcastList[i] ) then
    begin
      try
        fBroadcastList[i](sig);
      except
        on E: Exception do logerror( 'TGlobalConfig.BroadCastSignal: got error during method '+ PointerToStr(@fBroadcastList[i]) + ' sig: ' + IntToStr( ord (sig) ) + ' msg: ' + E.message);
      end;
    end;
end;


procedure TGlobalConfig.RunStartupSequence; //menat to be called from main form/app modeule after all forms are created - it will signal load conf and initialize
begin
  BroadCastSignal( CsigInit0Init );
  BroadCastSignal( CsigInit1LoadConfig );
  BroadCastSignal( CSigInit2AfterLoad );
end;


procedure TGlobalConfig.BroadCastProjectUpdate;  //for each registred token, calls  "onprojectupdateproc" procedure;
begin
  BroadCastSignal( CSigProjectConfUpdated );
end;

procedure TGlobalConfig.RunSaveTerminateSequence;
begin
  Timer1.Enabled := false;
  BroadCastSignal( CSigBeforeSaveConfig );
  BroadCastSignal( CSigSaveConfig );
  BroadCastSignal( CSigDisconnectDevices );
end;




procedure TGlobalConfig.RegisterFormPositionRec(frmname: string; frmref: TForm);
Var
 ind: integer;
 namecopy, section, s: string;
 ri: TRegistryItem;
begin
  namecopy := frmname + '';
  section := 'FormPositions';
  if fFormNameList=nil then exit;
  ind := fFormNameList.IndexOf( namecopy );
  if ind=-1 then
    begin
      if fFormNameList.Count>=99 then
        begin
          logwarning('TGlobalConfig.RegisterFormPositionRec Too many forms to register config!');
          exit;
        end;
      //SetLength( fFormPositions, fFormPosItemsCount);
      fFormNameList.Add( namecopy );
      fFormPosItemsCount := fFormNameList.Count;
    end;
    ind := fFormNameList.IndexOf( namecopy );                              //tform
    if ind<0 then exit;
    // get defaults
      if (frmref<>nil)then
        begin
          //get default values from form (because now there is the designed value stored there
          //ShowMessage( IntToStr(frmref.left) + ' ' + IntToStr(frmref.width) );
          with fFormPositions[ind] do             //FDESIGNSIZE
            begin
              defleft:= frmref.left;
              deftop:= frmref.top;
              defwidth:= frmref.width;
              defheight:= frmref.height;
            end;
        end
      else
        begin
          with fFormPositions[ind] do             //FDESIGNSIZE
            begin
              defleft:= 100;
              deftop:= 100;
              defwidth:= 500;
              defheight:= 500;
            end;
        end;
    //register vars

    with fFormPositions[ind] do             //FDESIGNSIZE
      begin

         frmname := namecopy;
         FormRef := frmref;
         s := namecopy+'_left';
         ri := fRegistry.NewItemDef(section, s, defleft);
         vleft := ri;
         vtop := fRegistry.NewItemDef(section, namecopy+'_top', deftop);
         vwidth := fRegistry.NewItemDef(section, namecopy+'_width', defwidth);
         vheight := fRegistry.NewItemDef(section, namecopy+'_height', defheight);
         vwindowstate := fRegistry.NewItemDef(section, namecopy+'_windowstate', Integer( wsNormal ) );
      end;
end;


function TGlobalConfig.GetFormPositionRec(frmname: string; Var rec: TFormPositionRec): boolean;
Var
 ind: integer;
begin
  Result := false;
  if fFormNameList=nil then exit;
  ind := fFormNameList.IndexOf( frmname );
  if ind=-1 then exit;
  rec := fFormPositions[ind];
  Result := true;
end;


procedure TGlobalConfig.UpdateFormPositionRec(frmname: string); //uses stored Form reference to update parameter values
Var
 ind: integer;
begin
  if fFormNameList=nil then exit;
  ind := fFormNameList.IndexOf( frmname );
  if ind=-1 then exit;
  UpdateFormPositionRecInd( Ind );
end;


procedure TGlobalConfig.UpdateFormPositionRecInd(ind: integer); //uses stored Form reference to update parameter values
Var
 frm: TForm;
begin
  if (ind<0) or (ind>=fFormPosItemsCount) then exit;
  frm := fFormPositions[ind].FormRef;
  if frm = nil then exit;
  with fFormPositions[ind] do
   begin
     vleft.valint := frm.Left;
     vtop.valint := frm.Top;
     vWidth.valint := frm.Width;
     vHeight.valint := frm.Height;
     vwindowstate.valint := Integer(frm.WindowState);
   end;
end;


procedure TGlobalConfig.ConfRegPositionRec(ind: integer);  //internal helper
begin
end;


procedure TGlobalConfig.UseFormPositionRec(modname: string; frm: TForm);  //tries to update given form parameters with stored values
Var
  rec: TFormPositionRec;
begin
  if frm=nil then exit;
  if GetFormPositionRec(modName, rec) then
    begin
      if (rec.vleft=nil) or (rec.vtop=nil) or (rec.vheight=nil) or (rec.vwidth=nil)
          or (rec.vwindowstate=nil) then exit;
      frm.SetBounds( rec.vleft.valint, rec.vtop.valint, rec.vwidth.valint, rec.vheight.valint);
      frm.WindowState := TWindowState( rec.vwindowstate.valint );
    end;
end;



function TGlobalConfig.getMainRegSection: TMyRegistryNodeObject;
begin
  Result := fRegistry.GetOrCreateSection(CGlobalSectionID);
end;


function TGlobalConfig.getAppPath: string;
begin
  Result := globAppDir + BackSlash;
end;

function TGlobalConfig.getDataPath: string;
begin
  Result := globDataDir + Backslash;
end;

function TGlobalConfig.getGlobAppDir(): string;
//!!!force copy of string instead of returning a refernence - want to avoid, that some other code will change this string
begin
  Result := fGlobAppDir + '';
end;

procedure TGlobalConfig.setGlobAppDir( newdir: string);
begin
  fGlobAppDir := newdir + '';  //!!!force copy of string instead of assigning a reference
end;

function TGlobalConfig.getGlobDataDir(): string;
//!!!force copy of string instead of returning a refernence - want to avoid, that some other code will change this string
begin
  Result := '';
  if fGlobDataDir=nil then exit;
  Result := fGlobDataDir.valStr;
end;

procedure TGlobalConfig.setGlobDataDir( newdir: string);
begin
  if fGlobDataDir=nil then exit;
  fGlobDataDir.valStr := newdir + '';  //!!!force copy of string instead of assigning a reference
end;

function TGlobalConfig.getGlobStationIDStr(): string;
//!!!force copy of string instead of returning a refernence - want to avoid, that some other code will change this string
begin
  if fGlobStationIDStr=nil then exit;
  Result := fGlobStationIDStr.valStr + '';
end;

procedure TGlobalConfig.setGlobStationIDStr( newdir: string);
begin
  if fGlobStationIDStr=nil then exit;
  fGlobStationIDStr.valStr := newdir + '';  //!!!force copy of string instead of assigning a reference
end;

function TGlobalConfig.getGlobFileCnt: longint;
begin
  if fGlobFileCnt=nil then exit;
  Result :=  fGlobFileCnt.valInt;
end;


procedure TGlobalConfig.setGlobFileCnt(cnt: longint);
begin
  if fGlobFileCnt=nil then exit;
  if cnt<0 then cnt := 0;
  fGlobFileCnt.valInt := cnt;
end;


function TGlobalConfig.getInitflag: boolean;
begin
  if fInitFlag=nil then exit;
  Result :=  fInitFlag.valBool;
end;

procedure TGlobalConfig.setInitflag(b:  boolean);
begin
  if fInitFlag=nil then exit;
  fInitFlag.valBool := b;
end;


function TGlobalConfig.getAutoInitDevices: boolean;
begin
  if fAutoInitDevices=nil then exit;
  Result :=  fAutoInitDevices.valBool;
end;


function TGlobalConfig.getReopenLastProject: boolean;
begin
  Result :=  fRegistry.GetOrCreateItem(CGlobalSectionID, IdReopenLastProject ).valBool;
end;

function TGlobalConfig.getAppVersionStr: string;
begin
  Result :=  fRegistry.GetOrCreateItem(CGlobalSectionID, IdAppVersionStr ).valStr;
end;

function TGlobalConfig.getLastProjectPath: string;
begin
  Result :=  fRegistry.GetOrCreateItem(CGlobalSectionID, IdLastProjectPath ).valStr;
end;

procedure TGlobalConfig.setLastProjectPath(s:  string);
begin
  fRegistry.GetOrCreateItem(CGlobalSectionID, IdLastProjectPath ).valStr := s;
end;


function TGlobalConfig.getOnZeroCurrentTurnPTCOff: boolean;
begin
  if fOnZeroCurrentTurnPTCOff=nil then exit;
  Result :=  fOnZeroCurrentTurnPTCOff.valBool;
end;

procedure TGlobalConfig.setOnZeroCurrentTurnPTCOff(b:  boolean);
begin
  if fOnZeroCurrentTurnPTCOff=nil then exit;
  fOnZeroCurrentTurnPTCOff.valBool := b;
end;










function TGlobalConfig.getNewFilePrefix: string;
Var s: string;
begin
  s := AddLeadingZeroes( GlobFileCnt,  CNumberDigitsCnt);
  Result := GlobStationIDStr + '_' + s + '_';
end;

function TGlobalConfig.getNewFilePrefixAndIncCnt: string;
begin
  Result := getNewFilePrefix;
  fGlobFileCnt.valInt := fGlobFileCnt.valInt + 1;
end;




procedure TGlobalConfig.RefreshForm;
begin
  PanGlobAppDir.Caption := GlobAppDir;
  PanGlobDataDir.Caption := globDataDir;
  PanStaId.Caption := globStationIDStr;
  PanAppPath.Caption := getAppPath;
  PanGlobFileCnt.Caption := IntToStr( GlobFileCnt );
end;


procedure TGlobalConfig.BuSaveFileCntClick(Sender: TObject);
var i: longint;
begin
  i := StrToIntDef( ENewFileCnt.Text, 0);
  GlobFileCnt := i;
end;

procedure TGlobalConfig.BuCancelClick(Sender: TObject);
begin
  GlobalConfig.Hide;
end;

procedure TGlobalConfig.Timer1Timer(Sender: TObject);
begin
  if not Timer1.Enabled then exit;
  Timer1.Enabled := false;
  RefreshForm;
  Timer1.Enabled := true;
end;

procedure TGlobalConfig.FormShow(Sender: TObject);
begin
  Timer1.Enabled := true;
  EnewStaid.Text := globStationIDStr;
  ENewFileCnt.Text := IntToStr( globFileCnt );
end;

procedure TGlobalConfig.FormHide(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

procedure TGlobalConfig.BuSaveHomeDirClick(Sender: TObject);
begin
  GlobDataDir := ENewDataDir.Text;
end;



procedure TGlobalConfig.BuSaveIdClick(Sender: TObject);
begin
  GlobStationIDStr := EnewStaid.Text;
end;




procedure RestoreFormWindow( frm: TForm );
begin
  if frm.WindowState = wsMinimized then frm.WindowState := wsNormal;
  frm.Show;
end;


function IndicatorColorOrange( st: TTriState): TColor;
begin
  Result := clGray;
  case st of
    CTriOn: Result := clOrange;
    CTriOff: Result := clLime;
  end;
end;


function IndicatorColorRed( st: TTriState): TColor;
begin
  Result := clGray;
  case st of
    CTriOn: Result := clRed;
    CTriOff: Result := clLime;
  end;
end;

function BoolToTriState(b: boolean): TTriState;
begin
  if b then Result := CTriOn else Result := CTriOff;
end;



procedure TGlobalConfig.chkAutoInitClick(Sender: TObject);
begin
  //
end;

procedure TGlobalConfig.chkReopenLastProjClick(Sender: TObject);
begin
   //fReopenLastProject := chkReopenLastProj.Checked;
end;

procedure TGlobalConfig.chkTurnPTCOffZeroIClick(Sender: TObject);
begin
   OnZeroCurrentTurnPTCOff :=  chkTurnPTCOffZeroI.Checked;
end;





procedure TGlobalConfig.Button1Click(Sender: TObject);
Var
 sl: TStringList;
begin
  sl := TStringList.Create;
  RegistryHW.DumpIntoStringList( sl );
  ListBox1.Items.AddStrings( sl );
  sl.Destroy;
end;

Initialization

  RegistryHW := TMyRegistryRootObject.Create;
  RegistryMainConfig := RegistryHW.GetOrCreateSection( CGlobalSectionID );
  //RegistryAliases := TMyRegistryRootObject.Create;

Finalization

  //RegistryHW.SaveAllToIni;
  RegistryHW.Destroy;
  //RegistryAliases.Destroy;  //no save needed



end.





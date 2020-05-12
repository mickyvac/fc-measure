unit FormProjectControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  StrUtils, IniFiles,
  FormGlobalConfig, Logger, myutils, mvconversion,
  MyEditInterfaceHelper;

Const
  CDefaultProjectInfoFile = 'config-projdefaults.txt';

  CBCastListMax = 100;


type
  TMethod = procedure of object;


type
  TProjectControl = class(TForm)
    EProjName: TEdit;
    Label23: TLabel;
    BuSave: TButton;
    BuCancel: TButton;
    EProjDir: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EProjDesc: TEdit;
    Panel2: TPanel;
    Label32: TLabel;
    Panel3: TPanel;
    Label51: TLabel;
    CBAnodeMat: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    Panel4: TPanel;
    Label53: TLabel;
    CBMembrane: TComboBox;
    CBMea: TComboBox;
    Label54: TLabel;
    Panel5: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    Label52: TLabel;
    CBCathodeMat: TComboBox;
    Label56: TLabel;
    CBAnodeGDL: TComboBox;
    Label8: TLabel;
    CBCathodeGDL: TComboBox;
    Label2: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    CBCellType: TComboBox;
    CBCellArea: TComboBox;
    CBAnodeLoading: TComboBox;
    CBAnodeStoich: TComboBox;
    CBAnodeFlowMin: TComboBox;
    CBCathodeLoading: TComboBox;
    CBCathodeStoich: TComboBox;
    CBCathodeFlowMin: TComboBox;
    Label13: TLabel;
    LaProjPath: TLabel;
    Label14: TLabel;
    LaProjDate: TLabel;
    Label15: TLabel;
    Button1: TButton;
    Panel1: TPanel;
    CBFlowTracking: TCheckBox;
    Panel6: TPanel;
    Label16: TLabel;
    Label17: TLabel;
    CBInvertCurrent: TCheckBox;
    CBInvertVoltage: TCheckBox;
    Label18: TLabel;
    Label19: TLabel;
    CBCurrLimLow: TComboBox;
    CBCurrLimHigh: TComboBox;
    CBVoltLimLow: TComboBox;
    CBVoltLimHigh: TComboBox;
    Label1: TLabel;
    Label30: TLabel;
    CHKEditDisabled: TCheckBox;
    Label5: TLabel;
    cBNumberOfCellsStack: TComboBox;
    chkNormLotageByNoOfCells: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CBCellAreaChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CBInvertCurrentClick(Sender: TObject);
    procedure CBInvertVoltageClick(Sender: TObject);
    procedure CBFlowTrackingClick(Sender: TObject);
    procedure CBCellTypeChange(Sender: TObject);
    procedure CBAnodeMatChange(Sender: TObject);
    procedure CBAnodeGDLChange(Sender: TObject);
    procedure CBAnodeLoadingChange(Sender: TObject);
    procedure CBAnodeStoichChange(Sender: TObject);
    procedure CBAnodeFlowMinChange(Sender: TObject);
    procedure CBCathodeMatChange(Sender: TObject);
    procedure CBCathodeGDLChange(Sender: TObject);
    procedure CBCathodeLoadingChange(Sender: TObject);
    procedure CBCathodeStochChange(Sender: TObject);
    procedure CBCathodeFlowMinChange(Sender: TObject);
    procedure CBMembraneChange(Sender: TObject);
    procedure CBMeaChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CBCurrLimLowChange(Sender: TObject);
    procedure CBCurrLimHighChange(Sender: TObject);
    procedure CBVoltLimLowChange(Sender: TObject);
    procedure CBVoltLimHighChange(Sender: TObject);
    procedure EProjNameChange(Sender: TObject);
    procedure EProjDescChange(Sender: TObject);
    procedure BuSaveClick(Sender: TObject);
    procedure BuCancelClick(Sender: TObject);
    procedure cBNumberOfCellsStackChange(Sender: TObject);
  private
    { Private declarations }
    fProjDir: string;
    fProjIniPath: string;
    monitorupdateflag: boolean;
    flogmonitornotworking: boolean;
  public
    property logmonitornotworking: boolean read flogmonitornotworking write flogmonitornotworking;
  public
    procedure setProjDir(newdir: string);
    function getProjDir(): string;
    procedure setProjIniPath(newdir: string);
    function getProjIniPath(): string;
  public
    property ProjDir: string read getProjDir write setProjDir;
         //dir (=without last backslash) where are project related files are to be stored
    property ProjIniPath: string read getProjIniPath write setProjIniPath;
        //full path to project.ini file including the 'project.ini'
  public
    // Public declarations - project configuration - TODO: maybe convert to properties  in future
    ProjName: string;
    ProjChangeDisabled: boolean;   //do not allow editing of UNSPECIFIED project!!!
    ProjDesc: string;
    ProjCellArea: double;
    ProjAnodeDescr: string;
    ProjAnodeGDL: string;
    ProjAnodeLoading: double;
    ProjAnodeMinFlow: double;
    ProjAnodeStoich: double;
    ProjCathodeDescr: string;
    ProjCathodeGDL: string;
    ProjCathodeLoading: double;
    ProjCathodeMinFlow: double;
    ProjCathodeStoich: double;
    ProjMembrane: string;
    ProjMEApreparation: string;
    ProjCellType: string;
    ProjCreateDate: TDateTime;
    ProjInvertCurrent: boolean;
    ProjInvertVoltage: boolean;
    ProjFlowTracking: boolean;
    ProjUndervoltageProtect: boolean;
    ProjMaxCurrent: double;
    ProjMinCurrent: double;
    ProjMaxVoltage: double;
    ProjMinVoltage: double;
    //ProjLoggingEnabled: boolean;   //disable file writes - for transition to new directory when sel new project
  public
    function ProjParametersToStr: string;
  public
    function OpenProject( path: string; rememberproject: boolean=true): boolean;
    function OpenDefaultProject: boolean;
    function CreateNewProject( name: string; path: string): boolean;
    procedure CloseProject(opendefault:boolean=true);
    procedure RestoreLastProject;
  public
    function getProjPath(): string; //returns path leading into project dir =  project dir + backslash
    function genDefProjName( name: string): string;    //generates name for project directory using name, stationID and date
    function genProjFileFullPath( fname: string): string;   //param is fname, returned is full path + fname in current project directory
    //function genNewFilenamewithPathAndIncCnt( suffix: string): string;
    //function peekNewFilename( suffix: string);
  private //configuration storage
    procedure LoadFromDefault;  {tries to load default values from config file or sets program defaults when not possible to load}
    procedure SaveToDefault;
    function LoadProjectConfig( path: string ): boolean;
    function SaveProjectConfig: boolean;
    procedure SaveProjectConfigIni( ini: TIniFile );
    procedure LoadProjectConfigIni( ini: TIniFile );
  private
    procedure RefreshForm;
    procedure UpdateParams;
  public
    procedure setMonitorUpdateFlag;
    procedure clearMonitorUpdateFlag;
    function getMonitorUpdateFlag: boolean;
  private
    broadcastlist: array of TMethod;
    bcastcount: integer;
  public
    procedure BroadCastProjectUpdate;  //for each registred token, calls  "onprojectupdateproc" procedure;
    function RegOnProjectUpdateMethod(pM: TMethod): boolean;
  end;

var
  ProjectControl: TProjectControl;

implementation

uses FormHWAccessControlUnit;

{$R *.dfm}

procedure TProjectControl.FormCreate(Sender: TObject);
begin
  //LoadDefault;
  bcastcount := 0;
  setlength( broadcastlist, CBCastListMax);
  Panel3.Color := clVeryLightRed;
  Panel5.Color := clVeryLightBlue;
  logmsg('asigning controls.');

  INterfaceHelper.AssignControl( chkNormLotageByNoOfCells, RegistryMainConfig, IdNormStackVoltageByNoOfCells);
  logmsg('ProjectControl.FormCreate done.');
end;



procedure TProjectControl.setProjDir( newdir: string);
begin
  fProjDir := newdir + '';
end;

function TProjectControl.getProjDir(): string;
//!!!force copy of string instead of returning a refernence - want to avoid, that some other code will change this string
begin
  Result := fProjDir + '';
end;

procedure TProjectControl.setProjIniPath(newdir: string);
//!!!force copy of string instead of assigning a reference
begin
  fProjIniPath := newdir + '';
end;

function TProjectControl.getProjIniPath(): string;
//!!!force copy of string instead of returning a refernence - want to avoid, that some other code will change this string
begin
  Result := fProjIniPath + '';
end;

function TProjectControl.getProjPath(): string; //returns path leading into project dir =  project dir + backslash
begin
  Result := fProjDir + CPathSlash;
end;

function TProjectControl.OpenProject( path: string; rememberproject: boolean=true): boolean;
Var
  b: boolean;
begin
  //expecting that it can overwrite variables (path) even though open will fail!!!
  Result := false;
  if not FileExists( path ) then
    begin
      exit;
      logmsg('TProjectControl.OpenProject: path does not exist');
      ShowMessage('TProjectControl.OpenProject: path does not exist');
    end;
  b := LoadProjectConfig( path );
  if b then
    begin
      BroadCastProjectUpdate;
      GlobalConfig.BroadCastSignal( CSigProjectConfUpdated );
      if rememberproject then GlobalConfig.LastProjectPath := path;
    end;
  Result := b;
end;

function TProjectControl.OpenDefaultProject: boolean;
Var p: string;
    res: boolean;
begin
  Result := false;
  P := GlobalConfig.getDataPath + GlobalConfig.GlobStationIDStr + '-' + 'UnspecifiedProject'+ backslash + 'project.ini';
  //if project does not exist then create it !!!
  if  not fileexists(P) then
    begin
      logmsg('ProjectControlForm: OpenDefaultProject: does not exist - try to create dir and file');
      Result := CreateNewProject( 'Unspecified Project', P);
    end;
  //open
  Res := OpenProject( P );   //do not store as last porject to restore
  if not res then
    begin
      logmsg('ProjectControlForm: OpenDefaultProject: failed - even creating new default project');
       ShowMessage('Error - ProjectControlForm: OpenDefaultProject: failed - even creating new default project');
  end;
  Result := res;
end;


function TProjectControl.CreateNewProject( name: string; path: string): boolean;
Var b, bo: boolean;
    newdir: string;
begin
  //save current porject and close it, then load defaults and open new project(create file)
  Result := false;
  logmsg('ProjectControlForm: CreateNewProject: name: '+ name + ' path: ' + path);
  LoadFromDefault;
  ProjName := name;
  ProjIniPath := path;
  //check if directory and file exist - if not then create it
  newdir := ExtractFilePath(path);
  if not DirectoryExists(newdir) then
    begin
    //create directory
       MakeSureDirExist( newdir );
       logmsg('ProjectControlForm: CreateNewProject: try to crfeate dir: ' + newdir);
       if not DirectoryExists(newdir) then //if not CreateDir(newdir) then
         begin
         logerror('ProjectControlForm: CreateNewProject: create dir failed');
         ShowMessage('Error - ProjectControlForm: CreateNewProject: create dir failed');
         exit;
         end;
    end;
  //if file exists then warn!
  if  fileexists(path) then
  begin
    logerror('ProjectControlForm: CreateNewProject: project.ini already exists - exiting');
    exit;
  end;
  b := SaveProjectConfig;
  if b then
    begin
      logmsg('ProjectControlForm: CreateNewProject: successfully saved');
      logmsg('ii TProjectControl.CreateNewProject: now opening newly created project...');
      bo := OpenProject(path);
      if bo then logmsg('ii TProjectControl.CreateNewProject: open success, now everthing fnished!')
      else logwarning(' TProjectControl.CreateNewProject: open newly created failed - but you can retry ...');
      Result := bo;
    end
  else
    begin
      logmsg('ii TProjectControl.CreateNewProject: failed saving new project.ini');
    end;
end;

procedure TProjectControl.CloseProject(opendefault:boolean=true);
begin
  SaveProjectConfig;
  //TODO:!!!!!!  consider just inhibiting ALL project log write - do not open the default proj
  if opendefault then OpenDefaultProject;  //LoadFromDefault
end;


procedure  TProjectControl.RestoreLastProject;
begin
  if (GlobalConfig.ReopenLastProject) and (GlobalConfig.LastProjectPath <> '') then
    begin
      OpenProject( GlobalConfig.LastProjectPath );
    end
  else OpenDefaultProject;
end;




function TProjectControl.genProjFileFullPath( fname: string ): string;   //param is fname, returned is full path  + fname
//you should get and add to fname the project prefix manually
begin
  Result := ProjDir + fname;
end;




procedure TProjectControl.LoadFromDefault;
//reads default configuration, but does not actually assign new project directory and inifile
Var
 Ini: TIniFile;
 P: string;
begin
   P := GlobalConfig.getAppPath() + CDefaultProjectInfoFile;
   Ini :=  TINIFile.Create( P );
   if Ini = nil then
   begin
     logmsg('FormProjectControl: LoadFromDefault: INI file assign/create failed');
     exit;
   end;
   LoadProjectConfigIni( ini );
   Ini.Destroy;
end;

procedure TProjectControl.SaveToDefault;
Var
 Ini: TIniFile;
 P: string;
begin
   P := GlobalConfig.getAppPath + CDefaultProjectInfoFile;
   Ini :=  TINIFile.Create(P);
   if Ini = nil then
   begin
     logmsg('FormProjectControl: SaveToDefault: INI file assign/create failed');
     exit;
   end;
   SaveProjectConfigIni( ini );
   Ini.Destroy;
end;





function TProjectControl.LoadProjectConfig( path: string): boolean;
Var
 Ini: TIniFile;
begin
  Result := false;
  Ini :=  TINIFile.Create( path );
   if Ini = nil then
   begin
     logmsg('FormProjectControl: LoadCofnig: INI file assign/create failed');
     exit;
   end;
   try
     LoadProjectConfigIni( ini );
   except
    on E: Exception do logError('TProjectControl.LoadProjectConfig EXCEPTION: ' + E.message);
   end;

   Ini.Destroy;
   logmsg('FormProjectControl: LoadConfig: done.');
   //now succes - updatre project path and dir
   ProjIniPath := path;
   ProjDir := ExtractFileDir( path );       //ExtractFilePath
   //reset monitor file
   setMonitorUpdateFlag;
   LogMsg('Monitor log (re)start');
   Result := true;
end;


function TProjectControl.SaveProjectConfig: boolean;
Var
 Ini: TIniFile;
begin
   Result := false;
   Ini :=  TINIFile.Create(ProjIniPath);
   if Ini = nil then
   begin
     logmsg('FormProjectControl: SaveCofnig: INI file assign/create failed');
     exit;
   end;
   try
     SaveProjectConfigIni( Ini );
   except
    on E: Exception do logError('TProjectControl.SaveProjectConfig EXCEPTION: ' + E.message);
   end;
   Ini.Destroy;
   logmsg('FormProjectControl: Saveconfig done.');
   Result := true;
end;

procedure TProjectControl.SaveProjectConfigIni( ini: TIniFile );
begin
   if Ini = nil then exit;

   Ini.WriteString('project', 'projname', ProjName);
   Ini.WriteString('project', 'projpath', ProjIniPath);
   Ini.WriteString('project', 'projdesc', ProjDesc);
   Ini.WriteFloat('project', 'ProjCellArea', ProjCellArea);

   Ini.WriteString('project', 'ProjAnodeDescr', ProjAnodeDescr);
   Ini.WriteString('project', 'ProjAnodeGDL', ProjAnodeGDL);
   Ini.WriteFloat('project', 'ProjAnodeLoading', ProjAnodeLoading);
   Ini.WriteFloat('project', 'ProjAnodeMinFlow', ProjAnodeMinFlow);
   Ini.WriteFloat('project', 'ProjAnodeStoich', ProjAnodeStoich);

   Ini.WriteString('project', 'ProjCathodeDescr', ProjCathodeDescr);
   Ini.WriteString('project', 'ProjCathodeGDL', ProjCathodeGDL);
   Ini.WriteFloat('project', 'ProjCathodeLoading', ProjCathodeLoading);
   Ini.WriteFloat('project', 'ProjCathodeMinFlow', ProjCathodeMinFlow);
   Ini.WriteFloat('project', 'ProjCathodeStoich', ProjCathodeStoich);
   Ini.WriteString('project', 'ProjMembrane', ProjMembrane);
   Ini.WriteString('project', 'ProjMEApreparation', ProjMEApreparation);
   Ini.WriteString('project', 'ProjCellType', ProjCellType);
   //
   Ini.WriteDateTime('project', 'ProjProjCreateDate', ProjCreateDate);
   Ini.WriteBool('project', 'ProjInvertCurrent', ProjInvertCurrent);
   Ini.WriteBool('project', ' ProjInvertVoltage',  ProjInvertVoltage);
   Ini.WriteBool('project', ' ProjFlowTracking',  ProjFlowTracking);
   //
   Ini.WriteFloat('project', 'ProjMaxCurrent', ProjMaxCurrent);
   Ini.WriteFloat('project', 'ProjMinCurrent', ProjMinCurrent);
   Ini.WriteFloat('project', 'ProjMaxVoltage', ProjMaxVoltage);
   Ini.WriteFloat('project', 'ProjMinVoltage', ProjMinVoltage);
   //
   Ini.WriteBool('project', IdNormStackVoltageByNoOfCells,  RegistryMainConfig.valBool[IdNormStackVoltageByNoOfCells] );
   Ini.WriteFloat('project', IdNumberOfCellsInStack,  RegistryMainConfig.valDouble[IdNumberOfCellsInStack] );

end;


procedure TProjectControl.LoadProjectConfigIni( ini: TIniFile );
begin
   if Ini = nil then exit;
   //
   ProjName := Ini.ReadString('project', 'projname', 'Unspecified Project');
   ProjChangeDisabled := Ini.ReadBool('project', 'ProjChangeDisabled', false);
   ProjDesc := Ini.ReadString('project', 'projdesc', '-default-');
   ProjCellArea := Ini.ReadFloat('project', 'ProjCellArea', 1);

   ProjAnodeDescr := Ini.ReadString('project', 'ProjAnodeDescr', '-unspecified-');
   ProjAnodeGDL := Ini.ReadString('project', 'ProjAnodeGDL', '-unspecified-');
   ProjAnodeLoading := Ini.ReadFloat('project', 'ProjAnodeLoading', 1 );
   ProjAnodeMinFlow := Ini.ReadFloat('project', 'ProjAnodeMinFlow', 40);
   ProjAnodeStoich := Ini.ReadFloat('project', 'ProjAnodeStoich', 1.2);

   ProjCathodeDescr := Ini.ReadString('project', 'ProjCathodeDescr', '-unspecified-' );
   ProjCathodeGDL := Ini.ReadString('project', 'ProjCathodeGDL', '-unspecified-' );
   ProjCathodeLoading := Ini.ReadFloat('project', 'ProjCathodeLoading', 1 );
   ProjCathodeMinFlow := Ini.ReadFloat('project', 'ProjCathodeMinFlow', 40);
   ProjCathodeStoich := Ini.ReadFloat('project', 'ProjCathodeStoich', 2);
   ProjMembrane := Ini.ReadString('project', 'ProjMembrane','-unspecified-');
   ProjMEApreparation := Ini.ReadString('project', 'ProjMEApreparation', '-unspecified-');
   ProjCellType := Ini.ReadString('project', 'ProjCellType', '-unspecified-');

   ProjCreateDate := Ini.ReadDateTime('project', 'ProjProjCreateDate', Now);
   ProjInvertCurrent := Ini.ReadBool('project', 'ProjInvertCurrent', false);
   ProjInvertVoltage := Ini.ReadBool('project', ' ProjInvertVoltage',  false);
   ProjFlowTracking := Ini.ReadBool('project', ' ProjFlowTracking',  true);

   ProjMaxCurrent := Ini.ReadFloat('project', 'ProjMaxCurrent', 15);
   ProjMinCurrent := Ini.ReadFloat('project', 'ProjMinCurrent', -15);
   ProjMaxVoltage := Ini.ReadFloat('project', 'ProjMaxVoltage', 1.5);
   ProjMinVoltage := Ini.ReadFloat('project', 'ProjMinVoltage', 0.3);

   cBNumberOfCellsStack.Text := Ini.ReadString('project', IdNumberOfCellsInStack, '1');
   chkNormLotageByNoOfCells.Checked := Ini.ReadBool('project', IdNormStackVoltageByNoOfCells, false);     Ini.WriteBool('project', IdNormStackVoltageByNoOfCells,  RegistryMainConfig.valBool[IdNormStackVoltageByNoOfCells] );
end;




procedure TProjectControl.RefreshForm;
begin
  EProjName.Text := ProjName;
  //disable editing of unspecified
  CHKEditDisabled.Checked := ProjChangeDisabled;
  EProjName.Enabled := true;
  if ProjChangeDisabled then EProjName.Enabled := false;

  EProjDir.Text := ProjDir;
  EProjDesc.Text := ProjDesc;
  LaProjPath.Caption := ProjIniPath;
  LaProjDate.Caption := DateTimeToStr( ProjCreateDate );
  //
  CBCellArea.Text := FloatToStrF( ProjCellArea, ffFixed,4,2);
  CBCellType.Text := ProjCellType;
  CBFlowTracking.Checked := ProjFlowTracking;
  //
  CBAnodeMat.Text := ProjAnodeDescr;
  CBAnodeGDL.Text := ProjAnodeGDL;
  CBAnodeLoading.Text := FloatToStrF( ProjAnodeLoading, ffFixed,4,2);
  CBAnodeStoich.Text := FloatToStrF( ProjAnodeStoich, ffFixed,4,2);
  CBAnodeFlowMin.Text := FloatToStrF( ProjAnodeMinFlow, ffFixed,4,2);
  //
  CBCathodeMat.Text := ProjCathodeDescr;
  CBCathodeGDL.Text := ProjCathodeGDL;
  CBCathodeLoading.Text := FloatToStrF( ProjCathodeLoading, ffFixed,4,2);
  CBCathodeStoich.Text := FloatToStrF( ProjCathodeStoich, ffFixed,4,2);
  CBCathodeFlowMin.Text := FloatToStrF( ProjCathodeMinFlow, ffFixed,4,2);
  //
  CBMembrane.Text := ProjMembrane;
  CBMea.Text := ProjMEApreparation;
  //
  CBInvertCurrent.Checked := ProjInvertCurrent;
  CBInvertVoltage.Checked := ProjInvertVoltage;
  CBCurrLimLow.Text := FloatToStrF( ProjMinCurrent, ffFixed,4,2);
  CBCurrLimHigh.Text := FloatToStrF( ProjMaxCurrent, ffFixed,4,2);
  CBVoltLimLow.Text := FloatToStrF( ProjMinVoltage, ffFixed,4,3);
  CBVoltLimHigh.Text := FloatToStrF( ProjMaxVoltage, ffFixed,4,3);
end;


function TProjectControl.ProjParametersToStr: string;
begin
  Result := 'Project:' + ProjName + '|'
            + 'Desc:' + ProjDesc + '|'
            + 'Path:' + ProjIniPath + '|'
            + 'ProjDate:' + DateTimeToStr( ProjCreateDate ) + '|'
            + 'FlowTracking:' + IfThen( ProjFlowTracking, '1', '0') + '|'
            + 'InvertCurrent:' + IfThen( ProjInvertCurrent, '1', '0') + '|'
            + 'ProjInvertVoltage:' + IfThen( ProjInvertVoltage, '1', '0') + '|'
            ;
end;



procedure TProjectControl.UpdateParams;
begin
  //TODO:
end;

procedure TProjectControl.setMonitorUpdateFlag;
begin
  MonitorUpdateFlag := true;
end;

procedure TProjectControl.clearMonitorUpdateFlag;
begin
  MonitorUpdateFlag := false;
end;

function TProjectControl.getMonitorUpdateFlag: boolean;
begin
  Result := MonitorUpdateFlag;
end;




function TProjectControl.genDefProjName( name: string): string;
begin
  Result := GlobalConfig.GlobStationIDStr +'-' + DateNowToStr +'-'+MyTrim( name );
end;





procedure TProjectControl.Button3Click(Sender: TObject);
begin
  RefreshForm;
end;

procedure TProjectControl.CBCellAreaChange(Sender: TObject);
begin
  ProjCellArea := MyStrToFloatDef( CBCellArea.Text, 1.0 );
end;

procedure TProjectControl.Button1Click(Sender: TObject);
begin
  SaveToDefault;
end;

procedure TProjectControl.CBInvertCurrentClick(Sender: TObject);
begin
  ProjectControl.ProjInvertCurrent :=  CBInvertCurrent.Checked;
end;

procedure TProjectControl.CBInvertVoltageClick(Sender: TObject);
begin
  ProjectControl.ProjInvertVoltage :=  CBInvertVoltage.Checked;
end;

procedure TProjectControl.CBFlowTrackingClick(Sender: TObject);
begin
  ProjectControl.ProjFlowTracking :=  CBFlowTracking.Checked;
end;

procedure TProjectControl.CBCellTypeChange(Sender: TObject);
begin
  ProjectControl.ProjCellType := CBCellType.Text;
end;

procedure TProjectControl.CBAnodeMatChange(Sender: TObject);
begin
  ProjectControl.ProjAnodeDescr := CBAnodeMat.Text;
end;


procedure TProjectControl.CBAnodeGDLChange(Sender: TObject);
begin
  ProjectControl.ProjAnodeGDL := CBAnodeGDL.Text;
end;


procedure TProjectControl.CBAnodeLoadingChange(Sender: TObject);
begin
  ProjectControl.ProjAnodeLoading := MyStrToFloatDef( CBAnodeLoading.Text, 0);
end;

procedure TProjectControl.CBAnodeStoichChange(Sender: TObject);
begin
  ProjectControl.ProjAnodeStoich := MyStrToFloatDef( CBAnodeStoich.Text, 0);
end;


procedure TProjectControl.CBAnodeFlowMinChange(Sender: TObject);
begin
  ProjectControl.ProjAnodeMinFlow := MyStrToFloatDef( CBAnodeFlowMin.Text, 0);
end;



procedure TProjectControl.CBCathodeMatChange(Sender: TObject);
begin
  ProjectControl.ProjCathodeDescr := CBCathodeMat.Text;
end;


procedure TProjectControl.CBCathodeGDLChange(Sender: TObject);
begin
  ProjectControl.ProjCathodeGDL := CBCathodeGDL.Text;
end;


procedure TProjectControl.CBCathodeLoadingChange(Sender: TObject);
begin
  ProjectControl.ProjCathodeLoading := MyStrToFloatDef( CBCathodeLoading.Text, 0);
end;


procedure TProjectControl.CBCathodeStochChange(Sender: TObject);
begin
  ProjectControl.ProjCathodeStoich := MyStrToFloatDef( CBCathodeStoich.Text, 0);
end;


procedure TProjectControl.CBCathodeFlowMinChange(Sender: TObject);
begin
  ProjectControl.ProjCathodeMinFlow := MyStrToFloatDef( CBCathodeFlowMin.Text, 0);
end;


procedure TProjectControl.CBMembraneChange(Sender: TObject);
begin
  ProjectControl.ProjMembrane := CBMembrane.Text;
end;


procedure TProjectControl.cBNumberOfCellsStackChange(Sender: TObject);
Var
  i: integer;
begin
  i := MVStrToInt( cBNumberOfCellsStack.Text );
  RegistryMainConfig.valInt[ IdNumberOfCellsInStack ] := i;
end;

procedure TProjectControl.CBMeaChange(Sender: TObject);
begin
  ProjectControl.ProjMEApreparation := CBMea.Text;
end;



procedure TProjectControl.FormShow(Sender: TObject);
begin
  RefreshForm;
end;

procedure TProjectControl.CBCurrLimLowChange(Sender: TObject);
begin
  ProjectControl.ProjMinCurrent := MyStrToFloatDef( CBCurrLimLow.Text, 0);
end;


procedure TProjectControl.CBCurrLimHighChange(Sender: TObject);
begin
  ProjectControl.ProjMaxCurrent := MyStrToFloatDef( CBCurrLimHigh.Text, 0);
end;


procedure TProjectControl.CBVoltLimLowChange(Sender: TObject);
begin
  ProjectControl.ProjMinVoltage := MyStrToFloatDef( CBVoltLimLow.Text, 0);
end;


procedure TProjectControl.CBVoltLimHighChange(Sender: TObject);
begin
  ProjectControl.ProjMaxVoltage := MyStrToFloatDef( CBVoltLimHigh.Text, 0);
end;

procedure TProjectControl.EProjNameChange(Sender: TObject);
begin
  ProjectControl.ProjName := EProjName.Text;
end;

procedure TProjectControl.EProjDescChange(Sender: TObject);
begin
  ProjectControl.ProjDesc := EProjDesc.Text;
end;

procedure TProjectControl.BuSaveClick(Sender: TObject);
begin
  GlobalConfig.BroadCastSignal( CSigProjectConfUpdated );
  ProjectControl.Hide;
end;

procedure TProjectControl.BuCancelClick(Sender: TObject);
begin
  ShowMessage('not implemented');
end;




procedure TProjectControl.BroadCastProjectUpdate;
Var
  i: integer;
  MMM: TMethod;
begin
  if bcastcount<=0 then exit;
  logmsg('TProjectControl.BroadCastProjectUpdate:  start');
  for i:= 0  to bcastcount-1 do
    begin
      MMM := broadcastlist[i];
			  try
			    if assigned(MMM) then MMM;
			  except
			    on E:Exception do ShowMessage( 'TProjectControl.BroadCastProjectUpdate: Exception when call assigned proc: ' + E.message);
			  end;
    end;
   logmsg('TProjectControl.BroadCastProjectUpdate:  end');
end;



function TProjectControl.RegOnProjectUpdateMethod(pM: TMethod): boolean;
begin
  Result := false;
  if bcastcount >= length( broadcastlist ) then exit;
  broadcastlist[ bcastcount ] := pM;
  inc( bcastcount );
  Result := true;
end;


end.

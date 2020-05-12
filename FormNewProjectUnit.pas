unit FormNewProjectUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  ClipBrd,
  FormProjectControl, StrUtils, ExtCtrls,
  logger;

type
  TNewProjectForm = class(TForm)
    BuCancel: TButton;
    BuCreateContinue: TButton;
    Label2: TLabel;
    BuNewPath: TButton;
    EName: TEdit;
    PanAutoDirectory: TPanel;
    Label3: TLabel;
    PanFullPath: TPanel;
    NFSaveDialog: TSaveDialog;
    Button1: TButton;
    Label4: TLabel;
    RBAutomatic: TRadioButton;
    RBManual: TRadioButton;
    Button2: TButton;
    Label1: TLabel;
    Label5: TLabel;
    procedure ENameChange(Sender: TObject);
    procedure BuCancelClick(Sender: TObject);
    procedure BuNewPathClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BuCreateContinueClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RBAutomaticClick(Sender: TObject);
    procedure RBManualClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    userspecdir: boolean;
    AutoPath: string;
    { Private declarations }
  public
    procedure Initialize;
    procedure GenerateAutoPath;
    { Public declarations }
  end;

var
  NewProjectForm: TNewProjectForm;

implementation

uses FormGlobalConfig, main;

{$R *.dfm}

procedure TNewProjectForm.FormCreate(Sender: TObject);
begin
 userspecdir := false;
 AutoPath := '';
 logmsg('TNewProjectForm.FormCreate done.');
end;


procedure TNewProjectForm.ENameChange(Sender: TObject);
begin
  GenerateAutoPath;
end;

procedure TNewProjectForm.BuCancelClick(Sender: TObject);
begin
  NewProjectForm.Hide;
end;

procedure TNewProjectForm.BuNewPathClick(Sender: TObject);
Var
  b: boolean;
begin
  //NFSaveDialog.Filename := GetCurrentDir;
  if NFSaveDialog.Execute then
  begin
    userspecdir := true;
    PanFullPath.Caption := NFSaveDialog.FileName;
    Label4.Caption := NFSaveDialog.InitialDir;

  end;
end;



procedure TNewProjectForm.Initialize;
Var
  s: string;
begin
  userspecdir := false;
  RBAutomatic.Checked := true;

  EName.Text := 'Nameless';
  GenerateAutoPath;
  s := GlobalConfig.getDataPath + AutoPath;

  NFSaveDialog.FileName := s + '\project.ini';
  NFSaveDialog.Filter := '*.ini';
  NFSaveDialog.InitialDir := s + '';

  PanFullPath.Caption := NFSaveDialog.FileName;
end;

procedure TNewProjectForm.GenerateAutoPath;
begin
  AutoPath :=  ProjectControl.genDefProjName( EName.Text );
  PanAutoDirectory.Caption := AutoPath;
  PanFullPath.Caption := GlobalConfig.getDataPath + AutoPath + '\' + 'project.ini';
end;

procedure TNewProjectForm.Button1Click(Sender: TObject);
begin
  Initialize;
end;

procedure TNewProjectForm.BuCreateContinueClick(Sender: TObject);
Var
  name, newfilepath, newdir, newfname: string;
begin
  name := EName.Text;
  newfilepath := PanFullPath.Caption;
  newdir := ExtractFilePath(newfilepath);

  //check file exists - if yes offer project reopen
  if  fileexists(newfilepath) then
  begin
    //if MessageDlg('That project.ini file already EXIST! Do you want to open that project instead?' + ExtractFileName(FileName) + '?'), mtConfirmation, [mbYes, mbNo], 0, mbNo) = IDYes then
    logmsg('Create new project: project.ini already exists - exiting');
    ShowMessage('That project.ini file already EXIST! - cancelling - Use OPEN project instead please');
    ////if fileexist     file open ????
    exit;
  end;

  ProjectControl.CloseProject;
  ProjectControl.CreateNewProject(name, newfilepath);
  //Form1.        //reset LOG
  NewProjectForm.Hide;
  ProjectControl.Show;

  //create new project = close actual, create dir/file with initial values,
  //    open newly created project, open project edit dialog, close this dialog

end;



procedure TNewProjectForm.RBAutomaticClick(Sender: TObject);
begin
  userspecdir := false;
end;

procedure TNewProjectForm.RBManualClick(Sender: TObject);
begin
  userspecdir := true;
end;

procedure TNewProjectForm.Button2Click(Sender: TObject);
begin
  Clipboard.AsText := PanAutoDirectory.Caption;
end;

end.

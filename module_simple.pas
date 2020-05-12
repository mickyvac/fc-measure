unit module_simple;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  FormHWAccessControlUnit, FormPTCHardwareUnit, Logger, HWInterface,
  myutils, MVConversion;


type
  TFormSimpleModule = class(TForm)
    BuStop: TButton;
    BuSetCurrent: TButton;
    BuSetVoltage: TButton;
    Label35: TLabel;
    EVoltageSp: TEdit;
    ECurrentsp: TEdit;
    Label36: TLabel;
    BuConLoad: TButton;
    buDisconLoad: TButton;
    BuHide: TButton;
    LaMsg: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure BuHideClick(Sender: TObject);
    procedure buDisconLoadClick(Sender: TObject);
    procedure BuConLoadClick(Sender: TObject);
    procedure BuSetCurrentClick(Sender: TObject);
    procedure BuSetVoltageClick(Sender: TObject);
    procedure BuStopClick(Sender: TObject);
    procedure ECurrentspKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EVoltageSpKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    token: THWAccessToken;
    fwindowLoadPosition: boolean;
    fModuleName: string;
  public
    { Public declarations }
  end;

var
  FormSimpleModule: TFormSimpleModule;

implementation

uses main, FormGlobalConfig;

{$R *.dfm}



procedure TFormSimpleModule.FormCreate(Sender: TObject);
begin
  token := THWAccessToken.Create;
  token.tokenname := 'Simple Control Module';
  token.statusmsg := '...';
  //restore position on first show        //!!! Form position must be set to poDesigned!!!
  Position := poDesigned;
  fwindowLoadPosition := true;
  fModuleName := 'SimpleModule';
  GlobalConfig.RegisterFormPositionRec(fModuleName+'', FormSimpleModule);
  logmsg('TFormSimpleModule.FormCreate done.');
end;

procedure TFormSimpleModule.FormDestroy(Sender: TObject);
begin
  token.Free;
end;



procedure TFormSimpleModule.BuHideClick(Sender: TObject);
begin
  FormSimpleModule.Hide;
end;

procedure TFormSimpleModule.buDisconLoadClick(Sender: TObject);
begin
  token.getLock;
  MainHWInterface.PTCTurnOFF(token);
    LogProjectEvent('Force TurnFF');
  token.unlock;
end;

procedure TFormSimpleModule.BuConLoadClick(Sender: TObject);
begin
  token.getLock;
  MainHWInterface.PTCTurnON(token);
    LogProjectEvent('Force TurnON');
  token.unlock;
end;

procedure TFormSimpleModule.BuSetCurrentClick(Sender: TObject);
Var F: Double;
     s: string;
begin
  F := MyStrToFloatDef(  ECurrentsp.Text, 0) / 1000;  //input in mA, setpoint in A
  s := 'Force Current: '+ FloatToStr(F) + ' A.cm-2';
  LogProjectEvent('Sinmple Module: USER ' + s);
  LaMsg.Caption := s;
  token.getLock;
  MainHWInterface.PTCSetCC(F, token);
  MainHWInterface.PTCTurnON(token);
  MainHWInterface.AquireAll(token);
  token.unlock;
  FormMain.RefreshMonitor();
end;

procedure TFormSimpleModule.BuSetVoltageClick(Sender: TObject);
Var F: Double;
begin
  F := MyStrToFloatDef(  EVoltageSp.Text, 0) / 1000;   //input in mV, setpoint in V
  LogProjectEvent('Sinmple Module: USER Force Voltage: '+ FloatToStr(F)  + ' V');
  LaMsg.Caption := 'Force Voltage: '+ FloatToStr(F * 1000)  + ' mV';
  token.getLock;
  MainHWInterface.PTCSetCV(F, token);
  MainHWInterface.PTCTurnON(token);
  MainHWInterface.AquireAll(token);
  token.unlock;
  FormMain.RefreshMonitor();
end;

procedure TFormSimpleModule.BuStopClick(Sender: TObject);
begin
  token.getLock;
  MainHWInterface.PTCTurnOFF(token);
  LogProjectEvent('Sinmple Module: USER STOP Click');
  token.unlock;
  LaMsg.Caption := 'Load OFF.';
end;

procedure TFormSimpleModule.ECurrentspKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=#13 then  BuSetCurrentClick(Sender);
end;


procedure TFormSimpleModule.EVoltageSpKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then  BuSetVoltageClick(Sender);
end;

procedure TFormSimpleModule.Button1Click(Sender: TObject);
begin
  token.getLock;
end;

procedure TFormSimpleModule.Button2Click(Sender: TObject);
begin
  token.unlock;
end;



procedure TFormSimpleModule.FormShow(Sender: TObject);
Var
  rec: TFormPositionRec;
begin
  if fwindowLoadPosition then   //only at start/first show
    begin
      GlobalConfig.UseFormPositionRec(fModuleName,FormSimpleModule);
      fwindowLoadPosition := false;
    end;
end;

end.

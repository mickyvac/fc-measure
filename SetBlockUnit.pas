unit SetBlockUnit;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Windows, Messages, ExtCtrls, Variants,
  Graphics, Forms,
  Dialogs, jpeg;

const
  //Items for ProcessType
  PT_Const = 'Const';
  PT_FromTo = 'From To';
  //Items for FeedBack
  FBT_Current = 'Current';
  FBT_Voltage = 'Voltage';

type
  TVoltageUnit = (uV, mV, V, kV);
  TCurrentUnit = (uA, mA, A, kA);
  TTimeUnit = (ms, s, min, h);


  TSetBlock = class(TGroupBox)
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; AParent: TWinControl); reintroduce; overload; //virtual;
  private
    //--- Objects of komponent ----
    FileName: TEdit;
    FileButton: TButton;
    FileName_label: TLabel;
    FeedBack: TComboBox;
    FeedBack_label: TLabel;
    ProcessType: TComboBox;
    ProcessType_label: TLabel;
    Time: TEdit;
    Time_label: TLabel;
    //case (FeedBack) do
    //FeedBack = const:
    ConstV: TEdit;
    ConstV_label: TLabel;
    WaitForStability: TCheckBox;
    Stability: TEdit;
    //FeedBack = From To:
    FromV: TEdit;
    FromV_label: TLabel;
    ToV: TEdit;
    ToV_label: TLabel;
    Step: TEdit;
    Step_label: TLabel;
    StepPerDTime: TEdit;
    //
    DelayBtLoad: TEdit;
    DelayBtLoad_label: TLabel;
    //---------------------------

    BgColorDef: TColor;
    BgCOnEnter: TColor;
    VoltageUnit: TVoltageUnit;
    CurrentUnit: TCurrentUnit;
    TimeUnit: TTimeUnit;
    VoltageMultiplier: double;
    CurrentMultiplier: double;
    TimeMultiplier: double;
    DelayBtLoadDTop: integer;
    Str_TimeUnit, Str_CurrentUnit, Str_VoltageUnit: string;
    Id: integer;
    InitialDir_: string;
    StepFrozen: boolean;

    DecPoint: char;
    RampAtTheEnd: boolean;

    FOnChange: TNotifyEvent;
    FOnKeyDown: TKeyEvent;
    //FOnClick : TNotifyEvent;

    function InitialDir_Get: string;
    procedure InitialDir_Set(TMFe: string);

    function V_FileName_Get: TFileName;
    procedure V_FileName_Set(TMFe: TFileName);
    function FileName_Get: TEdit;
    procedure FileName_Set(TMFe: TEdit);
    function FileName_label_Get: TLabel;
    procedure FileName_label_Set(TMFe: TLabel);
    function FileButton_Get: TButton;
    procedure FileButton_Set(TMFe: TButton);

    function Width_Get: integer;
    procedure Width_Set(TFMe: integer);

    function V_FeedBack_Get: string;
    procedure V_FeedBack_Set(TMFe: string);
    function FeedBack_Get: TComboBox;
    procedure FeedBack_Set(TFMe: TComboBox);
    function FeedBack_label_Get: TLabel;
    procedure FeedBack_label_Set(TFMe: TLabel);

    function V_ProcessType_Get: string;
    procedure V_ProcessType_Set(TMFe: string);
    function ProcessType_Get: TComboBox;
    procedure ProcessType_Set(TFMe: TComboBox);
    function ProcessType_label_Get: TLabel;
    procedure ProcessType_label_Set(TFMe: TLabel);

    function V_Time_Get: Int64;
    procedure V_Time_Set(TMFe: Int64);
    function Time_Get: TEdit;
    procedure Time_Set(TFMe: TEdit);
    function Time_label_Get: TLabel;
    procedure Time_label_Set(TFMe: TLabel);

    function V_Const_Get: double;
    procedure V_Const_Set(TMFe: double);
    function ConstV_Get: TEdit;
    procedure ConstV_Set(TFMe: TEdit);
    function ConstV_label_Get: TLabel;
    procedure ConstV_label_Set(TFMe: TLabel);

    function V_WaitForStability_Get: boolean;
    procedure V_WaitForStability_Set(TMFe: boolean);
    function WaitForStability_Get: TCheckBox;
    procedure WaitForStability_Set(TFMe: TCheckBox);
    function V_Stability_Get: double;
    procedure V_Stability_Set(TMFe: double);
    function Stability_Get: TEdit;
    procedure Stability_Set(TFMe: TEdit);

    function V_From_Get: double;
    procedure V_From_Set(TMFe: double);
    function FromV_Get: TEdit;
    procedure FromV_Set(TFMe: TEdit);
    function FromV_label_Get: TLabel;
    procedure FromV_label_Set(TFMe: TLabel);

    function V_To_Get: double;
    procedure V_To_Set(TMFe: double);
    function ToV_Get: TEdit;
    procedure ToV_Set(TFMe: TEdit);
    function ToV_label_Get: TLabel;
    procedure ToV_label_Set(TFMe: TLabel);

    function V_Step_Get: double;
    procedure V_Step_Set(TMFe: double);
    function Step_Get: TEdit;
    procedure Step_Set(TFMe: TEdit);
    function Step_label_Get: TLabel;
    procedure Step_label_Set(TFMe: TLabel);
    function StepPerDTime_Get: TEdit;
    procedure StepPerDTime_Set(TFMe: TEdit);

    function V_DelayBtLoad_Get: Int64;
    procedure V_DelayBtLoad_Set(TMFe: Int64);
    function DelayBtLoad_Get: TEdit;
    procedure DelayBtLoad_Set(TFMe: TEdit);
    function DelayBtLoad_label_Get: TLabel;
    procedure DelayBtLoad_label_Set(TFMe: TLabel);

    function BgCOnEnter_Get: TColor;
    procedure BgCOnEnter_Set(TFMe: TColor);

    function CurrentUnit_Get: TCurrentUnit;
    procedure CurrentUnit_Set(TFMe: TCurrentUnit);
    function VoltageUnit_Get: TVoltageUnit;
    procedure VoltageUnit_Set(TFMe: TVoltageUnit);
    function TimeUnit_Get: TTimeUnit;
    procedure TimeUnit_Set(TFMe: TTimeUnit);

    function DecPoint_Get: char;
    procedure DecPoint_Set(TFMe: char);

    function RampAtTheEnd_Get: boolean;
    procedure RampAtTheEnd_Set(TFMe: boolean);

    procedure SetBlockEnter(Sender: TObject);
    procedure SetBlockExit(Sender: TObject);

    procedure FileNameChange(Sender: TObject);
    procedure FeedBackChange(Sender: TObject);
    procedure ProcessTypeChange(Sender: TObject);
    procedure TimeChange(Sender: TObject);
    procedure ConstVChange(Sender: TObject);
    procedure WaitForStabilityChange(Sender: TObject);
    procedure StabilityChange(Sender: TObject);
    procedure FromVChange(Sender: TObject);
    procedure ToVChange(Sender: TObject);
    procedure StepChange(Sender: TObject);
    procedure StepChangeProcedure;
    procedure StepPerDTimeChange(Sender: TObject);
    procedure DelayBtLoadChange(Sender: TObject);

    procedure KomponentOnClick(Sender: TObject);
    procedure KomponentOnDblClick(Sender: TObject);
    procedure FileButtonOnClick(Sender: TObject);

    procedure FileNameOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimeOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ConstVOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StabilityOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FromVOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ToVOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StepOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StepPerDOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DelayBtLoadOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure SetComponentToDefault;
    procedure CaptionMake;  //because of unit - mA or V and so on
    procedure SetWidthOfComponents;
    procedure RefreshComponent;

    { Private declarations }
  protected
    { Protected declarations }
  public
    //V_  means public from My own variables - no property
    V_Entered: boolean;
    //V_TimeOfStep: double;
    V_CycleChar: boolean;
    //V_ProcessType: string;
    //V_Time: integer; // [ms]
    //V_Const: double; //[mA] or [mV]
    //V_WaitForStability: boolean;
    //V_Stability: double; //[mA] or [mV]
    //V_From: double; //[mA] or [mV]
    //V_To: double;  //[mA] or [mV]
    //V_Step: double;  //[mA] or [mV]
    //V_DelayBtLoad: integer; //[ms]

    procedure ProcessTypeForChange;
    { Public declarations }
  published
    //S_  means public from My own variables - but all property and V_ ... my important value
    Property V_InitialDir: string read InitialDir_Get write InitialDir_Set;
    Property V_FileName: TFileName read V_FileName_Get write V_FileName_Set;
    Property V_Id : integer read Id write Id;
    Property V_FeedBack: string read V_FeedBack_Get write V_FeedBack_Set;
    Property V_ProcessType: string read V_ProcessType_Get write V_ProcessType_Set;
    Property V_Time: Int64 read V_Time_Get write V_Time_Set; // [ms]
    Property V_Const: double read V_Const_Get write V_Const_Set; //[mA] or [mV]
    Property V_WaitForStability: boolean read V_WaitForStability_Get write V_WaitForStability_Set;
    Property V_Stability: double read V_Stability_Get write V_Stability_Set; //[mA] or [mV]
    Property V_From: double read V_From_Get write V_From_Set; //[mA] or [mV]
    Property V_To: double read V_To_Get write V_To_Set;  //[mA] or [mV]
    Property V_Step: double read V_Step_Get write V_Step_Set;  //[mA] or [mV]
    Property V_DelayBtLoad: Int64 read V_DelayBtLoad_Get write V_DelayBtLoad_Set; //[ms]}

    Property S_Width : integer read Width_Get write Width_Set;
    Property S_BgCOnEnter : TColor read BgCOnEnter_Get write BgCOnEnter_Set;
    Property S_FileName: TEdit read FileName_Get write FileName_Set;
    Property S_FileName_label: TLabel read FileName_label_Get write FileName_label_Set;
    Property S_FileButton: TButton read FileButton_Get write FileButton_Set;
    Property S_FeedBack: TComboBox read FeedBack_Get write FeedBack_Set;
    Property S_FeedBack_label: TLabel read FeedBack_label_Get write FeedBack_label_Set;
    Property S_ProcessType: TComboBox read ProcessType_Get write ProcessType_Set;
    Property S_ProcessType_label: TLabel read ProcessType_label_Get write ProcessType_label_Set;
    Property S_Time: TEdit read Time_Get write Time_Set;
    Property S_Time_label: TLabel read Time_label_Get write Time_label_Set;
    Property S_Const: TEdit read ConstV_Get write ConstV_Set;
    Property S_Const_label: TLabel read ConstV_label_Get write ConstV_label_Set;
    Property S_WaitForStability: TCheckBox read WaitForStability_Get write WaitForStability_Set;
    Property S_Stability: TEdit read Stability_Get write Stability_Set;
    Property S_From: TEdit read FromV_Get write FromV_Set;
    Property S_From_label: TLabel read FromV_label_Get write FromV_label_Set;
    Property S_To: TEdit read ToV_Get write ToV_Set;
    Property S_To_label: TLabel read ToV_label_Get write ToV_label_Set;
    Property S_Step: TEdit read Step_Get write Step_Set;
    Property S_Step_label: TLabel read Step_label_Get write Step_label_Set;
    Property S_StepPerDTime: TEdit read StepPerDTime_Get write StepPerDTime_Set;
    Property S_DelayBtLoad: TEdit read DelayBtLoad_Get write DelayBtLoad_Set;
    Property S_DelayBtLoad_label: TLabel read DelayBtLoad_label_Get write DelayBtLoad_label_Set;
    Property S_CurrentUnit: TCurrentUnit read CurrentUnit_Get write CurrentUnit_Set;
    Property S_VoltageUnit: TVoltageUnit read VoltageUnit_Get write VoltageUnit_Set;
    Property S_TimeUnit: TTimeUnit read TimeUnit_Get write TimeUnit_Set;

    Property S_DecPoint: char read DecPoint_Get write DecPoint_Set;
    Property S_RampAtTheEnd: boolean read RampAtTheEnd_Get write RampAtTheEnd_Set;

    Property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    Property OnChange: TNotifyEvent read FOnChange write FOnChange;
    //Property OnCLick: TNotifyEvent read FOnClick write FOnClick;
    { Published declarations }
  end;



procedure Register;


implementation

uses ConvUtils;

//--------Constructor-----------------
constructor TSetBlock.Create(AOwner: TComponent);
begin
  if AOwner is TWinControl then
    Create(AOwner, TWinControl(AOwner))
  else
    Create(AOwner, nil);

  FileName := TEdit.Create(Self);
  FileName.Parent := Self;
  FileButton := TButton.Create(Self);
  FileButton.Parent := Self;
  FileName_label := TLabel.Create(Self);
  FileName_label.Parent := Self;

  FeedBack := TComboBox.Create(Self);
  FeedBack.Parent := Self;
  FeedBack_label := TLabel.Create(Self);
  FeedBack_label.Parent := Self;

  ProcessType := TComboBox.Create(Self);
  ProcessType.Parent := Self;
  ProcessType_label := TLabel.Create(Self);
  ProcessType_label.Parent := Self;

  Time := TEdit.Create(Self);
  Time.Parent := Self;
  Time_label := TLabel.Create(Self);
  Time_label.Parent := Self;

  ConstV := TEdit.Create(Self);
  ConstV.Parent := Self;
  ConstV_label := TLabel.Create(Self);
  ConstV_label.Parent := Self;

  WaitForStability := TCheckBox.Create(Self);
  WaitForStability.Parent := Self;
  Stability := TEdit.Create(Self);
  Stability.Parent := Self;

  FromV := TEdit.Create(Self);
  FromV.Parent := Self;
  FromV_label := TLabel.Create(Self);
  FromV_label.Parent := Self;

  ToV := TEdit.Create(Self);
  ToV.Parent := Self;
  ToV_label := TLabel.Create(Self);
  ToV_label.Parent := Self;

  Step := TEdit.Create(Self);
  Step.Parent := Self;
  Step_label := TLabel.Create(Self);
  Step_label.Parent := Self;
  StepPerDTime := TEdit.Create(Self);
  StepPerDTime.Parent := Self;

  DelayBtLoad := TEdit.Create(Self);
  DelayBtLoad.Parent := Self;
  DelayBtLoad_label := TLabel.Create(Self);
  DelayBtLoad_label.Parent := Self;

  SetComponentToDefault;
end;

constructor TSetBlock.Create(AOwner: TComponent; AParent: TWinControl);
begin
  inherited Create(AOwner);
  Parent := AParent;
end;   // constructor

//--------- Get / Set functions due to Property...  ---------------------
//Initial Direction
function TSetBlock.InitialDir_Get: string;
begin
  Result := InitialDir_;
end;

procedure TSetBlock.InitialDir_Set(TMFe: string);
begin
  InitialDir_ := TMFe;
end;

//FileName
function TSetBlock.V_FileName_Get: TFileName;
begin
  Result := FileName.Text;
end;

procedure TSetBlock.V_FileName_Set(TMFe: TFileName);
begin
  FileName.Text := TMFe;
end;

function TSetBlock.FileName_Get: TEdit;
begin
  Result := FileName;
end;

procedure TSetBlock.FileName_Set(TMFe: TEdit);
begin
  FileName := TMFe;
end;

function TSetBlock.FileName_label_Get: TLabel;
begin
  Result := FileName_label;
end;

procedure TSetBlock.FileName_label_Set(TMFe: TLabel);
begin
  FileName_label := TMFe;
end;

function TSetBlock.FileButton_Get: TButton;
begin
  Result := FileButton;
end;

procedure TSetBlock.FileButton_Set(TMFe: TButton);
begin
  FileButton := TMFe;
end;

//Width
function TSetBlock.Width_Get: integer;
begin
  Result := Width;
end;

procedure TSetBlock.Width_Set(TFMe: integer);
begin
  Width := TFMe;
  SetWidthOfComponents;
end;

//FeedBack
function TSetBlock.V_FeedBack_Get: string;
begin
  Result := Feedback.Text;
end;

procedure TSetBlock.V_FeedBack_Set(TMFe: string);
begin
  FeedBack.Text := TMFe
end;

function TSetBlock.FeedBack_Get: TComboBox;
begin
   Result := FeedBack;
end;

procedure TSetBlock.FeedBack_Set(TFMe: TComboBox);
begin
  FeedBack := TFMe;
  //V_FeedBack := FeedBack.Text;
  //CaptionMake;
end;

function TSetBlock.FeedBack_label_Get: TLabel;
begin
  Result := FeedBack_label;
end;

procedure TSetBlock.FeedBack_label_Set(TFMe: TLabel);
begin
  FeedBack_label := TFMe;
end;

//ProcessType
function TSetBlock.V_ProcessType_Get: string;
begin
  Result := ProcessType.Text;
end;

procedure TSetBlock.V_ProcessType_Set(TMFe: string);
begin
  ProcessType.Text := TMFe;
end;

function TSetBlock.ProcessType_Get: TComboBox;
begin
   Result := ProcessType;
end;

procedure TSetBlock.ProcessType_Set(TFMe: TComboBox);
begin
  ProcessType := TFMe;
end;

function TSetBlock.ProcessType_label_Get: TLabel;
begin
  Result := ProcessType_label;
end;

procedure TSetBlock.ProcessType_label_Set(TFMe: TLabel);
begin
  ProcessType_label := TFMe;
end;

//Time
function TSetBlock.V_Time_Get: Int64;
begin
  Result := Round(StrToFloat(Time.Text) * TimeMultiplier);
end;

procedure TSetBlock.V_Time_Set(TMFe: Int64);
begin
  Time.Text := FloatToStr(TMFe / TimeMultiplier);
end;

function TSetBlock.Time_Get: TEdit;
begin
   Result := Time;
end;

procedure TSetBlock.Time_Set(TFMe: TEdit);
begin
  Time := TFMe;
end;

function TSetBlock.Time_label_Get: TLabel;
begin
  Result := Time_label;
end;

procedure TSetBlock.Time_label_Set(TFMe: TLabel);
begin
  Time_label := TFMe;
end;

//ConstV
function TSetBlock.V_Const_Get: double;
begin
  if(FeedBack.Text = FBT_Current)then begin
    Result := (StrToFloat(ConstV.Text) * CurrentMultiplier);
    Exit;
  end;
  if(FeedBack.Text = FBT_Voltage)then begin
    Result := (StrToFloat(ConstV.Text) * VoltageMultiplier);
    Exit;
  end;
  MessageDlg('Unknow feedback: '''+FeedBack.Text+''' !', mtError,[mbOk], 0);
  Result := 1;
end;

procedure TSetBlock.V_Const_Set(TMFe: double);
begin
  if(FeedBack.Text = FBT_Current)then
    ConstV.Text := FloatToStr(TMFe / CurrentMultiplier);
  if(FeedBack.Text = FBT_Voltage)then
    ConstV.Text := FloatToStr(TMFe / VoltageMultiplier);
end;

function TSetBlock.ConstV_Get: TEdit;
begin
   Result := ConstV;
end;

procedure TSetBlock.ConstV_Set(TFMe: TEdit);
begin
  ConstV := TFMe;
end;

function TSetBlock.ConstV_label_Get: TLabel;
begin
  Result := ConstV_label;
end;

procedure TSetBlock.ConstV_label_Set(TFMe: TLabel);
begin
  ConstV_label := TFMe;
end;

//wait for stability
function TSetBlock.V_WaitForStability_Get: boolean;
begin
  Result := WaitForStability.Checked;
end;

procedure TSetBlock.V_WaitForStability_Set(TMFe: boolean);
begin
  WaitForStability.Checked := TMFe;
end;

function TSetBlock.WaitForStability_Get: TCheckBox;
begin
  Result := WaitForStability;
end;

procedure TSetBlock.WaitForStability_Set(TFMe: TCheckBox);
begin
  WaitForStability := TFMe;
end;

function TSetBlock.V_Stability_Get: double;
begin
  if(FeedBack.Text = FBT_Current)then begin
    Result := (StrToFloat(Stability.Text) * CurrentMultiplier);
    Exit;
  end;
  if(FeedBack.Text = FBT_Voltage)then begin
    Result := (StrToFloat(Stability.Text) * VoltageMultiplier);
    Exit;
  end;
  MessageDlg('Unknow feedback: '''+FeedBack.Text+''' !', mtError,[mbOk], 0);
  Result := 1;
end;

procedure TSetBlock.V_Stability_Set(TMFe: double);
begin
  if(FeedBack.Text = FBT_Current)then
    Stability.Text := FloatToStr(TMFe / CurrentMultiplier);
  if(FeedBack.Text = FBT_Voltage)then
    Stability.Text := FloatToStr(TMFe / VoltageMultiplier);
end;

function TSetBlock.Stability_Get: TEdit;
begin
  Result := Stability;
end;

procedure TSetBlock.Stability_Set(TFMe: TEdit);
begin
  Stability := TFMe;
end;

//FromV
function TSetBlock.V_From_Get: double;
begin
  if(FeedBack.Text = FBT_Current)then begin
    Result := (StrToFloat(FromV.Text) * CurrentMultiplier);
    Exit;
  end;
  if(FeedBack.Text = FBT_Voltage)then begin
    Result := (StrToFloat(FromV.Text) * VoltageMultiplier);
    Exit;
  end;
  MessageDlg('Unknow feedback: '''+FeedBack.Text+''' !', mtError,[mbOk], 0);
  Result := 1;
end;

procedure TSetBlock.V_From_Set(TMFe: double);
begin
  if(FeedBack.Text = FBT_Current)then
    FromV.Text := FloatToStr(TMFe / CurrentMultiplier);
  if(FeedBack.Text = FBT_Voltage)then
    FromV.Text := FloatToStr(TMFe / VoltageMultiplier);
end;

function TSetBlock.FromV_Get: TEdit;
begin
   Result := FromV;
end;

procedure TSetBlock.FromV_Set(TFMe: TEdit);
begin
  FromV := TFMe;
end;

function TSetBlock.FromV_label_Get: TLabel;
begin
  Result := FromV_label;
end;

procedure TSetBlock.FromV_label_Set(TFMe: TLabel);
begin
  FromV_label := TFMe;
end;

//ToV
function TSetBlock.V_To_Get: double;
begin
  if(FeedBack.Text = FBT_Current)then begin
    Result := (StrToFloat(ToV.Text) * CurrentMultiplier);
    Exit;
  end;
  if(FeedBack.Text = FBT_Voltage)then begin
    Result := (StrToFloat(ToV.Text) * VoltageMultiplier);
    Exit;
  end;
  MessageDlg('Unknow feedback: '''+FeedBack.Text+''' !', mtError,[mbOk], 0);
  Result := 1;
end;

procedure TSetBlock.V_To_Set(TMFe: double);
begin
  if(FeedBack.Text = FBT_Current)then
    ToV.Text := FloatToStr(TMFe / CurrentMultiplier);
  if(FeedBack.Text = FBT_Voltage)then
    ToV.Text := FloatToStr(TMFe / VoltageMultiplier);
end;

function TSetBlock.ToV_Get: TEdit;
begin
   Result := ToV;
end;

procedure TSetBlock.ToV_Set(TFMe: TEdit);
begin
  ToV := TFMe;
end;

function TSetBlock.ToV_label_Get: TLabel;
begin
  Result := ToV_label;
end;

procedure TSetBlock.ToV_label_Set(TFMe: TLabel);
begin
  ToV_label := TFMe;
end;

//Step
function TSetBlock.V_Step_Get: double;
begin
  if(FeedBack.Text = FBT_Current)then begin
    Result := (StrToFloat(Step.Text) * CurrentMultiplier);
    Exit;
  end;
  if(FeedBack.Text = FBT_Voltage)then begin
    Result := (StrToFloat(Step.Text) * VoltageMultiplier);
    Exit;
  end;
  MessageDlg('Unknow feedback: '''+FeedBack.Text+''' !', mtError,[mbOk], 0);
  Result := 1;
end;

procedure TSetBlock.V_Step_Set(TMFe: double);
begin
  if(FeedBack.Text = FBT_Current)then
    Step.Text := FloatToStr(TMFe / CurrentMultiplier);
  if(FeedBack.Text = FBT_Voltage)then
    Step.Text := FloatToStr(TMFe / VoltageMultiplier);
end;

function TSetBlock.Step_Get: TEdit;
begin
   Result := Step;
end;

procedure TSetBlock.Step_Set(TFMe: TEdit);
begin
  Step := TFMe;
end;

function TSetBlock.Step_label_Get: TLabel;
begin
  Result := Step_label;
end;

procedure TSetBlock.Step_label_Set(TFMe: TLabel);
begin
  Step_label := TFMe;
end;

function TSetBlock.StepPerDTime_Get: TEdit;
begin
   Result := StepPerDTime;
end;

procedure TSetBlock.StepPerDTime_Set(TFMe: TEdit);
begin
  StepPerDTime := TFMe;
end;

//DelayBtDLoad
function TSetBlock.V_DelayBtLoad_Get: Int64;
begin
  Result := Round(StrToFloat(DelayBtLoad.Text) * TimeMultiplier);
end;

procedure TSetBlock.V_DelayBtLoad_Set(TMFe: Int64);
begin
  DelayBtLoad.Text := FloatToStr(TMFe / TimeMultiplier);
end;

function TSetBlock.DelayBtLoad_Get: TEdit;
begin
   Result := DelayBtLoad;
end;

procedure TSetBlock.DelayBtLoad_Set(TFMe: TEdit);
begin
  DelayBtLoad := TFMe;
end;

function TSetBlock.DelayBtLoad_label_Get: TLabel;
begin
  Result := DelayBtLoad_label;
end;

procedure TSetBlock.DelayBtLoad_label_Set(TFMe: TLabel);
begin
  DelayBtLoad_label := TFMe;
end;

//Unit
function TSetBlock.CurrentUnit_Get: TCurrentUnit;
begin
  Result := CurrentUnit;
end;

procedure TSetBlock.CurrentUnit_Set(TFMe: TCurrentUnit);
begin
  CurrentUnit := TFMe;
  case TFMe of
    uA: begin CurrentMultiplier := 0.001;  Str_CurrentUnit := 'uA'; end;
    mA: begin CurrentMultiplier := 1;  Str_CurrentUnit := 'mA'; end;
    A: begin CurrentMultiplier := 1000;  Str_CurrentUnit := 'A'; end;
    kA: begin CurrentMultiplier := 1000000; Str_CurrentUnit := 'kA'; end;
  end;
  CaptionMake;
end;

function TSetBlock.VoltageUnit_Get: TVoltageUnit;
begin
  Result := VoltageUnit;
end;

procedure TSetBlock.VoltageUnit_Set(TFMe: TVoltageUnit);
begin
  VoltageUnit := TFMe;
  case TFMe of
    uV: begin VoltageMultiplier := 0.001; Str_VoltageUnit := 'uV'; end;
    mV: begin VoltageMultiplier := 1;  Str_VoltageUnit := 'mV'; end;
    V: begin VoltageMultiplier := 1000; Str_VoltageUnit := 'V'; end;
    kV: begin VoltageMultiplier := 1000000;  Str_VoltageUnit := 'kV'; end;
  end;
  CaptionMake;
end;

function TSetBlock.TimeUnit_Get: TTimeUnit;
begin
  Result := TimeUnit;
end;

procedure TSetBlock.TimeUnit_Set(TFMe: TTimeUnit);
begin
  TimeUnit := TFMe;
  case TFMe of
    ms: begin TimeMultiplier := 1; Str_TimeUnit := 'ms'; end;
    s: begin TimeMultiplier := 1000; Str_TimeUnit := 's'; end;
    min: begin TimeMultiplier := 60000; Str_TimeUnit := 'min'; end;
    h: begin TimeMultiplier := 3600000; Str_TimeUnit := 'h'; end;
  end;
  CaptionMake;
end;

//BgCOnEnter
function TSetBlock.BgCOnEnter_Get: TColor;
begin
  Result := BgCOnEnter;
end;

procedure TSetBlock.BgCOnEnter_Set(TFMe: TColor);
begin
  BgCOnEnter := TFMe;
end;

//-----OnEnter functions-----------
procedure TSetBlock.SetBlockEnter(Sender: TObject);
begin
  //Color := BgCOnEnter;
  V_Entered := True;
end;

procedure TSetBlock.SetBlockExit(Sender: TObject);
begin
  //Color := BgColorDef;
  V_Entered := False;
end;

//----OnChange function--------
procedure TSetBlock.FileNameChange(Sender: TObject);
begin
  FOnChange(Self);
end;

procedure TSetBlock.FeedBackChange(Sender: TObject);
begin
  V_FeedBack := FeedBack.Text;
  CaptionMake;
  FOnChange(Self);
end;

procedure TSetBlock.ProcessTypeChange(Sender: TObject);
begin
  ProcessTypeForChange;
end;

procedure TSetBlock.ProcessTypeForChange;
begin
  V_ProcessType := ProcessType.Text;
  if(ProcessType.Text = PT_Const) then begin
    ConstV_label.Visible := True;
    ConstV.Visible := True;
    WaitForStability.Visible := True;
    Stability.Visible := True;

    FromV_label.Visible := False;
    FromV.Visible := False;
    ToV_label.Visible := False;
    ToV.Visible := False;
    Step_label.Visible := False;
    Step.Visible := False;
    StepPerDTime.Visible := False;

    if(DelayBtLoad_label.Top = 244+DelayBtLoadDTop)then begin
      DelayBtLoad_label.Top := DelayBtLoad_label.Top - DelayBtLoadDTop;
      DelayBtLoad.Top := DelayBtLoad.Top - DelayBtLoadDTop;
    end;
    //RefreshComponent;
    FOnChange(Self);
  end;
  if(ProcessType.Text = PT_FromTo)then begin
    ConstV_label.Visible := False;
    ConstV.Visible := False;
    WaitForStability.Visible := False;
    Stability.Visible := False;

    FromV_label.Visible := True;
    FromV.Visible := True;
    ToV_label.Visible := True;
    ToV.Visible := True;
    Step_label.Visible := True;
    Step.Visible := True;
    StepPerDTime.Visible := True;

    if(DelayBtLoad_label.Top = 244) then begin
      DelayBtLoad_label.Top := DelayBtLoad_label.Top + DelayBtLoadDTop;
      DelayBtLoad.Top := DelayBtLoad.Top + DelayBtLoadDTop;
    end;
    //RefreshComponent
    FOnChange(Self);
  end;
end;

procedure TSetBlock.TimeChange(Sender: TObject);
var
  int: integer;
begin
  if not TryStrToInt(Time.Text, int) then begin
     MessageDlg('The value '+Time.Text+' is not integer number!', mtInformation,[mbOk], 0);
     Time.Text := Copy(Time.Text,1,Length(Time.Text)-1);
  end
  else begin
    V_Time := Round(int * TimeMultiplier);
    if(RampAtTheEnd)
        then StepPerDTime.Text := FloatToStr(V_Time / (Abs(V_To - V_From) / V_Step +1))
        else StepPerDTime.Text := FloatToStr(V_Step * V_Time / Abs(V_To - V_From));
    FOnChange(Self);
  end;
  //S_Time := StrToInt(Time.Text);
end;

procedure TSetBlock.ConstVChange(Sender: TObject);
var
  doub: double;
begin
  if(Length(ConstV.Text)>0)
  then if(ConstV.Text[Length(ConstV.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(ConstV.Text,doub)) then begin
        MessageDlg('The value '+ConstV.Text+' is not real number!', mtInformation,[mbOk], 0);
        ConstV.Text := Copy(ConstV.Text,1,Length(ConstV.Text)-1);
    end
    else begin
      if(FeedBack.Text = FBT_Current)then
        V_Const := (doub * CurrentMultiplier);
      if(FeedBack.Text = FBT_Voltage)then
        V_Const := (doub * VoltageMultiplier);
      FOnChange(Self);
    end;
  end
  //S_Const := StrToFloat(ConstV.Text);
end;

procedure TSetBlock.WaitForStabilityChange(Sender: TObject);
begin
  V_WaitForStability := WaitForStability.Checked;
  Stability.Enabled := V_WaitForStability;
  KomponentOnClick(self);
end;

procedure TSetBlock.StabilityChange(Sender: TObject);
var
  doub: double;
begin
  if(Length(Stability.Text)>0)
  then if(Stability.Text[Length(Stability.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(Stability.Text,doub)) then begin
        MessageDlg('The value '+Stability.Text+' is not real number!', mtInformation,[mbOk], 0);
        Stability.Text := Copy(Stability.Text,1,Length(Stability.Text)-1);
    end
    else begin
      if(FeedBack.Text = FBT_Current)then
        V_Stability := (doub * CurrentMultiplier);
      if(FeedBack.Text = FBT_Voltage)then
        V_Stability := (doub * VoltageMultiplier);
      FOnChange(Self);
    end;
  end
end;

procedure TSetBlock.FromVChange(Sender: TObject);
var
  doub: double;
begin
  if(Length(FromV.Text)>0)
  then if(FromV.Text[Length(FromV.Text)] <> S_DecPoint)then
  begin
    if not TryStrToFloat(FromV.Text,doub) then begin
      MessageDlg('The value '+FromV.Text+' is not real number!', mtInformation,[mbOk], 0);
      FromV.Text := Copy(FromV.Text,1,Length(FromV.Text)-1);
    end
    else begin
      StepFrozen := True;
      if(FeedBack.Text = FBT_Current)then
        V_From := (doub * CurrentMultiplier);
      if(FeedBack.Text = FBT_Voltage)then
        V_From := (doub * VoltageMultiplier);
      if((Abs(V_To - V_From) <> 0) and (V_Step <> 0))
        then if(RampAtTheEnd)
                then StepPerDTime.Text := FloatToStr( (V_Time / (Abs(V_To - V_From) / V_Step +1)) / TimeMultiplier)
                else StepPerDTime.Text := FloatToStr( (V_Step * V_Time / Abs(V_To - V_From)) / TimeMultiplier)
        else ;//StepPerDTime.Text := '0';
      StepFrozen := False;
      FOnChange(Self);
    end;
  end;
  //S_From := StrToFloat(FromV.Text);
end;

procedure TSetBlock.ToVChange(Sender: TObject);
var
  doub: double;
begin
  if(Length(ToV.Text)>0)
  then if(ToV.Text[Length(ToV.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(ToV.Text,doub)) then begin
        MessageDlg('The value '+ToV.Text+' is not real number!', mtInformation,[mbOk], 0);
        ToV.Text := Copy(ToV.Text,1,Length(ToV.Text)-1);
    end
    else begin
      StepFrozen := True;
      if(FeedBack.Text = FBT_Current)then
        V_To := (doub * CurrentMultiplier);
      if(FeedBack.Text = FBT_Voltage)then
        V_To := (doub * VoltageMultiplier);
      if( (Abs(V_To - V_From) <> 0) and (V_Step <> 0))
        then  if(RampAtTheEnd)
                then StepPerDTime.Text := FloatToStr( (V_Time / (Abs(V_To - V_From) / V_Step +1)) / TimeMultiplier)
                else StepPerDTime.Text := FloatToStr( (V_Step * V_Time / Abs(V_To - V_From)) / TimeMultiplier)
        else ;//StepPerDTime.Text := '0';
      StepFrozen := False;
      FOnChange(Self);
    end;
  end;
  //S_To := StrToFloat(ToV.Text);
end;

procedure TSetBlock.StepChange(Sender: TObject);
begin
  StepChangeProcedure;
end;

procedure TSetBlock.StepChangeProcedure;
var
  doub: double;
begin
  if(Length(Step.Text)>0)
  then if(Step.Text[Length(Step.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(Step.Text,doub)) then begin
        MessageDlg('The value '+Step.Text+' is not integer or real number!', mtInformation,[mbOk], 0);
        Step.Text := Copy(Step.Text,1,Length(Step.Text)-1);
    end
    else begin
      StepFrozen := True;
      if(FeedBack.Text = FBT_Current)then
        V_Step := (doub * CurrentMultiplier);
      if(FeedBack.Text = FBT_Voltage)then
        V_Step := (doub * VoltageMultiplier);
      if( (Abs(V_To - V_From) <> 0) and (V_Step <> 0) )
        then if(RampAtTheEnd)
                then StepPerDTime.Text := FloatToStr( (V_Time / (Abs(V_To - V_From) / V_Step +1)) / TimeMultiplier )
                else StepPerDTime.Text := FloatToStr( (V_Step * V_Time / Abs(V_To - V_From)) / TimeMultiplier);
      StepFrozen := False;
      FOnChange(Self);
    end;
  end;
end;

procedure TSetBlock.StepPerDTimeChange(Sender: TObject);
var
  StepInTime: double;
begin
  if(Length(StepPerDTime.Text)>0)
  then if(StepPerDTime.Text[Length(StepPerDTime.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(StepPerDTime.Text,StepInTime)) then begin
        MessageDlg('The value '+StepPerDTime.Text+' is not integer or real number!', mtInformation,[mbOk], 0);
        StepPerDTime.Text := Copy(StepPerDTime.Text,1,Length(StepPerDTime.Text)-1);
    end
    else begin
      if( (Abs(V_To - V_From) <> 0) and (V_Time <> 0) )
        then if(RampAtTheEnd)
          then if(not StepFrozen) then V_Step := Abs(V_To - V_From) / (V_Time / (StepInTime * TimeMultiplier)-1)
          else if(not StepFrozen) then V_Step := Abs(V_To - V_From) * StepInTime / V_Time * TimeMultiplier;
        //Step.Text := FloatToStr(V_Step);
      //FOnChange(Self);
    end;
  end;
end;

procedure TSetBlock.DelayBtLoadChange(Sender: TObject);
var
  doub: double;
begin
  //MessageDlg('The last character is: '+DelayBtLoad.Text[Length(DelayBtLoad.Text)]+'!', mtInformation,[mbOk], 0);
  if(Length(DelayBtLoad.Text)>0)
  then if(DelayBtLoad.Text[Length(DelayBtLoad.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(DelayBtLoad.Text,doub)) then begin
        MessageDlg('The value '+DelayBtLoad.Text+' is not integer or real number!', mtInformation,[mbOk], 0);
        DelayBtLoad.Text := Copy(DelayBtLoad.Text,1,Length(DelayBtLoad.Text)-1);
    end
    else V_DelayBtLoad := Round(doub * TimeMultiplier);
  end;
end;

//---Other Properties----
function TSetBlock.DecPoint_Get: char;
begin
  Result := DecPoint;
end;

procedure TSetBlock.DecPoint_Set(TFMe: char);
begin
  DecPoint := TFMe;
end;

function TSetBlock.RampAtTheEnd_Get: boolean;
begin
  Result := RampAtTheEnd;
end;

procedure TSetBlock.RampAtTheEnd_Set(TFMe: boolean);
var
  doub: double;
begin
  RampAtTheEnd := TFMe;
  if(Length(Step.Text)>0)
  then if(Step.Text[Length(Step.Text)] <> S_DecPoint)then
  begin
    if (not TryStrToFloat(Step.Text,doub)) then begin
        MessageDlg('The value '+Step.Text+' is not integer or real number!', mtInformation,[mbOk], 0);
        Step.Text := Copy(Step.Text,1,Length(Step.Text)-1);
    end
    else begin
      if(FeedBack.Text = FBT_Current)then
        V_Step := (doub * CurrentMultiplier);
      if(FeedBack.Text = FBT_Voltage)then
        V_Step := (doub * VoltageMultiplier);
      if((Abs(V_To - V_From) <> 0) and (V_Step <> 0))
        then if(RampAtTheEnd)
              then StepPerDTime.Text := FloatToStr( (V_Time / (Abs(V_To - V_From) / V_Step +1)) / TimeMultiplier)
              else StepPerDTime.Text := FloatToStr( (V_Step * V_Time / Abs(V_To - V_From)) / TimeMultiplier);
      //FOnChange(Self);
    end;
  end;
end;


//-----OnClick methods -------------
procedure TSetBlock.KomponentOnClick(Sender: TObject);
begin
  OnClick(self);
end;

//---  OnDblClick --------
procedure TSetBlock.KomponentOnDblClick(Sender: TObject);
begin
  OnDblClick(self);
end;

// --- OnClick on FileButton
procedure TSetBlock.FileButtonOnClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
begin
  KomponentOnClick(Self);
  SaveDialog := TSaveDialog.Create(self);
  if(InitialDir_ <> '')then SaveDialog.InitialDir := InitialDir_;
  SaveDialog.Options := [ofHideReadOnly];
  SaveDialog.Filter := 'Text files *.txt|*.txt';
  SaveDialog.FilterIndex := 1;
  SaveDialog.DefaultExt := 'txt';
  if(SaveDialog.Execute)then begin
    V_InitialDir :=  ExtractFileDir(SaveDialog.FileName);
    if(FileExists(SaveDialog.FileName))
      then begin
            if(MessageDlg('File exists '+SaveDialog.FileName+'. Rewrite it?',
                          mtWarning, [mbYes, mbNo], 0) = mrYes)
            then V_FileName := SaveDialog.FileName
      end else V_FileName := SaveDialog.FileName;
  end;
  SaveDialog.Free;
end;


//-------OnKeyDown  methods -----------
procedure TSetBlock.FileNameOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.TimeOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.ConstVOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.StabilityOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.FromVOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.ToVOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.StepOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.StepPerDOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

procedure TSetBlock.DelayBtLoadOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOnKeyDown(Self,Key,Shift);
end;

//--------Dynamic properties of component-----------
procedure TSetBlock.SetWidthOfComponents;
begin
  //Set Width
  FileName.Width := Width - 35;
  FileName_label.Width := Width -10;
  FeedBack.Width := Width - 10;
  FeedBack_label.Width := Width - 10;
  ProcessType.Width := Width - 10;
  ProcessType_label.Width := Width - 10;
  Time.Width := Width - 10;
  Time_label.Width := Width - 10;
  ConstV.Width := Width - 10;
  ConstV_label.Width := Width - 10;
  WaitForStability.Width := Width - 10;
  Stability.Width := Width - 10;
  FromV.Width := Width - 10;
  FromV_label.Width := Width - 10;
  ToV.Width := Width - 10;
  ToV_label.Width := Width - 10;
  Step.Width := Width - 10;
  Step_label.Width := Width - 10;
  StepPerDTime.Width := Width - 10;
  DelayBtLoad.Width := Width - 10;
  DelayBtLoad_label.Width := Width - 10;

  //Set left
  FileName.Left := 5;
  FileButton.Left := 5 + FileName.Width;
  FileName_label.Left := 5;
  FeedBack.Left := 5;
  FeedBack_label.Left := 5;
  ProcessType.Left := 5;
  ProcessType_label.Left := 5;
  Time.Left := 5;
  Time_label.Left := 5;
  ConstV.Left := 5;
  ConstV_label.Left := 5;
  WaitForStability.Left := 5;
  Stability.Left := 5;
  FromV.Left := 5;
  FromV_label.Left := 5;
  ToV.Left := 5;
  ToV_label.Left := 5;
  Step.Left := 5;
  Step_label.Left := 5;
  StepPerDTime.Left := 5;
  DelayBtLoad.Left := 5;
  DelayBtLoad_label.Left := 5;

end;

procedure TSetBlock.CaptionMake;  //becouse of unit - Ma or V and so on
begin
  with Time_label do begin
    Caption := 'Duration' + ' ['+Str_TimeUnit+']';
  end;
  with ConstV_label do begin
    Caption := 'Holding value';
    if (FeedBack.Text = FBT_Current) then Caption := Caption + ' ['+Str_CurrentUnit+']';
    if (FeedBack.Text = FBT_Voltage) then Caption := Caption + ' ['+Str_VoltageUnit+']';
  end;
  with WaitForStability do begin
    Caption := 'Wait for stability';
    if (FeedBack.Text = FBT_Current) then Caption := Caption + ' ['+Str_CurrentUnit+']';
    if (FeedBack.Text = FBT_Voltage) then Caption := Caption + ' ['+Str_VoltageUnit+']';
  end;
  with FromV_label do begin
    Caption := 'From value';
    if (FeedBack.Text = FBT_Current) then Caption := Caption + ' ['+Str_CurrentUnit+']';
    if (FeedBack.Text = FBT_Voltage) then Caption := Caption + ' ['+Str_VoltageUnit+']';
  end;
  with ToV_label do begin
    Caption := 'To value';
    if (FeedBack.Text = FBT_Current) then Caption := Caption + ' ['+Str_CurrentUnit+']';
    if (FeedBack.Text = FBT_Voltage) then Caption := Caption + ' ['+Str_VoltageUnit+']';
  end;
  with Step_label do begin
    Caption := 'Step in';
    if (FeedBack.Text = FBT_Current) then Caption := Caption + ' current ['+Str_CurrentUnit+']';
    if (FeedBack.Text = FBT_Voltage) then Caption := Caption + ' voltage ['+Str_VoltageUnit+']';
    Caption := Caption + ' or time ['+Str_TimeUnit+']';
  end;
  with DelayBtLoad_label do begin
    Caption := 'Measuring delay';
    Caption := Caption + ' ['+Str_TimeUnit+']';
  end;
  RefreshComponent;
end;

//------Static properites of componet--------------
procedure TSetBlock.SetComponentToDefault;
begin
  StepFrozen := False;
  S_VoltageUnit := V;   //VoltageUnit := 'V';
  S_CurrentUnit := mA;  //CurrentUnit := 'mA';
  S_TimeUnit := ms;
  Str_VoltageUnit := 'V';
  Str_CurrentUnit := 'mA';
  Str_TimeUnit := 'ms';
  S_Width := 160;
  RampAtTheEnd := False;
  VoltageMultiplier := 1000;
  CurrentMultiplier := 1;
  TimeMultiplier := 1;
    V_FileName := '';
    V_Id := ComponentIndex;
    V_Entered := False;
    V_Time := 60000; // [ms]
    FeedBack.Text := FBT_Current;
    V_Const := 100; //[mA] or [mV]
    V_WaitForStability := False;
    V_Stability := 50; //[mA] or [mV]
    V_From := 100; //[mA] or [mV]
    V_To := 200;  //[mA] or [mV]
    V_Step := 25;  //[mA] or [mV]
    V_DelayBtLoad := 10; //[ms]
  DelayBtLoadDTop := 59;   // in relation with Height --|
  V_CycleChar := False;
  BgCOnEnter := clActiveBorder;
  BgColorDef := Color;
  OnEnter := SetBlockEnter;
  OnExit := SetBlockExit;
  S_DecPoint := '.';
  V_InitialDir := GetCurrentDir;

  FileName.OnChange := FileNameChange;
  FeedBack.OnChange := FeedBackChange;
  ProcessType.OnChange := ProcessTypeChange;
  Time.OnChange := TimeChange;
  ConstV.OnChange := ConstVChange;
  WaitForStability.OnClick := WaitForStabilityChange;
  Stability.OnClick := StabilityChange;
  FromV.OnChange := FromVChange;
  ToV.OnChange := ToVChange;
  Step.OnChange := StepChange;
  StepPerDTime.OnChange := StepPerDTimeChange;
  DelayBtLoad.OnChange := DelayBtLoadChange;

  FileName.OnClick := KomponentOnClick;
  FileName_label.OnClick := KomponentOnClick;
  FileButton.OnClick := FileButtonOnClick; //Included i KomponentOnClick(Self)
  FeedBack.OnClick := KomponentOnClick;
  FeedBack_label.OnClick := KomponentOnClick;
  ProcessType.OnClick := KomponentOnClick;
  ProcessType_label.OnClick := KomponentOnClick;
  Time.OnClick := KomponentOnClick;
  Time_label.OnClick := KomponentOnClick;
  ConstV.OnClick := KomponentOnClick;
  ConstV_label.OnClick := KomponentOnClick;
  //WaitForStability.OnClick := KomponentOnClick;
  Stability.OnClick := KomponentOnClick;
  FromV.OnClick := KomponentOnClick;
  FromV_label.OnClick := KomponentOnClick;
  ToV.OnClick := KomponentOnClick;
  ToV_label.OnClick := KomponentOnClick;
  Step.OnClick := KomponentOnClick;
  Step_label.OnClick := KomponentOnClick;
  StepPerDTime.OnClick := KomponentOnClick;
  DelayBtLoad.OnClick := KomponentOnClick;
  DelayBtLoad_label.OnClick := KomponentOnClick;

  FileName.OnDblClick := KomponentOnDblClick;
  FileName_label.OnDblClick := KomponentOnDblClick;
  FeedBack.OnDblClick := KomponentOnDblClick;
  FeedBack_label.OnDblClick := KomponentOnDblClick;
  ProcessType.OnDblClick := KomponentOnDblClick;
  ProcessType_label.OnDblClick := KomponentOnDblClick;
  Time.OnDblClick := KomponentOnDblClick;
  Time_label.OnDblClick := KomponentOnDblClick;
  ConstV.OnDblClick := KomponentOnDblClick;
  ConstV_label.OnDblClick := KomponentOnDblClick;
  //WaitForStability.OnDblClick := KomponentOnDblClick;
  Stability.OnDblClick := KomponentOnDblClick;
  FromV.OnDblClick := KomponentOnDblClick;
  FromV_label.OnDblClick := KomponentOnDblClick;
  ToV.OnDblClick := KomponentOnDblClick;
  ToV_label.OnDblClick := KomponentOnDblClick;
  Step.OnDblClick := KomponentOnDblClick;
  Step_label.OnDblClick := KomponentOnDblClick;
  StepPerDTime.OnDblClick := KomponentOnDblClick;
  DelayBtLoad.OnDblClick := KomponentOnDblClick;
  DelayBtLoad_label.OnDblClick := KomponentOnDblClick;

  FileName.OnKeyDown := FileNameOnKeyDown;
  Time.OnKeyDown := TimeOnKeyDown;
  ConstV.OnKeyDown := ConstVOnKeyDown;
  Stability.OnKeyDown := StabilityOnKeyDown;
  FromV.OnKeyDown := FromVOnKeyDown;
  ToV.OnKeyDown := ToVOnKeyDown;
  Step.OnKeyDown := StepOnKeyDown;
  StepPerDTime.OnKeyDown := StepPerDOnKeyDown;
  DelayBtLoad.OnKeyDown := DelayBtLoadOnKeyDown;

  OnKeyDown := FOnKeyDown;

  S_RampAtTheEnd := RampAtTheEnd;

  //GrubBox (Self)
  Caption := '';//IntToStr(S_Id);
  Height := 344; //305       // in relation with DelayBtLoadDTop --|
  Visible := False;

  //FileName
  With FileName_label do begin
    Caption := 'File name';
    Visible := True;
    Top := 10;
    //Width := 100;
    Height := 13;
  end;

  with FileButton do begin
    Caption := '<-';
    Visible := True;
    Enabled := True;
    Top := 26;
    Width := 25;
    Height := 17;
  end;

  with FileName do begin
    Text := '';
    Visible := True;
    Enabled := True;
    Top := 26;
    //Width := 100;
    Height := 17;
  end;

  //FeedBack
  with FeedBack_label do begin
    Caption := 'Feedback';
    Visible := True;
    Top := 49;
    //Width := 100;
    Height := 13;
  end;

  with FeedBack do begin
    Items.Append(FBT_Current);
    Items.Append(FBT_Voltage);
    ItemIndex := 0;
    Visible := True;
    Enabled := True;
    Style := csDropDownList;
    Top := 65;
    //Width := 100;
    Height := 17;
  end;

  //ProcessType
  with ProcessType_label do begin
    Caption := 'Type';
    Top := 88;
    //Width := 100;
    Height := 13;
  end;
  with ProcessType do begin
    Items.Append(PT_Const);
    Items.Append(PT_FromTo);
    ItemIndex := 0;
    Visible := True;
    Enabled := True;
    Style := csDropDownList;
    Top := 104;
    //Width := 100;
    Height := 17;
  end;

  //Time
  with Time_label do begin
    Visible := True;
    Top := 127;
    //Width := 100;
    Height := 13;
  end;
  with Time do begin
    Visible := True;
    Enabled := True;
    Text := IntToStr(V_Time);
    Top := 143;
    //Width := 100;
    Height := 17;
  end;

  //ConstV---------------
  with ConstV_label do begin
    Visible := True;
    Top := 166;
    //Width := 100;
    Height := 13;
  end;
  with ConstV do begin
    Text := FloatToStr(V_Const);
    Visible := True;
    Enabled := True;
    Top := 182;
    //Width := 100;
    Height := 17;
  end;

  //Wait for stability
  with WaitForStability do begin
    Checked := V_WaitForStability;
    Enabled := True;
    Visible := True;
    Top := 205;
    //Width := 200;
    Height := 13;
  end;
  with Stability do begin
    Text := FloatToStr(V_Stability);
    Enabled := WaitForStability.Checked;
    Visible := True;
    Top := 221;
    //Width := 200;
    Height := 17;
  end;

  //FromV----------------------
  with FromV_label do begin
    Visible := False;
    Top := 166;
    //Width := 100;
    Height := 13;
  end;
  with FromV do begin
    Text := FloatToStr(V_From);
    Visible := False;
    Enabled := True;
    Top := 182;
    //Width := 100;
    Height := 17;
  end;

  //ToV
  with ToV_label do begin
    Visible := False;
    Top := 205;
    //Width := 100;
    Height := 13;
  end;
  with ToV do begin
    Text := FloatToStr(V_To);
    Visible := False;
    Enabled := True;
    Top := 221;
    //Width := 100;
    Height := 17;
  end;

  //Step
  with Step_label do begin
    Visible := False;
    Top := 244;
    //Width := 100;
    Height := 13;
  end;
  with Step do begin
    Text := FloatToStr(V_Step);
    Visible := False;
    Enabled := True;
    Top := 260;
    //Width := 100;
    Height := 17;
  end;
  with StepPerDTime do begin
    Text := FloatToStr(V_Step * V_Time / Abs(V_To - V_From));
    Visible := False;
    Enabled := True;
    Top := 280;
    //Width := 100;
    Height := 17;
  end;

  //DelayBtLoad-----------------
  with DelayBtLoad_label do begin
    Visible := True;
    Top := 244;     //264  //205
    //Width := 100;
    Height := 13;
  end;
  with DelayBtLoad do begin
    Text := FloatToStr(V_DelayBtLoad);
    Visible := True;
    Enabled := True;
    Top := 260;    //280  //221
    //Width := 100;
    Height := 17;
  end;

  CaptionMake;
  SetWidthOfComponents;
  RefreshComponent;
  
end;

procedure TSetBlock.RefreshComponent;
begin
  S_FileName := FileName;
  S_FileName_label := FileName_label;
  S_FeedBack := FeedBack;
  S_FeedBack_label := FeedBack_label;
  S_ProcessType := ProcessType;
  S_ProcessType_label := ProcessType_label;
  S_Time := Time;
  S_Time_label := Time_label;
  S_Const := ConstV;
  S_Const_label := ConstV_label;
  S_WaitForStability := WaitForStability;
  S_Stability := Stability;
  S_From := FromV;
  S_From_label := FromV_label;
  S_To := ToV;
  S_To_label := ToV_label;
  S_Step := Step;
  S_Step_label := Step_label;
  S_StepPerDTime := StepPerDTime;
  S_DelayBtLoad := DelayBtLoad;
  S_DelayBtLoad_label := DelayBtLoad_label;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TSetBlock]);
end;

end.

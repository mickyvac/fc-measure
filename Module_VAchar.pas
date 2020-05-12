unit Module_VAchar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TeEngine, Series, TeeProcs, Chart,

  {config,} Grids, ValEdit, CheckLst,

  Logger, FormHWAccessControlUnit, HWabstractdevicesV3;


type

  TVACharParamRec = record
    NameFull: String;       //name to list in listbox in preset manager
    NameID: String;       //trimmed string from FullName to use as id label for storing conf
    FileNameSuffix: String;   //VA file name suffix
    controlvar: TPotentioMode;
    seqcontroluser: boolean;
    sequserstr: string;     //start value
    seqstart: double;
    seqstep: double;
    seqend: double;
    twowaychar: boolean;
    turnvoltage: double;
    undervoltprotect: boolean;
    aquirerefreshtime: longint;
    measureHFR: boolean;
    HFRfrequency: longint;  //in Hz
    usegloballimits: boolean;
  end;
{
 Type
  TParamRec = record
    Name: String;       //name to list in listbox
    FileName: String;   //VA file prefix
    ControlVar: byte;       //0..FBCUrrent, else FBVoltage
    ValStart: real;
    ValEnd: real;
    ValStep: real;
    TurnVoltage: real;
    Delay: longint;         //Time delay between steps
    WaitForStab: byte;      //0..false, else true
    WaitValue: real;
    Cycle: byte;            //0..false, else true
    LimCurrLo: real;
    LimCurrHi: real;
    LimVoltLo: real;
    LimVoltHi: real;

  end;
}

  TVADriveRec = record
      // VA char drive parameters
    LastSetpoint: double;

    seqincreasing: boolean;
    seqInternStep: double;
    seqInternLimit: double;
    seqlist: TList;

    GoingBack: boolean;
    limitreached: boolean;

    newsetpoint: double;
    step: double;
    limit: double;
    Unow: double;
    end;


TVACharModule = class
  public
    procedure VACharStart;
    procedure VACharNextStep;
    procedure VACharFinish;
    procedure getParamRec( VarParamRec: TVACharParamRec);
    function getStatusStr: string;
    procedure RequestStop;
  private
    VAParamRec: TVACharParamRec;
    VADriveRec:  TVADriveRec;
    id: longint;  //this is to be assigned by main control module - to lock potentiostat control by this instance of module
  public
    name: string; //name to identify this module object e.g. 'batch step #3: VA CHAR 30s'
end;



  TTimerProcedure = procedure;


  TScheduler = class(TObject)
  public
    //procedure PlanRun(timeinms: longint; callproc: TTimerProcedure; noprocmsgs: boolean = false);


  end;



type
  TFormVAchar = class(TForm)
    Button1: TButton;
    Label11: TLabel;
    Label46: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Button2: TButton;
    Button3: TButton;
    Edit6: TEdit;
    CheckBox5: TCheckBox;
    ComboBox6: TComboBox;
    Button12: TButton;
    Button19: TButton;
    Edit8: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label6: TLabel;
    Label9: TLabel;
    Edit7: TEdit;
    Button4: TButton;
    PanFlowStatus: TPanel;
    LaFlowStatus: TLabel;
    Label16: TLabel;
    Edit13: TEdit;
    Label22: TLabel;
    Label23: TLabel;
    Edit15: TEdit;
    Label24: TLabel;
    PanPlot: TPanel;
    Label33: TLabel;
    Chart1: TChart;
    Series1: TFastLineSeries;
    ComboBox18: TComboBox;
    Button15: TButton;
    Panel1: TPanel;
    LaMonPow: TLabel;
    LaMonVref: TLabel;
    LaMonVolt: TLabel;
    LaMonCurr: TLabel;
    Label25: TLabel;
    Panel2: TPanel;
    RBSeqIteration: TRadioButton;
    RBSeqUser: TRadioButton;
    ESeqUser: TEdit;
    Label17: TLabel;
    EValStart: TEdit;
    Label58: TLabel;
    Label75: TLabel;
    EStep: TEdit;
    Label21: TLabel;
    Label41: TLabel;
    EValEnd: TEdit;
    Label76: TLabel;
    Label26: TLabel;
    Panel3: TPanel;
    Label34: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    Label69: TLabel;
    Label71: TLabel;
    Label43: TLabel;
    Label45: TLabel;
    RadioButton3: TRadioButton;
    Edit18: TEdit;
    Edit24: TEdit;
    Edit23: TEdit;
    Edit22: TEdit;
    Label27: TLabel;
    Label3: TLabel;
    Label14: TLabel;
    Label13: TLabel;
    PanFullPath: TPanel;
    Label28: TLabel;
    Panel4: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Label7: TLabel;
    Edit5: TEdit;
    Label8: TLabel;
    Label10: TLabel;
    Edit11: TEdit;
    Label12: TLabel;
    Label18: TLabel;
    CBControlVar: TComboBox;
    Label15: TLabel;
    Label29: TLabel;
    CheckBox3: TCheckBox;
    FormRefreshTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EValStartChange(Sender: TObject);
    procedure EStepChange(Sender: TObject);
    procedure EValEndChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
     token: THWAccessToken;
  public
    { Public declarations }
    assignedVAChar: TVACharModule;
    procedure RefreshVACharData;
  private
{
    procedure RefreshVaComboBox;
    procedure RefreshVaParamForm;
    procedure UpdateVAParamRecord;
    procedure LoadVaParam(n: byte);
    procedure SaveVaParam;
    }
  end;

var
  FormVAchar: TFormVAchar;
  globalVACharModule: TVACharModule;

implementation

{$R *.dfm}


procedure TFormVAchar.FormCreate(Sender: TObject);
begin
  globalVACharModule := TVACharModule.Create;
  globalVACharModule.name := 'Global VA Char module';
  //
  assignedVAChar := globalVACharModule;
  //token
  token := THWAccessToken.Create;
  token.tokenname := 'Global VA Char module';
  token.statusmsg := '---';
  logmsg('TFormVAchar.FormCreate done.');
end;


procedure TFormVAchar.FormDestroy(Sender: TObject);
begin
  assignedVAChar := nil;
  globalVACharModule.Free;
  token.Free;
end;



procedure Timer1TimerMV(Sender: TObject);
//VA char main routine

var
  newsetpoint, step, limit, Unow: double;
  limitreached, poprve: boolean;
  VADriveParam: TVADriveRec;  //For single VA
{  VAParam: TParamRec;}

begin
  TTimer(Sender).Enabled := False;

  //initialize
  if (poprve) then
  begin
    poprve := false;

    //set new setpoint and start timer
    //////////SetpointSet( VAparam.ValStart );
    //stability check ini
    ////if(not StabilityCheck(VAParam.ControlVar))then begin StopIt(TTimer(Sender),Stop); Exit; end;
    TTimer(Sender).Enabled := True;
    exit;
  end;

  //Aqiure and save data and plot Data
 { if(not AquireAndSavePlot(VAParam.ControlVar)) then begin
    MessageDlg('I cannot aquire and save line of data to the data file. Procces will be terminated', mtError, [mbOk], 0);
    LogMsg('I cannot aquire and save line of data to the data file. Procces will be terminated');
    StopIt(TTimer(Sender),Stop);
    Exit;

  end;  }

  //general limits check
  {
  if(GeneralLimitsReached(0,1))then
  begin
    LogMSG('Pøekroèena mez. Charakteristika se zastaví.');
    StopIt(TTimer(Sender),Stop);
    Exit;
  end;
}
  //check if limits had been reached
 { step := VADriveParam.InternStep;
  limit := VADriveParam.InternLimit;
  newsetpoint := VADriveParam.LastSetpoint + step;
   }
  limitreached := false;
  If ( step >= 0) and (newsetpoint > limit) then //currently rising
  begin
    limitreached := true;
  end;
  If ( step < 0) and (newsetpoint < limit) then //currently rising
  begin
    limitreached := true;
  end;
  //check voltage - turn point
  //Unow := Mon.Voltage;
{  if not (IsNan(Unow)) then
    begin
     if (Unow < VAparam.TurnVoltage) and not (VADriveParam.GoingBack) then limitreached := true;
    end;
}
  {
  //without goiong back
  if limitreached and (VAParam.Cycle = 0) then
    begin
      StopIt(TTimer(Sender),Stop);
      LogMSG('Limit reached - stop - only one way');
      Exit;
    end;

  //goingback and returned
  if limitreached and VADriveParam.GoingBack and (VAParam.Cycle <> 0) then
    begin
      StopIt(TTimer(Sender),Stop);
      exit;
    end;

  //else want to go back
  if limitreached and (VAParam.Cycle <> 0) and (not VADriveParam.GoingBack) then
    begin
      VADriveParam.InternStep := - VADriveParam.InternStep;
      VADriveParam.InternLimit := VAparam.ValStart;
      VADriveParam.GoingBack := true;
      //update newsetpoint
      newsetpoint := VADriveParam.LastSetpoint + step;
    end;

  //new setpoint
  VADriveParam.LastSetpoint := newsetpoint;
  SetpointSet( newsetpoint );


  //stability check
  if(not StabilityCheck(VAParam.ControlVar))then begin StopIt(TTimer(Sender),Stop); Exit; end;

  TTimer(Sender).Enabled := True;
  }
end;


procedure TFormVAchar.Button1Click(Sender: TObject);
begin
  FormVAChar.Hide;
end;

procedure TFormVAchar.Button2Click(Sender: TObject);
begin
   globalVACharModule.VACharStart;
   //ShowMessage(IntToStr(VADriverec.
end;

procedure TVACharModule.VACharStart;
Var
  d: double;
  b: boolean;
  posdir: boolean;
  pd: ^double;
begin
    VADriveRec.LastSetpoint := VAparamRec.seqStart;
    VADriveRec.seqInternLimit := VAparamRec.seqEnd;
    VADriveRec.GoingBack := false;
    VADriveRec.LimitReached := false;

    posdir :=  VAparamRec.seqEnd > VAparamRec.seqStart;

    if posdir then
      begin
        VADriveRec.seqInternStep := Abs(VAparamRec.seqStep);
      end
    else
      begin
        VADriveRec.seqInternStep := - Abs(VAparamRec.seqStep);
      end;
    VADriveRec.seqlist := TList.Create;
    //if user spec list then create list ....
    if VAParamRec.seqcontroluser then
    begin

    end
    else
    //iteration - create list
    begin
      d := VAparamRec.seqStart;
      b := true;
      while  b do
        begin
        //add item
        New( pd );
        pd^ := d;
        VADriveRec.seqlist.Add( pd );   //tlist
        d := d + VAparamRec.seqstep;
        if posdir then b := (d <= VAparamRec.seqEnd) else b:= (d >= VAparamRec.seqEnd) ;
        end;
    end;
    ShowMessage(IntToStr(VADriverec.seqlist.Count));
end;

procedure TVACharModule.VACharNextStep;
begin
   //VACharRun;
end;

procedure TVACharModule.VACharFinish;
begin
   //VACharRun;
end;


procedure TVACharModule.getParamRec( VarParamRec: TVACharParamRec);
begin

end;

function TVACharModule.getStatusStr: string;
begin
  Result := 'todo';
end;

procedure TVACharModule.RequestStop;
begin
      //TQueue   TObjectQueue  TStopwatch
end;


procedure TFormVAchar.RefreshVACharData;
begin
   EValSTart.Text := FloatToStr(assignedVAChar.VAParamRec.seqstart);
   EStep.Text := FloatToStr(assignedVAChar.VAParamRec.seqstep);
   EValEnd.Text := FloatToStr(assignedVAChar.VAParamRec.seqend);

end;



{
procedure TVACharModule.RefreshVaComboBox;
Var
  n: byte;
  i: integer;
begin
  with ComboBox6 do
  begin
    i := ItemIndex;
    Clear;
    for n:=1 to GetNParams do
    begin
      Items.Add( GetParamName(n) );
    end;
    ItemIndex := i;
    Text := VAParam.name;
  end;
end;

procedure TVACharModule.RefreshVaParamForm;
begin
  ComboBox6.Text := VAParam.name;
  Edit6.Text :=  VAParam.filename;
  if (VAParam.ControlVar = 0) then ComboBox16.ItemIndex := 0 else ComboBox16.ItemIndex := 1;
  Edit2.Text := FloatToStr( VAPAram.ValStart * 1000);
  Edit14.Text := FloatToStr( VAPAram.ValEnd * 1000);
  Edit9.Text := FloatToStr( VAPAram.ValStep * 1000);
  Edit8.Text := FloatToStr( VAPAram.TurnVoltage * 1000);
  Edit3.Text := IntToStr (VAPAram.Delay);
  if (VAPAram.WaitForStab = 0 ) then CheckBox6.Checked := false else CheckBox6.Checked := true;
  Edit25.Text := FloatToStr( VAPAram.WaitValue * 1000);
  if (VAPAram.Cycle = 0) then CheckBox5.Checked := false else CheckBox5.Checked := true;
  Edit18.Text := FloatToStr( VAPAram.LimCurrLo * 1000);
  Edit22.Text := FloatToStr( VAPAram.LimCurrHi * 1000);
  Edit23.Text := FloatToStr( VAPAram.LimVoltLo * 1000);
  Edit24.Text := FloatToStr( VAPAram.LimVoltHi * 1000);
  if (VAParam.ControlVar = 0) then //FbCurrent
  begin
    Label58.Caption := 'mA';
    Label75.Caption := 'mA';
    Label76.Caption := 'mA';
  end
  else
  begin
    Label58.Caption := 'mV';
    Label75.Caption := 'mV';
    Label76.Caption := 'mV';
  end;

end;

procedure TVACharModule.UpdateVAParamRecord;
begin
  VAPAram.name := ComboBox6.Text;
  VAPAram.filename := Edit6.Text;
  if (ComboBox16.ItemIndex = 0) then  VAParam.ControlVar := 0 else VAParam.ControlVar := 1;
  VAPAram.ValStart := StrToFloatDef( Edit2.Text, 0) / 1000;  //input is in mV or mA, stored value is in V or A
  VAPAram.ValEnd := StrToFloatDef( Edit14.Text, 0) / 1000;
  VAPAram.ValStep := StrToFloatDef( Edit9.Text, 0) / 1000;
  VAPAram.TurnVoltage := StrToFloatDef( Edit8.Text, 0) / 1000;
  VAPAram.Delay := StrToIntDef( Edit3.Text, 50 );
  if (CheckBox6.Checked) then VAPAram.WaitForStab := 1 else VAPAram.WaitForStab := 0;
  VAPAram.WaitValue := StrToFloatDef( Edit25.Text, 0) / 1000;
  if (CheckBox5.Checked) then VAPAram.Cycle := 1 else VAPAram.Cycle  := 0;
  VAPAram.LimCurrLo := StrToFloatDef( Edit18.Text, 0) / 1000;
  VAPAram.LimCurrHi := StrToFloatDef( Edit22.Text, 0) / 1000;
  VAPAram.LimVoltLo := StrToFloatDef( Edit23.Text, 0) / 1000;
  VAPAram.LimVoltHi := StrToFloatDef( Edit24.Text, 0) / 1000;
  SetParamValues(0, VAPAram);
end;

procedure TVACharModule.LoadVaParam(n: byte);
begin
  GetParamValues(n, VAParam);
end;

procedure TVACharModule.SaveVaParam;
Var
  n: byte;
  i: integer;
begin
  i := COmboBox6.ItemIndex;
  if (i < 0 ) then
  begin
    n := CreateNewParam;
    if (n=0) then
    begin
      LogMsg('No more space for new VA setup');
      exit;
    end;
  end else n := i + 1;
  SetParamValues(n, VAParam);
  RefreshVaParamForm;
end;


}













procedure TFormVAchar.EValStartChange(Sender: TObject);
begin
  assignedVAChar.VAParamRec.seqstart := StrToFloatDef( EValStart.Text, 0.0);
  RefreshVACharData;
end;

procedure TFormVAchar.EStepChange(Sender: TObject);
begin
  assignedVAChar.VAParamRec.seqstep := StrToFloatDef( EStep.Text, 0.0);
  RefreshVACharData;
end;

procedure TFormVAchar.EValEndChange(Sender: TObject);
begin
  assignedVAChar.VAParamRec.seqend := StrToFloatDef( EValEnd.Text, 0.0);
  RefreshVACharData;
end;










end.

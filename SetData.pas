unit SetData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin,
  Logger, SetBlockUnit, SetData_Help;

const
  BlockTop = 330;
  BlockLeft = 0;
  BlockLeftD = 180;
  BoxHeight = 694;
  BoxWidth = 900;
  GraphBg = $ffffff;
  GraphSect = $00ff00;
  GraphHGrid = $555555;
  GraphVGrid = $555555;
  GraphColorC = $ff0000;
  GraphColorV = $0000ff;
  SizeY = 0.9090909;  //in [%]
  F2  = 113;
  F3 = 114;
  F4 = 115;
  StrHint = 'Use ''Click'' for select and ''DblClick'' for copy to template.';
  ShowHintB = True;
  
  //--Graphic--
  CConectConstLine = True;  //Lilne is conected to the end of previous line
  CRampAtTheEnd = True;    // for process type> From To
  ProgName = 'Batching';
  Fulllenght = False;   //name of file in the title contains all path or not

  // -- Set Const ---
  LowVoltageLimit_C = -1.5;
  HighVoltageLimit_C = 1.5;
  LowCurretLimit_C = -100000;
  HighCurretLimit_C = 100000;
  CycleChar_C = False;  // something what main program wants

type
  TValInt = record
    Max : real;
    Min: real;
    Difer: real;
  end;

  TRPoint = record
    X : real;
    Y : real;
  end;

  TFormAttr = record
    ConectedLines: boolean;
    RampAtTheEnd: boolean;
    TempFileName: TFileName;
    TempFeedBack: String;
    TempProcessType: String;
    TempDuration: Int64;
    TempConstV: double;
    TempWaitForStability: boolean;
    TempStability: double;
    TempFrom: double;
    TempToV: double;
    TempStep: double;
    TempDelayBtLoad: integer;
  end;

  TBatch = record
    FileName: TFileName;
    FeedBack: String;
    ProcessType: String;
    Duration: Int64;
    ConstV: double;
    WaitForStability: boolean;
    Stability: double;
    From: double;
    ToV: double;
    Step: double;
    TimeOfStep: double;
    DelayBtLoad: integer;
    CycleChar: boolean;
  end;

  PTBatch = ^TBatch;

  TCMB = class(TPersistent)
  private
    FileName: string;
    function Save_(filen: TFileName):  boolean;
    function BoolToInt(b: boolean): integer;
    function IntToBool(i: integer): boolean;
    procedure MultipleValue(FeedBack: string; multiple: real);
  public
    FormAttr: TFormAttr;  //Set value in all komponets in form
    LowVoltageLimit: real;
    HighVoltageLimit: real;
    LowCurretLimit: real;
    HighCurretLimit: real;
    NumOfRepeating: integer;
    CycleChar: boolean;
    VoltageUnit: TVoltageUnit;
    CurrentUnit: TCurrentUnit;
    TimeUnit: TTimeUnit;
    ListOfBatch: TList;
    constructor Create;
    destructor Destroy; override;
    function Open(filen: string): boolean;
    function Save: boolean;
    function SaveAs(filen: string): boolean;
    function GetFileName: string;
    function FileNameEx: boolean;
    function ReadyForUse: boolean; //True if object is filled with relevant data
    procedure Close;
    procedure MultipleCurrent(multiple: real);
    procedure MultipleVoltage(multiple: real);
    procedure MultipleTime(multiple: real);
    function GetRelayState(BatchID: int64): string; //return relay state- "FullConect" if feedback is Voltage or Current
                                                                       // "Disconect" if feedback is "Disconenct"
                                                                       // "OnlyVoltageLoad" if feedback is "OnlyVoltageLoad"
  end;

  TSetDataForm = class(TForm)
    Button1: TButton;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Timer1: TTimer;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CUnit: TComboBox;
    Label1: TLabel;
    VUnit: TComboBox;
    TUnit: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Cycling: TSpinEdit;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    OpenButton: TButton;
    SaveAsButton: TButton;
    SaveButton: TButton;
    SaveDialog1: TSaveDialog;
    Button5: TButton;
    ClearButton: TButton;
    //FrameHelpAndAout: TFrameHelpAndAout;
    //constructor Create(AOwner: TComponent); override;
    //destructor Destroy; override;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetBlockChange(Sender: TObject);
    procedure SetBlockKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure SetBlockClick(Sender: TObject);
    procedure ClickMethod(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure SetBlock1Click(Sender: TObject);
    procedure SetBlock1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CUnitChange(Sender: TObject);
    procedure VUnitChange(Sender: TObject);
    procedure TUnitChange(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure SetBlockDblClick(Sender: TObject);
    procedure SetBlock1DblClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure SaveAsButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure CyclingChange(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    function GetFileName: TFileName;
    procedure PFileName_ParentPointer(pstr: Pointer);
    procedure PCMB_ParnetPointer(p: Pointer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClearButtonClick(Sender: TObject);
  private
    SetBlock1: TSetBlock;
    SetBlock: TSetBlock;
    //SetBlockPrev: TSetBlock;
    BlockList: TList;
    Delta : integer;
    ForDelete : integer;
    ImageWidth : integer;
    MyBitmap: TBitmap;
    Selected_ID: integer;
    ConectConstLine: boolean;  //Lilne is conected to the end of previous line
    RampAtTheEnd: boolean;
    LowVoltageLimit: double;  //value for export to file
    NumOfRepeating: integer;
    CUnitV: TCurrentUnit;
    VUnitV: TVoltageUnit;
    TUnitV: TTimeUnit;
    CMB: TCMB;             //Objcet for exporting and importing and mazbe for connecting to other application
    HighVoltageLimit: real;
    LowCurretLimit: real;
    HighCurretLimit: real;
    ChangedIsFrozen: boolean;
    PFileName_ParentPointer_IsInitialized: boolean;
    PFileName_ParentPointer_: Pointer;
    PCMB_ParnetPointer_IsInitialized: boolean;
    PCMB_ParnetPointer_: Pointer;
    marknotdestroycmb : boolean;
    procedure ReplotBg(sections: integer; HStep: integer; VStep: integer);
    procedure RearangeBlock;
    procedure Replot;
    function ValueInterval(Feedback: string): TValInt;
    procedure DeleteKomponent;
    procedure Add;
    procedure AddWithoutRearange;
    procedure InsertL;
    procedure InsertR;
    function FillCMB:boolean;
    procedure ReadCMB;
    procedure ChangeFormName(FileName: TFileName;FullLenght: boolean);
    procedure ReInitDirForAllBoxes;
    procedure LeavingForm;
    procedure Clear;
    { Private declarations }
  public
    { Public declarations }
    //destructor Destroy; override;
  end;

var
  SetDataForm: TSetDataForm;

implementation

uses Math, TypInfo;

{$R *.dfm}


//---- TCMB ----------
constructor TCMB.Create;
begin
  FileName := '';
  CycleChar := False;
  //
  ListOfBatch := TList.Create;
end;

destructor TCMB.Destroy;
var
  i: integer;
  pBatch: PTBatch;
begin
  for i := 0 to (ListOfBatch.Count - 1) do
    begin
      pBatch := ListOfBatch.Items[i];
      Dispose(pBatch);
    end;
  //
  ListOfBatch.Clear;
  ListOfBatch.Free;
end;

function TCMB.Save: boolean;
begin
  //Use FileName as a file for save;
  if(FileNameEx)
    then Result := Save_(FileName)
    else begin MessageDlg('Use save as and no save only.',mtError,[mbOK],0); Result := False end;
end;

function TCMB.SaveAs(filen: string): boolean;
begin
  Result := Save_(filen);
end;

function TCMB.GetFileName: string;
begin
  Result := FileName;
end;

function TCMB.Open(filen: string): boolean;
var
  F: TextFile;
  S: string;
  i: integer;
  ErrLine: integer;
  Batch: TBatch;
  pBatch: PTBatch;

  function GetStr(FirstIsDescription: boolean): string;
  var
    S: string;
    Ch: char;
  begin
    Ch := '0';
    if(FirstIsDescription) then begin Readln(F,S); Inc(ErrLine); end;
    while (not Eoln(F)) and (not (Ch = '»')) do Read(F,Ch);
    Readln(F,S);
    Inc(ErrLine);
    Result := S;
  end;

  function GetInt(FirstIsDescription: boolean): int64;
  var
    Ch: char;
    int: Int64;
  begin
    Ch := '0';
    if(FirstIsDescription) then begin Readln(F,S); Inc(ErrLine); end;
    while (not Eoln(F)) and (not (Ch = '»')) do begin Read(F,Ch); {MessageDlg('Char: "' +Ch+'".',mtError,[mbOk], 0);} end;
    Readln(F,int);
    Inc(ErrLine);
    Result := int;
  end;

  function GetReal(FirstIsDescription: boolean): real;
  var
    Ch: char;
    d: real;
  begin
    Ch := '0';
    if(FirstIsDescription) then begin Readln(F,S); Inc(ErrLine); end;
    while (not Eoln(F)) and (not (Ch = '»')) do Read(F,Ch);
    Readln(F,d);
    Inc(ErrLine);
    Result := d;
  end;

begin
  ErrLine := 0;
  try
    AssignFile(F, filen);   { File selected in dialog box }
    Reset(F);
  except
    Result := False;
    Exit;
  end;
  try
    //Clear ListOfBatch
    if(ListOfBatch.Count > 0) then
      for i := 0 to (ListOfBatch.Count - 1) do
      begin
        pBatch := ListOfBatch.Items[i];
        Dispose(pBatch);
      end;
    ListOfBatch.Clear;
    //Reading of The Intro -1 lines
    for i:= 1 to 15 do begin inc(ErrLine); Readln(F,S); end;
    //Fisrt Part
    with FormAttr do begin
      ConectedLines := IntToBool(GetInt(True));
      RampAtTheEnd := IntToBool(GetInt(True));
      TempFileName := GetStr(True);
      TempFeedBack := GetStr(True);
      TempProcessType := GetStr(True);
      TempDuration := GetInt(True);
      TempConstV := GetReal(True);
      TempWaitForStability := IntToBool(GetInt(True));
      TempStability := GetReal(True);
      TempFrom := GetReal(True);
      TempToV := GetReal(True);
      TempStep := GetReal(True);
      TempDelayBtLoad := GetInt(True);
    end;
    //Second part
    for i:= 1 to 4 do begin inc(ErrLine); Readln(F,S); end;
    LowVoltageLimit := GetReal(True);
    HighVoltageLimit := GetReal(True);
    LowCurretLimit := GetReal(True);
    HighCurretLimit := GetReal(True);
    NumOfRepeating := GetInt(True);
    VoltageUnit := TVoltageUnit(GetEnumValue(TypeInfo(TVoltageUnit),GetStr(True)));      //typeinfo
    CurrentUnit := TCurrentUnit(GetEnumValue(TypeInfo(TCurrentUnit),GetStr(True)));
    TimeUnit := TTimeUnit(GetEnumValue(TypeInfo(TTimeUnit),GetStr(True)));
    //Third part
    for i:= 1 to 17 do begin inc(ErrLine); Readln(F,S); end;
    while not Eof(F) do begin
      Readln(F,S); inc(ErrLine);
      Readln(F,S); inc(ErrLine);
      If ( (Length(S) < 2) or ( (S[1] <> 'I') or (S[2] <> 'D') ) )then break;
      with Batch do begin
        FileName := GetStr(False);
        FeedBack := GetStr(False);
        ProcessType := GetStr(False);
        Duration := GetInt(False);
        ConstV := GetReal(False);
        WaitForStability := IntToBool(GetInt(False));
        Stability := GetReal(False);
        From := GetReal(False);
        ToV := GetReal(False);
        Step := GetReal(False);
        TimeOfStep := GetReal(False);
        DelayBtLoad := GetInt(False);
        CycleChar := IntToBool(GetInt(False));
      end;
      New(pBatch);
      pBatch^ := Batch;
      ListOfBatch.Add(pBatch);
    end;

    Result := True;
    FileName := filen;
    CloseFile(F);
  except
    CloseFile(F);
    Result := False;
    MessageDlg('Cannot read this file: "' +filen+'". Error in the line '+IntToStr(ErrLine),
      mtError,[mbOk], 0);
    Exit;
  end;
end;

function TCMB.Save_(filen: TFileName):  boolean;
var
  FileHandle: Integer;
  str: string;
  astr: ansistring;
  buffer: PWideChar;
  i: integer;
begin

  // by MV 21.7.2016  try set decimal separator to "." in order to get around the problem of local system format settings
DecimalSeparator := '.';

    str := '/******************************************************************************/' + #13#10;
str:=str + '/* Batch file for meassuring characteristics of cell especialy for fuel cell. */' + #13#10;
str:=str + '/*                                                                            */' + #13#10;
str:=str + '/*                                 * * *                                      */' + #13#10;
str:=str + '/*                                                                            */' + #13#10;
str:=str + '/* In first part is options of the form for creating this file.  One  line is */' + #13#10;
str:=str + '/* description  and  next  line  is  value.  In the second part is data which */' + #13#10;
str:=str + '/* are shared for all box of data for batchnig.In third part is datablock for */' + #13#10;
str:=str + '/* individual parts from batch.  It is introduced by head and blocks  of data */' + #13#10;
str:=str + '/* are continuing.                                                            */' + #13#10;
str:=str + '/*                                                                            */' + #13#10;
str:=str + '/* Note: All values are in mV or mA and ms.                                   */' + #13#10;
str:=str + '/******************************************************************************/' + #13#10;
str:=str + '/* The first part:                                                            */' + #13#10;
str:=str + '/*----------------------------------------------------------------------------*/' + #13#10;
str:=str + '/* Are curves from the neighboring boxes connected? (boolean - 1 or 0)        */' + #13#10;
str:=str + 'ConectedLines»'+IntToStr(BoolToInt(FormAttr.ConectedLines))+ #13#10;
str:=str + '/* Are the value sweep "stair" terminated by "-" and no by "|"? (boolean 1/0) */' + #13#10;
str:=str + 'RampAtTheEnd»'+IntToStr(BoolToInt(FormAttr.RampAtTheEnd))+ #13#10;
str:=str + '/* What is the file name for save a massuring data? (string)                  */' + #13#10;
str:=str + 'TempFileName»'+FormAttr.TempFileName+ #13#10;
str:=str + '/* What is use for feedbacking? (string - Current/Voltage)                    */' + #13#10;
str:=str + 'TempFeedBack»'+FormAttr.TempFeedBack+ #13#10;
str:=str + '/* What is the type? (string - Const/From To)                                 */' + #13#10;
str:=str + 'TempProcessType»'+FormAttr.TempProcessType+ #13#10;
str:=str + '/* What is the duration? (int64)                                              */' + #13#10;
str:=str + 'TempDuration»'+IntToStr(FormAttr.TempDuration)+ #13#10;
str:=str + '/* What is the value which is helded? (double)                                */' + #13#10;
str:=str + 'TempConstV»'+FloatToStr(FormAttr.TempConstV)+ #13#10;
str:=str + '/* Is waiting for stability enabled? (boolean -1 or 0)                        */' + #13#10;
str:=str + 'TempWaitForStability»'+IntToStr(BoolToInt(FormAttr.TempWaitForStability))+ #13#10;
str:=str + '/* What is the tolerance for stability? (double)                              */' + #13#10;
str:=str + 'TempStability»'+FloatToStr(FormAttr.TempStability)+ #13#10;
str:=str + '/* Starting value for the value sweep (or stepping). (double)                 */' + #13#10;
str:=str + 'TempFrom»'+FloatToStr(FormAttr.TempFrom)+ #13#10;
str:=str + '/* Ending value for the value sweep (or stepping). (double)                   */' + #13#10;
str:=str + 'TempTo»'+FloatToStr(FormAttr.TempToV)+ #13#10;
str:=str + '/* Stap for the value sweep (or stepping). (double)                           */' + #13#10;
str:=str + 'TempStep»'+FloatToStr(FormAttr.TempStep)+ #13#10;
str:=str + '/* Delay between loading point. (integer)                                     */' + #13#10;
str:=str + 'TempDelayBtLoad»'+IntToStr(FormAttr.TempDelayBtLoad)+ #13#10;
str:=str + '                                                                                ' + #13#10;
str:=str + '/*----------------------------------------------------------------------------*/' + #13#10;
str:=str + '/* The second part:                                                           */' + #13#10;
str:=str + '/*----------------------------------------------------------------------------*/' + #13#10;
str:=str + '/* Low voltage limit. If it is reach the meassuring is stopped. (double)      */' + #13#10;
str:=str + 'LowVoltageLimit»'+FloatToStr(LowVoltageLimit)+ #13#10;
str:=str + '/* High voltage limit. If it is reach the meassuring is stopped. (double)     */' + #13#10;
str:=str + 'HighVoltageLimit»'+FloatToStr(HighVoltageLimit)+ #13#10;
str:=str + '/* Low current limit. If it is reach the meassuring is stopped. (double)      */' + #13#10;
str:=str + 'LowCurretLimit»'+FloatToStr(LowCurretLimit)+ #13#10;
str:=str + '/* High current limit. If it is reach the meassuring is stopped. (double)     */' + #13#10;
str:=str + 'HighCurretLimit»'+FloatToStr(HighCurretLimit)+ #13#10;
str:=str + '/* The repetition cycle. How many times can be cyclic. (int)                  */' + #13#10;
str:=str + 'NumOfRepeating»'+IntToStr(NumOfRepeating)+ #13#10;
str:=str + '/* The unit which is use for voltage. (uV, mV, V, kV)                         */' + #13#10;
str:=str + 'VoltageUnit»'+GetEnumName(TypeInfo(TVoltageUnit),Ord(VoltageUnit)) + #13#10;
str:=str + '/* The unit which is use for current. (uA, mA, A, kA)                         */' + #13#10;
str:=str + 'CurrentUnit»'+ GetEnumName(TypeInfo(TCurrentUnit),Ord(CurrentUnit)) + #13#10;
str:=str + '/* The unit which is use for time. (ms, s, min, h)                            */' + #13#10;
str:=str + 'TimeUnit»'+  GetEnumName(TypeInfo(TTimeUnit),Ord(TimeUnit)) + #13#10;
str:=str + '                                                                                ' + #13#10;
str:=str + '/*----------------------------------------------------------------------------*/' + #13#10;
str:=str + '/* The third part:                                                            */' + #13#10;
str:=str + '/*----------------------------------------------------------------------------*/' + #13#10;
str:=str + '/* What is the file name for save a massuring data? (string)                  */' + #13#10;
str:=str + '/* What is use for feedbacking? (string - Current/Voltage)                    */' + #13#10;
str:=str + '/* What is the type? (string - Const/From To)                                 */' + #13#10;
str:=str + '/* What is the duration? (int64)                                              */' + #13#10;
str:=str + '/* What is the value which is helded? (double)                                */' + #13#10;
str:=str + '/* Is waiting for stability enabled? (boolean -1 or 0)                        */' + #13#10;
str:=str + '/* What is the tolerance for stability? (double)                              */' + #13#10;
str:=str + '/* Starting value for the value sweep (or stepping). (double)                 */' + #13#10;
str:=str + '/* Ending value for the value sweep (or stepping). (double)                   */' + #13#10;
str:=str + '/* Stap for the value sweep (or stepping). (double)                           */' + #13#10;
str:=str + '/* Duration of individual steps in the value sweep. (integer)                 */' + #13#10;
str:=str + '/* Delay between loading point. (integer)                                     */' + #13#10;
str:=str + '/* Repeating individual characteristic. (boolean - 1/0)                       */' + #13#10;
str:=str + '                                                                                ' + #13#10;

for i:=0 to ListOfBatch.Count-1 do begin
str:=str + 'ID»'+IntToStr(i)+ #13#10;
str:=str + 'FileName»'+PTBatch(ListOfBatch[i]).FileName+ #13#10;
str:=str + 'FeedBack»'+PTBatch(ListOfBatch[i]).FeedBack+ #13#10;
str:=str + 'ProcessType»'+PTBatch(ListOfBatch[i]).ProcessType+ #13#10;
str:=str + 'Duration»'+IntToStr(PTBatch(ListOfBatch[i]).Duration)+ #13#10;
str:=str + 'ConstV»'+FloatToStr(PTBatch(ListOfBatch[i]).ConstV)+ #13#10;
str:=str + 'WaitForStability»'+IntToStr(BoolToInt(PTBatch(ListOfBatch[i]).WaitForStability))+ #13#10;
str:=str + 'Stability»'+FloatToStr(PTBatch(ListOfBatch[i]).Stability)+ #13#10;
str:=str + 'From»'+FloatToStr(PTBatch(ListOfBatch[i]).From)+ #13#10;
str:=str + 'To»'+FloatToStr(PTBatch(ListOfBatch[i]).ToV)+ #13#10;
str:=str + 'Step»'+FloatToStr(PTBatch(ListOfBatch[i]).Step)+ #13#10;
str:=str + 'TimeOfStep»'+FloatToStr(PTBatch(ListOfBatch[i]).TimeOfStep)+ #13#10;
str:=str + 'DelayBtLoad»'+IntToStr(PTBatch(ListOfBatch[i]).DelayBtLoad)+ #13#10;
str:=str + 'CycleChar»'+IntToStr(BoolToInt(PTBatch(ListOfBatch[i]).CycleChar))+ #13#10;
str:=str + '                                                                                ' + #13#10;
end;

    astr := AnsiString(str);
    //buffer := PAnsiChar(astr);

    //ListOfBatch: TList;

    FileHandle := FileCreate(filen);
    if(FileHandle > 0 ) then begin
      FileName := filen;
      if(FileWrite(FileHandle, astr[1], Length(astr) ) <> -1) //      if(FileWrite(FileHandle,buffer,Length(str) * SizeOf(ansichar)) <> -1)
        then begin FileClose(FileHandle); FileName := filen; Result := True; end
        else begin FileClose(FileHandle); Result := False; end;
    end else begin
      FileClose(FileHandle);
      Result := False;
    end;
end;

function TCMB.FileNameEx: boolean;
begin
    If FileName <> '' then Result := True else Result := False;
end;

function TCMB.ReadyForUse: boolean;
begin
  If FileName <> '' then Result := True else Result := False;
end;

function TCMB.BoolToInt(b: boolean): integer;
begin
  If(b)then Result := 1 else Result := 0;
end;

function TCMB.IntToBool(i: integer): boolean;
begin
  if(i = 1) then Result := True else Result := False;          //tohle je teda dost divne udelane, vymyka se standardu
end;

procedure TCMB.Close;
begin
  FileName := '';
end;

procedure TCMB.MultipleValue(FeedBack: string; multiple: real);
var
  i: integer;
  Batch: TBatch;
begin
  if(FeedBack = 'Current')then begin
    LowCurretLimit := LowCurretLimit * multiple;
    HighCurretLimit := HighCurretLimit * multiple;
    if(FormAttr.TempFeedBack = 'Current')then
     with FormAttr do begin
      TempConstV := TempConstV * multiple;
      TempStability := TempStability * multiple;
      TempFrom := TempFrom * multiple;
      TempToV := TempToV * multiple;
      TempStep := TempStep * multiple;
     end;
    for i:= 0 to ListOfBatch.Count - 1 do begin
     if(PTBatch(ListOfBatch[i]).FeedBack = 'Current')then begin
      Batch := PTBatch(ListOfBatch[i])^;
        with Batch do begin
          ConstV := ConstV * multiple;
          Stability := Stability * multiple;
          From := From * multiple;
          ToV := ToV * multiple;
          Step := Step * multiple;
        end;
       PTBatch(ListOfBatch[i])^ := Batch;
      end;
    end;
  end else begin
    LowVoltageLimit := LowVoltageLimit * multiple;
    HighVoltageLimit := HighVoltageLimit * multiple;
    if(FormAttr.TempFeedBack = 'Voltage')then
     with FormAttr do begin
      TempConstV := TempConstV * multiple;
      TempStability := TempStability * multiple;
      TempFrom := TempFrom * multiple;
      TempToV := TempToV * multiple;
      TempStep := TempStep * multiple;
     end;
    for i:= 0 to ListOfBatch.Count - 1 do begin
     if(PTBatch(ListOfBatch[i]).FeedBack = 'Voltage')then begin
      Batch := PTBatch(ListOfBatch[i])^;
        with Batch do begin
          ConstV := ConstV * multiple;
          Stability := Stability * multiple;
          From := From * multiple;
          ToV := ToV * multiple;
          Step := Step * multiple;
        end;
       PTBatch(ListOfBatch[i])^ := Batch; 
      end;
    end;
  end;
end;

procedure TCMB.MultipleCurrent(multiple: real);
begin
  MultipleValue('Current',multiple);
end;

procedure TCMB.MultipleVoltage(multiple: real);
begin
  MultipleValue('Voltage',multiple);
end;

procedure TCMB.MultipleTime(multiple: real);
var
  i: integer;
  Batch: TBatch;
begin
  with FormAttr do begin
    TempDuration := Round(TempDuration * multiple);
    TempDelayBtLoad := Round(TempDelayBtLoad * multiple);
  end;
  for i:= 0 to ListOfBatch.Count - 1 do begin
   Batch := PTBatch(ListOfBatch[i])^;
   with Batch do begin
    Duration := Round(Duration * multiple);
    DelayBtLoad := Round(DelayBtLoad * multiple);
   end;
  end;
end;

function TCMB.GetRelayState(BatchID: int64): string; //return relay state- "FullConect" if feedback is Voltage or Current // "Disconnect" if feedback is "Disconnect" // "OnlyVoltageLoad" if feedback is "OnlyVoltageLoad"
begin
  //input must be correct
  if(BatchID >= ListOfBatch.Count) then begin
    MessageDlg('GetRelayState: index of LilstOfBatch is overflowed.', mtError,[mbOk], 0);
    Result := '';
    Exit;
  end;
  //Body
  if( (PTBatch(ListOfBatch[BatchID]).FeedBack = 'Current') or (PTBatch(ListOfBatch[BatchID]).FeedBack = 'Voltage'))then begin Result := 'FullConnect'; Exit; end;
  if(PTBatch(ListOfBatch[BatchID]).FeedBack = 'Disconnect')then begin Result := 'Disconnect'; Exit; end;
  if(PTBatch(ListOfBatch[BatchID]).FeedBack = 'OnlyVoltageLoad')then begin Result := 'OnlyVoltageLoad'; Exit; end;
  MessageDlg('GetRelayState: Uknow feed back type.', mtError,[mbOk], 0);
  Result := ''
end;

// ----- From construct ----------

procedure TSetDataForm.FormCreate(Sender: TObject);
begin
  PFileName_ParentPointer_IsInitialized := False;
  PCMB_ParnetPointer_IsInitialized := False;
  Position := poScreenCenter;

  SetBlock1 := TSetBlock.Create(SetDataForm);
  with SetBlock1 do
    begin
    Left := 0;
    Top := 332;
    Width := 168;
    Height := 344;
    TabOrder := 5;
    Visible := False;
    OnClick := SetBlock1Click;
    OnDblClick := SetBlock1DblClick;
    V_InitialDir := 'C:\';
    V_Id := 9;
    V_FeedBack := 'Current';
    V_ProcessType := 'Const';
    V_Time := 60000          ;
    V_Const := 100.000000000000000000;
    V_WaitForStability := False       ;
    V_Stability := 50.000000000000000000;
    V_From := 100.000000000000000000     ;
    V_To := 200.000000000000000000        ;
    V_Step := 25.000000000000000000        ;
    V_DelayBtLoad := 500                    ;
    S_Width := 168                           ;
    S_BgCOnEnter := clActiveBorder            ;
    S_CurrentUnit := mA                        ;
    S_VoltageUnit := V                          ;
    S_TimeUnit := ms                             ;
    S_DecPoint := '.'                             ;
    S_RampAtTheEnd := False                        ;
    OnKeyDown := SetBlock1KeyDown                   ;
    OnChange := SetBlockChange                       ;
   end;



  SetDataForm.Caption := ProgName;
  SetDataForm.Height := BoxHeight + 36;
  SetDataForm.Width := SetBlock1.Width + BoxWidth + 13;
  Delta := BoxWidth;
  Selected_ID := -1;
  //
  BlockList := TList.Create;
  //
  SetBlock1.Visible := True;
  SetBlock1.OnChange := SetBlockChange;
  SetBlock1.Left := 0;
  //SetBlock1.OnKeyDown := SetBlockKeyDown;
  //SetBlock1.OnClick := SetBlockClick;
  ScrollBox1.Top := 0;
  ScrollBox1.Left := SetBlock1.Width;
  ScrollBox1.Width := BoxWidth+4;
  ScrollBox1.Height := BoxHeight;
  ScrollBox1.DoubleBuffered := True;
  ImageWidth := BoxWidth;
  //
  MyBitmap:=TBitmap.Create;
  //
  MyBitmap.Width := BoxWidth;
  MyBitmap.Height := BlockTop;
  Image1.Picture.Bitmap.Assign(MyBitmap);
  Image1.Width := BoxWidth;
  Image1.Height := BlockTop;
  Image1.Top := 0;
  Image1.Left := 0;
  ConectConstLine := CConectConstLine;
  RampAtTheEnd := CRampAtTheEnd;
  SetBlock1.S_RampAtTheEnd := RampAtTheEnd;
  CheckBox2.Checked := RampAtTheEnd;
  CheckBox1.Checked := ConectConstLine;
  SetBlock1.Visible := true;
  SetBlock1.S_DecPoint := '.';
  SetBlock1.V_CycleChar := CycleChar_C;

  CUnit.Items.Add('uA');
  CUnit.Items.Add('mA');
  CUnit.Items.Add('A');
  CUnit.Items.Add('kA');
  VUnit.Items.Add('uV');
  VUnit.Items.Add('mV');
  VUnit.Items.Add('V');
  VUnit.Items.Add('kV');
  TUnit.Items.Add('ms');
  TUnit.Items.Add('s');
  TUnit.Items.Add('min');
  TUnit.Items.Add('h');

  CUnitV := mA;
  VUnitV := V;
  TUnitV := ms;
  CUnit.ItemIndex := 1;
  VUnit.ItemIndex := 2;
  Label5.Caption := '[V]';
  LowVoltageLimit := LowVoltageLimit_C;
  HighVoltageLimit := HighVoltageLimit_C;
  LowCurretLimit := LowCurretLimit_C;
  HighCurretLimit := HighCurretLimit_C;
  Edit1.Text := FloatToStr(LowVoltageLimit);

  TUnit.ItemIndex := 0;

  Cycling.MaxValue := MaxInt;
  NumOfRepeating := 1;
  Cycling.Value := NumOfRepeating;

  OpenDialog1.InitialDir := GetCurrentDir;
  OpenDialog1.Options := [ofFileMustExist,ofHideReadOnly];
  OpenDialog1.Filter :=
    'Cell massuring batch file *.cmb|*.cmb|Text files *.txt|*.txt|Any files *.*|*.*';
  OpenDialog1.FilterIndex := 1;

  SaveDialog1.InitialDir := GetCurrentDir;
  SaveDialog1.Options := [ofHideReadOnly];
  SaveDialog1.Filter :=
    'Cell massuring batch file *.cmb|*.cmb|Text files *.txt|*.txt';
  SaveDialog1.FilterIndex := 1;
  SaveDialog1.DefaultExt := 'cmb';

  //
  CMB := TCMB.Create;
  marknotdestroycmb := false;
  //
  ChangedIsFrozen := false;
  //Contact.Caption := 'romandotfiala@gmail.com';

  Replot;
  logmsg('TSetDataForm.FormCreate done.');
end;

// ------ Form Destroy  -------

procedure TSetDataForm.FormDestroy(Sender: TObject);
var
  index, i: integer;
begin
  //Clear BlockList
  index := BlockList.Count - 1;
  ForDelete := 0;
  for i:= 0 to index do DeleteKomponent;
  ForDelete := -1;
  //TCMB
  if not marknotdestroycmb then CMB.Free; // otherwise will be destoryed in main form
  //MyBitmap
  MyBitmap.Free;
  //BlockList
  BlockList.Clear;
  BlockList.Free;
  //
  Inherited;
end;



























//------------ Grapic ---------------

















procedure TSetDataForm.ReplotBg(sections: integer; HStep: integer; VStep: integer);
var
  P, LastP, origin : TPoint;
  i, j: integer;
  ValueIntervalC: TValInt;
  ValueIntervalV: TValInt;
  ValInt: TValInt;
  DX, DY: real;
  PR,FromR, ToR : TRPoint;
  HPosR: real;
  ToPFT: integer;
  Exeption: boolean;
  Rec: TRect;
  f: TFont;
begin
 //resize
 MyBitmap.Width := ImageWidth;
 MyBitmap.Height := BlockTop;

 //bg
 with MyBitmap.Canvas do
  begin
   Brush.Color := GraphBg;
   Brush.Style := bsSolid;
   FillRect(rect(0,0,ImageWidth,BlockTop));
  end;

 //HLines
 origin.X := 1;
 HPosR := - HStep / 2;
 origin.Y := Round(HPosR);
 i := 0;
 while (origin.Y < BlockTop) do begin
    i := i+1;
    HPosR := HPosR + HStep;
    origin.Y := Round(HPosR);
    with MyBitmap.Canvas do
      begin
        if((i mod 2) = 1)then begin
          Pen.Color := GraphHGrid;
          Pen.Style := psSolid;
          Pen.Width := 1;
        end else begin
          Pen.Color := clTeal;
          Pen.Style := psDash;
          Pen.Width := 1;
        end;
        MoveTo(origin.X, origin.Y);
        LineTo(ImageWidth-1, origin.Y);
      end;
 end;

 //VLines
 origin.X := 0;
 origin.Y := 1;
 i := 0;
 while (origin.X < ImageWidth) do begin
    i := i + 1;
    origin.X := Round(origin.X + VStep);
    with MyBitmap.Canvas do
      begin
        if((i mod 2) = 1)then begin
          Pen.Color := GraphHGrid;
          Pen.Style := psSolid;
          Pen.Width := 1;
        end else begin
          Pen.Color := clTeal;
          Pen.Style := psDash;
          Pen.Width := 1;
        end;
        MoveTo(origin.X, origin.Y);
        LineTo(origin.X, BlockTop-1);
      end;
 end;

 //Sections
 for i := 2 to sections do
 begin
   origin := Point(ImageWidth div sections, 1);
    with MyBitmap.Canvas do
      begin
        Pen.Color := GraphSect;
        Pen.Style := psSolid;
        Pen.Width := 2;
        MoveTo(origin.X * (i-1),1);
        LineTo(origin.X * (i-1), BlockTop-1);
      end;
 end;

 //Plot
 P.X := 0;
 P.Y := 0;
 PR.X := 0;
 PR.Y := 0;
 DX := 0;
 DY := 0;
 j:=0;
 i:=0;
 if (sections > 0) then
 begin
  ValueIntervalC := ValueInterval('Current');
  ValueIntervalV := ValueInterval('Voltage');
  for i := 0 to BlockList.Count - 1 do begin
    LastP := P;
    Exeption := false;
    SetBlock := BlockList.Items[i];
    if(SetBlock.V_FeedBack = 'Current')
     then ValInt := ValueIntervalC
     else ValInt := ValueIntervalV; 
     //MessageDlg('ValIn: '+FloatToStr(ValInt.Max)+'; '+FloatToStr(ValInt.Min)+', '+FloatToStr(ValInt.Difer)+'.', mtInformation, [mbOk], 0);


    if(SetBlock.V_Time = 0)then begin
          with MyBitmap.Canvas do begin
            f := Font;
            Font.Size := 24;
            Font.Color := clMaroon;
            TextOut(ImageWidth * i div sections + (ImageWidth div sections - 165 ) div 2,150,'Not correct!');
            Font := f;
          end;
    end else begin

      //ProcessType = From To
      if( (SetBlock.V_ProcessType = 'From To') and ( (SetBlock.V_From = SetBlock.V_To) or (SetBlock.V_Step = 0) ) )
      then begin
          ChangedIsFrozen := True;
          SetBlock.V_Const := SetBlock.V_From;
          ChangedIsFrozen := False;
          Exeption := True;
          with MyBitmap.Canvas do begin
            f := Font;
            Font.Size := 24;
            Font.Color := clMaroon;
            TextOut(ImageWidth * i div sections + (ImageWidth div sections - 165 ) div 2,150,'Not correct!');
            Font := f;
          end;
      end else begin //zacatek ifu
        if(SetBlock.V_ProcessType = 'From To') then begin
          FromR.X := ImageWidth * i / sections;
          ToR.X := ImageWidth * (i+1) / sections;
          FromR.Y := BlockTop - (BlockTop * SizeY) * Abs(SetBlock.V_From - ValInt.Min) / ValInt.Difer  - (BlockTop * (1 - SizeY) / 2);
          ToR.Y := BlockTop - (BlockTop * SizeY) * Abs(SetBlock.V_To - ValInt.Min) / ValInt.Difer  - (BlockTop * (1 - SizeY) / 2);
          if(SetBlock.V_From <> SetBlock.V_To) then begin
            if not RampAtTheEnd then begin
              DX := (SetBlock.S_Width * SetBlock.V_Step / Abs(SetBlock.V_From - SetBlock.V_To));
              ToPFT := Round(Abs(SetBlock.V_From - SetBlock.V_To) / SetBlock.V_Step);
            end else begin
              DX := (SetBlock.S_Width / (Abs(SetBlock.V_From - SetBlock.V_To) / SetBlock.V_Step +1));
              ToPFT := Round(Abs(SetBlock.V_From - SetBlock.V_To) / SetBlock.V_Step);
            end;
            DY := ((ToR.Y - FromR.Y)* SetBlock.V_Step / Abs(SetBlock.V_From - SetBlock.V_To));
          end else begin
            DX := 0;
            DY := 0;
          end;
          //MessageDlg('ValIn: '+IntToStr(Round(FromR.X))+'; '+IntToStr(Round(FromR.Y))+', '+IntToStr(Round(ToR.X))+', '+IntToStr(Round(ToR.Y))+', '+IntToStr(Round(DX))+', '+IntToStr(Round(DY))+'.', mtInformation, [mbOk], 0);
          with MyBitmap.Canvas do begin
            PR.X := FromR.X;
            PR.Y := FromR.Y;
            if(ConectConstLine and(i>0))
              then begin MoveTo(Round(PR.X),LastP.Y); Pen.Width := 1; Pen.Style := psDash; LineTo(Round(PR.X),Round(PR.Y)) end
              else MoveTo(Round(PR.X),Round(PR.Y));
            if(SetBlock.V_FeedBack = 'Current')
              then Pen.Color := GraphColorC
              else Pen.Color := GraphColorV;
            Pen.Style := psSolid;
            Pen.Width := 3;
            //MessageDlg('ValIn 1: '+IntToStr(Round(PR.X + DX))+', '+IntToStr(Round(PR.Y + DY))+'.', mtInformation, [mbOk], 0);
            for j:=1 to ToPFT do begin
              LineTo(Round(PR.X + DX), Round(PR.Y));
              LineTo(Round(PR.X + DX),Round(PR.Y + DY));
              //MessageDlg('ValIn 2: '+IntToStr(Round(PR.X + DX))+', '+IntToStr(Round(PR.Y + DY))+'.', mtInformation, [mbOk], 0);
              PR.X := PR.X+DX;
              PR.Y := PR.Y+DY;
            end;
            if RampAtTheEnd then begin PR.X := PR.X+DX; LineTo(Round(PR.X),Round(PR.Y)) end;
          end;
          P.X := Round(PR.X);
          P.Y := Round(PR.Y);
        end;
      end; // konec ifu


      //ProcessType = Const
      if(SetBlock.V_ProcessType = 'Const')or(Exeption) then begin
        P := Point(Round(ImageWidth * i / sections), BlockTop - Round((BlockTop * SizeY) * Abs(SetBlock.V_Const - ValInt.Min) / ValInt.Difer ) - Round(BlockTop * (1 - SizeY) / 2));
        with MyBitmap.Canvas do
          begin
            if(SetBlock.V_FeedBack = 'Current')
              then Pen.Color := GraphColorC
              else Pen.Color := GraphColorV;
            if(ConectConstLine and(i>0))
              then begin MoveTo(P.X,LastP.Y); Pen.Width := 1; Pen.Style := psDash; LineTo(P.X,P.Y) end
              else MoveTo(P.X,P.Y);
            Pen.Style := psSolid;
            Pen.Width := 3;
            P := Point(P.X + ImageWidth div sections, P.Y);
            LineTo(P.X,P.Y);
          end;
      end;

    end;

  end;

 end;


 Image1.Picture.Bitmap.Assign(MyBitmap);
 Image1.Width := MyBitmap.Width;
 Image1.Height := MyBitmap.Height;
end;


function TSetDataForm.ValueInterval(Feedback: string): TValInt;
var
  i: integer;
  Val: TValInt;
begin
    Val.Max := 0;
    Val.Min := MaxDouble;
    Val.Difer := MaxDouble;
  if(BlockList.Count > 0) then begin
    if(Feedback = 'Current')then
    begin
      for i:=0 to BlockList.Count-1 do begin
        if(Feedback = TSetBlock(BlockList[i]).V_FeedBack)then begin
          if(TSetBlock(BlockList[i]).V_ProcessType = 'Const') then begin
            if TSetBlock(BlockList[i]).V_Const > Val.Max then Val.Max := TSetBlock(BlockList[i]).V_Const;
            if TSetBlock(BlockList[i]).V_Const < Val.Min then Val.Min := TSetBlock(BlockList[i]).V_Const;
          end else if(TSetBlock(BlockList[i]).V_ProcessType = 'From To')then begin
            if TSetBlock(BlockList[i]).V_From > Val.Max then Val.Max := TSetBlock(BlockList[i]).V_From;
            if TSetBlock(BlockList[i]).V_To > Val.Max then Val.Max := TSetBlock(BlockList[i]).V_To;
            if TSetBlock(BlockList[i]).V_From < Val.Min then Val.Min := TSetBlock(BlockList[i]).V_From;
            if TSetBlock(BlockList[i]).V_To < Val.Min then Val.Min := TSetBlock(BlockList[i]).V_To;
          end else MessageDlg('Unknown process type: '+TSetBlock(BlockList[i]).V_ProcessType+'.', mtError, [mbOk], 0);
        end;
      end;
      val.Difer := Val.Max - Val.min;
      if(val.Difer = 0) then
      begin
        if(Val.Min = MaxDouble)then Val.Min := 0;
        Val.Max := Val.Min + 500;
        Val.Difer := Val.Max - Val.min;
      end;
      Result := Val;
    end else if (Feedback = 'Voltage') then begin
      for i:=0 to BlockList.Count-1 do begin
        if(Feedback = TSetBlock(BlockList[i]).V_FeedBack)then begin
          if(TSetBlock(BlockList[i]).V_ProcessType = 'Const') then begin
            if TSetBlock(BlockList[i]).V_Const > Val.Max then Val.Max := TSetBlock(BlockList[i]).V_Const;
            if TSetBlock(BlockList[i]).V_Const < Val.Min then Val.Min := TSetBlock(BlockList[i]).V_Const;
          end else if(TSetBlock(BlockList[i]).V_ProcessType = 'From To')then begin
            if TSetBlock(BlockList[i]).V_From > Val.Max then Val.Max := TSetBlock(BlockList[i]).V_From;
            if TSetBlock(BlockList[i]).V_To > Val.Max then Val.Max := TSetBlock(BlockList[i]).V_To;
            if TSetBlock(BlockList[i]).V_From < Val.Min then Val.Min := TSetBlock(BlockList[i]).V_From;
            if TSetBlock(BlockList[i]).V_To < Val.Min then Val.Min := TSetBlock(BlockList[i]).V_To;
          end else MessageDlg('Unknown process type: '+TSetBlock(BlockList[i]).V_ProcessType+'.', mtError, [mbOk], 0);
        end;
      end;
      val.Difer := Val.Max - Val.min;
      if(val.Difer = 0) then
      begin
        if(Val.Min = MaxDouble)then Val.Min := 0;
        Val.Max := Val.Min + 500;
        Val.Difer := Val.Max - Val.min;
      end;
      Result := Val;
    end else begin
      MessageDlg('Unknown feed back: '+Feedback+'.', mtError, [mbOk], 0);
      Val.Difer := MaxDouble; Result := Val;
    end;
  end else begin
    MessageDlg('BlockList is empty.', mtError, [mbOk], 0);
    Result := Val;
  end;
end;

// ------- Refreshing of graph and komonent size and position
procedure TSetDataForm.Replot;
var
  index: integer;
begin
  index := BlockList.Count;
  if(index > 0) then
    case index of
    1: ReplotBg(index,30,50);
    2: ReplotBg(index,30,50);
    3: ReplotBg(index,30,60);
    4: ReplotBg(index,30,45);
    5: ReplotBg(index,30,45);
    else ReplotBg(index,30,45);
  end else ReplotBg(0,30,50);
end;

procedure TSetDataForm.RearangeBlock;
var
  index, scroll : integer;
  i: integer;
begin
  scroll := ScrollBox1.HorzScrollBar.Position;
  ScrollBox1.HorzScrollBar.Position := 0;
  index := BlockList.Count-1;
  for i := 0 to index do TSetBlock(BlockList[i]).V_Id := i;
  SetBlock := BlockList.Items[index];
  case index of
    0 : begin
          Delta := BoxWidth;
          SetBlock.Left := BlockLeft;
          SetBlock.S_Width := BoxWidth;
          SetBlock.Top := BlockTop;
          SetBlock.Visible := True;
          SetBlock.OnChange := SetBlockChange;
          SetBlock.OnKeyDown := SetBlockKeyDown;
          SetBlock.OnClick := SetBlockClick;
          SetBlock.OnDblClick := SetBlockDblClick;
          SetBlock.ShowHint := ShowHintB;
          SetBlock.Hint := StrHint;
          SetBlock.V_CycleChar := CycleChar_C;
          SetBlock1.V_InitialDir := SetBlock1.V_InitialDir;
          SetBlock.V_Id := index;
          //ReplotBg(index+1,40,50);
        end;
    1 : begin
          Delta := BoxWidth div 2;
          SetBlock.Left := BlockLeft + Delta;
          SetBlock.S_Width := Delta;
          SetBlock.Top := BlockTop;
          SetBlock.Visible := True;
          SetBlock.OnChange := SetBlockChange;
          SetBlock.OnKeyDown := SetBlockKeyDown;
          SetBlock.OnClick := SetBlockClick;
          SetBlock.OnDblClick := SetBlockDblClick;
          SetBlock.ShowHint := ShowHintB;
          SetBlock.Hint := StrHint;
          SetBlock.V_CycleChar := CycleChar_C;
          SetBlock1.V_InitialDir := SetBlock1.V_InitialDir;
          SetBlock.V_Id := index;
          SetBlock := BlockList.Items[0];
          SetBlock.Left := BlockLeft;
          SetBlock.S_Width := Delta;
          //ReplotBg(index+1,40,50);
        end;
    2 : begin
          Delta := BoxWidth div 3;
          SetBlock.Left := BlockLeft + 2 * Delta;
          SetBlock.S_Width := Delta;
          SetBlock.Top := BlockTop;
          SetBlock.Visible := True;
          SetBlock.OnChange := SetBlockChange;
          SetBlock.OnKeyDown := SetBlockKeyDown;
          SetBlock.OnClick := SetBlockClick;
          SetBlock.OnDblClick := SetBlockDblClick;
          SetBlock.ShowHint := ShowHintB;
          SetBlock.Hint := StrHint;
          SetBlock.V_CycleChar := CycleChar_C;
          SetBlock1.V_InitialDir := SetBlock1.V_InitialDir;
          SetBlock.V_Id := index;
          SetBlock := BlockList.Items[0];
          SetBlock.Left := BlockLeft;
          SetBlock.S_Width := Delta;
          SetBlock := BlockList.Items[1];
          SetBlock.Left := BlockLeft + Delta;
          SetBlock.S_Width := Delta;
          //ReplotBg(index+1,40,60);
        end;
    3 : begin
          Delta := BoxWidth div 4;
          SetBlock.Left := BlockLeft + 3 * Delta;
          SetBlock.S_Width := Delta;
          SetBlock.Top := BlockTop;
          SetBlock.Visible := True;
          SetBlock.OnChange := SetBlockChange;
          SetBlock.OnKeyDown := SetBlockKeyDown;
          SetBlock.OnClick := SetBlockClick;
          SetBlock.OnDblClick := SetBlockDblClick;
          SetBlock.ShowHint := ShowHintB;
          SetBlock.Hint := StrHint;
          SetBlock.V_CycleChar := CycleChar_C;
          SetBlock1.V_InitialDir := SetBlock1.V_InitialDir;
          SetBlock.V_Id := index;
          SetBlock := BlockList.Items[0];
          SetBlock.Left := BlockLeft;
          SetBlock.S_Width := Delta;
          SetBlock := BlockList.Items[1];
          SetBlock.Left := BlockLeft + Delta;
          SetBlock.S_Width := Delta;
          SetBlock := BlockList.Items[2];
          SetBlock.Left := BlockLeft + 2 * Delta;
          SetBlock.S_Width := Delta;
          //ReplotBg(index+1,40,45);
        end;
    4 : begin
          Delta := BoxWidth div 5;
          SetBlock.Left := BlockLeft + 4 * Delta;
          SetBlock.S_Width := Delta;
          SetBlock.Top := BlockTop;
          SetBlock.Visible := True;
          SetBlock.OnChange := SetBlockChange;
          SetBlock.OnKeyDown := SetBlockKeyDown;
          SetBlock.OnClick := SetBlockClick;
          SetBlock.OnDblClick := SetBlockDblClick;
          SetBlock.ShowHint := ShowHintB;
          SetBlock.Hint := StrHint;
          SetBlock.V_CycleChar := CycleChar_C;
          SetBlock1.V_InitialDir := SetBlock1.V_InitialDir;
          SetBlock.V_Id := index;
          SetBlock := BlockList.Items[0];
          SetBlock.Left := BlockLeft;
          SetBlock.S_Width := Delta;
          SetBlock := BlockList.Items[1];
          SetBlock.Left := BlockLeft + Delta;
          SetBlock.S_Width := delta;
          SetBlock := BlockList.Items[2];
          SetBlock.Left := BlockLeft + 2 * Delta;
          SetBlock.S_Width := delta;
          SetBlock := BlockList.Items[3];
          SetBlock.Left := BlockLeft + 3 * Delta;
          SetBlock.S_Width := Delta;
          //ReplotBg(index+1,40,45);
        end;
    else
    begin
      Delta := BoxWidth div 5;
      for i := 0 to BlockList.Count-1 do
      begin
        TSetBlock(BlockList[i]).Left := BlockLeft + BlockLeftD * (i);
        TSetBlock(BlockList[i]).Top := BlockTop;
        TSetBlock(BlockList[i]).S_Width := BlockLeftD;
        TSetBlock(BlockList[i]).Visible := True;
        TSetBlock(BlockList[i]).OnChange := SetBlockChange;
        TSetBlock(BlockList[i]).OnKeyDown := SetBlockKeyDown;
        TSetBlock(BlockList[i]).OnClick := SetBlockClick;
        TSetBlock(BlockList[i]).OnDblClick := SetBlockDblClick;
        TSetBlock(BlockList[i]).ShowHint := ShowHintB;
        TSetBlock(BlockList[i]).Hint := StrHint;
        TSetBlock(BlockList[i]).V_CycleChar := CycleChar_C;
        TSetBlock(BlockList[i]).V_InitialDir := SetBlock1.V_InitialDir;
        TSetBlock(BlockList[i]).V_Id := i;
      end;
      ImageWidth := ImageWidth + BlockLeftD;
      //ReplotBg(index+1,40,45);
    end;
  end;
  ScrollBox1.HorzScrollBar.Position := scroll;
end;



//------- OnChange --------------
procedure TSetDataForm.SetBlockChange(Sender: TObject);
begin
  if(ChangedIsFrozen)then Exit;
  with Sender as TSetBlock do begin
    if((S_Step.Text = '0')and(V_ProcessType = 'From To'))then MessageDlg('Step cannot be zero! Use process type: "Const" or change value.', mtInformation, [mbOk], 0);
    if((V_From = V_To)and(V_ProcessType = 'From To')) then MessageDlg('Value ''From'' cannot be equal to ''To''! Use process type: "Const" or change values.', mtInformation, [mbOk], 0);
    if(V_Time = 0) then MessageDlg('Duration cannot be zero !', mtInformation, [mbOk], 0);
  end;
  ReInitDirForAllBoxes;
  Replot;
end;

//--------- OnCLick ------------
procedure TSetDataForm.SetBlockClick(Sender: TObject);
begin
  ClickMethod(Sender);
end;

procedure  TSetDataForm.ClickMethod(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to BlockList.Count-1 do TSetBlock(BlockList[i]).Color := clBtnFace;
  with Sender as TSetBlock do begin
    Selected_ID := V_Id;
    Color := S_BgCOnEnter;
  end;
end;

//------ OnDblClick -------------
procedure TSetDataForm.SetBlockDblClick(Sender: TObject);
begin
  // do OnClick + make copy of object to themplate in the left
  ClickMethod(Sender);
  ChangedIsFrozen := True;
  with Sender as TSetBlock do begin
    SetBlock1.V_FileName := V_FileName;
    SetBlock1.S_FeedBack.ItemIndex := S_FeedBack.ItemIndex;
    SetBlock1.S_ProcessType.ItemIndex := S_ProcessType.ItemIndex;
    SetBlock1.ProcessTypeForChange;
    SetBlock1.S_Time.Text := S_Time.Text;
    SetBlock1.S_Const.Text := S_Const.Text;
    SetBlock1.S_WaitForStability.Checked := S_WaitForStability.Checked;
    SetBlock1.S_Stability.Text := S_Stability.Text;
    SetBlock1.S_From.Text := S_From.Text;
    ChangedIsFrozen := False;
    SetBlock1.S_To.Text := S_To.Text;
    SetBlock1.S_Step.Text := S_Step.Text;
    SetBlock1.S_DelayBtLoad.Text := S_DelayBtLoad.Text;

    SetBlock1.S_CurrentUnit := S_CurrentUnit;
    SetBlock1.S_VoltageUnit := S_VoltageUnit;
    SetBlock1.S_TimeUnit := S_TimeUnit;
    SetBlock1.S_DecPoint := S_DecPoint;
  end;
end;

//----- Key Press -----------
procedure TSetDataForm.SetBlockKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //MessageDlg('Key press: '+IntToStr(Ord(Key))+'.', mtInformation, [mbOk], 0);
  if(Ord(Key) = 46)then begin   //46 means DELETE
    if(Sender is TSetBlock) then
      with Sender as TSetBlock do begin
        if(BlockList.Count-1 < V_Id)
              then MessageDlg('Index: '+IntToStr(V_Id)+' from '+IntToStr(BlockList.Count-1) + ' is nonsence!', mtError, [mbOk], 0)
              else begin
                ForDelete := V_Id;
                Timer1.Enabled := True;
               // Free;
              end;
      end;
  end;
  if(Ord(Key) = 13)then Replot;
  If(Ord(Key) = F2) then InsertL;
  If(Ord(Key) = F3) then InsertR;
  If(Ord(Key) = F4) then Add;
end;

//------ Delete -----------
procedure TSetDataForm.DeleteKomponent;
var
  i: integer;
  PrevLeft : integer;
  scroll: integer;
begin
  scroll := ScrollBox1.HorzScrollBar.Position;
  ScrollBox1.HorzScrollBar.Position := 0;
  //Timer1.Enabled := false;
  TSetBlock(BlockList[ForDelete]).Free;
  if(BlockList.Count > 5)then ImageWidth := ImageWidth - BlockLeftD;
  BlockList.Delete(ForDelete);
  for i:= 0 to BlockList.Count-1 do begin
    TSetBlock(BlockList[i]).V_Id := i;
  end;
  case BlockList.Count-1 of
    0: begin
         Delta := BoxWidth;
         PrevLeft := -Delta;
         for i:=0 to BlockList.Count -1 do
         begin
          PrevLeft := PrevLeft + Delta;
          TSetBlock(BlockList[i]).Left := PrevLeft;
          TSetBlock(BlockList[i]).S_Width := Delta;
         end;
       end;
    1: begin
         Delta := BoxWidth div 2;
         PrevLeft := -Delta;
         for i:=0 to BlockList.Count -1 do
         begin
          PrevLeft := PrevLeft + Delta;
          TSetBlock(BlockList[i]).Left := PrevLeft;
          TSetBlock(BlockList[i]).S_Width := Delta;
         end;
       end;
    2: begin
         Delta := BoxWidth div 3;
         PrevLeft := -Delta;
         for i:=0 to BlockList.Count -1 do
         begin
          PrevLeft := PrevLeft + Delta;
          TSetBlock(BlockList[i]).Left := PrevLeft;
          TSetBlock(BlockList[i]).S_Width := Delta;
         end;
       end;
    3: begin
         Delta := BoxWidth div 4;
         PrevLeft := -Delta;
         for i:=0 to BlockList.Count -1 do
         begin
          PrevLeft := PrevLeft + Delta;
          TSetBlock(BlockList[i]).Left := PrevLeft;
          TSetBlock(BlockList[i]).S_Width := Delta;
         end;
       end;
    4: begin
         Delta := BoxWidth div 5;
         PrevLeft := -Delta;
         for i:=0 to BlockList.Count -1 do
         begin
          PrevLeft := PrevLeft + Delta;
          TSetBlock(BlockList[i]).Left := PrevLeft;
          TSetBlock(BlockList[i]).S_Width := Delta;
         end;
       end;
  else begin
        Delta := BoxWidth div 5;
        PrevLeft := -Delta;
        for i:=0 to BlockList.Count -1 do
        begin
         PrevLeft := PrevLeft + Delta;
         TSetBlock(BlockList[i]).Left := PrevLeft;
         TSetBlock(BlockList[i]).S_Width := Delta;
       end;
      end;
  end;
  ScrollBox1.HorzScrollBar.Position := scroll;
  Replot;
end;

procedure TSetDataForm.Timer1Timer(Sender: TObject);  //for deleting
begin
  Timer1.Enabled := false;
  DeleteKomponent;
end;

procedure TSetDataForm.Button2Click(Sender: TObject);
begin
  if(Selected_ID >= 0) then
    begin
      ForDelete := Selected_ID;
      DeleteKomponent;
      //if(Selected_ID > 0)then Selected_ID := Selected_ID -1;
    end;
end;

// ------ Insert L ------
procedure TSetDataForm.Button3Click(Sender: TObject);
begin
  InsertL;
end;

procedure TSetDataForm.InsertL;
var
  index: integer;
begin
  If (Selected_ID < 0) then index := 0 else index := Selected_ID;
  BlockList.Insert(index,TSetBlock.Create(ScrollBox1));
  //TSetBlock(BlockList[index]).Left := BlockLeft;
  //TSetBlock(BlockList[index]).S_Width := BoxWidth;

  ChangedIsFrozen := True;
  TSetBlock(BlockList[index]).Visible := True;
  TSetBlock(BlockList[index]).OnChange := SetBlockChange;
  TSetBlock(BlockList[index]).OnKeyDown := SetBlockKeyDown;
  TSetBlock(BlockList[index]).OnClick := SetBlockClick;
  TSetBlock(BlockList[index]).V_FileName := '';
  TSetBlock(BlockList[index]).V_InitialDir := SetBlock1.V_InitialDir;
  TSetBlock(BlockList[index]).S_FeedBack.ItemIndex := SetBlock1.S_FeedBack.ItemIndex;
  TSetBlock(BlockList[index]).S_ProcessType.ItemIndex := SetBlock1.S_ProcessType.ItemIndex;
  TSetBlock(BlockList[index]).ProcessTypeForChange;
  TSetBlock(BlockList[index]).S_Time.Text := SetBlock1.S_Time.Text;
  TSetBlock(BlockList[index]).S_Const.Text := SetBlock1.S_Const.Text;
  TSetBlock(BlockList[index]).S_WaitForStability.Checked := SetBlock1.S_WaitForStability.Checked;
  TSetBlock(BlockList[index]).S_Stability.Text := SetBlock1.S_Stability.Text;
  TSetBlock(BlockList[index]).S_From.Text := SetBlock1.S_From.Text;
  ChangedIsFrozen := False;
  TSetBlock(BlockList[index]).S_To.Text := SetBlock1.S_To.Text;
  TSetBlock(BlockList[index]).S_Step.Text := SetBlock1.S_Step.Text;
  TSetBlock(BlockList[index]).S_DelayBtLoad.Text := SetBlock1.S_DelayBtLoad.Text;

  TSetBlock(BlockList[index]).S_CurrentUnit := SetBlock1.S_CurrentUnit;
  TSetBlock(BlockList[index]).S_VoltageUnit := SetBlock1.S_VoltageUnit;
  TSetBlock(BlockList[index]).S_TimeUnit := SetBlock1.S_TimeUnit;
  TSetBlock(BlockList[index]).S_DecPoint := SetBlock1.S_DecPoint;

  TSetBlock(BlockList[index]).Top := BlockTop;
  TSetBlock(BlockList[index]).V_Id := index;
  Selected_ID := Selected_ID + 1;

  RearangeBlock;
  Replot;
end;

//------Insert R
procedure TSetDataForm.Button4Click(Sender: TObject);
begin
  InsertR;
end;

procedure TSetDataForm.InsertR;
var
  index: integer;
begin
  If (Selected_ID < 0) then index := BlockList.Count-1 else index := Selected_ID;
  If (Selected_ID = BlockList.Count-1)
    then begin index := BlockList.Add(TSetBlock.Create(ScrollBox1)); index := index -1; end
    else BlockList.Insert(index+1,TSetBlock.Create(ScrollBox1));
  //TSetBlock(BlockList[index]).Left := BlockLeft;
  //TSetBlock(BlockList[index]).S_Width := BoxWidth;
  ChangedIsFrozen := True;
  TSetBlock(BlockList[index+1]).Visible := True;
  TSetBlock(BlockList[index+1]).OnChange := SetBlockChange;
  TSetBlock(BlockList[index+1]).OnKeyDown := SetBlockKeyDown;
  TSetBlock(BlockList[index+1]).OnClick := SetBlockClick;
  TSetBlock(BlockList[index+1]).V_FileName := '';
  TSetBlock(BlockList[index+1]).V_InitialDir := SetBlock1.V_InitialDir;
  TSetBlock(BlockList[index+1]).S_FeedBack.ItemIndex := SetBlock1.S_FeedBack.ItemIndex;
  TSetBlock(BlockList[index+1]).S_ProcessType.ItemIndex := SetBlock1.S_ProcessType.ItemIndex;
  TSetBlock(BlockList[index+1]).ProcessTypeForChange;
  TSetBlock(BlockList[index+1]).S_Time.Text := SetBlock1.S_Time.Text;
  TSetBlock(BlockList[index+1]).S_Const.Text := SetBlock1.S_Const.Text;
  TSetBlock(BlockList[index+1]).S_WaitForStability.Checked := SetBlock1.S_WaitForStability.Checked;
  TSetBlock(BlockList[index+1]).S_Stability.Text := SetBlock1.S_Stability.Text;
  TSetBlock(BlockList[index+1]).S_From.Text := SetBlock1.S_From.Text;
  ChangedIsFrozen := False;
  TSetBlock(BlockList[index+1]).S_To.Text := SetBlock1.S_To.Text;
  TSetBlock(BlockList[index+1]).S_Step.Text := SetBlock1.S_Step.Text;
  TSetBlock(BlockList[index+1]).S_DelayBtLoad.Text := SetBlock1.S_DelayBtLoad.Text;
  TSetBlock(BlockList[index+1]).Top := BlockTop;
  TSetBlock(BlockList[index+1]).Visible := True;
  TSetBlock(BlockList[index+1]).S_CurrentUnit := SetBlock1.S_CurrentUnit;
  TSetBlock(BlockList[index+1]).S_VoltageUnit := SetBlock1.S_VoltageUnit;
  TSetBlock(BlockList[index+1]).S_TimeUnit := SetBlock1.S_TimeUnit;
  TSetBlock(BlockList[index+1]).S_DecPoint := SetBlock1.S_DecPoint;

  TSetBlock(BlockList[index+1]).V_Id := index+1;
  RearangeBlock;
  Replot;
end;

//--- Add - Insert at the end -------
procedure TSetDataForm.Button1Click(Sender: TObject);
begin
  Add;
end;

procedure TSetDataForm.AddWithoutRearange;
var
  index: integer;
  //ap: ^TSetBlock;
  //a: TSetBlock;
begin
  ChangedIsFrozen := True;
  index := BlockList.Add(TSetBlock.Create(ScrollBox1));
  TSetBlock(BlockList[index]).Visible := True;
  TSetBlock(BlockList[index]).OnChange := SetBlockChange;
  TSetBlock(BlockList[index]).OnKeyDown := SetBlockKeyDown;
  TSetBlock(BlockList[index]).OnClick := SetBlockClick;
  TSetBlock(BlockList[index]).V_FileName := '';
  TSetBlock(BlockList[index]).V_InitialDir := SetBlock1.V_InitialDir;
  TSetBlock(BlockList[index]).S_FeedBack.ItemIndex := SetBlock1.S_FeedBack.ItemIndex;
  TSetBlock(BlockList[index]).S_ProcessType.ItemIndex := SetBlock1.S_ProcessType.ItemIndex;
  TSetBlock(BlockList[index]).ProcessTypeForChange;
  TSetBlock(BlockList[index]).S_Time.Text := SetBlock1.S_Time.Text;
  TSetBlock(BlockList[index]).S_Const.Text := SetBlock1.S_Const.Text;
  TSetBlock(BlockList[index]).S_WaitForStability.Checked := SetBlock1.S_WaitForStability.Checked;
  TSetBlock(BlockList[index]).S_Stability.Text := SetBlock1.S_Stability.Text;
  TSetBlock(BlockList[index]).S_From.Text := SetBlock1.S_From.Text;
  ChangedIsFrozen := False;
  TSetBlock(BlockList[index]).S_To.Text := SetBlock1.S_To.Text;
  TSetBlock(BlockList[index]).S_Step.Text := SetBlock1.S_Step.Text;
  TSetBlock(BlockList[index]).S_DelayBtLoad.Text := SetBlock1.S_DelayBtLoad.Text;
  TSetBlock(BlockList[index]).S_CurrentUnit := SetBlock1.S_CurrentUnit;
  TSetBlock(BlockList[index]).S_VoltageUnit := SetBlock1.S_VoltageUnit;
  TSetBlock(BlockList[index]).S_TimeUnit := SetBlock1.S_TimeUnit;
  TSetBlock(BlockList[index]).S_DecPoint := SetBlock1.S_DecPoint;
end;

procedure TSetDataForm.Add;
begin
  AddWithoutRearange;
  RearangeBlock;
  Replot;
end;
//---------------


//---- Onclikc a KeyDown pro Sablonni SetBlock  -
//    Jen kvuli tomu aby byli definovane, ale nic nedelaji
procedure TSetDataForm.SetBlock1Click(Sender: TObject);
begin
  Exit;
end;

procedure TSetDataForm.SetBlock1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Exit;
end;

procedure TSetDataForm.CheckBox1Click(Sender: TObject);
begin
  ConectConstLine := CheckBox1.Checked;
end;

procedure TSetDataForm.CheckBox2Click(Sender: TObject);
var
  i: integer;
begin
  RampAtTheEnd := CheckBox2.Checked;
  SetBlock1.S_RampAtTheEnd := RampAtTheEnd;
  for i:=0 to BlockList.Count-1 do TSetBlock(BlockList[i]).S_RampAtTheEnd := RampAtTheEnd;
  Replot;
end;

procedure TSetDataForm.CUnitChange(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to BlockList.Count -1 do TSetBlock(BlockList[i]).S_CurrentUnit := TCurrentUnit(CUnit.ItemIndex);
  SetBlock1.S_CurrentUnit := TCurrentUnit(CUnit.ItemIndex);
  CUnitV := TCurrentUnit(CUnit.ItemIndex);
end;

procedure TSetDataForm.VUnitChange(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to BlockList.Count -1 do TSetBlock(BlockList[i]).S_VoltageUnit := TVoltageUnit(VUnit.ItemIndex);
  case VUnit.ItemIndex of
   0 : Label5.Caption := '[uV]';
   1 : Label5.Caption := '[mV]';
   2 : Label5.Caption := '[V]';
   3 : Label5.Caption := '[kV]';
  else ;
    Label5.Caption := '[?]';
  end;
  SetBlock1.S_VoltageUnit := TVoltageUnit(VUnit.ItemIndex);
  VUnitV := TVoltageUnit(VUnit.ItemIndex);
end;

procedure TSetDataForm.TUnitChange(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to BlockList.Count -1 do TSetBlock(BlockList[i]).S_TimeUnit := TTimeUnit(TUnit.ItemIndex);
  SetBlock1.S_TimeUnit := TTimeUnit(TUnit.ItemIndex);
  TUnitV := TTimeUnit(TUnit.ItemIndex);
end;

procedure TSetDataForm.Edit1Change(Sender: TObject);
var
  doub: double;
begin
  if(Length(Edit1.Text)>0)
  then if(Edit1.Text[Length(Edit1.Text)] <> SetBlock1.S_DecPoint)then
  begin
    if (not TryStrToFloat(Edit1.Text,doub)) then begin
        MessageDlg('The value '+Edit1.Text+' is not real number!', mtInformation,[mbOk], 0);
        Edit1.Text := Copy(Edit1.Text,1,Length(Edit1.Text)-1);
    end
    else begin
      LowVoltageLimit := (doub );
    end;
  end
end;

procedure TSetDataForm.SetBlock1DblClick(Sender: TObject);
begin
  Exit;
end;

procedure TSetDataForm.OpenButtonClick(Sender: TObject);
begin
  if(OpenDialog1.Execute)
    then begin
      if(not(CMB.Open(OpenDialog1.FileName)))
          then MessageDlg('Cannot open this file: "' +SaveDialog1.FileName+'".',
                mtError,[mbOk], 0)
          else begin
            ChangeFormName(OpenDialog1.FileName,Fulllenght);
            ReadCMB;
            SetBlock1.V_InitialDir := ExtractFileDir(OpenDialog1.FileName);
            ReInitDirForAllBoxes;
          end;
    end else ;
end;

procedure TSetDataForm.SaveAsButtonClick(Sender: TObject);
begin
  if(not FillCMB) then Exit;
  if(SaveDialog1.Execute)
    then begin

         if(FileExists(SaveDialog1.FileName))
            then begin
                 if (MessageDlg('File '+SaveDialog1.FileName+' exist. Rewrite it?',
                      mtWarning, [mbYes, mbNo], 0) = mrYes)
                        then begin if( not(CMB.SaveAs(SaveDialog1.FileName)))
                                    then MessageDlg('Cannot save this file: "' +SaveDialog1.FileName+'".',
                                      mtError,[mbOk], 0)
                                    else begin
                                      ChangeFormName(SaveDialog1.FileName,Fulllenght);
                                      SetBlock1.V_InitialDir := ExtractFileDir(SaveDialog1.FileName);
                                      ReInitDirForAllBoxes;
                                    end
                             end
                 end
            else begin
                 if( not(CMB.SaveAs(SaveDialog1.FileName)))
                    then MessageDlg('Cannot save this file: "' +SaveDialog1.FileName+'".',
                          mtError,[mbOk], 0)
                    else begin
                      ChangeFormName(SaveDialog1.FileName,Fulllenght);
                      SetBlock1.V_InitialDir := ExtractFileDir(SaveDialog1.FileName);
                      ReInitDirForAllBoxes;
                    end
                 end
         end
    else ;
end;

procedure TSetDataForm.SaveButtonClick(Sender: TObject);
begin
  if(not FillCMB) then Exit;
  If(CMB.FileNameEx)
    then begin
         if( not(CMB.Save))
              then MessageDlg('Cannot save this file: "' +SaveDialog1.FileName+'".',
                                  mtError,[mbOk], 0)
         end
    else begin
            SaveAsButtonClick(SaveButton);
         end        
end;

function TSetDataForm.FillCMB:boolean;
var
  Batch: TBatch;
  pBatch: PTBatch;
  ListOfBatch: TList;
  i, j: integer;
begin
  ListOfBatch := TList.Create;
  // Prat 1
  CMB.FormAttr.ConectedLines := ConectConstLine;
  CMB.FormAttr.RampAtTheEnd := RampAtTheEnd;
  CMB.FormAttr.TempFeedBack := SetBlock1.V_FeedBack;
  CMB.FormAttr.TempProcessType := SetBlock1.V_ProcessType;
  CMB.FormAttr.TempDuration := SetBlock1.V_Time;
  CMB.FormAttr.TempConstV := SetBlock1.V_Const;
  CMB.FormAttr.TempWaitForStability := SetBlock1.V_WaitForStability;
  CMB.FormAttr.TempStability := SetBlock1.V_Stability;
  CMB.FormAttr.TempFrom := SetBlock1.V_From;
  CMB.FormAttr.TempToV := SetBlock1.V_To;
  CMB.FormAttr.TempStep := SetBlock1.V_Step;
  CMB.FormAttr.TempDelayBtLoad := SetBlock1.V_DelayBtLoad;
  // Part 2
  CMB.LowVoltageLimit := LowVoltageLimit;
  CMB.HighVoltageLimit := HighVoltageLimit;
  CMB.LowCurretLimit := LowCurretLimit;
  CMB.HighCurretLimit := HighCurretLimit;
  CMB.NumOfRepeating := NumOfRepeating;
  CMB.VoltageUnit := VUnitV;
  CMB.CurrentUnit := CUnitV;
  CMB.TimeUnit := TUnitV;
  // Part 3
  for i:=0 to BlockList.Count - 1 do begin
    with Batch do begin
        FileName := TSetBlock(BlockList[i]).V_FileName;
        FeedBack := TSetBlock(BlockList[i]).V_FeedBack;
        ProcessType := TSetBlock(BlockList[i]).V_ProcessType;
        Duration := TSetBlock(BlockList[i]).V_Time;
        ConstV := TSetBlock(BlockList[i]).V_Const;
        WaitForStability := TSetBlock(BlockList[i]).V_WaitForStability;
        Stability := TSetBlock(BlockList[i]).V_Stability;
        From := TSetBlock(BlockList[i]).V_From;
        ToV := TSetBlock(BlockList[i]).V_To;
        Step := TSetBlock(BlockList[i]).V_Step;
        TimeOfStep := StrToFloat(TSetBlock(BlockList[i]).S_StepPerDTime.Text);
        DelayBtLoad := TSetBlock(BlockList[i]).V_DelayBtLoad;
        CycleChar := TSetBlock(BlockList[i]).V_CycleChar;
    end;
    if((Batch.From = Batch.ToV)and(Batch.ProcessType = 'From To'))
      then begin
        for j := 0 to (ListOfBatch.Count - 1) do
        begin
          pBatch := ListOfBatch.Items[j];
          Dispose(pBatch);
        end;
        ListOfBatch.Free;
        MessageDlg('Cannot be ''From''('+FloatToStr(Batch.From)+') equal to ''To''('+FloatToStr(Batch.ToV)+') in box '+IntToStr(i+1)+' Use ''Const'' process or change values!.',
                                  mtError,[mbOk], 0);
        Result := False;
        Exit;
      end else begin
        New(pBatch);
        pBatch^ := Batch;
        ListOfBatch.Add(pBatch);
      end;
  end;
  //Cleanig of ListOfBatch
  for i := 0 to (CMB.ListOfBatch.Count - 1) do
  begin
    pBatch := CMB.ListOfBatch.Items[i];
    Dispose(pBatch);
  end;
  CMB.ListOfBatch.Clear;
  CMB.ListOfBatch := ListOfBatch;
  Result := True;
  //ListOfBatch.Free; //Zkus a uvidis
end;

procedure TSetDataForm.ReadCMB;
var
  i, index: integer;
begin
  //Clear BlockLists
  Clear;
  ChangedIsFrozen := True;
  // Part 1
  ConectConstLine := CMB.FormAttr.ConectedLines;
  RampAtTheEnd := CMB.FormAttr.RampAtTheEnd;
  SetBlock1.V_FeedBack := CMB.FormAttr.TempFeedBack;
  SetBlock1.V_ProcessType := CMB.FormAttr.TempProcessType;
  SetBlock1.V_Time := CMB.FormAttr.TempDuration;
  SetBlock1.V_Const := CMB.FormAttr.TempConstV;
  SetBlock1.V_WaitForStability := CMB.FormAttr.TempWaitForStability;
  SetBlock1.V_Stability := CMB.FormAttr.TempStability;
  SetBlock1.V_From := CMB.FormAttr.TempFrom;
  SetBlock1.V_To := CMB.FormAttr.TempToV;
  SetBlock1.V_Step := CMB.FormAttr.TempStep;
  SetBlock1.V_DelayBtLoad := CMB.FormAttr.TempDelayBtLoad;
  // Part 2
  LowVoltageLimit := CMB.LowVoltageLimit;
  HighVoltageLimit := CMB.HighVoltageLimit;
  LowCurretLimit := CMB.LowCurretLimit;
  HighCurretLimit := CMB.HighCurretLimit;
  NumOfRepeating := CMB.NumOfRepeating;
  VUnitV := CMB.VoltageUnit;
  CUnitV := CMB.CurrentUnit;
  TUnitV := CMB.TimeUnit;
  //Part 3
  for i:=0 to CMB.ListOfBatch.Count - 1 do begin
    with PTBatch(CMB.ListOfBatch[i])^ do begin
        index := BlockList.Add(TSetBlock.Create(ScrollBox1));
        //MessageDlg('Index:' +intToStr(Index)+',i:'+IntToStr(i), mtWarning,[mbOk], 0);
        TSetBlock(BlockList[index]).Visible := True;
        TSetBlock(BlockList[index]).OnChange := SetBlockChange;
        TSetBlock(BlockList[index]).OnKeyDown := SetBlockKeyDown;
        TSetBlock(BlockList[index]).OnClick := SetBlockClick;
        TSetBlock(BlockList[index]).V_FileName := FileName;
        TSetBlock(BlockList[index]).V_InitialDir := SetBlock1.V_InitialDir;
        if(FeedBack = 'Current')then
        TSetBlock(BlockList[index]).S_FeedBack.ItemIndex := 0
        else
        TSetBlock(BlockList[index]).S_FeedBack.ItemIndex := 1;
        If(ProcessType = 'Const')then
        TSetBlock(BlockList[index]).S_ProcessType.ItemIndex := 0
        else
        TSetBlock(BlockList[index]).S_ProcessType.ItemIndex := 1;
        TSetBlock(BlockList[index]).ProcessTypeForChange;
        TSetBlock(BlockList[index]).S_Time.Text := FloatToStr(Duration);
        TSetBlock(BlockList[index]).S_Const.Text := FloatToStr(ConstV);
        TSetBlock(BlockList[index]).S_WaitForStability.Checked := WaitForStability;
        TSetBlock(BlockList[index]).S_Stability.Text := FloatToStr(Stability);
        TSetBlock(BlockList[index]).S_From.Text := FloatToStr(From);
        TSetBlock(BlockList[index]).S_To.Text := FloatToStr(ToV);
        TSetBlock(BlockList[index]).S_Step.Text := FloatToStr(Step);
        TSetBlock(BlockList[index]).S_StepPerDTime.Text := FloatToStr(TimeOfStep);
        TSetBlock(BlockList[index]).S_DelayBtLoad.Text := IntToStr(DelayBtLoad);
        TSetBlock(BlockList[index]).S_CurrentUnit := CUnitV;
        TSetBlock(BlockList[index]).S_VoltageUnit := VUnitV;
        TSetBlock(BlockList[index]).S_TimeUnit := TUnitV;
        TSetBlock(BlockList[index]).S_DecPoint := SetBlock1.S_DecPoint;
        RearangeBlock; 
    end;
  end;
  //RearangeBlock;

  //Reinit
  Edit1.Text := FloatToStr(LowVoltageLimit);
  CUnit.ItemIndex := Ord(CUnitV);
  VUnit.ItemIndex := Ord(VUnitV);
  TUnit.ItemIndex := Ord(TUnitV);
  CheckBox1.Checked := ConectConstLine;
  CheckBox2.Checked := RampAtTheEnd;
  CheckBox1Click(CheckBox1);
  CheckBox2Click(CheckBox2);
  CUnitChange(CUnit);
  VUnitChange(VUnit);
  TUnitChange(TUnit);
  ChangedIsFrozen := False;
  Replot;
end;

procedure TSetDataForm.Clear;
var
  index, i : integer;
begin
  index := BlockList.Count - 1;
  ForDelete := 0;
  for i:= 0 to index do DeleteKomponent;
  BlockList.Clear;
  ForDelete := -1;
end;

procedure TSetDataForm.CyclingChange(Sender: TObject);
begin
  NumOfRepeating := Cycling.Value;
end;

procedure TSetDataForm.ChangeFormName(FileName: TFileName;FullLenght: boolean);
begin
  If (not FullLenght)then FileName := ExtractFileName(FileName);
  SetDataForm.Caption := ProgName + ' - ' + FileName;
end;

procedure TSetDataForm.Button5Click(Sender: TObject);
begin
  SetData_Hlp.Visible := True;
end;

procedure TSetDataForm.ReInitDirForAllBoxes;
var
  i: integer;
begin
  //Initial Direction Change In All boxes
  for i:= 0 to BlockList.Count - 1 do TSetBlock(BlockList[i]).V_InitialDir := SetBlock1.V_InitialDir;
end;

function TSetDataForm.GetFileName: TFileName;
begin
  Result := CMB.GetFileName;
end;

procedure TSetDataForm.PFileName_ParentPointer(pstr: Pointer);
begin
  PFileName_ParentPointer_ := pstr;
  PFileName_ParentPointer_IsInitialized := True;
end;

procedure TSetDataForm.PCMB_ParnetPointer(p: Pointer);
begin
  PCMB_ParnetPointer_ := p;
  PCMB_ParnetPointer_IsInitialized := True;
end;

procedure TSetDataForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  LeavingForm;
end;

procedure TSetDataForm.LeavingForm;
var
  E: ^TEdit;
  C: ^TCMB;
begin
  if(PFileName_ParentPointer_IsInitialized)then begin
    E := PFileName_ParentPointer_;
    E.Text := GetFileName;
  end;
  If(PCMB_ParnetPointer_IsInitialized)then begin
    C := PCMB_ParnetPointer_;
    //need to Clone!!!!!
     //clone
    C^.Free;     //free old class in other form, replace with this one
    C^ := CMB;                  //???? causes change of reference from other form and  MEMORY LEAK !!!!!!! (2x free on the same object ... CMB)
    marknotdestroycmb := true;      //will be destroyed from other form
  end;
end;

procedure TSetDataForm.ClearButtonClick(Sender: TObject);
begin
  CMB.Close;
  Clear;
end;

end.

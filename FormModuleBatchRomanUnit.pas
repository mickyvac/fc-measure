unit FormModuleBatchRomanUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DateUtils,
  HWAbstractDevicesV3, HWinterface,
  FormGlobalConfig, FormProjectControl,
  FormHWAccessControlUnit, DataStorage,
  Logger, myUtils,
  SetData;

const
  PathSlash = '\'; //fucking backslash - If I use full path direction name it is necessary
 {this horrible thing should be removed ...
  TimerIntervalCorrection_StepTimer = 28;
  TimerIntervalCorrection_DataStorageTimer = 7;
  }
  {ms that are subtracted from timer intervals.
  For example 78 - 28 = 50. We wants 50. But we observed 78. I don'tknow why !!!!!!.}
  {And know I know why. In fact the timer set OS and set event but it is stupit stopwatch.
  It is +/- and the increment of time is divided by 13-15 ms and it depends actual activity (how busy) of system.
  Call enable/disabled take nex 13-15 ms.
  IT IS NO STOPWATCH!!!. Awful. But it's happened. Please, do clever objcet for it which is load to seperate thread and use some standard delay function}
  Infinity = High(Cardinal);  //It is use for set off of timers. I know disabled could be better but I hope that this way is more general
  {...not a good idea, better to make them disabled and "more genereal" is of course this way of disabling}

type

  TMonitor = record
    Voltage: real;     //voltage in volts
    Current: real;     //current in amperes
    Power: real;
    Temperature: real;   //temp in degrees of celsius
    ColdEndTemp: real;
    PotencioMode : TPotentioMode;
    LoadRelayConnected : boolean;
    Timestamp: TDateTime;
    ErrorStatus: byte; // 0 = all OK, 1=
  end; //TMonitor


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


type
  TMyMethod = procedure of object;


type
  TFormModuleBatchRoman = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label3: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label21: TLabel;
    Label41: TLabel;
    Label34: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label58: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    Label69: TLabel;
    Label71: TLabel;
    Label72: TLabel;
    Label75: TLabel;
    Label76: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit3: TEdit;
    Edit6: TEdit;
    Edit10: TEdit;
    Edit2: TEdit;
    Edit9: TEdit;
    Edit14: TEdit;
    Edit18: TEdit;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    ComboBox6: TComboBox;
    CheckBox6: TCheckBox;
    Edit25: TEdit;
    ComboBox16: TComboBox;
    BFileName: TEdit;
    BatchOpenButt: TButton;
    Edit8: TEdit;
    Label32: TLabel;
    PanStatus: TPanel;
    Edit12: TEdit;
    Label73: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit4: TEdit;
    Edit5: TEdit;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    CheckBox2: TCheckBox;
    Label23: TLabel;
    BuUnlockHW: TButton;
    Memo1: TMemo;
    cbDebug: TCheckBox;
    BuGenNewDir: TButton;
    BuOpenBatch: TButton;
    OpenDialogBatch: TOpenDialog;
    BuHide: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    CheckBox3: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BuUnlockHWClick(Sender: TObject);
    procedure ComboBox6Select(Sender: TObject);
    procedure ComboBox16Change(Sender: TObject);
    procedure BFileNameChange(Sender: TObject);
    procedure BatchOpenButtClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure BuGenNewDirClick(Sender: TObject);
    procedure BuOpenBatchClick(Sender: TObject);
    procedure BuHideClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
  private
    { Private declarations }
    memdatahistory: TMonitorMemDataStorage;
    hwtoken : THWAccessToken;
    stopsignal: boolean;
    fHoldTimers: boolean;    //when need to wait with application process messages- need to mute timers
  public
    { Public declarations }
  private
    { Private declarations }
    DataFile, output2: TextFile;
    input: TextFile;
    AnalogOut, AnalogOut_Init: real;

    saveinterval:integer;

    MaxVykon, MaxProud, MaxNapeti, Tlast, SkokTeploty: real;
    MaxValChange, MaxValChangeAt, ValBeforeDelay: real;

    Mon: TMonitor;
    VAParam: TParamRec;

    DataDir: string;  // Contains of TextEdit12.It is direction only. No fullpath. It is for saveing meassuring data.

    meassurestart: TDateTime;
    poprve: boolean;

    //-----------------------------------------------
    //Due to including Program for make a batch for meassuring
    //CellParamBatch: TCMB;  it is included after implementation. Creating is needed.Here is mirror only
    StepTimer: TTimer;   //Timer which will be stepping by delay between steps in value (voltage or current). (TCMB.ListOfBatch[i].Delay ) Creating is needed.   Crearing of both are in procedure Initializace
    StorageDataTimer: TTimer; //Timer which will be stepping by delay for data load.  (TCMB.ListOfBatch[i].DelayBtLoad )
    BatchIsActive: boolean;  //True if batch is ready for use. VACharFormEnable has already done this time. It is equal to (BFilename.Text <> '') NOW!!
    LastSelectComboBox6: integer; //Save last set VA char "in bloubox"
    DelayBtStep, DelayBtLoad, BatchID : Int64;
    LastFeedBack : string;
    BatchStartTime: TDateTime;
    BatchStepStartIncrementTime: Int64;
    procedure VACharFormEnable(bool: boolean);  //Change enabling of components in "blue box" if batchs are used
    function BInitialiationBatch: boolean;  //batch open. Imortant if u can use BFileName filed by user and no by BatchButton
    procedure RefreshBlueBox(BatchID: integer);   //For filling data form. BatchID means index for  CellParamBatch.ListOfBatch[ID]. ..(data)
    procedure BRun;
    function BatchExecute(BatchIndex: Int64): boolean; //Set timers for next batch. return FLASE if last +1 Batch itme was reached. Then u can use BStop and do timer.Enabled := FALSE.
    procedure StepTimerOnTimer(Sender: TObject);
    procedure StorageDataTimerOnTimer(Sender: TObject);
    procedure BStop;
    function IsFileInUse(fName: string): boolean;  //Check if the file is open
    function BFeedBack(BatchID: integer): integer;  // retunr index of feedback 0- Current, 1 voltage, -1 error was indicated
    function EndBatchItem(AnalogOut: real; BatchStartIncrement: Int64; BatchStartTime: TDateTime; UseTime: boolean): boolean;   //checking if is reach end of batch item and if is true so call BatchExecute
    function BSetRelay(BatchID: integer): boolean;  //Call BSetRelay It depent on feedback (in future ownvariable) if is it "Disconect" - it can be use for Pause in batching and "OnlyVoltageLoad" - it can be used for obtaining open voltage. It wokr only if something is changed. Return false if change is done badly.
    procedure BStopIt(var Timer1: TTimer; var Timer2: TTimer; Stop: TMyMethod);
    function BDataWriteln(line: string): boolean;
    procedure BDelay(ms : word);   //Standart Delay in milisecunds with Application.ProcessMessages

  public

    HomePath: string; //It is home direction in full path. It is CurrentDirection after create.
                      //Direction for saving the data is DataDir = HomePatch + TextEdit12)

    function DataPath(): string;  //Direction for saving the data is DataDir = HomePatch + TextEdit12)

    procedure CreateGraph;
    function FinishFile(feedback: integer): boolean;
    procedure Inicializace;

    procedure RefreshBatchForm;

    procedure RefreshVaParamForm;
    procedure UpdateVAParamRecord;

    procedure PlotUI( U,I: real);

    procedure BeforeRun;
    procedure AfterRun;
    function OpenDataFileAndInit(FileName: TFileName; feedback: integer; from: real; tov: real; Step: real; Delay: real): boolean;
    //procedure generatefileinfoheader;
    procedure SetTimerRun(var Timer: TTimer; Delay:Cardinal; TimerOnTimer: TNotifyEvent);
    function AquireAndSavePlot(feedback: integer): boolean;
    function GeneralLimitsReached(delay_ms: integer; loops: integer): boolean;
    function StabilityCheck(feedback: integer): boolean;
    procedure StopIt(var Timer: TTimer; Stop: TMyMethod);

  public
    { Public declarations }
    procedure SaveParams;
    procedure LoadParams;
    procedure LeaveMessage(s: string);
    procedure LockGet;
    procedure LockClear;
    procedure ObtainNewDataDirectory;
    procedure DelayWithAquire( dtms: TDateTime );
  public
    {wrappers for measurement access with new system *** 3.9.2015}
    fLastRelayStatus: boolean; //added 07.2016
    fDesiredRelayStatus: boolean;     //added 08.2016
    fDesiredFeedback: TPotentioMode;
    fDesiredSetpointVal: double;
    fDidTurnLoadOff: boolean;

    procedure Aquire; //read all data, determine range used and so on (mainly it reads the voltage and current)
                      //the aquired data are stored in the public variables of the TMonitor class

    procedure MonInit;   //call at start or later to reinitialize variables
//    procedure ConInit;     //Tcontrol  //call at start or later to reinitialize variables
    procedure SetpointSet(val:real); //value in Volts or Amperes (depending on feedback selected)
    //procedure SetRelayStatus(rs:TRelaystatus);   //RsOFF, RsVolt, RsVoltCurr
    procedure SetRelayStatus(state: boolean);   //RsOFF, RsVolt, RsVoltCurr
    procedure SetFeedbackCurrent(sp: real);      //setpoint in amperes
    procedure SetFeedbackVoltage(sp: real);      //setpoint in volts
    procedure PTCTurnON;
    procedure PTCTurnOFF;
    function getLoadRelayStatus: boolean;
    function isPTCready: boolean;
    //
    procedure HandleBroadcastSignals(sig: TMySignal);
  end;

//********************************************************************

var
  FormModuleBatchRoman: TFormModuleBatchRoman;

  CellParamBatch: TCMB;


//********************************************************************



implementation

uses math, ConfigManager;


{$R *.dfm}

procedure TFormModuleBatchRoman.FormCreate(Sender: TObject);

begin
  //other ini
  hwtoken := THWAccessToken.Create;
  hwtoken.tokenname := 'Batch Roman';
  hwtoken.statusmsg := '-idle-';
  //data storage
  memdatahistory := TMonitorMemDataStorage.Create;
  //timers
  StepTimer := TTimer.Create(Self);
  StepTimer.Enabled := False;
  StorageDataTimer := TTimer.Create(Self);
  StorageDataTimer.Enabled := False;
  //TCMB
  CellParamBatch := TCMB.Create;
  //ini
  stopsignal := true;
  fHoldTimers := false;
  //
  GlobalConfig.RegisterForBroadcastSignals( HandleBroadcastSignals );
  //
  logmsg('FormModuleBatchRoman.FormCreate done.');
end;

procedure TFormModuleBatchRoman.FormDestroy(Sender: TObject);
begin
  CellParamBatch.Free;
  StepTimer.Enabled := False;
  StorageDataTimer.Enabled := False;
  StepTimer.Free;
  StorageDataTimer.Free;
  memdatahistory.Free;
  hwtoken.Free;
end;


procedure TFormModuleBatchRoman.Inicializace;
//call after everything has been initialized before - that is probably from FormMain.Inicializace....
var
  i, ChanelX, ChanelY: integer;
  buffer: string;
  datstr: String;
  r: real;

begin
  MonInit;                    //clone  tpersistent
  //batch ini
  //
  HomePath := GlobalConfig.getAppPath;

  //
  // Including batch maker
  //if CellParamBatch = nil then CellParamBatch := TCMB.Create;
  StepTimer.OnTimer := StepTimerOnTimer;
  StepTimer.Enabled := False;
  //StepTimer.Interval := 50;
  StorageDataTimer.OnTimer := StorageDataTimerOnTimer;
  StorageDataTimer.Enabled := False;
  //StorageDataTimer.Interval := 50;
  BatchIsActive := False;
  // ---
  BFileName.Text := GlobalConfig.GlobalRegistrySection.valStr[IdFormBatchBFleNameText];
  //BFileNameChange(nil);

  if FileExists(HomePath + '\' + 'config.txt') then
  begin
   AssignFile(input, HomePath + '\' +'config.txt');
   reset(input);
  end else begin
   //ShowMessage('Config.txt dosn`t exist in directory: '+HomePath+'Program will be terminated...');
   Exit;
  end;

  readln(input,buffer);
  readln(input,buffer);
  //Edit12.Text:=buffer;
  readln(input,buffer);
  readln(input,r);
  readln(input,buffer);
  readln(input, r); //WireResistance := r;
  readln(input,buffer);
  readln(input,chanelX);
  readln(input,buffer);
  readln(input,chanelY);
  readln(input,buffer);
  readln(input,r); //KonstX
  readln(input,buffer);
  readln(input,r); //KonstY
  readln(input,buffer);
  readln(input,r); //DeltaX
  readln(input,buffer);
  readln(input,r); //DeltaY
  readln(input,buffer);
  readln(input,buffer);
  //****XXYZZY  Edit4.Text:=buffer;
  readln(input,buffer);
  readln(input,buffer);
  //****XXYZZY  Edit5.Text:=buffer;
  readln(input,buffer);
  readln(input,buffer);
  //Edit7.Text:=buffer; dummy now
  readln(input,buffer);
  readln(input,buffer);
  //Edit11.Text:=buffer; dummy now
  readln(input,buffer);
  readln(input,buffer);
  //Edit8.Text:=buffer; dummy now
  readln(input,buffer);
  readln(input,buffer);
  readln(input,buffer);
  readln(input,buffer);
  readln(input,buffer);
  readln(input, r); //TempAmplification := r;
  readln(input,buffer);
  readln(input,buffer);
  readln(input,buffer);
  readln(input,SkokTeploty);

  DateTimeToString(datstr, 'yymmdd', Now);
  //
  ObtainNewDataDirectory;
  ProjectControl.RegOnProjectUpdateMethod( ObtainNewDataDirectory );    //register to receive project update event
  //
  RefreshVAParamForm;
  //monitor init
end;



//------------------------------------------------




//-----batch graphics -----------



procedure TFormModuleBatchRoman.CreateGraph;
var StepX, StepY, i, stredX, stredY, Delka, Sirka, cislo : integer;
begin
 Delka:=FormModuleBatchRoman.Image1.Width-20;
 Sirka:=FormModuleBatchRoman.Image1.Height-20;
 stredX:=Delka div 2;
 stredY:=Sirka div 2;
 //delka := delka - 20;
 //sirka:= sirka -20;
 with FormModuleBatchRoman.Image1 do
 begin
   Canvas.MoveTo(10, stredY+10);
   Canvas.LineTo(Delka+10, stredY+10);
   Canvas.MoveTo(stredX+10, Sirka+10);
   Canvas.LineTo(stredX+10, 10);
   StepX:=round(Delka / 20);
   StepY:=round(Sirka / 20);
   cislo:=-StrToInt(FormModuleBatchRoman.Edit4.Text);
   {osa X}
   for i:=0 to -2*cislo do begin
     Canvas.MoveTo(StepX*abs(i)+10, Sirka-stredY+10);
     Canvas.LineTo(StepX*abs(i)+10,Sirka-stredY+5+10);
     if (cislo mod 2 = 0) and (cislo <> 0) then Canvas.TextOut(StepX*abs(i)-6+10,Sirka-stredY+5+10, IntToStr(cislo));
     if cislo = 0 then Canvas.TextOut(StepX*abs(i)-9+10,Sirka-stredY+5+10, IntToStr(cislo));
     inc(cislo);
   end;
   cislo:=-StrToInt(FormModuleBatchRoman.Edit5.Text);
   {Osa Y}
   for i:=0 to -2*cislo do begin
     Canvas.MoveTo(stredX+10, Sirka-StepY*abs(i)+10);
     canvas.LineTo(stredX+5+10,Sirka-StepY*abs(i)+10);
     if (cislo mod 2 = 0) and (cislo <> 0) then Canvas.TextOut(stredX+5+10,Sirka-StepY*abs(i)-6+10, IntToStr(cislo));
     inc(cislo);
   end;
 end
end;

procedure TFormModuleBatchRoman.PlotUI( U,I: real);
Var X1,y1,x2,y2: integer;
    ChannelX, Channely: Real;
    stredX, stredY, PolomerBodu, Delka, Sirka: integer;
    iii, np: longint;
    pp: PMonitorRec;

begin
  //ShowMessage('Další krok');
  Delka:=Image1.Width - 20;
  Sirka:=Image1.Height - 20;
  stredX := Delka div 2;
  stredY := Sirka div 2;
  PolomerBodu:=3;

  if (IsNan(U) or IsNan(I)) then Exit;

  ChannelX := U;
  ChannelY := I;
  {X := round((ChannelX * (Delka-stredX)) / StrToInt(Form1.Edit4.Text))+ stredX + 10;
  Y := stredY - round(ChannelY * (Sirka-stredY) / StrToInt(Form1.Edit5.Text)) + 10; }

    X1:=round((ChannelX * (Delka-stredX)) / StrToInt(FormModuleBatchRoman.Edit4.Text)-PolomerBodu)+10+stredX+10;
    Y1:=round(Sirka-PolomerBodu-stredY - (ChannelY * (Sirka-stredY)) / StrToInt(FormModuleBatchRoman.Edit5.Text))+10;
    X2:=round((ChannelX * (Delka-stredX)) / StrToInt(FormModuleBatchRoman.Edit4.Text)+PolomerBodu)+10+stredX+10;
    Y2:=round(Sirka+PolomerBodu-stredY - (ChannelY * (Sirka-stredY)) / StrToInt(FormModuleBatchRoman.Edit5.Text))+10;
 with FormModuleBatchRoman.Image1 do
 begin
   Canvas.Pen.Color := clBlack;
   Canvas.Brush.Color := clRed;
   Canvas.Brush.Style := bsDiagCross;
   //Canvas.Ellipse(X-PolomerBodu, Y-PolomerBodu, X+PolomerBodu , Y+PolomerBodu);
   Canvas.Ellipse(X1, Y1, X2 , Y2);
   //ShowMessage('tady');
 end;

end;

// batch   --- ruzne   --------------------

{Viditelnost komponent, inicializace a pristup k nim, inicializace grafu}
procedure TFormModuleBatchRoman.BeforeRun;
begin
  if not CheckBox2.Checked then begin
    Image1.Canvas.Brush.Color:=clWhite;
    Image1.Canvas.Pen.Color:=clWhite;
    Image1.Canvas.Brush.Style:=bsSolid;
    Image1.Canvas.Rectangle(0,0,10000,10000);
    Image1.Canvas.Refresh;
  end;

  Image1.Canvas.Pen.Color:=clBlack;
  Image1.Canvas.Brush.Style:=bsSolid;
  Button2.enabled:=true;      //stop
  Button1.enabled:=false;     //run
end;

procedure TFormModuleBatchRoman.AfterRun;
begin
  Button2.enabled:=false;
  Button1.enabled:=true;
  //Timer1.Enabled:=false;
  ComboBox1.Enabled:=true;
  ComboBox2.Enabled:=true;
  //Edit6.Enabled:=true;
  Edit4.Enabled:=true;
  Edit5.Enabled:=true;
  //Edit3.Enabled:=true;
  ComboBox3.Enabled:=true;
  ComboBox4.Enabled:=true;
end;

procedure TFormModuleBatchRoman.BFileNameChange(Sender: TObject);
begin
  If(BFileName.Text <> '') then begin
    VACharFormEnable(False);
    BFileName.Color := clMoneyGreen;
    ComboBox6.Color := clInactiveBorder;
    BatchIsActive := True;
    LastSelectComboBox6 := ComboBox6.ItemIndex;
    //update storage variable
    GlobalConfig.GlobalRegistrySection.valStr[IdFormBatchBFleNameText] := BFileName.Text;
  end else begin
    VACharFormEnable(True);
    ComboBox6.Color := clMoneyGreen;
    BFileName.Color := clInactiveBorder;
    BatchIsActive := False;
    ComboBox6.ItemIndex := LastSelectComboBox6;
  end;
end;

procedure TFormModuleBatchRoman.VACharFormEnable(bool: boolean);
begin
  ComboBox6.Enabled := bool;
  Edit6.Enabled := bool;
  Edit10.Enabled := bool;
  ComboBox16.Enabled := bool;
  Edit2.Enabled := bool;
  Edit9.Enabled := bool;
  Edit14.Enabled := bool;
  Edit3.Enabled := bool;
  Edit25.Enabled := bool;
  Edit18.Enabled := bool;
  Edit22.Enabled := bool;
  Edit23.Enabled := bool;
  Edit24.Enabled := bool;
  CheckBox6.Enabled := bool;
end;

procedure TFormModuleBatchRoman.RefreshBlueBox(BatchID: integer);   //For filling data from
begin
  VAPAram.name := 'External Control';
  VAPAram.filename := ExtractFileName(PTBatch(CellParamBatch.ListOfBatch[BatchID]).FileName);
  if (PTBatch(CellParamBatch.ListOfBatch[BatchID]).FeedBack = 'Current') then  VAParam.ControlVar := 0 else VAParam.ControlVar := 1;
  VAPAram.ValStart := PTBatch(CellParamBatch.ListOfBatch[BatchID]).From ;  //input is in mV or mA, stored value is in V or A
  VAPAram.ValEnd := PTBatch(CellParamBatch.ListOfBatch[BatchID]).ToV ;
  VAPAram.ValStep := PTBatch(CellParamBatch.ListOfBatch[BatchID]).Step ;
  VAPAram.Delay := PTBatch(CellParamBatch.ListOfBatch[BatchID]).Duration;
  if (PTBatch(CellParamBatch.ListOfBatch[BatchID]).WaitForStability) then VAPAram.WaitForStab := 1 else VAPAram.WaitForStab := 0;
  VAPAram.WaitValue := PTBatch(CellParamBatch.ListOfBatch[BatchID]).Stability ;
  if (PTBatch(CellParamBatch.ListOfBatch[BatchID]).CycleChar) then VAPAram.Cycle := 1 else VAPAram.Cycle  := 0;
  VAPAram.LimCurrLo := CellParamBatch.LowCurretLimit ;
  VAPAram.LimCurrHi := CellParamBatch.HighCurretLimit ;
  VAPAram.LimVoltLo := CellParamBatch.LowVoltageLimit ;
  VAPAram.LimVoltHi := CellParamBatch.HighVoltageLimit ;
  //
  //  xxxxx SetParamValues(0, VAPAram);
  RefreshVaParamForm;
end;



//--------  RUN -------------------------

procedure TFormModuleBatchRoman.SetTimerRun(var Timer: TTimer; Delay:Cardinal; TimerOnTimer: TNotifyEvent);
begin
  poprve := True;
  fHoldTimers := false;
  Timer.OnTimer := TimerOnTimer;
  Timer.Interval := Delay;
  Timer.Enabled := True;
end;




procedure TFormModuleBatchRoman.Button1Click(Sender: TObject);    //button Start
begin
 if(BatchIsActive)then begin
   // External batching
   if(not BInitialiationBatch)then begin ShowMessage('BInitialiationBatch false'); exit; end;
   if not hwtoken.getLock then begin ShowMessage('Not Able to get lock on PTC - USAGE is BLOCKED - try again?'); hwtoken.unlock; exit; end;
   stopsignal := false;
   BRun;
 end
 else
   ShowMessage('BatchIsActive = false');
end;



procedure TFormModuleBatchRoman.Button2Click(Sender: TObject);   //button Stop
begin
 stopsignal := true;
 if(BatchIsActive)then begin
   BStopIt(StepTimer,StorageDataTimer,BStop);
 end;
 hwtoken.unlock;
 ObtainNewDataDirectory;
end;


procedure TFormModuleBatchRoman.StopIt(var Timer: TTimer; Stop: TMyMethod);
begin
  //stop the measurement
  Timer.Enabled := False;
  Stop;
  LogMSG('VA char finished.');
  Exit;
end;








//------ IO  ---



function TFormModuleBatchRoman.OpenDataFileAndInit(FileName: TFileName; feedback: integer; from: real; tov: real; Step: real; Delay: real): boolean;
Var
  filepath: string; 
begin
  {inicializace konstatnt}
  MaxVykon:=0;
  MaxProud:=0;
  MaxNapeti:=0;
  MaxValChange := 0;
  MaxValChangeAt := 0;
  meassurestart := Now;
  {Open File}
  FilePath := DataPath();
  DataDir := ExcludeTrailingPathDelimiter( filepath );
  If (not DirectoryExists(DataDir)) then
    if(not CreateDir(DataDir))then begin Result := False; Exit; end;
  //if not FileExists(HomeDir+Edit6.Text+Edit10.Text+'.txt') then error:=FileCreate(HomeDir+Edit6.Text+Edit10.Text+'.txt');
  try
    AssignFile(DataFile, Filepath+FileName);
    //ShowMessage(HomeDir+Edit6.Text+Edit10.Text+'.txt');
    Rewrite(DataFile);
    writeln(DataFile, '[LinearBatch Acquisition File]');
    writeln(DataFile, MainHWInterface.Generatefileinfoheader);

    writeln(DataFile,'#Mereni provedeno: '+DateToStr(Date)+' '+TimeToStr(Time));
    writeln(DataFile,'#Teplota: '+ FloatToStrF( Mon.Temperature,ffFixed,4,1 ) + ' deg C; Teplota okoli: ' + FloatToStrF( Mon.ColdEndTemp,ffFixed,4,1  ));
    writeln(DataFile,'#Invert Current: ', ProjectControl.ProjInvertCurrent, 'Invert Voltage: ', ProjectControl.ProjInvertVoltage);
    writeln(DataFile,'#From '+FloatToStr(from)+ ' ' + Label58.Caption + ' to ' + FloatToStr(tov) + ' ' +Label58.Caption +' by step ' + FloatToStr(Step));
    writeln(DataFile,'#Prodleva mezi nacitanim bodu: ' + FloatToStr(Delay));
    writeln(DataFile,'#Fuel used: '+'TODO');
    writeln(DataFile,'#Oxigen medium: '+'TODO');
    writeln(DataFile,'#Anode material: '+ProjectControl.ProjAnodeDescr);
    writeln(DataFile,'#Cathode material: '+ProjectControl.ProjCathodeDescr);
    writeln(DataFile,'#Membrane: '+ProjectControl.ProjMembrane);
    writeln(DataFile,'#MEApreparation: '+ProjectControl.ProjMeaPreparation);
    writeln(DataFile,'#GDL material: '+ProjectControl.ProjAnodeGDL + ' ' + ProjectControl.ProjCathodeGDL);
    writeln(DataFile,'#Press for hot-pressing: '+'TODO');
    writeln(DataFile,'#Comment: ');
    writeln(DataFile,'#Osa X ['+ComboBox3.Text+']'+#9+'Osa Y ['+ComboBox4.Text+']'+#9+'Vykon ['+ComboBox3.Text+'*'+ComboBox4.Text+']' );
    writeln(DataFile,'#Osa X '); //****XXYZZY
    writeln(DataFile,'#-------------------------------------------------------------------------------------------------------------------------------------------------------');
    //proud A, napeti V, vykon W, proud mA, napeti V, vykon mW
    case feedback of
      0 : writeln(DataFile,'Time from start [ms]'+#9+'Temperature [°C]'+#9+'Current [mA]'+#9+'Voltage [V]'+#9+'Power [mW]'+#9+'Instability [mV]'+#9+'Time');
      1 : writeln(DataFile,'Time from start [ms]'+#9+'Temperature [°C]'+#9+'Current [mA]'+#9+'Voltage [V]'+#9+'Power [mW]'+#9+'Instability [mA]'+#9+'Time');
    else
      //MessageDlg('Finish file function recieved wrong feedback type: '+IntToStr(feedback), mtError, [mbOk], 0);
      LeaveMessage('Finish file function recieved wrong feedback type: '+IntToStr(feedback));
      LogError('Finish file function recieved wrong feedback type: '+IntToStr(feedback));
      Result := False;
      Exit;
    end;
  except
    on E:exception do
     begin
      ShowMessage(E.Message);
      Result := false;
      Exit;
     end;
  end;
  Result := True;
end;


function TFormModuleBatchRoman.AquireAndSavePlot(feedback: integer): boolean;
var
  MonTimeStamp :  TTime;
  deltat: Int64;
  MonU, MonI, MonTemp, ValChange, Vykon: real;
  a,b: double;
  sx: string;
begin
  //Aquire
  Aquire;
  //Setlocal variables
  MonU := Mon.Voltage;
  MonI := Mon.Current;
  Vykon := Mon.Power;
  MonTemp := Mon.Temperature;
  MonTimeStamp := Mon.Timestamp;
  case feedback of
    0: ValChange := Abs( ValBeforeDelay - MonU); //Current feedback
    1: ValChange := Abs( ValBeforeDelay - MonI); //Voltage feedback
  else
    MessageDlg('Stability check function recieved wrong feedback type: '+IntToStr(feedback), mtError, [mbOk], 0);
    Result := False;
    Exit;
  end;
  
  //Set instability variables
  if ((not IsNan(ValChange)) and (not IsNan(MaxValChange))) then
    if (ValChange > MaxValChange) then
    begin
      MaxValChange := ValChange;
      case feedback of
        0 : MaxValChangeAt := MonU;//Current feedback
        1 : MaxValChangeAt := MonI;//Voltage feedback
      end;
    end;

  //Plotting
  PlotUI(MonU, MonI);

  // Save to the file
  try
    if ((not IsNan(Vykon)) and (not IsNan(MaxVykon))) then
      if Vykon > MaxVykon then
      begin
        MaxVykon:=vykon; MaxProud:=MonI; MaxNapeti:=MonU;
      end;
    deltat := MilliSecondsBetween(Now , meassurestart);
    //Èas od startu ms, teplota °C, proud mA, napeti V, vykon mW, nestabilita mV or mA imply from feedback, Èas
    if (not IsNan(MonU)) then  MonU := MonU * 1000;
    if (not IsNan(MonI)) then  MonI := MonI * 1000;
    if (not IsNan(Vykon)) then  Vykon := Vykon * 1000;
    if (not IsNan(ValChange)) then  ValChange := ValChange * 1000;
    Writeln(DataFile,IntToStr(deltat)+#9+FloatToStr(MonTemp)+#9+FloatToStr(MonI)+#9+FloatToStr(MonU)+#9+FloatToStr(Vykon)+#9+FloatToStr(ValChange)+#9+TimeToStr(MonTimeStamp));
  except
    // IO error
    On E : EInOutError do begin
      sx := ('I cannot save data file. File has already been closed.');
      //MessageDlg('I cannot save data file. File has already been closed.', mtError, [mbOk], 0);
      leavemessage(sx);
      logerror(sx);
      //TODO:  TADY TO CASTO HAZELO TENHLE MESSAGE PO ZASTAVENI DAVKY
      Result := False;
      Exit
    end else begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;


function TFormModuleBatchRoman.FinishFile(feedback: integer): boolean;
Var
  s, fn: string;
  pn: double;
begin
 //check if is file open
 {$I-}
 FileSize(DataFile);
 {$I+}
 if(IOResult <> 0) then begin {MessageDlg('Neni uz otevreny', mtError, [mbOk], 0);} Result := True; Exit; end;
 try
  //teplotni zavislost finish file
  if false then //teplotnizavyslost
    begin
      Writeln(output2,FloatToStr(Mon.Temperature)+#9+FloatToStr(MaxVykon)+#9+FloatToStr(MaxProud)+#9+FloatToStr(MaxNapeti));
      CloseFile(output2);
    end else begin
      writeln(DataFile,'');
      case feedback of
        0:  //Current feed back
            writeln(DataFile,'Maximalni Vykon [mW]'+#9+'Odpovídající proud [mA]'+#9+'Odpovídající napìtí [V]'+#9+'Maximální nestabilita [mV]'+#9+'pøi napìtí [mV]');
        1:  //Voltage feed back
            writeln(DataFile,'Maximalni Vykon [mW]'+#9+'Odpovídající proud [mA]'+#9+'Odpovídající napìtí [V]'+#9+'Maximální nestabilita [mA]'+#9+'pøi proudu [mA]');
      else
        MessageDlg('Finish file function recieved wrong feedback type: '+IntToStr(feedback), mtError, [mbOk], 0);
        Result := False;
        Exit;
      end;
      writeln(DataFile,FloatToStr(MaxVykon*1000)+#9+FloatToStr(MaxProud*1000)+#9+FloatToStr(MaxNapeti)+#9+FloatToStr(MaxValChange*1000)+#9+FloatToStr(MaxValChangeAt*1000));
      //add new item to report
      pn := MaxVykon / ProjectControl.ProjCellArea ;
      fn := TTextRec(datafile).name;         //Text       //TTextRec
      //TODO: now temoporaryli using logproject as storage for results
      logreport('>>>Finished VA "' + fn +'"  max vykon(W.cm-2): ' + FloatToStr( pn ) + ' pri napeti(V): ' + FloatToStr( MaxNapeti ) );

      CloseFile(DataFile);
    end;

  //display some results
  case feedback of
    0: s := 'Max Power: '+ FloatToStrF(MaxVykon*1000, ffFixed,6,1) + ' mW @ ' + FloatToStrF(MaxNapeti*1000,ffFixed,5,0) +' mV;  Max Instability: ' + FloatToStrF(MaxValChange*1000,ffFixed,4,0) +' mV @ ' + FloatToStrF(MaxValChangeAt*1000,ffFixed,4,0) +' mV';
    1: s := 'Max Power: '+ FloatToStrF(MaxVykon*1000, ffFixed,6,1) + ' mW @ ' + FloatToStrF(MaxNapeti*1000,ffFixed,5,0) +' mV;  Max Instability: ' + FloatToStrF(MaxValChange*1000,ffFixed,4,0) +' mA @ ' + FloatToStrF(MaxValChangeAt*1000,ffFixed,4,0) +' mA';
  else
    MessageDlg('Finish file function recieved wrong feedback type: '+IntToStr(feedback), mtError, [mbOk], 0);
    Result := False;
    Exit;
  end;
  Label73.Caption := s;
 {      Label22.Caption := FloatToStrF(U,ffFixed,7,3) + ' V';
      Label24.Caption := FloatToStrF(I*1000,ffFixed,7,4) + ' mA';
      Label25.Caption := FloatToStrF(T,ffFixed,5,1) + ' °C';
      Label47.Caption := FloatToStrF(U*I*1000,ffFixed,7,3) + ' mW';}
 except
   on E: Exception do
    begin
      LogError('Got Exception '+ E.message);
      Result := False;
      Exit;
    end;
 end;
 Result := True;
end;



function TFormModuleBatchRoman.StabilityCheck(feedback: integer): boolean;
begin
  BDelay(1);
  Aquire;    //!!!!!!!!!!!!!!!!!!!!! here is aquire
  case feedback of
    0 : ValBeforeDelay := Mon.Voltage;  //Current feedback
    1 : ValBeforeDelay := Mon.Current; //Voltage feedback
  else
    MessageDlg('Stability check function recieved wrong feedback type: '+IntToStr(feedback), mtError, [mbOk], 0);
    Result := False;
    Exit;
  end;
  Result := True;
end;










// --------------------------------------------
//---------------------------------------------
// Including of Program for make batch for meassuring FC charateristic
function TFormModuleBatchRoman.BFeedBack(BatchID: integer): integer;     //0=current 1=voltage
begin
  //input must be correct
  if(BatchID >= CellParamBatch.ListOfBatch.Count)then begin
    MessageDlg('BFedBack recieved bad BatchID: '+IntToStr(BatchID), mtError, [mbOk], 0);
    Result := -1;
    Exit;
  end;
  //case feedback of {Current -> 0  and Voltage -> 1}
  if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).FeedBack = 'Current')
    then Result := 0
    else if (PTBatch(CellParamBatch.ListOfBatch[BatchID]).FeedBack = 'Voltage')
            then Result := 1
            else begin
              MessageDlg('Illegal feed back. Process has been stoped', mtError, [mbOk], 0);
              Result := -1;
            end;
end;



procedure TFormModuleBatchRoman.BatchOpenButtClick(Sender: TObject);
var
  p: Pointer;
begin
  SetDataForm.Visible := True;
  SetDataForm.Show;
  p := @BFileName;
  SetDataForm.PFileName_ParentPointer(p);
  p := @CellParamBatch;
  SetDataForm.PCMB_ParnetPointer(p);
end;

function TFormModuleBatchRoman.BInitialiationBatch;
begin
 if(BFileName.Text <>'')then
 begin
   if(not FileExists(BFileName.Text)) then begin
      MessageDlg('Batch file dosn''t exist:' + BFileName.Text, mtError, [mbOk], 0);
      Result := False;
      Exit;
   end;
   if(not CellParamBatch.Open(BFileName.Text))then begin
      MessageDlg('I cannot open batch file but it exists:' + BFileName.Text, mtError, [mbOk], 0);
      Result := False;
      Exit;
   end;
 end;
 if(CellParamBatch.ListOfBatch.Count < 1) then begin
   MessageDlg('This file doesn''t contain batches'':' + BFileName.Text, mtError, [mbOk], 0);
   Result := False;
   Exit;
 end;
 CellParamBatch.MultipleCurrent(0.001);
 CellParamBatch.MultipleVoltage(0.001);
 RefreshBlueBox(0);
 Result := True;
end;




procedure TFormModuleBatchRoman.BRun;
var
  err: integer;

 function AllFilenameCorrected: integer;
 var
   i: integer;
   //filename: integer;
   onetime: boolean;
   handle: integer;
 begin
   onetime := False;
   fDidTurnLoadOff := false;
   Result := 0;
   for i:= 0 to CellParamBatch.ListOfBatch.Count - 1 do
     begin
     if((PTBatch(CellParamBatch.ListOfBatch[i]).FileName)<>'')then
       begin
       handle := FileCreate(PTBatch(CellParamBatch.ListOfBatch[i]).FileName);
       if(handle = -1) then
         begin
         Result := i+1;
         FileClose(handle);
         Exit;
         end;
       FileClose(handle);
       if( (not onetime)and(not DeleteFile(PTBatch(CellParamBatch.ListOfBatch[i]).FileName)) )then
          begin
          onetime := True;
          MessageDlg('Ou, I cannot delete an experimental file: '+PTBatch(CellParamBatch.ListOfBatch[i]).FileName, mtError, [mbOk], 0);
          end;
       end;
     end;
 end;

begin
  {Initializace konstant}
  BatchID := 0;

  //Input must be correct
  if(CellParamBatch.ListOfBatch.Count < 1) then begin
    MessageDlg('The batch are empty. Process has been stoped', mtError, [mbOk], 0);
    Exit;
  end;
  if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).FileName = '') then begin
    MessageDlg('First item of batch doesn''t content file name.', mtError, [mbOk], 0);
    Exit;
  end;
  err := AllFilenameCorrected;
  if(err > 0) then begin
    MessageDlg('File name in batch item '+IntToStr(err)+' cannot be used. Please repair it. ' +#13#10+ PTBatch(CellParamBatch.ListOfBatch[err-1]).FileName, mtError, [mbOk], 0);
    Exit;
  end;

  {Viditelnost komponent, inicializace a pristup k nim, inicializace grafu}
  BeforeRun;
  LeaveMessage('Batch START.');

  {Graph creating}
  CreateGraph;   //lze vypnout a ppustit naopak v BatchExecute

  //Initialization of last feedback. It is equal "not first feedback". Change is call in BatchExecute
  if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).FeedBack = 'Current')
    then LastFeedBack := 'Voltage';
  if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).FeedBack = 'Voltage')
    then LastFeedBack := 'Current';                                                    //LASTFEEDBACK!!!!

  //Call execute
  if(not BatchExecute(BatchID)) then
    begin
      //ShowMessage('Batch execute returned false');
      LeaveMessage('Batch execute returned false');
      Exit;
    end;
end;


function TFormModuleBatchRoman.BatchExecute(BatchIndex: Int64): boolean;
var
  From: real;
  PBItem: PTBatch;
  s: string;
  xfrom, xto: double;
begin
  //Write information about start to the logfile
  LogProjectEvent('NEW BATCH (VA char start). New BatchID: '+ IntToStr( BatchIndex ) );
  LeaveMessage('begin of batch execute');
  RefreshBatchForm;  //write info mesage containing BatchID ...

  //Input must be correct
  if(CellParamBatch.ListOfBatch.Count <= 0) then begin
    BStopIt(StepTimer,StorageDataTimer,BStop);
    MessageDlg('The batch are empty. Process has been stoped.', mtError, [mbOk], 0);
    Result := False;
    Exit;
  end;
  if(BatchIndex > CellParamBatch.ListOfBatch.Count) then begin
    BStopIt(StepTimer,StorageDataTimer,BStop);
    MessageDlg('BatchExecute: The batch index has overflowed!.', mtError, [mbOk], 0);
    Result := False;
    Exit;
  end;

  //if the last batch item was reached and now is calling last + 1 raise finishfile and return false
  if(BatchIndex = CellParamBatch.ListOfBatch.Count)then begin
    BStopIt(StepTimer,StorageDataTimer,BStop);
    Result := False;
    Exit;
  end;

  //ready
  PBItem := PTBatch(CellParamBatch.ListOfBatch[BatchIndex]);

  //Set "blue box" with new data belongs to new Batch item
    RefreshBlueBox(BatchIndex);
  RefreshBatchForm;
  LeaveMessage('batch execute - refreshblubox');

  //Application.ProcessMessages;   //???? nevim jestli to je dobry napad

  //Initialization intervals for execution
  DelayBtStep := Abs(Round(PBItem^.TimeOfStep));
  DelayBtLoad := Abs(Round(PBItem^.DelayBtLoad));
    //Corretion of timer inrevals !!!!!!!!!!!!!!! Read in head of this file
    //{zakomentovano MV: zadna korekce nebude ;)}
    //DelayBtStep := DelayBtStep - TimerIntervalCorrection_StepTimer;

    if(DelayBtStep <= 0)then begin
      BStopIt(StepTimer,StorageDataTimer,BStop);
      MessageDlg('BatchExecute: Correction "DelayBtStep" faild due to to high correction! Correction is: -'+IntToStr(-99999) + ' and inteval is' +IntToSTr(DelayBtStep), mtError, [mbOk], 0); //TimerIntervalCorrection_StepTimer
      Result := False;
      Exit;
    end;
    //{zakomentovano MV: zadna korekce nebude ;)}
    //DelayBtLoad := DelayBtLoad - TimerIntervalCorrection_DataStorageTimer;
    if(DelayBtLoad <= 0)then begin
      BStopIt(StepTimer,StorageDataTimer,BStop);
      MessageDlg('BatchExecute: Correction "DelayBtLoad" faild due to to high correction! Correction is: -'+IntToStr(-9999999) + ' and inteval is' +IntToSTr(DelayBtLoad), mtError, [mbOk], 0); //TimerIntervalCorrection_DataStorageTimer
      Result := False;
      Exit;
    end;
  // continuing set processial order
  if(PBItem^.ProcessType = 'Const')
    then begin
      DelayBtStep := Infinity;
      PBItem^.Step := 0;
      From := PBItem^.ConstV;
      s := PBItem^.ProcessType + ' ' +  PBItem^.FeedBack + ' ' + FloatToStr( From);
    end else begin
      if(PBItem^.ProcessType = 'From To')
        then begin
          if (DelayBtStep = DelayBtLoad)then DelayBtLoad := Infinity;
          From := PBItem^.From;
          s := PBItem^.ProcessType + ' ' +  PBItem^.FeedBack + ' (' + FloatToStr( From) + '; ' + FloatToStr( PBItem^.ToV ) + ')';
        end else begin
          BStopIt(StepTimer,StorageDataTimer,BStop);
          MessageDlg('Unknow process type: '+PTBatch(CellParamBatch.ListOfBatch[BatchIndex]).ProcessType, mtError, [mbOk], 0);
          Result := False;
          Exit;
        end;
    end;

  //leave meewesage and update token
  LogMSG('BATCH type: '+ s );
  hwtoken.statusmsg2 := s;

  {DelayBtStep = DelayBtLoad menas that user wants use simply loading of data.
  Only befor change point and that's all.
  So timer "DataSTorageTimer" is switch off with using infiniti interval}

  //If filename exist close file (if it is opened) And open new file. (rewrite open)
  if(PBItem^.FileName <> '')then begin
    if( not FinishFile(BFeedBack(BatchIndex)))then begin Result := False; Exit; end;
    if( not OpenDataFileAndInit(ExtractFileName(PBItem^.FileName),
                                BFeedBack(BatchIndex),
                                PBItem^.From * 1000,
                                PBItem^.ToV * 1000,
                                PBItem^.Step * 1000,
                                Abs(PBItem^.TimeOfStep)) ) then
    begin //File open faild
      BStopIt(StepTimer,StorageDataTimer,BStop);
      MessageDlg('Cannot rewrite and make head in file for storage meassuring data: '+PTBatch(CellParamBatch.ListOfBatch[BatchIndex]).FileName, mtError, [mbOk], 0);
      Result := False;
      Exit;
    end else begin //File has been opened successfully
//!!! {Graph creating}
      //CreateGraph;   //Vypnuto protoze pusteno z BRun. Ale treba nekdy ay bude graf delany jinak
    end;
  end else
    //write delimiter between individual batch belonging to same file and if DelayBtLoad <> High(Int64);
    if ( (BatchIndex <> 0) and (DelayBtLoad <> High(Int64)) )then begin
      if(not BDataWriteln('----------------------------------------------------------------------------'))
        then begin
          BStopIt(StepTimer,StorageDataTimer,BStop);
          MessageDlg('I cannot write line to the data file: '+PTBatch(CellParamBatch.ListOfBatch[BatchIndex]).FileName, mtError, [mbOk], 0);
          Result := False;
          Exit;
        end;
    end;

  {Set feed back relay}
  if(LastFeedBack <> PBItem^.FeedBack) or true then
    if (PBItem^.FeedBack = 'Current') then
      //Feedback current
      SetFeedbackCurrent( From ) //MainPTCiface.PTCSetCC( From )
    else
      //Feedback voltage
      SetFeedBackVoltage( From ); //MainPTCiface.PTCSetCV( From );
  LastFeedBack := PBItem^.FeedBack;

  {Set potentiostat to wokr state} //Call BSetRelay It depent on feedback (in future ownvariable) if is it "Disconect" - it can be use for Pause in batching and "OnlyVoltageLoad" - it can be used for obtaining open voltage. It wokr only if something is changed .
  if(not BSetRelay(BatchID))then begin
    BStopIt(StepTimer,StorageDataTimer,BStop);
    logerror('BSetRalay failed'); //ShowMessage('BSetRalay failed');
    Result := False;
    Exit;
  end;

  {check and enforce correct polarity of variable "step" - added MV}

  if ( PBItem^.From > PBItem^.ToV ) then
    begin
      //force negative value
      PBItem^.Step := - Abs( PBItem^.Step);
    end
    else
    begin
      //force positive value
      PBItem^.Step := + Abs( PBItem^.Step);
    end;

  //!!!!!added 19.2.2016
  //wait some time to achieve stabilization on the first setpoint

  if (PBItem^.ProcessType = 'From To') then
    begin
      LogProjectEvent('BATCH FromTo initial delay to stabilize');
      //setfeedback was done few lines above - so it should be ready
      //but need to temporarily disable timers - delay with aquire uses application.processmessages
      SetpointSet( From );
      fHoldTimers := true;
      DelayWithAquire( 10000 );
      fHoldTimers := false;
      //update setpoint to restore relay status
      SetpointSet( From );
    end;

  {inicializace konstatnt}
  BatchStartTime := Now;
  BatchStepStartIncrementTime := 0;
  poprve := false;
  //new setpoint
  AnalogOut := From;
  AnalogOut_Init := From;
  SetpointSet(From);
  //stability check ini
  if(not StabilityCheck(BFeedBack(BatchID)))then
    begin
    BStopIt(StepTimer,StorageDataTimer,BStop);
    Result := False; Exit;
    end;

  leaveMessage('BATCH execute - start timers');
  LogProjectEvent('BATCH start execute');
  //use intrevals for setting of timers //Executing
  fHoldTimers := false;
  SetTimerRun(StepTimer,DelayBtStep,StepTimerOnTimer);
  SetTimerRun(StorageDataTimer,DelayBtLoad,StorageDataTimerOnTimer);

  Result := True;
end;



function TFormModuleBatchRoman.BSetRelay(BatchID: integer): boolean;
var
  RelaySate: string;
begin
  //input must be correct
  if(BatchID >= CellParamBatch.ListOfBatch.Count) then begin
    BStopIt(StepTimer,StorageDataTimer,BStop);
    MessageDlg('BSetRelay: index of list of batches is overflowed.', mtError,[mbOk], 0);
    Result := False;
    Exit;
  end;
  //body
  RelaySate := CellParamBatch.GetRelayState(BatchID); 
  if( (RelaySate = 'FullConnect') )then begin
    PTCTurnON;
    Result := True;
    Exit;
  end;
  if( (RelaySate = 'Disconnect') )then begin
    PTCTurnOFF;
    Result := True;
    Exit;
  end;
  if(( RelaySate = 'OnlyVoltageLoad')  )then begin
    PTCTurnOFF;
    Result := True;
    Exit;
  end;
//  if(con.RelayState = RsERR)then begin
//    BStopIt(StepTimer,StorageDataTimer,BStop);
//    LogMsg('BSetRealy: Error realy state. May be hardware error or too short time for change state of relay!');
//    MessageDlg('BSetRealy: Error realy state. May be hardware error or too short time for change state of relay!', mtError, [mbOk], 0);
//    Result := False;
//    Exit;
/// end;
  Result := True;
end;

procedure TFormModuleBatchRoman.StepTimerOnTimer(Sender: TObject);
begin
  //Set self disabled
  TTimer(Sender).Enabled := False;
  LeaveMessage('step timer - begin');
  if MainHWInterface.fFCSInterlok then stopsignal := true;
  if  stopsignal then exit;  //TODO:  PREVENTS UNWANTED TURNON AGAIN
  if fHoldTimers then exit;

  //Aquire and save
  if(IsPTCReady) //of((con.RelayState<>RsNONE) and (con.RelayState <> RsERR))
    then AquireAndSavePlot(BFeedBack(BatchID));

  //Prepare new analog out - incrementing with Step
     //AnalogOut := AnalogOut + PTBatch(CellParamBatch.ListOfBatch[BatchID]).Step;
  //BatchStepStartIncrementTime := BatchStepStartIncrementTime + TTimer(Sender).Interval;
  // Jednou mozna pouyiji pro presnejsi nastavnei sweep rate
  AnalogOut := AnalogOut_Init + PTBatch(CellParamBatch.ListOfBatch[BatchID]).Step * Round( Abs(MilliSecondsBetween(Now,BatchStartTime))  / Abs(PTBatch(CellParamBatch.ListOfBatch[BatchID]).TimeOfStep)) ;
  BatchStepStartIncrementTime :=  abs(MilliSecondsBetween(Now,BatchStartTime)); //BatchStepStartIncrementTime + Round(Abs(PTBatch(CellParamBatch.ListOfBatch[BatchID]).TimeOfStep));  //abs(MilliSecondsBetween(Now,BatchStartTime));

  
  //Check end fo batch item or reach general limit
  if(EndBatchItem(AnalogOut,BatchStepStartIncrementTime,BatchStartTime,False))then exit;  //Enable = False both timers are including into.

  //new setpoint - Becouse new analog out was checked
  SetpointSet(AnalogOut);
  //stability check
  if(not StabilityCheck(VAParam.ControlVar))then begin BStopIt(StepTimer,StorageDataTimer,BStop); Exit; end;

  LeaveMessage('step timer - end');
  if  stopsignal then exit;  //TODO:  PREVENTS UNWANTED TURNON AGAIN
  //Set self enabled
  TTimer(Sender).Enabled := True;
end;

procedure TFormModuleBatchRoman.StorageDataTimerOnTimer(Sender: TObject);
begin
  // if step timer is running now break this timer
  if(not StepTimer.Enabled)then Exit;
  if MainHWInterface.fFCSInterlok then stopsignal := true;  
  if  stopsignal then exit;  //TODO:  PREVENTS UNWANTED TURNON AGAIN
  if fHoldTimers then exit;

  LeaveMessage('store timer - start');
  //Set self disabled
  TTimer(Sender).Enabled := False;
  //Aquire and save the data
  if (IsPTCReady) //of((con.RelayState<>RsNONE) and (con.RelayState <> RsERR))
    then AquireAndSavePlot(BFeedBack(BatchID));
  LeaveMessage('storage timer - almost end - aout: '+ FloatToStr(analogout) + ' bstepincrtime '
      + IntToStr(BatchStepStartIncrementTime) + 'start time ' + TimeToStr(BatchStartTime) );
  //Check end fo batch item or reach general limit
  if( EndBatchItem(AnalogOut,BatchStepStartIncrementTime,BatchStartTime,True))then
    begin
      LeaveMessage('storage timer - end batch condition true');
      Exit;  //Enable = False for both timers are including into.
    end;
  //Set self enabled
  LeaveMessage('storage timer - end - timing is ' + IntToStr( TTimer(Sender).Interval ) );
  if stopsignal then exit;  //TODO:  PREVENTS UNWANTED TURNON AGAIN
  TTimer(Sender).Enabled := True;
end;


// --------------------- limits ----


function TFormModuleBatchRoman.GeneralLimitsReached(delay_ms: integer; loops: integer): boolean;
var
  MonU, MonI: real;
  i, increment: integer;
  relayStat: boolean;   //TRelayStatus = ( RsNONE, RsVolt, RsVoltCurr, RsERR );   //true =on
begin
  if(loops < 0)then begin MessageBox(0, 'GeneralLimitsReached Input Error: loops < 0! ','Error',MB_ICONERROR);; result := false; Exit; end;
  //Set local variables
  //Aquire;
  MonU := Mon.Voltage;
  MonI := Mon.Current;
  if ((IsNan(MonU)) or (IsNan(MonI))) then begin result := false; Exit; end;
  loops := loops-1;
  relayStat := getLoadRelayStatus;
  increment := 20000;
  leavemessage('generallimits - before for, loops: ' + IntToStr(loops) + ' monU: ' + FloatToStr( MonU) +
      ' monI: ' + FloatToStr( MonI)   ); //LeaveMessage
  //general limits
  for i := 0 to loops do
  begin
    if (MonU > VaParam.LimVoltHi) or (MonI > VaParam.LimCurrHi) then
    begin
      Result := True;
      LogProjectEvent('Pøekroèena HORNI mez. Exiting general limits. BacthID: '+IntToStr(BatchID));
      PTCTurnOFF; //SetRelayStatus(RsVolt);
      break;
    end;
    if (MonU < VaParam.LimVoltLo) or (MonU > VaParam.LimVoltHi) or (MonI < VaParam.LimCurrLo) or (MonI > VaParam.LimCurrHi) then
    begin
      Result := True;
      if(i=0)then
        begin
          LogProjectEvent('generallimits Iter 0 Pøekroèena mez. Pouze oznamuji, zatim nevypinam vystup. BacthID: '+IntToStr(BatchID));
          break;
        end;
      if(i>0)then begin
        LogProjectEvent('Pøekroèena mez. Èekám >iter '+IntToStr(i+1)+'. '+ IntToStr(delay_ms)+' ms a zkusím to znova. BacthID: '+IntToStr(BatchID));
        PTCTurnOFF; //SetRelayStatus(RsVolt);
        DelayWithAquire(delay_ms);  //BDelay(delay_ms);
        SetRelayStatus( relayStat );
        delay_ms := delay_ms + increment;
        Aquire;  ///!!! musi tu byt asi aquire  !!!
        MonU := Mon.Voltage;
        MonI := Mon.Current;
      end;
    end else
      begin
        Result := False;
        if(i>0)then begin
          LogProjectEvent('Hodnota v mezích. Pokraèuji. BacthID: '+IntToStr(BatchID));
         end;
        //if =0 then   toto je standardni stav, ktery se stava temer porad!!!!!
        break;
      end;
    //set the same state as in the beginning

  end; //for
  LeaveMessage('leaving gen limits reached');
end;

{function TFormModuleBatchRoman.GeneralLimitsReached: boolean;
var
  MonU, MonI: real;
begin
  //Set local variables
  MonU := Mon.Voltage;
  MonI := Mon.Current;
  //general limits
  if (MonU < VaParam.LimVoltLo) or (MonU > VaParam.LimVoltHi) or (MonI < VaParam.LimCurrLo) or (MonI > VaParam.LimCurrHi) then
  begin
    Result := True;
  end else begin
    Result := False;
  end;
end; }



function TFormModuleBatchRoman.EndBatchItem(AnalogOut: real; BatchStartIncrement: Int64; BatchStartTime:TDateTime;UseTime: boolean): boolean;
var
  TryUseNextBatch: boolean;
  Delay_, Loop_: integer;
begin
  TryUseNextBatch := False;

  //check if limits had been reached only for process "From To"
  if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).ProcessType = 'From To')then
  begin
    If ( PTBatch(CellParamBatch.ListOfBatch[BatchID]).Step >= 0 ) then //currently rising, delta > 0
    begin
      If (AnalogOut > PTBatch(CellParamBatch.ListOfBatch[BatchID]).ToV) then
         begin TryUseNextBatch := True; logmsg('Batch end condition: AnalogOout>ToV'); end;
    end
    else //currently falling, delta <0
    begin
      If (AnalogOut  < PTBatch(CellParamBatch.ListOfBatch[BatchID]).ToV) then
        begin TryUseNextBatch := True; logmsg('Batch end condition: AnalogOout<ToV') end;
    end;
  end;
  //general limits  - loping for not 'From To' type only
  if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).ProcessType = 'From To')then
  begin
    Delay_ := 0;
    Loop_ := 1;
  end else begin
    Delay_ := 2000;
    Loop_ := 10;
  end;
  LeaveMessage('endbatchitem - entering GeneralLimitsReached' );

  if not TryUseNextBatch then
    begin

     if( GeneralLimitsReached(Delay_,Loop_))then
     begin
       LogMSG('Pøekroèena mez. Charakteristika se zastaví. BacthID: '+IntToStr(BatchID));
       TryUseNextBatch := True;
     end;

    end;

       {MessageDlg(FLoatToStr(VAParam.LimCurrLo)+' '+FLoatToStr(Mon.Current)+' ' + FloatToStr(CellParamBatch.LowCurretLimit) + #13#10+
               FLoatToStr(VAParam.LimCurrHi)+' ' +FLoatToStr(Mon.Current)+' ' + FloatToStr(CellParamBatch.HighCurretLimit) + #13#10+
               FLoatToStr(VAParam.LimVoltLo)+' ' +FLoatToStr(Mon.Voltage)+' ' + FloatToStr(CellParamBatch.LowVoltageLimit) + #13#10+
               FLoatToStr(VAParam.LimVoltHi)+' ' +FLoatToStr(Mon.Voltage)+' ' + FloatToStr(CellParamBatch.HighVoltageLimit) + #13#10+
               BoolToStr(TryUseNextBatch, True),
               mtError, [mbOk], 0); }

  //Duration limits
  if((BatchStepStartIncrementTime >= PTBatch(CellParamBatch.ListOfBatch[BatchID]).Duration)and(not UseTime))
    then begin
      logmsg('Batch end condition: BatchStepStartIncrementTime>Duration');
      TryUseNextBatch := True;
      //{Pak smazat!!!!!}MessageDlg('real time:' +IntToStr(MilliSecondsBetween(Now,BatchStartTime))+' and incremented time is: '+IntToStr(BatchStepStartIncrementTime), mtInformation, [mbOk], 0);
    end;
  if(( abs(MilliSecondsBetween(Now,BatchStartTime)) > PTBatch(CellParamBatch.ListOfBatch[BatchID]).Duration)and(UseTime)and(PTBatch(CellParamBatch.ListOfBatch[BatchID]).ProcessType <> 'From To'))
    then begin
      logmsg('Batch end condition: Now-BatchStartTime>Duration');
      TryUseNextBatch := True;
      //{Pak smazat!!!!!}MessageDlg('Real time:' +IntToStr(MilliSecondsBetween(Now,BatchStartTime))+' and incremented time is: '+IntToStr(BatchStepStartIncrementTime), mtInformation, [mbOk], 0);
    end;

  //Try call batchExecute with new ID. Set timers for next batch item. Return FLASE if last +1 Batch itme was reached. Than the BStop and do timer.Enabled := FALSE are called automaticaly.
 LeaveMessage('endbatchitem - before try next batch' );
  if(TryUseNextBatch)then
  begin
    //!!!! MAKE DELAY BEFORE STARTING NEW ITEM AND TURN TO OPENVOLTAGE IF REQUESTED
    if false then   //disabled now  !!!!!!
      begin
       LogProjectEvent('After Batch: DELAY 5000ms (BatchID : '+IntToStr(BatchID) + ')');
       LogProjectEvent('Setting OpenVOltage');
       //SetFeedbackCurrent( 0 );  //
       //if(PTBatch(CellParamBatch.ListOfBatch[BatchID]).ProcessType = 'From To')then
        // begin
        // end;
       //DelayWithAquire( 5000 );
     end;

    //StorageDataTimer.Enabled := False;
    //StepTimer.Enabled := False;
    Result := True;
    LogProjectEvent('VA char finished. BatchID: '+IntToStr(BatchID));
    Inc(BatchID);
    if(not BatchExecute(BatchID))then
      begin
        logMsg('Batch execute returned false (' +IntToStr(BatchID) +')');
        exit;
      end;//Call stopit if is reached last batch item.
  end
  else
    begin
      Result := False;
    end;
end;


procedure TFormModuleBatchRoman.DelayWithAquire( dtms: TDateTime );
Var
  t: tDateTime;
begin
  t := Now;
  while ( TimeDeltaNowMS( t) < dtms ) and (not stopsignal) do
    begin
      Aquire;
      delayMS(10);
      Application.ProcessMessages;
    end;
  Aquire;
end;



procedure TFormModuleBatchRoman.BStop;
begin
  //set grahic back
  AfterRun;
  //shut off
  SetFeedbackCurrent(0);
  PTCTurnOFF;
  //Finish the data file
  If(not FinishFile(VAParam.ControlVar)) then MessageDlg('I cannot finished the data file.',mtError,[mbOk],0);
  hwtoken.statusmsg := 'Finished.';
  LockClear;
  ObtainNewDataDirectory;
end;


procedure TFormModuleBatchRoman.BStopIt(var Timer1: TTimer; var Timer2: TTimer; Stop: TMyMethod);
begin
  Timer1.Enabled := False;
  Timer2.Enabled := False;
  Stop;
  if(BatchID < CellParamBatch.ListOfBatch.Count - 1)
    then begin
      LogWarning('VA char finished before reaching last batch item. May be due to error or manual stopping. BatchID: '+IntToStr(BatchID)+'/'+IntToStr(CellParamBatch.ListOfBatch.Count - 1));
      LogMSG('Batch END.');
      //MessageDlg('VA char finished before reaching last batch item. BatchID: '+IntToStr(BatchID)+'/'+IntToStr(CellParamBatch.ListOfBatch.Count - 1)+#13#10+'Batch has finished.'+#13#10+'The data are in your directory: '+ DataPath, mtWarning, [mbOk], 0);
    end else begin
      LogMSG('Batch END.');
      //MessageDlg('Batch has finished. The data are in your directory: '+ DataPath, mtInformation, [mbOk], 0);
    end;
end;

function TFormModuleBatchRoman.BDataWriteln(line: string): boolean;
begin
  {$I-}
  Writeln(DataFile,line);
  {$I+}
  if(IOResult <> 0)then Result := False else Result := True;
end;



function TFormModuleBatchRoman.IsFileInUse(fName: string) : boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(fName) then begin
    Exit;
  end;

  HFileRes := CreateFile(PChar(fName)
    ,GENERIC_READ or GENERIC_WRITE
    ,0
    ,nil
    ,OPEN_EXISTING
    ,FILE_ATTRIBUTE_NORMAL
    ,0);

  Result := (HFileRes = INVALID_HANDLE_VALUE);

  if not(Result) then begin
    CloseHandle(HFileRes);
  end;
end;


procedure TFormModuleBatchRoman.BDelay(ms : word);
var
  when : Int64;
begin
   when := GetTickCount + ms;
  while GetTickCount < when do Application.ProcessMessages;
end;


function TFormModuleBatchRoman.DataPath(): string;
begin
  Result := Edit12.Text;  //should contain full path
end;



procedure TFormModuleBatchRoman.RefreshVaParamForm;
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

  Checkbox1.Checked := GlobalConfig.GlobalRegistrySection.valBool[IdOnZeroCurrentTurnPTCOff];
  Checkbox3.Checked := GlobalConfig.GlobalRegistrySection.valBool[IdMakeSureLoadIsON];
end;

procedure TFormModuleBatchRoman.UpdateVAParamRecord;
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
  VAPAram.LimCurrLo := StrToFloatDef( Edit18.Text, 0) / 1000;
  VAPAram.LimCurrHi := StrToFloatDef( Edit22.Text, 0) / 1000;
  VAPAram.LimVoltLo := StrToFloatDef( Edit23.Text, 0) / 1000;
  VAPAram.LimVoltHi := StrToFloatDef( Edit24.Text, 0) / 1000;
end;


procedure TFormModuleBatchRoman.MonInit;
begin
//  rav_last := VrERR; //forces reloading of coefficients
//  rac_last := CrERR;
  Mon.Temperature := NaN;
  Mon.Voltage := NAN;
  Mon.Current := NAN;
  //Mon.InfoRelayStatus := RsERR;
end;

//***************************HW control wrappers *****


procedure TFormModuleBatchRoman.Aquire; //read all data, determine range used and so on (mainly it reads the voltage and current)
                      //the aquired data are stored in the public variables of the TMonitor class
Var
  b: boolean;
begin
  LeaveMessage('Aquire');
  Mon.ErrorStatus := 1;
  Mon.Voltage := NaN;
  Mon.Current := NaN;
  Mon.Power := NaN;
  Mon.Timestamp := Now;
  Mon.ErrorStatus := 0;
  b := MainHWInterface.AquireAll( hwtoken );
  if not b then
    begin
      Mon.ErrorStatus := 1;
    end;
  Mon.Voltage := MainHWInterface.DataRec.U;
  Mon.Current := MainHWInterface.DataRec.I;
  Mon.Power := MainHWInterface.DataRec.P;
  Mon.Timestamp := MainHWInterface.DataRec.PTCrec.timestamp;
  Mon.Temperature := NAN;   //temp in degrees of celsius
  Mon.ColdEndTemp := NAN;
  //
  fLastRelayStatus := MainHWInterface.DataRec.PTCStatus.isLoadConnected;
end;


procedure TFormModuleBatchRoman.SetRelayStatus(state: boolean);   //RsOFF, RsVolt, RsVoltCurr
Var
  b: boolean;
begin
  LeaveMessage('SetRelayStatus request: ' +  BoolToStr( state ) );
  if state then PTCTurnON
  else
    PTCTurnOFF;
end;

procedure TFormModuleBatchRoman.PTCTurnON;
Var
  b: boolean;
begin
  if not hwtoken.isAccessAllowed then
  begin
    LeaveMessage('Turn PTC ON: HW access NOT allowed!');
    exit;
  end;
  fDesiredRelayStatus := true;
  b:= MainHWInterface.PTCTurnON(hwtoken);
  if b then fLastRelayStatus := true;
  LeaveMessage('Turn PTC ON req:' +  ' res='+ BoolToStr(b));
end;


procedure TFormModuleBatchRoman.PTCTurnOFF;
Var
  b: boolean;
begin
  if not hwtoken.isAccessAllowed then
  begin
    LeaveMessage('Turn PTC OFF: HW access NOT allowed!');
    exit;
  end;
  fDesiredRelayStatus := false;
  b:= MainHWInterface.PTCTurnOFF(hwtoken);
  if b then fLastRelayStatus := false;
  LeaveMessage('Turn PTC OFF req:' + ' res='+ BoolToStr(b));
end;


procedure TFormModuleBatchRoman.SetpointSet(val:real); //value in Volts or Amperes (depending on feedback selected)
Var
  b: boolean;
begin
  LeaveMessage('SetpointSet request val=' +  FloatTOStr( val) + ' feedback='+ LastFeedback);
  if LastFeedBack = 'Current' then  SetFeedbackCurrent(val);
  if LastFeedBack = 'Voltage' then  SetFeedbackVoltage(val);
end;


procedure TFormModuleBatchRoman.SetFeedbackCurrent(sp: real);      //setpoint in amperes
Var
  b: boolean;
Const
  CAlmostZeroCurrentThreshold = 0.001; //A
begin
  if not hwtoken.isAccessAllowed then
  begin
    LeaveMessage('SetConstCurrent: HW access NOT allowed!');
    exit;
  end;
  LastFeedBack := 'Current';
  fDesiredFeedback := CPotCC;
  fDesiredSetpointVal := sp;
  b:= MainHWInterface.PTCSetCC(sp, hwtoken);
  LeaveMessage('set CC ' +  FloatTOStr(sp)+ ' res='+ BoolToStr(b));
  //check wheter the load is turned ON -> and make seure it is
  if not fLastRelayStatus then
    begin
      if (GlobalConfig.GlobalRegistrySection.valBool[IdMakeSureLoadIsON]) and (not fDidTurnLoadOff) then
        begin
          LeaveMessage('  detected Load Relay OFF -> turning load back ON!');
          PTCTurnON;
        end
    end;

  //check if want turn load off for zero setpoint
  //!!!!!!
  //fDidTurnLoadOff := false;
  if GlobalConfig.OnZeroCurrentTurnPTCOff then
    begin
      if abs(sp) < CAlmostZeroCurrentThreshold then
        begin
          LeaveMessage('  PTC turn OFF for zero current is ON -> SP is almost zero -> turning OFF load!!!');
          fDidTurnLoadOff := true;
          PTCTurnOFF;
        end
      else
        begin
          if fDidTurnLoadOff then
            begin
              PTCTurnOn;
              fDidTurnLoadOff := false;
            end;
        end;
    end;
end;

procedure TFormModuleBatchRoman.SetFeedbackVoltage(sp: real);      //setpoint in volts
Var
  b: boolean;
begin
  if not hwtoken.isAccessAllowed then
  begin
    LeaveMessage('SetConstVoltage: HW access NOT allowed!');
    exit;
  end;
  LastFeedBack := 'Voltage';
  fDesiredFeedback := CPotCV;
  fDesiredSetpointVal := sp;
  b:= MainHWInterface.PTCSetCV(sp, hwtoken);
  LeaveMessage('set CV ' +  FloatTOStr(sp)+ ' res='+ BoolToStr(b));
  // check that relay is on
  if not fLastRelayStatus then
    begin
      if GlobalConfig.GlobalRegistrySection.valBool[IdMakeSureLoadIsON] then
        begin
          LeaveMessage('  detected Load Relay OFF -> turning load back ON!');
          PTCTurnON;
        end
    end;

end;



function TFormModuleBatchRoman.getLoadRelayStatus: boolean;
begin
  Result := MainHWInterface.PTCGetRelayStatus( hwtoken );
end;

function TFormModuleBatchRoman.isPTCready: boolean;
begin
  Result := MainHWInterface.PtcIsReady;
end;


//**************************************************** other *****


procedure TFormModuleBatchRoman.RefreshBatchForm;
Var s: string;
begin
  if (BatchIsActive) then
    begin
      s := 'Item: ' +IntToStr(BatchID)+'/'+IntToStr(CellParamBatch.ListOfBatch.Count - 1);
      PanStatus.Caption := s;
      hwtoken.statusmsg := s;
    end;
end;


procedure TFormModuleBatchRoman.SaveParams;
Var f:Textfile;
begin
  AssignFile(f, HomePath + 'vacharparams.txt');
  Rewrite(f);
  writeln(f, BFileName.Text);
  writeln(f, 'range N/A'); //writeln(f, CurrentRangeToStr( Mon.CurrentRange) + VoltageRangeToStr( Mon.VoltageRange));
  writeln(f, 'fuel TODO');
  writeln(f, 'oxygen TODO');
  writeln(f, ProjectControl.ProjMeaPreparation);    //mea prep
  writeln(f, 'ComboBox9.Text');     //anode mat
  writeln(f, 'ComboBox10.Text');      //cathode mat
  writeln(f, 'ComboBox11.Text');      //membrane
  writeln(f, 'ComboBox12.Text');      //ox flow
  writeln(f, 'ComboBox13.Text');      //h2 flow
  writeln(f, 'ComboBox14.Text');      //gdl
  writeln(f, 'ComboBox15.Text');      //hotpress
  writeln(f, FloatToStr( Mon.ColdEndTemp) );
  CloseFile(f);
end;


procedure TFormModuleBatchRoman.LoadParams;
Var f:textfile;
    //i:integer;
    s4, s5,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16: string;
Const paramfile = 'vacharparams.txt';
begin
  if not FileExists(paramfile) then exit;
  AssignFile(f, HomePath + paramfile);
  Reset(f);
  readln(f, s4);
  readln(f, s5);    //dummy read - used to be current range index
  readln(f, s5);
  readln(f, s7);
  readln(f, s8);
  readln(f, s9);
  readln(f, s10);
  readln(f, s11);
  readln(f, s12);
  readln(f, s13);
  readln(f, s14);
  readln(f, s15);
  readln(f, s16);
  CloseFile(f);
  BFileName.Text := s4;
  //if (s16 = '') then Edit22.Text := FloatToStrDef(TempColdEnd) else Edit22.Text := s16;
  //if s8 = 'N' + ComboBox8.Items.ValueFromIndex[0] then ComboBox15.Enabled := false; // 'N' je tam protoze ze nepochopitelnych duvodu neni cteno prbni pismenko a to je N
end;


procedure IncText( Var t: TEdit);
begin
  t.Text:=IntToStr(StrToInt(t.Text)+1);
end;

procedure TFormModuleBatchRoman.LeaveMessage(s: string);
begin
  if cbDebug.checked then Memo1.Lines.Add(s);
end;

procedure TFormModuleBatchRoman.LockGet;
begin
  hwtoken.getLock;
end;

procedure TFormModuleBatchRoman.LockClear;
begin
  hwtoken.unlock;
end;

procedure TFormModuleBatchRoman.ObtainNewDataDirectory;
Var
  datstr: string;
begin
  DateTimeToString(datstr, 'yymmdd', Now);
  DataDir := ProjectControl.getProjPath  + GlobalConfig.getNewFilePrefixAndIncCnt + '_Batch_'+datstr+PathSlash;
  Edit12.Text := DataDir;
end;

procedure TFormModuleBatchRoman.BuUnlockHWClick(Sender: TObject);
begin
  hwtoken.unlock;
end;

procedure TFormModuleBatchRoman.ComboBox6Select(Sender: TObject);
begin
    RefreshVaParamForm;
end;



procedure TFormModuleBatchRoman.ComboBox16Change(Sender: TObject);
begin
 UpdateVAParamRecord;
 RefreshVaParamForm;
end;


procedure TFormModuleBatchRoman.FormShow(Sender: TObject);
begin
  //MonTimer.Enabled := true;
  RefreshVaParamForm;
end;

procedure TFormModuleBatchRoman.FormHide(Sender: TObject);
begin
  //MonTimer.Enabled := false;
end;

procedure TFormModuleBatchRoman.BuGenNewDirClick(Sender: TObject);
begin
  ObtainNewDataDirectory;
end;

procedure TFormModuleBatchRoman.BuOpenBatchClick(Sender: TObject);
var
  olddir: string;
begin
  olddir := ExtractFileDir( BFileName.Text );
  OpenDialogBatch.InitialDir := 'ahh';
  OpenDialogBatch.FileName := '';
  OpenDialogBatch.InitialDir := olddir;

  If OpenDialogBatch.Execute then
    BFileName.Text := OpenDialogBatch.FileName;
end;

procedure TFormModuleBatchRoman.BuHideClick(Sender: TObject);
begin
  FormModuleBatchRoman.Hide;
end;



Function BatchToStr(Var batch: TBatch): string;
Var s: string;
begin
  s := '[';
  with batch do
    begin
      s := s + 'ID»batch' + ';';
      s := s + 'FileName»'+ FileName  + ';';
      s := s + 'FeedBack»'+FeedBack  + ';';
      s := s +  'ProcessType»'+ProcessType  + ';';
      s := s +  'Duration»'+IntToStr(Duration)  + ';';
      s := s +  'ConstV»'+FloatToStr(ConstV)   + ';';
      s := s +  'WaitForStability»'+BoolToStr(WaitForStability)  + ';';
      s := s +  'Stability»'+FloatToStr(Stability)  + ';';
      s := s +  'From»'+FloatToStr(From)   + ';';
      s := s + 'To»'+FloatToStr(ToV)+    ';';
      s := s + 'Step»'+FloatToStr(Step)   + ';';
      s := s +  'TimeOfStep»'+FloatToStr(TimeOfStep) + ';';
      s := s +  'DelayBtLoad»'+IntToStr(DelayBtLoad)  + ';';
      s := s +  'CycleChar»'+BoolToStr(CycleChar) ;
    end;
  s := s + ']';
  Result := s;
end;


procedure TFormModuleBatchRoman.Button3Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFormModuleBatchRoman.Button4Click(Sender: TObject);
Var
 i: integer;
 s: string;
 bat: TBatch;
begin
  i := StrToIntDef( Edit1.Text, 0);
  s := 'N/A';
  if i< CellParamBatch.ListOfBatch.Count then
    begin
      bat := PTBatch(CellParamBatch.ListOfBatch[i])^;
      s :=  BatchToStr( bat  );
    end;
  Memo1.Lines.Add( IntToStr(i) + ': ' + s );
end;



procedure TFormModuleBatchRoman.HandleBroadcastSignals(sig: TMySignal);
begin
  case sig of
    //
    CsigStopRequest:
       begin
         if Button2.Enabled then Button2Click(Button2);
       end;
  end; //case
end;

procedure TFormModuleBatchRoman.CheckBox1Click(Sender: TObject);
begin
  GlobalConfig.OnZeroCurrentTurnPTCOff := Checkbox1.Checked;
end;

procedure TFormModuleBatchRoman.CheckBox3Click(Sender: TObject);
begin
  GlobalConfig.GlobalRegistrySection.valBool[IdMakeSureLoadIsON] := Checkbox3.Checked;
end;

end.

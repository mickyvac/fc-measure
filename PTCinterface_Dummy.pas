unit PTCinterface_Dummy;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils,
  myutils, Logger, ConfigManager, FormGlobalConfig,
  HWAbstractDevicesV3;

{create descendant of virtual abstract potentio object and define its methods
especially including definition of configuration and setup methods}


Const
  CDummyPTCVer = 'DummyPTC 2016-02-23';
  CDummyPTCVerLong = CDummyPTCVer + ' interface (by Michal Vaclavu)';
{
  CIntRezist = 0.100;
  COpenVolt = 1.1;
  CTafelSlope = 0.07;
  CTafelI0 = 0.002;
  CCrossover = 0.001;
  CDistortionfreq = 0.15; //Hz sinusoidal distortion  of current
  CDistortAmp = 0.04;  //Amplitude = fraction of actual current
  CRandomNoiseAmp = 0.003;  //distortion of voltage - Random noise amplitude in Volts is added to basic value of reported voltage
  CDieOutHalfTime = 40; //Die Out is represented es exponential decay of current up to some minumu value it is reset after new setpoint is set
  CDieOutMaxFrac = 0.1;
 }

Type

TDummyPotentio = class (TPotentiostatObject)
    public
      constructor Create;
      destructor Destroy; override;
    public
    //Basic Potenciostat control funcions - made available on all devices
    function AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean; override;
    //  returns electrical DATA and status
    //  this is the only fucntion that actualy aquires the status info (every time it is called)
    //  and after each call the internal status is updated and with it, also the corresponding flags if relevant!
    //  !!! range of voltage and current is checked (and flags set),
    //               but NO ACTION IS TAKEN to prevent overrange -> This should be done by HIGHER LEVEL control fucntion!!!!
     function AquireStatus(Var Status: TPotentioStatus): boolean;  //quickly retrieves only status
    function SetCC( val: double): boolean; override;   //constant current mode
    function SetCV( val: double): boolean; override;   //constant voltage mode
    function TurnLoadON(): boolean; override;            //connect load to PTC
    function TurnLoadOFF(): boolean; override;          //disconnect LOAD (only voltage is monitored continuosly)
  public
    //general control functions
    function IsAvailable(): boolean; override; //indication that device is available = ready to be initialized (meaning can be communicated with)
    //                                                  //if false, it means the device cannot be initilized and cannot become ready
    function Initialize(): boolean; override;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
    procedure Finalize; override;   //do tasks to  prepare for disconnecting
                                              // device will become not ready, if possible - object will disconnect the port beeing used for communication
    function GetFlags(): TPotentioFlagSet; override;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    //                                                            flags will contain indicator why the fuse has been triggerd
    function GenFileInfoHeaderBasic: string; override;
    function GenFileInfoHeaderIncludeDC: string; override;
  protected
    //internal fields for properties
{    fName: string;
    fDummy: boolean;
    fReady: boolean;
    fRngActCurr: TPotentioRangeRecord;
    fRngActVolt: TPotentioRangeRecord;
    fRngActCurrId: byte;
    fRngActVoltId: byte;
    fRngCurrCount: byte;
    fRngVoltCount: byte;
}
  //RANGE reporting and control
  protected
    procedure SetRngCurrent(nr: byte); override;
    procedure SetRngVoltage(nr: byte); override;
    procedure SetRngV4SwLimit(rec: TRangeRecord); override;
    procedure SetRngV4HardLimit(rec: TRangeRecord); override;
  public
    procedure GetRngArrayCurrent( Var ar:TPotentioRangeArray); override;
    procedure GetRngArrayVoltage( Var ar:TPotentioRangeArray); override;
    public //additional
      procedure LoadConfig;
      procedure SaveConfig;
    public //configure simultaion
      fNoiseEnabled: boolean;
      fDieoutEnabled: boolean;
      fCommErrorSimul: boolean;
      fFuseSimul: boolean;
      fSoftLimSimul: boolean;
    public    //parameters fro simulation
      fIntRezist: double;   //Ohm
      fOpenVolt: double;    //V
      fTafelSlope: double;  //V.decade(I)-1
      fTafelI0: double;     //A
      fActivity900mV: double;     //A
      fCrossover: double;   //A
      fDistortionfreq: double; //Hz sinusoidal distortion  of current
      fDistortAmp: double;  //Amplitude = fraction of actual current  (0..1)
      fRandomNoiseAmp: double;  //distortion of voltage - Random noise amplitude in Volts is added to basic value of reported voltage
      fDieOutHalfTime: double; //Die Out is represented es exponential decay of current up to some minumu value it is reset after new setpoint is set
      fDieOutMaxFrac: double;
    private
    //---- private variables declaration
      fConfClient: TConfigCLient;
      //simul state variables
      fPTCmode: TPotentioMode;
      fRelayisON: boolean;
      fLastsetpoint: double;
      fSetpI: double;
      fSetpU: double;
      fLastData : TPotentioRec;
      fLastStatus : TPotentioStatus;
      fT0, fDieoutT0: TDateTime;           //dieoutt0 is updated every time new setpoint is set
      function simulU(i: double): double;
      function simulI(u: double): double;
      function AddNoiseU(u: double): double;
      function AddNoiseI(i: double): double;
      function AddDistortionI(i: double): double;
      function AddDieOutI(i: double): double;
      function AddDieOutInvertedI(i: double): double;
      function convActivityToI0(act: double): double;
  private  //helpers
      procedure mymsg(s: string); //log msg
    //*************************
  end;




Implementation

uses Math;



constructor TDummyPotentio.Create;
begin
  inherited Create('Simple Virtual PTC', CDummyPTCVer, true);
  setIsReady(false);
  fRngCurrRec.low := -100; fRngCurrRec.high := 100;
  fRngVoltRec.low := 100; fRngVoltRec.high := 100;
  fRngCurrId := 0;
  fRngVoltId := 0;
  fRngCurrCount := 1;
  fRngVoltCount := 1;
  fSoftLimSimul := false;
  //
  //fInitialized := false;
  //
      fIntRezist := 0.100;
      fOpenVolt := 1.1;
      fTafelSlope := 0.07;
      fActivity900mV := 0.100;
      fTafelI0 := convActivityToI0( fActivity900mV );
      fCrossover := 0.001;
      fDistortionfreq := 0.15; //Hz sinusoidal distortion  of current
      fDistortAmp := 0.04;  //Amplitude = fraction of actual current
      fRandomNoiseAmp := 0.003;  //distortion of voltage - Random noise amplitude in Volts is added to basic value of reported voltage
      fDieOutHalfTime := 40; //Die Out is represented es exponential decay of current up to some minumu value it is reset after new setpoint is set
      fDieOutMaxFrac := 0.1;

  // init config object
  fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, 'DummyPTC_Config');
end;



destructor TDummyPotentio.Destroy;
begin
  fConfClient.Destroy;
  inherited;
end;


procedure TDummyPotentio.LoadConfig;
begin
  if fConfclient=nil then exit;
  fIntRezist := fConfClient.Load( 'fIntRezist', 0.100 );
  fOpenVolt := fConfClient.Load( 'fOpenVolt', 1.1 );
  fTafelSlope := fConfClient.Load( 'fTafelSlope'  , 0.07 );
  fActivity900mV := fConfClient.Load( 'fActivity900mV'  , 100.0 );                        //rtti
  fTafelI0 := fConfClient.Load( 'fTafelI0'  ,  0.00001 );
  fDistortionfreq := fConfClient.Load( 'fDistortionfreq'  , 0.15 );
  fDistortAmp := fConfClient.Load( 'fDistortAmp'  ,  0.04 );
  fRandomNoiseAmp := fConfClient.Load( 'fRandomNoiseAmp'  ,  0.003 );
  fDieOutHalfTime := fConfClient.Load( 'fDieOutHalfTime'  ,  40.0 );
  fDieOutMaxFrac := fConfClient.Load( 'fDieOutMaxFrac'  , 0.1 );
  fNoiseEnabled := fConfClient.Load( 'fNoiseEnabled'  , false );
  fDieoutEnabled := fConfClient.Load(  'fDieoutEnabled' ,  false );
  fCommErrorSimul := fConfClient.Load( 'fCommErrorSimul'  , false );
end;

procedure TDummyPotentio.SaveConfig;
begin
  if fConfclient=nil then exit;
  fConfClient.Save( 'fIntRezist', fIntRezist );
  fConfClient.Save( 'fOpenVolt', fOpenVolt );
   fConfClient.Save( 'fTafelSlope'  , fTafelSlope );
   fConfClient.Save( 'fActivity900mV'  , fActivity900mV );
  fConfClient.Save( 'fTafelI0'  ,   fTafelI0 );
   fConfClient.Save( 'fDistortionfreq'  , fDistortionfreq );
   fConfClient.Save( 'fDistortAmp'  , fDistortAmp );
   fConfClient.Save( 'fRandomNoiseAmp'  , fRandomNoiseAmp );
   fConfClient.Save( 'fDieOutHalfTime'  , fDieOutHalfTime );
   fConfClient.Save( 'fDieOutMaxFrac'  , fDieOutMaxFrac );
   fConfClient.Save( 'fNoiseEnabled'  , fNoiseEnabled );
   fConfClient.Save(  'fDieoutEnabled' ,  fDieoutEnabled );
   fConfClient.Save( 'fCommErrorSimul'  ,fCommErrorSimul );
end;




function TDummyPotentio.Initialize: boolean;
begin
  Result := true;
  InitPtcRecWithNAN(fLastData, fLastStatus);
  SetCC(0); //ini mode
  TurnLoadOFF; //ini load relay
  Randomize;
  fT0 := Now;
  setIsReady(true);
  mymsg('Connect: Connected to DummyPTC!!!' );
  mymsg('Connect: Id str: ' + CDummyPTCVerLong );
end;


procedure TDummyPotentio.Finalize;
begin
  setIsReady(false);
end;

function TDummyPotentio.IsAvailable(): boolean;  //indication that device is available = ready to be initialized (meaning can be communicated with)
begin
  Result := true;
end;

function TDummyPotentio.GetFlags(): TPotentioFlagSet;    //flags may be device specific, example of common flag would be "Current Overrange" indicator
begin
  Result := [];
end;

procedure TDummyPotentio.SetRngCurrent(nr: byte);
begin
  fRngVoltRec.low := 100;   fRngVoltRec.high := 100;
end;

procedure TDummyPotentio.SetRngVoltage(nr: byte);
begin
  fRngVoltRec.low := 15;   fRngVoltRec.high := 15;
end;


procedure TDummyPotentio.SetRngV4SwLimit(rec: TRangeRecord);
begin
  fRngV4SWLimit := rec;
  fRngV4HardLimit := rec;
end;

procedure TDummyPotentio.SetRngV4HardLimit(rec: TRangeRecord);
begin
  fRngV4SWLimit := rec;
  fRngV4HardLimit := rec;
end;

procedure TDummyPotentio.GetRngArrayCurrent( Var ar:TPotentioRangeArray);
begin
  setlength(ar, 0);
end;

procedure TDummyPotentio.GetRngArrayVoltage( Var ar:TPotentioRangeArray); 
begin
  setlength(ar, 0);
end;

//basic control functions
function TDummyPotentio.AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean;
begin
    Result := false;
    InitPtcRecWithNAN(rec,Status);
    if not IsReady then exit;
    //
    rec.Uref := CommonDataRegistry.valDouble['Vref'];
    if fPTCmode=CPotCC then
          begin
          rec.I := -AddNoiseI( fSetpI );
          if not fRelayisON then rec.I := 0;
          //die out simul: have to treat it that the voltage drops as if there is more current flowing out of FC -nedd the votlage to drop ...
          rec.U := simulU( AddDieOutInvertedI ( AddDistortionI( -rec.I ) ) ); //using already distorted value  + adding more distortion
          end
    else if fPTCmode=CPotCV then
          begin
          rec.U := AddNoiseU( fSetpU );
          if not fRelayisON then rec.U := AddNoiseU ( fOpenVolt );
          rec.I := -AddDieOutI ( AddDistortionI ( simulI( rec.U ) ) );   //using already distorted value + adding more distortion
          end
    else
            begin
            rec.I := 0.;
            rec.U := 0.;
            end;
    //rec.Uref := 0;
   AquireStatus( status );
   fLastData := rec;
   fLastStatus := status;
   Result := true;
end;


function TDummyPotentio.AquireStatus(Var Status: TPotentioStatus): boolean;
begin
    with Status do
    begin
        flagset := [];
        FlagUpdate( fSoftLimSimul, CPtcSoftLimitationActive, flagset);
        FlagUpdate( fFuseSimul, CPtcHardFuseActivated, flagset);        
        setpoint := fLastsetpoint;
        mode := fPTCmode;
        isLoadConnected :=fRelayisON;
        rangeCurrent:= fRngCurrRec;
        rangeVoltage:= fRngVoltRec;
        debuglogmsg:= '[dummy]';
        rngV4Safe := fRngV4SWLimit;
        rngV4hard := fRngV4HardLimit;
    end;
   Result := true;
end;



function TDummyPotentio.SetCC( val: double): boolean;
begin
  fPTCmode := CPotCC;
  fSetpI := -val;
  fLastsetpoint := fSetpI;
  fDieoutt0 := Now;
  Result := true;
end;


function TDummyPotentio.SetCV( val: double): boolean;
begin
  fPTCmode := CPotCV;
  fSetpU := val;
  fLastsetpoint := fSetpU;
  fDieoutt0 := Now;
  Result := true;
end;


function TDummyPotentio.TurnLoadON: boolean;
begin
  fRelayisON := true;
  fDieoutt0 := Now;
  Result := true;
end;


function TDummyPotentio.TurnLoadOFF: boolean;
begin
  fRelayisON := false;
  Result := true;
end;




function TDummyPotentio.AddNoiseI(i: double): double;
begin
  Result := i;
  if fNoiseEnabled then
    begin
    Result := i + 2 * (Random - 0.5) * fRandomNoiseAmp / fIntRezist;
    end;
end;


function TDummyPotentio.AddNoiseU(u: double): double;
begin
  Result := u;
  if fNoiseEnabled then
    begin
    Result := u + 2 * (Random - 0.5) * fRandomNoiseAmp / 3;   //random noise      /3 is just to decrease the amplitude a little
    end;
end;


function TDummyPotentio.AddDistortionI(i: double): double;
Var
  dt: double;
begin
  Result := i;
  //adding distortion
  if fNoiseEnabled then
    begin  //adding sinosoidal distortion
      dt := MilliSecondsBetween(fT0, Now)/1000;  //time in seconds
      Result := i + i * fDistortAmp * sin( dt * fDistortionfreq * Pi);
    end;
end;


function TDummyPotentio.AddDieOutI(i: double): double;
//Die Out is represented es exponential decay of current up to some minumu value it is reset after new setpoint is set
Var
  dt, coef: double;
begin
  Result := i;
  if fDieoutEnabled then
    begin
      dt := MilliSecondsBetween(fDieoutt0, Now)/1000;  //time in seconds
      coef := exp( (-1) *  dt / fDieOutHalfTime );
      if coef<fDieOutMaxFrac then coef := fDieOutMaxFrac;
      Result := i * coef;
    end;
end;

function TDummyPotentio.AddDieOutInvertedI(i: double): double;
//Die Out is represented es exponential decay of current up to some minumu value it is reset after new setpoint is set
Var
  dt, coef: double;
begin
  Result := i;
  if fDieoutEnabled then
    begin
      dt := MilliSecondsBetween(fDieoutt0, Now)/1000;  //time in seconds
      coef := exp( (-1) *  dt / fDieOutHalfTime );
      if coef<fDieOutMaxFrac then coef := fDieOutMaxFrac;
      Result := i / coef;
    end;
end;



function TDummyPotentio.simulU(i: double): double;
Var
  ix, U, DUTafel: double;
begin
  Result := fOpenVolt;
  if not IsReady or not fRelayisON then exit;
  //
  ix := i + fCrossover;
  if ix <= fTafelI0 then DUTafel := 0
  else
    DUTafel := fTafelSlope * log10( ix / fTafelI0);
  U := fOpenVolt - i * fIntRezist - DUTafel;
  Result := U; //if relayisON then
end;


function TDummyPotentio.simulI(u: double): double;
Var
  dUtot, ix, ux, I, DUTafel: double;
  b: boolean;
  epsilon: double;
  {COpenVolt = 1.1;
  CTafelSlope = 0.07;
  CTafelI0 = 0.002;
  CCrossover = 0.001;
  }
begin
  Result := 0.;
  dUtot := fOpenVolt - u;
  epsilon := 0.01;
  ux := simulU( fTafelI0 );
  if not fRelayisON or not isReady then
  begin
    Result := 0.;
    exit;
  end;
  if u>ux then
   begin
     Result := DUtot / fIntRezist;
     exit;
   end;
  //bacause it is not possible easily to calculate current based on voltage setpoint
  //- I have to use iteration - and find approximate solution by using simulU function and finding current for which the U is close enough
  ix := fTafelI0;
  ux := simulU( fTafelI0 );
  while (ux > u) and (ux>0) do
  begin
    ix := ix * 1.005;
    ux := simulU( ix );
    if ix>100 then break;
  end;
  Result := ix;
end;



procedure TDummyPotentio.mymsg(s: string); //set lastmsg and log it at the same time
begin
  logmsg('DummyPTC: '+ s);
end;


function TDummyPotentio.convActivityToI0(act: double): double;
//extrapolate from 900mV to Open voltage using tafel slope
Var
  r: double;
begin
  Result := 0;
  if fOpenVolt<900 then begin end;
  if fOpenVolt<=0 then exit;
  try
    r := (fOpenVolt - 0.9) / fTafelSlope;  //how many decades more or less
    Result := power(10, Log10(act) - r );
  except
    Result := 0;
  end;

end;



function TDummyPotentio.GenFileInfoHeaderBasic: string;
begin
  Result := '[PTC Status]'#13#10
            + 'ID=VIRTUAL PTC '+ CDummyPTCVer + #13#10
end;

function TDummyPotentio.GenFileInfoHeaderIncludeDC: string;
begin
  Result := GenFileInfoHeaderBasic
            + 'OutputEnabled='+ BoolToStr( fRelayisON )+#13#10
            + 'Feedback='+ PTCModeToStr( fPTCmode )+#13#10
            + 'Setpoint='+ FloatToStrF( fLastsetpoint, ffFixed, 4,2)+#13#10
            + 'V='+ FloatToStrF( fLastData.U , ffFixed, 4,2)+#13#10
            + 'Vref='+ FloatToStrF( fLastData.Uref , ffFixed, 4,2)+#13#10
            + 'I='+ FloatToStrF( fLastdata.I , ffFixed, 4,2)+#13#10;
end;

end.

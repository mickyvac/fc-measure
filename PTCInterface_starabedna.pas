unit HWInterfaceMeasure;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ExtCtrls, DateUtils,
  HWInterfaceDef;

Type
  TCurrentRange = ( Cr2A, Cr200mA, Cr20mA, Cr2mA, CrERR );
  TVoltageRange = ( Vr10V, Vr2V, Vr1V, VrERR );
  TRelayStatus = ( RsNONE, RsVolt, RsVoltCurr, RsERR );  
  TFeedback = ( FBCurrent, FBVoltage );
  TCorrFactors = record
                  Factor: real;
                  Offset: real;
                  SetPointFactor: real;
                  SetPointOffset: real;
                 end;

  TMonitor = record
    Voltage: real;     //voltage in volts
    Current: real;     //current in amperes
    Power: real;
    Temperature: real;   //temp in degrees of celsius
    ColdEndTemp: real;
    HumidificationH2: real; // Humidification of H2 in RH%
    HumidificationAIR: real;  // Humidification of AIR/O2 in RH%
    VoltageRange: TVoltageRange;
    CurrentRange: TCurrentRange;
    InfoRelayStatus: TRelayStatus;
    PosPwr: real;
    NegPwr: real;
    PosAbsolVolt: real;
    Timestamp: TDateTime;
    ErrorStatus: byte; // 0 = all OK, 1=
  end; //TMonitor

  TControl = record
    InvertCurrent: boolean;
    InvertVoltage: boolean;
    SetPointVal: real;
    SetPointIsValid: boolean;
    Feedback: TFeedback;
    RelayState: TRelayStatus;
  end; //TControl

  TVADriveParam = record
      // VA char drive parameters
    LastSetpoint: double;
    InternStep: double;
    InternLimit: double;
    Valid: boolean;
    GoingBack: boolean;
    end;
    //


//-----public headers-----------------


  procedure MeasureInit;  //!!!!! must be called at start to create necessary objects

  //Tmonitor
  procedure Aquire; //read all data, determine range used and so on (mainly it reads the voltage and current)
                      //the aquired data are stored in the public variables of the TMonitor class
  procedure MonInit;   //call at start or later to reinitialize variables
  function TestIsDummy():boolean;  //test if we are working with real card interface
  function VoltageRangeToStr(r: TVoltageRange): AnsiString;
  function CurrentRangeToStr(r: TCurrentRange): AnsiString;
  function RelayStatusToStr(r: TRelayStatus): AnsiString;
  //function ReadVoltageRaw():real;
  //function ReadCurrentRaw():real;

  //Tcontrol
  procedure ConInit;   //call at start or later to reinitialize variables
  procedure SetpointSet(val:real); //value in Volts or Amperes (depending on feedback selected)
  procedure SetpointSetRaw(val:real); //value as voltage - directly set DA out (maximum is +- 10.)
  procedure SetpointUpdate; //sets again last setpoints (use when the coefficients are changed)
  procedure SetRelayDisconnect;      //disconnect load from the unit
  procedure SetRelayVoltOnly;        //connect load to only voltage measurement
  procedure SetRelayFullConnection;  //connect load to Voltage meas. and output drive
  procedure SetRelayStatus(rs:TRelaystatus);   //RsOFF, RsVolt, RsVoltCurr
  procedure SetFeedbackCurrent(sp: real);      //setpoint in amperes
  procedure SetFeedbackVoltage(sp: real);      //setpoint in volts

  //coefficients
  function InitializeCoefficients: boolean;  //!!call this one at start
  function SaveCoefficients: boolean;

  procedure UpdateRangeCoefficients;
  procedure ConfigCurrRange(r: TCurrentRange; fact, offs, spfact, spoffs: real);
  procedure ConfigVoltRange(r: TVoltageRange; fact, offs, spfact, spoffs: real);
  procedure ReadCurrRange(r: TCurrentRange; Var fact, offs, spfact, spoffs: real);
  procedure ReadVoltRange(r: TVoltageRange; Var fact, offs, spfact, spoffs: real);

  //HumidificationSenzors
  //procedure InitializeHumidificationSenzors();
  //procedure DestructorHumidificationSenzors();

  procedure DelayMS( d:longint );

Const
  Fconfname = 'config-coef.txt';

  MeanValIter: word = 40;

  RelayDelayTime: word = 200; //in ms

  ChannelVoltage: byte = 1;
  ChannelCurrent: byte = 2;
  ChannelTemperature: byte = 3;
  ChannelTempColdEnd: byte = 4;
  ChannelVoltageRange: byte = 5;
  ChannelCurrentRange: byte = 6;
  ChannelVoltageRelayStat: byte = 7;
  ChannelCurrentRelayStat: byte = 8;
  ChannelPosPowerMon: byte = 9;
  ChannelNegPowerMon: byte = 10;
  ChannelVoltagePosMon: byte = 11;
  ChannelHumidificationHIH4000_H2: byte = 12;
  ChannelHumidificationHIH4000_AIR: byte = 13;
  ChannelHumidificationBB_H2: byte = 14;

Var
    //!!!!  measurement interface object - use for all data aquisition
    //!!!!!!!!!!! must be initialized (is done in MeasureInit)
    MainIface: TCommonInterfaceObject;


  Mon: TMonitor; //here are placed all aquired data and status
  Con: TControl;

  CurrCorrFactors: array [TCurrentRange] of TCorrFactors;
  VoltCorrFactors: array [TVoltageRange] of TCorrFactors;

  //HumidificationSenzors: THumiSenzors;

  TempAmplification: real = 1000;
  WireResistance: real = 0.50;         //Ohm
  RoomTSensCoef: real = 0.0203566;      //V per K



implementation

uses main, bk8500;

Var
  VoltageFactor: real;
  VoltageOffset: real;
  CurrentFactor: real;
  CurrentOffset: real;
  SetPointFactor: real;
  SetPointOffset: real;

  rav_last: TVoltageRange;
  rac_last: TCurrentRange;

// -----------private headers  -------------

  function ReadVoltage():real; forward;
  function ReadCurrent():real; forward;
  function ReadTemp(): real; forward;
  function ReadTempColdEnd():real; forward;
  function ReadPosPowerMon():real; forward;
  function ReadNegPowerMon():real; forward;
  function ReadRelayStatus(): TRelayStatus; forward;
  function ReadVoltageRange(): TVoltageRange; forward;
  function ReadCurrentRange(): TCurrentRange; forward;
  function ReadPosVoltMon():real; forward;
  procedure RelayChangeState; forward;



  
//--- impl ---



procedure MeasureInit;
begin
  MainIface := TCommonInterfaceObject.Create();
  MonInit;
  ConInit;
end;



///--- helper functions

procedure Readln4real(Var f: TextFile; Var fact, offs, spfact, spoffs: real);
begin
  fact := 1;
  offs := 0;
  spfact := 1;
  spoffs := 0;
  readln(f,fact);
  readln(f,offs);
  readln(f,spfact);
  readln(f,spoffs);
end;

procedure Writeln4real(Var f: TextFile; Var fact, offs, spfact, spoffs: real);
begin
  writeln(f,fact);
  writeln(f,offs);
  writeln(f,spfact);
  writeln(f,spoffs);
end;

function InitializeCoefficients : boolean;   //return true on success false on file read error
Var
  fconf: TextFile;
  buf: string;
  fact, offs, spfact, spoffs: real;
begin
  result := false;
{$ifdef AddHumiForm}
  InitializeHumidificationSenzors();
{$endif}
  ConfigCurrRange(Cr2A, 1, 0 ,1, 0);
  ConfigCurrRange(Cr200mA, 1, 0 ,1, 0);
  ConfigCurrRange(Cr20mA, 1, 0 ,1, 0);
  ConfigCurrRange(Cr2mA, 1, 0 ,1, 0);
  ConfigCurrRange(CrERR, 1, 0 ,1, 0);
  ConfigVoltRange(Vr10V, 1, 0 ,1, 0);
  ConfigVoltRange(Vr2V, 1, 0 ,1, 0);
  ConfigVoltRange(Vr1V, 1, 0 ,1, 0);
  ConfigVoltRange(VrERR, 1, 0 ,1, 0);

  //fopen
  if FileExists(Fconfname) then
  begin
   AssignFile(fconf, Fconfname);
   Reset(fconf);
  end else begin
   result := false;
   exit;
  end;
  //read data
  readln(fconf,buf); //dummy
  readln(fconf,buf); //dummy
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigCurrRange(Cr2A, fact, offs, spfact, spoffs);
  readln(fconf,buf); //dummy
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigCurrRange(Cr200mA, fact, offs, spfact, spoffs);
  readln(fconf,buf); //dummy
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigCurrRange(Cr20mA, fact, offs, spfact, spoffs);
  readln(fconf,buf); //dummy
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigCurrRange(Cr2mA, fact, offs, spfact, spoffs);
  readln(fconf,buf); //dummy - Volt 10V
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigVoltRange(Vr10V, fact, offs, spfact, spoffs);
  readln(fconf,buf); //dummy - Volt 2V
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigVoltRange(Vr2V, fact, offs, spfact, spoffs);
  readln(fconf,buf); //dummy - Volt 1V
  Readln4real(fconf, fact, offs, spfact, spoffs);
  //ConfigVoltRange(Vr1V, fact, offs, spfact, spoffs);
  CloseFile(fconf);
  result := true;
end;


function SaveCoefficients : boolean;   //return true on success false on file read error
Var
  fconf: TextFile;
  fact, offs, spfact, spoffs: real;
begin
  SaveCoefficients := true;
  //fopen
  AssignFile(fconf, Fconfname);
  Rewrite(fconf);
  //save data
  writeln(fconf, '#Correction factors - every group has four numbers');
  writeln(fconf, '#Current 2A');
  ReadCurrRange(Cr2A, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  writeln(fconf, '#Current 200mA');
  ReadCurrRange(Cr200mA, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  writeln(fconf, '#Current 20mA');
  ReadCurrRange(Cr20mA, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  writeln(fconf, '#Current 2mA');
  ReadCurrRange(Cr2mA, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  writeln(fconf, '#Voltage 10V');
  ReadVoltRange(Vr10V, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  writeln(fconf, '#Voltage 2V');
  ReadVoltRange(Vr2V, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  writeln(fconf, '#Voltage 1V');
  ReadVoltRange(Vr1V, fact, offs, spfact, spoffs);
  Writeln4Real(fconf, fact, offs, spfact, spoffs);
  CloseFile(fconf);
end;


//=================== Tmonitor implementation ====


//***********
//Aquire data
//***************

procedure Aquire;
Var
  rav: TVoltageRange;
  rac: TCurrentRange;
  rv, rc, rp, nv, nc, np, s, t: real;
  ts: TDateTime;
  updsetpoint: boolean;
begin
  Mon.ErrorStatus := 0;
  updsetpoint := false;

  //determien ranges
  rav := ReadVoltageRange;
  rac := ReadCurrentRange;

  Mon.InfoRelayStatus := ReadRelayStatus;    //****
  //ranges
  Mon.VoltageRange := rav;        //****
  Mon.CurrentRange := rac;        //****


  {if ((rav = VrERR) or (rac = CrERR)) then Mon.ErrorStatus := 1;
  if (rav_last <> rav) and (rav<>VrERR) then //set different set of coefficients
  begin
    UpdateRangeCoefficients;
    updsetpoint := true;
  end;
  if (rac_last <> rac) and (rac<>CrERR) then
  begin
    UpdateRangeCoefficients;
    updsetpoint := true;
  end; }

  rav_last := rav;
  rac_last := rac;
  if (updsetpoint) then SetpointUpdate;
  //read voltage, curent
  //rv := ReadVoltage;
  //rc := ReadCurrent;

  MainIface.PotentioRead();
  Mon.ErrorPotentio := Ord( MainIFace.LastResult );
  //Label15.Caption := IntToStr( LastCommResult );
  if MainIface.PotentioStatus.isError then exit;      //!!!!!!!!!!!!!!
  //if Mon.ErrorPotentio>0 then exit;
  rv:= MainIface.PotentioData.U;
  rc:= MainIface.PotentioData.I;
  rp:= MainIface.PotentioData.P;
  ts := MainIface.PotentioData.timestamp;   //timestamp
  //
  nv := rv;
  if ( Con.InvertVoltage ) then nv := -rv;
  nc := rc;
  if ( Con.InvertCurrent ) then nc := -rc;
  Mon.Voltage := nv;
  Mon.Current := nc;
  Mon.Timestamp := ts;
  Mon.Power := nc * nv;
  Mon.Temperature := ReadTemp;   //temp in degrees of celsius
  Mon.ColdEndTemp := ReadTempColdEnd;
  Mon.HumidificationH2 := -1; //HumidificationSenzors.Humidification_H2();
  Mon.HumidificationAIR := -1; //HumidificationSenzors.Humidification_AIR();
  Mon.PosPwr := ReadPosPowerMon;
  Mon.NegPwr := ReadNegPowerMon;
  Mon.PosAbsolVolt := ReadPosVoltMon;
end;

procedure MonInit;
begin
  rav_last := VrERR; //forces reloading of coefficients
  rac_last := CrERR;
  Mon.Temperature := -200;
  Mon.Voltage := 100;
  Mon.Current := 100;
  Mon.InfoRelayStatus := RsERR;
end;


function TestIsDummy():boolean;
begin
 Result := false;
end;

function VoltageRangeToStr(r: TVoltageRange): AnsiString;
begin
  case r of
    Vr10V: Result:= 'Voltage 10V';
    Vr2V:  Result:= 'Voltage 2V';
    Vr1V:  Result:= 'Voltage 1V';
    else  Result:= 'Undefined state';
  end;
end;



function CurrentRangeToStr(r: TCurrentRange): AnsiString;
begin
  case r of
    Cr2A: Result:= 'Current 2000mA';
    Cr200mA:  Result:= 'Current 200mA';
    Cr20mA:  Result:= 'Current 20mA';
    Cr2mA:   Result:= 'Current 2mA';
    else  Result:= 'Undefined state';
  end;
end;

function RelayStatusToStr(r: TRelayStatus): AnsiString;
begin
  case r of
    RsVoltCurr: Result:= 'Power + Voltage';
    RsVolt:  Result:= 'Voltage only';
    RsNone:  Result:= '__   \__';
    else  Result:= 'Undefined state';
  end;
end;


function ReadVoltage():real;
var i: integer;
    prumer: real;
begin
// prumer:=0;
// for i:=1 to MeanValIter do prumer := Form2.PCIBaseEnv.GetChannel(ChannelVoltage) + prumer;
// prumer := prumer / MeanValIter;
 //Result := VoltageFactor * (prumer - VoltageOffset);
end;

function ReadVoltageRaw():real;
var i: integer;
    prumer: real;
begin
 prumer:=0;
 //for i:=1 to MeanValIter do prumer := Form2.PCIBaseEnv.GetChannel(ChannelVoltage) + prumer;
 //Result := prumer / MeanValIter;
end;


function ReadCurrent():real;
var i: integer;
    prumer: real;
begin
 //prumer:=0;
 //for i:=1 to MeanValIter do prumer := Form2.PCIBaseEnv.GetChannel(ChannelCurrent) + prumer;
 //prumer := prumer/MeanValIter;
 //Result := CurrentFactor * (prumer - CurrentOffset);
end;

function ReadCurrentRaw():real;
var i: integer;
    prumer: real;
begin
 //prumer:=0;
 //for i:=1 to MeanValIter do prumer := Form2.PCIBaseEnv.GetChannel(ChannelCurrent) + prumer;
 //Result := prumer/MeanValIter;
end;


function ReadTemp():real;
const
  //Chromel-alumel polynom koeficienty - pro deg C a mV
  //this temperature is realtive to the temp of the "cold end" - second TC junction
  a0 = 0.23;
  a1 = 24152.11;
  a2 = 67233.43;
  a3 = 2210340;
  a4 = -860963915;
  aver = 10;
var   i: integer;
      x, z, t, prumer:real;
begin
 //prumer:=0;
 //for i:=1 to aver do prumer := Form2.PCIBaseEnv.GetChannel( ChannelTemperature ) + prumer;
 //x := prumer / aver;
 //z := x / TempAmplification;
 //t := a0 + z * ( a1 + z * ( a2 + z * (a3 + z * a4)));
 //Result := t + Mon.ColdEndTemp;
 Result := -300;
end;

function ReadTempColdEnd():real;
  //returns value in degree Celsius
  //using RoomTSensCoef
  //expecting sensor that have characteristic T = const . Usens (absolute temperature in Kelvin)
  //typical const value:  20 mV/K   (for datasheet configuration of TL334)
const
  aver = 10;
  zeroC = 273.15; // in Kelvin
var
   i: integer;
   x, z, prumer: real;
begin
 {prumer:=0;
 for i:=1 to aver do prumer := Form2.PCIBaseEnv.GetChannel( ChannelTempColdEnd ) + prumer;
 x := prumer / aver;
 z := x / RoomTSensCoef; //coef means  V / K
 Result := z - zeroC;  //konverze z K na deg C}
 Result := -273;
end;

function ReadPosPowerMon():real;
  //returns value in volts - on board positive power source voltage
const
  aver = 1;
  coef = 2;
var
   i: integer;
   x, prumer: real;
begin
 {prumer:=0;
 for i:=1 to aver do prumer := Form2.PCIBaseEnv.GetChannel(ChannelPosPowerMon) + prumer;
 x := prumer / aver;
 Result := x * coef;}
 Result := 0;
end;

function ReadNegPowerMon():real;
  //returns value in volts - on board positive power source voltage
const
  aver = 1;
  coef = 2;
var
   i: integer;
   x, prumer: real;
begin
 {prumer:=0;
 for i:=1 to aver do prumer := Form2.PCIBaseEnv.GetChannel( ChannelNegPowerMon ) + prumer;
 x := prumer / aver;
 Result := x * coef;}
 Result := 0;
end;

function ReadRelayStatus(): TRelayStatus;
const
  onstate = 4; //value in Volts, above which the relay is activated
var
   rVon, rIon: boolean;
   rV, rI: real;
begin
 {rVon := false;
 rIon := false;
 rV := Form2.PCIBaseEnv.GetChannel( ChannelVoltageRelayStat );
 rI := Form2.PCIBaseEnv.GetChannel( ChannelCurrentRelayStat );
 if (rV>onstate) then rVon := true;
 if (rI>onstate) then rIon := true;
 if (not rVon) and (not rIon) then Result := RsNone
 else if (rVon) and (not rIon) then Result := RsVolt
 else if (rVon) and (rIon) then Result := RsVoltCurr
 else Result := RsERR;}
 Result := RsNONE;
 if MainIface.PotentioStatus.isError then exit;
 Result := RsVolt;
 if MainIface.PotentioStatus.isLoadConnected then Result := RsVoltCurr;
end;

function ReadVoltageRange(): TVoltageRange;
const
  r10Vlow = -2;  //values in volts
  r10Vhigh = -1;
  r2Vlow = -3.0;
  r2Vhigh = -2.0;
  r1Vlow = -5.5;
  r1Vhigh = -4.5;
var
  x: real;
begin
  {Result := VrERR;
  x := Form2.PCIBaseEnv.GetChannel( ChannelVoltageRange );
  if (x>r10Vlow) and (x<r10Vhigh) then Result := Vr10V;
  if (x>r2Vlow) and (x<r2Vhigh) then Result := Vr2V;
  if (x>r1Vlow) and (x<r1Vhigh) then Result := Vr1V;}
  Result := Vr10V;
end;

function ReadCurrentRange(): TCurrentRange;
const
  r2Alow = -5.5;  //values in volts
  r2Ahigh = -4.5;
  r200mAlow = -3.0;
  r200mAhigh = -2.0;
  r20mAlow = -2;
  r20mAhigh = -1;
  r2mAlow = -0.8;
  r2mAhigh = -0.3;
var
  x: real;
begin
  {Result := CrERR;
  x := Form2.PCIBaseEnv.GetChannel( ChannelCurrentRange );
  if (x>r2Alow) and (x<r2Ahigh) then Result := Cr2A;
  if (x>r200mAlow) and (x<r200mAhigh) then Result := Cr200mA;
  if (x>r20mAlow) and (x<r20mAhigh) then Result := Cr20mA;
  if (x>r2mAlow) and (x<r2mAhigh) then Result := Cr2mA;  }
  Result := Cr2A;
end;


function ReadPosVoltMon():real;
const
  aver = 1;
  coef = 2;
var
   i: integer;
   x, prumer: real;
begin
 {prumer:=0;
 for i:=1 to aver do prumer := Form2.PCIBaseEnv.GetChannel( ChannelVoltagePosMon ) + prumer;
 x := prumer / aver;
 Result := x * coef;}
 Result := 0;
end;

//=========end monitor=================================


//==== TControl =========================================
procedure ConInit;
begin
    Con.InvertCurrent := false;
    Con.InvertVoltage := false;
    Con.SetPointVal := 0;
    Con.SetPointIsValid := false;
    Con.Feedback := FBCurrent;
    Con.RelayState := RsERR;
end;

//-------SETPOINT ---------

procedure SetpointSet(val:real);
var newval: real;
begin
  Con.SetPointIsValid := true;
  Con.SetpointVal := val;
  //invert current or voltage
  if (Con.InvertCurrent) and (Con.feedback = FBCurrent) then val := -val;
  if (Con.InvertVoltage) and (Con.feedback = FBVoltage) then val := -val;
  //correction calculations ... !!!
  {newval :=  val * SetPointFactor + SetPointOffset;
  Form2.PCIBaseEnv.SetDA1(newval);}
  if Con.feedback = FBCurrent then   MainIface.PotentioSetCC( val);
  if Con.feedback = FBVoltage then   MainIface.PotentioSetCV( val);
end;

procedure SetpointSetRaw(val:real);
begin
  Con.SetPointIsValid := false;
  {Form2.PCIBaseEnv.SetDA1(val);}
  if Con.feedback = FBCurrent then   MainIface.PotentioSetCC( val);
  if Con.feedback = FBVoltage then   MainIface.PotentioSetCV( val);
end;

procedure SetpointUpdate;
var
  rs: TRelayStatus;
  cr: TCurrentRange;
  vr: TVoltageRange;
begin
  vr := Mon.VoltageRange;
  cr := Mon.CurrentRange;
  if Con.Feedback = FBCurrent then
    begin
      SetPointFactor := CurrCorrFactors[ cr ].SetPointFactor;
      SetPointOffset := CurrCorrFactors[ cr ].SetPointOffset;
    end
  else
    begin
      SetPointFactor := VoltCorrFactors[ vr ].SetPointFactor;
      SetPointOffset := VoltCorrFactors[ vr ].SetPointOffset;
    end;
  if (Con.SetpointIsValid) then SetpointSet( Con.SetpointVal )
  else
    begin
      rs := Con.RelayState;
      {if ( rs = RsVoltCurr) then rs := RsVolt;    //safety measure - disconnect power in undefined state}
      SetRelayStatus( rs );
    end;
end;

procedure RelayChangeState;
Var
  r, s: real;
begin
{
  if (Con.Feedback = FBCurrent) then r := 1
  else r:= -1;
  if (Con.RelayState = RsVoltCurr) then s := 5
  else if (Con.RelayState = RsVolt) then  s := 3
  else s := 0.5;
  Form2.PCIBaseEnv.SetDA2( r*s );
  }
  if (Con.RelayState = RsVoltCurr) then MainIface.PotentioTurnON
  else MainIface.PotentioTurnOFF;
end;


procedure SetRelayDisconnect;
begin
  SetRelayStatus( RsNone );
end;

procedure SetRelayVoltOnly;
begin
  SetRelayStatus( RsVolt );
end;

procedure SetRelayFullConnection;
begin
  SetRelayStatus( RsVoltCurr );
end;

procedure SetRelayStatus(rs:TRelaystatus);
var wait: boolean;
begin
   wait := false;
   if (rs <> Con.RelayState) then wait := true;
   Con.RelayState := rs;
   RelayChangeState;
   if wait then DelayMS( RelayDelayTime );
end;



procedure SetFeedbackCurrent(sp: real);
Var
  rs: TRelayStatus;
begin
  rs := Con.RelayState;
  //prepare new setpoint
  Con.SetPointIsValid := true;
  Con.SetpointVal := sp;
  //check relays
  if (Con.Feedback <> FBCurrent) then  //must switch relay first
  begin //if RsVoltCurr then disconnect and later reconnect otherwise do not need to do anything
    if ( rs = RsVoltCurr) then SetRelayStatus( RsVolt);
    Con.Feedback := FBCurrent;
    RelayChangeState;
    DelayMS( RelayDelayTime );
  end;
  //update coefficients and set new setpoint
  SetpointUpdate;
  SetRelayStatus( rs ); //return to original state (only needed when the state was RsVoltCurr)
end;

procedure SetFeedbackVoltage(sp: real);
Var
  rs: TRelayStatus;
begin
  rs := Con.RelayState;
  //prepare new setpoint
  Con.SetPointIsValid := true;
  Con.SetpointVal := sp;
  //check relays
  if (Con.Feedback <> FBVoltage) then  //must switch relay first
  begin //if RsVoltCurr then disconnect and later reconnect otherwise do not need to do anything
    if (Con.RelayState = RsVoltCurr) then SetRelayStatus( RsVolt);
    Con.Feedback := FBVoltage;
    RelayChangeState;
    DelayMS( RelayDelayTime );
  end;
  //update coefficients and set new setpoint
  SetpointUpdate;
  SetRelayStatus( rs ); //return to original state (only needed when the state was RsVoltCurr)
end;

//==== end TControl =========================================


//-----coefficients utils ----

procedure UpdateRangeCoefficients;
Var
 rV: TVoltageRange;
 rC: TCurrentRange;
begin
  rV := Mon.VoltageRange;
  rc := Mon.CurrentRange;
  CurrentFactor := CurrCorrFactors[ rC ].Factor;
  CurrentOffset := CurrCorrFactors[ rC ].Offset;
  VoltageFactor := VoltCorrFactors[ rV ].Factor;
  VoltageOffset := VoltCorrFactors[ rV ].Offset;
end;


procedure ConfigCurrRange(r: TCurrentRange; fact, offs, spfact, spoffs: real);
begin
  CurrCorrFactors[ r ].Factor := fact;
  CurrCorrFactors[ r ].Offset := offs;
  CurrCorrFactors[ r ].SetPointFactor := spfact;
  CurrCorrFactors[ r ].SetPointOffset := spoffs;
  UpdateRangeCoefficients; //refresh values - so the change take effect
end;

procedure ConfigVoltRange(r: TVoltageRange; fact, offs, spfact, spoffs: real);
begin
  VoltCorrFactors[ r ].Factor := fact;
  VoltCorrFactors[ r ].Offset := offs;
  VoltCorrFactors[ r ].SetPointFactor := spfact;
  VoltCorrFactors[ r ].SetPointOffset := spoffs;
  UpdateRangeCoefficients; //refresh values - so the change take effect
end;


procedure ReadCurrRange(r: TCurrentRange; Var fact, offs, spfact, spoffs: real);
begin
  fact := CurrCorrFactors[ r ].Factor;
  offs := CurrCorrFactors[ r ].Offset;
  spfact := CurrCorrFactors[ r ].SetPointFactor;
  spoffs := CurrCorrFactors[ r ].SetPointOffset;
end;

procedure ReadVoltRange(r: TVoltageRange; Var fact, offs, spfact, spoffs: real);
begin
  fact := VoltCorrFactors[ r ].Factor;
  offs := VoltCorrFactors[ r ].Offset;
  spfact := VoltCorrFactors[ r ].SetPointFactor;
  spoffs := VoltCorrFactors[ r ].SetPointOffset;
end;

procedure InitializeHumidificationSenzors();
begin
{$ifdef AddHumiForm}
 if(HumidificationSenzors = nil)then
   HumidificationSenzors := THumiSenzors.Create;
 HumidificationSenzors.InitFromFile(Form1.HomePath + 'config-humidificationsenzors.txt');
{$endif}
end;

procedure DestructorHumidificationSenzors();
begin
{$ifdef AddHumiForm}
  HumidificationSenzors.SaveToFile;
  HumidificationSenzors.Free;
{$endif}  
end;


procedure DelayMS( d: longint );
Var
  n: TDateTime;
  i: integer;
begin
    n := Now + d / 24/3600/1000;
    while (Now < n) do i := 1;
end;




end.          //unit



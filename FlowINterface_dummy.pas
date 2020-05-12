unit FlowInterface_Dummy;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils,
  myutils, Logger,
  HWAbstractDevicesV3;

{create descendant of virtual abstract FLOW object and define its methods
especially including definition of configuration and setup methods}

Const
  CInterfaceVer = 'DummyFlow interface 2015-10-19 (by Michal Vaclavu)';
  CDistortionfreq = 0.05; //Hz sinusoidal distortion
  CDistortAmp = 5;  //Amplitude = fraction of actual flow in sccm

Type

  TDummyFlowControl = class (TFlowControllerObject)
    public
      constructor Create;
      destructor Destroy;      
    public
    //inherited virtual functions - must override!
      function Initialize: boolean; override;
      procedure Finalize; override;
      function GetFlags: TFlowControllerFlagSet; override;
      //basic control functions
      function Aquire(Var data: TFlowData; Var status: TCommDevFlagSet): boolean; override;
      function SetSetp(dev: TFlowDevices; val: double): boolean; override;
      function GetRange(dev: TFlowDevices): TRangeRecord; override;
    private
      function getIfaceStatus: TInterfaceStatus; override;
    public
      NoiseEnabled: boolean;
    private
    //---- private variables declaration
      initialized: boolean;
      fReady: boolean;
      setpA: array [TFlowDevices] of double;
      t0: TDateTime;           //t0 - for sinusoidal distortion - is updated every time new setpoint is set
      function AddNoise(i, amp: double): double;
      function AddDistortion(i: double): double;
      procedure leavemsg(s: string); //log msg and set return msg
    //*************************
  end;




Implementation

uses Math;

constructor TDummyFlowControl.Create;
begin
  inherited Create('Dummy Flow', 'Dummy Flow Control 2016-01-26 by MV', true);
  setLastAcqTimeMS(0);
  fReady := false;
end;

destructor TDummyFlowControl.Destroy;
begin
  inherited;
end;



function TDummyFlowControl.Initialize: boolean;
begin
  setpA[CFlowAnode] := 0;   //CFlowH2, CFlowO2, CFlowN2, CFlowRes
  setpA[CFlowCathode] := 0;
  setpA[CFlowN2] := 0;
  setpA[CFlowRes] := 0;
  t0 := Now;
  logmsg('Connect: Connected to DummyFLOW!!!' );
  logmsg('Connect: Iface ID str: ' + CInterfaceVer );
  initialized := true;
  fReady := true;
  Result := true;
end;


procedure TDummyFlowControl.Finalize;
begin
   initialized := false;
   fReady := false;
end;


function TDummyFlowControl.GetFlags: TFlowControllerFlagSet;
begin
   Result := [];
end;



function TDummyFlowControl.getIfaceStatus: TInterfaceStatus;
begin
   Result := CISReadyOK;
end;



//basic control functions
function TDummyFlowControl.Aquire(Var data: TFlowData; Var status: TCommDevFlagSet): boolean;

  procedure setit(Var r: TFlowRec; sp: double);
  begin
        InitWithNAN(r);
        with r do
          begin
            timestamp := Now;
            setpoint := sp;
            pressure := AddNoise(14.7, 2);
            temp := AddNoise(20, 10);
            massflow := AddNoise( setpoint, sp/10);
            volflow := 0;
          end;
  end;

begin
   Result := false;
   setit(data[CFlowAnode], setpA[CFlowAnode]);
   setit(data[CFlowN2], setpA[CFlowN2]);
   setit(data[CFlowCathode], setpA[CFlowCathode]);
   setit(data[CFlowRes], setpA[CFlowRes]);
   status := [];
   Result := true;
end;


function TDummyFlowControl.SetSetp(dev: TFlowDevices; val: double): boolean;
begin
   MakeSureIsInRange(val, 0, 1000);
   setpA[dev] := val;
   Result := true;
end;

function TDummyFlowControl.GetRange(dev: TFlowDevices): TRangeRecord;
begin
   Result.low := 0;
   Result.high := 1000;
end;


function TDummyFlowControl.AddNoise(i, amp: double): double;
begin
  Result := i;
  if NoiseEnabled then
    begin
      Result := i + 2 * (Random - 0.5) * amp;
    end;
end;


function TDummyFlowControl.AddDistortion(i: double): double;
Var
  dt: double;
begin
  Result := i;
  //adding distortion
  if NoiseEnabled then
    begin  //adding sinosoidal distortion
      dt := MilliSecondsBetween(t0, Now)/1000;  //time in seconds
      Result := i + i * CDistortAmp * sin( dt * CDistortionfreq * Pi);
    end;
end;


procedure TDummyFlowControl.leavemsg(s: string); //set lastmsg and log it at the same time
begin
  logmsg('DummyPTC: '+ s);
end;


end.

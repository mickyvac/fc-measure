unit HWAbstractdevicesNew;

interface

uses
  Classes;

type

// ***
//common data structure definition
//
   TCommDevFlags = (CFlowConnectionLost,     //general indication that aquire was failing for some time for all devices
                    CFlowAquireThreadRunning);
   TCommDevFlagSet = set of TCommDevFlags;

   TPotentioMode = (CPotCC, CPotCV, CPotCR, CPotCP, CPotERR);

   //conjunction of all possible indicators etc. af all usable potentiostats - hope it can fit inside  255 elements, which is the max for use with a set
   TPotentioFlags = (CPtcFuseActivated, CPtcOverRangeCurrent, CPtcOverRangeVoltage,
                    CPtcHigherRngCurrentAvailbale, CPtcLowerRngCurrentAvailable,
                    CPtcHigherRngCurrentRecommended, CPtcLowerRngCurrentRecommended,
                    cPTCImporatntChangeDetected,
                    CPtcNotConfigured);

   TPotentioFlagSet = set of TPotentioFlags;   //set

   TPotentioRangeRecord = record
      low: double;
      high: double;
   end;

   TRangeRecord = TPotentioRangeRecord;

   TPotentioRangeArray = array of TPotentioRangeRecord;  //dynamic array

   TPotentioRec = record
        timestamp: TDateTime;
        U: double;
        I: double;
        P: double;
        Uref: double;
   end;

   TPotentioStatus = record
        flagSet: TPotentioFlagSet;
        setpoint: double;
        mode: TPotentioMode;
        isLoadConnected: boolean;
        rangeCurrent: TPotentioRangeRecord;
        rangeVoltage: TPotentioRangeRecord;
        debuglogmsg: string;
   end;

   //FLWO DEVICES , STATUS AND CONTROL

   TFlowDevices = ( CFlowAnode, CFlowN2, CFlowCathode, CFlowRes);
   TFlowGasType = ( CGasUnknown, CGasN2, CGasH2, CGasO2, CGasCO, CGasAir, CGasHe, CGasAr);

   TFlowDevFlags = (CFlowDevNotResponding, CFlowSetpointDiffersFromFlow, CFlowDevDisabled);  //for single device - if not possible to aquire several times
   TFlowDevFlagSet = set of TFlowDevFlags;   //set

   TFlowRec = record
        timestamp: TDateTime;
        massflow:  double;          //WILL BE nan IF UNDEFINED
        volflow: double;
        pressure: double;
        temp: double;
        setpoint: double;
        gastype: TFlowGasType;
        flagSet: TFlowDevFlagSet;     //uf undefined state flag is aadded!!!! CHECK FOR IT
        end;

   TFlowData = array [TFlowDevices] of TFlowRec;

   TFlowStatus = record
        CommFlagSet: TCommDevFlagSet;
        end;

   //Valve, Temp, Pressure , STATUS AND CONTROL

   TValveState = (CStateUndefined, CStateOpen, CStateClosed);    //need the third state - NaN

   TValveTPDevFlags = (CVTPNotResponding, CVTPSetpointDiffersForValue, CVTPDevDisabled);  //for single device - if not possible to aquire several times
   TValveTPDevFlagSet = set of TValveTPDevFlags;

   TValveRec  = record
        timestamp: TDateTime;
        state: TValveState;
        end;

   TTempRec = record
        timestamp: TDateTime;
        temp: double;             //in degC  NaN if undefined
        end;

   TPressureSensRec =  record
        timestamp: TDateTime;
        pressure: double;       //in Bar, relative   NaN if undefined
        end;

   TPressureRegRec =  record
        timestamp: TDateTime;
        setpoint: double;      //in Bar, relative   NaN if undefined
        end;


  //principal devices on system

  TValveDevices = ( CVH2bH, CVN2bH, CVO2bO, CVAirbO, CVN2bO, CVN2safN2,
                    CVbHA , CVbOA, CVbNA, CVnSafN2A, CVresA, CVbOK, CVbHK, CVbNK, CVnsafN2K, CVnbNfl,
                    CVnAxH, CVAxO, CVnKxO, CVKxH, CVresFl, CVwtrbH, CVwtrbN, CVwtrbO, CVLED);

  TTempDevices  = ( CTBubH2, CTBubN2, CTBubO2, CTCellBot, CTCellTop, CTOven1, CTOven2, CTRoom);

  TPressureSensDevices = ( CpAnode, CpCathode, CpPiston, CpN2, CpReserve, CpBPControl);
  TPressureRegDevices = ( CpRegBackpress, CMFC1, CMFC2, CMFC3, CMFC4, CMswCtrl, CMswStatus, CMswProgress );

  TOtherDevices  = ( CPwrSwitch );


  TValveData = array [TValveDevices] of TValveRec;

  TTempData = array [TTempDevices] of TTempRec;

  TPressureSensData =  array [TPressureSensDevices] of TPressureSensRec;
  TPressureRegData = array [TPressureRegDevices] of TPressureRegRec;

  TOtherDevData = array [TOtherDevices] of TValveRec;

  TVTPStatus = record
        VTPFlagSet:  TValveTPDevFlagSet;
        CommFlagSet: TCommDevFlagSet;
        end;



  TValveCathodeGas = (CGasCathodeO2, CGasCathodeAir, CGasCathodeN2);
  TValveAnodeGas = (CGasAnodeH2, CGasAnodeN2);


//miscelineous - reporting types

TConnectStatus = ( CDisconnected, CConnecting, CBusy, CReady, CError );




//
// definition of basic devices virtual objects
//

//************************
//PTC

TPotentiostatObject = class
  //ANY single-time ERROR REPORTING should be best done through logmsg/logwarning/logerror functions
  //continous state errors or such may be indicated by status flags...
  public
    constructor Create;
    destructor Destroy; virtual;
  public
    //Basic Potenciostat control funcions - made available on all devices
    function AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean; virtual; abstract;
    //  returns electrical DATA and status
    //  this is the only fucntion that actualy aquires the status info (every time it is called)
    //  and after each call the internal status is updated and with it, also the corresponding flags if relevant!
    //  !!! range of voltage and current is checked (and flags set),
    //               but NO ACTION IS TAKEN to prevent overrange -> This should be done by HIGHER LEVEL control fucntion!!!!
    function AquireStatus(Var Status: TPotentioStatus): boolean; virtual; abstract;  //quickly retrieves only status
    function SetCC( val: double): boolean; virtual; abstract;   //constant current mode
    function SetCV( val: double): boolean; virtual; abstract;   //constant voltage mode
    function TurnLoadON(): boolean; virtual; abstract;            //connect load to PTC
    function TurnLoadOFF(): boolean; virtual; abstract;           //disconnect LOAD (only voltage is monitored continuosly)
  public
    //general control functions
    function IsAvailable(): boolean; virtual; abstract;  //indication that device is available = ready to be initialized (meaning can be communicated with)
    //                                                  //if false, it means the device cannot be initilized and cannot become ready
    function Initialize(): boolean; virtual; abstract;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
    procedure Finalize; virtual; abstract;   //do tasks to  prepare for disconnecting
                                              // device will become not ready, if possible - object will disconnect the port beeing used for communication
    function GetFlags(): TPotentioFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    //                                                            flags will contain indicator why the fuse has been triggerd
  protected
    //internal fields for properties
    fName: string;
    fDummy: boolean;
    fReady: boolean;
    fRngActCurr: TPotentioRangeRecord;
    fRngActVolt: TPotentioRangeRecord;
    fRngActCurrId: byte;
    fRngActVoltId: byte;
    fRngCurrCount: byte;
    fRngVoltCount: byte;
  public
    //general properties
    property Name: string read fName;                   //short name or description of device
    property IsDummy: boolean read fDummy;            //true if NOT a REAL device
    property IsReady: boolean read fReady;            //is ready to provide data - if not, the device will not be accepting commands
    //                                                    must call  Initialize first, to make it ready
  //RANGE reporting and control
  protected
    procedure SetRngCurrent(nr: byte); virtual; abstract;
    procedure SetRngVoltage(nr: byte); virtual; abstract;
  public
    property RngActiveCurrentRng: TPotentioRangeRecord read fRngActCurr;
    property RngActiveVoltageRng: TPotentioRangeRecord read fRngActVolt;
    //use this property to read or to set new reange
    property RngActiveCurrentId: byte read fRngActCurrId write SetRngCurrent;
    property RngActiveVoltageId: byte read fRngActVoltId write SetRngVoltage;
    property RngCurrentCount: byte read fRngCurrCount;  //number of ranges: indexed 0..(N-1)
    property RngVoltageCount: byte read fRngVoltCount;  //number of ranges: indexed 0..(N-1)
  public
    procedure GetRngArrayCurrent( Var ar:TPotentioRangeArray); virtual; abstract;
    procedure GetRngArrayVoltage( Var ar:TPotentioRangeArray); virtual; abstract;
end;


//************************
//FLOW


//conjunction of all possible indicators  - hope it can fit inside  255 elements, which is the max for use with a set
TFlowControllerFlags = (CFlowNotConfigured);

TFlowControllerFlagSet = set of TFlowControllerFlags;


TFlowControllerObject = class
  //ANY single-time ERROR REPORTING should be best done through logmsg/logwarning/logerror functions
  //continous state errors or such may be indicated by status flags...
  public
    constructor Create;
  public
    //setup,configuration of an actual device is defined for that device, because it is device-specific
    function Initialize: boolean; virtual; abstract;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
    procedure Finalize; virtual; abstract;   //do tasks to  prepare for disconnecting resp. disconnects device, makes it not ready
    function GetFlags(): TFlowControllerFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    //                                                            flags will contain indicator why the fuse has been triggerd
    procedure ResetConnection; virtual; abstract; //to try to repair connection lost problem
  public
    //basic control functions
    function Aquire(Var data: TFlowData; Var status: TFlowStatus): boolean; virtual; abstract;  //returns DATA and status
    function SetSetp(dev: TFlowDevices; val: double): boolean; virtual; abstract;   //set setpoint
    function SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean; virtual; abstract;
    function GetRange(dev: TFlowDevices): TRangeRecord; virtual; abstract;
  protected
    //internal fields for properties
    fName: string;
    fDummy: boolean;
    fReady: boolean;
  public
    //general properties
    property Name: string read fName;                   //short name or description of device
    property IsDummy: boolean read fDummy;            //true if NOT a REAL device
    property IsReady: boolean read fReady;            //is ready to provide data - if not, the device will not be accepting commands
    //                                                    must call  Initialize first, to make it ready
end;


//************************
//VTP...Valve Temperature Pressure

TVTPControllerFlags = (CVTPNotConfigured);

TVTPControllerFlagSet = set of TVTPControllerFlags;

TVTPControllerObject = class       //VTP...Valve Temperature Pressure
  //ANY single-time ERROR REPORTING should be best done through logmsg/logwarning/logerror functions
  //continous state errors or such may be indicated by status flags...
  public
    constructor Create;
  public
    //setup,configuration of an actual device is defined for that device, because it is device-specific
    function Initialize: boolean; virtual; abstract;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
    procedure Finalize; virtual; abstract;   //do tasks to  prepare for disconnecting resp. disconnects device, makes it not ready
    function GetFlags(): TFlowControllerFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    //                                                            flags will contain indicator why the fuse has been triggerd
    procedure ResetConnection; virtual; abstract; //to try to repair connection lost problem
  public
    //basic control functions
    function AquireValve(Var data: TValveData): boolean; virtual; abstract;
    function AquireTemp(Var data: TTempData): boolean; virtual; abstract;
    function AquirePressureSens(Var data: TPressureSensData): boolean; virtual; abstract;
    function AquirePressureReg(Var data: TPressureRegData): boolean; virtual; abstract;
    function AquireOther(Var data: TOtherDevData ): boolean; virtual; abstract;
    function SetSetpPressureReg(dev: TPressureRegDevices; val: double): boolean; virtual; abstract;
    //function SetSetpOtherDevice(dev: TOtherDevices; val: double): boolean; virtual; abstract;
    function GetRangePressureSens(dev: TPressureSensDevices): TRangeRecord; virtual; abstract;
    function GetRangePressureReg(dev: TPressureRegDevices): TRangeRecord; virtual; abstract;
    function AquireStatus(Var status: TVTPStatus): boolean; virtual; abstract;
  protected
    //internal fields for properties
    fName: string;
    fDummy: boolean;
    fReady: boolean;
  public
    //general properties
    property Name: string read fName;                   //short name or description of device
    property IsDummy: boolean read fDummy;            //true if NOT a REAL device
    property IsReady: boolean read fReady;            //is ready to provide data - if not, the device will not be accepting commands
    //                                                    must call  Initialize first, to make it ready
end;



//





//maybe useful constant

Const
  CPTCZeroRng: TPotentioRangeRecord = ( low: 0.0; high: 0.0);



//general helper funcitons

procedure InitPtcRecWithNAN(Var rec: TPotentioRec; Var Status: TPotentioStatus);

procedure InitFlowRecWithNAN(Var rec: TFlowRec);
procedure InitFlowStatusWithNAN( Var rec: TFlowData);

function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord): string; overload;
function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord; unitstr: string): string; overload;

function FlowDevToStr(d: TFlowDevices): string;
function FlowGasTypeToStr(g: TFlowGasType): string;

function VTPDeviceToStr( dev: TTempDevices ): string; overload;
function VTPDeviceToStr( dev: TValveDevices ): string; overload;
function VTPDeviceToStr( dev: TPressureSensDevices ): string; overload;
function VTPDeviceToStr( dev: TPressureRegDevices ): string; overload;
function VTPDeviceToStr( dev: TOtherDevices ): string; overload;


implementation

uses math, sysutils, dateutils;



constructor TPotentiostatObject.Create;

begin
  //fill default values - should be owerwritten in subclass!!
  fName := 'Abstract PTC';
  fDummy := true;
  fReady := false;
  fRngActCurr := CptcZeroRng;
  fRngActVolt := CptcZeroRng;
  fRngActCurrId := 0;
  fRngActVoltId := 0;
  fRngCurrCount := 0;
  fRngVoltCount := 0;
end;

destructor TPotentiostatObject.Destroy;
begin
end;

constructor TFlowControllerObject.Create;
begin
  //fill default values - should be owerwritten in subclass!!
  fName := 'Abstract FlowControl';
  fDummy := true;
  fReady := false;
end;


constructor TVTPControllerObject.Create;
begin
  fName := 'Abstract VTP Control';
  fDummy := true;
  fReady := false;
end;

procedure InitPtcRecWithNAN(Var rec: TPotentioRec; Var Status: TPotentioStatus);
begin
  with rec do
    begin
        timestamp := Now();
        U := NaN;
        I := NaN;
        P := NaN;
        Uref := NaN;
   end;
   with status do
    begin
       flagSet := [];
       setpoint := NaN;
       mode := CPotERR;
       rangeCurrent := CptcZeroRng;
       rangeVoltage := CptcZeroRng;
       isLoadConnected := false;
       debuglogmsg := '';
    end;
end;

procedure InitFlowRecWithNAN(Var rec: TFlowRec);
begin
  with rec do
    begin
        timestamp := Now();
        massflow := NaN;
        volflow := NaN;
        pressure := NaN;
        temp := NaN;
        setpoint := NaN;
        gastype := CGasUnknown;
        flagSet := [];
   end;
end;


procedure InitFlowStatusWithNAN( Var rec: TFlowData);
Var
  d: TFlowDevices;
begin
  for d := Low(TFlowDevices) to High(TFlowDevices) do
      begin
        InitFlowRecWithNAN(rec[d]);
        rec[d].timestamp := Now();
      end;
end;



function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord): string;
begin
  Result := '(' + FloatToStrF(rr.low, ffFixed,7,3) + '; ' + FloatToStrF(rr.high, ffFixed,7,3) + ')';
end;

function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord; unitstr: string): string; overload;
begin
  Result := '(' + FloatToStrF(rr.low, ffFixed,7,3) + ' '+ unitstr + '; ' + FloatToStrF(rr.high, ffFixed,7,3) + ' ' + unitstr + ')';
end;


function FlowDevToStr(d: TFlowDevices): string;
begin
  Result := 'unknown';
  case d of
    CFlowAnode: Result := 'MFC-A';
    CFlowN2: Result := 'MFC-N2';
    CFlowCathode: Result := 'MFC-C';
    CFlowRes: Result := 'MFC-Res';
  end;
end;


//   TFlowGasType = (CGasUnknown, CGasN2, CGasH2, CGasO2, CGasCO, CGasAir, CGasHe, CGasAr);

function FlowGasTypeToStr(g: TFlowGasType): string;
begin
  Result := '<unknown>';
  case g of
    CGasN2: Result := 'N2';
    CGasH2: Result := 'H2';
    CGasO2: Result := 'O2';
    CGasCO: Result := 'CO';
    CGasAir: Result := 'Air';
    CGasHe: Result := 'He';
    CGasAr: Result := 'Air';
  end;
end;



function VTPDeviceToStr( dev: TTempDevices ): string;
begin
  Result := 'Undef';
end;

function VTPDeviceToStr( dev: TValveDevices ): string;
begin
  Result := 'Undef';
end;

function VTPDeviceToStr( dev: TPressureSensDevices ): string;
begin
  case dev of
    CpAnode:  Result := 'S1';
    CpCathode:  Result := 'S2';
    CpBPControl:  Result := 'R1GET';
    CpPiston:  Result := 'S3';
    CpN2: Result := 'S4';
    CpReserve: Result := 'S5';
    else Result := 'Undef';
  end;
end;

function VTPDeviceToStr( dev: TPressureRegDevices ): string;
begin
  Result := 'Undef';
end;

function VTPDeviceToStr( dev: TOtherDevices ): string;
begin
  Result := 'Undef';
end;




end.


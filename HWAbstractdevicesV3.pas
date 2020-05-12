unit HWAbstractdevicesV3;

interface

uses
  Classes, Contnrs, MyThreadUtils, MyUtils, ConfigManager, MVvariant_DataObjects;//, MyStringHelpers;


Const
  //: string = '';
  idRegReadyStatus: string = 'devReadyStatus';
  idRegLastAcqTimeMS: string = 'devLastAcqTimeMS';
  idRegIfaceStatusAsInt: string = 'devIfaceStatusAsInt';
  idRegHWFuseMSG: string = 'devHWFuseMSG';
  idRegHWFuseActive: string = 'devHWFuseActive';
  idRegHWFuseLastTStamp: string = 'devHWFuseLastTStamp';
  idRegDebugLevel: string = 'devDebugLevel';


  IdPTC_U: string = 'IdPTC_U';
  IdPTC_I: string = 'IdPTC_I';
  IdPTC_P: string = 'IdPTC_P';
  IdPTC_Mode: string = 'IdPTC_Mode';
  IdPTC_SetPoint: string = 'IdPTC_SetPoint';
  IdPTC_OutputON: string = 'IdPTC_OutputON';


  IdObjHWMFC: string = 'ObjHWMFC';
  IdObjVirtMFC: string = 'ObjVirtMFC';

type

   TInterfaceStatus = ( CISError, CISReadyOK, CISTurnedOFFByUser,
                        CISTurnedOFFInternally, CISTryingConnect, CISDeviceNotResponding);

   TCommStatusFlags = ( CCSConnectionLost, CCSNotReady);
   TCommDevFlagSet = set of TCommStatusFlags;


  // ***
  //common data structure definition

   TPotentioMode = (CPotCC, CPotCV, CPotCR, CPotCP, CPotERR);

   //conjunction of all possible indicators etc. af all usable potentiostats - hope it can fit inside  255 elements, which is the max for use with a set
   TPotentioFlags = (CInternalError, CPtcHardFuseActivated, CPtcSoftLimitationActive,
                    CPtcOverRangeCurrent, CPtcOverRangeVoltage,
                    CPtcREVERSEDpolarityDetected, CDevOverHeat, CDevOverloadU, CDevOverloadI, CPTCRemoteSenseON,
                    CPtcHigherRngCurrentAvailbale, CPtcLowerRngCurrentAvailable,
                    CPtcHigherRngCurrentRecommended, CPtcLowerRngCurrentRecommended,
                    cPTCImporatntChangeDetected, cPtcConfigNotConsistent,
                    CPtcNotConfigured, CPtcNotResponding, CServerNotResponding, CNotAvailable, CNotReady);

   TPotentioFlagSet = set of TPotentioFlags;   //set

   TPTCProcessedData = record
       U: double;
       I: double;
       P: double;
       Inorm: single;
       Unorm: single;
       Pnorm: single;
    end;

   TRangeRecord = record
      low: double;
      high: double;
   end;

   TPotentioRangeRecord = TRangeRecord;

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
        rangeCurrent: TRangeRecord;
        rangeVoltage: TRangeRecord;
        rngV4Safe: TRangeRecord;
        rngV4hard: TRangeRecord;
        debuglogmsg: string;
   end;

   //FLWO DEVICES , STATUS AND CONTROL

   TFlowDevices = ( CFlowAnode, CFlowN2, CFlowCathode, CFlowRes);
   TFlowGasType = ( CGasUnknown, CGasN2, CGasH2, CGasO2, CGasCO, CGasAir, CGasHe, CGasAr);

   TFlowDevFlags = (CFlowDevNotResponding, CFlowSetpointDiffersFromFlow, CFlowDevDisabled);  //for single device - if not possible to aquire several times
   TFlowDevFlagSet = set of TFlowDevFlags;   //set

   TFlowRec = record
        timestamp: TDateTime;
        massflow:  single;          //WILL BE nan IF UNDEFINED
        volflow: single;
        pressure: single;
        temp: single;
        setpoint: single;
        gastype: TFlowGasType;
        flagSet: TFlowDevFlagSet;     //uf undefined state flag is aadded!!!! CHECK FOR IT
        end;

   TFlowData = array [TFlowDevices] of TFlowRec;



   //Valve, Temp, Pressure , STATUS AND CONTROL

  //principal devices on system - valve, temp, pressure, etc...

  TValveDevices = ( CVH2bH, CVN2bH, CVO2bO, CVAirbO, CVN2bO, CVN2safN2,
                    CVbHA , CVbOA, CVbNA, CVnSafN2A, CVresA, CVbOK, CVbHK, CVbNK, CVnsafN2K, CVnbNfl,
                    CVnAxH, CVAxO, CVnKxO, CVKxH, CVresFl, CVwtrbH, CVwtrbN, CVwtrbO, CVLED,
                    CPwrSwitch, CStateH1, CStateH2, CStateH3, CStateH4, CStateH5, CStateH6);

  TSensorDevices  = ( CTBubH2, CTBubN2, CTBubO2, CTCellBot, CTCellTop, CTOven1, CTOven2, CTPipeA, CTPipeB,
                     CpAnode, CpCathode, CpReserve, CpBPControl, CpPiston, CpN2,
                     CTH1set, CTH2set, CTH3set, CTH4Set, CTH5set, CTH6set,
                     CMswCtrl, CVref, CPSA, CPSN2, CPSC);                               //CpPiston, CpN2

  TRegDevices = ( CpRegBackpress,
                  CMFC1, CMFC2, CMFC3, CMFC4,
                  CMswStatus, CMswProgress );


   TValveState = (CStateUndefined, CStateOpen, CStateClosed);    //need the third state - NaN

   TValveRec  = record
        timestamp: TDateTime;
        state: TValveState;
        end;

   TOneDoubleRec = record
        timestamp: TDateTime;
        val: double;             //NaN if undefined; unit variable
        end;


  TValveData = array [TValveDevices] of TValveRec;
  TSensorData = array [TSensorDevices] of TOneDoubleRec;
  TRegData =  array [TRegDevices] of TOneDoubleRec;






// -
// definition of basic devices virtual objects
// -


TDeviceInterface = class (TObject)
  public
    constructor Create(devname: string; ifaceid: string; dummy: boolean);
    destructor Destroy; override;

  public
    function Initialize: boolean; virtual;  //assuming the device is available and connected, try to set initial condition
                                   //without initialization, the device should not become ready
                                   //this is wrapper only to asses simultaneous "Conenct",
                                   //inside calls fInitialize, which should be defined in descendant
    procedure Finalize; virtual;   //do tasks to  prepare for disconnecting , makes it not ready,
                           //this is wrapper that calls inside the "fFinalize" method

    procedure ResetHWFuse; virtual;  //general wrapper, inside calls "fRestHWFuse", which should be defined in descendant
    function LoadHWConfig: boolean; virtual; abstract;  //uses dataregistry to save config data into config file, based on interface name
       //this is simple wrapper defined HERE - calls fAfterLoadConfig to process loaded data
    function SaveHWConfig: boolean; virtual; abstract;  //uses registry to save config data into config file, based on interface name
        //this is simple wrapper defined HERE - calls fBeforeSaveConfig to process config data ands store into registry
        //only registry data marked as to be saved are saved
  public
    function GenFileInfoHeaderShort: string; virtual;   //should be overloaded
    function GenFileInfoHeaderFull: string; virtual;    //should be overloaded
  public //these must be defined in descendant
    function Connect: boolean; virtual; abstract;   //connect and initialize interface, without connection, no sense to do initialization
    procedure Disconnect; virtual; abstract;   //disconnect interface
    procedure Reconnect; virtual; abstract;
  public
    //Load config, save config
    function ForceUpdateHWConfig: boolean; virtual; abstract;  //e.g. after reload of configuration
  protected
    function fInitialize: boolean; virtual; abstract; //defined in descendant
    procedure fFinalize; virtual; abstract;  //defined in descendant
    procedure fResetHWFuse; virtual; abstract;  //defined in descendant
    function fAfterLoadHWConfig: boolean; virtual; abstract;
    function fBeforeSaveHWConfig: boolean; virtual; abstract;
  protected
    //
    function getIsReady: boolean; virtual;
    procedure setIsReady(b: boolean); virtual;
    function getLastAcqTimeMS: longint; virtual;
    procedure setLastAcqTimeMS(i: longint); virtual;
    function getDebug: boolean; virtual;
    procedure setDebug(b: boolean); virtual;
    function getHWFuse: boolean; virtual;
    procedure setHWFuse(b: boolean); virtual;
    function getFuseMsg: string; virtual; //report last FUSE error code and msg
    procedure setFuseMsg(s: string); virtual; //report last FUSE error code and msg
    function getIFaceStatus: TInterfaceStatus; virtual;
    procedure setIFaceStatus( ifs: TInterfaceStatus); virtual;
  protected
    fDevName: string;
    fIfaceId: string;
    fDummy: boolean;
  protected
            //KEY object to store all status and data and config, it is thread safe!!!!!
    fRegistry: TMyRegistryNodeObject;   //stores internally data and status - access methods are THREADSAFE!!!
             //designed to be extensively used also ion the descendat, to store all data and variables !!!
             //in has integrated feature of storing and loading data
  protected
    fReady: TRegistryItem;
    fLastAcqTimeMS: TRegistryItem;
    fFuseState: TRegistryItem;
    fIfaceStatus: TRegistryItem;
    fDebugLevel: TRegistryItem;
  public
    property DevName: string read fDevName;                   //short name or description of device
    property InterfaceId: string read fIfaceId;          //identification of interface used, version, etc...
    property IsDummy: boolean read fDummy;            //true if VIRTUAL = NOT a REAL device
    property IsReady: boolean read getIsReady;            //is ready to provide data - if not, the device will not be accepting commands
    property LastAcqTimeMS: longint read getLastAcqTimeMS;   //benchmark of acquire process
    property HWFuseActive: boolean read getHWFuse;
    property IfaceStatus: TInterfaceStatus read getIfaceStatus;
    property Debug: boolean read getDebug write setDebug;
   end;


//************************
//PTC

TPotentiostatObject = class (TDeviceInterface)
  //ANY single-time ERROR REPORTING should be best done through logmsg/logwarning/logerror functions
  //continous state errors or such may be indicated by status flags...
  public
    constructor Create(name: string; ifaceid: string; dummy: boolean);
    destructor Destroy; override;
  public
    //Basic Potenciostat control funcions - expected to be available on all devices of this type
    function AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean; virtual; abstract;
    //  returns electrical DATA and status
    //  this is the only fucntion that actualy aquires the status info (every time it is called)
    //  and after each call the internal status is updated and with it, also the corresponding flags if relevant!
    //  !!! range of voltage and current is checked (and flags set),
    //               but NO ACTION IS TAKEN to prevent overrange -> This should be done by HIGHER LEVEL control fucntion!!!!
    //function AquireStatus(Var Status: TPotentioStatus): boolean; virtual; abstract;  //quickly retrieves only status
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
    function getFlags(): TPotentioFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    //                                                            flags will contain indicator why the fuse has been triggerd
    function getFuseMsg: string; virtual; abstract; //report last (HARD) FUSE error code and msg
    function ResetFuse: boolean; virtual; abstract; //recover from fuse event
  protected
    //internal fields for properties
    fNameLong: string;
    fRngV4SWLimit: TRangeRecord;
    fRngV4HardLimit: TRangeRecord;
    fRngCurrRec: TRangeRecord;
    fRngVoltRec: TRangeRecord;
    fRngCurrId: byte;
    fRngVoltId: byte;
    fRngCurrCount: byte;
    fRngVoltCount: byte;
    //statistics
    fIfaceStatus: TInterfaceStatus;
  public
    //general properties
    property NameLongId: string read fNameLong;
    property IfaceStatus: TInterfaceStatus read fIfaceStatus;
    //statistics
  protected
    //RANGE reporting and control
    procedure SetRngCurrent(nr: byte); virtual; abstract;
    procedure SetRngVoltage(nr: byte); virtual; abstract;
    procedure SetRngV4SwLimit(rec: TRangeRecord); virtual; abstract;
    procedure SetRngV4HardLimit(rec: TRangeRecord); virtual; abstract;
  public
    property RngV4SwLimit: TRangeRecord read fRngV4SWLimit write SetRngV4SwLimit;
    property RngV4HardLimit: TRangeRecord read fRngV4HardLimit write SetRngV4HardLimit;
    property RngCurrentRec: TRangeRecord read fRngCurrRec;
    property RngVoltageRec: TRangeRecord read fRngVoltRec;
    //use this property to read or to set new reange
    property RngCurrentId: byte read fRngCurrId write SetRngCurrent;
    property RngVoltageId: byte read fRngVoltId write SetRngVoltage;
    property RngCurrentCount: byte read fRngCurrCount;  //number of ranges: indexed 0..(N-1)
    property RngVoltageCount: byte read fRngVoltCount;  //number of ranges: indexed 0..(N-1)
  public
    procedure GetRngArrayCurrent( Var ar:TPotentioRangeArray); virtual; abstract;
    procedure GetRngArrayVoltage( Var ar:TPotentioRangeArray); virtual; abstract;
  public
    function GenFileInfoHeaderBasic: string; virtual; abstract;
    function GenFileInfoHeaderIncludeDC: string; virtual; abstract;
end;


//************************
//FLOW


//conjunction of all possible indicators  - hope it can fit inside  255 elements, which is the max for use with a set
//TFlowControllerFlags = (CFlowNotConfigured);

TFlowControllerFlagSet = TCommDevFlagSet; //set of TFlowControllerFlags;


TFlowControllerObject = class (TDeviceInterface)
  //ANY single-time ERROR REPORTING should be best done through logmsg/logwarning/logerror functions
  //continous state errors or such may be indicated by status flags...
  public
    constructor Create(name: string; ifaceid: string; dummy: boolean);
    destructor Destroy; override;
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
    function Aquire(Var data: TFlowData; Var flags: TCommDevFlagSet): boolean; virtual; abstract;  //returns DATA and status
    function SetSetp(dev: TFlowDevices; val: double): boolean; virtual; abstract;   //set setpoint
    function SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean; virtual; abstract;
    function GetRange(dev: TFlowDevices): TRangeRecord; virtual; abstract;
  protected
    //internal fields for properties
    function getIfaceStatus: TInterfaceStatus; virtual; abstract;
  public
    property IfaceStatus: TInterfaceStatus read getIfaceStatus;
end;


  THwMFCAncestor = class (TMVUniversalObjectRef)
  public
    constructor Create(_nickname: string);
    destructor Destroy; override;
  public
    function SetFlow(sp: double): boolean;  virtual; abstract;      //in device units
    function SetGas(gasid: byte): boolean;  virtual; abstract;
    function GetFlow(): double;  virtual;  abstract;                   //in device units
    function GetGas(): byte;     virtual; abstract;
    function GetFullStatStr(): string;     virtual; abstract;
    function ConfigureFromStr(par: string): boolean; virtual; abstract;
  private
    Fnickname: string;
  public
    comment: string;
    unitstr: string;
    unitfactorsccm: double;
    rangemin: double;
    rangemax: double;
    h2coef: double;
    o2coef: double;
  public
    property nickname: string read Fnickname;
  end;



TVirtualMFCAncestor = class (TMVUniversalObjectRef)
  public
    constructor Create(_nickname: string);
    destructor Destroy; override;
  public
    function SetFlow(sp: double): boolean;  virtual; abstract;  //in actual units
    function SetFlowSccm(sp: double): boolean;  virtual; abstract;  //in sccm units
    function SetGas(gasid: byte): boolean;  virtual; abstract;
    function GetFlow(): double;  virtual; abstract;    //in actual units
    function GetFlowSccm(): double;  virtual; abstract;
    function GetGas(): byte;     virtual; abstract;
  public
    //procedure CreateGUI(var p: TPanel);  virtual;
  private
    Fnickname: string;
    function convflowtosccm(flowrelunit: double): double;
  public
    unitstr: string;
    unitfactorsccm: double;
    rangemin: double;
    rangemax: double;
  public
    property nickname: string read Fnickname;
  end;


THWFlowControllerList = class (TMyRegistryNodeObject)
  public
    constructor Create();
    destructor Destroy; override;
  public
    procedure AddMFC(name: string; mfco: THwMFCAncestor);
    function GetMFCbyName(name: string): THwMFCAncestor;
    procedure GetNickNamesList(Var sl: TStringList);
    //property IfaceStatus: TInterfaceStatus read getIfaceStatus;
end;



//************************
//VTP...Valve Temperature Pressure

//TVTPControllerFlags = (CVTPNotConfigured);
TVTPControllerFlagSet = TCommDevFlagSet;


TVTPControllerObject = class  (TDeviceInterface)     //VTP...Valve Temperature Pressure
  //ANY single-time ERROR REPORTING should be best done through logmsg/logwarning/logerror functions
  //continous state errors or such may be indicated by status flags...
  public
    constructor Create(name: string; ifaceid: string; dummy: boolean);
    destructor Destroy; override;
  public
    //setup,configuration of an actual device is defined for that device, because it is device-specific
    function Initialize: boolean; virtual; abstract;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
    procedure Finalize; virtual; abstract;   //do tasks to  prepare for disconnecting resp. disconnects device, makes it not ready
    //                                                            flags will contain indicator why the fuse has been triggerd
    procedure ResetConnection; virtual; abstract; //to try to repair connection lost problem
  public
    //basic control functions
    function Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean; virtual; abstract;
    function GetFlags(): TCommDevFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    function SetRegSetp(dev: TRegDevices; val: double): boolean; virtual; abstract;
    function SendCmdRaw(s: string): boolean; virtual; abstract;
    function GetRange(dev: TSensorDevices): TRangeRecord; overload; virtual; abstract;
    function GetRange(dev: TRegDevices): TRangeRecord; overload; virtual; abstract;
end;



//universal voltage monitor class (single or many channels)

TVoltageMonitor = class (TDeviceInterface)
  public
    constructor Create(name: string; ifaceid: string; dummy: boolean);
    destructor Destroy; override;
  public

    function ForceUpdateHWConfig: boolean; virtual; abstract;  //e.g. after reload of configuration
  public
    //Load config
    //save config
  protected
    function fInitialize: boolean; virtual; abstract; //defined in descendant
    procedure fFinalize; virtual; abstract;  //defined in descendant
    procedure fResetHWFuse; virtual; abstract;  //defined in descendant
    //Load config, save config



    //setup,configuration of an actual device is defined for that device, because it is device-specific
    function Initialize: boolean; virtual; abstract;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
    procedure Finalize; virtual; abstract;   //do tasks to  prepare for disconnecting resp. disconnects device, makes it not ready
    //                                                            flags will contain indicator why the fuse has been triggerd
    procedure ResetConnection; virtual; abstract; //to try to repair connection lost problem
  public
    //basic control functions
    function Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean; virtual; abstract;
    function GetFlags(): TCommDevFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    function SetRegSetp(dev: TRegDevices; val: double): boolean; virtual; abstract;
    function SendCmdRaw(s: string): boolean; virtual; abstract;
    function GetRange(dev: TSensorDevices): TRangeRecord; overload; virtual; abstract;
    function GetRange(dev: TRegDevices): TRangeRecord; overload; virtual; abstract;

    //function getChannel(i:longint): double;
    //function  ChannelCount(): longint;
public

end;






Var

  CommonDataRegistry: TMyRegistryNodeObject;





//maybe useful constant

Const
  CPTCZeroRng: TPotentioRangeRecord = ( low: 0.0; high: 0.0);



//general helper funcitons

procedure InitPtcRecWithNAN(Var rec: TPotentioRec; Var Status: TPotentioStatus);

procedure InitWithNAN(Var rec: TFlowRec); overload;
procedure InitWithNAN( Var rec: TFlowData); overload;

procedure InitWithNAN( Var rec: TValveData); overload;
procedure InitWithNAN( Var rec: TSensorData); overload;
procedure InitWithNAN( Var rec: TRegData); overload;

procedure InitWithNAN( Var rec: TValveRec); overload;
procedure InitWithNAN( Var rec: TOneDoubleRec); overload;


procedure InitWithNAN( Var rec: TRangeRecord); overload;

function PTCModeToStr(m: TPotentioMode): string;


function TRangeRecordToStr(Var rr: TRangeRecord): string; overload;
function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord): string; overload;
function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord; unitstr: string): string; overload;

function FlowDevToStr(d: TFlowDevices): string;
function FlowGasTypeToStr(g: TFlowGasType): string;


function VTPDeviceToStr( dev: TValveDevices ): string; overload;
function VTPDeviceToStr( dev: TSensorDevices ): string; overload;
function VTPDeviceToStr( dev: TRegDevices ): string; overload;

function VTPDevUnit(dev: TRegDevices): string; overload;
function VTPDevUnit(dev: TSensorDevices): string; overload;

function ValveStateToStr( val: TValveState ): string;


procedure FlagUpdate( isincluded: boolean; flag: TPotentioFlags; Var flagset: TPotentioFlagSet);  overload;
procedure FlagUpdate( isincluded: boolean; flag: TFlowDevFlags; Var flagset: TFlowDevFlagSet);  overload;

function FlagIsSet( flagset: TPotentioFlagSet; flag: TPotentioFlags): boolean;  overload;


implementation

uses math, sysutils, dateutils, MyStringHelpers;


Var
  iPTCModeToStr: TEnumStringRec;
  iFlowDevToStr: TEnumStringRec;
  iVTPDeviceToStr: TEnumStringRec;



//---------------------- Ancestor to all interfaces


constructor TDeviceInterface.Create(devname: string; ifaceid: string; dummy: boolean);
begin
  inherited Create();
  fDevName := devname;
  fIfaceId := ifaceid;
  fDummy := isdummy;
  //
  fRegistry := TMyRegistryNodeObject.Create( fDevName );
  //
  fReady := fRegistry.SetOrCreateItem( idRegReadyStatus, false);
  fLastAcqTimeMS := fRegistry.SetOrCreateItem( idRegLastAcqTimeMS,-1);
  fFuseState := fRegistry.SetOrCreateItem( idRegHWFuseActive, false);
  fIfaceStatus := fRegistry.SetOrCreateItem( idRegIfaceStatusAsInt, 0);
  fDebugLevel := fRegistry.SetOrCreateItem( idRegDebugLevel, false);
end;

destructor TDeviceInterface.Destroy;
begin
  fReady := nil;
  fLastAcqTimeMS := nil;
  fFuseState := nil;
  fIfaceStatus := nil;
  fDebugLevel := nil;
  MyDestroyAndNil( fRegistry );
  inherited;
end;


function TDeviceInterface.Initialize: boolean;
//assuming the device is available and connected, try to set initial condition
//without initialization, the device should not become ready
//this is wrapper only, in side calls fInitialize
begin
  Connect;
  Result := fInitialize;
end;

procedure TDeviceInterface.Finalize;    //do tasks to  prepare for disconnecting , makes it not ready, this is wrapper only
begin
  fFinalize;
  Disconnect;
end;



procedure TDeviceInterface.ResetHWFuse;   //genral wrapper, inside calls "fRestHWFuse", which should be defined in descendant
begin
  //TODO counter and timestamp
  fResetHWFuse;
end;





function TDeviceInterface.GenFileInfoHeaderShort: string;
begin
 Result := '[Interface-' + fDevName + ']';
end;

function TDeviceInterface.GenFileInfoHeaderFull: string;
begin
 Result := '[Interface-' + fDevName + ']';
end;

function TDeviceInterface.getIsReady: boolean;
begin
 Result := fReady.valBool;
end;

procedure TDeviceInterface.setIsReady(b: boolean);
begin
 fReady.valBool := b;
end;

function TDeviceInterface.getLastAcqTimeMS: longint;
begin
 Result := fLastAcqTimeMS.valInt;
end;

procedure TDeviceInterface.setLastAcqTimeMS(i: longint);
begin
 fLastAcqTimeMS.valInt := i;
end;

function TDeviceInterface.getHWFuse: boolean;
begin
 Result := fFuseState.valBool;
end;


procedure TDeviceInterface.setHWFuse(b: boolean);
begin
 fFuseState.valBool := b;
end;

function TDeviceInterface.getFuseMsg: string;  //report last FUSE error code and msg
begin
 Result := 'ERROR';
 if fRegistry = nil then exit;
 Result := fRegistry.valstr[ idRegHWFuseMSG ];
end;


procedure TDeviceInterface.setFuseMsg(s: string); //FUSE error code and msg
begin
 if fRegistry = nil then exit;
 fRegistry.valstr[ idRegHWFuseMSG ] := s;
end;

function TDeviceInterface.getIFaceStatus: TInterfaceStatus;
begin
 Result := TInterfaceStatus( fIfaceStatus.valInt );
end;


procedure TDeviceInterface.setIFaceStatus( ifs: TInterfaceStatus);
begin
 fIfaceStatus.valInt := longint(ifs);
end;

function TDeviceInterface.getDebug: boolean;
begin
 Result := fDebugLevel.valBool;
end;

procedure TDeviceInterface.setDebug(b: boolean);
begin
 fDebugLevel.valBool := b;
end;



//---------------------- POtenciostat

constructor TPotentiostatObject.Create(name: string; ifaceid: string; dummy: boolean);
begin
  inherited Create(name, ifaceid, dummy);
  //fill default values - should be owerwritten in subclass!!
  fRngCurrRec := CptcZeroRng;
  fRngVoltRec := CptcZeroRng;
  fRngV4SWLimit := CptcZeroRng;
  fRngV4HardLimit := CptcZeroRng;
  fRngCurrId := 0;
  fRngVoltId := 0;
  fRngCurrCount := 0;
  fRngVoltCount := 0;
  //
end;

destructor TPotentiostatObject.Destroy;
begin
  inherited;
end;


constructor TFlowControllerObject.Create(name: string; ifaceid: string; dummy: boolean);
begin
  inherited Create(name, ifaceid, dummy);
end;


destructor TFlowControllerObject.Destroy;
begin
  inherited;
end;


constructor TVTPControllerObject.Create(name: string; ifaceid: string; dummy: boolean);
begin
  inherited Create(name, ifaceid, dummy);
end;



destructor TVTPControllerObject.Destroy;
begin
  inherited;
end;


//**********************************



constructor TVoltageMonitor.Create(name: string; ifaceid: string; dummy: boolean);
begin
  inherited Create(name, ifaceid, dummy);
  //fill default values - should be owerwritten in subclass!!
end;

destructor TVoltageMonitor.Destroy;
begin
  inherited;
end;

//function TVoltageMonitor.ForceUpdateHWConfig: boolean; virtual; abstract;  //e.g. after reload of configuration

//function TVoltageMonitor.fInitialize: boolean; virtual; abstract; //defined in descendant
//procedure TVoltageMonitor.fFinalize; virtual; abstract;  //defined in descendant
//procedure TVoltageMonitor.fResetHWFuse; virtual; abstract;  //defined in descendant
//Load config, save config



//setup,configuration of an actual device is defined for that device, because it is device-specific
//function TVoltageMonitor.Initialize: boolean; virtual; abstract;   //assuming the device is available and connected, try to set initial condition
                                                   //without initialization, the device should not become ready
//procedure TVoltageMonitor.Finalize; virtual; abstract;   //do tasks to  prepare for disconnecting resp. disconnects device, makes it not ready
//                                                            flags will contain indicator why the fuse has been triggerd
//procedure TVoltageMonitor.ResetConnection; virtual; abstract; //to try to repair connection lost problem

//function TVoltageMonitor.Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean; virtual; abstract;
//function TVoltageMonitor.GetFlags(): TCommDevFlagSet; virtual; abstract;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
//function TVoltageMonitor.SetRegSetp(dev: TRegDevices; val: double): boolean; virtual; abstract;
//function TVoltageMonitor.SendCmdRaw(s: string): boolean; virtual; abstract;
//function TVoltageMonitor.GetRange(dev: TSensorDevices): TRangeRecord; overload; virtual; abstract;
//function TVoltageMonitor.GetRange(dev: TRegDevices): TRangeRecord; overload; virtual; abstract;

//function TVoltageMonitor.getChannel(i:longint): double;
//function  TVoltageMonitor.ChannelCount(): longint;









//**********************************



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
       rngV4Safe := CptcZeroRng;
       rngV4hard := CptcZeroRng;
       isLoadConnected := false;
       debuglogmsg := '';
    end;
end;

procedure InitWithNAN(Var rec: TFlowRec);
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


procedure InitWithNAN( Var rec: TFlowData);
Var
  d: TFlowDevices;
begin
  for d := Low(TFlowDevices) to High(TFlowDevices) do InitWithNAN(rec[d]);
end;


procedure InitWithNAN( Var rec: TValveData);
var
  d: TValveDevices;
begin
  for d:= Low(TValveDevices) to High(TValveDevices) do InitWithNAN(rec[d]);
end;

procedure InitWithNAN( Var rec: TSensorData); overload;
var
  d: TSensorDevices;
begin
  for d:= Low(TSensorDevices) to High(TSensorDevices) do InitWithNAN(rec[d]);
end;

procedure InitWithNAN( Var rec: TRegData); overload;
var
  d: TRegDevices;
begin
  for d:= Low(TRegDevices) to High(TRegDevices) do InitWithNAN(rec[d]);
end;




procedure InitWithNAN( Var rec: TValveRec);
begin
  rec.timestamp := Now;
  rec.state := CStateUndefined;
end;

procedure InitWithNAN( Var rec: TOneDoubleRec);
begin
  rec.timestamp := Now;
  rec.val := NAN;
end;


procedure InitWithNAN( Var rec: TRangeRecord); overload;
begin
  rec.low := NAN;
  rec.high := NAN;
end;



function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord): string;
begin
  Result := '(' + FloatToStrF(rr.low, ffFixed,4,2) + '; ' + FloatToStrF(rr.high, ffFixed,4,2) + ')';
end;

function PTCRangeRecordToStr(Var rr: TPotentioRangeRecord; unitstr: string): string; overload;
begin
  Result := '(' + FloatToStrF(rr.low, ffFixed,7,3) + ' '+ unitstr + '; ' + FloatToStrF(rr.high, ffFixed,7,3) + ' ' + unitstr + ')';
end;

function TRangeRecordToStr(Var rr: TRangeRecord): string;
begin
  Result := '(' + FloatToStrF(rr.low, ffFixed,7,3) + ' V; ' + FloatToStrF(rr.high, ffFixed,7,3) + ' V)';
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



function VTPDeviceToStr( dev: TValveDevices ): string;
begin
  case dev of
    CVH2bH: Result := 'V_H2bH';
    CVN2bH: Result := 'V_N2bH';
    CVO2bO: Result := 'V_O2bO';
    CVAirbO: Result := 'V_AirbO';
    CVN2bO: Result := 'V_N2bO';
    CVN2safN2: Result := 'V_N2safN2';
    CVbHA: Result := 'V_bHA';
    CVbOA: Result := 'V_bOA';
    CVbNA: Result := 'V_bNA';
    CVnSafN2A: Result := 'V_!SafN2A';
    CVresA: Result := 'V_resA';
    CVbOK: Result := 'V_bOK';
    CVbHK: Result := 'V_bHK';
    CVbNK: Result := 'V_bNK';
    CVnsafN2K: Result := 'V_!safN2K';
    CVnbNfl: Result := 'V_!bNfl';
    CVnAxH: Result := 'V!AxH';
    CVAxO: Result := 'V_AxO';
    CVnKxO: Result := 'V_!KxO';
    CVKxH: Result := 'V_KxH';
    CVresFl: Result := 'V_resFl';
    CVwtrbH: Result := 'V_wtrbH';
    CVwtrbN: Result := 'V_wtrbN';
    CVwtrbO: Result := 'V_wtrbO';
    CVLED: Result := 'V_LED';
    CPwrSwitch: Result := 'MainPower';
    CStateH1: Result := 'H1';
    CStateH2: Result := 'H2';
    CStateH3: Result := 'H3';
    CStateH4: Result := 'H4';
    CStateH5: Result := 'H5';
    CStateH6: Result := 'H6';

    else  Result := 'Undef';
  end;
end;


function VTPDeviceToStr( dev: TSensorDevices ): string;
begin
  case dev of
    CTBubH2: Result := 'T_bubH2';
    CTBubN2: Result := 'T_bubN2';
    CTBubO2: Result := 'T_bubO2';
    CTCellBot: Result := 'T_cellBott';
    CTCellTop: Result := 'T_cellTop';
    CTOven1: Result := 'T_oven1';
    CTOven2: Result := 'T_oven2';
    //
    CpAnode: Result := 'p_Anode';
    CpCathode: Result := 'p_Cathode';
    CpPiston: Result := 'p_Piston';
    CpN2: Result := 'p_N2';
   CpReserve: Result := 'p_Reserve';
    CpBPControl: Result := 'p_BP-readback';
    //
    CMswCtrl: Result := 'FCS-MSWCtrl';
    CVref: Result := 'Vref';
    CPSA: Result := 'CPSA';
    CPSN2: Result := 'CPSN2';
    CPSC: Result := 'CPSC';
    //
    CTH1set: Result := 'H1set';
    CTH2set: Result := 'H2set';
    CTH3set: Result := 'H3set';
    CTH4Set: Result := 'H4set';
    CTH5set: Result := 'H5set';
    CTH6set: Result := 'H6set';

    else  Result := 'Undef';
  end;
end;


function VTPDevUnit(dev: TSensorDevices): string;
begin
  case dev of
    CTBubH2..CTPipeB: Result := 'C';
    CpAnode..CpBPControl: Result := 'bar';
    else  Result := '';
  end;
end;

function VTPDeviceToStr( dev: TRegDevices ): string;
begin
  case dev of
    CpRegBackpress: Result := 'p_BP-SetPoint';
    CMFC1: Result := 'FCS-MFC1';
    CMFC2: Result := 'FCS-MFC2';
    CMFC3: Result := 'FCS-MFC3';
    CMFC4: Result := 'FCS-MFC4';
    CMswStatus: Result := 'FCS-MswStatus';
    CMswProgress: Result := 'FCS-MswProgress';
    else  Result := 'Undef';
  end;
end;

function VTPDevUnit(dev: TRegDevices): string;
begin
  case dev of
    CpRegBackpress: Result := 'bar';
    else  Result := '';
  end;
end;



function ValveStateToStr( val: TValveState ): string;
begin
  if val = CStateOpen then Result := '1' //'OPEN';
  else if val = CStateClosed then Result := '0' //'closed';
  else Result := 'X';   //'undefined';
end;




procedure FlagUpdate( isincluded: boolean; flag: TPotentioFlags; Var flagset: TPotentioFlagSet);  overload;
begin
  if isincluded then Include(flagset, flag)
  else  Exclude(flagset, flag);
end;

procedure FlagUpdate( isincluded: boolean; flag: TFlowDevFlags; Var flagset: TFlowDevFlagSet);  overload;
begin
  if isincluded then Include(flagset, flag)
  else  Exclude(flagset, flag);
end;



function FlagIsSet( flagset: TPotentioFlagSet; flag: TPotentioFlags): boolean;
begin
  Result := flag in flagset;
end;




procedure FillPTCPTCModeToStr;
  function xtoint(m: TPotentioMode): longint;
    begin
      Result := longint(m);
    end;
begin
  with iPTCModeToStr do
    begin
      Add(xtoint( CpotCC ), 'Feedback-Current');
      Add(xtoint( CpotCV ), 'Feedback-Voltage');
      Add(xtoint( CpotCR ), 'Feedback-Rezistance');
      Add(xtoint( CpotCP ), 'Feedback-Power');
      Add(xtoint( CpotERR ), 'Feedback-ERROR');
    end;
end;

function PTCModeToStr(m: TPotentioMode): string;
begin
  Result:= iPTCModeToStr.getbyid( longint(m) ) ;
end;





{ THwMFCAncestor }

constructor THwMFCAncestor.Create(_nickname: string);
begin
  inherited Create();
  Fnickname := _nickname;
end;

destructor THwMFCAncestor.Destroy;
begin
  inherited;
end;

{ TVirtualMFCAncestor }

function TVirtualMFCAncestor.convflowtosccm(flowrelunit: double): double;
begin
 try
   Result := flowrelunit * unitfactorsccm;
 finally
   Result := flowrelunit;
 end;
end;

constructor TVirtualMFCAncestor.Create(_nickname: string);
begin
  inherited Create();
  Fnickname := _nickname;
end;

destructor TVirtualMFCAncestor.Destroy;
begin
  inherited;
end;

{ THWFlowControllerList }

constructor THWFlowControllerList.Create;
begin
  inherited Create('HWFlowControllerObjects');
end;

destructor THWFlowControllerList.Destroy;
Var
  i: integer;
begin
  //shoudl be objects in list destoryed here?  YES they will be
  inherited;
end;

procedure THWFlowControllerList.AddMFC(name: string; mfco: THwMFCAncestor);
Var
  ri: TRegistryItem;
begin
  ri := CreateItemObj(name, mfco);
  //if ri=nil then logERROR  
end;


function THWFlowControllerList.GetMFCbyName(name: string): THwMFCAncestor;
begin

end;

procedure THWFlowControllerList.GetNickNamesList(var sl: TStringList);
Var
  cnt, i: longint;
  ri: TRegistryItem;
begin
  //will not clear list - only add
  if sl=nil then exit;
  Lock();
    for I := 0 to CountNoLock() - 1 do
      begin
        ri := getItemByIdNoLock(i);
        if ri<>nil then sl.Add( ri.Name );
      end;
  UnLock();
end;

initialization

  CommonDataRegistry := TMyRegistryNodeObject.Create('CommonDataRegistry');


  iPTCModeToStr := TEnumStringRec.Create;
  iFlowDevToStr:= TEnumStringRec.Create;
  iVTPDeviceToStr:= TEnumStringRec.Create;

  FillPTCPTCModeToStr;


finalization



  iPTCModeToStr.Destroy;
  iFlowDevToStr.Destroy;
  iVTPDeviceToStr.Destroy;

  MyDestroyAndNil( CommonDataRegistry);



end.


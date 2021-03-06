unit HWInterface;
{Last mod: 2015-09-02 MVac}
{
All the function prototypes are expected to provide basic high level access to the functions
of the hw WITHOUT USING ACTUALLY ANY HARDWARE SPECIFIC FUNCTIONS - these are provided in other units
through ABSTRACT DEFINED CLASSES
*** For example TPTCInterface for communication with potenciosrtat uses only reference to TPotenciostatObject
This reference is configured through user configuration in program in the FormPTCHardware
---------------------
From the gerneral point of devices, there is to be expected these cateories:
- Potenciostat/electronic load control
- Gas flow control
- Temperature/heaters monitoring and control
}

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$MODE Delphi}
{$ENDIF}


interface

//***************************************
//!!!!!!!!!!!!!!!!!!!!!!!!!
//******  HOwto use: any measurement and reading  call to MainXXXInterface  (e.g. MainPTCInterface)
//for this include this unit in main app and make sure to create and initialize each XXXInterface object
//***************************************


uses
{$IFDEF Lazarus}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  Logger, FormHWAccessControlUnit, FormProjectControl, FormGlobalConfig,
  HWAbstractDevicesV3,
  DataStorage, ConfigManager,
  PTCInterface_KolPTC_TCPIP_new, FlowInterface_Alicat_new3;
  //HWInterfaceControlObjects;


Const
  CHWErrorCOuntThreshold = 20;
  CHWTryReconnectDelayMS = 120000;                   //tobjectlist

//
//hw devices stats structures - see "hwabstractdevices"
//  TPotentioRec, TPotentioStatus, ...

type
    PBool = ^boolean;



type

  TPTCInterfaceObject = class  (TObject)
  //PTC intermediate object to be used inmain interface
  //aquire places data in the public variables, from there the main interface will redistribute them...
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure PTCAssign( dev: TPotentiostatObject );
    function Init(): boolean;
  public
    function PTCIsReady(): boolean;               //if ready then available to aquire
    function PTCAquire(): boolean;
    function PTCSetCC(val: double): boolean;    //normally expecting value in "A.cm-2" + will do processing according to Invertcurrent!!
    function PTCSetCV(val: double): boolean;    //will do processing according to InvertVoltage!!
    function PTCUpdatesetpoint(val: double): boolean;  //wrapper for the two above functions  with processed values  (value in V or A.cm-2)
    function PTCSetCCwonorm(val: double): boolean;  // this  uses invercurrent, but no normalization - the value in "A"
    function PTCSetCCraw(val: double): boolean;    //does do anything to the parameter  value in "A"
    function PTCSetCVraw(val: double): boolean;    //does do anything to the parameter  value in "V"
    function PTCTurnON: boolean;
    function PTCTurnOFF: boolean;
    function PTCGetRelayStatus(): boolean;    
    function PTCSetV4SafetyRange(rng: TRangeRecord): boolean;
    function PTCSetV4HardRange(rng: TRangeRecord): boolean;
    //
   // function GenerateFileInfoHeaderPTC: string;
    function GenerateFileInfoHeaderPTCBasic: string;
    function GenerateFileInfoHeaderPTCInclDC: string;
  private
    //temporary - maybe remove it in future
    function PTCUpdatesetpointraw(val: double): boolean;  //uses the PTCmode used last time, no adjustments to the value
  public
    //uses these public properties to read last aquireddata - available are processed and raw U, I  (for example effect of invert current option)
    PTCRawData: TPotentioRec;
    PTCStatus: TPotentioStatus;
    PTCProcessedData: TPTCProcessedData;
  private
    //!!! which module for potentio is used, is selected through function  PotentioAssign from hardware control form
    MyPotentio: TPotentiostatObject;
    fPTClastmode: TPotentioMode;
    fPTCLastRelayStatus: boolean;
    fRootToken: THWAccessToken;
    fHWerrorCount: longint;
    fHWErrorLastTime: TDateTime;
    fLastAquireTimeMS: longint;
  private
    //postprocessing of measured U,I variables - using configuration in TProjectControl
    function processI(i: double): double;
    function processU(u: double): double;
    function normI(i: double): double;
    function invprocessI(i: double): double;
    function invprocessU(u: double): double;
    function invnormI(i: double): double;
    function normU(u: double): double;
    function invnormU(u: double): double;
    //undervolt protect
    //procedure underVprotect1;
    //procedure underVprotect2;
  private
    function CheckForNil( name: string): boolean;  //check if reference is not nil and log msg
  public
    property ControlObj: TPotentiostatObject read MyPotentio;
    property LastAquireTimeMS: longint read fLastAquireTimeMS;
  end;



  TFlowCtrlInterfaceObject = class  (TObject)
  //intermediate class to be used by main interface
  //aquire places data in the public variables, from there the main interface will redistribute them...
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure DeviceAssign( dev: TFlowControllerObject );
  public
    function DevIsReady: boolean;               //if ready then available to aquire
    function Aquire(): boolean;    //reads data and status, it is stoerd into internal buffer - read it from FlowDataLatest
                                   //it is ok to call aquire often - the flow modules run in different thread and only provides cached data anyway
                                   //aquire does not check for valid token access - because aquire does not modify anything and practically does not block any access
    function SetFlow(dev: TFlowDevices; sp: double): boolean; //value in sccm; only if token t is currently owning control will be the change done
  public
    FlowData: TFlowData;
    FlowFlags: TCommDevFlagSet;
    function FlowGetLatestDataSingle( flowdev: TFlowDevices): TFlowRec;
    function FlowGetLatestDataAll(): TFlowData;
    function FlowGetDeviceRange(flowdev: TFlowDevices): TRangeRecord;
    function FlowCheckDataIsValid(flowdev: TFlowDevices; Var FD: TFlowData): boolean;
    procedure CheckReconnect;
    //
    function GenerateFileInfoHeaderFlow: string;

  private
    //!!! which module is selected through function  DeviceAssign from hardware control form
    fMyDev: TFlowControllerObject;
    fHWerrorCount: longint;
    fHWErrorLastTime: TDateTime;
    fHWLastTimeOnline: TDateTime;
    fRootToken: THWAccessToken;
    //
    fLastAquireTimeMS: longint;
  private
  //internal helpers
    function  CheckForNil( sender: string): boolean;  //check if reference is not nil - if yes then log msg - name = sender msg
  public
    property ControlObj: TFlowControllerObject read fMyDev;
    property LastAquireTimeMS: longint read fLastAquireTimeMS;
  end;



 TVTPInterfaceObject = class  (TObject)
  //intermediate class to be used by main interface
  //aquire places data in the public variables, from there the main interface will redistribute them...
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure DeviceAssign( dev: TVTPControllerObject );
  public
    function DevIsReady: boolean;               //if ready then available to aquire
    function Aquire(): boolean;    //reads data and status, it is stoerd into internal buffer - read it from FlowDataLatest
                                   //it is ok to call aquire often - the flow modules run in different thread and only provides cached data anyway
                                   //aquire does not check for valid token access - because aquire does not modify anything and practically does not block any access
    function SetDevice(dev: TRegDevices; sp: double): boolean; //
    function SendCmdRaw(s: string): boolean;
    function GenerateFileInfoHeaderVTP: string;

    //function SetDeviceById(devid: string; sp: double): boolean; //device is found according to the id-str  value is converted according to need
  public
    datav: TValveData;
    dataS: TSensorData;
    dataR: TRegData;
    CommFlags:  TCommDevFlagSet;
  private
    //!!! which module is selected through function  DeviceAssign from hardware control form
    fMyDev: TVTPControllerObject;
    fHWerrorCount: longint;
    fHWErrorLastTime: TDateTime;
    fRootToken: THWAccessToken;
    fLastAquireTimeMS: longint;
  private
  //internal helpers
    function  CheckForNil( sender: string): boolean;  //check if reference is not nil - if yes then log msg - name = sender msg
  public
    property ControlObj: TVTPControllerObject read fMyDev;
    property LastAquireTimeMS: longint read fLastAquireTimeMS;
  end;




  TMainInterfaceObject = class (TObject)
  //root Interface - agregates all other interfaces and takes care of aquiring data
  //to access the data use the praticular interface variables
  //this object also takes care of monitoring/processing data and logging them into project datalog
  //for now - I cannot decide what is better( everything inside one object or separated - but I chosed to do one large MEGA object containing links
  //and which has only ONE public AQUIRE which makes it easier to synchro
  //to all other interfaces
  //!!! PTC aquires directly in the MAIN thread - all other interfaces should have its own threads
  //       or be non blocking !!! otherwise the responsivnes of program would be terrible
  //
  //HW Access - limiting simultaneous use- to be able to control PTC and other HW, one has to obtain and provide corrent �token�, which has locked control of HW access
  //aquire and setting setpoint should check validity of token lock each time

  public
    constructor Create;
    destructor Destroy; override;
  public
    function AquireAll(t: THWAccessToken): boolean;  //MOST INPORTANT FUCNTION - You want to use this one in most cases
                                         //After aquire - access the data in the DataAll property
    function PtcIsReady: boolean;        //if ready then available to aquire and control
    function FlowDevIsReady: boolean;
    function GenerateFileInfoHeader:string;
  public
    //general functions
    procedure PtcDevAssign( dev: TPotentiostatObject );
    procedure FlowDeviceAssign( dev: TFlowControllerObject );
    procedure VTPDeviceAssign( dev: TVTPControllerObject );
    function InitAll: boolean;  //if not initialized it will try to - for every iface
    function PTCinit: boolean;   //force PTCinit
    procedure HandleBroadcastSignals(sig: TMySignal);
  public
    //ptc control
    function PTCSetCC(val: double; t: THWAccessToken): boolean;    //normally expecting value in "A.cm-2" + will do processing according to Invertcurrent!!
    function PTCSetCV(val: double; t: THWAccessToken): boolean;    //will do processing according to InvertVoltage!!
    function PTCUpdateSetpoint(val: double; t: THWAccessToken): boolean;  //wrapper for the two above functions  with processed values  (value in V or A.cm-2)
    function PTCSetCCwonorm(val: double; t: THWAccessToken): boolean;  // this  uses invercurrent, but no normalization - the value in "A"
    function PTCSetCCraw(val: double; t: THWAccessToken): boolean;    //does do anything to the parameter  value in "A"
    function PTCSetCVraw(val: double; t: THWAccessToken): boolean;    //does do anything to the parameter  value in "V"
    function PTCUpdateSetpointRaw(val: double; t: THWAccessToken): boolean;  //uses the PTCmode used last time, no adjustments to the value
    function PTCTurnON(t: THWAccessToken): boolean;
    function PTCTurnOFF(t: THWAccessToken): boolean;
    function PTCGetRelayStatus(t: THWAccessToken): boolean;
  public
    //flow control
    function FlowInit: boolean;    
    function FlowFinalize(force: boolean = false): boolean;  //if force is set true, interface will not try to reinitialize automatically
    function FlowSetSP(dev: TFlowDevices; sp: double; t: THWAccessToken): boolean; //value in sccm; only if token t is currently owning control will be the change done
  public
    //VTP control
    function VTPsetDevice(dev: TRegDevices; sp: double; t: THWAccessToken): boolean; overload;
    function VTPsendCmdRaw(s: string; t: THWAccessToken): boolean;
    //function VTPsetDevice(dev: TValveDevices; state: TValveState; t: THWAccessToken): boolean; overload;
  private
    //devices!!! module is selected through function  DeviceAssign from hardware control form
    fPTCiface: TPTCInterfaceObject;
    fFLOWiface: TFlowCtrlInterfaceObject;
    fVTPiface: TVTPInterfaceObject;
  private
    fMonitorRec: TMonitorRec;    //contains all relevant data - last aquired - from all devices - aquire will place it there
    fMinLogInt: longint;
    fLastLogTime: TDateTime;
    fForceLog: boolean;
    fPTCwasReady: boolean;
    fFlowwasReady: boolean;
    fVTPwasReady: boolean;
    fPTCReadylaststate: boolean;
    fLastAquireTime: TDateTime;
    fLastAquireTotalDurMS: longint;
    fFlowForceOffline: boolean;
  private
    fEnableSendMFC: boolean;
    fAcquireLock: boolean;   
  private
    //helpers
    function CheckToken(t: THWAccessToken): boolean;
    procedure LogData;
    procedure setMinLogInterval( tms: longint); //log into file/memory will happen only oftar some interval - except in scepcial cases e.g. some quick change, or fuse triggered
  public
    //PROPERTIES
    //use these public properties to read last aquireddata - available are processed and raw U, I  (for example effect of invert current option)
    property DataRec: TMonitorRec read fMonitorRec;  //latest data
    property PTCwasReady: boolean read fPTCwasReady;
    property FlowwasReady: boolean read fFlowwasReady;
    property VTPwasReady: boolean read fVTPwasReady;
    property MinLogInterval: longint read fMinLogInt write setMinLogInterval;
    property PTCControl: TPTCInterfaceObject read fPTCiface;
    property FlowControl: TFlowCtrlInterfaceObject read fFLOWiface;
    property VTPControl: TVTPInterfaceObject read fVTPiface;
    property LastAquireTime: TDateTime read fLastAquireTime;
    property LastAquireDuration: longint read fLastAquireTotalDurMS;
    property FlowForceOffline: boolean read fFlowForceOffline;
    property EnableSendMFC: boolean read fEnableSendMFC write fEnableSendMFC;
  public

    fMSWCtrlStatus: Integer;
    fFCSInterlok: boolean;

  end;




Const
  CFlowIfaceVer = '20160207';

  CAnFlCoef = 7.0; //sccm.A-1
  CCaFlCoef = 3.5; //sccm.A-1



Var
  //!!!!  measurement interface objects - since 2015 use for all data aquisition  !!!
  //!!!!!!!!!!! must be initialized (is done in MainInterfaceInitInit)

  MainHWInterface: TMainInterfaceObject;
  CommonDataRegistry: TMyRegistryNodeObject;


//!!!!!!!!!
//Initialization procedures

procedure HWInterfaceInit;
procedure HWInterfaceDestroy;




//helper functions

function PTCmodeToStr(m: TPotentioMode): string;
function PTCrelayToStr(b: boolean): string;

function CalculateFlowAnode( Iraw: double ): double;   //Iraw=current in A, result in sccm - calculates flow using projects settings for flow tracking
function CalculateFlowCathode( Iraw: double ): double;   //Iraw=current in A, result in sccm - calculates flow using projects settings for flow tracking





implementation

uses DateUtils, Windows, MyUtils, Math;


//
//
//*******************
//
//  PTC Interface Object
//
//
// **************




constructor TPTCInterfaceObject.Create;
begin
  inherited;
  MyPotentio := nil;
  fRootToken := THWAccessToken.Create;
  if fRootToken<>nil then fRootToken.tokenname := 'PTCIfaceObject-FlowTracking';
  if FormHWAccessControl<>nil then FormHWAccessControl.RegisterRootToken( fRootToken );
  fHWerrorCount := 0;
  logmsg('TPTCInterfaceObject.Create; done.');
end;

destructor TPTCInterfaceObject.Destroy;
begin
  fRootToken.Destroy;
  inherited;
end;

procedure TPTCInterfaceObject.PTCAssign( dev: TPotentiostatObject );
begin
  MyPotentio := dev;
  if dev<>nil then GlobalConfig.BroadCastSignal( CSigProjectConfUpdated );  //in order to update new PTC with V4 limits information
end;

function TPTCInterfaceObject.Init: boolean;
Var
  r1, r2: boolean;
begin
  //try register root token again - bacause before
  if FormHWAccessControl=nil then logerror('TPTCInterfaceObject.Init: FormHWAccessControl=nil ROOT token not registered');
  if FormHWAccessControl<>nil then
    begin
      FormHWAccessControl.RegisterRootToken( fRootToken );
      if FormHWAccessControl.IsTokenInRoot( fRootToken) then logmsg ('TPTCInterfaceObject.Init: RootToken registered OK')
      else logerror ('TPTCInterfaceObject.Init: RootToken NOT registered');
    end;

  //PTC
  if CheckForNil('Init') then exit;
  if not MyPotentio.IsReady then
    begin
      logmsg( 'PTCInterfaceObject: Init: PTC is not ready, will do do init' );
      r2 := MyPotentio.Initialize;
    end;
  r1 := MyPotentio.IsReady;
  fPTCLastMode := CPotERR;
  fPTCLastRelayStatus := false;
  fHWerrorCount := 0;
  if not r1 then  logmsg( 'PTCInterfaceObject: Init: init failed' );
  Result := r1
end;


function TPTCInterfaceObject.PTCIsReady: boolean;
begin
  Result := false;
  if CheckForNil('PTCIsReady') then exit;
  Result := MyPotentio.IsReady;
end;


function TPTCInterfaceObject.PTCAquire(): boolean;
Var
  res, b1, b2, wasfuseON: boolean;
  af, cf, val: double;
  s: string;
  kolPTC: TKolPTCObject;  //for ref
begin
  Result := false;
  fLastAquireTimeMS := -1;
  if CheckForNil('PTCAquire') then exit;
  //check for request to restart server and do it!!1
  if MyPotentio is TKolPTCObject then
            begin
              kolPTC := TKolPTCObject(Mypotentio);
              if kolPTC.RequestRestartServer and kolPTC.RestartServerEnabled then
                begin
                  logwarning('GOING TO RESTART PTC SERVER');
                  kolPTC.RestartPTCServer;
                end;
            end;
  //


  if not PTCIsReady then exit;
  //aquire new data
  res := MyPotentio.AquireDataStatus(PTCrawData, PTCStatus);
  if not res then
    begin
     logmsg( 'PTCInterfaceObject: PTCAquire: error during reading potentio' );
    end;
  //process  aquired values so it can be accesed from public varibles
  if not res then
    begin
      //no we should not assume that just because aquire failed last state is not valid...
      //fPTCLastMode := CPotERR;
      //fPTCLastRelayStatus := false;
    end;
  if res then
    begin
      with PTCProcessedData do
        begin
          U := processU( PTCRawData.U );
          I := processI( PTCRawData.I );
          P := U * I;
          Inorm := normI( I );
          Unorm := normU( U );
          Pnorm := Unorm * Inorm;
        end;
    end;
  //FLOW tracking in ConstU mode - on every aquire update setpoint ???????
  if res and (PTCStatus.mode = CPotCV) and (PTCStatus.isLoadConnected ) and  ProjectControl.ProjFlowTracking then
    begin
     // Update Flow VALUES - based on actual current
     val := PTCRawData.I;
     try
       af := CalculateFlowAnode( val );
       cf := CalculateFlowCathode( val );
       MainHWInterface.FlowSetSP(CFlowAnode, af, fRootToken);
       MainHWInterface.FlowSetSP(CFlowCathode, cf, fRootToken);
     except
       on E: Exception do logError('TPTCInterfaceObject.PTCAquire() EXCEPTION when calculate flow: ' + E.message);
     end;
     logmsg('iii FlowTracking ON && constU mode -> (I='+ FloatToStr( val ) +'A)...setting flow anode/cathode (sccm): ' + FloatToStr(af) + ' / ' + FloatToStr(cf) );
    end;

  //check for conditions - if limits are reached - take appropriate measures
  //TODO:!!!!!
  //reset HW error count, if no error in last hour
  if (fHWerrorCount>0) and (TimeDeltaNowMS(fHWErrorLastTime) > 300000) then  //5min
    begin
      LogProjectEvent('ii TPTCInterfaceObject.PTCAquire: Since last HW error was long ago, reseting HW error counter');
      fHWerrorCount := 0;
    end;

  //check for FUSE activasted, try resuscitate
  wasfuseON := false;
  if CPtcHardFuseActivated in PTCStatus.flagSet then   //FUSE
    begin
      s := 'EEEEE PTCAquire: PTC FUSE ACTIVATION DETECTED!!!!  ErrorMsg='+  MyPotentio.GetFuseMsg   + ' Total count recently: ' + IntToStr( fHWerrorCount );
      logError( s );
      Inc( fHWerrorCount );
      wasfuseON := true;
      fHWErrorLastTime := Now();
      //if error is not very high, try to reset error and hope, it will not happen again
      if fHWerrorCount < CHWErrorCountThreshold then
        begin
          //resuscitate from FUSe activation = keep setpoint and turn ON
          LogProjectEvent('ii TPTCInterfaceObject.PTCAquire: Attempting Ptc.ResetFUSE');
          b1 := MyPotentio.ResetFuse;
          if b1 then LogProjectEvent('           PTC reset FUSE - was succesfull!!')
          else LogProjectEvent('EE TPTCInterfaceObject.PTCAquire: Attempt at reset FUSE FAILED');
        end
      else
        begin
          LogProjectEvent('EE TPTCInterfaceObject.PTCAquire: TOO MANY HW errors RECENTLY - GIVING UP - will not recover again and disconnect PTC!!!!  count: ' + IntToStr( fHWerrorCount ) );
          MyPotentio.Finalize;
        end;
    end;


  //check for changes in output relay and non-standard situation to set flag for forced log
  //cahnge in output relay
  Exclude(PTCStatus.flagset, cPTCImporatntChangeDetected );
  if res and (fPTCLastRelayStatus<>PTCStatus.isLoadConnected) then
    begin
      Include(PTCStatus.flagset, cPTCImporatntChangeDetected );
      LogProjectEvent('IIII OUTPUT RELAY status changed!!! (now=' + BoolToStr(PTCStatus.isLoadConnected) + ')' );
    end;
  //change in mode
  if res and (fPTCLastMode <> PTCStatus.mode) then
    begin
      Include(PTCStatus.flagset, cPTCImporatntChangeDetected );
      LogProjectEvent('IIII PTC MODE changed!!! (now=' + PTCModeToStr( PTCStatus.mode ) + ')' );
    end;
  //
  //store state
  if res and (not wasfuseON) then
    begin
      fPTCLastMode := PTCStatus.mode;
      fPTCLastRelayStatus := PTCStatus.isLoadConnected;
    end;
  //
  
  //call after aquire(status) - check and synchronise PTC configuration to expected state if detectede difference (flag from aquire)
  if FlagIsSet(PTCStatus.flagSet, cPtcConfigNotConsistent) then   //FUSE
    begin
      LogProjectEvent('IIII PTC NON-consistent CONFIG detected - resending!! ');
      res := res and MyPotentio.ForceUpdateHWConfig;
    end;
  //
  //time statistic
  fLastAquireTimeMS := MyPotentio.LastAcqTimeMS;
  //
  Result := res;
end;



function TPTCInterfaceObject.PTCSetCC(val: double): boolean;
begin
  Result := PTCSetCCraw( invprocessI( invnormI(val) ) );
end;


function TPTCInterfaceObject.PTCSetCV( val: double): boolean;
begin
  Result := PTCSetCVraw( invprocessU( invnormU( val) ) );
end;


function TPTCInterfaceObject.PTCUpdateSetpoint( val: double): boolean;
begin
  Result := false;
  if CheckForNil('PTCUpdateSetpoint') then exit;
  case fPTCLastMode of
    CPotCC:
            begin
              Result := PTCSetCC( val )
            end;
    CPotCV:
            begin
              Result := PTCSetCV( val )
            end;
    CPotERR:
            begin
              Result := false;
              logerror( 'PTCInterfaceObject: CpoERR state - undefined State - cannot update setpoint' );
            end;
    else
       begin
         logerror( 'PTCInterfaceObject: UpdateSetpoint: other mode not implemented' );
       end;
  end;
end;


function TPTCInterfaceObject.PTCSetCCwonorm( val: double): boolean;
begin
  Result := PTCSetCCraw( invprocessI( val ) );
end;


function TPTCInterfaceObject.PTCSetCCraw( val: double): boolean;
Var
  af, cf: double;
  ftrack: boolean;
  aflowrng, cflowrng: TRangeRecord;
begin
  Result := false;
  if CheckForNil('PTCSetCCraw') then exit;
  fPTCLastMode := CpotCC;
  Result := MyPotentio.SetCC(val);
  //if enabled GlobalConfig.OnZeroCurrentTurnPTCOff turn LAOD OFF

  if (GlobalConfig.OnZeroCurrentTurnPTCOff)  then       //added 2016.07 to address issue with non zero current
    begin
      if CompareEpsilonAequalB(val, 0, 0.000001) then
        begin
          logmsg('PTCSetCCraw: setp=0 and enabled turnoffrelay -> off');
          MyPotentio.TurnLoadOFF;
        end
      else
        begin
          if fPTCLastRelayStatus=false then
            begin
              logmsg('PTCSetCCraw: setp<>0 and relay was off -> TURN ON');
              MyPotentio.TurnLoadON;
            end;
        end;
    end;

  // Update Flow VALUES - if flow tracking
  af := CalculateFlowAnode( val );
  cf := CalculateFlowCathode( val );
  ftrack := ProjectControl.ProjFlowTracking;
  //get actual range limit

  aflowrng := MainHWInterface.FlowControl.FlowGetDeviceRange( CFlowAnode );
  cflowrng := MainHWInterface.FlowControl.FlowGetDeviceRange( CFlowCathode );
  if (not IsNan(aflowrng.low)) and (not Isnan(aflowrng.high)) then MakeSureIsInRange(af, aflowrng.low, aflowrng.high );
  if (not IsNan(cflowrng.low)) and (not Isnan(cflowrng.high)) then MakeSureIsInRange(cf, cflowrng.low, cflowrng.high );

  if ftrack then
    begin
      LogProjectEvent('iii FlowTracking ON -> we have I='+ FloatToStr( val ) +' A -> setting flow anode/cathode (sccm): ' + FloatToStr(af) + ' / ' + FloatToStr(cf) );
      MainHWInterface.FlowSetSP(CFlowAnode, af, fRootToken);
      MainHWInterface.FlowSetSP(CFlowCathode, cf, fRootToken);
    end;
end;


function TPTCInterfaceObject.PTCSetCVraw( val: double): boolean;
begin
  Result := false;
  if CheckForNil('PTCSetCVraw') then exit;
  fPTClastmode := CpotCV;
  Result := MyPotentio.SetCV(val);
end;


function TPTCInterfaceObject.PTCUpdatesetpointraw( val: double): boolean;
//raw - directly passes value to potencio object
begin
  Result := false;
  if CheckForNil('PTCUpdateSetpointRaw') then exit;
  if fPTClastmode = CPotCC then Result := MyPotentio.SetCC(val)
  else if fPTClastmode = CPotCV  then Result := MyPotentio.SetCV(val)
  else
    begin
      logerror( 'PTCInterfaceObject: UpdateSetpointRaw: other mode not implemented' );
    end;
end;


function TPTCInterfaceObject.PTCTurnON: boolean;
begin
  Result := false;
  if CheckForNil('PTCTurnON') then exit;
  Result := MyPotentio.TurnLoadON;
end;


function TPTCInterfaceObject.PTCTurnOFF: boolean;
begin
  Result := false;
  if CheckForNil('PTCTurnOFF') then exit;
  Result := MyPotentio.TurnLoadOFF;
end;


function TPTCInterfaceObject.PTCSetV4SafetyRange(rng: TRangeRecord): boolean;
begin
  Result := false;
  if CheckForNil('SetV4SafetyRange') then exit;
  MyPotentio.RngV4SwLimit := rng;
  Result := true;
end;


function TPTCInterfaceObject.PTCSetV4HardRange(rng: TRangeRecord): boolean;
begin
  Result := false;
  if CheckForNil('SetV4HardRange') then exit;
  MyPotentio.RngV4HardLimit := rng;
  Result := true;
end;


function TPTCInterfaceObject.PTCGetRelayStatus(): boolean;
Var
  st: TPotentioStatus;
  rec: TPotentioRec;
begin
  Result := false;
  if CheckForNil('PTCGetRelayStatus') then exit;
  if MyPotentio.AquireDataStatus(rec, st) then Result := st.isLoadConnected;
end;


function  TPTCInterfaceObject.CheckForNil( name: string): boolean;
begin
  if MyPotentio=Nil then
    begin
      logmsg( 'ee  TPTCInterfaceObject: in' + name + ': MyPotentio=Nil');
      Result := true;
      exit;
    end;
  Result := false;
end;


function TPTCInterfaceObject.processI(i: double): double;
//calculate invertcurrent
begin
  if ProjectControl.ProjInvertCurrent then Result := -i
  else
    Result := i;
end;

function TPTCInterfaceObject.invprocessI(i: double): double;
begin
    Result := processI(i);
end;


function TPTCInterfaceObject.processU(u: double): double;
//calculate invertvotlage
begin
  if ProjectControl.ProjInvertVoltage then Result := -u
  else
    Result := u;
end;

function TPTCInterfaceObject.invprocessU(u: double): double;
begin
    Result := processU(u);
end;

function TPTCInterfaceObject.normI(i: double): double;
//calculate normalized current to area
Var a: double;
begin
  //assuming now are awuired valid data
  Result := i;
  a := ProjectControl.ProjCellArea;
  try
      if a>0 then Result := i / a;
  except
      on E: Exception do
        begin
         logmsg( 'PTCInterfaceObject: normI: error normalize divide - ' + E.message);
         Result := i;
        end;
  end;
end;

function TPTCInterfaceObject.invnormI(i: double): double;
Var a: double;
begin
  a := ProjectControl.ProjCellArea;
  Result := i * a;
end;

function TPTCInterfaceObject.normU(u: double): double;
//calculate normalized current to area
Var
  n: double;
  b: boolean;
begin
  b := RegistryMainConfig.valBool[ IdNormStackVoltageByNoOfCells ];
  if b then n := RegistryMainConfig.valInt[ IdNumberOfCellsInStack ] else n := 1;
  try
      if n>0 then Result := u / n else Result := u;
  except
      on E: Exception do
        begin
         //logmsg( 'PTCInterfaceObject: normI: error normalize divide - ' + E.message);
         Result := u;
        end;
  end;
end;

function TPTCInterfaceObject.invnormU(u: double): double;
Var n: double;
    b: boolean;
begin
  b := RegistryMainConfig.valBool[ IdNormStackVoltageByNoOfCells ];
  if b then n := RegistryMainConfig.valInt[ IdNumberOfCellsInStack ] else n := 1;
  if n>0 then Result := u * n else Result := u;
end;


function TPTCInterfaceObject.GenerateFileInfoHeaderPTCBasic: string;
begin
  Result := 'PTC N/A';
  if ControlObj=nil then exit;
  Result := ControlObj.GenFileInfoHeaderBasic;
end;

function TPTCInterfaceObject.GenerateFileInfoHeaderPTCInclDC: string;
begin
  Result := ControlObj.GenFileInfoHeaderBasic
            + 'OutputEnabled='; //+ BoolToStr( ControlObj.LastPTCStatus.isLoadConnected )+#13#10
           // + 'Feedback='+ PTCModeToStr( fLastPTCStatus.Mode )+#13#10
           // + 'Setpoint='+ BoolToStr( fLastPTCStatus.isLoadConnected )+#13#10
           // + 'Vout=NA'+#13#10
           // + 'Vsense='+ FloatToStrF( fLastPTCdata.U , ffFixed, 4,2)+#13#10
           // + 'Vref='+ FloatToStrF( fLastPTCdata.Uref , ffFixed, 4,2)+#13#10
            //;+ 'I='+ FloatToStrF( fLastPTCdata.I , ffFixed, 4,2)+#13#10
end;


//*****************************




function PTCmodetostr(m: TPotentioMode): string;
begin
  if m = CPotCC then Result := 'Const I'
  else if m = CPotCV then Result := 'Const U'
   else if m = CPotCR then Result := 'Const R'
   else if m = CPotCP then Result := 'Const P'
   else Result := 'PTCmode-Error';
end;

function PTCrelayToStr(b: boolean): string;
begin
  if b then Result := 'Output CONNECTED'
  else Result := 'Disconnected';
end;





//
//
//*******************
//
//  Flow Controller Object
//
//
// **************




constructor TFlowCtrlInterfaceObject.Create;
begin
  inherited;
  fMyDev := nil;
  fHWerrorCount := 0;
  fHWLastTimeOnline := 0;
  //
  fRootToken := THWAccessToken.Create;
  if fRootToken<>nil then fRootToken.tokenname := 'FlowIfaceObject-SetMFC';
  if FormHWAccessControl<>nil then FormHWAccessControl.RegisterRootToken( fRootToken );
  logmsg('ii TFlowCtrlInterfaceObject.Create: done.');
end;

destructor TFlowCtrlInterfaceObject.Destroy;
begin
  fRootToken.Destroy;
  inherited;
end;

function TFlowCtrlInterfaceObject.DevIsReady: boolean;
begin
  Result := false;
  if CheckForNil('DevIsReady') then exit;
  Result := fMyDev.IsReady;
end;

procedure TFlowCtrlInterfaceObject.DeviceAssign( dev: TFlowControllerObject );
begin
  fMyDev := dev;
end;


procedure TFlowCtrlInterfaceObject.CheckReconnect;
begin
  if CheckForNil('CheckReconnect') then exit;
  if (not fMyDev.IsReady)  and  (not MainHWInterface.FlowForceOffline)  and (TimeDeltaNowMS(fHWLastTimeOnline) > CHWTryReconnectDelayMS) then   //try reconnect
    begin
      LogProjectEvent(' Flow dev was offline and time since last error is long enough -> try reinitialise');
      fHWerrorCount := 0;
      fHWLastTimeOnline := Now; //!!!
      fMyDev.Initialize;
    end;
end;

function TFlowCtrlInterfaceObject.GenerateFileInfoHeaderFlow: string;
begin
  //Result := ControlObj.GenFileInfoHeaderBasic;
  Result := '[FLOW]' + #13#10;
end;


function TFlowCtrlInterfaceObject.Aquire(): boolean;
//reads data and status, it is stoerd into internal buffer - read it from FlowDataLatest
//it is ok to call aquire often - the flow modules run in different thread and only provides cached data anyway
//here aquire does not check for valid token access - because aquire does not modify anything and practically does not block any access
Var
  dev: TFlowDevices;
  p, df, maxf: double;
  s: string;
  fs: TFormatSettings;
  Alicat: TAlicatFlowControl;
Const
  CEpsilonSCCM=1;
  CfactorSCCM=0.05;
begin
  Result := false;
  fLastAquireTimeMS := -1;
  if CheckForNil('Aquire') then exit;
  if not DevIsReady then exit;
  //update last online
  fHWLastTimeOnline := Now();

  Result := fMyDev.Aquire( FlowData, FlowFlags );
  if not Result then exit;   //something was nil or very wrong
  //Do necessary transformation
  //Convert psi to bar
  for dev:= low(TFlowDevices) to high(TFlowDevices) do
    begin
      p := FlowData[dev].pressure;
{      try
        p := ConvertPsiToBar( p ) - 1.0;        //psi to bar
      except
        on E: Exception do p := NaN;
      end;}
      FlowData[dev].pressure := p;
    end;
  //Warn when device not responding
  for dev:= low(TFlowDevices) to high(TFlowDevices) do
    begin
      if (CFlowDevNotResponding in FlowData[dev].flagSet) then
          begin
         //logWarning( 'TFlowCtrlInterfaceObject.Aquire: Device NOT RESPONDING: ' + FlowDevToStr( dev) )
          end
      else if not FlowCheckDataIsValid(dev, FlowData) then
         logWarning( 'TFlowCtrlInterfaceObject.Aquire: Data not valid for device: ' + FlowDevToStr( dev) );
    end;
  //
  //check if connection is working and if not - try Reconnect!!!
  if (CCSConnectionLost in FlowFlags) and (fHWerrorCount=0) then
    begin
      logerror('TFlowCtrlInterfaceObject.Aquire: DETECTED FlowDevice ConnectionLost FLAG -> trying to reset (count recently ' + IntToStr(fHWerrorCount) );
      Inc( fHWerrorCount );
      fHWErrorLastTime := Now();
      //only try once after error is found - next try will be after set amout of time , when the error count is reset to 0
      fMyDev.ResetConnection;
    end;
  //reset HW error count, if no error in last interval
  if (fHWerrorCount>0) and (TimeDeltaNowMS(fHWErrorLastTime) > 30000) then  //1min    //!!!!must be less than time after which recoonect is tried
    begin
      LogProjectEvent('iii TFlowCtrlInterfaceObject.Aquire: Since last HW error was long ago, reseting HW error counter');
      fHWerrorCount := 0;
    end;

  //
  //check flow and setpoint - iof differes a lot set warning flag
  for dev:= low(TFlowDevices) to high(TFlowDevices) do
    begin
      Exclude( FlowData[dev].flagSet, CFlowSetpointDiffersFromFlow);
      df := Abs( FlowData[dev].setpoint - FlowData[dev].massflow );
      maxf := fMyDev.GetRange(dev).high;
      if isnan(df) then continue;
      if df > maxf*CfactorSCCM then
        begin
          Include( FlowData[dev].flagSet, CFlowSetpointDiffersFromFlow);
          //logWarning( 'TFlowCtrlInterfaceObject.Aquire: Setpoint DIFFERS TOO MUCH FROM ACTUAL FLOW - CHECK GAS SUPPLY : ' + FlowDevToStr( dev) )
        end;
    end;

  fs := GlobalConfig.FormatSettings;
  //send values to FCS control
  s := 'SET MFC1' + ' ' + FloatToStr( FlowData[CFlowAnode].massflow, fs )+';' ;
  StrAdd(s, 'SET MFC2' + ' ' + FloatToStr( FlowData[CFlowN2].massflow, fs )+';' );
  StrAdd(s, 'SET MFC3' +  ' ' + FloatToStr( FlowData[CFlowCathode].massflow, fs )+';' );
  StrAdd(s, 'SET MFC4' +  ' ' + FloatToStr( FlowData[CFlowRes].massflow, fs ) + ';' );
  StrAdd(s, 'SET SMFC1' +  ' ' + FloatToStr( FlowData[CFlowAnode].pressure, fs ) +';' );
  StrAdd(s, 'SET SMFC2' +  ' ' + FloatToStr( FlowData[CFlowN2].pressure, fs ) +';' );
  StrAdd(s, 'SET SMFC3' +  ' ' + FloatToStr( FlowData[CFlowCathode].pressure, fs ) +';' );
  StrAdd(s, 'SET SMFC4' +  ' ' + FloatToStr( FlowData[CFlowRes].pressure, fs ) +';' );
  StrAdd(s, 'SET S4' +  ' ' + FloatToStr( FlowData[CFlowN2].pressure, fs ) +';' );
  StrAdd(s, 'SET S5' +  ' ' + FloatToStr( FlowData[CFlowRes].pressure, fs ) );

  if MainHWInterface.fEnableSendMFC then
    begin
      MainHWInterface.VTPsendCmdRaw(s, fRootToken);
    end;

  //statistic  LastCycleDurMS
  fLastAquireTimeMS := -1;
  //if fMydev is TAlicatFlowControl then  !!!!!!!!!!!!!
  //  begin
  //    Alicat := TAlicatFlowControl( fMyDev);
  //    fLastAquireTimeMS := Alicat.fLastCycleInsideMS; //Alicat.GetLastCycleDurMS;
  //  end;
  fLastAquireTimeMS := fMyDev.LastAcqTimeMS;

end;



function TFlowCtrlInterfaceObject.SetFlow(dev: TFlowDevices; sp: double): boolean; //value in sccm; only if token t is currently owning control will be the change done
Var
 b: boolean;
begin
  Result := false;
  if CheckForNil('SetFlow') then exit;
  Result := fMyDev.SetSetp( dev, sp);
end;


function TFlowCtrlInterfaceObject.FlowGetLatestDataSingle( flowdev: TFlowDevices): TFlowRec;
begin
  Result := FlowData[ flowdev];
end;


function TFlowCtrlInterfaceObject.FlowGetDeviceRange(flowdev: TFlowDevices): TRangeRecord;
begin
  InitWithNAN( Result );
   if CheckForNil('FlowGetDeviceRange') then exit;
  Result := fMyDev.GetRange( flowdev );
end;


function TFlowCtrlInterfaceObject.FlowGetLatestDataAll(): TFlowData;
begin
end;




function TFlowCtrlInterfaceObject.FlowCheckDataIsValid(flowdev: TFlowDevices; Var FD: TFlowData): boolean;
Var
  d: TDateTime;
  bad: boolean;
Const
  CMaxAgeMS = 5000;
begin
  bad := true;
  d := FD[ flowdev ].timeStamp;
  if not IsNAN( d ) then
      begin
        try
          bad := DateTimeToMS( TimeDeltaNow(d) ) > CMaxAgeMS;
        except
           bad := true;
        end;
      end;
  Result := not bad;
end;



function  TFlowCtrlInterfaceObject.CheckForNil( sender: string): boolean;  //check if reference is not nil - if yes then log msg - name = sender msg
begin
  if fMyDev=Nil then
    begin
      logmsg( 'eeee TFlowCtrlInterfaceObject: inside ' + sender + ': MyDev=Nil!');
      Result := true;
      exit;
    end;
  Result := false;
end;



//
//
//*******************
//
//  VTP INTERFACE Object
//
//
// **************



constructor TVTPInterfaceObject.Create;
begin
  inherited;
  fMyDev := nil;
  fHWerrorCount := 0;
  //
  fRootToken := THWAccessToken.Create;
  if fRootToken<>nil then fRootToken.tokenname := 'VTPIfaceObject';
  if FormHWAccessControl<>nil then FormHWAccessControl.RegisterRootToken( fRootToken );
  logmsg('ii TVTPInterfaceObject.Create: done.');
end;

destructor TVTPInterfaceObject.Destroy;
begin
  fRootToken.Destroy;
  inherited;
end;

function TVTPInterfaceObject.DevIsReady: boolean;
begin
  Result := false;
  if CheckForNil('DevIsReady') then exit;
  Result := fMyDev.IsReady;
end;

procedure TVTPInterfaceObject.DeviceAssign( dev: TVTPControllerObject );
begin
  fMyDev := dev;
end;


function TVTPInterfaceObject.Aquire(): boolean;
//reads data and status, it is stoerd into internal buffer - read it from FlowDataLatest
//it is ok to call aquire often - the flow modules run in different thread and only provides cached data anyway
//here aquire does not check for valid token access - because aquire does not modify anything and practically does not block any access
Var
  dev: TFlowDevices;
  p, df, maxf: double;
Const
  CEpsilonSCCM=1;
  CfactorSCCM=0.05;
begin
  Result := false;
  fLastAquireTimeMS := -1;
  if CheckForNil('Aquire') then exit;
  if not DevIsReady then exit;
  //
  Result := fMyDev.Aquire( DataV, DataS, DataR );
  CommFlags := fMyDev.GetFlags;
  //
  MainHWInterface.fMSWCtrlStatus := Round(dataS[CMswCtrl].val);

  //reset HW error count, if no error in last hour
  if (fHWerrorCount>0) and (TimeDeltaNowMS(fHWErrorLastTime) > 300000) then  //5min
    begin
      LogProjectEvent('iii TFlowCtrlInterfaceObject.Aquire: Since last HW error was long ago, reseting HW error counter');
      fHWerrorCount := 0;
    end;
  //check if connection is working and if not - try Reconnect!!!
  if CCSConnectionLost in CommFlags then
    begin
      logerror('TFlowCtrlInterfaceObject.Aquire: DETECTED FlowDevice ConnectionLost FLAG -> trying to reset (count recently ' + IntToStr(fHWerrorCount) );
      Inc( fHWerrorCount );
      fHWErrorLastTime := Now();
      //if error is not very high, try to reset error and hope, it will not happen again
      if fHWerrorCount < CHWErrorCountThreshold then
        begin
          fMyDev.ResetConnection;
        end
      else
        begin
          LogProjectEvent('EE TFlowCtrlInterfaceObject.Aquire: TOO MANY HW errors RECENTLY - GIVING UP - will not recover again and disconnect!!!!  count: ' + IntToStr( fHWerrorCount ) );
          fMyDev.Finalize;
        end;
    end;
  //

  //time statistic
  fLastAquireTimeMS := fMyDev.LastAcqTimeMS;

  if not Result then exit;   //something was nil or very wrong
  //Do necessary transformation
      //none
  //

  //check setpoint - iof differes a lot set warning flag

end;


function TVTPInterfaceObject.SetDevice(dev: TRegDevices; sp: double): boolean;
begin
  Result := false;
  if CheckForNil('SetDevice') then exit;
  Result := fMyDev.SetRegSetp( dev, sp);
end;


function TVTPInterfaceObject.SendCmdRaw(s: string): boolean;
begin
  Result := false;
  if CheckForNil('SetDevice') then exit;
  Result := fMyDev.SendCmdRaw(s);
end;


function TVTPInterfaceObject.GenerateFileInfoHeaderVTP: string;
begin
  Result := '[FCSControl]'
            + 'OutputEnabled='; //+ BoolToStr( ControlObj.LastPTCStatus.isLoadConnected )+#13#10
           // + 'Feedback='+ PTCModeToStr( fLastPTCStatus.Mode )+#13#10
           // + 'Setpoint='+ BoolToStr( fLastPTCStatus.isLoadConnected )+#13#10
           // + 'Vout=NA'+#13#10
           // + 'Vsense='+ FloatToStrF( fLastPTCdata.U , ffFixed, 4,2)+#13#10
           // + 'Vref='+ FloatToStrF( fLastPTCdata.Uref , ffFixed, 4,2)+#13#10
            //;+ 'I='+ FloatToStrF( fLastPTCdata.I , ffFixed, 4,2)+#13#10
end;


{

function TFlowCtrlInterfaceObject.FlowGetLatestDataAll(): TFlowData;
begin
end;




function TVTPInterfaceObject.FlowCheckDataIsValid(flowdev: TFlowDevices): boolean;
Var
  d: TDateTime;
  bad: boolean;
Const
  CMaxAgeMS = 5000;
begin
  Result := false;
  d := FlowData[ flowdev ].timeStamp;
    if IsNAN( d ) then bad := true
    else
      begin
        try
          bad := DateTimeToMS( TimeDeltaNow(d) ) > CMaxAgeMS;
        except
           bad := true;
        end;
      end;
  if bad then exit;
  Result := true;
end;

}

function  TVTPInterfaceObject.CheckForNil( sender: string): boolean;  //check if reference is not nil - if yes then log msg - name = sender msg
begin
  if fMyDev=Nil then
    begin
      logmsg( 'eeee TVTPInterfaceObject: inside ' + sender + ': MyDev=Nil!');
      Result := true;
      exit;
    end;
  Result := false;
end;








//
//
//*******************
//
//  MAIN INTERFACE Object
//
//
// **************



constructor TMainInterfaceObject.Create;
begin
  inherited;
  fPTCiface := TPTCInterfaceObject.Create();
  fFLOWiface := TFlowCtrlInterfaceObject.Create;
  fVTPiface := TVTPInterfaceObject.Create;
  //fFlowDataValid := false;
  //fPTCDataValid := false;
  fMinLogInt := 500;
  fLastAquireTime := 0;
  fMSWCtrlStatus := -1;
  fFCSInterlok := false;
  fFlowForceOffline := false;
  fEnableSendMFC := false;
  //
  fAcquireLock := false;
  //
  fPTCReadylaststate := false;
  //register receive signals
  GlobalConfig.RegisterForBroadcastSignals( HandleBroadcastSignals );
  //
end;



destructor TMainInterfaceObject.Destroy;
begin
  fPTCiface.Destroy;
  fFLOWiface.Destroy;
  fVTPiface.Destroy;
  inherited;
end;


procedure TMainInterfaceObject.HandleBroadcastSignals(sig: TMySignal);
Var
  invv: boolean;
  limlow, limhigh: double;
  rngrec: TRangeRecord;
begin
  case sig of
    //
     CSigProjectConfUpdated:
       begin
         //TODO:
         //check invert voltage state and update safety limits in PTC!
         if ProjectControl.ProjInvertVoltage then
           begin
             limlow := - ProjectControl.ProjMaxVoltage;
             limhigh := - ProjectControl.ProjMinVoltage;
           end
         else
           begin
             limlow := ProjectControl.ProjMinVoltage;
             limhigh := ProjectControl.ProjMaxVoltage;
           end;
         rngrec.low := limlow;
         rngrec.high := limhigh;
         if fPTCiface<>nil then fPTCiface.PTCSetV4SafetyRange( rngrec );
         // ??? more
       end;
  end; //case
end;


function TMainInterfaceObject.InitAll: boolean;  //IMPORTANT TO CALL - creates & ini  all necessary modules
Var
 b1, b2, b3: boolean;
begin
  b1 := false;
  b2 := false;
  b3 := false;
  if fPTCiface<>nil then  if fPTCiface.PTCIsReady then b1 := true else b1 := fPTCiface.ControlObj.Initialize;
  if fFLOWiface<>nil then  if fFLOWiface.DevIsReady then b2 := true else b2 := fFLOWiface.ControlObj.Initialize;
  if fVTPiface<>nil then  if fVTPiface.DevIsReady then b3 := true else b3 := fVTPiface.ControlObj.Initialize;
  Result := b1 and b2 and b3;
end;


function TMainInterfaceObject.PTCinit: boolean;   //force PTCinit
begin
  Result := false;
  if fPTCiface<>nil then  Result := fPTCiface.Init;
end;



function TMainInterfaceObject.PTCIsReady: boolean;
begin
  Result := false;
  if fPTCiface<>nil then  Result := fPTCiface.PTCIsReady;
end;

function TMainInterfaceObject.FlowDevIsReady: boolean;
begin
  Result := false;
  if fFLOWiface<>nil then  Result := fFLOWiface.DevIsReady;
end;


function TMainInterfaceObject.GenerateFileInfoHeader:string;
begin
  Result := '[Application]'#13#10
            + 'AppVersion='+ GlobalConfig.AppVersionStr + #13#10
            + PTCControl.GenerateFileInfoHeaderPTCBasic
            + FlowControl.GenerateFileInfoHeaderFLow
            + VTPControl.GenerateFileInfoHeaderVTP;
end;



procedure TMainInterfaceObject.PTCDevAssign( dev: TPotentiostatObject );
begin
  if fPTCiface<>nil then fPTCiface.PTCAssign(dev);
end;

procedure TMainInterfaceObject.FlowDeviceAssign( dev: TFlowControllerObject );
begin
  if fFLOWiface<>nil then fFLOWiface.DeviceAssign(dev);
end;

procedure TMainInterfaceObject.VTPDeviceAssign( dev: TVTPControllerObject );
begin
  if fVTPiface<>nil then fVTPiface.DeviceAssign(dev);
end;


function TMainInterfaceObject.AquireAll(t: THWAccessToken): boolean;  //MOST INPORTANT FUCNTION - You want to use this one in most cases
Const
  CLagReportLimit = 1000;
Var
  b1, b2, b3: boolean;
  nt, deltant: longint;
  t0: longint;
begin
  Result := false;
  if not CheckToken( t ) then exit;

  //
  if fAcquireLock then
    begin
      LogWarning('in AQUIREALL: reentrance detected');
      exit;  //should prevent REENTRANCE
    end
  else fAcquireLock := true;
  try

  fForceLog := false;
  nt := GetTickCount();
  //PTC
  MonitorRecFillNaN( fMonitorRec );
  fMSWCtrlStatus := -1;


  t0 := TimeDeltaTICKgetT0;

  b1 := false;
  try
    if fPTCiface<>nil then
      begin
        fPTCwasReady := fPTCiface.PTCIsReady;
        //check if PTC become ready -if yes - run projectUpdate - need to set V4 limits !!!
        if fPTCwasReady and (not fPTCReadylaststate) then  HandleBroadcastSignals( CSigProjectConfUpdated );
        fPTCReadylaststate := fPTCwasReady;
        //
        b1 := fPTCiface.PTCAquire();
      end;
  except
    on E: Exception do logError('EEEE TMainInterfaceObject.AquireAll PTCAquire EXCEPTION: ' + E.message);
  end;
  //fill PTC data

  if b1 then
    begin
	    fMonitorRec.U := fPTCiface.PTCProcessedData.U;
      fMonitorRec.I := fPTCiface.PTCProcessedData.I;
      fMonitorRec.P := fPTCiface.PTCProcessedData.P;
	    fMonitorRec.Inorm := fPTCiface.PTCProcessedData.Inorm;
      fMonitorRec.Unorm := fPTCiface.PTCProcessedData.Unorm;
	    fMonitorRec.Pnorm := fPTCiface.PTCProcessedData.Pnorm;
	    fMonitorRec.Uraw := fPTCiface.PTCRawData.U;
	    fMonitorRec.Iraw := fPTCiface.PTCRawData.I;
	    fMonitorRec.Praw := fPTCiface.PTCRawData.P;
	    fMonitorRec.Uref := fPTCiface.PTCRawData.Uref;
	    fMonitorRec.PTCrec := fPTCiface.PTCRawData;
	    fMonitorRec.PTCstatus := fPTCiface.PTCStatus;
      //
      if cPTCImporatntChangeDetected in fPTCiface.PTCStatus.flagSet then fForceLog := true;
    end;
  //
  //FLOW
  b2 := false;
  try
    if fFLOWiface<>nil then
      begin
        if (not fFLOWiface.DevIsReady) and (not globalconfig.initflag) then fFLOWiface.CheckReconnect;
        fFlowwasReady := fFLOWiface.DevIsReady;
        b2 := fFLOWiface.Aquire();
      end;
  except
    on E: Exception do logError('EEEE TMainInterfaceObject.AquireAll fFLOWiface.Aquire EXCEPTION: ' + E.message);
  end;

  //fFlowDataValid := b2;
  if b2 then
    begin
      fMonitorRec.FlowData := fFLOWiface.FlowData;      //!!!!
      fMonitorRec.FlowFlags := fFLOWiface.FlowFlags;
    end;
  //fMonitorRec.FlowStatus := fFLOWiface.FlowStatus;

  b3 := false;
  try
    if fVTPiface<>nil then
      begin
        fVTPwasReady := fVTPiface.DevIsReady;
        b3 := fVTPiface.Aquire();
      end;
  except
    on E: Exception do logError('EEEE TMainInterfaceObject.AquireAll VTPiface.Aquire EXCEPTION: ' + E.message);
  end;

  if b3 then
    begin
      fMonitorRec.ValveData := fVTPiface.datav;      //!!!!
      fMonitorRec.SensorData := fVTPiface.DataS;      //!!!!
      fMonitorRec.RegData := fVTPiface.DataR;      //!!!!
      fMonitorRec.VTPFlags := fVTPiface.CommFlags;
    end;

   fLastAquireTotalDurMS := TimeDeltaTICKNowMS( t0 );


  //performance check
  deltant := GetTickCount () - nt;
  if deltant>CLagReportLImit then
    begin
      logmsg('iiii TMainInterfaceObject.AquireAll: finished, needed UNUSUALLY MANY ticks: '+ IntTOStr( deltant) +
               'details: PTC ' + IntToStr( PTCControl.LastAquireTimeMS) +
               'Flow ' + IntToStr( FlowControl.LastAquireTimeMS) +
               'VTP ' + IntToStr( VTPControl.LastAquireTimeMS)    );
    end;
  //
  //HARDWARE HEALTH CHECK -

  //
  LogData;
  //
  Result := b1 and b2 and b3;
  
  finally
    fAcquireLock := false;
  end;
end;



procedure TMainInterfaceObject.LogData;
Var
  pmonrec: PMonitorRec;
begin
  //process and log data
  //store aquired data into log and intot memory storage
  //***********************************
  //recording data for online graph
  //
  if fForceLog or (TimeDeltaNowMS( fLastLogTime ) > minloginterval ) then
	  begin
	    pmonrec := @fMonitorRec;
	    //log into memory storage
      //do not log during init!!! prevent temporary some trouble with NANs ...
	    if GlobalConfig<>nil then
        begin
           if not GlobalConfig.initflag then
             begin
               if (MonitorMemHistory.MemUsageProcent)>95 then
                 begin
                   logwarning('TMainInterfaceObject.LOGDATA - MonitorMemHistory.MemUsageMB ALMOST FULL - DELETING 20% of oldest records!!!');
                   MonitorMemHistory.MakeSpaceProcents(20);
                 end;
               MonitorMemHistory.AddRec( pmonrec );
             end;
        end;
	    //log data into monitor log file
	    MonitorFileMain.LogRecord( fMonitorRec );
	  end;
end;


//***********************************
//  wrappers

function TMainInterfaceObject.PTCSetCC(val: double; t: THWAccessToken): boolean;    //normally expecting value in "A.cm-2" + will do processing according to Invertcurrent!!
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCSetCC(val);
end;

function TMainInterfaceObject.PTCSetCV(val: double; t: THWAccessToken): boolean;    //will do processing according to InvertVoltage!!
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCSetCV(val);
end;

function TMainInterfaceObject.PTCUpdateSetpoint(val: double; t: THWAccessToken): boolean;  //wrapper for the two above functions  with processed values  (value in V or A.cm-2)
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCUpdateSetpoint(val);
end;

function TMainInterfaceObject.PTCSetCCwonorm(val: double; t: THWAccessToken): boolean;  // this  uses invercurrent, but no normalization - the value in "A"
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCSetCCwonorm(val);
end;

function TMainInterfaceObject.PTCSetCCraw(val: double; t: THWAccessToken): boolean;    //does do anything to the parameter  value in "A"
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCSetCCraw(val);
end;

function TMainInterfaceObject.PTCSetCVraw(val: double; t: THWAccessToken): boolean;    //does do anything to the parameter  value in "V"
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCSetCVraw(val);
end;

function TMainInterfaceObject.PTCUpdateSetpointRaw(val: double; t: THWAccessToken): boolean;  //uses the PTCmode used last time, no adjustments to the value
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCUpdateSetpointRaw(val);
end;

function TMainInterfaceObject.PTCTurnON(t: THWAccessToken): boolean;
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCTurnON;
end;

function TMainInterfaceObject.PTCTurnOFF(t: THWAccessToken): boolean;
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCTurnOFF;
end;

function TMainInterfaceObject.PTCGetRelayStatus(t: THWAccessToken): boolean;
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fPTCiface=nil then exit;
  Result := fPTCiface.PTCGetRelayStatus;
end;


function TMainInterfaceObject.FlowInit: boolean;  //if force is set true, interface will not try to reinitialize automatically
begin
  if fFLOWiface=nil then exit;
  if fFLOWiface.fMyDev = nil then exit;
  Result := fFLOWiface.fMyDev.Initialize;
end;


function TMainInterfaceObject.FlowFinalize(force: boolean = false): boolean;  //if force is set true, interface will not try to reinitialize automatically
begin
  Result := false;
  fFlowForceOffline := force;
  if fFLOWiface=nil then exit;
  if fFLOWiface.fMyDev = nil then exit;
  fFLOWiface.fMyDev.Finalize;
  Result := true;
end;

function TMainInterfaceObject.FlowSetSP(dev: TFlowDevices; sp: double; t: THWAccessToken): boolean; //value in sccm; only if token t is currently owning control will be the change done
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fFLOWiface=nil then exit;
  Result := fFLOWiface.SetFlow(dev, sp);
end;

function TMainInterfaceObject.VTPsetDevice(dev: TRegDevices; sp: double; t: THWAccessToken): boolean;
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fVTPiface=nil then exit;
  Result := fVTPiface.SetDevice(dev, sp);
end;

function TMainInterfaceObject.VTPsendCmdRaw(s: string; t: THWAccessToken): boolean;
begin
  Result := false;
  if not CheckToken( t ) then exit;
  if fVTPiface=nil then exit;
  Result := fVTPiface.sendCmdRaw(s);
end;

function TMainInterfaceObject.CheckToken(t: THWAccessToken): boolean;
begin
  Result := false;
  if t=nil then begin exit; end;  //exit;
  Result := FormHWAccessControl.TokenCanAccessHW( t );
  if Result = false then logwarning('TMainInterfaceObject.CheckToken: this token has not been granted access to HW! (' + t.tokenname + ')' );
end;


procedure TMainInterfaceObject.setMinLogInterval( tms: longint);
begin
  if tms<10 then tms := 10;
  fMinLogInt := tms;
end;




//***********************************






procedure HWInterfaceInit;
begin
  MainHWInterface := TMainInterfaceObject.Create();
end;

procedure HWInterfaceDestroy;
begin
  MainHWInterface.Destroy;
end;


//***********************************


function CalculateFlowAnode( Iraw: double ): double;   //Iraw=current in A, result in sccm - calculates flow using projects settings for flow tracking
Var
  min, stoich, flow: double;
 n: double;
    b: boolean;
begin
  b := RegistryMainConfig.valBool[ IdNormStackVoltageByNoOfCells ];
  if b then n := RegistryMainConfig.valInt[ IdNumberOfCellsInStack ] else n := 1.0;
  min := ProjectControl.ProjAnodeMinFlow;
  stoich := ProjectControl.ProjAnodeStoich;
  //correct for number of cells
  Iraw := Iraw * n;
  //
  if IsNaN(Iraw) then
   begin
     Result := NaN;
     exit;
   end;
  flow := Abs(Iraw) * CAnFlCoef * stoich;
  if isnan(flow) or isnan(min) then
       begin Result := NAN; exit; end;
  if flow<min then flow := min;
  Result := flow;
end;

function CalculateFlowCathode( Iraw: double ): double;   //Iraw=current in A, result in sccm - calculates flow using projects settings for flow tracking
Var
  min, stoich, flow: double;
    n: double;
    b: boolean;
begin
  b := RegistryMainConfig.valBool[ IdNormStackVoltageByNoOfCells ];
  if b then n := RegistryMainConfig.valInt[ IdNumberOfCellsInStack ] else n := 1.0;
  //
  min := ProjectControl.ProjCathodeMinFlow;
  stoich := ProjectControl.ProjCathodeStoich;
  //correct for number of cells
  Iraw := Iraw * n;
  //
  if IsNaN(Iraw) then
   begin
     Result := NaN;
     exit;
   end;
  if isnan(flow) or isnan(min) then
       begin Result := NAN; exit; end;
  flow := Abs(Iraw) * CCaFlCoef * stoich;
  if flow<min then flow := min;
  Result := flow;
end;


//***********************************

initialization

  CommonDataRegistry := TMyRegistryNodeObject.Create('CommonDataRegistry');

finalization

  MyDestroyAndNil( CommonDataRegistry);

end.


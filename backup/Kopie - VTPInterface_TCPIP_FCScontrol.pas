unit VTPInterface_TCPIP_FCScontrol;

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, ParseUtils, Logger, ConfigManager,
  HWAbstractDevicesNew,                  sockets,
  cport ,   //in '..\cport\cport.pas'
  cportctl;  //in '..\cport\cportCtl.pas'

{create descendant of virtual abstract FLOW object and define its methods
especially including definition of configuration and setup methods}


//http://stackoverflow.com/questions/5530038/how-to-handle-received-data-in-the-tcpclient-delphi-indy

Const
  CInterfaceVer = 'TCPIP client 2016-02-24 (by Michal Vaclavu)';

  CNotRespCount = 5;
  CComTimeoutConstMS = 5000;
  CReportLagThreshold = 2000;

  CThreadIdStr = 'VTP';

Type

  //flow commands

  TVTPCmdType = (CVTPCmdUNDEF, CVTPCmdSetVar, CVTPCmdUser);

  TSynchroMethodId = procedure(cmdid: longint; result: boolean) of object;

  TVTPDataThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)   //for reporting data back
  public
    constructor Create;
    destructor Destroy; override;
  public
    dataV: TValveData;
    dataT: TTempData;
    dataPSens: TPressureSensData;
    dataPReg: TPressureRegData;
    dataO: TOtherDevData;
    fLastSuccessAquireTime: TDateTime;
    aswerlowlvl: string;  //for use with user cmd - answer to last USER cmd - in raw as received
  end;

  TVTPCmdArrayRec = record
    t: TVTPCmdType;
    id: longint;
    varname: string;
    paramd: double;
    parami: longint;
    paramb: boolean;
    params: string;
    responsemethod: TSynchroMethodId;  //if not nil then that is request to call synchronize to this method after completing or failing cmd
                                     //the result of last cmd is to be stored elsewhere - will be in datasynchro
  end;

  TVTPCmdQueueThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)
  public
    constructor Create;
    destructor Destroy; override;
  public
    //this section will be used by aquire thread to pop commands and execute them
    Asize: word; //allocaed size of cmd array -  which works like queue "round-robin" style
    cmdArray: array of TVTPCmdArrayRec;
    strtpos: word; //
    endpos: word;
    function PopCmd(Var cmdrec: TVTPCmdArrayRec): boolean; //if ok, non empty then returns cmd from and deletes the oldest record
    function nWaiting(): word;  //if >0 then there is  work and can use pop
  public
    //control interface only uses addcmd
    function AddCmd(cmd: TVTPCmdArrayRec): boolean;
    function CanAdd(): boolean; // if there is space for new cmd
  end;
  //    cmdwaiting: boolean;  //signal by main thread that new cmd is ready - will be cleared by sub-thread after processing during "synchro reading"


  TTCPClientThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)
    public
      constructor Create;
      destructor Destroy; override;                                         //tcp
    public
      fTCPClient: TTCPClient;    //!!!!!!main communication component             //unit sockets
    private
      fcnterr: longint;    //counter of send msg/ recv msg errors
      fcntok: longint;
    public
      property comOkcnt: longint read fcntok write fcntok;
      property comErrcnt: longint read fcnterr write fcnterr;
      //property comSent: cardinal read fTCPClient.BytesSent;
      //property comReceived: cardinal read TCPClient.BytesReceived;
  end;


  TTempDeviceParamRec = record   //limits are for warning purposes only
    min: double;
    max: double;
    enabled: boolean;
    IdStr: string;
  end;

  TValveParamRec = record   //limits are for warning purposes only
    enabled: boolean;
  end;

  TPressureSensParamRec = record   //used for PressuresSens ; for Sensors - warning purpose if outside limits
    min: double;
    max: double;
    enabled: boolean;
    IdStr: string;
  end;

  TPressureRegParamRec = record   //used for Pressures Regulators includes last known setpoint
    min: double;
    max: double;
    setpoint: double;
    enabled: boolean;
    IdStr: string;
  end;

  TOtherDevParamRec = record   //used for other ON/OFF controls from Jiri Libra's "FcsControl"
    enabled: boolean;
    IdStr: string;
  end;




  TVTPDevicesListThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)     //for devices to iterare over    //TThreadList
  public
    constructor Create;
    destructor Destroy; override;
  public
    // this dynamic list will be used by aquire thread to poll each added device (read only)
    //it is here so that only selected devices will be polled for data!!! = those that are added to the arrays at initialization
    //device identificators to name the request will be produced by helper conversion function (in HWAbstractDevices)
    ValveDevs: array of TValveDevices;
    TempDevs: array of TTempDevices;
    PressSensDevs: array of TPressureSensDevices;
    PressRegDevs: array of TPressureRegDevices;
    OtherDevs: array of TOtherDevices;
    //id string to adrees device on the server
    IdStrValveDev: array[ TValveDevices ] of string;
    IdStrTempDev: array[ TTempDevices ] of string;
    IdStrPressSensDev: array[ TPressureSensDevices ] of string;
    IdStrPressRegDev: array[ TPressureRegDevices ] of string;
    IdStrOtherDev: array[ TOtherDevices ] of string;
  public    //these two methods - to make setup by main control interface
    procedure ClearAll;
    //
    procedure AddDev(dev: TTempDevices); overload;
    procedure AddDev(dev: TValveDevices); overload;
    procedure AddDev(dev: TPressureSensDevices); overload;
    procedure AddDev(dev: TPressureRegDevices); overload;
    procedure AddDev(dev: TOtherDevices); overload;
    //returns true if OK
    function GetDev(Var dev: TTempDevices; i: byte): boolean;  overload;
    function GetDev(Var dev: TValveDevices; i: byte): boolean;  overload;
    function GetDev(Var dev: TPressureSensDevices; i: byte): boolean;  overload;
    function GetDev(Var dev: TPressureRegDevices; i: byte): boolean;  overload;
    function GetDev(Var dev: TOtherDevices; i: byte): boolean;  overload;
  end;




  TMyAquireThread = class (TThread)       //TMultiReadExclusiveWriteSynchronizer.
    public
      constructor Create;
      destructor Destroy; override;
    public
      MySuspend: boolean;
      cmdsynchro: TVTPCmdQueueThreadSafe; //controls access to cmd queue and variables
                                          //after finishig, signal can be sent through assigned method
      datasynchro: TVTPDataThreadSafe;  //from here the data can be read anytime - cached buffer
                                         //!!!but still use beginread ... and endread methods to access)
                                         //the latest data should be there, expecting refresh interval every 500ms or so
      comsynchro: TTCPClientThreadSafe;  //locked access because of possible change of configuration -
                                         //this is only reference to the client object,   //the OBJECT is OWNED by the ROOT INTERFACE
      devicessynchro: TVTPDevicesListThreadSafe;  //over this assigned devices will be iterated aquire
    public
      procedure Execute; override;
      procedure AssignComSynchro(comsync: TTCPClientThreadSafe );
    private
      function getNextDev(Var it: longint; Var dev: TValveDevices; Var idstr: string): boolean; overload;
      function getNextDev(Var it: longint; Var dev: TTempDevices; Var idstr: string): boolean; overload;
      function getNextDev(Var it: longint; Var dev: TPressureSensDevices; Var idstr: string): boolean; overload;
      function getNextDev(Var it: longint; Var dev: TPressureRegDevices; Var idstr: string): boolean; overload;
      function getNextDev(Var it: longint; Var dev: TOtherDevices; Var idstr: string): boolean; overload;
      //
      function procDev(dev: TValveDevices; idstr: string; replystr: string): boolean; overload;
      function procDev(dev: TTempDevices; idstr: string; replystr: string): boolean; overload;
      function procDev(dev: TPressureSensDevices; idstr: string; replystr: string): boolean; overload;
      function procDev(dev: TPressureRegDevices; idstr: string; replystr: string): boolean; overload;
      function procDev(dev: TOtherDevices; idstr: string; replystr: string): boolean; overload;
      //
      function getNextCmd(Var cmd: TVTPCmdArrayRec): boolean;
      //
      //procedure PollDevice(devaddr: char; dev: TFlowDevices);
      //function MakeCmdDone( cmd: TVTPCmdArrayRec ): string;
    private
      function parseReplyStr1Dbl(idstr: string; replystr: string; Var val: double): boolean;
      function parseReplyStr1Int(idstr: string; replystr: string; Var val: longint): boolean;
      procedure ComOnReceive(Sender: TObject; Buf: pchar; var DataLen: integer); //this is the event handler for receiving data !!!
      function IsEndOfPacket: boolean;
      procedure MyThreadProcessMessages;
      function ActivelyWaitForReply(timeoutx: longword): boolean; //if timeout return false
      function ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
      function comSend(cmd: string; Var answer: string; toutms: longword): boolean; //basic comm - sends and receives answer !!! do not use inside critical/locked section - needs to process messages - may dead lock
      //---error reporting and logging fucntion
      procedure IncErrCnt;
      procedure IncOKCnt;
      //log - use only when necessary - uses synchronize call to  main thread
      procedure LeaveLogMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
      procedure LeaveWarningMsg(a: string);  //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
      procedure LeaveErrorMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
    private
      //low level helper
      procedure SyncLeaveLogMsg;     //this will argument to synchronize - used internaly, for log use proc LeaveLogMsg
      procedure SyncLeaveWarningMsg;  //this will argument to synchronize - used internaly
      procedure SyncLeaveErrorMsg;   //this will argument to synchronize - used internaly
    private
      syncmsg: string;
    private
      fSynchroLockedByWait: boolean;
      rxPacketEnd: TSimpleEvent;
      rxbuf: string;
      fFormatSettings: TFormatSettings;
      frefreshint: longint;
      fnextrefreshtime: array[TFLowDevices] of TDateTime; //index is the same as in devicessynchro: TFlowDevicesListThreadSafe
      fnextpoll: array[TFLowDevices] of TDateTime;
      fcommtimeoutcnt: array[TFLowDevices] of byte;
      fDebug: boolean;
    public
      property Debug: boolean read fDebug write fDebug;
  end;



  TVTPControl_TCP_FCSControl = class (TVTPControllerObject)
    //this obejct controls one serial port with up to N Alicat flow controllers attached
    //it uses another thread to poll for data on regular basis
    public
      constructor Create;
      destructor Destroy; override;
    public
    //inherited virtual functions - must override!
      function Initialize: boolean; override;
      procedure Finalize; override;
      procedure ResetConnection; override;
      //basic control functions
      function AquireValve(Var data: TValveData): boolean; override;
      function AquireTemp(Var data: TTempData): boolean; override;
      function AquirePressureSens(Var data: TPressureSensData): boolean; override;
      function AquirePressureReg(Var data: TPressureRegData): boolean; override;
      function AquireOther(Var data: TOtherDevData ): boolean; override;
      function SetSetpPressureReg(dev: TFlowDevices; val: double): boolean; override;
      function GetRangePressureSens(dev: TFlowDevices): TRangeRecord; override;
      function GetRangePressureReg(dev: TFlowDevices): TRangeRecord; override;
      function AquireStatus(Var status: TVTPStatus): boolean; override;
//iherited properties - just to have a notice ...
//  protected
//    fName: string;
//    fDummy: boolean;
//    fReady: boolean;
//  public
//    property Name: string read fName;
//    property IsDummy: boolean read fDummy;
//    property IsReady: boolean read fReady;
     private
      fConStatus: TConnectStatus;
      flock: boolean;  //prevent multiple nesting calls to comm fucntions
      fDebug: boolean;
      procedure setDebug(b: boolean);
    public
      property ConStatus: TConnectStatus read fConStatus;
      property Debug: boolean read fDebug write setDebug;
    private
      AquireThread: TMyAquireThread;
      comsynchro: TTCPClientThreadSafe;  //object created/owned here -> reference is assigned to the AquireThread
                                         // when accesing use beginwrite/endwrite
    public
      //TCPIP Client/ Com operation, configuration
      function CheckComClient(): boolean; //if not il returns true including comsynchro.TCPClient 
      function OpenCom(): boolean;
      procedure CloseCom;
      procedure SetupCom(host: string; port: string); //TCPIP
      function isComConnected(): boolean;
      function getErrCount(): longint;
      function getOKCount(): longint;
      procedure resetErrOKCounters;
      //others---
      //function Ping(): boolean; //try some simple command to check response
    public
      //user command
      fUserCmdReplyS: string;
      fUserCmdReplyTime: TDateTime;
      fUserCmdReplyIsNew: boolean;
    public
      //thread control
      procedure ThreadStart;
      procedure ThreadStop;
      function IsThreadRunning(): boolean;
      function getThreadStatus: string;
      procedure UpdateDevicesInThread;
      function GetNDevsInThread: byte;
      function SendUserCmd(cmd: string): boolean;
      procedure ReceiveReplyFromThread(cmdid: longint; result: boolean);    //"event handler" - reads reply from data.aswerlowlvl when beeing called using synchronize from thread
    public
      //devices config storage if relevant - for reading - Interface form can access them directly with no cencerns
      //for updating there is a method to make it easier
      fTempParamArray: array[TTempDevices] of TTempDeviceParamRec;
      fValveParamArray: array[TValveDevices] of TValveParamRec;  //only one property to remember now: enabled
      //here only pressure sensors and regulators have minimum and maximum
      fPresSensParamArray: array[TPressureSensDevices] of TPressureSensParamRec;  //sensor mostly in order to check value is in range
      fPresRegParamArray: array[TPressureRegDevices] of TPressureRegParamRec;
      fOtherDevParamArray: array[TOtherDevices] of TOtherDevParamRec;
    public
      //
      procedure UpdateDev(dev: TTempDevices; en: boolean; rngmin, rngmax: double); overload;
      procedure UpdateDev(dev: TValveDevices; en: boolean); overload;
      procedure UpdateDev(dev: TPressureSensDevices; en: boolean; rngmin, rngmax: double); overload;
      procedure UpdateDev(dev: TPressureRegDevices; en: boolean; rngmin, rngmax: double); overload;
      procedure UpdateDev(dev: TOtherDevices; en: boolean); overload;
    public
      //configuration load save
      procedure AssignConfigManager( Var cm: TLoadSaveConfigManager );  //use this to partially automate storing/loading of configuration from PTC control form
      procedure DoAfterConfLoad; //process values after load process of config manager registered variables
      procedure DoBeforeSavingConf;  // prepare variables to be saved by config manager
    private
    //---- private variables declaration
      fConfManagerId: longint;
      fConfigManager: TLoadSaveConfigManager;
      //configuration storage (need to use varibale, so it can be asigned to config manager
      fComHost: string;
      fComPort: word;
      //
    private
      procedure ResetLastAquireTime;
      //procedure leavemsg(s: string); //log msg and set return msg
    //*************************
  public
//    function PressureConnect(port:string; baud: longint): boolean;  virtual; abstract;
//    procedure PressureDisconnect; virtual; abstract;
  end;



//---------------------------------------
//helper, conversion functions

function FCSControlTCP_PressSensDev_ToStrId( dev: TPressureSensDevices  ): string;


//---------------------------------------
//Protocol description

// GET <name>
// SET <name> <val>



Implementation

uses Math, Windows, Forms;



//****************************
//          Aquire Thread
//****************************


constructor  TMyAquireThread.Create;
begin
  inherited Create(true); //createsuspended=true
  cmdsynchro := TVTPCmdQueueThreadSafe.Create;
  datasynchro := TVTPDataThreadSafe.Create;
  devicessynchro := TVTPDevicesListThreadSafe.Create;
  //
  comsynchro := nil;  //assigned from AlicatFlowControlObject
  rxbuf := '';
  GetLocaleFormatSettings(0, fFormatSettings );    //TFormatSettings
  //For Alicat!!! define "." as deciaml separator
  fFormatSettings.DecimalSeparator := '.';
  fSynchroLockedByWait := false;
  MySuspend := true;
  logmsg('TMyFlowAquireThread.Create: done.');
end;


destructor  TMyAquireThread.Destroy;
begin
  devicessynchro.Destroy;
  datasynchro.Destroy;
  cmdsynchro.Destroy;
  inherited;
end;


procedure TMyAquireThread.LeaveLogMsg(a: string);
//in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  syncmsg := 'THREAD ' + CThreadIdStr + ' ' + a;
  Synchronize( SyncLeaveLogMsg );
end;

procedure TMyAquireThread.LeaveWarningMsg(a: string);  //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  syncmsg :='THREAD ' + CThreadIdStr + ' ' + a;
  Synchronize( SyncLeaveWarningMsg );
end;

procedure TMyAquireThread.LeaveErrorMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  syncmsg :='THREAD ' + CThreadIdStr + ' ' + a;
  Synchronize( SyncLeaveErrorMsg );
end;

procedure TMyAquireThread.SyncLeaveLogMsg;     //this will serve as argument to synchronize - used internaly, for log use proc LeaveLogMsg
begin
  LogMsg( syncmsg );
end;

procedure TMyAquireThread.SyncLeaveWarningMsg;  //dtto
begin
  LogWarning( syncmsg );
end;

procedure TMyAquireThread.SyncLeaveErrorMsg;   //dtto
begin
  LogError( syncmsg );
end;

procedure TMyAquireThread.AssignComSynchro(comsync: TTCPClientThreadSafe );
Var
 client: TTCPClient;
begin
  comsynchro := comsync;
  if comsync<>nil then
    begin
      client := comsync.fTCPClient;
      if client<>nil then
        begin
          client.OnReceive := ComOnReceive;
        end;
    end;
end;



procedure TMyAquireThread.Execute;
Const
  CTargetCycleTimeMS = 500;
  CTCPTimeoutMS = 200;
Var
  //nv, nt, nps, npr, no: byte;
  n: longint;
  b1, b2: boolean;
  replystr: string;
  cmd: TVTPCmdArrayRec;
  d0: TDateTime;
  i, it, cnt: longint;
  vdev: TValveDevices;
  tdev: TTempDevices;
  psdev: TPressureSensDevices;
  prdev: TPressureRegDevices;
  odev: TOtherDevices;
  idstr: string;
  br: boolean;
begin
  LeaveLogMsg('TMyFlowAquireThread.Execute: started');
  //TSemaphore             //tthread
  while not Terminated do
    begin
    d0 := Now();
    if (DevicesSynchro=nil) or (cmdsynchro=nil) or (datasynchro=nil) or (comsynchro=nil) then
      begin
        LeaveLogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        sleep(10000);
        continue;
      end;
    if MySuspend then  //I want to hold the Aquire - but suspend does have some side effects and termitate cannot be easily restarted
    begin
      sleep(100);      //TODO: not very elegant - future - use maybe event waitfor...
      continue;
    end;
    //walk through active device of one type - for each type active devices are defined in devicessynchro (+its IDstring):
    //   beginread; read next device from devicesynchro and get its stringID, end read; polldevice;  continue;...
    cnt := 0;
    it := 0;
    while getNextDev(it, vdev, idstr) do
      begin
        if not comSend('GET '+idstr,  replystr, CTCPTimeoutMS) then LeaveLogMsg('EEE com error when processing dev ' + idstr);
        procDev( vdev, idstr, replystr);
        Inc(cnt);
      end;
    it := 0;
    while getNextDev(it, tdev, idstr) do
      begin
        if not comSend('GET '+idstr,  replystr, CTCPTimeoutMS) then LeaveLogMsg('EEE com error when processing dev ' + idstr);
        procDev( tdev, idstr, replystr);
        Inc(cnt);
      end;
    it := 0;
    while getNextDev(it, psdev, idstr) do
      begin
        if not comSend('GET '+idstr,  replystr, CTCPTimeoutMS) then LeaveLogMsg('EEE com error when processing dev ' + idstr);
        procDev( psdev, idstr, replystr);
        Inc(cnt);
      end;
    it := 0;
    while getNextDev(it, prdev, idstr) do
      begin
        if not comSend('GET '+idstr,  replystr, CTCPTimeoutMS) then LeaveLogMsg('EEE com error when processing dev ' + idstr);
        procDev( prdev, idstr, replystr);
        Inc(cnt);
      end;
    while getNextDev(it, odev, idstr) do
      begin
        if not comSend('GET '+idstr,  replystr, CTCPTimeoutMS) then LeaveLogMsg('EEE com error when processing dev ' + idstr);
        procDev( odev, idstr, replystr);
        Inc(cnt);
      end;
    //
    if fDebug then LeaveLogMsg('Thread execute Iter - iterated devices: ' + IntToStr(cnt));
    //cheack if there are any commands in queue and do them...
    //
    it := 0;
    while getNextCmd(cmd) do
        begin
          //MakeCmdDone( cmd );
        end;
    //
    //
    i := DateTimeToMS( TimeDeltaNow( d0 ) );
    if i>CReportLagThreshold then logmsg('TMyAquireThread.Execute:  READ AND DoCMD TOOK TOO LONG: (ms)' + IntToStr(i) );
    if i<CTargetCycleTimeMS then sleep(CTargetCycleTimeMS-i);  //some sleep or something - only if whole process took less than NNN ms
    //check big lag and report!!!

    end; //root while not Terminated do
  //
  LeaveLogMsg('TMyFlowAquireThread.Execute: Finished!!! EXECUTE ');
end;






function TMyAquireThread.getNextDev(Var it: longint; Var dev: TValveDevices; Var idstr: string): boolean;
//iterator as reference!!! do not forget to increase it!!!
//if result true then there was next device with index it - and its parameters are assigned to vdev & idstr
Var
  n: longint;
begin
  Result := false;
  DevicesSynchro.BeginRead;
    n := Length( DevicesSynchro.ValveDevs );
    if (n<=0) or (it>n-1) then
      begin
        DevicesSynchro.EndRead;
        exit;    //do not forget unlock!
      end;
    dev := DevicesSynchro.ValveDevs[it];
    idstr :=  DevicesSynchro.IdStrValvedev[ dev ];
    it := it + 1; //!!! increase iterator
  DevicesSynchro.EndRead;
  Result := true;
end;

function TMyAquireThread.getNextDev(Var it: longint; Var dev: TTempDevices; Var idstr: string): boolean;
//iterator as reference!!! do not forget to increase it!!!
//if result true then there was next device with index it - and its parameters are assigned to vdev & idstr
Var
  n: longint;
begin
  Result := false;
  DevicesSynchro.BeginRead;
    n := Length( DevicesSynchro.TempDevs );
    if (n<=0) or (it>n-1) then
      begin
        DevicesSynchro.EndRead;
        exit;    //do not forget unlock!
      end;
    dev := DevicesSynchro.TempDevs[it];
    idstr :=  DevicesSynchro.IdStrTempdev[ dev ];
    it := it + 1; //!!! increase iterator
  DevicesSynchro.EndRead;
  Result := true;
end;

function TMyAquireThread.getNextDev(Var it: longint; Var dev: TPressureSensDevices; Var idstr: string): boolean;
//iterator as reference!!! do not forget to increase it!!!
//if result true then there was next device with index it - and its parameters are assigned to vdev & idstr
Var
  n: longint;
begin
  Result := false;
  DevicesSynchro.BeginRead;
    n := Length( DevicesSynchro.PressSensDevs );
    if (n<=0) or (it>n-1) then
      begin
        DevicesSynchro.EndRead;
        exit;    //do not forget unlock!
      end;
    dev := DevicesSynchro.PressSensDevs[it];
    idstr :=  DevicesSynchro.IdStrPressSensdev[ dev ];
    it := it + 1; //!!! increase iterator
  DevicesSynchro.EndRead;
  Result := true;
end;

function TMyAquireThread.getNextDev(Var it: longint; Var dev: TPressureRegDevices; Var idstr: string): boolean;
//iterator as reference!!! do not forget to increase it!!!
//if result true then there was next device with index it - and its parameters are assigned to vdev & idstr
Var
  n: longint;
begin
  Result := false;
  DevicesSynchro.BeginRead;
    n := Length( DevicesSynchro.PressRegDevs );
    if (n<=0) or (it>n-1) then
      begin
        DevicesSynchro.EndRead;
        exit;    //do not forget unlock!
      end;
    dev := DevicesSynchro.PressRegDevs[it];
    idstr :=  DevicesSynchro.IdStrPressRegdev[ dev ];
    it := it + 1; //!!! increase iterator
  DevicesSynchro.EndRead;
  Result := true;
end;

function TMyAquireThread.getNextDev(Var it: longint; Var dev: TOtherDevices; Var idstr: string): boolean;
//iterator as reference!!! do not forget to increase it!!!
//if result true then there was next device with index it - and its parameters are assigned to vdev & idstr
Var
  n: longint;
begin
  Result := false;
  DevicesSynchro.BeginRead;
    n := Length( DevicesSynchro.OtherDevs );
    if (n<=0) or (it>n-1) then
      begin
        DevicesSynchro.EndRead;
        exit;    //do not forget unlock!
      end;
    dev := DevicesSynchro.OtherDevs[it];
    idstr :=  DevicesSynchro.IdStrOtherdev[ dev ];
    it := it + 1; //!!! increase iterator
  DevicesSynchro.EndRead;
  Result := true;
end;
      //


function TMyAquireThread.parseReplyStr1Dbl(idstr: string; replystr: string; Var val: double): boolean;
Var
  b: boolean;
  toklist: TTokenList; //dynamic array
  retid: string;
begin
  Result := false;
  val := NaN;
  //parse reply
  ParseStrSimple(replystr, toklist);
  //expecting reply '<idstr> <val>' = 2 tokens
  b := false;
  if length(toklist) >= 2 then
    begin
       b := true;
       //check the id match
      retid := toklist[0].s;
      if retid <> idstr then b := false;
      //convert numbers
      //NEED to use fFormatSettings to be independent on system settings!!!!!
      try
        val := StrToFloatDef(toklist[1].s, NaN , fFormatSettings);
      except
        b := false;
      end;
    end;
  Result := b;
end;


function TMyAquireThread.parseReplyStr1Int(idstr: string; replystr: string; Var val: longint): boolean;
Var
  b: boolean;
  toklist: TTokenList; //dynamic array
  retid: string;
begin
  Result := false;
  val := Low(longint);
  //parse reply
  ParseStrSimple(replystr, toklist);
  //expecting reply '<idstr> <val>' = 2 tokens
  b := false;
  if length(toklist) >= 2 then
    begin
       b := true;
       //check the id match
      retid := toklist[0].s;
      if retid <> idstr then b := false;
      //convert numbers
      //NEED to use fFormatSettings to be independent on system settings!!!!!
      try
        val := StrToIntDef(toklist[1].s, Low(longint));
      except
        b := false;
      end;
    end;
  Result := b;
end;


function TMyAquireThread.procDev(dev: TValveDevices; idstr: string; replystr: string): boolean;
Var
  b: boolean;
  vali: longint;
  vstate: TValveState;
begin
  Result := false;
  //parse reply
  b := parseReplyStr1Int( idstr, replystr, vali);
  if b then
    begin  //store into datasynchro
       if vali<>0 then vstate := CStateOpen
       else vstate := CStateClosed;
    end
  else
    begin
      LeaveLogMsg('EEE process reply failed for ' + idstr);
      vstate := CStateUndefined;
    end;
  datasynchro.BeginWrite;
         datasynchro.dataV[ dev ].timestamp := Now;
         datasynchro.dataV[ dev ].state := vstate;
  datasynchro.EndWrite;
  Result := b;
end;

function TMyAquireThread.procDev(dev: TTempDevices; idstr: string; replystr: string): boolean;
Var
  b: boolean;
  vald: double;
begin
  Result := false;
  //parse reply
  b := parseReplyStr1Dbl( idstr, replystr, vald);
  if not b then
    begin
      vald := NaN;
      LeaveLogMsg('EEE process reply failed for ' + idstr);
    end;
  datasynchro.BeginWrite;
         datasynchro.dataT[ dev ].timestamp := Now;
         datasynchro.dataT[ dev ].temp := vald;
  datasynchro.EndWrite;
  Result := b;
end;


function TMyAquireThread.procDev(dev: TPressureSensDevices; idstr: string; replystr: string): boolean;
Var
  b: boolean;
  vald: double;
begin
  Result := false;
  //parse reply
  b := parseReplyStr1Dbl( idstr, replystr, vald);
  if not b then
    begin
      vald := NaN;
      LeaveLogMsg('EEE process reply failed for ' + idstr);
    end;
  datasynchro.BeginWrite;
         datasynchro.dataPSens[ dev ].timestamp := Now;
         datasynchro.dataPSens[ dev ].pressure := vald;
  datasynchro.EndWrite;
  Result := b;
end;


function TMyAquireThread.procDev(dev: TPressureRegDevices; idstr: string; replystr: string): boolean;
Var
  b: boolean;
  vald: double;
begin
  Result := false;
  //parse reply
  b := parseReplyStr1Dbl( idstr, replystr, vald);
  if not b then
    begin
      vald := NaN;
      LeaveLogMsg('EEE process reply failed for ' + idstr);
    end;
  datasynchro.BeginWrite;
         datasynchro.dataPReg[ dev ].timestamp := Now;
         datasynchro.dataPReg[ dev ].readback := vald;
  datasynchro.EndWrite;
  Result := b;
end;

function TMyAquireThread.procDev(dev: TOtherDevices; idstr: string; replystr: string): boolean;
Var
  b: boolean;
  vali: longint;
  vstate: TValveState;
begin
  Result := false;
  //parse reply
  b := parseReplyStr1Int( idstr, replystr, vali);
  if b then
    begin  //store into datasynchro
       if vali<>0 then vstate := CStateOpen
       else vstate := CStateClosed;
    end;
  if not b then
    begin
      LeaveLogMsg('EEE process reply failed for ' + idstr);
      vstate := CStateUndefined;
    end;
  datasynchro.BeginWrite;
         datasynchro.dataO[ dev ].timestamp := Now;
         datasynchro.dataO[ dev ].state := vstate;
  datasynchro.EndWrite;
  Result := b;
end;
      //


function TMyAquireThread.getNextCmd(Var cmd: TVTPCmdArrayRec): boolean;
begin
  Result := false;
  cmdsynchro.BeginRead;
    Result := cmdsynchro.PopCmd( cmd );
  cmdsynchro.EndRead;
end;






{

function TMyFlowAquireThread.MakeCmdDone( cmd: TFlowCmdArrayRec ): string;
Var
  com: TComPort;
  msg: string;
  b: boolean;
  toklist: TTokenList;
  d1, d2, d3, d4, d5: double;
  w: word;
  devid, gas: string;
  frec: TFlowRec;
  s, s2: string;

begin
  Result := '';
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: addr: ' + cmd.addr );
  //generate msg based on cmd
  case cmd.t of
    CFlowCmdSetSP:
      begin
        if cmd.paramb then  //compatibilty mode - cmd is like "A 64000"   parametr is int fom 0..64000
          begin
            //integer val is stored in parami
            w := cmd.parami;  //this conversion to word type will make sure it has correct ragne
            s := ' ' + IntToStr(w);
          end
        else    //new mode cmd is like "AS9.9"   parametr is actual value as float
          begin
            s := 'S' + FloatToStr( cmd.paramd , fFormatSettings);
          end;
        msg := cmd.addr + s + #13;
      end;
    CFlowCmdUserCmd:
      begin
        s := cmd.params + '';  //force copy
        msg := s + #13;
        LeaveLogMsg('Alicat USER CMD: ' + BinStrToPrintStr(s) );
      end;
    CFlowCmdSetGas:
      begin
        s := IntToStr( cmd.parami );
        msg := cmd.addr + '$$' + s + #13;
      end;
  end;
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: sending cmd: ' + BinStrToPrintStr(msg) );
  b := comSendLowLvl( msg );
  // wait for reply !!! but do not process
  ActivelyWaitForReply(500);
  s2 := ExtractReply(rxbuf);
  if fDebug then LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: reply "'+ BinStrToPrintStr( s2 ) + '"' );
  if cmd.t = CFlowCmdUserCmd then
    begin
      LeaveLogMsg('Alicat USER CMD reply: "' + BinStrToPrintStr(s2) + '"' );
      //store data into datasynchro      flowdatasynchro
      flowdatasynchro.BeginWrite;
        flowdatasynchro.aswerlowlvl := s2;
      flowdatasynchro.EndWrite;
      if Assigned( cmd.responsemethod ) then cmd.responsemethod; //let know the main thread about result
    end;
  Result := s2;
end;

}

function TMyAquireThread.comSend(cmd: string; Var answer: string; toutms: longword): boolean;
//basic comm - sends and receives answer
//!!! do not use inside critical/locked section - needs to process messages - may dead lock
Var
  com: TTCPClient;        //TTCPIPCLient
  e, timeout: boolean;
  n: longint;
begin
  Result := false;
  if comsynchro=nil then exit;
  com := comsynchro.fTCPClient;
  if com=nil then exit;  //do not forget to unlock
  //send
  comsynchro.BeginWrite;
  if Com.Connected then
    begin
     e := true;
     n := Com.Sendln(cmd, #13);  //terminating string is <CR> only
     //LeaveLogMsg('TMyFlowAquireThread.comSend: SendLn ' + IntToStr(n) );
    end
  else
    begin
      e := false;
      LeaveLogMsg('EEEE TMyFlowAquireThread.comSend: Com: NOT CONNECTED' );
    end;
  comsynchro.EndWrite;
  //wait for reply
  answer := '';
  rxbuf := '';
  timeout := true;
  if e then
    begin
      timeout := ActivelyWaitForReply( toutms );    //com.Receiveln()
      if not timeout then answer := ExtractReply( rxbuf );  //removes <CR> et the end
    end;
  rxbuf := '';
  Result := e and timeout;
end;



procedure TMyAquireThread.ComOnReceive(Sender: TObject; Buf: pchar; var DataLen: integer);
//this is the event handler for receiving data on TTCPClient!!!
Var
 i, n, o: integer;
 s: string;
 com: TTCPClient;
 marklock: boolean;
begin
  if comsynchro=nil then exit;
  com := comsynchro.fTCPClient;
  if com=nil then exit;
  if fDebug then  LeaveLogMsg('TTT ComRxChar: n=' + IntToStr( DataLen));
  //synchro
  s := '';
  marklock := false;
  if not fSynchroLockedByWait then
   begin
     marklock := true;
     comsynchro.BeginWrite;
   end;
    //read chars into internal buffer
    n := DataLen;
    CopyPcharToStr( s, Buf, DataLen);
  //!!unlock if necessary
  if marklock then comsynchro.EndWrite;
  //store
  rxbuf := rxbuf + s;
  //check if message is completed - stop condition
  if IsEndOfPacket then
    //end of line found, signal event
    begin
      //rxPacketEnd.SetEvent;    //DOES NOT WORK SOMEHOW - use of single evnet FREEZES PROGRAM
    end;
end;


function TMyAquireThread.IsEndOfPacket: boolean;
Const
  CMarkEnd = #13;
begin
  Result := False;
  if length(rxbuf)=0 then exit;
  if Pos(CMarkEnd, rxbuf)>0 then Result := true else Result := false;
end;


procedure TMyAquireThread.MyThreadProcessMessages;
var
  Msg: TMsg;
begin
      while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
end;

function TMyAquireThread.ActivelyWaitForReply(timeoutx: longword): boolean; //if timeout return false
Var
  d, d0: TDateTime;
  tout: boolean;
begin
  Result := false;
  d0 := Now();
  d := d0 + timeoutx/3600/24/1000;
  //lock access to comport
  if fSynchroLockedByWait then exit; //shoudl not ever happen
  if comsynchro=nil then exit;

  fSynchroLockedByWait := true;
  comsynchro.BeginWrite;
    //!!! mark that the port is locked
  tout := true;
  while d>Now() do
  begin
    //need to process received messages from system, because that is the way how this implementation of serial port works!!!
    //but should not use ApplicationProcessMessages inside a thread -> so I use my own loop fro processing
    //found here:  http://stackoverflow.com/questions/15467263/how-do-i-forcibly-process-messages-inside-a-thread (Remy Lebeau)
    MyThreadProcessMessages;
    if IsEndOfPacket then
      begin
        if fDebug then   LeaveLogMsg('iiii TTTT TMyFlowAquireThread.ActivelyWaitForReply: got pakcet in(ms):'+ DateTimeMStoStr( TimeDeltaNow(d0)) );
        tout := false;
        Result := true;
        break;
      end;
  end;
  comsynchro.EndWrite;
  fSynchroLockedByWait := false;
  if tout then LeaveLogMsg('WWWW ActivelyWaitForReply: TIMEOUT!! ('+ IntToStr(timeoutx) +')');
end;                                                                       //WaitForSingleObject


function TMyAquireThread.ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
Const
  CMarkEnd = #13;
Var
  i: longword;
  tmp: string;
begin
  Result := '';
  i := Pos(CMarkEnd, buf);
  if fDebug then LeaveLogMsg('ExtractReply: pos end i=' + IntToStr( i ) + ' / in buf total: ' + IntToStr( Length(buf) ) );
  if i>0 then
    begin
      Result := Copy(buf, 0 , i-1);
      //delete used part
      tmp := Copy(buf, i+1 , Length(buf));  //REMOVE ALSO MarkEND (#13)!!!
      buf := tmp;
      //reset event
      //rxPacketEnd.ResetEvent;
      //now recheck for another packet end;
      //if Pos(CMarkEnd, buf)>0 then  rxPacketEnd.SetEvent;
    end;
end;








procedure TMyAquireThread.IncErrCnt; //does no begin/end write - expect it will be called only internally
begin
  if comsynchro=nil then exit;
  comsynchro.BeginWrite;
    comsynchro.comerrcnt := comsynchro.comerrcnt + 1;
  comsynchro.EndWrite;
end;


procedure TMyAquireThread.IncOKCnt;  //does no begin/end write
begin
  if comsynchro=nil then exit;
  comsynchro.BeginWrite;
    comsynchro.comokcnt := comsynchro.comokcnt + 1;
  comsynchro.EndWrite;
end;




//****************************
//        control object
//****************************


constructor TVTPControl_TCP_FCSControl.Create;
begin
  inherited;
  fName := CInterfaceVer;
  fDummy := false;
  comsynchro := TTCPClientThreadSafe.Create;
  AquireThread := TMyAquireThread.Create;
  if AquireThread<>nil then AquireThread.AssignComSynchro(comsynchro);
  fready := false;
  logmsg('TAlicatFlowControl.Create: done.');
end;


destructor TVTPControl_TCP_FCSControl.Destroy;
begin
  fready := false;
  // unreg variables references inside configmanager (but not destroy!!)
  if fConfigManager<>nil then
    begin
      fConfigManager.UnregAllWithId( fConfManagerId );
    end;
  //aquirethread
  if AquireThread<>nil then
    begin
      AquireThread.Terminate;
      //!!! wait to terminate
      while (not AquireThread.Terminated) do sleep(20);
    end;
  AquireThread.Destroy;
  //terminate comport
  if comsynchro<>nil then
    begin
         if comsynchro.fTCPClient<> nil then comsynchro.fTCPClient.Disconnect;
    end;
  comsynchro.Destroy;
  inherited;
end;


//**************
//basic control functions
//---------------------




function TVTPControl_TCP_FCSControl.Initialize: boolean;
Var
  b: boolean;
begin
  Result := false;
 // fsetp[CFlowAnode] := 0;   //CFlowAnode, CFlowCathode, CFlowN2, CFlowRes

  // port
  if not isComConnected() then
    begin
      logmsg('TAlicatFlowControl.Initialize: Com is NOT open - try open');
      try
        b := OpenCom();
      except
        on E:exception do begin logerror('Initialize: Com open - exception: ' + E.message); end;
      end;
      if not b then
        begin
          logmsg('Initialize: open FAILED -> exit');
          exit;
        end;
    end;
  ThreadStart;
  if not IsThreadRunning then
        begin
          logmsg('TVTPControl_TCP_FCSControl.Initialize: Thread is NOT running -> exit');
          exit;
        end;
  //reset last aquire time
  //ResetLastAquireTime;
  //
  fUserCmdReplyIsNew := false;
  fready := true;
  Result := true;
  logmsg('TVTPControl_TCP_FCSControl.Initialize: Connected to TCPIP client to FCSCOntrol!!!' );
  logmsg('             .... Iface ver str: ' + CInterfaceVer );
end;


procedure TVTPControl_TCP_FCSControl.Finalize;
begin
  logmsg('TAlicatFlowControl.Finalize: Stopping thread...!!!' );
  ThreadStop;
  fready  := false;
end;


procedure TVTPControl_TCP_FCSControl.ResetConnection;
//close port, open port - this should help it seems
Var
  client: TTCPClient;
Const
  CThisMod = 'TVTPControl_TCP_FCSControl.ResetConnection';
begin
  logmsg(CThisMod + ': Closing and opening PORT!!!' );
//  CloseComPort;
//  Sleep(500);
//  //!!!!!!!!!!!!!!  FUJ FUJ
//  Application.ProcessMessages;   //tapplication
//  OpenComPort;
  if comsynchro=nil then
    begin
      logerror(CThisMod + ':  comportsynchro=nil');
      exit;
    end;
  client := comsynchro.fTCPClient;
  if client=nil then
    begin
      LogError(CThisMod + ': client=nil');
      exit;
    end;
  comsynchro.BeginWrite;
    client.Disconnect;
    client.Connect;
  comsynchro.EndWrite;
end;

{
function TVTPControl_TCP_FCSControl.Aquire(Var data: TFlowData; Var status: TFlowStatus): boolean;
//
Var
  d: TFlowDevices;
  TSdata: TFlowDataThreadSafe;
  lastaq : tDateTime;
begin
  Result := false;
  InitFlowStatusWithNAN(data);
  if not fReady then exit;
  if AquireThread=nil then exit;
  TSdata := AquireThread.flowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    for d := Low(TFlowDevices) to High(TFlowDevices) do
      begin
        if fdevarray[d].enabled then data[d] := TSdata.stats[d]
        else
          begin
            InitFlowRecWithNAN( data[d]);  //for disabled devices, fill NAN
            Include(data[d].flagSet, CFlowDevDisabled);
          end;
      end;
    lastaq := TSdata.fLastSuccessAquireTime;
  TSdata.EndRead;
  // check for communication connection lost
  status.CommFlagSet := [];
  if TimeDeltaNowMS( lastaq ) > CFlowTimeoutConstMS then  Include(status.CommFlagSet, CFlowConnectionLost);
  Result := true;
end;
}


function TVTPControl_TCP_FCSControl.AquireValve(Var data: TValveData): boolean;
begin
  Result := false;
end;

function TVTPControl_TCP_FCSControl.AquireTemp(Var data: TTempData): boolean;
begin
  Result := false;
end;

function TVTPControl_TCP_FCSControl.AquirePressureSens(Var data: TPressureSensData): boolean;
begin
  Result := false;
end;

function TVTPControl_TCP_FCSControl.AquirePressureReg(Var data: TPressureRegData): boolean;
begin
  Result := false;
end;

function TVTPControl_TCP_FCSControl.AquireOther(Var data: TOtherDevData ): boolean;
begin
  Result := false;
end;

function TVTPControl_TCP_FCSControl.SetSetpPressureReg(dev: TFlowDevices; val: double): boolean;
begin
  Result := false;
end;

function TVTPControl_TCP_FCSControl.GetRangePressureSens(dev: TFlowDevices): TRangeRecord;
begin
  Result.low := NaN;
end;

function TVTPControl_TCP_FCSControl.GetRangePressureReg(dev: TFlowDevices): TRangeRecord;
begin
  Result.low := NaN;
end;

function TVTPControl_TCP_FCSControl.AquireStatus(Var status: TVTPStatus): boolean;
begin
  Result := false;
end;

{
function TAlicatFlowControl.SetSetp(dev: TFlowDevices; val: double): boolean;
Var
  min, max, oldv: double;
  cmdsync: TCmdQueueThreadSafe;
  b: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
  altsp: word;
Const
  epsilon = 0.01;
begin
   Result := false;
   oldv := val;
   min := fdevarray[dev].minSccm;
   max := fdevarray[dev].maxSccm;
   if fDebug then logmsg('TAlicatFlowControl.SetSetp: dev ' + FlowDevToStr(dev) + ' sp: ' + FloatToStr(val) + ' (min: ' + FloatToStr(min) + ',max: ' + FloatToStr(max) + ') compatmode: ' + BoolToStr( fSetpCompatibMode ) );
   if not MakeSureIsInRange(val, min-epsilon, max+epsilon) then LogWarning('TAlicatFlowControl.SetSetp:  setpoint outside allowed range - ADJUSTING!!!! (from ' + FloatToStr(oldv) +' to ' + FloatToStr(val) +')');
   //calculate compatibility setpoin value (it is in relative value from 0 to 64000 related to maxvalue  fo flow => depends on device range
   try
     altsp := Trunc( val/max*64000 );
   except
     altsp := 0;
     logerror('TAlicatFlowControl.SetSetp: altsp exception!');
   end;
   //prepare cmd
   cmdrec.addr := fdevarray[dev].addr;
   cmdrec.t := CFlowCmdSetSP;
   cmdrec.paramd := val;
   cmdrec.parami := altsp;
   cmdrec.paramb := false;
   if fSetpCompatibMode then cmdrec.paramb := true;  //mark compatibility mode
   cmdrec.responsemethod := nil;
   //enqueue new command into aquire thread
   if AquireThread=nil then
     begin
       logmsg('TAlicatFlowControl.SetSetp AquireThread=nil ');
       exit;
     end;
   cmdsync := AquireThread.cmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      if not cmdsync.CanAdd() then logmsg('eeee TAlicatFlowControl.SetSetp cannot add CMD to CMDsynchro');
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if fDebug then logmsg('iiii TAlicatFlowControl.SetSetp - addded cmd, total waiting now: '+ IntToStr(nw) );
   if b then
     begin
       fsetp[dev] := val;
       Result := true;
     end;
end;


function TAlicatFlowControl.SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  b: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
  thisid: string;
begin
   Result := false;
   thisid := 'TAlicatFlowControl.SetGas';
   if fDebug then logmsg(thisid + ': dev ' + FlowDevToStr(dev) + ' sp: ' + FlowGasTypeToStr(gas) );
   //prepare cmd
   cmdrec.addr := fdevarray[dev].addr;
   cmdrec.t := CFlowCmdSetGas;
   cmdrec.parami := AlicatGasTypeToAlicatGasId(gas);
   cmdrec.responsemethod := nil;
   if gas=CGasUnknown then
     begin
       logwarning(thisid + ': invalid argument of gas ID');
       exit;
     end;
   //enqueue new command into aquire thread
   if AquireThread=nil then
     begin
       logmsg(thisid + ': AquireThread=nil ');
       exit;
     end;
   cmdsync := AquireThread.cmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      if not cmdsync.CanAdd() then logmsg(thisid + ': eeee cannot add CMD to CMDsynchro');
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if fDebug then logmsg(thisid + ': iii addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;
end;
}

{
function TAlicatFlowControl.GetRange(dev: TFlowDevices): TRangeRecord;
begin
  Result.low := fdevarray[dev].minSccm;
  Result.high := fdevarray[dev].maxSccm;
end;
}


procedure TVTPControl_TCP_FCSControl.setDebug(b: boolean);
begin
  fDebug := b;
  if AquireThread<>nil then AquireThread.Debug := b;
end;



procedure TVTPControl_TCP_FCSControl.ResetLastAquireTime;
Var
  TSdata: TVTPDataThreadSafe;
  lastaq : tDateTime;
begin
  if AquireThread=nil then exit;
  TSdata := AquireThread.datasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    TSdata.fLastSuccessAquireTime := Now;
  TSdata.EndRead;
end;





procedure TVTPControl_TCP_FCSControl.SetupCom(host: string; port: string); //TCPIP
Var
  client : TTcpClient;
Const
  CThisM = 'TVTPControl_TCP_FCSControl.SetupCom';
begin
  if comsynchro=nil then
    begin
      logerror(CThisM  + ':  comportsynchro=nil');
      exit;
    end;
  client := comsynchro.fTCPClient;

    if client<>nil then
      begin
        comsynchro.BeginWrite;
          client.RemoteHost := host;
          client.RemotePort := port;
        comsynchro.EndWrite;
      end
    else
      begin
        logerror(CThisM  + ':  com=nil ');
        exit;
      end;
  logmsg(CThisM  + ':  new config= ' + host + ' port=' + port );
  //ShowMessage('comport conf change');
end;





function TVTPControl_TCP_FCSControl.isComConnected(): boolean;
Var
  client: TTCPClient;
begin
  Result := False;
  if comsynchro=nil then exit;
  client := comsynchro.fTCPClient;
  if client=nil then exit;
  comsynchro.BeginRead;
    Result := client.Connected;
  comsynchro.EndRead;
end;


function TVTPControl_TCP_FCSControl.OpenCom(): boolean;
Var
  client: TTCPClient;
begin
  Result := False;
  if comsynchro=nil then
    begin
      logerror('TVTPControl_TCP_FCSControl.OpenPort():  comportsynchro=nil');
      exit;
    end;
  client := comsynchro.fTCPClient;
  if client=nil then
    begin
      LogError('TVTPControl_TCP_FCSControl..OpenPort(): comport=nil');
      exit;
    end;
  comsynchro.BeginWrite;
    client.Connect;
    Result := client.Connected;
  comsynchro.EndWrite;
end;


procedure TVTPControl_TCP_FCSControl.CloseCom;
Var
  client: TTCPClient;
begin
  if comsynchro=nil then exit;
  client := comsynchro.fTCPClient;
  if client=nil then
    begin
      LogError('TVTPControl_TCP_FCSControl.ClosePort: comport=nil');
      exit;
    end;
  comsynchro.BeginWrite;
    client.Disconnect;
  comsynchro.EndWrite;
  CheckSynchronize(1);
  logmsg('TVTPControl_TCP_FCSControl. ClosePort - PORT CLOSED');
end;


{
procedure TVTPControl_TCP_FCSControl.getComPortConf;
Var
  com: TComPort;
begin
  if comportsynchro=nil then exit;
  com := comsynchro.ComPort;
  if com=nil then exit;
  comsynchro.BeginRead;
    fComPortName := com.Port;
    fComPortBR := BaudRateToStr( Com.BaudRate ) ;
    fComPortStopBits := StopBitsToStr( Com.StopBits );
    fComPortDataBits := DataBitsToStr( Com.DataBits );
    fComPortParity := ParityToStr( Com.Parity.Bits );
    fComPortFlowCtrl := FlowControlToStr( Com.FlowControl.FlowControl );
  comsynchro.EndRead;
end;

procedure TVTPControl_TCP_FCSControl.setComPortConf;
Var
  com: TComPort;
begin
  if comportsynchro=nil then exit;
  com := comsynchro.ComPort;
  if com=nil then exit;
  comsynchro.BeginWrite;
    com.Port := fComPortName;
    com.BaudRate := StrToBaudRate(fComPortBR);
    com.StopBits := StrToStopBits(fComPortStopBits);
    com.DataBits := StrToDataBits(fComPortDataBits);
    com.Parity.Bits := StrToParity(fComPortParity);
    com.FlowControl.FlowControl := StrToFlowControl( fComPortFlowCtrl );
  comsynchro.EndWrite;
end;


}

function TVTPControl_TCP_FCSControl.getErrCount(): longint;
begin
  Result := -1;
{  if comportsynchro=nil then exit;
  comsynchro.BeginRead;
  Result :=  comsynchro.comerrcnt;
  comsynchro.EndRead; }
end;


function TVTPControl_TCP_FCSControl.getOKCount(): longint;
begin
  Result := -1;
{  if comportsynchro=nil then exit;
  comsynchro.BeginRead;
  Result :=  comsynchro.comokcnt;
  comsynchro.EndRead;   }
end;

procedure TVTPControl_TCP_FCSControl.resetErrOKCounters;
begin
{  if comportsynchro=nil then exit;
  comsynchro.BeginWrite;
  comsynchro.comokcnt := 0;
  comsynchro.comerrcnt := 0;
  comsynchro.EndWrite; }
end;



procedure TVTPControl_TCP_FCSControl.ThreadStart;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling RESUME');
  AquireThread.MySuspend := false;
  AquireThread.Resume;     //TThread  //in case it was suspended
end;


procedure TVTPControl_TCP_FCSControl.ThreadStop;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling SUSPEND');
  //AquireThread.Suspend;  //apparently can freeze if supsended in middle of communication
  //AquireThread.Terminate;   //cannot be restarted
  AquireThread.MySuspend := true;
end;


function TVTPControl_TCP_FCSControl.IsThreadRunning(): boolean;
begin
  Result := false;
  if AquireThread = nil then exit;
  if (not AquireThread.Terminated) and (not AquireThread.Suspended) and (not AquireThread.MySuspend) then Result := true;
end;

function TVTPControl_TCP_FCSControl.getThreadStatus: string;
begin
  Result := 'NIL';
  if AquireThread = nil then exit;
  if AquireThread.Suspended then Result := 'Suspended';
  if AquireThread.Terminated then Result := 'Terminated';
  if (AquireThread.Terminated) and (AquireThread.Suspended) then Result := 'Suspended+Terminated';
  if (not AquireThread.Terminated) and (not AquireThread.Suspended) then Result := 'Running...';
  if AquireThread.MySuspend then Result := Result + '/NoAquire';
end;



procedure TVTPControl_TCP_FCSControl.UpdateDevicesInThread;
Var
  devsync: TVTPDevicesListThreadSafe;
  d: TFlowDevices;
begin
  if AquireThread = nil then exit;
  {
  devsync := AquireThread.devicessynchro;
  if devsync = nil then exit;
  devsync.BeginWrite;
    devsync.ClearAll;
    for d:= low(TFlowDevices) to High(TFlowDevices) do
      begin
        if fdevarray[d].enabled then devsync.AddDev(d, fdevarray[d].addr );
      end;
  devsync.EndWrite;   }
end;


function TVTPControl_TCP_FCSControl.GetNDevsInThread: byte;
Var
  devsync: TVTPDevicesListThreadSafe;
begin
  Result := 0;
  {
    if AquireThread = nil then exit;
  devsync := AquireThread.devicessynchro;
  if devsync = nil then exit;
  devsync.BeginRead;
    Result := devsync.GetNDev;
  devsync.EndRead;       }
end;


function TVTPControl_TCP_FCSControl.SendUserCmd(cmd: string): boolean;
Var
  cmdsync: TVTPCmdQueueThreadSafe;
  b: boolean;
  cmdrec: TVTPCmdArrayRec;
  nw: word;
begin
   Result := false;  {
   if fDebug then logmsg('TAlicatFlowControl.SendUserCmd: ' + BinaryStrTostring(cmd) );
   //prepare cmd
   cmdrec.t := CFlowCmdUserCmd;
   cmdrec.params := cmd  + '';
   cmdrec.responsemethod := ReceiveReplyFromThread;
   //enqueue new command into aquire thread
   if AquireThread=nil then
     begin
       logmsg('TAlicatFlowControl.SetSetp AquireThread=nil ');
       exit;
     end;
   cmdsync := AquireThread.cmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      if not cmdsync.CanAdd() then logmsg('eeee TAlicatFlowControl.SetSetp cannot add CMD to CMDsynchro');
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if fDebug then logmsg('iiii TAlicatFlowControl.SetSetp - addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;       }
end;


procedure TVTPControl_TCP_FCSControl.ReceiveReplyFromThread;       //reads reply from data.aswerlowlvl
//
Var
  copys : string;
  TSdata: TVTPDataThreadSafe;
begin
  if AquireThread=nil then exit;  {
  TSdata := AquireThread.flowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    copys := TSdata.aswerlowlvl + '';      //!!!!!!!!!! necessary to copy, not just assign reference - to be sure
  TSdata.BeginRead;
  logmsg('TAlicatFlowControl.ReceiveReplyFromThread str=' + BinStrToPrintStr( copys));
  fUserCmdReplyS := copys;
  fUserCmdReplyTime := Now;
  fUserCmdReplyIsNew := true;      }
end;

{procedure TVTPControl_TCP_FCSControl.UpdateDev(dev: TFlowDevices; en: boolean; a: char; rngmin, rngmax: double);
begin
  with fdevarray[ dev ] do
    begin
      enabled := en;
      addr := a;
      minsccm := rngmin;
      maxsccm := rngmax;
    end;
end;}

procedure TVTPControl_TCP_FCSControl.UpdateDev(dev: TTempDevices; en: boolean; rngmin, rngmax: double);
begin
end;


procedure TVTPControl_TCP_FCSControl.UpdateDev(dev: TValveDevices; en: boolean);
begin
end;


procedure TVTPControl_TCP_FCSControl.UpdateDev(dev: TPressureSensDevices; en: boolean; rngmin, rngmax: double);
begin
end;

procedure TVTPControl_TCP_FCSControl.UpdateDev(dev: TPressureRegDevices; en: boolean; rngmin, rngmax: double);
begin
end;

procedure TVTPControl_TCP_FCSControl.UpdateDev(dev: TOtherDevices; en: boolean);
begin
end;




procedure TVTPControl_TCP_FCSControl.AssignConfigManager( Var cm: TLoadSaveConfigManager );  //use this to partially automate storing/loading of configuration from PTC control form
Var
  Section: string;
begin
  fConfigManager := cm;
  if cm=nil then exit;
  fConfManagerId := cm.genNewID;
  //config
  //Assign variables to be loaded/saved
{  Section := 'AlicatRS232_Parameters';
  cm.RegVariableBool(fConfManagerId, @(fSetpCompatibMode), 'SetpCompatibMode', false, Section );
  //  comport
  Section := 'AlicatRS232_Config_ComPort';
  cm.RegVariableStr(fConfManagerId, @(fComPortName), 'PortName', 'COM2', Section );
  cm.RegVariableStr(fConfManagerId, @(fComPortBR), 'BaudRate', '19200', Section );
  cm.RegVariableStr(fConfManagerId, @(fComPortDataBits), 'DataBits', '8', Section );
  cm.RegVariableStr(fConfManagerId, @(fComPortStopBits), 'StopBits', '1', Section );
  cm.RegVariableStr(fConfManagerId, @(fComPortParity), 'Parity', 'None', Section );
  cm.RegVariableStr(fConfManagerId, @(fComPortFlowCtrl), 'FlowControl', 'None', Section );     }
end;


procedure TVTPControl_TCP_FCSControl.DoAfterConfLoad; //process values after load process of config manager registered variables
begin
 // setComPortConf;
end;


procedure TVTPControl_TCP_FCSControl.DoBeforeSavingConf;
begin
  //getComPortConf;
end;

//****************************************************



constructor TTCPClientThreadSafe.Create;
begin
  inherited;
  fTCPClient := TTCPCLient.Create(nil);
  //assign onRx event handler
  if fTCPClient<>nil then fTCPClient.OnReceive := nil;
end;

destructor TTCPClientThreadSafe.Destroy;
begin
  fTCPClient.Destroy;
  inherited;
end;


//****************************************************



constructor TVTPDataThreadSafe.Create;
Var
  d: TFlowDevices;
begin
  inherited;
 { for d := Low(TFlowDevices) to High(TFlowDevices) do
      begin
        InitFlowRecWithNAN( stats[d] );
      end;      }
  fLastSuccessAquireTime := Now();     
end;

destructor TVTPDataThreadSafe.Destroy;
begin
  inherited;
end;

//****************************************************


constructor TVTPCmdQueueThreadSafe.Create;
Const
  CDefaultCmdArraySize = 100;
begin
  inherited;
  Asize := CDefaultCmdArraySize;
  setLength( cmdArray, CDefaultCmdArraySize );
  strtpos := 0;
  endpos := 0; //strpos == endpos =-> empty
end;


destructor TVTPCmdQueueThreadSafe.Destroy;
begin
  Asize := 0;
  setLength( cmdArray, 0 );
  inherited;
end;

function TVTPCmdQueueThreadSafe.PopCmd(Var cmdrec: TVTPCmdArrayRec): boolean;
begin
  Result := false;
  cmdrec.t := CVTPCmdUNDEF;
  if strtpos=endpos then exit;  //meaning array is empty
  cmdrec := cmdArray[strtpos];
  Inc( strtpos );
  if strtpos >= Asize then strtpos := 0;
  Result := true;
end;

function TVTPCmdQueueThreadSafe.nWaiting(): word;  //if >0 then there is  work and can use pop
begin
  if endpos>=strtpos then Result := endpos - strtpos
  else Result := Asize - (strtpos - endpos);
end;

function TVTPCmdQueueThreadSafe.AddCmd(cmd: TVTPCmdArrayRec): boolean;
begin
  Result := false;
  if not CanAdd then exit;
  cmdArray[ endpos ] := cmd;
  Inc(endpos);
  if endpos>=Asize then endpos := 0;
  Result := true;
end;

function TVTPCmdQueueThreadSafe.CanAdd(): boolean; // if there is space for new cmd
begin
  Result := false;
  if nWaiting<(Asize-1) then Result := true;  //the useful maximum capacity is Asize-1 (at full, one index is unsued)
end;

//****************************************************

constructor TVTPDevicesListThreadSafe.Create;
begin
  inherited;
  setlength( TempDevs, 0 );
  setlength( ValveDevs, 0 );
  setlength( PressSensDevs, 0 );
  setlength( PressRegDevs, 0 );
  setlength( OtherDevs, 0 );
end;


destructor TVTPDevicesListThreadSafe.Destroy;
begin
  ClearAll;
  inherited;
end;

procedure TVTPDevicesListThreadSafe.ClearAll;
begin
  setlength( TempDevs, 0 );
  setlength( ValveDevs, 0 );
  setlength( PressSensDevs, 0 );
  setlength( PressRegDevs, 0 );
  setlength( OtherDevs, 0 );
end;

procedure TVTPDevicesListThreadSafe.AddDev(dev: TTempDevices);
Var n: integer;
begin
  n := Length( TempDevs );
  setlength( TempDevs, n + 1);
  TempDevs[n] := dev;
end;

procedure TVTPDevicesListThreadSafe.AddDev(dev: TValveDevices);
Var n: integer;
begin
  n := Length( ValveDevs );
  setlength( ValveDevs, n + 1);
  ValveDevs[n] := dev;
end;

procedure TVTPDevicesListThreadSafe.AddDev(dev: TPressureSensDevices);
Var n: integer;
begin
  n := Length( PressSensDevs );
  setlength( PressSensDevs, n + 1);
  PressSensDevs[n] := dev;
end;

procedure TVTPDevicesListThreadSafe.AddDev(dev: TPressureRegDevices);
Var n: integer;
begin
  n := Length( PressRegDevs );
  setlength( PressRegDevs, n + 1);
  PressRegDevs[n] := dev;
end;

procedure TVTPDevicesListThreadSafe.AddDev(dev: TOtherDevices);
Var n: integer;
begin
  n := Length( OtherDevs );
  setlength( OtherDevs, n + 1);
  OtherDevs[n] := dev;
end;


function TVTPDevicesListThreadSafe.GetDev(Var dev: TTempDevices; i: byte): boolean;
//returns true if OK
Var n: integer;
begin
  Result := false;
  n := Length( TempDevs );
  if (i<0) or (i>=n) then exit;
  dev := TempDevs[i];
  Result := true;
end;

function TVTPDevicesListThreadSafe.GetDev(Var dev: TValveDevices; i: byte): boolean;
Var n: integer;
begin
  Result := false;
  n := Length( ValveDevs );
  if (i<0) or (i>=n) then exit;
  dev :=  ValveDevs[i];
  Result := true;
end;

function TVTPDevicesListThreadSafe.GetDev(Var dev: TPressureSensDevices; i: byte): boolean;
Var n: integer;
begin
  Result := false;
  n := Length( PressSensDevs );
  if (i<0) or (i>=n) then exit;
  dev := PressSensDevs[i];
  Result := true;
end;

function TVTPDevicesListThreadSafe.GetDev(Var dev: TPressureRegDevices; i: byte): boolean;
Var n: integer;
begin
  Result := false;
  n := Length( PressRegDevs );
  if (i<0) or (i>=n) then exit;
  dev := PressRegDevs[i];
  Result := true;
end;


function TVTPDevicesListThreadSafe.GetDev(Var dev: TOtherDevices; i: byte): boolean;
Var n: integer;
begin
  Result := false;
  n := Length( OtherDevs );
  if (i<0) or (i>=n) then exit;
  dev := OtherDevs[i];
  Result := true;
end;


//****************************************************


function FCSControlTCP_PressSensDev_ToStrId( dev: TPressureSensDevices  ): string;
begin
  Result := 'xxx';
end;








end.

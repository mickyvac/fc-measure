unit VTPInterface_TCPIP_FCScontrol;

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs, StrUtils,
  myutils, ParseUtils, Logger, ConfigManager, MyLockableObject,
  HWAbstractDevicesNew2, MyAquireThreadPrototype,  sockets;

//http://stackoverflow.com/questions/5530038/how-to-handle-received-data-in-the-tcpclient-delphi-indy

Const
  CInterfaceVer = 'TCPIP client 2016-02-24';

  CNotRespCount = 5;
  CComTimeoutConstMS = 10000;
  CReportLagThreshold = 2000;

  CVTPdataMaxAgeMS = 100000;

  CLockWaitMax = 10000;

  CThreadIdStr = 'VTP';

Type

  //flow commands

  TVTPCmdType = (CVTPCmdUNDEF, CVTPCmdSetVarInt, CVTPCmdSetVarDbl, CVTPCmdUser);

  TSynchroMethodId = procedure(cmdid: longint; result: boolean) of object;

  TVTPDataThreadSafe = class (TMyLockableObject)   //for reporting data back
  public
    constructor Create;
    destructor Destroy; override;
  public
    dataV: TValveData;
    dataS: TSensorData;
    dataR: TRegData;
    fLastSuccessAquireTime: TDateTime;
    fLastAquireDurMS: longint;
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
    function AddCmd(cmd: TVTPCmdArrayRec): boolean;  //the cmd is copied
    function CanAdd(): boolean; // if there is space for new cmd
  end;
  //    cmdwaiting: boolean;  //signal by main thread that new cmd is ready - will be cleared by sub-thread after processing during "synchro reading"


  TDevType = (CDevUndef, CDevValve, CDevSens, CDevReg);

  TDeviceBaseRec = record
      idstr: string;
      name: string;
      unitStr: string;
      enabled: boolean;
      id: longint; //position in the alldata array, assigned when device added; for crossreference
  end;

  TVTPDeviceBase = class
  public
      baserec: TDeviceBaseRec;
      dtype: TDevType;
      function ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean; virtual; abstract;
        //process reply from server according to device format
      function GetLastValStr(Var ds: TVTPDataThreadSafe): string; virtual; abstract;
        //to quick get last known value (read from datasynchro)
  end;


  TDevSensorParamRec = record
    min: double;   //limits are for warning purposes only
    max: double;
    flagOutOfLimit: boolean;
  end;

  TDevValveParamRec = record
  end;

  TDevRegParamRec = record   //used for Pressures Regulators includes last known setpoint
    min: double;
    max: double;
    flagOutOfLimit: boolean;
  end;



 TVTPDeviceSensor = class ( TVTPDeviceBase )
  public
    constructor create(_dev: TSensorDevices; _idstr: string; _name: string; _enabled: boolean);
  public
    param: TDevSensorParamRec;
    fDev: TSensorDevices;  //need this to store the data to the right place
    function ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean; override;
    function GetLastValStr(Var ds: TVTPDataThreadSafe): string; override;
  end;


 TVTPDeviceValve = class ( TVTPDeviceBase )
  public
    constructor create(_dev: TValveDevices; _idstr: string; _name: string; _enabled: boolean);
  public
    param: TDevValveParamRec;
    fDev: TValveDevices;  //need this to store the data to the right place
    function ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean; override;
    function GetLastValStr(Var ds: TVTPDataThreadSafe): string; override;
  end;


 TVTPDeviceReg = class ( TVTPDeviceBase )
  public
    constructor create(_dev: TRegDevices; _idstr: string; _name: string; _enabled: boolean);
  public
    param: TDevRegParamRec;
    fDev: TRegDevices;  //need this to store the data to the right place
    //
    function ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean; override;
    function GetLastValStr(Var ds: TVTPDataThreadSafe): string; override;
    //
    function CreateSetpointCmd(val: double): string;
  end;




  TVTPDevicesListThreadSafe = class (TMyLockableObject)     //for devices to iterare over    //TThreadList
  public
    constructor Create;
    destructor Destroy; override;
    procedure AssignThreadPtr(_threadptr: TAquireThreadCommonAncestor);
  public
    AllDevices: array of TVTPDeviceBase;   //all devices - used for polling and control, when not want to distinguish between types
    //alias arrays - just to have distinguished access to each device type
    ValveDevices: array[TValveDevices] of TVTPDeviceValve;
    SensorDevices: array[TSensorDevices] of TVTPDeviceSensor;
    RegDevices: array[TRegDevices] of TVTPDeviceReg;

  public
    procedure ClearDevices;
    procedure AddDevice( devobj: TVTPDeviceBase ); //object must created outside, but is destroyed from the synchro
    function GetDevice(i:longint): TVTPDeviceBase; //if valid return pointer to device ancestor or NIL
    function FindDevByStr( devstr: string ): TVTPDeviceBase;
  private
    threadptr: TAquireThreadCommonAncestor;
  end;


  TMyAquireThread = class (TTCPAquireThreadBase)       //TMultiReadExclusiveWriteSynchronizer.
    public
      constructor Create;
      procedure BeforeDestroy; override;
      destructor Destroy; override;
    public
      cmdsynchro: TVTPCmdQueueThreadSafe; //controls access to cmd queue and variables
                                          //after finishig, signal can be sent through assigned method
      datasynchro: TVTPDataThreadSafe;  //from here the data can be read anytime - cached buffer
                                         //!!!but still use beginread ... and endread methods to access)
                                         //the latest data should be there, expecting refresh interval every 500ms or so
      devicessynchro: TVTPDevicesListThreadSafe;  //over this assigned devices will be iterated aquire
    public
      procedure Execute; override;
      function IsEndOfMessage(Const recvbuf: string): boolean; override;  //descendadnt must define this for communication to work
    private
      //data are fetched from arrays in datasynchro
      //only devices, that are ENABLED are processed - if not enabled false is returned,
      //function procDev(dev: TVTPDeviceBase): boolean;
      function procDev(baserec: TDeviceBaseRec): boolean;
      function ProcSingleReply( str: string): boolean;
      //
      function getNextCmd(Var cmd: TVTPCmdArrayRec): boolean;
      //
      function MakeCmdDone( cmd: TVTPCmdArrayRec ): boolean;
    private
      function CheckDevEnabled( en: boolean; idstr: string): boolean;  //helper
      function SendDevQuery( idstr: string; Var reply: string): boolean; //helper
    private
      rxbuf: string;
      fFormatSettings: TFormatSettings;
      frefreshint: longint;
      fTCPTimeoutMS: longint;
      fNDevsProcessed: word;
      fLastCycleFInishTime: TDateTime;
      fLastCycleRunMS: longint;
    public
      //statistic - read only - do not have care about locking, update every execute cyclus
      property NDevsProcessed: word read fNDevsProcessed;
      property LastCycleFinishTime: TDateTime read fLastCycleFInishTime;
      property LastCycleRunMS: longint read fLastCycleRunMS;
  end;



  TVTPControl_TCP_FCSControl = class (TVTPControllerObject)
    //this obejct controls one serial port with up to N Alicat flow controllers attached
    //it uses another thread to poll for data on regular basis
    public
      constructor Create;
      destructor Destroy; override;
      procedure createDevObjects;
    public
    //inherited virtual functions - must override!
      function Initialize: boolean; override;
      procedure Finalize; override;
      procedure ResetConnection; override;
      //basic control functions
      function Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean; override;
      function GetFlags(): TCommDevFlagSet; override;
      function SetRegSetp(dev: TRegDevices; val: double): boolean; override;
      function GetRange(dev: TSensorDevices): TRangeRecord; overload; override;
      function GetRange(dev: TRegDevices): TRangeRecord; overload; override;
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
    public
      //TCPIP Client/ Com operation, configuratio
      function OpenCom(timeoutMS: longint = 4000): boolean;
      procedure CloseCom;
      procedure SetupCom(host: string; port: string); //TCPIP
      procedure GetComConf(Var srv, prt: string);
      function isComConnected(): boolean;
      function getErrCount(): longint;
      function getOKCount(): longint;
      procedure resetErrOKCounters;
      //others---
      procedure LoadConfig;
      procedure SaveConfig;
      //function Ping(): boolean; //try some simple command to check response
    public
      //user command
      fUserCmdReplyS: string;
      fUserCmdReplyTime: TDateTime;
      fUserCmdReplyIsNew: boolean;
      //other
    public
      //thread control
      procedure ThreadStart(timeoutMS: longint = 500);
      procedure ThreadStop;
      function IsThreadRunning(): boolean;
      function getThreadStatus: string;
      procedure SetUserSuspend;
      procedure ResetUserSuspend;
      procedure UpdateDevicesInThread;
      function GetNDevsInThread(): word;
      function getLastAquireTime(): TDateTime;
      function SendUserCmd(cmd: string): boolean;
      procedure ReceiveReplyFromThread(cmdid: longint; result: boolean);    //"event handler" - reads reply from data.aswerlowlvl when beeing called using synchronize from thread
    public
    public
      //gets device parameters from the devicesynchro
      //function getBaseDevParamById(i: longint; Var baseRec: TDeviceBaseRec);  overload; //general - but for only the base access
      function getBaseDevParamById(i: longint; Var baseRec: TDeviceBaseRec; Var valstr: string): boolean;  overload;
        //if no device with id of i then return false
      function getBaseDevCount: longint;
      //device type specific
      procedure getDevParam(dev: TValveDevices; Var ParRec: TDevValveParamRec; Var baseRec: TDeviceBaseRec); overload;
      procedure getDevParam(dev: TSensorDevices; Var ParRec: TDevSensorParamRec; Var baseRec: TDeviceBaseRec); overload;
      procedure getDevParam(dev: TRegDevices; Var ParRec: TDevRegParamRec; Var baseRec: TDeviceBaseRec); overload;
      //updates ...
      procedure setBaseDevParamById(i: longint; Var baseRec: TDeviceBaseRec);  //general - but for only the base access
      //device type specific
      procedure setDevParam(dev: TValveDevices; Var ParRec: TDevValveParamRec; Var baseRec: TDeviceBaseRec); overload;
      procedure setDevParam(dev: TSensorDevices; Var ParRec: TDevSensorParamRec; Var baseRec: TDeviceBaseRec); overload;
      procedure setDevParam(dev: TRegDevices; Var ParRec: TDevRegParamRec; Var baseRec: TDeviceBaseRec); overload;

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
      function GetDeviceSynchro(Var ds: TVTPDevicesListThreadSafe): boolean; //checks for nNIL and assigns pointer - if ok returns True
      function GetDataSynchro(Var datas: TVTPDataThreadSafe):  boolean; //checks for nNIL and assigns pointer - if ok returns True
      procedure ResetLastAquireTime;
      //procedure leavemsg(s: string); //log msg and set return msg
    //*************************
  public
//    function PressureConnect(port:string; baud: longint): boolean;  virtual; abstract;
//    procedure PressureDisconnect; virtual; abstract;
  end;



//---------------------------------------
//helper, conversion functions



function VTPDefDevIdStr( dev: TValveDevices ): string; overload;
function VTPDefDevIdStr( dev: TSensorDevices ): string; overload;
function VTPDefDevIdStr( dev: TRegDevices ): string; overload;


//processing communication strigns from KolTCP Server
function parseReplyStr1Dbl(idstr: string; replystr: string; Var val: double; Var fs: TFormatSettings): boolean;
function parseReplyStr1Int(idstr: string; replystr: string; Var val: longint; Var fs: TFormatSettings): boolean;
function ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)


procedure FillNaN(Var Rec: TDeviceBaseRec); overload;
procedure FillNaN(Var ParRec: TDevValveParamRec); overload;
procedure FillNaN(Var ParRec: TDevSensorParamRec); overload;
procedure FillNaN(Var ParRec: TDevRegParamRec); overload;



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
  inherited; //createsuspended=true
  fThreadId := 'VTP';
  cmdsynchro := TVTPCmdQueueThreadSafe.Create;
  datasynchro := TVTPDataThreadSafe.Create;
  devicessynchro := TVTPDevicesListThreadSafe.Create;
  //
  rxbuf := '';
  fTCPTimeoutMS := 2000;
  GetLocaleFormatSettings(0, fFormatSettings );    //TFormatSettings
  //define "." as deciaml separator
  fFormatSettings.DecimalSeparator := '.';
  LeaveLogMsg('Create: done.');
end;

procedure TMyAquireThread.BeforeDestroy;
begin
  devicessynchro.Destroy;
  datasynchro.Destroy;
  cmdsynchro.Destroy;
  inherited;
end;

destructor  TMyAquireThread.Destroy;
begin
  inherited;
end;


procedure TMyAquireThread.Execute;
Const
  CTargetCycleTimeMS = 500;
  //send msg
  CTCPTimeoutMS = 2000;
Var
  //nv, nt, nps, npr, no: byte;
  ntotal, nen: longint;
  b1, b2,bs, didlock: boolean;
  replystr: string;
  cmd: TVTPCmdArrayRec;
  //d0: TDateTime;
  i, it, err: longint;
  devbase: TVTPDeviceBase;
  baserec: TDeviceBaseRec;
  time0: longword;
  bigcmd, bigreply, idcmdstr, replyid, replydata: string;
  idcmd: longword;
  //replylist: TStringList; //key-value pars  idstr=valstr
  toklist: TTokenList;
begin
  idcmd := 1000;
  // replylist := TStringList.Create;
  SetLength(toklist, 0);
  if fDebug then LeaveLogMsg('execute started');
  //
  while not Terminated do
    begin
    if (DevicesSynchro=nil) or (cmdsynchro=nil) or (datasynchro=nil) then
      begin
        LeaveLogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        sleep(10000);
        continue;
      end;
    ///!!!! CHECK Communication configuration requests (neccesary to work - defined in ancestor
    /// also checks and handles the user-suspend request!!!!
    //LeaveLogMsg('before proc req');
    //
    CheckAndProcessRequests;
    //fTCPConnected := com.Connected;
    //
    //if not isComConnected then continue;
    //
    //walk through active device of one type - for each type active devices are defined in devicessynchro (+its IDstring):
    //   beginread; read next device from devicesynchro and get its stringID, end read; polldevice;  continue;...
    //
    time0 := TimeDeltaTICKgetT0;      //d0 := Now();

    //new 2016-04-20  prepare one large command to get  data for all devices
{
UdÏlal jsem to hromadnÈ posÌl·nÌ p¯Ìkaz˘ pro server FcsControl.
Nakonec bylo nejjednoduööÌ udÏlat to nejobecnÏji tak, ûe se d· zadat vÌce p¯Ìkaz˘, takûe form·t packetu je teÔ
[#ID] <cmd1>; <cmd2>; ...

M˘ûeö tedy mÌchat get i set v jednom. A v˝sledek si prvnÏ rozparsujeö podle st¯ednÌku (jeötÏ p¯ed tÌm u¯Ìzneö p¯ÌpadnÈ ID) a potom ¯eöÌö kaûd˝ zvl·öù
P¯Ìklad:
#123 get FC1; get TC2; set MSwCtrl 1; get TC7; echo
#123 read FC1 1.1; read TC2 -4.341; read MSwCtrl 1; read TC7 NAN; echo

to read v odpovÏdi vûdy vracÌ p¯eËtenou hodnotu, ne tu, cos poslal. Pokud nap¯. s ventilem nejde hnout a d·ö set 1, vr·tÌ ti 0.
Jinak jsem dodÏl·val, ûe by mÏlo fungovat NAN jako leg·lnÌ hodnota pro ËtenÌ i z·pis, ale kdyby to nÏkde spadlo, tak dej vÏdÏt.
}

    //CHECK AND PROCESS COMMANDS queue
    while getNextCmd(cmd) do
        begin
          MakeCmdDone( cmd );
        end;


    Inc(idcmd);
    idcmdstr := '#' + IntToStr( idcmd );
	  bigcmd := idcmdstr + ' ';
		
        if fDebug then LeaveLogMsg('execute - START it: ' + IntToStr(idcmd));

        if fDebug then LeaveLogMsg('execute - walk devs');
    devicessynchro.LockTimeout(didlock, CLockWaitMax );
          if not didlock then
            begin
             LeaveLogMsg('execute - skipped(no lock): ' + IntToStr(it));
             continue;
            end;
        ntotal := Length( devicessynchro.AllDevices );
        nen := 0;
        for it := 0 to ntotal-1 do
          begin
            devbase := devicessynchro.GetDevice(it);
            if devbase=nil then continue;
            baserec := devbase.baserec;
            if not baserec.enabled then continue;
            Inc(nen);
            bigcmd := bigcmd + 'GET ' + baserec.idstr + ';';
          end;
    devicessynchro.UnLock(didlock);
       if fDebug then LeaveLogMsg( ' got enabled devices count:  ' + IntToStr(nen));
      //
      bigcmd := bigcmd + #13#10;
      //send big cmd;
     if fDebug then LeaveLogMsg( '  polling devices; id ' + idcmdstr + ' bigcmd= ' + bigcmd);
     //
     bs := SendReceive(bigcmd, bigreply, fTCPTimeoutMS);
     //
     if fDebug then LeaveLogMsg( '  reply ' + bigreply);
     //
     if not bs then
       begin
         LeaveLogMsg('query failed! - skipping this round ' + idcmdstr);
         continue;
       end;

     //check reply id      pos    leftstr   midstr
     i := posex(' ', bigreply, 1);  //space after idstr
     if i<1 then
       begin
         LeaveLogMsg('idstr not found! - skipping this round ' + idcmdstr);
         continue;
       end;
     replydata := RightStr(bigreply, Length(bigreply)-i);
     replyid := leftstr( bigreply, i - 1 );
     if replyid<>idcmdstr then
       begin
         LeaveLogMsg('idstr NOT MATCH! - skipping this round ' + idcmdstr);
         continue;
       end;
     if fDebug then  LeaveLogMsg('   so far ok, idstr match!, going for parse');
     //
     //parse response       rightstr
     b1 := ParseStrSep( replydata, ';', toklist );
     if fDebug then  LeaveLogMsg( '  tokenlist: ' + TokenListToStr( toklist ) );
     //walk toklist, fill tstringlist with key-val pairs
     //idstr=response
     if Length(toklist)<1 then continue;
     //replylist.Clear;
     err := 0;
     b2 := true;
     it := 0;
     for i:=0 to Length(toklist)-1 do
       begin
         if not ProcSingleReply( toklist[i].s ) then begin
           Inc(err);
           LeaveLogMsg('  ProcSingleReply: failed - str was: ' + toklist[i].s);
           end
           else Inc(it);
       end;
    //
    fNDevsProcessed := it;
    if fDebug then LeaveLogMsg('execute - iterated devices: ' + IntToStr(it) + ' processing errors: ' + IntToStr( err));
    //cheack if there are any commands in queue and do them...
    //

    //
    fLastCycleFinishTime := Now();
    fLastCycleRunMS := TimeDeltaTICKNowMS( time0 );
    //
    if fLastCycleRunMS>CReportLagThreshold then logmsg('TMyAquireThread.Execute:  READ AND DoCMD TOOK TOO LONG: (ms)' + IntToStr(fLastCycleRunMS) );
    if fLastCycleRunMS<CTargetCycleTimeMS then sleep(CTargetCycleTimeMS-fLastCycleRunMS);  //some sleep or something - only if whole process took less than NNN ms
    //check big lag and report!!!
    end; //root while not Terminated do
  //
  LeaveLogMsg('TMyFlowAquireThread.Execute: Finished!!! EXECUTE ');
end;


function TMyAquireThread.ProcSingleReply( str: string): boolean;
Var
  singletoklist: TTokenList;
  b1, b2, b3: boolean;
  devidstr: string;
  valstr: string;
  basedev: TVTPDeviceBase;
  didlock: boolean;
begin
  Result := false;
  SetLength( singletoklist, 0);
  b1 := ParseStrSep( MyTrim(str), ' ', singletoklist );
  if fDebug then LeaveLogMsg('  ProcSingleReply:toklist= ' + TokenListToStr(singletoklist) );
  if Length(singletoklist)<3 then begin
    if fDebug then LeaveLogMsg('  E: Length(singletoklist)<3');
    exit;
    end;
  if LowerCase( singletoklist[0].s )<>'read' then begin
    if fDebug then LeaveLogMsg('  E: <>read');
    exit;
    end;
  devidstr := singletoklist[1].s;
  valstr := singletoklist[2].s;
  //
  basedev := devicessynchro.FindDevByStr( devidstr );
  if basedev = nil then begin
     LeaveLogMsg('   ProcSingleReply FindDevByStr -> nil for: ' + devidstr);
     exit;
     end;
  if fDebug then LeaveLogMsg('preocdev so far good - go for procreply');
  devicessynchro.LockTimeout(didlock, CLockWaitMax);
     Result := basedev.ProcReply( valstr, datasynchro, fFormatSettings );
  devicessynchro.UnLock(didlock);
  if not Result then LeaveLogMsg('   ProcSingleReply procdev -> failed');
end;

function TMyAquireThread.CheckDevEnabled( en: boolean; idstr: string): boolean;
//helper - checks if enabled, return enabled state, if not enabled, log message
begin
  Result := en;
  if not en then if fDebug then LeaveLogMsg('procDev: dev not enabled ' + IdStr);
end;

function TMyAquireThread.SendDevQuery( idstr: string; Var reply: string): boolean;
//helper - checks if enabled, return enabled state, if not enabled, log message
Var
  msg: string;
begin
  Result := false;
  //send msg
  msg := 'GET ' + IdStr + #13#10;
  Result := SendReceive(msg,  reply, fTCPTimeoutMS);
  if not Result then LeaveLogMsg('SendDevQuery: Query failed for dev ' + IdStr);
end;



function TMyAquireThread.procDev(baserec: TDeviceBaseRec): boolean;
//function TMyAquireThread.procDev(dev: TVTPDeviceBase): boolean;
//only devices, that are ENABLED are processed - if not enabled false is returned
Var
  idstr, reply: string;
  bs, b, en: boolean;
  ddev: TVTPDeviceBase;
  didlock: boolean;
begin
  Result := false;
  idstr := baserec.idstr;
  en := baserec.enabled;
  //check enabled
  if not CheckDevEnabled(en, idstr) then
    begin
      Result := true;
      exit;
    end;
  //send msg
  bs := SendDevQuery(IdStr,  reply);
  if not bs then
    begin
      LeaveLogMsg('EEE sendquery failed for device ' + baserec.name + ' idstr ' + idstr);
    end;
  //process reply - by virtul function of device
  b := false;
  if bs then
    begin
      //get dev
      ddev := devicessynchro.GetDevice( baserec.id );
      if ddev=nil then
        begin
          LeaveLogMsg('procDev device=nil ' + baserec.name + ' idstr ' + idstr);
          exit;
        end;
      if fDebug then LeaveLogMsg('preocdev - go for procreply');
      devicessynchro.LockTimeout(didlock, CLockWaitMax);
        b := ddev.ProcReply( reply, datasynchro, fFormatSettings );
      devicessynchro.UnLock(didlock);
    end;
  if not b then
    begin
      LeaveLogMsg('EEE process reply failed for device ' + baserec.name + ' idstr ' + idstr);
    end;
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


function TMyAquireThread.MakeCmdDone( cmd: TVTPCmdArrayRec ): boolean;
Var
  msg, reply: string;
  b: boolean;
  w: word;
  s: string;
  //d0: TDateTime;
  time0: longword;
  deltaMS: longint;
  locked: boolean;
Const
  CCmdTimeoutMS = 2000;
begin
  Result := false;
  if fDebug or true then  LeaveLogMsg('TMyAquireThread.MakeCmdDone: cmd:  ' + IntToStr( Ord(cmd.t) ) ); // + cmd.params
  //generate msg based on cmd
  case cmd.t of
    CVTPCmdSetVarDbl:
      begin
        s := 'SET ' + cmd.varname + ' ' + FloatToStr( cmd.paramd , fFormatSettings);
      end;
    CVTPCmdSetVarInt:
      begin
        s := 'SET ' + cmd.varname + ' ' + IntToStr( cmd.parami );
      end;
    CVTPCmdUser:
      begin
        s := cmd.params + '';  //force copy
        LeaveLogMsg('USER CMD: ' + BinStrToPrintStr(s) );
      end;
  end; //case
  msg := s + #13#10;  //terminated bby <CR><LF>
  //
  //send
  time0 := TimeDeltaTICKgetT0; //d0 := Now;
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: sending cmd: "' + BinStrToPrintStr(msg)+ '"');
  b := SendReceive(msg, reply, CCmdTimeoutMS);
  if fDebug then LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: reply "'+ BinStrToPrintStr( reply ) + '"' );
  deltaMS := TimeDeltaTICKNowMS( time0 );
  //
  //process reply
  if cmd.t = CVTPCmdUser then
    begin
      //store data into datasynchro      flowdatasynchro
      LeaveLogMsg('USER CMD - timeMS: ' + IntToStr(deltaMS) +' reply: "' + BinStrToPrintStr(reply) + '"' );
      locked := datasynchro.LockTimeout( CLockWaitMax );
      if not locked then LeaveLogMsg('USER CMD lock obtain FAILED force write');
        datasynchro.aswerlowlvl := reply;
      if locked then datasynchro.UnLock;
      if Assigned( cmd.responsemethod ) then cmd.responsemethod( cmd.id, b); //let know the main thread about result
     end;
  //
  Result := b;
end;


function TMyAquireThread.IsEndOfMessage(Const recvbuf: string): boolean;
//descendadnt must define this for communication to work
Var
  l, p: longint;
begin
  //for comm with KolFCSControl Server the end is <CR><LF>
  Result := False;
  l := length(recvbuf);
  if l=0 then exit;
  try
    p := Pos(#13#10, recvbuf);
    if p>0 then Result := true;
  except
    Result := false;
  end;
end;








//****************************
//        control object
//****************************


constructor TVTPControl_TCP_FCSControl.Create;
begin
  inherited;
  fName := CInterfaceVer;
  fDummy := false;
  AquireThread := TMyAquireThread.Create;
  fready := false;
  //create aquire thread dev synchro device objects
  createDevObjects;
  if AquireThread<>nil then AquireThread.devicessynchro.AssignThreadPtr( AquireThread );
  logmsg('TVTPControl_TCP_FCSControl.Create: done.');
end;


destructor TVTPControl_TCP_FCSControl.Destroy;
Var
 i: integer;
begin
  if fReady then Finalize;
  fready := false;
  // unreg variables references inside configmanager (but not destroy!!)
  if fConfigManager<>nil then
    begin
      fConfigManager.UnregAllWithId( fConfManagerId );
    end;
  //aquirethread
  if AquireThread<> nil then
    begin
      AquireThread.SetUserSuspend;
      AquireThread.Terminate;
      //!!! wait to terminate
      i :=1000;
      while (not AquireThread.Terminated) do
        begin
          sleep(100);
          Dec(i);
          if i<1 then break; //force quit waiting if takes too long
        end;
      AquireThread.BeforeDestroy;
      AquireThread.Free; //AquireThread.Destroy;
      //ShowMessage('Here');
      //AquireThread.Free;  //instead of Destory call FREE!!! as is described in the help
                          //destroy causes program hang on exit;
                          //- now freeonterminate is set FALSE, so I need to call free!!!
    end;
  inherited;
end;



procedure TVTPControl_TCP_FCSControl.createDevObjects;
Var

  devV: TValveDevices;
  devS: TSensorDevices;
  devR: TRegDevices;
  objV: TVTPDeviceValve;
  objS: TVTPDeviceSensor;
  objR: TVTPDeviceReg;
  idstr, name: string;
  ds: TVTPDevicesListThreadSafe;
begin
  if AquireThread = nil then exit;
  ds := AquireThread.devicessynchro;
  if ds=nil then exit;
  //traverse all
  for devV := Low( TValveDevices) to high( TValveDevices) do
    begin
      idstr := VTPDefDevIdStr( devV );
      name := VTPDeviceToStr( devV );
      objV := TVTPDeviceValve.create(devV, idstr, name, false);
      ds.AddDevice( objV );
    end;
  for devS := Low( TSensorDevices) to high( TSensorDevices) do
    begin
      idstr := VTPDefDevIdStr( devS );
      name := VTPDeviceToStr( devS );
      objS := TVTPDeviceSensor.create(devS, idstr, name, false);
      ds.AddDevice( objS );
    end;
  for devR := Low( TRegDevices) to high( TRegDevices) do
    begin
      idstr := VTPDefDevIdStr( devR );
      name := VTPDeviceToStr( devR );
      objR := TVTPDeviceReg.create(devR, idstr, name, false);
      ds.AddDevice( objR );
    end;
end;



//**************
//basic control functions
//---------------------




function TVTPControl_TCP_FCSControl.Initialize: boolean;
Var
  b: boolean;
begin
  Result := false;
  ThreadStart;
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

  if not IsThreadRunning then
        begin
          logwarning('TVTPControl_TCP_FCSControl.Initialize: Thread is NOT running -> exit');
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
  fready  := false;
  if AquireThread = nil then exit;
  AquireThread.CloseCom;
  ThreadStop;
end;


procedure TVTPControl_TCP_FCSControl.ResetConnection;
//close port, open port - this should help it seems
Const
  CThisMod = 'TVTPControl_TCP_FCSControl.ResetConnection';
begin
  logmsg(CThisMod + ': Closing and opening PORT!!!' );
  if AquireThread=nil then exit;
  AquireThread.ResetConnection;
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


function TVTPControl_TCP_FCSControl.Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean;
Var
 dsync: TVTPDataThreadSafe;
 devV: TValveDevices;
 devS: TSensorDevices;
 devR:  TRegDevices;
 locked: boolean;
begin
  Result := false;
  InitWithNAN(datav);
  InitWithNAN(datas);
  InitWithNAN(datar);
  if not GetDataSynchro(dsync) then exit;
  locked := dsync.LockTimeout( CLockWaitMax );
     datav := dsync.dataV;
     datas := dsync.dataS;
     datar := dsync.dataR;
  if locked then dsync.unLock;
  Result := true;
end;

function TVTPControl_TCP_FCSControl.GetFlags(): TCommDevFlagSet;
begin
  Result := [];
end;

function TVTPControl_TCP_FCSControl.SetRegSetp(dev: TRegDevices; val: double): boolean;
Var
  devs: TVTPDevicesListThreadSafe;
  cmd: string;
begin
  Result := false;
  if not GetDeviceSynchro(devs) then exit;
  //MakeSureIsInRange(val, param.min, param.max);
  cmd := devs.RegDevices[dev].CreateSetpointCmd(val);
  Result := SendUserCmd(cmd);
end;

function TVTPControl_TCP_FCSControl.GetRange(dev: TSensorDevices): TRangeRecord;
begin
  InitWithNAN(Result);
end;

function TVTPControl_TCP_FCSControl.GetRange(dev: TRegDevices): TRangeRecord;
begin
  InitWithNAN(Result);
end;


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
  TSdata.Lock;
    TSdata.fLastSuccessAquireTime := Now;
  TSdata.UnLock;
end;





procedure TVTPControl_TCP_FCSControl.SetupCom(host: string; port: string); //TCPIP
Const
  CThisM = 'TVTPControl_TCP_FCSControl.SetupCom';
begin
  logmsg(CThisM + ': SetupCom!!!' );
  if AquireThread=nil then exit;
  AquireThread.ConfigureTCP( host, port);
  logmsg(CThisM  + ':  new config= ' + host + ' port=' + port );
end;

procedure TVTPControl_TCP_FCSControl.GetComConf(Var srv, prt: string);
begin
  if AquireThread=nil then exit;
  AquireThread.getTCPConf(srv, prt);
end;



function TVTPControl_TCP_FCSControl.isComConnected(): boolean;
begin
  Result := False;
  if AquireThread=nil then exit;
  Result := AquireThread.IsComConnected;
end;


function TVTPControl_TCP_FCSControl.OpenCom(timeoutMS: longint = 4000): boolean;
Var
  d0: longword;
begin
  Result := False;
  if AquireThread=nil then exit;
  logmsg('Trying OPenCom');
  AquireThread.OpenCom;  //this is non blocking request - will wait for timeout if sucess, if not call Close
  //(ccaling close will also solve problem, when open will wait undefinitely for not responding server)
  d0 := TimeDeltaTICKgetT0;
  while not AquireThread.isComConnected and (TimeDeltaTICKNowMS(d0)<timeoutMS) do
    begin
      Application.ProcessMessages;      //TODO: THIS MAY BE DANGEROUS!!!
    end;
  Result := AquireThread.isComConnected;
  If not Result then
    begin
      logError('TVTPControl_TCP_FCSControl.OpenCom(): Connection was NOT successful!!!!');
      AquireThread.ForcedClose;  //in case of timeout from server
    end;
end;


procedure TVTPControl_TCP_FCSControl.CloseCom;
begin
  if AquireThread=nil then exit;
  AquireThread.CloseCom;
end;



function TVTPControl_TCP_FCSControl.getErrCount(): longint;
begin
  Result := -1;
  if AquireThread=nil then exit;
  Result := AquireThread.comErrcnt;
end;


function TVTPControl_TCP_FCSControl.getOKCount(): longint;
begin
  Result := -1;
  if AquireThread=nil then exit;
  Result := AquireThread.comErrcnt;
end;

procedure TVTPControl_TCP_FCSControl.resetErrOKCounters;
begin
  if AquireThread=nil then exit;
  AquireThread.ResetCnts;
end;



procedure TVTPControl_TCP_FCSControl.ThreadStart(timeoutMS: longint = 500);
Var
  d0: longword;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling RESUME');
  AquireThread.Resume;     //TThread  //in case it was suspended
  ResetUserSuspend;
  //wait for thread to start
  d0 := TimeDeltaTICKgetT0;
  while (not AquireThread.IsThreadRunning) and (TimeDeltaTICKNowMS(d0)<timeoutMS) do
    begin
      //Application.ProcessMessages;      //TODO: THIS MAY BE DANGEROUS!!!
    end;
end;


procedure TVTPControl_TCP_FCSControl.ThreadStop;
begin
  if AquireThread = nil then exit;
  //Only use user suspend
  SetUserSuspend;
end;


function TVTPControl_TCP_FCSControl.IsThreadRunning(): boolean;
begin
  Result := false;
  if AquireThread = nil then exit;
  Result := AquireThread.IsThreadRunning;
end;

function TVTPControl_TCP_FCSControl.getThreadStatus: string;
begin
  Result := 'NIL';
  if AquireThread = nil then exit;
  Result := AquireThread.getThreadStatusStr;
end;

procedure TVTPControl_TCP_FCSControl.SetUserSuspend;
begin
  if AquireThread = nil then exit;
  AquireThread.SetUserSuspend;
end;

procedure TVTPControl_TCP_FCSControl.ResetUserSuspend;
begin
  if AquireThread = nil then exit;
  AquireThread.ResetUserSuspend;
end;

function TVTPControl_TCP_FCSControl.GetNDevsInThread: word;
begin
  Result := 0;
  if AquireThread = nil then exit;
  Result := AquireThread.NDevsProcessed;
end;


function TVTPControl_TCP_FCSControl.getLastAquireTime(): TDateTime;
begin
  Result := 0;
  if AquireThread = nil then exit;
  Result := AquireThread.LastCycleFinishTime;
end;


function TVTPControl_TCP_FCSControl.SendUserCmd(cmd: string): boolean;
Var
  cmdsync: TVTPCmdQueueThreadSafe;
  b: boolean;
  cmdrec: TVTPCmdArrayRec;
  nw: word;
begin
   Result := false;
   if fDebug or true then logmsg('SendUserCmd: ' + BinStrToPrintStr(cmd) );
   //prepare cmd
   cmdrec.t := CVTPCmdUser;
   cmdrec.params := cmd  + '';  //force copy
   cmdrec.responsemethod := ReceiveReplyFromThread;
   //enqueue new command into aquire thread
   if AquireThread=nil then
     begin
       logmsg('AquireThread=nil ');
       exit;
     end;
   cmdsync := AquireThread.cmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      if not cmdsync.CanAdd() then logmsg('eeee  cannot add CMD to CMDsynchro');
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if fDebug or true then logmsg('iiii addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;
end;


procedure TVTPControl_TCP_FCSControl.ReceiveReplyFromThread(cmdid: longint; result: boolean);       //reads reply from data.aswerlowlvl
//
Var
  copys : string;
  TSdata: TVTPDataThreadSafe;
begin
  logmsg('ReceiveReplyFromThread');
  if AquireThread=nil then exit;
  TSdata := AquireThread.datasynchro;
  if TSdata=nil then exit;
  TSdata.Lock;
    copys := TSdata.aswerlowlvl + '';      //!!!!!!!!!! necessary to copy, not just assign reference - to be sure
  TSdata.UnLock;
  logmsg('ReceiveReplyFromThread str=' + BinStrToPrintStr( copys));
  fUserCmdReplyS := copys;
  fUserCmdReplyTime := Now;
  fUserCmdReplyIsNew := true;
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



function TVTPControl_TCP_FCSControl.getBaseDevParamById(i: longint; Var baseRec: TDeviceBaseRec; Var valstr: string): boolean;
//gets device parameters from the devicesynchro
Var
  devs: TVTPDevicesListThreadSafe;
  dats: TVTPDataThreadSafe;
  dev: TVTPDeviceBase;
  didlock: boolean;
begin
  Result := false;
  FillNaN( BaseRec);
  if not GetDeviceSynchro(devs) then exit;
  if not GetDataSynchro(dats) then exit;
  devs.LockTimeout(didlock, CLockWaitMax);
    if not didlock then begin LogMsg('TVTPControl_TCP_FCSControl.getBaseDevParamById: obtain LOCK failed'); exit; end;
    dev := devs.GetDevice(i);
    if dev<>nil then
      begin
        baseRec := dev.baserec;
        valstr := dev.GetLastValStr( dats );
        Result := true;
      end;
  devs.UnLock(didlock);
end;

function TVTPControl_TCP_FCSControl.getBaseDevCount: longint;
//gets device parameters from the devicesynchro
Var
  devs: TVTPDevicesListThreadSafe;
begin
  Result := 0;
  if not GetDeviceSynchro(devs) then exit;
  Result := Length( devs.AllDevices );
end;



procedure TVTPControl_TCP_FCSControl.getDevParam(dev: TValveDevices; Var ParRec: TDevValveParamRec; Var baseRec: TDeviceBaseRec);
Var
  ds: TVTPDevicesListThreadSafe;
  obj: TVTPDeviceValve;
begin
  FillNaN( ParRec);
  FillNaN( BaseRec);
  if not GetDeviceSynchro(ds) then exit;
  obj := ds.ValveDevices[dev];
  if obj=nil then exit;
  ds.Lock;
    ParRec := obj.param;
    BaseRec := obj.baserec;
  ds.UnLock;
end;

procedure TVTPControl_TCP_FCSControl.getDevParam(dev: TSensorDevices; Var ParRec: TDevSensorParamRec; Var baseRec: TDeviceBaseRec);
Var
  ds: TVTPDevicesListThreadSafe;
  obj: TVTPDeviceSensor;
begin
  FillNaN( ParRec);
  FillNaN( BaseRec);
  if not GetDeviceSynchro(ds) then exit;
  obj := ds.SensorDevices[dev];
  if obj=nil then exit;
  ds.Lock;
    ParRec := obj.param;
    BaseRec := obj.baserec;
  ds.UnLock;
end;

procedure TVTPControl_TCP_FCSControl.getDevParam(dev: TRegDevices; Var ParRec: TDevRegParamRec; Var baseRec: TDeviceBaseRec);
Var
  ds: TVTPDevicesListThreadSafe;
  obj: TVTPDeviceReg;
begin
  FillNaN( ParRec);
  FillNaN( BaseRec);
  if not GetDeviceSynchro(ds) then exit;
  obj := ds.RegDevices[dev];
  if obj=nil then exit;
  ds.Lock;
    ParRec := obj.param;
    BaseRec := obj.baserec;
  ds.UnLock;
end;


//updates ...

procedure TVTPControl_TCP_FCSControl.setBaseDevParamById(i: longint; Var baseRec: TDeviceBaseRec);  //general - but for only the base access
Var
  ds: TVTPDevicesListThreadSafe;
  dev: TVTPDeviceBase;
  didlock: boolean;
begin
  if not GetDeviceSynchro(ds) then exit;
  ds.LockTimeout(didlock, CLockWaitMax);
    if not didlock then LogMsg('TVTPControl_TCP_FCSControl.setBaseDevParamById: obtain LOCK failed');
    dev := ds.GetDevice(i);
    if dev<>nil then dev.baserec := baseRec;
  ds.UnLock(didlock);
end;



procedure TVTPControl_TCP_FCSControl.setDevParam(dev: TValveDevices; Var ParRec: TDevValveParamRec; Var baseRec: TDeviceBaseRec);
Var
  ds: TVTPDevicesListThreadSafe;
  obj: TVTPDeviceValve;
begin
  if not GetDeviceSynchro(ds) then exit;
  obj := ds.ValveDevices[dev];
  if obj=nil then exit;
  ds.Lock;
    obj.param := ParRec;
    obj.baserec := baseRec;
  ds.UnLock;
end;

procedure TVTPControl_TCP_FCSControl.setDevParam(dev: TSensorDevices; Var ParRec: TDevSensorParamRec; Var baseRec: TDeviceBaseRec);
Var
  ds: TVTPDevicesListThreadSafe;
  obj: TVTPDeviceSensor;
begin
  if not GetDeviceSynchro(ds) then exit;
  obj := ds.SensorDevices[dev];
  if obj=nil then exit;
  ds.Lock;
    obj.param := ParRec;
    obj.baserec := baseRec;
  ds.UnLock;
end;

procedure TVTPControl_TCP_FCSControl.setDevParam(dev: TRegDevices; Var ParRec: TDevRegParamRec; Var baseRec: TDeviceBaseRec);
Var
  ds: TVTPDevicesListThreadSafe;
  obj: TVTPDeviceReg;
begin
  if not GetDeviceSynchro(ds) then exit;
  obj := ds.RegDevices[dev];
  if obj=nil then exit;
  ds.Lock;
    obj.param := ParRec;
    obj.baserec := baseRec;
  ds.UnLock;
end;





function TVTPControl_TCP_FCSControl.GetDeviceSynchro(Var ds: TVTPDevicesListThreadSafe): boolean;
//checks for nNIL and assigns pointer - if ok returns True
begin
  Result := false;
  ds := nil;
  if AquireThread=nil then exit;
  ds := AquireThread.devicessynchro;
  Result := ds<>nil;
end;

function TVTPControl_TCP_FCSControl.GetDataSynchro(Var datas: TVTPDataThreadSafe):  boolean; //checks for nNIL and assigns pointer - if ok returns True
//checks for nNIL and assigns pointer - if ok returns True
begin
  Result := false;
  datas := nil;
  if AquireThread=nil then exit;
  datas := AquireThread.datasynchro;
  Result := datas<>nil;
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


procedure TVTPControl_TCP_FCSControl.LoadConfig;
begin
end;

procedure TVTPControl_TCP_FCSControl.SaveConfig;
begin
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





constructor TVTPDataThreadSafe.Create;
Var
  d: TFlowDevices;
begin
  inherited create( 30000 ) ;
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
  inherited create(30000);
  //place nil in all aliases
  ClearDevices;
  threadptr := nil;
end;

destructor TVTPDevicesListThreadSafe.Destroy;
begin
  ClearDevices;
  inherited;
end;


procedure TVTPDevicesListThreadSafe.AssignThreadPtr(_threadptr: TAquireThreadCommonAncestor);
begin
  threadptr := _threadptr;
end;

procedure TVTPDevicesListThreadSafe.ClearDevices;
Var
  //devobj: TVTPDeviceBase;
  vdev: TValveDevices;
  sdev: TSensorDevices;
  rdev: TRegDevices;
  i: longint;
begin
  for i := 0 to Length(AllDevices)-1 do AllDevices[i].Destroy;
  SetLength( AllDevices, 0);
  //place nil in all aliases
  for vdev := Low(TValveDevices) to High(TValveDevices) do ValveDevices[vdev] := nil;
  for sdev := Low(TSensorDevices) to High(TSensorDevices) do SensorDevices[sdev] := nil;
  for rdev := Low(TRegDevices) to High(TRegDevices) do RegDevices[rdev] := nil;
end;


procedure TVTPDevicesListThreadSafe.AddDevice( devobj: TVTPDeviceBase );
//object must created outside, but is destroyed from the synchro !!
Var
  i: longint;
  dv: TVTPDeviceValve;
  ds: TVTPDeviceSensor;
  dr: TVTPDeviceReg;
begin
  if devobj=nil then
    begin
      //if threadptr<>nil then threadptr.LeaveLogMsg
      logmsg('TVTPDevicesListThreadSafe.AddDevice devobj=nil');
      exit;
    end;
  i := Length(AllDevices);
  SetLength(AllDevices, i+1);
  AllDevices[i] := devobj;
  devobj.baserec.id := i;
  logmsg('TVTPDevicesListThreadSafe.AddDevice adding dev: ' + devobj.baserec.idstr);
  //asign corresponding alias to the device
  case (devobj.dtype) of
        CDevValve:
          begin
            dv := TVTPDeviceValve(devobj);
            ValveDevices[ dv.fDev ] := dv;
          end;
        CDevSens:
          begin
            ds := TVTPDeviceSensor(devobj);
            SensorDevices[ ds.fDev ] := ds;
          end;
        CDevReg:
          begin
            dr := TVTPDeviceReg(devobj);
            RegDevices[ dr.fDev ] := dr;
          end;
    end; //case
end;


function TVTPDevicesListThreadSafe.GetDevice(i:longint): TVTPDeviceBase;
//if valid return pointer to device ancestor or NIL
begin
  Result := nil;
  if (i>=0) and (i<Length(AllDevices)) then Result := AllDevices[i];
end;

function TVTPDevicesListThreadSafe.FindDevByStr( devstr: string ): TVTPDeviceBase;
 Var i: longint;
begin
  Result := nil;
  for i:=0 to Length(AllDevices) do
    begin
      if Alldevices[i].baserec.idstr = devstr then begin
         Result :=  Alldevices[i];
         break;
         end;
    end;
end;


//***********

// internal VTP device objects and PROCESS REPLY!!!!

//  TDevType = (CDevUndef, CDevTemp, CDevValve, CDevPressSens, CDevPressReg, CDevOther);




constructor TVTPDeviceValve.create(_dev: TValveDevices; _idstr: string; _name: string; _enabled: boolean);
begin
  dtype := CDevValve;
  fDev := _dev;
  baserec.idstr := _idstr;
  baserec.name := _name;
  baserec.enabled := _enabled;
end;

function TVTPDeviceValve.ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean;
//expecting lock on datasynchro is engaged before calling this method
Var
  b: boolean;
  val: longint;
  rec: TValveRec;
begin
  Result := false;
  b := parseReplyStr1Int( baserec.idstr, reply, val, fs);
  if b and (ds<>nil) then
    begin
      rec.timestamp := Now();
      rec.state := CStateUndefined;
      if (val=1) then rec.state := CStateOpen;
      if (val=0) then rec.state := CStateClosed;
      ds.dataV[fDev] := rec;
      Result := true;
    end;
end;

function TVTPDeviceValve.GetLastValStr(Var ds: TVTPDataThreadSafe): string;
//here - this method should LOCK the DATASYNCHRO, although it only reads, maybe not necessary?
//but will probably be called from main thread mainly
Var
  val: TValveState;
  ts: TDateTime;
begin
  //ds.Lock;
    val := ds.dataV[fDev].state;
    ts :=  ds.dataV[fDev].timestamp;
  //ds.UnLock;
  if TimeDeltaNowMS(ts) > CVTPdataMaxAgeMS then Result := 'data too old'
  else Result := ValveStateToStr( val );
end;



constructor TVTPDeviceSensor.create(_dev: TSensorDevices; _idstr: string; _name: string; _enabled: boolean);
begin
  dtype := CDevSens;
  fDev := _dev;
  baserec.idstr := _idstr;
  baserec.name := _name;
  baserec.enabled := _enabled;
  baserec.unitStr := VTPDevUnit(_dev);
end;

function TVTPDeviceSensor.ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean;
//expecting lock on datasynchro is engaged before calling this method
Var
  b: boolean;
  val: double;
  rec: TOneDoubleRec;
begin
  Result := false;
  try
     b := parseReplyStr1Dbl( baserec.idstr, reply, val, fs);
  except
    b := false;
  end;
  if b and (ds<>nil) then
    begin
      rec.timestamp := Now();
      rec.val := val;
      //check limits, if out set flag!
      try
        param.flagOutOfLimit := (val< param.min) or (val> param.max);
      except
        param.flagOutOfLimit := false;
      end;
      ds.dataS[fDev] := rec;
      Result := true;
    end;
end;

function TVTPDeviceSensor.GetLastValStr(Var ds: TVTPDataThreadSafe): string;
//here - this method should LOCK the DATASYNCHRO, although it only reads, maybe not necessary?
//but will probably be called from main thread mainly
Var
  val: double;
  ts: TDateTime;
begin
  //ds.Lock;
    val := ds.dataS[fDev].val;
    ts :=  ds.dataS[fDev].timestamp;
  //ds.UnLock;
  if TimeDeltaNowMS(ts) > CVTPdataMaxAgeMS then Result := 'data too old'
  else Result := FloatToStrF( val, ffFixed,4,2) + ' ' + baserec.unitStr;
end;


constructor TVTPDeviceReg.create(_dev: TRegDevices; _idstr: string; _name: string; _enabled: boolean);
begin
  dtype := CDevReg;
  fDev := _dev;
  baserec.idstr := _idstr;
  baserec.name := _name;
  baserec.enabled := _enabled;
  baserec.unitStr := VTPDevUnit(_dev);
end;

function TVTPDeviceReg.ProcReply(reply: string; Var ds: TVTPDataThreadSafe; Var fs: TFormatSettings): boolean;
//expecting lock on datasynchro is engaged before calling this method
Var
  b: boolean;
  val: double;
  rec: TOneDoubleRec;
begin
  Result := false;
  try
    b := parseReplyStr1Dbl( baserec.idstr, reply, val, fs);
  except
    b := false;
  end;
  if b and (ds<>nil) then
    begin
      rec.timestamp := Now();
      rec.val := val;
      //check limits, if out set flag!
      try
        param.flagOutOfLimit := (val< param.min) or (val> param.max);
      except
        param.flagOutOfLimit := false;
      end;
      ds.dataR[fDev] := rec;
      Result := true;
    end;
end;

function TVTPDeviceReg.GetLastValStr(Var ds: TVTPDataThreadSafe): string;
//here - this method should LOCK the DATASYNCHRO, although it only reads, maybe not necessary?
//but will probably be called from main thread mainly
Var
  val: double;
  ts: TDateTime;
begin
  ds.Lock;
    val := ds.dataR[fDev].val;
    ts :=  ds.dataR[fDev].timestamp;
  ds.UnLock;
  if TimeDeltaNowMS(ts) > CVTPdataMaxAgeMS then Result := 'data too old'
  else Result := 'SP=' +FloatToStrF( val, ffFixed,4,2) + ' bar';
end;


function TVTPDeviceReg.CreateSetpointCmd(val: double): string;
begin
  MakeSureIsInRange(val, param.min, param.max);
  Result := 'SET '+ baserec.idstr + ' ' + FloatToStr(val);
end;







//****************************************************





function VTPDefDevIdStr( dev: TValveDevices ): string;
begin
  case dev of
    CVH2bH: Result := 'V1';
    CVN2bH: Result := 'V2';
    CVO2bO: Result := 'V3';
    CVAirbO: Result := 'V4';
    CVN2bO: Result := 'V5';
    CVN2safN2: Result := 'V6';
    CVbHA: Result := 'V7';
    CVbOA: Result := 'V8';
    CVbNA: Result := 'V9';
    CVnSafN2A: Result := 'V10';
    CVresA: Result := 'V11';
    CVbOK: Result := 'V12';
    CVbHK: Result := 'V13';
    CVbNK: Result := 'V14';
    CVnsafN2K: Result := 'V15';
    CVnbNfl: Result := 'V16';
    CVnAxH: Result := 'V18';
    CVAxO: Result := 'V19';
    CVnKxO: Result := 'V20';
    CVKxH: Result := 'V21';
    CVresFl: Result := 'V22';
    CVwtrbH: Result := 'V23';
    CVwtrbN: Result := 'V24';
    CVwtrbO: Result := 'V25';
    CVLED: Result := 'V26';
    CPwrSwitch: Result := 'PWR';
    else  Result := 'NULL';
  end;
end;


 function VTPDefDevIdStr( dev: TSensorDevices ): string;
begin
  case dev of
    CTBubH2: Result := 'TC1';
    CTBubN2: Result := 'TC2';
    CTBubO2: Result := 'TC3';
    CTCellBot: Result := 'TC4';
    CTCellTop: Result := 'TC5';
    CTOven1: Result := 'TC6';
    CTOven2: Result := 'TC7';
    CTRoom: Result := 'Troom';
    //
    CpAnode: Result := 'S1';
    CpCathode: Result := 'S2';
    CpPiston: Result := 'S3';
    CpN2: Result := 'S4';
    CpReserve: Result := 'S5';
    CpBPControl: Result := 'R1GET';
    //
    CMswCtrl: Result := 'MswCtrl';
    else  Result := 'NULL';
  end;
end;


function VTPDefDevIdStr( dev: TRegDevices ): string;
begin
  case dev of
    CpRegBackpress: Result := 'R1SET';
    //
    CMFC1: Result := 'FC1';
    CMFC2: Result := 'FC2';
    CMFC3: Result := 'FC3';
    CMFC4: Result := 'FC4';
    CMswStatus: Result := 'MswStatus';
    CMswProgress: Result := 'MswProgress';
    else  Result := 'NULL';
  end;
end;













function ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
Const
  CMarkEnd = #13#10;
Var
  i: longword;
  tmp: string;
begin
  Result := '';
  i := Pos(CMarkEnd, buf);
  if i>0 then
    begin
      Result := Copy(buf, 0 , i-1);
      //delete used part
      tmp := Copy(buf, i+1 , Length(buf));  //REMOVE ALSO MarkEND (#13)!!!
      buf := tmp;
    end;
end;



function parseReplyStr1Dbl(idstr: string; replystr: string; Var val: double; Var fs: TFormatSettings): boolean;
Var
  b: boolean;
  toklist: TTokenList; //dynamic array
  retid: string;
  rs: string;
begin
  Result := false;
  val := NaN;
  //parse reply
  rs := ExtractReply( replystr);
  ParseStrSimple(rs, toklist);
  //expecting reply '<idstr> <val>' = 2 tokens
  b := false;
  if length(toklist) >= 1 then
    begin
       b := true;
      try
        val := StrToFloatDef(toklist[0].s, NaN , fs);
      except
        b := false;
        val := NaN;
      end;
    end;
  Result := b;
end;


function parseReplyStr1Int(idstr: string; replystr: string; Var val: longint; Var fs: TFormatSettings): boolean;
Var
  b: boolean;
  toklist: TTokenList; //dynamic array
  retid: string;
  rs: string;
begin
  Result := false;
  val := Low(longint);
  //parse reply
  rs := ExtractReply( replystr);
  ParseStrSimple(rs, toklist);
  //expecting reply '<idstr> <val>' = 2 tokens
  b := false;
  if length(toklist) >= 1 then
    begin
       b := true;
       //check the id match
      //retid := toklist[0].s;
      //if retid <> idstr then b := false;
      //convert numbers
      //NEED to use fFormatSettings to be independent on system settings!!!!!
      try
        val := StrToIntDef(toklist[0].s, Low(longint));
      except
        b := false;
      end;
    end;
  Result := b;
end;




procedure FillNaN(Var Rec: TDeviceBaseRec);
begin
  with Rec do
    begin
      idstr := 'None';
      name := 'None';
      enabled := false;
      unitStr := '';
      id := -1;
    end;
end;


procedure FillNaN(Var ParRec: TDevSensorParamRec);
begin
  with ParRec do
    begin
      min := NAN;
      max := NAN;
    end;
end;

procedure FillNaN(Var ParRec: TDevValveParamRec);
begin
  with ParRec do
    begin
    end;
end;


procedure FillNaN(Var ParRec: TDevRegParamRec);
begin
  with ParRec do
    begin
      min := NAN;
      max := NAN;
    end;
end;



end.

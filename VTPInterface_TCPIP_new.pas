unit VTPInterface_TCPIP_new;

{
* From Jirka LIbra:
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

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs, StrUtils,
  myutils, MyParseUtils, Logger, ConfigManager, MyThreadUtils, MVConversion,
  HWAbstractDevicesV3, FormGlobalConfig,
  MyTCPKolServerAquireThread, LoggerThreadSafe;

//http://stackoverflow.com/questions/5530038/how-to-handle-received-data-in-the-tcpclient-delphi-indy

Const
  CInterfaceVer = 'VTP-Interface-V3';

  CNotRespCount = 5;
  CComTimeoutConstMS = 10000;
  CReportLagThreshold = 2000;

  CVTPdataMaxAgeMS = 100000;

  CLockWaitMax = 10000;

  CThreadIdStr = 'VTP';

  CDefaultVTPdevList = 'PWR,V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,V13,V14,V15,V16,V17,V18,V19,V20,V21,V22, V23, V24, V25, V26, T1, T2, T3, T4, T5, T6, S1, S2, S3, S4, S5, H1, H2, H3, H4, H5, H6, T1set, T2set, T3set, T4set, T5set,T6set,MSWCtrl,MSWStatus,MSwProgress,Vref';

Type

  //flow commands

  TVTPCmdType = (CVTPCmdUNDEF, CVTPCmdSetVarInt, CVTPCmdSetVarDbl, CVTPCmdUser);

  TSynchroMethodId = procedure(cmdid: longint; result: boolean) of object;


  TVTPDeviceData = record   //for reporting data back
    dataV: TValveData;
    dataS: TSensorData;
    dataR: TRegData;
    fLastSuccessAquireTime: TDateTime;
    fLastAquireDurMS: longint;
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
      function ProcReply(reply: string; Var ds: TVTPDeviceData): boolean; virtual; abstract;
        //process reply from server according to device format
      function GetLastValStr(Var ds: TVTPDeviceData): string; virtual; abstract;
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
    function ProcReply(reply: string; Var ds: TVTPDeviceData): boolean; override;
    function GetLastValStr(Var ds: TVTPDeviceData): string; override;
  end;


 TVTPDeviceValve = class ( TVTPDeviceBase )
  public
    constructor create(_dev: TValveDevices; _idstr: string; _name: string; _enabled: boolean);
  public
    param: TDevValveParamRec;
    fDev: TValveDevices;  //need this to store the data to the right place
    function ProcReply(reply: string; Var ds: TVTPDeviceData): boolean; override;
    function GetLastValStr(Var ds: TVTPDeviceData): string; override;
  end;


 TVTPDeviceReg = class ( TVTPDeviceBase )
  public
    constructor create(_dev: TRegDevices; _idstr: string; _name: string; _enabled: boolean);
  public
    param: TDevRegParamRec;
    fDev: TRegDevices;  //need this to store the data to the right place
    //
    function ProcReply(reply: string; Var ds: TVTPDeviceData): boolean; override;
    function GetLastValStr(Var ds: TVTPDeviceData): string; override;
    //
    function CreateSetpointCmd(val: double): string;
  end;




  TVTPDevicesListThreadSafe = class (TMyLockableObject)     //for devices to iterare over    //TThreadList
  public
    constructor Create;
    destructor Destroy; override;
    //procedure AssignThreadPtr(_threadptr: TAquireThreadCommonAncestor);
  public
    AllDevices: array of TVTPDeviceBase;   //all devices - used for polling and control, when not want to distinguish between types
    //alias arrays - just to have distinguished access to each device type
    ValveDevices: array[TValveDevices] of TVTPDeviceValve;
    SensorDevices: array[TSensorDevices] of TVTPDeviceSensor;
    RegDevices: array[TRegDevices] of TVTPDeviceReg;
    //fWorkerhread: TAquireThread_KolServer_TCPIP;
  public
    procedure ClearDevices;
    procedure AddDevice( devobj: TVTPDeviceBase ); //object must created outside, but is destroyed from the synchro
    function GetDevice(i:longint): TVTPDeviceBase; //if valid return pointer to device ancestor or NIL
    function FindDevByStr( devstr: string ): TVTPDeviceBase;
  private
    //threadptr: TAquireThreadCommonAncestor;
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
      function Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean; override;
      function GetFlags(): TCommDevFlagSet; override;
      function SetRegSetp(dev: TRegDevices; val: double): boolean; override;
      function SendCmdRaw(s: string): boolean; override;
      function GetRange(dev: TSensorDevices): TRangeRecord; overload; override;
      function GetRange(dev: TRegDevices): TRangeRecord; overload; override;
    private
      function getIsReady: boolean; override;
//iherited properties - just to have a note ...
//  public
//    property Name: string read fName;
//    property IsDummy: boolean read fDummy;
//    property IsReady: boolean read fReady;
    private
      fAcquireThread: TAquireThread_KolServer_TCPIP;
      fDeviceSynchro: TVTPDevicesListThreadSafe;
    public
      fDataRegistry: TMyRegistryNodeObject;   //stores data and status - access methods are THREADSAFE!!!
    public
      procedure createDevObjects;
      procedure LoadConfig;
      procedure SaveConfig;
      procedure RunAfterInit;
    private
      fConStatus: TInterfaceStatus;
      fTargetCycleTimeMS: longword;
      flock: boolean;  //prevent multiple nesting calls to comm fucntions
      fLog:  TMyLoggerThreadSafe;
      fDebug: boolean;
      procedure setDebug(b: boolean);
      procedure fLogMsg(a: string);
    public
      property ConStatus: TInterfaceStatus read fConStatus;
      property Debug: boolean read fDebug write setDebug;
    public
      //TCPIP Client/ Com operation, configuratio
      function OpenCom(timeoutMS: longint = 4000): boolean;
      procedure CloseCom;
      procedure SetupCom(host: string; port: string); //TCPIP
      procedure GetComConf(Var srv, prt: string);
      function isComConnected(): boolean;
    private
      fIsconfigured: boolean;
      //config storage registry items (do not destroy - managed in the registry objects)
      fRiAquireDevicesList: TRegistryItem;
      fRiTCPHost: TRegistryItem;
      fRiTCPPort: TRegistryItem;
      fRiProtocolVer: TRegistryItem;
    public
      //user command
      fUserCmdReplyS: string;
      fUserCmdReplyTime: TDateTime;
      //fLastCycleDurMs: longint;
      fUserCmdReplyIsNew: boolean;
      fEnableSendMFC: boolean;
      //other
    public
      //thread control
      procedure ThreadStart(timeoutMS: longint = 500);
      procedure ThreadStop;
      function IsThreadRunning(): boolean;
      function getThreadStatus: string;
      procedure SetUserSuspend;
      procedure ResetUserSuspend;
      //procedure UpdateAcquireDevices;
    public
      function GetNDevsInThread(): word;
      function getLastAquireTime(): TDateTime;
      function SendUserCmd(cmd: string): boolean;
      //function SendUserCmdRaw(cmd: string): boolean;
      //procedure ReceiveReplyFromThread(cmdid: longint; result: boolean);    //"event handler"
         //- reads reply from data.aswerlowlvl when beeing called using synchronize from thread
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
     // procedure AssignConfigManager( Var cm: TLoadSaveConfigManager );  //use this to partially automate storing/loading of configuration from PTC control form
      procedure DoAfterConfLoad; //process values after load process of config manager registered variables
      procedure DoBeforeSavingConf;  // prepare variables to be saved by config manager
    private
    //---- private variables declaration
      fConfManagerId: longint;
      //configuration storage (need to use varibale, so it can be asigned to config manager
      fComHost: string;
      fComPort: word;
      //
    private
      function GetDeviceSynchro(Var ds: TVTPDevicesListThreadSafe): boolean; //checks for nNIL and assigns pointer - if ok returns True
      //function GetDataSynchro(Var datas: TVTPDeviceData):  boolean; //checks for nNIL and assigns pointer - if ok returns True
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
function parseReplyStr1Dbl(idstr: string; replystr: string; Var val: double): boolean;
function parseReplyStr1Int(idstr: string; replystr: string; Var val: longint): boolean;
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
//        control object
//****************************


constructor TVTPControl_TCP_FCSControl.Create;
begin
  inherited Create('Valve+Temp+Pressure Control via FCSControl', CInterfaceVer, false);
  fLog := TMyLoggerThreadSafe.Create('!vtp-fcs-tcpip_', '', GlobalConfig.getAppPath + 'log' + CPathSlash);
  fAcquireThread := TAquireThread_KolServer_TCPIP.Create( fLog );
  fDeviceSynchro := TVTPDevicesListThreadSafe.Create;
  fDataRegistry := CommonDataRegistry;
  //
{  fDataRegistry := TMyRegistryNodeObject.Create('VTPDataAndStatus');
  fDataRegistry.GetOrCreateItem( IdKSLastAquireTS );
  fDataRegistry.GetOrCreateItem( IdKSLastElapsedMS );
  fDataRegistry.GetOrCreateItem( IdKSAnswerLowLevel ); //for use with user cmd - answer to last USER cmd - in raw as received
  fDataRegistry.GetOrCreateItem( IdKSCLientState );
  fDataRegistry.GetOrCreateItem( IdCLientStatusStr );
  fDataRegistry.GetOrCreateItem( IdInterfaceReady );}
  //create aquire thread dev synchro device objects
  createDevObjects;
  //if AquireThread<>nil then AquireThread.devicessynchro.AssignThreadPtr( nil );
  logmsg('TVTPControl_TCP_FCSControl.Create: done.');
end;


destructor TVTPControl_TCP_FCSControl.Destroy;
Var
 i: integer;
begin
  if IsReady then Finalize;
  // unreg variables references inside configmanager (but not destroy!!)
  //aquirethread
  if fAcquireThread<> nil then fAcquireThread.Destroy;
  if fDeviceSynchro<>nil then fDeviceSynchro.Destroy;
  {if fDataRegistry<>nil then fDataRegistry.Destroy;}
  if fLog<>nil then fLog.Destroy;
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
  if fDeviceSynchro = nil then exit;
  ds := fDeviceSynchro;
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
  if fAcquireThread = nil then exit;
  if not fIsconfigured then
    begin
      LoadConfig;
    end;
  if not fIsconfigured then exit;
  //UpdateAcquireDevices;
  fAcquireThread.RunAcquire;
  fUserCmdReplyIsNew := false;
  Result := true;
  fDataRegistry := CommonDataRegistry;

  logmsg('TVTPControl_TCP_FCSControl.Initialize: .... Iface ver str: ' + CInterfaceVer );
end;



procedure TVTPControl_TCP_FCSControl.Finalize;
begin
  logmsg('TAlicatFlowControl.Finalize: Stopping thread...!!!' );
  if fAcquireThread = nil then exit;
  fAcquireThread.StopAcquire;
end;


procedure TVTPControl_TCP_FCSControl.ResetConnection;
begin
  if fAcquireThread=nil then exit;
  fAcquireThread.ResetConnection;
end;


function TVTPControl_TCP_FCSControl.getIsReady: boolean;
begin
  Result := false;
  if fAcquireThread=nil then exit;
  Result := fAcquireThread.IsReady;
end;

function TVTPControl_TCP_FCSControl.Aquire(Var datav: TValveData; Var datas: TSensordata; Var datar: TRegData): boolean;
Var
 dsync: TVTPDeviceData;
 devV: TValveDevices;
 devS: TSensorDevices;
 devR:  TRegDevices;
 locked: boolean;
 id, reply: string;
 i, n: longint;
begin
  Result := false;
  InitWithNAN(datav);
  InitWithNAN(datas);
  InitWithNAN(datar);
  if fAcquireThread=nil then exit;
  if fDeviceSynchro=nil then exit;
  if not getIsReady then exit;

  InitWithNAN(dsync.datav);
  InitWithNAN(dsync.datas);
  InitWithNAN(dsync.datar);

  n := Length(fDeviceSynchro.AllDevices);
  for i:= 0 to n-1 do
    begin
      id := fDeviceSynchro.AllDevices[i].baserec.idstr;
      reply := fAcquireThread.data[ id ].valStr;
      fDeviceSynchro.AllDevices[i].ProcReply(reply, dsync)
    end;
  //fAquireThread.ManualAquire;
     datav := dsync.dataV;
     datas := dsync.dataS;
     datar := dsync.dataR;
     fLastAcqTimeMS.valInt := fAcquireThread.data[ IdKSLastElapsedMS ].valInt;
  Result := true;
end;

procedure TVTPControl_TCP_FCSControl.LoadConfig;
Var i: integer;
    s, s2, fdname, fddef, sec, secdev: string;
    fd: TFlowDevices;
    tl: TTokenList;
    aRI: TRegistryItem;
    RIiniscriptenabled, RIiniscript: TRegistryItem;
    xs: string;
    xb: boolean;
begin
  //flowdevices
  //FMFCCount := fConfClient.Load('MFCCount', 0);
  sec := CInterfaceVer;
  secdev := SecIdDevices;
  if fAcquireThread=nil then begin LogWarning(' VTP-load conf: AcquireThread=nil'); exit; end;
  // devices
  fRiAquireDevicesList := RegistryHW.NewItemDef(sec, 'AquireDevicesList', CDefaultVTPDevList);
  //
  //UpdateAcquireDevices(fRiAquireDevicesList.valStr) ;
  ParseStrSep(fRiAquireDevicesList.valStr, ',', tl);
  CommonDataRegistry.valStr['VTPAcquireDevList'] := fRiAquireDevicesList.valStr;
  fAcquireThread.ClearAcquireObjects;
  for i:=0 to length(tl)-1 do fAcquireThread.AddAcquireObject( tl[i].s );
  //
  // TCP parameters + protocolo version
  fRiTCPHost := RegistryHW.NewItemDef(sec, 'TCPHost', 'localhost');   //s := fConfClient.Load('TCPHost', 'localhost');
  fRiTCPPort := RegistryHW.NewItemDef(sec, 'TCPPort', '20005');  //s2 := fConfClient.Load('TCPPort', '20005');
  fRiProtocolVer := RegistryHW.NewItemDef(sec, 'ProtocolVersion', 2);   //i := fConfClient.Load('ProtocolVersion', 1);
  //
  fAcquireThread.setTCPconf(fRiTCPHost.valStr, fRiTCPPort.valStr, fRiProtocolVer.valInt);
  //
  RIiniscriptenabled := _NullRegistryItem;
  RIiniscript := _NullRegistryItem;
  if RegistryHW<> nil then
    begin
      RIiniscriptenabled := RegistryHW.NewItemDef(sec, 'InitScriptSendEnabled', true);
      RIiniscript :=  RegistryHW.NewItemDef(sec, 'InitScriptCMD', 'SET V10 0; SET V15 0; SET V6 1');  //safety N2
    end;
  if (RIiniscriptenabled<>nil) and (RIiniscript<>nil) then
    begin
      xb := RIiniscriptenabled.valBool;
      xs :=  RIiniscript.valstr;
      ari := fAcquireThread.Data[ IdKSInitScriptEnabled ];
      ari.valBool := xb;
      ari := fAcquireThread.Data[ IdKSInitScriptCmd ];
      ari.valStr := xs;
      CommonDataRegistry.valStr['VTPInitScript'] := xs;
    end;
  //

  fIsconfigured := true;
end;


procedure TVTPControl_TCP_FCSControl.RunAfterInit;
begin
end;


procedure TVTPControl_TCP_FCSControl.SaveConfig;
begin
end;


function TVTPControl_TCP_FCSControl.GetFlags(): TCommDevFlagSet;
begin
  Result := [];
end;

function TVTPControl_TCP_FCSControl.SetRegSetp(dev: TRegDevices; val: double): boolean;
Var
  cmd: string;
  ddev: TVTPDeviceReg;
begin
  Result := false;
  if fDeviceSynchro=nil then exit;
  if not getIsReady then exit;
  if fDebug then logmsg( 'VTP  SetRegSetp: '+ VTPDeviceToStr(dev) +' '+ FloatToStr(val));
  //MakeSureIsInRange(val, param.min, param.max);
  ddev := fDeviceSynchro.RegDevices[dev];
  if ddev<>nil then
    begin
      cmd := ddev.CreateSetpointCmd(val);
      fAcquireThread.AddCommand( cmd );
    end;
  Result := true;
end;

function TVTPControl_TCP_FCSControl.SendCmdRaw(s: string): boolean;
begin
  Result := false;
  if not getIsReady then exit;
  if fDebug then logmsg( 'VTP  SendCmdRaw: '+ s);
  fAcquireThread.AddCommand( s );
  Result := true;
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
  if fAcquireThread<>nil then fAcquireThread.Debug := b;
end;



procedure TVTPControl_TCP_FCSControl.ResetLastAquireTime;
begin
  if fAcquireThread=nil then exit;
end;





procedure TVTPControl_TCP_FCSControl.SetupCom(host: string; port: string); //TCPIP
Const
  CThisM = 'TVTPControl_TCP_FCSControl.SetupCom';
begin
  logmsg(CThisM + ': SetupCom!!!' );
  if fAcquireThread=nil then exit;
  fRiTCPHost.valStr := host;
  fRiTCPPort.valStr := port;
  fAcquireThread.setTCPconf( fRiTCPHost.valStr, fRiTCPPort.valStr, fRiProtocolVer.valInt);
  logmsg(CThisM  + ':  new config= ' + host + ' port=' + port );
end;

procedure TVTPControl_TCP_FCSControl.GetComConf(Var srv, prt: string);
Var
  pv: integer;
begin
  if fAcquireThread=nil then exit;
  fAcquireThread.getTCPConf(srv, prt, pv);
end;



function TVTPControl_TCP_FCSControl.isComConnected(): boolean;
begin
  Result := False;
  if fAcquireThread=nil then exit;
  Result := fAcquireThread.isClientConnected;
end;


function TVTPControl_TCP_FCSControl.OpenCom(timeoutMS: longint = 4000): boolean;
Var
  d0: longword;
begin
  Result := False;
  if fAcquireThread=nil then exit;
  Result := fAcquireThread.isClientConnected;
end;


procedure TVTPControl_TCP_FCSControl.CloseCom;
begin
  if fAcquireThread=nil then exit;
end;





procedure TVTPControl_TCP_FCSControl.ThreadStart(timeoutMS: longint = 500);

begin
  if fAcquireThread=nil then exit;
  fAcquireThread.RunAcquire;
  logmsg('TAlicatFlowControl.ThreadStart: calling RESUME');
end;


procedure TVTPControl_TCP_FCSControl.ThreadStop;
begin
  if fAcquireThread=nil then exit;
  //Only use user suspend
  fAcquireThread.StopAcquire;
end;


function TVTPControl_TCP_FCSControl.IsThreadRunning(): boolean;
begin
  Result := false;
  if fAcquireThread=nil then exit;
  Result := fAcquireThread.IsRunning;
end;

function TVTPControl_TCP_FCSControl.getThreadStatus: string;
begin
  Result := 'NIL';
  if fAcquireThread=nil then exit;
  Result := fAcquireThread.getThreadStatus;
end;

procedure TVTPControl_TCP_FCSControl.SetUserSuspend;
begin

end;

procedure TVTPControl_TCP_FCSControl.ResetUserSuspend;
begin

end;

function TVTPControl_TCP_FCSControl.GetNDevsInThread: word;
begin
  Result := 0;
end;


function TVTPControl_TCP_FCSControl.getLastAquireTime(): TDateTime;
begin
  Result := 0;
  if fAcquireThread=nil then exit;
  Result := fAcquireThread.data[ IdKSLastAquireTS ].valDouble;
end;


function TVTPControl_TCP_FCSControl.SendUserCmd(cmd: string): boolean;
Var
  b: boolean;
  cmdrec: TVTPCmdArrayRec;
  nw: word;
begin
   Result := false;
   if fDebug then logmsg('SendUserCmd: ' + BinStrToPrintStr(cmd) );
   //prepare cmd
//   cmdrec.t := CVTPCmdUser;
//   cmdrec.params := cmd  + '';  //force copy
//   cmdrec.responsemethod := ReceiveReplyFromThread;
   //enqueue new command into aquire thread
  if fAcquireThread=nil then exit;
  Result := true;
  fAcquireThread.AddCommand( cmd );
end;

{
procedure TVTPControl_TCP_FCSControl.ReceiveReplyFromThread(cmdid: longint; result: boolean);       //reads reply from data.aswerlowlvl
//
Var
  copys : string;
  TSdata: TVTPDataThreadSafe;
begin
  if fDebug then logmsg('ReceiveReplyFromThread');
  if AquireThread=nil then exit;
  TSdata := AquireThread.datasynchro;
  if TSdata=nil then exit;
  TSdata.Lock;
    copys := TSdata.aswerlowlvl + '';      //!!!!!!!!!! necessary to copy, not just assign reference - to be sure
  TSdata.UnLock;
  if fDebug then logmsg('ReceiveReplyFromThread str=' + BinStrToPrintStr( copys));
  fUserCmdReplyS := copys;
  fUserCmdReplyTime := Now;
  fUserCmdReplyIsNew := true;
end;
}



function TVTPControl_TCP_FCSControl.getBaseDevParamById(i: longint; Var baseRec: TDeviceBaseRec; Var valstr: string): boolean;
//gets device parameters from the devicesynchro
Var
  devs: TVTPDevicesListThreadSafe;
  dev: TVTPDeviceBase;
  didlock: boolean;
begin
  Result := false;
  FillNaN( BaseRec);
  if not GetDeviceSynchro(devs) then exit;
  if fAcquireThread=nil then exit;
  devs.Lock;
try
    dev := devs.GetDevice(i);
    if dev<>nil then
      begin
        baseRec := dev.baserec;
        valstr := fAcquireThread.data[ baserec.idstr ].valStr ;
        Result := true;
      end;
  finally
    devs.Unlock;
  end;
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
  ds.Lock;
  try
    dev := ds.GetDevice(i);
    if dev<>nil then dev.baserec := baseRec;
  finally
    ds.Unlock;
  end;
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
  ds := fDeviceSynchro;
  Result := ds<>nil;
end;



procedure TVTPControl_TCP_FCSControl.DoAfterConfLoad; //process values after load process of config manager registered variables
begin
 // setComPortConf;
end;


procedure TVTPControl_TCP_FCSControl.DoBeforeSavingConf;
begin
  //getComPortConf;
end;

procedure TVTPControl_TCP_FCSControl.fLogMsg(a: string);
begin
  if flog=nil then exit;
  fLog.LogMsg(a);
end;


//****************************************************




{
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
  s := '';
  if fDebug then  LeaveLogMsg('TMyAquireThread.MakeCmdDone: cmd type:' + IntToStr( Ord(cmd.t) ) ); // + cmd.params
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
        if fDebug then LeaveLogMsg('USER CMD: ' + BinStrToPrintStr(s) );
      end;
    else s:='';
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
      if fDebug then LeaveLogMsg('USER CMD - timeMS: ' + IntToStr(deltaMS) +' reply: "' + BinStrToPrintStr(reply) + '"' );
      locked := datasynchro.LockTimeout( CLockWaitMax );
      if not locked then LeaveLogMsg('USER CMD lock obtain FAILED force write');
        datasynchro.aswerlowlvl := reply;
        datasynchro.aswerlowlvlDurMS := deltaMS;
      if locked then datasynchro.UnLock;
      if Assigned( cmd.responsemethod ) then cmd.responsemethod( cmd.id, b); //let know the main thread about result
     end;
  //
  Result := b;
end;
}










//****************************************************


//****************************************************

constructor TVTPDevicesListThreadSafe.Create;
begin
  inherited create;
  //place nil in all aliases
  ClearDevices;
  //threadptr := nil;
end;

destructor TVTPDevicesListThreadSafe.Destroy;
begin
  ClearDevices;
  inherited;
end;


{procedure TVTPDevicesListThreadSafe.AssignThreadPtr(_threadptr: TAquireThreadCommonAncestor);
begin
  threadptr := _threadptr;
end;
}

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

function TVTPDeviceValve.ProcReply(reply: string; Var ds: TVTPDeviceData): boolean;
//expecting lock on datasynchro is engaged before calling this method
Var
  b: boolean;
  val: longint;
  rec: TValveRec;
begin
  Result := false;
  b := parseReplyStr1Int( baserec.idstr, reply, val);
  if b  then
    begin
      rec.timestamp := Now();
      rec.state := CStateUndefined;
      if (val=1) then rec.state := CStateOpen;
      if (val=0) then rec.state := CStateClosed;
      ds.dataV[fDev] := rec;
      CommonDataRegistry.SetOrCreateItem(baserec.idstr, val);
      Result := true;
    end;
end;

function TVTPDeviceValve.GetLastValStr(Var ds: TVTPDeviceData): string;
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

function TVTPDeviceSensor.ProcReply(reply: string; Var ds: TVTPDeviceData): boolean;
//expecting lock on datasynchro is engaged before calling this method
Var
  b: boolean;
  val: double;
  rec: TOneDoubleRec;
begin
  Result := false;
  try
     b := parseReplyStr1Dbl( baserec.idstr, reply, val);
  except
    b := false;
  end;
  if b then
    begin
      rec.timestamp := Now();
      rec.val := val;
      //check limits, if out set flag!
      try
        param.flagOutOfLimit := (val< param.min) or (val> param.max);
      except
        param.flagOutOfLimit := false;
      end;
      CommonDataRegistry.SetOrCreateItem(baserec.idstr, val);
      ds.dataS[fDev] := rec;
      Result := true;
    end;
end;

function TVTPDeviceSensor.GetLastValStr(Var ds: TVTPDeviceData): string;
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

function TVTPDeviceReg.ProcReply(reply: string; Var ds: TVTPDeviceData): boolean;
//expecting lock on datasynchro is engaged before calling this method
Var
  b: boolean;
  val: double;
  rec: TOneDoubleRec;
begin
  Result := false;
  try
    b := parseReplyStr1Dbl( baserec.idstr, reply, val);
  except
    b := false;
  end;
  if b then
    begin
      rec.timestamp := Now();
      rec.val := val;
      //check limits, if out set flag!
      try
        param.flagOutOfLimit := (val< param.min) or (val> param.max);
      except
        param.flagOutOfLimit := false;
      end;
      CommonDataRegistry.SetOrCreateItem(baserec.idstr, val);
      ds.dataR[fDev] := rec;
      Result := true;
    end;
end;

function TVTPDeviceReg.GetLastValStr(Var ds: TVTPDeviceData): string;
//here - this method should LOCK the DATASYNCHRO, although it only reads, maybe not necessary?
//but will probably be called from main thread mainly
Var
  val: double;
  ts: TDateTime;
begin
    val := ds.dataR[fDev].val;
    ts :=  ds.dataR[fDev].timestamp;
  if TimeDeltaNowMS(ts) > CVTPdataMaxAgeMS then Result := 'data too old'
  else Result := 'SP=' +FloatToStrF( val, ffFixed,4,2) + ' bar';
end;


function TVTPDeviceReg.CreateSetpointCmd(val: double): string;
begin
  //MakeSureIsInRange(val, param.min, param.max);
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

    CStateH1: Result := 'H1';
    CStateH2: Result := 'H2';
    CStateH3: Result := 'H3';
    CStateH4: Result := 'H4';
    CStateH5: Result := 'H5';
    CStateH6: Result := 'H6';

    else  Result := 'NULL';
  end;
end;


 function VTPDefDevIdStr( dev: TSensorDevices ): string;
begin
  case dev of
    CTBubH2: Result := 'T1';
    CTBubN2: Result := 'T2';
    CTBubO2: Result := 'T3';
    CTCellBot: Result := 'T4';
    CTCellTop: Result := 'T5';
    CTOven1: Result := 'T6';
    CTOven2: Result := 'T7';
    CTPipeA: Result := 'T8';
    CTPipeB: Result := 'T9';
    //
    CpAnode: Result := 'S1';
    CpCathode: Result := 'S2';
    CpPiston: Result := 'S3';
    CpN2: Result := 'S4';
    CpReserve: Result := 'S4';
    CpBPControl: Result := 'R1GET';
    //
    CMswCtrl: Result := 'MswCtrl';

    //
    CTH1set: Result := 'T1set';
    CTH2set: Result := 'T2set';
    CTH3set: Result := 'T3set';
    CTH4Set: Result := 'T4set';
    CTH5set: Result := 'T5set';
    CTH6set: Result := 'T6set';

    CVref: Result := 'Vref';
    CPSA: Result := 'CPSA';
    CPSN2: Result := 'CPSN2';
    CPSC: Result := 'CPSC';

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



function parseReplyStr1Dbl(idstr: string; replystr: string; Var val: double): boolean;
begin
  Result := false;
  val := NaN;
  //parse reply
      try
        val := MyStrToFloatDef(replystr, 0);
        Result := true;
      except
        on E: exception do val := NaN;
      end;
end;


function parseReplyStr1Int(idstr: string; replystr: string; Var val: longint): boolean;
begin
  Result := false;
  val := Low(longint);
  //parse reply
   try
     val := StrToIntDef(replystr, Low(longint));
     Result := true;
   except
   end;
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

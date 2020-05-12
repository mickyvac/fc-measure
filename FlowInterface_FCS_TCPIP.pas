unit FlowInterface_FCS_TCPIP;
{$IFDEF FPC}  // for compatibility between delphi  and lazarus
{$MODE delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs, ExtCtrls, Graphics,
  myutils, MyParseUtils, Logger, LoggerThreadSafe, ConfigManager, MVConversion,
  FormGLobalConfig,
  HWAbstractDevicesV3,
  MVvariant_DataObjects, MyThreadUtils, MyTCPKolServerAquireThread;
// MyAquireThreadPrototype,

{ create descendant of virtual abstract FLOW object and define its methods
  especially including definition of configuration and setup methods }

Const
  CInterfaceVer2 = 'Flow-FCScontrol-TCPIP-V2';
  CInterfaceVer = 'Flow-FCScontrol-TCPIP-V3';
  CFlowTimeoutConstMS = 5000;
  CTimeDeltaNotRespondingMS = 5000;
  IdHWMFClist = 'HWMFClist';
  IdVirtMFClist = 'VirtualMFClist';
  IdHelpDummy = 'hlpnote';

Type

  // flow commands

  TFlowCmdType = (CFlowCmdSetUNDEF, CFlowCmdSetSP, CFLowCmdSetGas,
    CFlowCmdUserCmd);

  TSynchroMethod = procedure of object;

  TMFCSimple = class(TVirtualMFCAncestor)
  public
    constructor Create(_nickname: string; registry: TMyRegistryNodeObject);
    destructor Destroy; override;
  public
  private
    FworkRN: TMyRegistryNodeObject;
    Fnickname: string;
    FRIsetp: TRegistryItem;
    FRIgasID: TRegistryItem;
    //
    FLinkedHWMFC: THwMFCAncestor;
    //
    fLastSetp: double;
    fLastGasId: longint;
  private
    procedure OnUpdateRegistry; // should avoid modify registry!
  end;

  {
    TMFCVirtual2MFCfixedRatio = class (TVirtualMFCAncestor)
    public
    constructor Create(_nickname: string; registrynode: TMyRegistryNodeObject);
    destructor Destroy; override;
    public
    ratio12: double;
    procedure SetFromParamStr(s: string);
    function GetParamStr: string;
    private
    FworkRN: TMyRegistryNodeObject;
    end;
    }

  THwMFCAlicatFCSControl = class(THwMFCAncestor)
  public
    constructor Create(_nickname: string; registry: TMyRegistryNodeObject);
    destructor Destroy; override;
  public
    procedure SetFromParamStr(s: string);
    function GetPackedParamStr: string;
    procedure GenerateAcquireNames(Var cmdlist: TStringList);
    // add only to cooperate with other objects
    function ObtainStoichFactorForGasId(AlicatID: byte): double; // check for record in config file  gas#stoichfactor=h2coef;o2coef   otherwise sets zero to both
  private
    function getFlow(): double;
    function getSetp(): double;
    function getPress(): double;
    function getTemp(): double;
    function getGsStr(): string;
    function getGasId(): byte;
  public
    property flow: double read getFlow;
    property setpoint: double read getSetp;
    property pressure: double read getPress;
    property temp: double read getTemp;
    property gasstr: string read getGsStr;
    property gasid: byte read getGasId;
  private
    Fnickname: string;
    FworkRN: TMyRegistryNodeObject;
    Flastgasstrid: string;
  private
    fIDflow: string;
    fIDsetp: string;
    fIDpress: string;
    fIDtemp: string;
    fIDgasID: string;
    fIDgasStr: string;
  private
    fRange: double;
    fUnitstr: string;
    fEnabled: boolean;
    fFCSNameAlias: string;
    fDescription: string;
  end;

  TFlowCmdArrayRec = record
    id: byte;
    t: TFlowCmdType;
    paramd: double;
    parami: longint;
    paramb: boolean;
    params: string;
    responsemethod: TSynchroMethod; // if not nil then that is request to call synchronize to this method after completing or failing cmd
    // the result of last cmd is to be stored elsewhere
  end;

  TCmdQueueThreadSafe = class(TMultiReadExclusiveWriteSynchronizer)
  public
    constructor Create;
    destructor Destroy; override;
  public
    // this section will be used by aquire thread to pop commands and execute them
    Asize: word; // allocaed size of cmd array -  which works like queue "round-robin" style
    cmdArray: array of TFlowCmdArrayRec;
    strtpos: word; //
    endpos: word;
    function PopCmd(Var cmdrec: TFlowCmdArrayRec): boolean; // if ok, non empty then returns cmd from and deletes the oldest record
    function nWaiting(): word; // if >0 then there is  work and can use pop
  public
    // control interface only uses addcmd
    function AddCmd(cmd: TFlowCmdArrayRec): boolean;
    function CanAdd(): boolean; // if there is space for new cmd
  end;
  // cmdwaiting: boolean;  //signal by main thread that new cmd is ready - will be cleared by sub-thread after processing during "synchro reading"

  TFlowDevicesListThreadSafe = class(TMyLockableObject)
  // for devices to iterare over    //TThreadList
  public
    constructor Create;
    destructor Destroy; override;
  protected
    devslist: array of TFLowDevices; // will be used by aquire thread to poll each added device (read only)
    devsid: array [TFLowDevices] of byte; // addresses
    fTimeStamp: TDateTime;
  public
    procedure AddDev(dev: TFLowDevices; id: byte; lockit: boolean = true);
    function GetDev(i: byte; Var dev: TFLowDevices; Var id: byte;
      lockit: boolean = true): boolean; // returns true if OK
    procedure ClearAll(lockit: boolean = true);
  private // these two methods - to make setup by main control interface
    // procedure AddAquireName(s: string);
    // procedure GetAquireNames(Var sl: TStringlist); //creates copy
    function GetCount: longint;
    function GetCountNoLock: longint;
    function GetTimestamp: TDateTime;
    // function GetName(index: longint): string;  //returns empty string if error
  public
    property LastChanged: TDateTime read GetTimestamp; // locked access
    property LastChangedNoLock: TDateTime read fTimeStamp; // locked access
    property Count: longint read GetCount; // locked access
    property CountNoLock: longint read GetCountNoLock;
    // property Names[index: longint]: string read GetName;
  end;

  TALicatFlowCtrlRec = record
    name: string;
    namealias: string;
    d: byte;
    minSccm: double;
    maxSccm: double;
    maxFlowHWunit: double;
    enabled: boolean;
    units: string;
    sccmfactor: double;
  end;

  TFlowControlFCS_TCPIP = class(TFlowControllerObject)
    // this obejct controls one serial port with up to N Alicat flow controllers attached
    // it uses another thread to poll for data on regular basis
  public
    constructor Create(p: TPanel; ifaceID: string);
    // p panel to create status reporting controls
    destructor Destroy; override;
  public
    // inherited virtual functions - must override!
    function Initialize: boolean; override;
    procedure Finalize; override;
    procedure ResetConnection; override;
    // basic control functions
    function Aquire(Var data: TFlowData; Var flags: TCommDevFlagSet): boolean;
      override;
    function SetSetp(dev: TFLowDevices; val: double): boolean; override;
    function SetGas(dev: TFLowDevices; gas: TFlowGasType): boolean; override;
    function GetRange(dev: TFLowDevices): TRangeRecord; override;
  private
    // inherited fields
    // fName: string;
    // fDummy: boolean;
  private
    function getIsReady: boolean; override;
    function getIfaceStatus: TInterfaceStatus; override;
  private
    flock: boolean; // prevent multiple nesting calls to comm fucntions
    fFormatSettings: TFormatSettings;

  protected
    fLog: TMyLoggerThreadSafe;
    procedure _LogMsg(a: string); // in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
  private
    procedure setDebug(b: boolean); override;
    // fDataRegistry: TMyRegistryNodeObject;   //stores data and status - access methods are THREADSAFE!!!
  protected
    // aquire thread and objects
    fAcquireThread: TAquireThread_KolServer_TCPIP;
    procedure UpdateDevicesInThread;
    procedure UpdateAcquireObjectsInThread;
    procedure ThreadStart(timeoutMS: longint = 500);
    procedure ThreadStop;
    function IsThreadRunning(): boolean;
    function getThreadStatus: string;
  private
    fCmdSynchro: TCmdQueueThreadSafe; // controls access to cmd queue and variables
    // after finishig, signal can be sent through assigned method
    fDevicesSynchro: TFlowDevicesListThreadSafe;
    fAquireNameList: TStringList;
    fAquireNameListTStamp: TDateTime;
    freplylist: TStringList;
    procedure GenAquireNames(Var sl: TStringList);
  protected
    // thread control
    // fAquireThread: TAquireThreadV2_TCPIP; //TAquireThreadBaseV2;
    // fTargetCycleTimeMS: longword;
    // procedure fMyExecute; //TMyExecuteMethod
    // procedure fMyOnClientStatusChange;  //runs by thread after e.g. connection open
    // procedure fInsideThreadAcquire;
    // procedure fInsideThreadProcessCmd;
  protected
  public
    procedure ConfigureTCP(server: string; port: string);
    // called from main thread, must not block
    procedure getTCPConf(Var server: string; Var port: string);
    // called from main thread, must not block
    procedure ForceClientClose; // this is called from main thread - emergency close - will not check criticial section
    function IsPortOpen(): boolean;
  public
    procedure LoadConfig;
    procedure SaveConfig; // prepare variables to be saved config manager
  private
    // config storage registry items (do not destroy - managed in the registry objects)
    fIsconfigured: boolean;
    fRiTCPHost: TRegistryItem;
    fRiTCPPort: TRegistryItem;
    fRiProtocolVer: TRegistryItem;
  protected
    fpanelerf: TPanel;
    fMemo: TMemo;
    fInfoLabel: TLabel;
    procedure CreatePanelIface;
  public
    procedure UpdatePanelIface;
  public
    // user command
    fUserCmdReplyS: string;
    fUserCmdReplyTime: TDateTime;
    fUserCmdReplyIsNew: boolean;
    fLastCycleInsideMS: longint;
  public
    //
    function SendUserCmd(cmd: string): boolean;
    procedure ReceiveReplyFromThread; // "event handler" - reads reply from data.aswerlowlvl when beeing called as syncrhonize from thread
    function MakeCmdStr(cmd: TFlowCmdArrayRec): string;
    procedure UpdateDevRec(Var frec: TFlowRec; Var rlist: TStringList;
      ofs: byte);
  public
    // flowcontrollers to iterate over - it must be public, because I want to load/save conf from Control Form
    // after update to this array - the new settings must updated inside the aquire thread (there it is private var)
    fdevarray: array [TFLowDevices] of TALicatFlowCtrlRec;
    procedure UpdateDev(dev: TFLowDevices; en: boolean; a: byte;
      rngmin, rngmax: double);
    procedure FillDevRecFromRegistry(fd: TFLowDevices; Var frec: TFlowRec);
  private
    fMFCCount: longint;
    fDoingInit: TMVVariantThreadSafe;
    //
    fDesiredSetp: array [TFLowDevices] of double; // not accessed from acquire thread - only from main thread via acquire
  end;

Const
  CIdLastAquireTS = '_LastAquireTimeStamp';
  CIdLastElapsedMS = '_LastAquireElapsedMS';
  CIdAnswerLowLevel = '_AnswerLowLevel'; // for use with user cmd - answer to last USER cmd - in raw as received
  CIdCLientState = '_CLientState';
  CIdCLientStatusStr = '_CLientStatusStr';
  CIdInterfaceReady = '_InterfaceReady';

  // Var
  // IdDoingInit: string = '_DoingInit';
  // IdLastAquireTS: string = '_LastAquireTimeStamp';
  // IdLastElapsedMS: string = '_LastAquireElapsedMS';
  // IdAnswerLowLevel: string = '_AnswerLowLevel';       //for use with user cmd - answer to last USER cmd - in raw as received
  // IdCLientState: string = '_CLientState';
  // IdCLientStatusStr: string =  '_CLientStatusStr';
  // IdInterfaceReady: string = '_InterfaceReady';


  // ---------------------------------------
  // helper, conversion functions

function AlicatGasStrToType(gas: string): TFlowGasType;
function AlicateRecStatusToStr(rec: TALicatFlowCtrlRec): string;
function AlicatGasTypeToAlicatGasId(gastype: TFlowGasType): byte;
function AlicatGasIdToGasType(gasid: byte): TFlowGasType;


// ---------------------------------------
// Alicat Protocol description

// rs232 conf: 8-N-1-None (8  Data Bits, No Parity, 1 Stop Bit, and no Flow Control) protocol.
// from manual - how to configure terminal:
// Click on the “ASCII Setup” button and be sure the “Send Line Ends with Line
// Feeds” box is not checked and the “Echo Typed Characters Locally” box and
// the “Append Line Feeds to Incoming Lines” boxes are checked. Those settings
// not mentioned here are normally okay in the default position.
//
// ==>>messages are finsihed by <CR>
//
// example commnads
// change setpoint on A to 4.54:  AS4.54
// change gas for address B:   B$$#<Enter>
// read register 21   *R21
// write register *w91=X, where X is a positive integer from 1 to 65535, followed by “Enter”.

// poll:   <address><CR>

// known registers:
// 91: streaming mode delay
// 21: P of PID
// 22: D of PID

// 46: gas type same as control #
// 53: valve offset 0-65535  =0-100%
// 44: ??? identifies max range of flow controller?  2057 = 100sccm  10249 = 500sccm

// poll retun data format

// For mass flow controllers, there are six columns of data representing
// pressure, temperature, volumetric flow, mass flow, set-point, and the selected gas
//
// example
// +014.70 +025.00 +02.004 +02.004 2.004 Air

// Gas codes (new alicat) 15.2.2016 MV:
// 6=H2
// 0=Air
// 1=Ar
// 7=He
// 8=N2
// 11=O2

Implementation

uses Math, Windows, Forms, Controls;

constructor TFlowControlFCS_TCPIP.Create(p: TPanel; ifaceID: string);
begin
  inherited Create('Flow Control via FCSControl - ' + CInterfaceVer, ifaceID,
    false);
  //
  fLog := TMyLoggerThreadSafe.Create('!' + fIfaceID + '_', '',
    GlobalConfig.getAppPath + 'log' + CPathSlash);
  //
  fAcquireThread := TAquireThread_KolServer_TCPIP.Create(fLog);
  //
  fCmdSynchro := TCmdQueueThreadSafe.Create;
  fDevicesSynchro := TFlowDevicesListThreadSafe.Create;
  fAquireNameList := TStringList.Create;

  fIsconfigured := false;
  //
  //
  fpanelerf := p;
  CreatePanelIface;
  // freplylist := Tstringlist.Create;
  //
  if fAcquireThread <> nil then
    fFormatSettings := fAcquireThread.FormatSet
  else
    GetLocaleFormatSettings(0, fFormatSettings);
  //
  logmsg('TFlowControlFCS_TCPIP.Create: done.');
  _LogMsg('TFlowControlFCS_TCPIP.Create: done.');
end;

destructor TFlowControlFCS_TCPIP.Destroy;

begin
  if getIsReady then
    Finalize;
  if fAcquireThread <> nil then
    fAcquireThread.Destroy;
  //
  fDevicesSynchro.Destroy;
  fCmdSynchro.Destroy;
  fAquireNameList.Destroy;
  //
  fLog.Destroy;
  inherited;
end;

function TFlowControlFCS_TCPIP.getIsReady: boolean;
begin
  Result := false;
  if fAcquireThread = nil then
    exit;
  Result := fAcquireThread.IsReady;
end;

function TFlowControlFCS_TCPIP.getIfaceStatus: TInterfaceStatus;
begin
  Result := CISError;
  if fAcquireThread = nil then
    exit;
  // Result := fAcquireThread.sReady;
end;

procedure TFlowControlFCS_TCPIP.setDebug(b: boolean);
begin
  inherited;
  fAcquireThread.Debug := b;
end;

procedure TFlowControlFCS_TCPIP.CreatePanelIface;
var
  w, h: integer;

begin
  if fpanelerf = nil then
    exit;
  w := fpanelerf.Width;
  h := fpanelerf.Height;
  fInfoLabel := TLabel.Create(nil);
  with fInfoLabel do
  begin
    Parent := fpanelerf;
    autosize := false;
    Height := 20;
    top := 1;
    left := 1;
    Width := fpanelerf.Width;
    font.Color := clLime;
    Color := clBlack;
    Caption := 'Created...'
  end;
  fMemo := TMemo.Create(nil);
  with fMemo do
  begin
    Parent := fpanelerf;
    top := 25;
    left := 1;
    Width := fpanelerf.Width;
    Height := fpanelerf.Height - 30;
  end;
end;

procedure TFlowControlFCS_TCPIP.UpdatePanelIface;
Var
  i, cnt: integer;
  fd: TFLowDevices;
  id: byte;
  s: string;
begin
  if (fAcquireThread = nil) or (fRiTCPHost = nil) or (fRiTCPPort = nil) or
    (fRiProtocolVer = nil) or (fMemo = nil) then
  begin
    if fInfoLabel <> nil then
      fInfoLabel.Caption := 'NIL!';
    exit;
  end;
  if fInfoLabel <> nil then
  begin
    fInfoLabel.Caption := 'TCP: ' + fRiTCPHost.valStr + ':' +
      fRiTCPPort.valStr + ' || protocol ver' + fRiProtocolVer.valStr;
  end;
  if fMemo <> nil then
  begin
    fMemo.Lines.Clear;
    fMemo.Lines.Add('Iface configured: ' + BoolToStr(fIsconfigured));
    fMemo.Lines.Add('TCPClient: ' + fAcquireThread.data[IdKSCLientState]
        .valStr);
    fMemo.Lines.Add('Iface READY: ' + BoolToStr(fAcquireThread.IsReady));
    fMemo.Lines.Add('Thread: ' + fAcquireThread.getThreadStatus);
    fMemo.Lines.Add('Devices Count: ' + IntToStr(fDevicesSynchro.Count));
    fMemo.Lines.Add('FlowInterface READY: ' + BoolToStr(IsReady));

    fMemo.Lines.Add(' ');
    cnt := fDevicesSynchro.Count;
    fMemo.Lines.Add('Devices Count: ' + IntToStr(cnt));
    // fMemo.Lines.Add( 'Active device count: '+ IntToStr( fIsconfigured ) );
    fMemo.Lines.Add('Devices list: ');

    for i := 0 to cnt - 1 do
    begin
      fDevicesSynchro.GetDev(i, fd, id);
      s := fdevarray[fd].name + ' id: ' + IntToStr(fdevarray[fd].d)
        + ' alias: ' + fdevarray[fd].namealias + ' maxflow(hw units): ' +
        FloatToStr(fdevarray[fd].maxSccm) + ' enabled: ' + BoolToStr
        (fdevarray[fd].enabled) + ' units: ' + fdevarray[fd]
        .units + ' sccmfactor: ' + FloatToStr(fdevarray[fd].sccmfactor);
      fMemo.Lines.Add(s);
    end;

  end;
end;


// inherited functions overload


// **************
// basic control functions
// ---------------------

function TFlowControlFCS_TCPIP.Initialize: boolean;
Var
  b: boolean;
  t0: longword;
begin
  Result := false;
  if (fAcquireThread = nil) then
    exit;
  fAcquireThread.StopAcquire;
  //
  if not fIsconfigured then
  begin
    LoadConfig;
  end;
  //
  fDesiredSetp[CFlowAnode] := 0; // CFlowAnode, CFlowCathode, CFlowN2, CFlowRes
  fDesiredSetp[CFlowCathode] := 0;
  fDesiredSetp[CFlowN2] := 0;
  fDesiredSetp[CFlowRes] := 0;
  // TCpClient - open via thread in background
  // reset last aquire time
  setLastAcqTimeMS(-1);
  //
  UpdateAcquireObjectsInThread;
  fAcquireThread.RunAcquire;
  //
  fUserCmdReplyIsNew := false;
  // fready IS NOT SET HERE - at is set in the aquire thread after succesfull connection !!!!;
  Result := true;
  logmsg('TFlowControlFCS_TCPIP.Initialize:' + DevName + ' | Iface ver str: ' +
      InterfaceId);
end;

procedure TFlowControlFCS_TCPIP.Finalize;
begin
  logmsg('TFlowControlFCS_TCPIP.Finalize: Stopping thread...!!!');
  fAcquireThread.StopAcquire;
  fAcquireThread.ForceClientClose; // will force close even during openingn in progress (calls fTCPclient.Close)
end;

procedure TFlowControlFCS_TCPIP.GenAquireNames(Var sl: TStringList);

  procedure AddPollDeviceCmd(Var cmdlist: TStringList; id: string);
  Var
    s: string;
  begin
    if cmdlist = nil then
      exit;
    s := id;
    cmdlist.Add(s); // 'GET '+
    cmdlist.Add(s + 'SP');
    cmdlist.Add(s + 'P');
    cmdlist.Add(s + 'GAS');
  end;

Var
  i, n: longint;
  dev: TFLowDevices;
  did: byte;
  nalias: string;
begin
  sl.Clear;
  fDevicesSynchro.Lock;
  n := fDevicesSynchro.CountNoLock;
  for i := 0 to n - 1 do
  begin
    fDevicesSynchro.GetDev(i, dev, did, false);
    nalias := fdevarray[dev].namealias;
    AddPollDeviceCmd(sl, nalias);
  end;
  fDevicesSynchro.UnLock;
end;

procedure TFlowControlFCS_TCPIP.UpdateAcquireObjectsInThread;
Var
  sl: TStringList;
begin
  sl := TStringList.Create;
  if (sl = nil) or (fAcquireThread = nil) then
    exit;
  GenAquireNames(sl);
  fAcquireThread.ClearAcquireObjects;
  fAcquireThread.AddAcquireObjectList(sl);
  sl.Destroy;
end;

procedure TFlowControlFCS_TCPIP.LoadConfig;
Var
  i: integer;
  s, s2, fdname, fddef, fdalias, sec, secdev: string;
  slistmfc, slistmfcdef: string;
  fd: TFLowDevices;
  tl, tlmfc: TTokenList;
  aRI: TRegistryItem;
  RNIface, RNIfacenew, RNAliases: TMyRegistryNodeObject;
  fdrec: TAlicatFlowCtrlRec;
  xfd: byte;
begin
  // flowdevices
  sec := CInterfaceVer2; // fIfaceID;
  secdev := SecIdDevices;
  RNIface := RegistryHW.GetOrCreateSection(sec);
  RNIfacenew := RegistryHW.GetOrCreateSection(fIfaceID);
  RNAliases := RegistryHW.GetOrCreateSection(SecIdAliases);
  // Assert((RNIface=nil) or (RNAliases=nil) );
  if ((RNIface = nil) or (RNAliases = nil)) then
    exit; ;
  //
  RNIfacenew.GetOrCreateItem(IdHelpDummy + '1',
    'HWMFCLIST=comma separated list of nicknames');
  RNIfacenew.GetOrCreateItem(IdHelpDummy + '2',
    'HWMFCNickName=Range(in default unit);default unit string;Enabled(1|0);FCSControlName-reference string;Comment string');
  slistmfcdef := 'MFCA,MFCN,MFCC,MFCMIX';
  //slistmfc := RNIface.GetOrCreateItem(IdHWMFClist, slistmfcdef).valStr;
  slistmfc := RNIface.GetOrCreateItem('MFClist', slistmfcdef).valStr;
  ParseStrSep(slistmfc, ',;', tlmfc);
  //
  for i := 0 to Length(tlmfc) - 1 do
  begin
    fdname := tlmfc[i].s;
    fddef := IntToStr(i+1) + ';100;1;slpm;1';
    //new fddef := '100;slpm;1;MFC' + IntToStr(i) + ';no comment';
    s := RNIface.GetOrCreateItem(fdname, fddef).valStr;

    //new fddef := IntToStr(i) + ';100;1';
    s := RNIface.GetOrCreateItem(fdname, fddef).valStr;
    ParseStrSep(s, ';', tl);
    if Length(tl) >= 3 then
    begin
      // RegistryHW.NewItemDef(secdev, fdname, fdname);
      // aRI := RegistryHW.ItemExists(SecIdAliases, fdname);   //!!do not create alias automatically
      fdalias := RNAliases.GetOrCreateItem(fdname, IntToStr(i)).valStr;
      fdrec.name := fdname + '';
      fdrec.namealias := fdalias;
      fdrec.d := MyXStrToInt(tl[0].s);
      fdrec.maxSccm := MyStrToFloat(tl[1].s);
      fdrec.minSccm := 0;
      fdrec.enabled := StrToBool(tl[2].s);
    end;
    fdrec.units := 'sccm';
    if Length(tl) >= 4 then
      fdrec.units := tl[3].s;
    fdrec.sccmfactor := 1.0;
    if Length(tl) >= 5 then
      fdrec.sccmfactor := MyStrToFloat(tl[4].s);
    if IsNAN(fdrec.sccmfactor) then
      fdrec.sccmfactor := 1.0;
    if fdrec.sccmfactor = 0 then
      fdrec.sccmfactor := 1.0;

    //store to flowdevarray
    xfd := fdrec.d - 1;  //internal indexed from 0
    fd := CFlowRes;  //fallback default
    if (fdrec.d >= Ord( Low( TFlowDevices))) and (fdrec.d<= Ord( High( TFlowDevices) )) then fd := TFlowDevices( xfd )
      else fd := CFlowRes;
    fdevarray[fd] := fdrec;

  end; //for i
  // if I<= Ord( High( TFlowDevices) ) then fd := TFlowDevices( i )
  // else fd := CFlowRes;

  // Use device config
  UpdateDevicesInThread;
  //
  // TCP parameters + protocolo version
  fRiTCPHost := RegistryHW.NewItemDef(sec, 'TCPHost', 'localhost');
  // s := fConfClient.Load('TCPHost', 'localhost');
  fRiTCPPort := RegistryHW.NewItemDef(sec, 'TCPPort', '20005');
  // s2 := fConfClient.Load('TCPPort', '20005');
  fRiProtocolVer := RegistryHW.NewItemDef(sec, 'ProtocolVersion', 2);
  // i := fConfClient.Load('ProtocolVersion', 1);
  //
  if (fAcquireThread <> nil) and (fRiTCPHost <> nil) and (fRiTCPPort <> nil)
    and (fRiProtocolVer <> nil) then
    fAcquireThread.setTCPconf(fRiTCPHost.valStr, fRiTCPPort.valStr,
      fRiProtocolVer.valInt);
  //
  // other
  fIsconfigured := true;
end;

procedure TFlowControlFCS_TCPIP.SaveConfig;
begin
end;

procedure TFlowControlFCS_TCPIP.ResetConnection;
// close port, open port - this should help it seems
begin
  logmsg('TFlowControlFCS_TCPIP.ResetConnection: Closing and opening PORT!!!');
  fAcquireThread.ResetConnection;
end;

procedure TFlowControlFCS_TCPIP.UpdateDevRec(Var frec: TFlowRec;
  Var rlist: TStringList; ofs: byte);
begin
  InitWithNAN(frec);
  if rlist = nil then
    exit;
  if rlist.Count < ofs + 3 then
    exit;
  try
    frec.timestamp := Now;
    frec.massflow := MyStrToFloat(rlist.Strings[ofs]);
    frec.setpoint := MyStrToFloat(rlist.Strings[ofs + 1]);
    frec.pressure := MyStrToFloat(rlist.Strings[ofs + 2]);
    frec.gastype := AlicatGasIdToGasType(MyXStrToInt(rlist.Strings[ofs + 3]));
    frec.volflow := NAN;
    frec.temp := NAN;
  except
    on E: Exception do
    begin
      _LogMsg('E: ' + E.Message)
    end;
  end;
end;

procedure TFlowControlFCS_TCPIP.FillDevRecFromRegistry(fd: TFLowDevices;
  Var frec: TFlowRec);
Var
  fdname, fdnameKol: string;
  i: longint;
  ri: TRegistryItem;
begin
  // ;flow-controllers
  // MFC1=;MFC1 Anode;;;sccm
  // MFC1Set=;Setpoint;;;sccm
  // MFC1SP=;Setpoint readback;;;sccm
  // MFC1T=;Temperature;;;�C
  // MFC1P=;Pressure;;;bar
  // MFC1VF=;Volumetric flow;;;ccm
  // MFC1GasCode=;Selected gas
  // MFC1Gas=;Selected gas index

  InitWithNAN(frec);
  if fAcquireThread = nil then
    exit;
  fdname := fdevarray[fd].namealias + '';
  Uniquestring(fdname);
  try
    frec.massflow := fAcquireThread.data[fdname].valDouble;
    frec.setpoint := fAcquireThread.data[fdname + 'SP'].valDouble;
    frec.pressure := fAcquireThread.data[fdname + 'P'].valDouble;
    i := fAcquireThread.data[fdname + 'GAS'].valInt;
    frec.gastype := AlicatGasIdToGasType(i);
    frec.timestamp := fAcquireThread.data[CIdLastAquireTS].valDouble;
  except
    on E: Exception do
    begin
      _LogMsg('E: ' + E.Message)
    end;
  end;
  //
  if not IsNAN(frec.timestamp) then
  begin
    FlagUpdate(TimeDeltaNow(frec.timestamp) > CTimeDeltaNotRespondingMS,
      CFlowDevNotResponding, frec.flagSet);
  end;
end;

function TFlowControlFCS_TCPIP.Aquire(Var data: TFlowData;
  Var flags: TCommDevFlagSet): boolean;
//
Var
  d: TFLowDevices;
  lastaq: TDateTime;
begin
  Result := false;
  flags := [];
  for d := Low(TFLowDevices) to High(TFLowDevices) do
    InitWithNAN(data[d]);
  if not getIsReady then
  begin
    Include(flags, CCSNotReady);
    exit;
  end;
  if fAcquireThread = nil then
    exit;
  for d := Low(TFLowDevices) to High(TFLowDevices) do
  begin
    if fdevarray[d].enabled then
    begin
      FillDevRecFromRegistry(d, data[d]);
    end
    else
    begin
      // InitWithNAN( data[d]);  //for disabled devices, fill NAN
      Include(data[d].flagSet, CFlowDevDisabled);
    end;
  end;
  lastaq := fAcquireThread.data[CIdLastAquireTS].valDouble;
  if IsNAN(lastaq) then
    lastaq := 0;
  fLastCycleInsideMS := fAcquireThread.data[CIdLastElapsedMS].valInt;
  setLastAcqTimeMS(fLastCycleInsideMS);
  // check for communication connection lost
  if TimeDeltaNowMS(lastaq) > CFlowTimeoutConstMS then
    Include(flags, CCSConnectionLost);
  Result := true;
end;

function TFlowControlFCS_TCPIP.SetSetp(dev: TFLowDevices; val: double): boolean;
Var
  min, max, oldv: double;
  cmds, fdname: string;
  cmdsync: TCmdQueueThreadSafe;
  b, CanAdd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
  altsp: word;
  valsccm: double;
Const
  epsilon = 0.01;
begin
  Result := false;
  if not getIsReady then
    exit;
  //
  oldv := val;
  min := fdevarray[dev].minSccm;
  max := fdevarray[dev].maxSccm; // in hw units
  if Debug then
    logmsg('TFlowControlFCS_TCPIP.SetSetp: dev ' + FlowDevToStr(dev)
        + ' sp: ' + FloatToStr(val) + ' (min: ' + FloatToStr(min)
        + ',max: ' + FloatToStr(max));
  // convert unit by factor to sccm
  valsccm := val * fdevarray[dev].sccmfactor;
  // from now on use converted value
  val := valsccm;

  if not MakeSureIsInRange(val, min - epsilon, max + epsilon) then
    LogWarning(
      'TFlowControlFCS_TCPIP.SetSetp:  setpoint outside allowed range - ADJUSTING!!!! (from ' + FloatToStr(oldv) + 'sccm to ' + FloatToStr(val) + 'hwflowunit)');
  //
  fDesiredSetp[dev] := val;
  // calculate compatibility setpoin value (it is in relative value from 0 to 64000 related to maxvalue  fo flow => depends on device range
  // prepare cmd
  cmdrec.id := fdevarray[dev].d;
  cmdrec.t := CFlowCmdSetSP;
  cmdrec.paramd := val;
  cmdrec.params := fdevarray[dev].namealias;
  cmdrec.parami := altsp;
  cmdrec.paramb := false;
  cmdrec.responsemethod := nil;
  //
  fdname := fdevarray[dev].namealias;
  cmds := 'SET ' + fdname + 'SET ' + FloatToStr(val, fFormatSettings);
  if fAcquireThread <> nil then
    fAcquireThread.AddCommand(cmds);
  //
  if Debug then
    logmsg(
      'iiii TFlowControlFCS_TCPIP.SetSetp - addded cmd, total waiting now: ' +
        IntToStr(nw));
  Result := true;
end;

{ backup
  function TFlowControlFCS_TCPIP.SetSetp(dev: TFlowDevices; val: double): boolean;
  Var
  min, max, oldv: double;
  cmds, fdname: string;
  cmdsync: TCmdQueueThreadSafe;
  b, canadd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
  altsp: word;
  Const
  epsilon = 0.01;
  begin
  Result := false;
  if not getIsReady then exit;
  //
  oldv := val;
  min := fdevarray[dev].minSccm;
  max := fdevarray[dev].maxSccm;
  if Debug then logmsg('TFlowControlFCS_TCPIP.SetSetp: dev ' + FlowDevToStr(dev) + ' sp: ' + FloatToStr(val) + ' (min: ' + FloatToStr(min) + ',max: ' + FloatToStr(max) );
  if not MakeSureIsInRange(val, min-epsilon, max+epsilon) then LogWarning('TFlowControlFCS_TCPIP.SetSetp:  setpoint outside allowed range - ADJUSTING!!!! (from ' + FloatToStr(oldv) +' to ' + FloatToStr(val) +')');
  //
  fDesiredSetp[dev] := val;
  //calculate compatibility setpoin value (it is in relative value from 0 to 64000 related to maxvalue  fo flow => depends on device range
  //prepare cmd
  cmdrec.id := fdevarray[dev].d;
  cmdrec.t := CFlowCmdSetSP;
  cmdrec.paramd := val;
  cmdrec.params := fdevarray[dev].namealias;
  cmdrec.parami := altsp;
  cmdrec.paramb := false;
  cmdrec.responsemethod := nil;
  //
  fdname := fdevarray[dev].namealias;
  cmds := 'SET '+fdname + 'SET ' + FloatToStr( val, fFormatSettings);
  if fAcquireThread<>nil then fAcquireThread.AddCommand( cmds );
  //
  if Debug then logmsg('iiii TFlowControlFCS_TCPIP.SetSetp - addded cmd, total waiting now: '+ IntToStr(nw) );
  Result := true;
  end;
}

function TFlowControlFCS_TCPIP.SetGas(dev: TFLowDevices;
  gas: TFlowGasType): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  cmds, fdname: string;
  b, CanAdd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
  thisid: string;
begin
  Result := false;
  if not getIsReady then
    exit;
  //
  thisid := 'TFlowControlFCS_TCPIP.SetGas';
  if Debug then
    logmsg(thisid + ': dev ' + FlowDevToStr(dev) + ' sp: ' + FlowGasTypeToStr
        (gas));
  // prepare cmd
  cmdrec.id := fdevarray[dev].d;
  cmdrec.params := fdevarray[dev].namealias;
  cmdrec.t := CFLowCmdSetGas;
  cmdrec.parami := AlicatGasTypeToAlicatGasId(gas);
  cmdrec.responsemethod := nil;
  if gas = CGasUnknown then
  begin
    LogWarning(thisid + ': invalid argument of gas ID');
    exit;
  end;
  // enqueue new command into aquire thread
  //
  fdname := fdevarray[dev].namealias;
  cmds := 'SET ' + fdname + 'GAS ' + IntToStr(AlicatGasTypeToAlicatGasId(gas));
  if fAcquireThread <> nil then
    fAcquireThread.AddCommand(cmds);
  //
  if Debug then
    logmsg(thisid + ': iii addded cmd, total waiting now: ' + IntToStr(nw));
  Result := true;
end;
{
  CFlowCmdSetSP:
  begin
  s := 'SET ' + cmd.params+'SET '+ FloatToStr( cmd.paramd , fFormatSettings);
  end;
  CFlowCmdUserCmd:
  begin
  s := cmd.params + '';  //force copy
  //_LogMsg('Alicat USER CMD: ' + BinStrToPrintStr(s) );
  end;
  CFlowCmdSetGas:
  begin
  s :=  'SET ' + cmd.params+'GAS '+ IntToStr( cmd.parami );
  end;
  }

function TFlowControlFCS_TCPIP.GetRange(dev: TFLowDevices): TRangeRecord;
begin
  Result. low := fdevarray[dev].minSccm;
  Result. high := fdevarray[dev].maxSccm;
end;



// aquire thread, execute poll devices

function TFlowControlFCS_TCPIP.MakeCmdStr(cmd: TFlowCmdArrayRec): string;
Var
  msg, rxb: string;
  b: boolean;
  toklist: TTokenList;
  d1, d2, d3, d4, d5: double;
  w: word;
  devid, gas: string;
  frec: TFlowRec;
  s, s2: string;

begin
  Result := '';
  if Debug then
    _LogMsg('TMyFlowAquireThread.MakeCmdDone: addr: ' + IntToStr(cmd.id));
  // generate msg based on cmd
  case cmd.t of
    CFlowCmdSetSP:
      begin
        s := 'SET ' + cmd.params + 'SET ' + FloatToStr(cmd.paramd,
          fFormatSettings);
      end;
    CFlowCmdUserCmd:
      begin
        s := cmd.params + ''; // force copy
        // _LogMsg('Alicat USER CMD: ' + BinStrToPrintStr(s) );
      end;
    CFLowCmdSetGas:
      begin
        s := 'SET ' + cmd.params + 'GAS ' + IntToStr(cmd.parami);
      end;
  end;

  if Debug then
    _LogMsg('TMyFlowAquireThread.MakeCmdDone: sending cmd: ' + BinStrToPrintStr
        (msg));
  Result := s;
end;

procedure TFlowControlFCS_TCPIP.ConfigureTCP(server: string; port: string);
// called from main thread, must not block
Var
  s1, s2: string;
  x: integer;
begin
  if fAcquireThread = nil then
    exit;
  fAcquireThread.getTCPConf(s1, s2, x);
  fAcquireThread.setTCPconf(server, port, x);
end;

procedure TFlowControlFCS_TCPIP.getTCPConf(Var server: string;
  Var port: string); // called from main thread, must not block
Var
  x: integer;
begin
  server := '';
  port := '';
  if fAcquireThread = nil then
    exit;
  fAcquireThread.getTCPConf(server, port, x);
end;

procedure TFlowControlFCS_TCPIP.ForceClientClose; // this is called from main thread - emergency close - will not check criticial section
begin
  if fAcquireThread = nil then
    exit;
  fAcquireThread.ForceClientClose;
end;

function TFlowControlFCS_TCPIP.IsPortOpen(): boolean;
begin
  Result := false;
  if fAcquireThread = nil then
    exit;
  Result := fAcquireThread.isClientConnected;
end;


// TALicatFlowCtrlRec = record
// d: byte;
// minSccm: double;
// maxSccm: double;
// enabled: boolean;
// end;

procedure TFlowControlFCS_TCPIP.ThreadStart;
begin
  if fAcquireThread = nil then
    exit;
  logmsg('TFlowControlFCS_TCPIP.ThreadStart: calling RESUME');
  fAcquireThread.RunAcquire; // TThread  //in case it was suspended
end;

procedure TFlowControlFCS_TCPIP.ThreadStop;
begin
  if fAcquireThread = nil then
    exit;
  logmsg('TFlowControlFCS_TCPIP.ThreadStart: calling SUSPEND');
  fAcquireThread.StopAcquire;
end;

function TFlowControlFCS_TCPIP.IsThreadRunning(): boolean;
begin
  Result := false;
  if fAcquireThread = nil then
    exit;
  Result := fAcquireThread.IsThreadRunning;
end;

function TFlowControlFCS_TCPIP.getThreadStatus: string;
begin
  Result := 'NIL';
  if fAcquireThread = nil then
    exit;
  Result := fAcquireThread.getThreadStatus;
end;

procedure TFlowControlFCS_TCPIP.UpdateDevicesInThread;
Var
  devsync: TFlowDevicesListThreadSafe;
  d: TFLowDevices;
begin
  devsync := fDevicesSynchro;
  if devsync = nil then
    exit;
  devsync.ClearAll();
  for d := low(TFLowDevices) to High(TFLowDevices) do
  begin
    if fdevarray[d].enabled then
      devsync.AddDev(d, fdevarray[d].d);
  end;
end;

function TFlowControlFCS_TCPIP.SendUserCmd(cmd: string): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  b, CanAdd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
begin
  Result := false;
  if not getIsReady then
    exit;
  if Debug then
    logmsg('TFlowControlFCS_TCPIP.SendUserCmd: ' + BinaryStrTostring(cmd));
  // prepare cmd
  cmdrec.t := CFlowCmdUserCmd;
  cmdrec.params := cmd + '';
  cmdrec.responsemethod := ReceiveReplyFromThread;
  // enqueue new command into aquire thread
  if fAcquireThread = nil then
  begin
    logmsg('TFlowControlFCS_TCPIP.SetSetp AquireThread=nil ');
    exit;
  end;
  fAcquireThread.AddCommand(cmd);
  Result := true;
end;

procedure TFlowControlFCS_TCPIP.ReceiveReplyFromThread;
// reads reply from data.aswerlowlvl
//
Var
  copys: string;
begin
  if fAcquireThread = nil then
    exit;
  // if fDataRegistry=nil then exit;
  // fUserCmdReplyS := fDataRegistry.valStr[ CIdAnswerLowLevel ];
  fUserCmdReplyTime := Now;
  fUserCmdReplyIsNew := true;
  logmsg('TFlowControlFCS_TCPIP.ReceiveReplyFromThread str=' + BinStrToPrintStr
      (fUserCmdReplyS));
end;

procedure TFlowControlFCS_TCPIP.UpdateDev(dev: TFLowDevices; en: boolean;
  a: byte; rngmin, rngmax: double);
begin
  with fdevarray[dev] do
  begin
    enabled := en;
    d := a;
    minSccm := rngmin;
    maxSccm := rngmax;
  end;
end;

procedure TFlowControlFCS_TCPIP._LogMsg(a: string);
begin
  if fLog = nil then
    exit;
  fLog.logmsg(a);
end;

// ****************************************************

constructor TCmdQueueThreadSafe.Create;
Const
  CDefaultCmdArraySize = 100;
begin
  inherited;
  Asize := CDefaultCmdArraySize;
  setLength(cmdArray, CDefaultCmdArraySize);
  strtpos := 0;
  endpos := 0; // strpos == endpos =-> empty
end;

destructor TCmdQueueThreadSafe.Destroy;
begin
  Asize := 0;
  setLength(cmdArray, 0);
  inherited;
end;

function TCmdQueueThreadSafe.PopCmd(Var cmdrec: TFlowCmdArrayRec): boolean;
begin
  Result := false;
  cmdrec.t := CFlowCmdSetUNDEF;
  if strtpos = endpos then
    exit; // meaning array is empty
  cmdrec := cmdArray[strtpos];
  Inc(strtpos);
  if strtpos >= Asize then
    strtpos := 0;
  Result := true;
end;

function TCmdQueueThreadSafe.nWaiting(): word; // if >0 then there is  work and can use pop
begin
  if endpos >= strtpos then
    Result := endpos - strtpos
  else
    Result := Asize - (strtpos - endpos);
end;

function TCmdQueueThreadSafe.AddCmd(cmd: TFlowCmdArrayRec): boolean;
begin
  Result := false;
  if not CanAdd then
    exit;
  cmdArray[endpos] := cmd;
  Inc(endpos);
  if endpos >= Asize then
    endpos := 0;
  Result := true;
end;

function TCmdQueueThreadSafe.CanAdd(): boolean; // if there is space for new cmd
begin
  Result := false;
  if nWaiting < (Asize - 1) then
    Result := true; // the useful maximum capacity is Asize-1 (at full, one index is unsued)
end;

// ****************************************************

constructor TFlowDevicesListThreadSafe.Create;
begin
  inherited Create;
  fTimeStamp := Now;
end;

destructor TFlowDevicesListThreadSafe.Destroy;
begin
  inherited;
end;

procedure TFlowDevicesListThreadSafe.ClearAll(lockit: boolean = true);
begin
  if lockit then
    Lock;
  fTimeStamp := Now;
  setLength(devslist, 0);
  if lockit then
    UnLock;
end;

procedure TFlowDevicesListThreadSafe.AddDev(dev: TFLowDevices; id: byte;
  lockit: boolean = true);
Var
  ndevs: integer;
begin
  if lockit then
    Lock;
  ndevs := Length(devslist) + 1;
  setLength(devslist, ndevs);
  devslist[ndevs - 1] := dev;
  devsid[dev] := id;
  fTimeStamp := Now;
  if lockit then
    UnLock;
end;

function TFlowDevicesListThreadSafe.GetDev(i: byte; Var dev: TFLowDevices;
  Var id: byte; lockit: boolean = true): boolean; // returns true if OK
begin
  Result := false;
  if lockit then
    Lock;
  if not((i >= 0) and (i < Length(devslist))) then
    exit;
  dev := devslist[i];
  id := devsid[dev];
  Result := true;
  if lockit then
    UnLock;
end;

function TFlowDevicesListThreadSafe.GetCount: longint;
begin
  Lock;
  Result := Length(devslist);
  UnLock;
end;

function TFlowDevicesListThreadSafe.GetCountNoLock: longint;
begin
  Result := Length(devslist);
end;

function TFlowDevicesListThreadSafe.GetTimestamp: TDateTime;
begin
  Lock;
  Result := fTimeStamp;
  UnLock;
end;

{ procedure TFlowDevicesListThreadSafe.GetAquireNames(Var sl: TStringlist); //creates copy
  Var
  i: integer;
  begin
  if sl=nil then exit;
  lock;
  sl.Clear;
  for i:=0 to faquireNames.Count -1 do sl.Add( faquireNames.Strings[i] );
  unlock;
  end;
}

{
  procedure TFlowDevicesListThreadSafe.GetName(index: longint): string;  //returns empty string if error
  Var
  c: integer;
  begin
  Result := '';
  lock;
  c := faquireNames.Count -1;
  if (index>0) and (index<=c) then Result := faquireNames.Strings[index];
  unlock;
  end;
}


// ****************************************************

function AlicatGasStrToType(gas: string): TFlowGasType;
begin
  Result := CGasUnknown;
  if gas = 'N2' then
    Result := CGasN2;
  if gas = 'O2' then
    Result := CGasO2;
  if gas = 'H2' then
    Result := CGasH2;
  if gas = 'Air' then
    Result := CGasAir;
  if gas = 'CO' then
    Result := CGasCO;
  if gas = 'Ar' then
    Result := CGasAr;
  if gas = 'He' then
    Result := CGasHe;
end;

function AlicateRecStatusToStr(rec: TALicatFlowCtrlRec): string;
begin
  if rec.enabled = false then
  begin
    Result := 'Disabled.';
    exit;
  end;
  Result := 'Addr: ' + IntToStr(rec.d) + ' Range ' + FloatToStr(rec.minSccm)
    + ':' + FloatToStr(rec.maxSccm) + ' Unit ' + rec.units + ' SccmFactor ' +
    FloatToStr(rec.sccmfactor);
end;

function AlicatGasIdToGasType(gasid: byte): TFlowGasType;
// Gas codes (new alicat) 15.2.2016 MV:
// 6=H2
// 0=Air
// 1=Ar
// 7=He
// 8=N2
// 11=O2
begin
  Result := CGasUnknown;
  case gasid of
    8:
      Result := CGasN2;
    6:
      Result := CGasH2;
    11:
      Result := CGasO2;
    0:
      Result := CGasAir;
    7:
      Result := CGasHe;
    1:
      Result := CGasAr;
  end;
end;

function AlicatGasTypeToAlicatGasId(gastype: TFlowGasType): byte;
// Gas codes (new alicat) 15.2.2016 MV:
// 6=H2
// 0=Air
// 1=Ar
// 7=He
// 8=N2
// 11=O2
begin
  Result := 0;
  case gastype of
    CGasN2:
      Result := 8;
    CGasH2:
      Result := 6;
    CGasO2:
      Result := 11;
    CGasCO:
      Result := 6;
    CGasAir:
      Result := 0;
    CGasHe:
      Result := 7;
    CGasAr:
      Result := 1;
  end;

end;

{ TMFCSimple }

constructor TMFCSimple.Create(_nickname: string;
  registry: TMyRegistryNodeObject);
begin
  FworkRN := registry;
  Fnickname := _nickname;
  FRIsetp := FworkRN.GetOrCreateItem(_nickname + 'SET', 0);
  if FRIsetp <> nil then
    FRIsetp.AfterUpdateEvent.RegisterEventMethod(OnUpdateRegistry);
  FRIgasID := FworkRN.GetOrCreateItem(_nickname + 'GASID', 0);
  if FRIgasID <> nil then
    FRIgasID.AfterUpdateEvent.RegisterEventMethod(OnUpdateRegistry);
end;

destructor TMFCSimple.Destroy;
begin

  inherited;
end;

procedure TMFCSimple.OnUpdateRegistry;
Var
  d: double;
  i: integer;
begin
  Assert((FRIsetp <> nil) and (FRIgasID <> nil));
  d := FRIsetp.valDouble;
  if d <> fLastSetp then
    SetFlow(d);
  i := FRIgasID.valInt;
  if i <> fLastGasId then
    SetGas(i);
  ShowMessage('in on update');
end;

{ THwMFCAlicatFCSControl }

constructor THwMFCAlicatFCSControl.Create(_nickname: string;
  registry: TMyRegistryNodeObject);
begin
  Fnickname := _nickname;
  FworkRN := registry;

end;

destructor THwMFCAlicatFCSControl.Destroy;
begin

  inherited;
end;

procedure THwMFCAlicatFCSControl.GenerateAcquireNames(var cmdlist: TStringList);
begin

end;

function THwMFCAlicatFCSControl.getFlow: double;
begin
  Result := FworkRN.GetOrCreateItem(fIDflow, -1.0).valDouble;
end;

function THwMFCAlicatFCSControl.getGasId: byte;
begin
  Result := FworkRN.GetOrCreateItem(fIDgasID, 0).valInt;
end;

function THwMFCAlicatFCSControl.getGsStr: string;
begin
  Result := FworkRN.GetOrCreateItem(fIDgasStr, 'undef').valStr;
end;

function THwMFCAlicatFCSControl.getPress: double;
begin
  Result := FworkRN.GetOrCreateItem(fIDpress, -1.0).valDouble;
end;

function THwMFCAlicatFCSControl.getSetp: double;
begin
  Result := FworkRN.GetOrCreateItem(fIDsetp, -1.0).valDouble;
end;

function THwMFCAlicatFCSControl.getTemp: double;
begin
  Result := FworkRN.GetOrCreateItem(fIDtemp, -1.0).valDouble;
end;

function THwMFCAlicatFCSControl.GetPackedParamStr: string;
begin
  Result := FloatToStr(fRange) + ';' + fUnitstr + ';' + BoolToStr(fEnabled)
    + ';' + fFCSNameAlias + ';' + fDescription;
end;

function THwMFCAlicatFCSControl.ObtainStoichFactorForGasId(AlicatID: byte)
  : double;
begin

end;

procedure THwMFCAlicatFCSControl.SetFromParamStr(s: string);
Var
  tl: TTokenList;
begin
  // example: fddef := '100;slpm;1;MFC'+IntToStr(I)+';no comment';
  ParseStrSep(s, ';', tl);
  if Length(tl) >= 5 then
  begin
    // RegistryHW.NewItemDef(secdev, fdname, fdname);
    // aRI := RegistryHW.ItemExists(SecIdAliases, fdname);   //!!do not create alias automatically
    fRange := MyStrToFloat(tl[0].s);
    fUnitstr := tl[1].s;
    fEnabled := StrToBool(tl[2].s);
    fFCSNameAlias := tl[3].s;
    fDescription := tl[4].s;
  end;
end;

end.

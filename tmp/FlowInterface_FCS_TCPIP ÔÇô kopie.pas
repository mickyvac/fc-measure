unit FlowInterface_FCS_TCPIP;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs, ExtCtrls, Graphics,
  myutils, MyParseUtils, Logger, LoggerThreadSafe, ConfigManager, FormGLobalConfig,
  HWAbstractDevicesNew2, MyAquireThreadNEW_TCPIP, MyTCPClientForKolServer,
  MyTCPClient_indy; //MyAquireThreadPrototype,

{create descendant of virtual abstract FLOW object and define its methods
especially including definition of configuration and setup methods}

Const
  CInterfaceVer = 'Flow-FCScontrol-TCPIP';
  CFlowTimeoutConstMS = 200;

Type

  //flow commands

  TFlowCmdType = (CFlowCmdSetUNDEF, CFlowCmdSetSP, CFLowCmdSetGas, CFlowCmdUserCmd);

  TSynchroMethod = procedure of object;

  TFlowDataThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)   //for reporting data back
  public
    constructor Create;
    destructor Destroy; override;
  public
    stats: TFlowData;
    fLastSuccessAquireTime: TDateTime;
    LastAquireDurMS: longword;
    aswerlowlvl: string;  //for use with user cmd - answer to last USER cmd - in raw as received
  end;

  TFlowCmdArrayRec = record
    id: byte;
    t: TFlowCmdType;
    paramd: double;
    parami: longint;
    paramb: boolean;
    params: string;
    responsemethod: TSynchroMethod;  //if not nil then that is request to call synchronize to this method after completing or failing cmd
                                     //the result of last cmd is to be stored elsewhere
  end;

  TCmdQueueThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)
  public
    constructor Create;
    destructor Destroy; override;
  public
    //this section will be used by aquire thread to pop commands and execute them
    Asize: word; //allocaed size of cmd array -  which works like queue "round-robin" style
    cmdArray: array of TFlowCmdArrayRec;
    strtpos: word; //
    endpos: word;
    function PopCmd(Var cmdrec: TFlowCmdArrayRec): boolean; //if ok, non empty then returns cmd from and deletes the oldest record
    function nWaiting(): word;  //if >0 then there is  work and can use pop
  public
    //control interface only uses addcmd
    function AddCmd(cmd: TFlowCmdArrayRec): boolean;
    function CanAdd(): boolean; // if there is space for new cmd
  end;
  //    cmdwaiting: boolean;  //signal by main thread that new cmd is ready - will be cleared by sub-thread after processing during "synchro reading"



  TFlowDevicesListThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)     //for devices to iterare over    //TThreadList
  public
    constructor Create;
    destructor Destroy; override;
  public
    devslist: array of TFLowDevices;              // will be used by aquire thread to poll each added device (read only)
    devsid: array[TFLowDevices] of byte; //addresses
  public    //these two methods - to make setup by main control interface
    procedure ClearAll;
    procedure AddDev(dev: TFlowDevices; id: byte);
    function GetDev(i: byte; Var dev: TFlowDevices; Var id: byte): boolean;  //returns true if OK
    function GetNDev: byte;  //returns true if OK
  end;


 {

  TMyFlowAquireThread = class (TAquireThreadBaseV2)
  //!!!!!NOTE!!!!
    public
      constructor Create;
      destructor Destroy; override;
    public

    protected
      procedure ExecuteInnerLoop; override;
      function IsEndOfMessage(Const recvbuf: string): boolean; override;  //descendadnt must define this for communication to work
                                                                              // used by SendReceive
    private
      procedure PollDevice(devaddr: char; dev: TFlowDevices);
      function MakeCmdDone( cmd: TFlowCmdArrayRec ): string;
    private
      function ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
    private
      fFormatSettings: TFormatSettings;
      frefreshint: longint;
      //fnextrefreshtime: array[TFLowDevices] of TDateTime; //index is the same as in devicessynchro: TFlowDevicesListThreadSafe
      //fnextpoll: array[TFLowDevices] of TDateTime;
      fcommtimeoutcnt: array[TFLowDevices] of byte;
      fTargetCycleTimeMS: longint;
      fQueryTimeoutMS: longint;
      fLastCycleInsideMS: longint
  end;
  //TSimpleEvent      //sleep
      }




  TALicatFlowCtrlRec = record
    d: byte;
    minSccm: double;
    maxSccm: double;
    enabled: boolean;
  end;





  TFlowControlFCS_TCPIP = class (TFlowControllerObject)
    //this obejct controls one serial port with up to N Alicat flow controllers attached
    //it uses another thread to poll for data on regular basis
    public
      constructor Create( p: TPanel);
      destructor Destroy; override;
    public
    //inherited virtual functions - must override!
      function Initialize: boolean; override;
      procedure Finalize; override;
      procedure ResetConnection; override;
      //basic control functions
      function Aquire(Var data: TFlowData; Var flags: TCommDevFlagSet): boolean; override;
      function SetSetp(dev: TFlowDevices; val: double): boolean; override;
      function SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean; override;
      function GetRange(dev: TFlowDevices): TRangeRecord; override;
    private
      //inherited fields
      //internal fields for properties
      //fName: string;
      //fDummy: boolean;
      //fReady: boolean;
      //fStatus: TInterfaceStatus;
      //----------------------
    private
      flock: boolean;  //prevent multiple nesting calls to comm fucntions
      fDebug: boolean;
      procedure setDebug(b: boolean);
    protected
      fLog:  TMyLoggerThreadSafe;
      procedure LeaveLogMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
    public
      property Debug: boolean read fDebug write setDebug;
    private
      //aquire thread and objects
      fcmdsynchro: TCmdQueueThreadSafe; //controls access to cmd queue and variables
      //after finishig, signal can be sent through assigned method
      fflowdatasynchro: TFlowDataThreadSafe;  //from here the data can be read anytime - cached buffer
                                               //!but still use beginread ... and endread methods to access)
                                               //the latest data should be there, expecting refresh interval every 500ms or so
      fdevicessynchro: TFlowDevicesListThreadSafe;
    protected
      //thread control
      fTargetCycleTimeMS: longword;
      fAquireThread: TAquireThreadV2_TCPIP; //TAquireThreadBaseV2;
      procedure fMyExecute; //TMyExecuteMethod
      procedure ThreadStart;
      procedure ThreadStop;
      function IsThreadRunning(): boolean;
      function getThreadStatus: string;
    protected
      //commucation
      fTCPclient: TMyTCPClientForKolServer;
      fpanelerf: TPanel;
    public
      procedure ConfigureTCP( server: string; port: string);    //called from main thread, must not block
      procedure getTCPConf( Var server: string; Var port: string); //called from main thread, must not block
      procedure ForcedClose; //this is called from main thread - emergency close - will not check criticial section
      function IsPortOpen(): boolean;
    public
      procedure LoadConfig;
      procedure SaveConfig;  // prepare variables to be saved config manager
    protected
      procedure CreatePanelIface;
    public
      procedure UpdatePanelIface;
    public
      //user command
      fUserCmdReplyS: string;
      fUserCmdReplyTime: TDateTime;
      fUserCmdReplyIsNew: boolean;
      fLastCycleInsideMS: longint;
    public
      //
      procedure UpdateDevicesInThread;
      function SendUserCmd(cmd: string): boolean;
      procedure ReceiveReplyFromThread;       //"event handler" - reads reply from data.aswerlowlvl when beeing called as syncrhonize from thread
      function GetLastCycleDurMS: longint;
      function MakeCmdStr( cmd: TFlowCmdArrayRec ): string;      
    public
      //flowcontrollers to iterate over - it must be public, because I want to load/save conf from Control Form
      //after update to this array - the new settings must updated inside the aquire thread (there it is private var)
      fdevarray: array[TFLowDevices] of TALicatFlowCtrlRec;
      procedure UpdateDev(dev: TFlowDevices; en: boolean; a: byte; rngmin, rngmax: double);
    private
      fIsconfigured: boolean;
      fConfClient: TConfigClient;        //tIni
      fFormatSettings: TFormatsettings;
      fMFCCount: longint;
      //
      fsetp: array[TFlowDevices] of double;
    private
      procedure ResetLastAquireTime;
    private
    //display
      fMemo: TMemo;
      fInfoLabel: TLabel;
  end;



//---------------------------------------
//helper, conversion functions

function AlicatGasStrToType( gas:  string ): TFlowGasType;
function AlicateRecStatusToStr( rec: TALicatFlowCtrlRec ): string;
function AlicatGasTypeToAlicatGasId(gastype: TFlowGasType): byte;
function AlicatGasIdToGasType(gasid: byte): TFlowGasType;


//---------------------------------------
//Protocol description

//rs232 conf: 8-N-1-None (8  Data Bits, No Parity, 1 Stop Bit, and no Flow Control) protocol.
//from manual - how to configure terminal:
//Click on the “ASCII Setup” button and be sure the “Send Line Ends with Line
//Feeds” box is not checked and the “Echo Typed Characters Locally” box and
//the “Append Line Feeds to Incoming Lines” boxes are checked. Those settings
//not mentioned here are normally okay in the default position.
//
// ==>>messages are finsihed by <CR>
//
//example commnads
//change setpoint on A to 4.54:  AS4.54
//change gas for address B:   B$$#<Enter>
//read register 21   *R21
//write register *w91=X, where X is a positive integer from 1 to 65535, followed by “Enter”.

//poll:   <address><CR>

//known registers:
//91: streaming mode delay
//21: P of PID
//22: D of PID

//46: gas type same as control #
//53: valve offset 0-65535  =0-100%
//44: ??? identifies max range of flow controller?  2057 = 100sccm  10249 = 500sccm

//poll retun data format

//For mass flow controllers, there are six columns of data representing
//pressure, temperature, volumetric flow, mass flow, set-point, and the selected gas
//
//example
//+014.70 +025.00 +02.004 +02.004 2.004 Air

//Gas codes (new alicat) 15.2.2016 MV:
//6=H2
//0=Air
//1=Ar
//7=He
//8=N2
//11=O2



Implementation

uses Math, Windows, Forms, MyAquireThreadPrototype, MyAquireThreadNEW,
  Controls;


//****************************
//        Alicat flow control
//****************************


constructor TFlowControlFCS_TCPIP.Create( p: TPanel);
begin
  inherited Create;
  fName := CInterfaceVer;
  fDummy := false;
  fcmdsynchro := TCmdQueueThreadSafe.Create;
  fflowdatasynchro := TFlowDataThreadSafe.Create;
  fdevicessynchro := TFlowDevicesListThreadSafe.Create;

  fTCPclient :=  TMyTCPClientForKolServer.Create;
  fTCPClient.AssignLogProc( LeaveLogMsg );

  fAquireThread := TAquireThreadV2_TCPIP.Create( fMyExecute, TMyTCPClientThreadSafe(fTCPclient) );
  fready := false;
  if fAquireThread<>nil then
    begin
      fAquireThread.SetUserSuspend;
      fAquireThread.Resume;
    end;
  //
  fLog := TMyLoggerThreadSafe.Create('!flow-fcs-tcpip_', '', GlobalConfig.getAppPath + 'log/');
  //
  fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, 'Alicat-via-FCSTCPIP' );
  fIsconfigured := false;
  //
  GetLocaleFormatSettings(0, fFormatSettings );    //TFormatSettings
  //For Alicat!!! define "." as deciaml separator
  fFormatSettings.DecimalSeparator := '.';
  //
  fTargetCycleTimeMS := 300;
  //
  fpanelerf := p;
  CreatePanelIface;
  //
  logmsg('TFlowControlFCS_TCPIP.Create: done.');
end;


destructor TFlowControlFCS_TCPIP.Destroy;

begin
  if fReady then Finalize;             //tthread.destroy
  if fAquireThread<> nil then
    begin
      fAquireThread.TerminateAndWaitForExecuteFinish;
      fAquireThread.Free;
    end;
  fdevicessynchro.Destroy;
  fflowdatasynchro.Destroy;
  fcmdsynchro.Destroy;
  fConfClient.Destroy;
  fLog.Destroy;
  inherited;
end;


procedure TFlowControlFCS_TCPIP.CreatePanelIface;
var
 w,h: integer;

begin
  if fpanelerf=nil then exit;
  w := fpanelerf.Width;
  h := fpanelerf.Height;
  fInfoLabel := TLabel.Create(nil);
  with fInfoLabel do
    begin
      Parent := fpanelerf;
      height := 20;
      top := 1;
      left := 1;
      width := fpanelerf.Width;
      font.Color := clLime;
      Color := clBlack;
    end;
  fMemo := TMemo.Create(nil);
  with fMemo do
    begin
      Parent := fpanelerf;
      top := 25;
      left := 1;
      width := fpanelerf.Width;
      height := fpanelerf.Height - 30;
    end;
end;

procedure TFlowControlFCS_TCPIP.UpdatePanelIface;
begin
  if fInfoLabel<>nil then
    begin
      fInfoLabel.Caption := 'TCP: ' + fTCPclient.ConfHost + ':' + fTCPclient.ConfPort
                                  +  '  ' + fTCPclient.ClientStateTXT;
    end;
  if fMemo<>nil then
    begin
      fMemo.Lines.Clear;
      fMemo.Lines.Add( 'TCP client: ' + BoolToStr( fTCPclient.Isopen) );
      fMemo.Lines.Add( 'Thread: ' +  fAquireThread.getThreadStatusStr );
      fMemo.Lines.Add( 'Devices Count: ' + IntToStr( fdevicessynchro.GetNDev ) );
    end;
end;


//inherited functions overload


//**************
//basic control functions
//---------------------

function TFlowControlFCS_TCPIP.Initialize: boolean;
Var
  b: boolean;
  t0: longword;
begin
  Result := false;
  fReady := false;
  //
  if not fIsconfigured then
    begin
      LoadConfig;
    end;
  //
  fsetp[CFlowAnode] := 0;   //CFlowAnode, CFlowCathode, CFlowN2, CFlowRes
  fsetp[CFlowCathode] := 0;
  fsetp[CFlowN2] := 0;
  fsetp[CFlowRes] := 0;
  // TCpClient - open via thread in background
  fAquireThread.ConfigureTCP('195.113.25.204', '20005');
  fAquireThread.OpenTCP;
  ThreadStart;
  //reset last aquire time
  ResetLastAquireTime;
  //
  fUserCmdReplyIsNew := false;
  //fready := true;
  t0 := TimeDeltaTICKgetT0;
  while (not fTCPclient.IsOpen) do
    begin
      sleep(80);
      if TimeDeltaTICKNowMS(t0)>1000 then break;
    end;
  fready := fTCPclient.IsOpen;
  Result := true;
  logmsg('TFlowControlFCS_TCPIP.Initialize:' + fName +' success' + 'is ready: ' + BoolToStr(fReady) );
  logmsg('             .... Iface ver str: ' + CInterfaceVer );
end;


procedure TFlowControlFCS_TCPIP.Finalize;
begin
  logmsg('TFlowControlFCS_TCPIP.Finalize: Stopping thread...!!!' );
  ThreadStop;
  fready  := false;
  fLastAquireTimeMS := -1;
  fAquireThread.CloseTCP;
  //fTCPclient.Close;  //will force close even during openingn in progress
end;


procedure TFlowControlFCS_TCPIP.ResetConnection;
//close port, open port - this should help it seems
begin
  logmsg('TFlowControlFCS_TCPIP.ResetConnection: Closing and opening PORT!!!' );
  fAquireThread.ResetConnection;
end;


function TFlowControlFCS_TCPIP.Aquire(Var data: TFlowData; Var flags: TCommDevFlagSet): boolean;
//
Var
  d: TFlowDevices;
  TSdata: TFlowDataThreadSafe;
  lastaq : tDateTime;
begin
  Result := false;
  flags := [];
  if not fReady then exit;
  TSdata := fflowdatasynchro;
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
  fLastCycleInsideMS := fAquireThread.LastCycleMS;
  if TimeDeltaNowMS( lastaq ) > CFlowTimeoutConstMS then  Include(flags, CConnectionLost);
  Result := true;
end;



function TFlowControlFCS_TCPIP.SetSetp(dev: TFlowDevices; val: double): boolean;
Var
  min, max, oldv: double;
  cmdsync: TCmdQueueThreadSafe;
  b, canadd: boolean;
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
   if fDebug then logmsg('TFlowControlFCS_TCPIP.SetSetp: dev ' + FlowDevToStr(dev) + ' sp: ' + FloatToStr(val) + ' (min: ' + FloatToStr(min) + ',max: ' + FloatToStr(max) );
   if not MakeSureIsInRange(val, min-epsilon, max+epsilon) then LogWarning('TFlowControlFCS_TCPIP.SetSetp:  setpoint outside allowed range - ADJUSTING!!!! (from ' + FloatToStr(oldv) +' to ' + FloatToStr(val) +')');
   //calculate compatibility setpoin value (it is in relative value from 0 to 64000 related to maxvalue  fo flow => depends on device range
   //prepare cmd
   cmdrec.id := fdevarray[dev].d;
   cmdrec.t := CFlowCmdSetSP;
   cmdrec.paramd := val;
   cmdrec.parami := altsp;
   cmdrec.paramb := false;
   cmdrec.responsemethod := nil;
   //enqueue new command into aquire thread
   cmdsync := fcmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      canadd := cmdsync.CanAdd();
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if not canadd then logmsg('eeee TFlowControlFCS_TCPIP.SetSetp cannot add CMD to CMDsynchro');
   if fDebug then logmsg('iiii TFlowControlFCS_TCPIP.SetSetp - addded cmd, total waiting now: '+ IntToStr(nw) );
   if b then
     begin
       fsetp[dev] := val;
       Result := true;
     end;

end;


function TFlowControlFCS_TCPIP.SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  b, canadd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
  thisid: string;
begin
   Result := false;
   thisid := 'TFlowControlFCS_TCPIP.SetGas';
   if fDebug then logmsg(thisid + ': dev ' + FlowDevToStr(dev) + ' sp: ' + FlowGasTypeToStr(gas) );
   //prepare cmd
   cmdrec.id := fdevarray[dev].d;
   cmdrec.t := CFlowCmdSetGas;
   cmdrec.parami := AlicatGasTypeToAlicatGasId(gas);
   cmdrec.responsemethod := nil;
   if gas=CGasUnknown then
     begin
       logwarning(thisid + ': invalid argument of gas ID');
       exit;
     end;
   //enqueue new command into aquire thread
   cmdsync := fcmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      canadd := cmdsync.CanAdd();
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if not canadd then logmsg(thisid + ': eeee cannot add CMD to CMDsynchro');
   if fDebug then logmsg(thisid + ': iii addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;
end;


function TFlowControlFCS_TCPIP.GetRange(dev: TFlowDevices): TRangeRecord;
begin
  Result.low := fdevarray[dev].minSccm;
  Result.high := fdevarray[dev].maxSccm;
end;



procedure TFlowControlFCS_TCPIP.setDebug(b: boolean);
begin
  fDebug := b;
  //if AquireThread<>nil then AquireThread.Debug := b;
end;


procedure TFlowControlFCS_TCPIP.ResetLastAquireTime;
Var
  TSdata: TFlowDataThreadSafe;
  lastaq : tDateTime;
begin
  TSdata := fflowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    TSdata.fLastSuccessAquireTime := Now;
  TSdata.EndRead;
end;

// aquire thread, execute poll devices

procedure AddPollDeviceCmd( Var cmdlist: TStringList; id: byte );
Var
 s: string;
begin
  if cmdlist=nil then exit;
  s := 'MFC'+IntToStr(id);
  cmdlist.Add(s);   //'GET '+
  cmdlist.Add(s+'SET');
  cmdlist.Add(s+'S');
  cmdlist.Add(s+'GAS');
end;

procedure UpdateDevRec(Var frec: TFlowRec; Var rlist: TStringlist; ofs: byte);
begin
  InitFlowRecWithNAN( frec );
  if rlist=nil then exit;
  if rlist.Count < ofs+3 then exit;
  frec.timestamp := Now;
  frec.massflow := MyXStrToFloat( rlist.Strings[ofs]);
  frec.setpoint := MyXStrToFloat( rlist.Strings[ofs+1]);
  frec.pressure := MyXStrToFloat( rlist.Strings[ofs+2]);
  frec.gastype := AlicatGasIdToGasType( MyXStrToInt( rlist.Strings[ofs+3] ));
  frec.volflow := NAN;
  frec.temp := NAN;
end;


procedure TFlowControlFCS_TCPIP.fMyExecute; //TMyExecuteMethod
Var
  n: byte;
  w: word;
  i, k: longint;
  b: boolean;
  ardev: array[byte] of TFlowDevices;
  arid: array[byte] of byte;
  cmd: TFlowCmdArrayRec;
  t0, t, dt: longword;
  cmdstrlist, replylist: Tstringlist;
  frec: TFlowRec;
begin
    if (fdevicessynchro=nil) or (fcmdsynchro=nil) or (fflowdatasynchro=nil) then
      begin
        LeaveLogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        exit;
      end;
    //
   cmdstrlist := TStringList.Create;
   replylist := TStringList.Create;
    t0 := TimeDeltaTICKgetT0;
    //get active device list
    fDevicesSynchro.BeginRead;
      n := fDevicesSynchro.GetNDev;
      for i:=0 to n-1 do fDevicesSynchro.GetDev(i, ardev[i], arid[i]);
    fDevicesSynchro.EndRead;
    if fDebug then LeaveLogMsg('Thread execute Iter - devices n: ' + IntToStr(n));
    if n>0 then
      begin

         for i:=0 to n-1 do AddPollDeviceCmd( cmdstrlist, arid[i] );
         b := fTCPclient.QueryGetVariables(cmdstrlist, replylist);
         if b then
           begin
             for i:=0 to n-1 do
               begin
                 k := I*4;
                 UpdateDevRec( frec, replylist, i);
                 fflowdatasynchro.BeginWrite;
                   fflowdatasynchro.stats[ ardev[i] ] := frec;
                   fflowdatasynchro.fLastSuccessAquireTime := frec.timestamp;
                 fflowdatasynchro.EndWrite;
               end;
           end;
      end;
    cmdstrlist.Clear;
    replylist.Clear;
    //cheack if there are any commands in queue and do them...
    //
    fcmdsynchro.BeginRead;
      w := fcmdsynchro.nWaiting;
      for i:=0 to w-1 do
        begin
           b := fcmdsynchro.PopCmd( cmd );
           if b then cmdstrlist.Add( MakeCmdStr( cmd ) );
        end;
    fcmdsynchro.EndRead;
    b := fTCPclient.QueryDoCommands(cmdstrlist, replylist);
    //
    //
    t := TimeDeltaTICKNowMS(t0);
    fLastCycleInsideMS := t;
    //
    cmdstrlist.Destroy;
    replylist.Destroy;
    dt := longword(fTargetCycleTimeMS) - t;
    if fDebug then LeaveLogMsg('  finished in ms: ' + IntToStr(t) + ' ... target cycle is ' + IntToStr(fTargetCycleTimeMS) );
    if t<longword(fTargetCycleTimeMS) then sleep( dt );  //some sleep or something - only if whole process took less than NNN ms
end;






function TFlowControlFCS_TCPIP.MakeCmdStr( cmd: TFlowCmdArrayRec ): string;
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
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: addr: ' + IntTOStr(cmd.id) );
  //generate msg based on cmd
  case cmd.t of
    CFlowCmdSetSP:
      begin
        s := 'SET ' + 'MFC'+inttostr(cmd.id)+'SP'+ FloatToStr( cmd.paramd , fFormatSettings);
      end;
    CFlowCmdUserCmd:
      begin
        s := cmd.params + '';  //force copy
        //LeaveLogMsg('Alicat USER CMD: ' + BinStrToPrintStr(s) );
      end;
    CFlowCmdSetGas:
      begin
        s :=  'SET ' + 'MFC'+inttostr(cmd.id)+'GAS'+ IntToStr( cmd.parami );
      end;
  end;
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: sending cmd: ' + BinStrToPrintStr(msg) );
  Result := s;
end;









procedure TFlowControlFCS_TCPIP.ConfigureTCP( server: string; port: string);    //called from main thread, must not block
begin
  if fAquireThread=nil then exit;
  fAquireThread.ConfigureTCP(server, port);
end;

procedure TFlowControlFCS_TCPIP.getTCPConf( Var server: string; Var port: string); //called from main thread, must not block
begin
  if fTCPclient=nil then exit;
  server := fTCPclient.ConfHost;
  port := fTCPclient.ConfPort;
end;

procedure TFlowControlFCS_TCPIP.ForcedClose; //this is called from main thread - emergency close - will not check criticial section
begin
  if fTCPclient=nil then exit;
  fTCPclient.CLose;
end;

function TFlowControlFCS_TCPIP.IsPortOpen(): boolean;
begin
  Result := false;
  if fTCPclient=nil then exit;
  Result := fTCPClient.IsOpen;
end;


//  TALicatFlowCtrlRec = record
//    d: byte;
//    minSccm: double;
//    maxSccm: double;
//    enabled: boolean;
// end;


procedure TFlowControlFCS_TCPIP.LoadConfig;
Var i: integer;
    s: string;
    fd: TFlowDevices;
    tl: TTokenList;
begin
  //FMFCCount := fConfClient.Load('MFCCount', 0);
  fd := CFlowAnode;
  s := fConfClient.Load('MFCA', '1;5000;1');
  ParseStrSep(s,';', tl);
  if length(tl)>=3 then
    begin
      fdevarray[fd].d := MyXStrToInt( tl[0].s );
      fdevarray[fd].maxSccm := MyXStrToFloat( tl[1].s );
      fdevarray[fd].minSccm := 0;
      fdevarray[fd].enabled := StrToBool( tl[2].s );
    end;
  fd := CFlowN2;
  s := fConfClient.Load('MFCN', '2;100;1');
  ParseStrSep(s,';', tl);
  if length(tl)>=3 then
    begin
      fdevarray[fd].d := MyXStrToInt( tl[0].s );
      fdevarray[fd].maxSccm := MyXStrToFloat( tl[1].s );
      fdevarray[fd].minSccm := 0;
      fdevarray[fd].enabled := StrToBool( tl[2].s );
    end;
  s := fConfClient.Load('MFCC', '3;5000;1');
  fd := CFlowCathode;
  ParseStrSep(s,';', tl);
  if length(tl)>=3 then
    begin
      fdevarray[fd].d := MyXStrToInt( tl[0].s );
      fdevarray[fd].maxSccm := MyXStrToFloat( tl[1].s );
      fdevarray[fd].minSccm := 0;
      fdevarray[fd].enabled := StrToBool( tl[2].s );
    end;
  s := fConfClient.Load('MFCMix', '4;100;1');
  fd := CFlowRes;
  ParseStrSep(s,';', tl);
  if length(tl)>=3 then
    begin
      fdevarray[fd].d := MyXStrToInt( tl[0].s );
      fdevarray[fd].maxSccm := MyXStrToFloat( tl[1].s );
      fdevarray[fd].minSccm := 0;
      fdevarray[fd].enabled := StrToBool( tl[2].s );
    end;
  fIsconfigured := true;
end;


procedure TFlowControlFCS_TCPIP.SaveConfig;
begin
end;



procedure TFlowControlFCS_TCPIP.ThreadStart;
begin
  if fAquireThread = nil then exit;
  logmsg('TFlowControlFCS_TCPIP.ThreadStart: calling RESUME');
  fAquireThread.ResetUserSuspend;
  fAquireThread.Resume;     //TThread  //in case it was suspended
end;


procedure TFlowControlFCS_TCPIP.ThreadStop;
begin
  if fAquireThread = nil then exit;
  logmsg('TFlowControlFCS_TCPIP.ThreadStart: calling SUSPEND');
  fAquireThread.SetUserSuspend;
end;


function TFlowControlFCS_TCPIP.IsThreadRunning(): boolean;
begin
  Result := false;
  if fAquireThread = nil then exit;
  Result := fAquireThread.IsThreadRunning;
end;

function TFlowControlFCS_TCPIP.getThreadStatus: string;
begin
  Result := 'NIL';
  if fAquireThread = nil then exit;
  Result := fAquireThread.getThreadStatusStr;
end;



procedure TFlowControlFCS_TCPIP.UpdateDevicesInThread;
Var
  devsync: TFlowDevicesListThreadSafe;
  d: TFlowDevices;
begin
  devsync := fdevicessynchro;
  if devsync = nil then exit;
  devsync.BeginWrite;
    devsync.ClearAll;
    for d:= low(TFlowDevices) to High(TFlowDevices) do
      begin
        if fdevarray[d].enabled then devsync.AddDev(d, fdevarray[d].d );
      end;
  devsync.EndWrite;
end;



function TFlowControlFCS_TCPIP.SendUserCmd(cmd: string): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  b, canadd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
begin
   Result := false;
   if fDebug then logmsg('TFlowControlFCS_TCPIP.SendUserCmd: ' + BinaryStrTostring(cmd) );
   //prepare cmd
   cmdrec.t := CFlowCmdUserCmd;
   cmdrec.params := cmd  + '';
   cmdrec.responsemethod := ReceiveReplyFromThread;
   //enqueue new command into aquire thread
   if fAquireThread=nil then
     begin
       logmsg('TFlowControlFCS_TCPIP.SetSetp AquireThread=nil ');
       exit;
     end;
   cmdsync := fcmdsynchro;
   if cmdsync=nil then exit;
   //
   b := false;
   cmdsync.beginwrite;
      CanAdd := cmdsync.CanAdd();
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if not CanAdd  then logmsg('eeee TFlowControlFCS_TCPIP.SetSetp cannot add CMD to CMDsynchro');
   if fDebug then logmsg('iiii TFlowControlFCS_TCPIP.SetSetp - addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;
end;


procedure TFlowControlFCS_TCPIP.ReceiveReplyFromThread;       //reads reply from data.aswerlowlvl
//
Var
  copys : string;
  TSdata: TFlowDataThreadSafe;
begin
  if fAquireThread=nil then exit;
  TSdata := fflowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    copys := TSdata.aswerlowlvl + '';      //!!!!!!!!!! necessary to copy, not just assign reference - to be sure
  TSdata.EndRead;
  logmsg('TFlowControlFCS_TCPIP.ReceiveReplyFromThread str=' + BinStrToPrintStr( copys));
  fUserCmdReplyS := copys;
  fUserCmdReplyTime := Now;
  fUserCmdReplyIsNew := true;
end;

function TFlowControlFCS_TCPIP.GetLastCycleDurMS: longint;
begin
  if fAquireThread=nil then exit;
  Result := fAquireThread.LastCycleMS;
end;



procedure TFlowControlFCS_TCPIP.UpdateDev(dev: TFlowDevices; en: boolean; a: byte; rngmin, rngmax: double);
begin
  with fdevarray[ dev ] do
    begin
      enabled := en;
      d := a;
      minsccm := rngmin;
      maxsccm := rngmax;
    end;
end;



procedure TFlowControlFCS_TCPIP.LeaveLogMsg(a: string);
begin
  if flog=nil then exit;
  fLog.LogMsg(a);
end;

//****************************************************



constructor TFlowDataThreadSafe.Create;
Var
  d: TFlowDevices;
begin
  inherited;
  for d := Low(TFlowDevices) to High(TFlowDevices) do
      begin
        InitFlowRecWithNAN( stats[d] );
      end;
  fLastSuccessAquireTime := Now();     
end;

destructor TFlowDataThreadSafe.Destroy;
begin
  inherited;
end;

//****************************************************


constructor TCmdQueueThreadSafe.Create;
Const
  CDefaultCmdArraySize = 100;
begin
  inherited;
  Asize := CDefaultCmdArraySize;
  setLength( cmdArray, CDefaultCmdArraySize );
  strtpos := 0;
  endpos := 0; //strpos == endpos =-> empty
end;


destructor TCmdQueueThreadSafe.Destroy;
begin
  Asize := 0;
  setLength( cmdArray, 0 );
  inherited;
end;

function TCmdQueueThreadSafe.PopCmd(Var cmdrec: TFlowCmdArrayRec): boolean;
begin
  Result := false;
  cmdrec.t := CFlowCmdSetUNDEF;
  if strtpos=endpos then exit;  //meaning array is empty
  cmdrec := cmdArray[strtpos];
  Inc( strtpos );
  if strtpos >= Asize then strtpos := 0;
  Result := true;
end;

function TCmdQueueThreadSafe.nWaiting(): word;  //if >0 then there is  work and can use pop
begin
  if endpos>=strtpos then Result := endpos - strtpos
  else Result := Asize - (strtpos - endpos);
end;

function TCmdQueueThreadSafe.AddCmd(cmd: TFlowCmdArrayRec): boolean;
begin
  Result := false;
  if not CanAdd then exit;
  cmdArray[ endpos ] := cmd;
  Inc(endpos);
  if endpos>=Asize then endpos := 0;
  Result := true;
end;

function TCmdQueueThreadSafe.CanAdd(): boolean; // if there is space for new cmd
begin
  Result := false;
  if nWaiting<(Asize-1) then Result := true;  //the useful maximum capacity is Asize-1 (at full, one index is unsued)
end;

//****************************************************

constructor TFlowDevicesListThreadSafe.Create;
begin
  inherited;
  setlength(devslist, 0);
end;


destructor TFlowDevicesListThreadSafe.Destroy;
begin
  setlength( devslist, 0 );
  inherited;
end;

procedure TFlowDevicesListThreadSafe.ClearAll;
begin
  setlength( devslist, 0 );
end;

procedure TFlowDevicesListThreadSafe.AddDev(dev: TFlowDevices; id: byte);
Var
 ndevs: integer;
begin
  ndevs := length( devslist) + 1;
  setlength( devslist, ndevs );
  devslist[ndevs-1] := dev;
  devsid[dev] := id;
end;


function TFlowDevicesListThreadSafe.GetDev(i: byte; Var dev: TFlowDevices; Var id: byte): boolean;  //returns true if OK
begin
  Result := false;
  if not( (i>=0) and (i<Length(devslist)) ) then exit;
  dev := devslist[i];
  id := devsid[dev];
  Result := true;
end;

function TFlowDevicesListThreadSafe.GetNDev: byte;
begin
  Result := Length(devslist);
end;


//****************************************************





function AlicatGasStrToType( gas: string ): TFlowGasType;
begin
  Result := CGasUnknown;
  if gas='N2' then Result := CGasN2;
  if gas='O2' then Result := CGasO2;
  if gas='H2' then Result := CGasH2;
  if gas='Air' then Result := CGasAir;
  if gas='CO' then Result := CGasCO;
  if gas='Ar' then Result := CGasAr;
  if gas='He' then Result := CGasHe;
end;


function AlicateRecStatusToStr( rec: TALicatFlowCtrlRec ): string;
begin
  if rec.enabled = false then
    begin
      Result := 'Disabled.';
      exit;
    end;
  Result := 'Addr: ' + IntToStr(rec.d) + ' Range ' + FloatToStr( rec.minSccm) + ':' + FloatToStr( rec.maxSccm) ;
end;


function AlicatGasIdToGasType(gasid: byte): TFlowGasType;
//Gas codes (new alicat) 15.2.2016 MV:
//6=H2
//0=Air
//1=Ar
//7=He
//8=N2
//11=O2
begin
  Result := CGasUnknown;
  case gasid of
    8: Result :=  CGasN2;
    6: Result :=  CGasH2;
    11: Result := CGasO2;
    0: Result :=   CGasAir;
    7: Result := CGasHe;
    1: Result :=  CGasAr;
  end;
end;


function AlicatGasTypeToAlicatGasId(gastype: TFlowGasType): byte;
//Gas codes (new alicat) 15.2.2016 MV:
//6=H2
//0=Air
//1=Ar
//7=He
//8=N2
//11=O2
begin
  Result := 0;
  case gastype of
    CGasN2: Result := 8;
    CGasH2: Result := 6;
    CGasO2: Result := 11;
    CGasCO: Result := 6;
    CGasAir: Result := 0;
    CGasHe: Result := 7;
    CGasAr: Result := 1;
  end;

end;




end.

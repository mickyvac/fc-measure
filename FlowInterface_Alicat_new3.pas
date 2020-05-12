unit FlowInterface_Alicat_new3;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, MVConversion,
  Logger, ConfigManager, FormGLobalConfig,
  HWAbstractDevicesV3, MyAquireThreadRS232, MyComPort; //MyAquireThreadPrototype,

{create descendant of virtual abstract FLOW object and define its methods
especially including definition of configuration and setup methods}

Const
  CInterfaceVer = 'Alicat RS232 interface';

  CFlowNotRespCount = 5;
  CFlowTimeoutConstMS = 5000;

  IdHelpDummy = 'hlpnote';

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
    addr: char;
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
    devsaddr: array[TFLowDevices] of char; //addresses
    ndevs: byte;
  public    //these two methods - to make setup by main control interface
    procedure ClearAll;
    procedure AddDev(dev: TFlowDevices; addr: char);
    function GetDev(Var dev: TFlowDevices; i: byte): boolean;  //returns true if OK
    function GetNDev: byte;  //returns true if OK
  end;




  TMyFlowAquireThread = class (TRS232AquireThreadBase)       //TMultiReadExclusiveWriteSynchronizer.
  //!!!!!NOTE!!!!
  //descendant must define ExecuteInnerLoop; instead of execute;
    public
      constructor Create;
      destructor Destroy; override;
    public
      cmdsynchro: TCmdQueueThreadSafe; //controls access to cmd queue and variables
      //after finishig, signal can be sent through assigned method
      flowdatasynchro: TFlowDataThreadSafe;  //from here the data can be read anytime - cached buffer
                                               //!but still use beginread ... and endread methods to access)
                                               //the latest data should be there, expecting refresh interval every 500ms or so
      devicessynchro: TFlowDevicesListThreadSafe;
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

  TALicatFlowCtrlRec = record
    addr: char;
    minSccm: double;
    maxSccm: double;
    enabled: boolean;
    units: string;
    sccmfactor: double;
  end;


  TAlicatRegisters = (CAliRegP, CAliRegD);
  TAlicatRegConfig = array [TAlicatRegisters] of word;   //contains number for each of register label




  TAlicatFlowControl = class (TFlowControllerObject)
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
      function Aquire(Var data: TFlowData; Var flags: TCommDevFlagSet): boolean; override;
      function SetSetp(dev: TFlowDevices; val: double): boolean; override;
      function SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean; override;
      function GetRange(dev: TFlowDevices): TRangeRecord; override;
    private
      fIsconfigured: boolean;
      fLastAquireTimeMS : longint;
      fConStatus: TInterfaceStatus;
      flock: boolean;  //prevent multiple nesting calls to comm fucntions
      fDebug: boolean;
      fSetpCompatibMode: boolean;
      procedure setDebug(b: boolean);
    public
      property ConStatus: TInterfaceStatus read fConStatus;
      property Debug: boolean read fDebug write setDebug;
      property SetpCompatibMode: boolean read fSetpCompatibMode write fSetpCompatibMode;
    private
      AquireThread: TMyFlowAquireThread;
    public
      procedure LoadConfig;
      procedure SaveConfig;  // prepare variables to be saved config manager
    public
      //Comport operation, configuration
      function OpenComPort(): boolean;
      procedure CloseComPort;
      procedure SetupComPort;
      procedure getComPortConf;
      procedure setComPortConf;
      function isPortOpen(): boolean;
      function getPortName(): string;
      function getBaudRate(): string;
      procedure setBaudRate(brstr: string);
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
      fLastCycleInsideMS: longint;
    public
      //thread control
      procedure ThreadStart;
      procedure ThreadStop;
      function IsThreadRunning(): boolean;
      function getThreadStatus: string;
      procedure UpdateDevicesInThread;
      function GetNDevsInThread: byte;
      function SendUserCmd(cmd: string): boolean;
      procedure ReceiveReplyFromThread;       //"event handler" - reads reply from data.aswerlowlvl when beeing called as syncrhonize from thread
      function GetLastCycleDurMS: longint;
    public
      //flowcontrollers to iterate over - it must be public, because I want to load/save conf from Control Form
      //after update to this array - the new settings must updated inside the aquire thread (there it is private var)
      fdevarray: array[TFLowDevices] of TALicatFlowCtrlRec;
      procedure UpdateDev(dev: TFlowDevices; en: boolean; a: char; rngmin, rngmax: double);
    private
      //fConfClient: TConfigClient;
      //
      fsetp: array[TFlowDevices] of double;
      //configuration storage (need to use varibale, so it can be asigned to config manager
      fComPortConf: TComPortConf;
    private
      procedure ResetLastAquireTime;
  end;



//---------------------------------------
//helper, conversion functions

function AlicatGasStrToType( gas:  string ): TFlowGasType;
function AlicateRecStatusToStr( rec: TALicatFlowCtrlRec ): string;
function AlicatGasTypeToAlicatGasId(gastype: TFlowGasType): byte;


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

uses Math, Windows, Forms, MyAquireThreadPrototype;



//****************************
//          Aquire Thread
//****************************


constructor  TMyFlowAquireThread.Create;
begin
  fThreadId := 'Alicat';   //I want to have in the log name ;)
  inherited Create; //createsuspended=true
  freeonterminate := false;  //!!! i need to destroy synchro objects
  cmdsynchro := TCmdQueueThreadSafe.Create;
  flowdatasynchro := TFlowDataThreadSafe.Create;
  devicessynchro := TFlowDevicesListThreadSafe.Create;
  //
  GetLocaleFormatSettings(0, fFormatSettings );    //TFormatSettings
  //For Alicat!!! define "." as deciaml separator
  fFormatSettings.DecimalSeparator := '.';
  fThreadId := 'Alicat';
  fTargetCycleTimeMS := 200;
  fQueryTimeoutMS := 2000;
  fLastCycleInsideMS := -1;
  SetUserSuspend;
  logmsg('TMyFlowAquireThread.Create: done.');
end;


destructor  TMyFlowAquireThread.Destroy;
begin  //TThread
  TerminateAndWaitForExecuteFinish;
  devicessynchro.Destroy;
  flowdatasynchro.Destroy;
  cmdsynchro.Destroy;
  inherited;    //thread must be already terminated when calling iherited destroy
end;




procedure TMyFlowAquireThread.ExecuteInnerLoop;
Var
  n: byte;
  w: word;
  i: longint;
  b: boolean;
  ardev: array[byte] of TFlowDevices;
  araddr: array[byte] of char;
  cmd: TFlowCmdArrayRec;
  t0, t, dt: longword;
begin
    if (DevicesSynchro=nil) or (cmdsynchro=nil) or (flowdatasynchro=nil) then
      begin
        LeaveLogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        sleep(5000);
        exit;
      end;
    t0 := TimeDeltaTICKgetT0;
    //get active device list
    DevicesSynchro.BeginRead;
      n := DevicesSynchro.ndevs;
      for i:=0 to n-1 do
        begin
          DevicesSynchro.GetDev(ardev[i], i);
          araddr[i] := DevicesSynchro.devsaddr[ ardev[i] ];
        end;
    DevicesSynchro.EndRead;
    if fDebug then LeaveLogMsg('Thread execute Iter - devices n: ' + IntToStr(n));
    if n>0 then
      begin
          for i:=0 to n-1 do PollDevice( araddr[i], ardev[i] );
      end;
    //cheack if there are any commands in queue and do them...
    //
    cmdsynchro.BeginRead;
      w := cmdsynchro.nWaiting;
    cmdsynchro.EndRead;
      for i:=0 to w-1 do
        begin
           cmdsynchro.BeginRead;
           b := cmdsynchro.PopCmd( cmd );
           cmdsynchro.EndRead;
           if b then MakeCmdDone( cmd );
        end;
    //
    //
    t := TimeDeltaTICKNowMS(t0);
    fLastCycleInsideMS := t;
    dt := longword(fTargetCycleTimeMS) - t;
    if fDebug then LeaveLogMsg('  finished in ms: ' + IntToStr(t) + ' ... target cycle is ' + IntToStr(fTargetCycleTimeMS) );
    if t<longword(fTargetCycleTimeMS) then sleep( dt );  //some sleep or something - only if whole process took less than NNN ms
end;



procedure TMyFlowAquireThread.PollDevice(devaddr: char; dev: TFlowDevices);
Var
  msg, rxb, reply: string;
  b: boolean;
  toklist: TTokenList;
  d1, d2, d3, d4, d5, pbar: double;
  devid, gas: string;
  frec: TFlowRec;
  timeout, aquirevalid: boolean;
begin
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: addr: ' + devaddr + ' dev# ' + IntToStr(Ord(dev)) );
  aquirevalid := false;
  b := true;
  msg := devaddr + #13;
  //wait for reply
  rxb := '';
  timeout := not SendReceive(msg, rxb, fQueryTimeoutMS);
  //process reply
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: extract reply rxbuf=|'+ BinStrToPrintStr( rxb )+'|' );
  reply := ExtractReply(rxb);
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: parsestr reply=|' + reply +'|');
  setlength( toklist, 0 );
  ParseStrSimple(reply, toklist);
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: process, toklist n=' + IntToStr( length(toklist) ) );
  if fDebug then  LeaveLogMsg('   toklist: ' + TokenListToStr( toklist) );
  //check the response
  if length(toklist) >= 7 then
    begin
       b := true;
      //convert numbers
      //NEED to use fFormatSettings to be independent on system settings!!!!!
      devid := toklist[0].s;
      d1 := StrToFloatDef( toklist[1].s, NaN , fFormatSettings);
      d2 := StrToFloatDef( toklist[2].s, NaN , fFormatSettings);
      d3 := StrToFloatDef( toklist[3].s, NaN , fFormatSettings);
      d4 := StrToFloatDef( toklist[4].s, NaN , fFormatSettings);
      d5 := StrToFloatDef( toklist[5].s, NaN , fFormatSettings);
      gas := toklist[6].s;
      if ( IsNan(d1) or Isnan(d2) or IsNan(d3) or IsNan(d4) or IsNan(d5) ) then b:= false;
      if devid <> devaddr then b:=false;
    end
  else
    begin
      b := false; //error: too few tokens
      //report log error
      LeaveLogMsg('TMyFlowAquireThread.PollDevice:  ERROR addr:' + devaddr + ' timeout='+ BoolToStr( timeout) +' proc rxbuf=|'+ BinStrToPrintStr( rxb )+  ' | reply=|'+ BinStrToPrintStr( reply )+  '|  toklist n=' + IntToStr( length(toklist) ) );
    end;
  //store data
  InitWithNAN( frec );
  frec.timestamp := Now;
  if b then
    begin
      fcommtimeoutcnt[dev] := 0;
      //frec.pressure := ConvertPsiToBar( d1 ) - 1.0;          //need conversion to bar(relative)!!! ... ALicat returns Psi absolute
      pbar := ConvertPsiToBar( d1 );
      frec.pressure := pbar;          //... ALicat returns Psi absolute - conversion will be done inside the main Interface object!!!
      frec.temp := d2;
      frec.volflow := d3;
      frec.massflow :=  d4;
      frec.setpoint :=  d5;
      frec.gastype := AlicatGasStrToType( gas );
      frec.flagSet := [];
      //mark last valid aquire
      aquirevalid := true;
    end;
  if timeout then  if fcommtimeoutcnt[dev]<100 then Inc( fcommtimeoutcnt[dev]);   //inc up to max of 100
  if not timeout then  fcommtimeoutcnt[dev] := 0;  //reset counter
  //assign flag if too many timouts
  Exclude(frec.flagSet, CFlowDevNotResponding);
  if fcommtimeoutcnt[dev]>CFlowNotRespCount then Include(frec.flagSet, CFlowDevNotResponding);
  //
  if fDebug then  LeaveLogMsg('   aquired dev: '+ devid + ' mass flow: ' + FLoatToStr( frec.massflow ) + ' gas ' + gas);
  //store record to synchro object
  flowdatasynchro.BeginWrite;
    flowdatasynchro.stats[dev] := frec;
    if aquirevalid then flowdatasynchro.fLastSuccessAquireTime := frec.timestamp;
  flowdatasynchro.EndWrite;
end;


function TMyFlowAquireThread.MakeCmdDone( cmd: TFlowCmdArrayRec ): string;
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
  b := SendReceive( msg, rxb, 500 );
  s2 := ExtractReply(rxb);
  if fDebug then LeaveLogMsg('TMyFlowAquireThread.MakeCmdDone: reply "'+ BinStrToPrintStr( s2 ) + '"' );
  if cmd.t = CFlowCmdUserCmd then
    begin
      LeaveLogMsg('Alicat USER CMD reply: "' + BinStrToPrintStr(s2) + '"' );
      //store data into datasynchro      flowdatasynchro
      flowdatasynchro.BeginWrite;
        flowdatasynchro.aswerlowlvl := s2;
      flowdatasynchro.EndWrite;
      if Assigned( cmd.responsemethod ) then
        begin
          try
            cmd.responsemethod; //let know the main thread about result
          except
            on E: exception do  LeaveLogMsg('Alicat USER CMD reply: rensposemethod-run got exception:' + E.Message);
          end;
        end;
    end;
  Result := s2;
end;





function TMyFlowAquireThread.IsEndOfMessage(Const recvbuf: string): boolean;
Const
  CMarkEnd = #13;
begin
  Result := False;
  if length(recvbuf)=0 then exit;
  Result := Pos(CMarkEnd, recvbuf)>0;
end;



function TMyFlowAquireThread.ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
Const
  CMarkEnd = #13;
Var
  i, j: longword;
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
      buf := tmp + '';
    end
  else
    begin  //copy whole buf
      Result := buf + '';
      buf := '';
    end;
end;





//****************************
//        Alicat flow control
//****************************


constructor TAlicatFlowControl.Create;
begin
  inherited Create('Alicat Flow Controllers', CInterfaceVer, false);  //'Alicat RS232 Flow Control';
  fIsconfigured := false;
  fLastAquireTimeMS := -1;
  AquireThread := TMyFlowAquireThread.Create;
  AquireThread.FreeOnTerminate := false;
  if AquireThread<>nil then
    begin
      AquireThread.SetUserSuspend;
      AquireThread.Resume;
    end;
  //fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, 'AlicatFLOW' );

  logmsg('TAlicatFlowControl.Create: done.');
end;


destructor TAlicatFlowControl.Destroy;

begin
  if getIsReady then Finalize;             //tthread.destroy
  //fConfClient.Destroy;
  if AquireThread<> nil then
    begin
      AquireThread.Terminate;
      AquireThread.TerminateAndWaitForExecuteFinish;
    try
      //AquireThread.Destroy;                  //waitfor
      AquireThread.Free;  //instead of Destory call FREE!!! as is described in the help
                          //destroy causes program hang on exit;
                          //- now freeonterminate is set FALSE, so I need to call free!!!
    except
      on E: Exception do ShowMessage(E.message);
    end;
    end;
  inherited;
end;


//inherited functions overload


//**************
//basic control functions
//---------------------

function TAlicatFlowControl.Initialize: boolean;
Var
  b: boolean;
begin
  Result := false;
  setIsReady(false);
  fsetp[CFlowAnode] := 0;   //CFlowAnode, CFlowCathode, CFlowN2, CFlowRes
  fsetp[CFlowCathode] := 0;
  fsetp[CFlowN2] := 0;
  fsetp[CFlowRes] := 0;
  //.
  if not fIsconfigured then
  begin
    LoadConfig;
  end;
  if not fIsconfigured then exit;
  // port
  if not IsPortOpen() then
    begin
      logmsg('TAlicatFlowControl.Initialize: Comport is NOT open - try open');
      try
        b := OpenComPort();
      except
        on E:exception do begin logerror('TAlicatFlowControl.Initialize: Port open - exception: ' + E.message); end;
      end;
      if not b then
        begin
          logmsg('TAlicatFlowControl.Initialize: Port open FAILED -> exit');
          exit;
        end;
    end;
  ThreadStart;
  //Sleep(100);  //???
  //if not IsThreadRunning then
  //      begin
  //        logmsg('TAlicatFlowControl.Initialize: Thread is NOT running -> exit');
  //        exit;
  //      end;
  //reset last aquire time
  ResetLastAquireTime;
  //
  fUserCmdReplyIsNew := false;
  setIsReady(true);
  Result := true;
  AquireThread.EnableCom;
  logmsg('TAlicatFlowControl.Initialize: AlicatRS232 success!!!' );
  logmsg('             .... Iface ver str: ' + CInterfaceVer );
end;


procedure TAlicatFlowControl.Finalize;
begin
  logmsg('TAlicatFlowControl.Finalize: Stopping thread...!!!' );
  setIsReady(false);
  fLastAquireTimeMS := -1;
  AquireThread.DisableCom;
  ThreadStop;
  CloseComPort;
end;


procedure TAlicatFlowControl.ResetConnection;
//close port, open port - this should help it seems
begin
  logmsg('TAlicatFlowControl.ResetConnection: Closing and opening PORT!!!' );
  AquireThread.ResetConnection;
end;


function TAlicatFlowControl.Aquire(Var data: TFlowData; Var flags: TCommDevFlagSet): boolean;
//
Var
  d: TFlowDevices;
  TSdata: TFlowDataThreadSafe;
  lastaq : tDateTime;
begin
  Result := false;
  flags := [];
  if not getIsReady then exit;
  if AquireThread=nil then exit;
  TSdata := AquireThread.flowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginWrite;
    for d := Low(TFlowDevices) to High(TFlowDevices) do
      begin
        if fdevarray[d].enabled then data[d] := TSdata.stats[d]
        else
          begin
            InitWithNAN( data[d]);  //for disabled devices, fill NAN
            Include(data[d].flagSet, CFlowDevDisabled);
          end;
      end;
    lastaq := TSdata.fLastSuccessAquireTime;
  TSdata.EndWrite;
  // check for communication connection lost
  fLastCycleInsideMS := AquireThread.fLastCycleInsideMS;
  if TimeDeltaNowMS( lastaq ) > CFlowTimeoutConstMS then  Include(flags, CCSConnectionLost);
  Result := true;
end;



function TAlicatFlowControl.SetSetp(dev: TFlowDevices; val: double): boolean;
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
      canadd := cmdsync.CanAdd();
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if not canadd then logmsg('eeee TAlicatFlowControl.SetSetp cannot add CMD to CMDsynchro');
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
  b, canadd: boolean;
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
      canadd := cmdsync.CanAdd();
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if not canadd then logmsg(thisid + ': eeee cannot add CMD to CMDsynchro');
   if fDebug then logmsg(thisid + ': iii addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;
end;


function TAlicatFlowControl.GetRange(dev: TFlowDevices): TRangeRecord;
begin
  Result.low := fdevarray[dev].minSccm;
  Result.high := fdevarray[dev].maxSccm;
end;



procedure TAlicatFlowControl.setDebug(b: boolean);
begin
  fDebug := b;
  if AquireThread<>nil then AquireThread.Debug := b;
end;


procedure TAlicatFlowControl.ResetLastAquireTime;
Var
  TSdata: TFlowDataThreadSafe;
  lastaq : tDateTime;
begin
  if AquireThread=nil then exit;
  TSdata := AquireThread.flowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    TSdata.fLastSuccessAquireTime := Now;
  TSdata.EndRead;
end;



procedure TAlicatFlowControl.SetupComPort;

begin
  if AquireThread=nil then exit;
  AquireThread.OpenComPortSetupForm;
  getComPortConf;
  logmsg('TAlicatFlowControl.SetupComPort:  new config= ' + portconftostr(fComPortConf) );
end;




function TAlicatFlowControl.IsPortOpen(): boolean;
begin
  Result := false;
  if AquireThread=nil then exit;
  Result := AquireThread.isComConnected;
end;


function TAlicatFlowControl.OpenComPort(): boolean;
Var
  d0: TDateTime;
Const
  COpenTimeoutMS = 3000;
begin
  Result := False;
  if AquireThread=nil then exit;
  logmsg('TAlicatFlowControl. Trying OPENCom');
  AquireThread.OpenCom;  //this is non blocking request - will wait for timeout if sucess, if not call Close
  AquireThread.ResetUserSuspend;
  Result := True;

{  //(ccaling close will also solve problem, when open will wait undefinitely for not responding server)
  d0 := Now;
  while not AquireThread.isComConnected and (TimeDeltaNowMS(d0)<COpenTimeoutMS) do
    begin
      //Application.ProcessMessages;      //TODO: THIS MAY BE DANGEROUS!!!
    end;
  Result := AquireThread.isComConnected;
  If not Result then
    begin
      logError('TAlicatFlowControl.: Opening was NOT successful!!!!');
    end;}
end;



procedure TAlicatFlowControl.CloseComPort;
begin
  if AquireThread=nil then exit;
  logmsg('TAlicatFlowControl. Trying CloseCOM');
  AquireThread.CloseCom;
end;



function TAlicatFlowControl.getPortName(): string;
Var
  pc: TComPortConf;
begin
  if AquireThread=nil then exit;
  AquireThread.getPortConf(pc);
  Result := pc.Name;
end;


function TAlicatFlowControl.getBaudRate(): string;
Var
  pc: TComPortConf;
begin
  if AquireThread=nil then exit;
  AquireThread.getPortConf(pc);
  Result := pc.BR;
end;

procedure TAlicatFlowControl.setBaudRate(brstr: string);
Var
  pc: TComPortConf;
begin
  if AquireThread=nil then exit;
  AquireThread.getPortConf(pc);
  pc.BR := brstr;
  AquireThread.ConfigurePort( pc );
  getComPortConf;
end;


procedure TAlicatFlowControl.getComPortConf;
begin
  if AquireThread=nil then exit;
  AquireThread.getPortConf(fComPortConf);
end;

procedure TAlicatFlowControl.setComPortConf;
begin
  if AquireThread=nil then exit;
  AquireThread.ConfigurePort(fComPortConf);
end;

procedure TAlicatFlowControl.LoadConfig;
Var
  i: integer;
  s, s2, fdname, fddef, fdalias, sec, secdev: string;
  slistmfc, slistmfcdef: string;
  fd: TFLowDevices;
  tl, tlmfc: TTokenList;
  aRI: TRegistryItem;
  RNIfacenew: TMyRegistryNodeObject;
  fdrec: TAlicatFlowCtrlRec;
  xfd: byte;
  fdaddr: char;
  //
  fPortName: string;
  fBR: string;
  fDataBits: string;
  fStopBits: string;
  fParity: string;
  fFlowCtrl: string;
begin
  RNIfacenew := RegistryHW.GetOrCreateSection(fIfaceID);
  if (RNIfacenew = nil) then exit;

  fSetpCompatibMode := RNIfacenew.GetOrCreateItem('SetpCompatibilityMode', false).valbool;

  fPortName := RNIfacenew.GetOrCreateItem('COMPortName', 'COM2').valstr;
  fBR := RNIfacenew.GetOrCreateItem( 'COMBR', '19200').valstr;
  fDataBits := RNIfacenew.GetOrCreateItem( 'COMDataBits', '8').valstr;
  fStopBits := RNIfacenew.GetOrCreateItem( 'COMStopBits', '1').valstr;
  fParity := RNIfacenew.GetOrCreateItem( 'COMParity', 'None').valstr;
  fFlowCtrl := RNIfacenew.GetOrCreateItem( 'COMFlowCtrl', 'None').valstr;
   with fComPortConf do
     begin
       Name := fPortName;
       BR   := fBR;
       DataBits  := fDataBits;
       StopBits  := fStopBits;
       Parity    := fParity;
       FlowCtrl  := fFlowCtrl;
     end;
  //
  setComPortConf;
  //.
  //load devices
  //.
  //sec := CInterfaceVer; // fIfaceID;
  //secdev := SecIdDevices;

  //RNAliases := RegistryHW.GetOrCreateSection(SecIdAliases);
  // Assert((RNIface=nil) or (RNAliases=nil) );

  //
  RNIfacenew.GetOrCreateItem(IdHelpDummy + '1',
    'HWMFCLIST=comma separated list of nicknames, order is FIXED in sw, use address to change mapping:  AnodeMFC, N2MFC, CathodeMFC, MFCReserve, MFCX1, MFCX2');
  RNIfacenew.GetOrCreateItem(IdHelpDummy + '2',
    'HWMFCNickName=Addrchar, Range(in default unit);Enabled(1|0);default unit string;sccm factor for given unit');
  slistmfcdef := 'MFCA,MFCN,MFCC,MFCMIX';
  //slistmfc := RNIface.GetOrCreateItem(IdHWMFClist, slistmfcdef).valStr;
  slistmfc := RNIfacenew.GetOrCreateItem('MFClist', slistmfcdef).valStr;
  ParseStrSep(slistmfc, ',;', tlmfc);
  //
  for i := 0 to Length(tlmfc) - 1 do
  begin
    fdname := tlmfc[i].s;
    fddef := Char(Ord('A') + i) + ';100;0;sccm';
    //new fddef := '100;slpm;1;MFC' + IntToStr(i) + ';no comment';
    //new fddef := IntToStr(i) + ';100;1';
    s := RNIfacenew.GetOrCreateItem(fdname, fddef).valStr;
    ParseStrSep(s, ';', tl);
    if Length(tl) >= 3 then
    begin
      // RegistryHW.NewItemDef(secdev, fdname, fdname);
      // aRI := RegistryHW.ItemExists(SecIdAliases, fdname);   //!!do not create alias automatically
      //fdalias := RNAliases.GetOrCreateItem(fdname, IntToStr(i)).valStr;

//      fdrec.name := fdname + '';
//      fdrec.namealias := fdalias;
       fdaddr := 'A'; if Length(tl[0].s)>0 then fdaddr := tl[0].s[1];
      fdrec.addr := fdaddr;
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
    xfd := i;  //internal indexed from 0
    fd := CFlowRes;  //fallback default
    if (xfd>= Ord( Low( TFlowDevices))) and (xfd<= Ord( High( TFlowDevices) )) then fd := TFlowDevices( xfd );
    fdevarray[fd] := fdrec;
  end; //for i
  // if I<= Ord( High( TFlowDevices) ) then fd := TFlowDevices( i )
  // else fd := CFlowRes;

  // Use device config
  UpdateDevicesInThread;


  //.
  fIsconfigured := true;
end;

procedure TAlicatFlowControl.SaveConfig;
Var
  i: integer;
  s, s2, fdname, fddef, fdalias, sec, secdev: string;
  slistmfc, slistmfcdef: string;
  fd: TFLowDevices;
  tl, tlmfc: TTokenList;
  aRI: TRegistryItem;
  RNIfacenew: TMyRegistryNodeObject;
  fdrec: TAlicatFlowCtrlRec;
  xfd: byte;
  fdaddr: char;
  //
  fPortName: string;
  fBR: string;
  fDataBits: string;
  fStopBits: string;
  fParity: string;
  fFlowCtrl: string;
begin
  RNIfacenew := RegistryHW.GetOrCreateSection(fIfaceID);
  if (RNIfacenew = nil) then exit;
  //.
  getComPortConf;
  RNIfacenew.SetOrCreateItem('SetpCompatibilityMode', fSetpCompatibMode);
  with fComPortConf do
    begin
       RNIfacenew.SetOrCreateItem('COMPortName', Name).valstr;
       RNIfacenew.SetOrCreateItem( 'COMBR', BR).valstr;
       RNIfacenew.SetOrCreateItem( 'COMDataBits', DataBits).valstr;
       RNIfacenew.SetOrCreateItem( 'COMStopBits', StopBits).valstr;
       RNIfacenew.SetOrCreateItem( 'COMParity', Parity).valstr;
       RNIfacenew.SetOrCreateItem( 'COMFlowCtrl', FlowCtrl).valstr;
    end;
end;



function TAlicatFlowControl.getErrCount(): longint;
begin
  Result := -1;
  if AquireThread=nil then exit;
  Result := AquireThread.comErrcnt;
end;


function TAlicatFlowControl.getOKCount(): longint;
begin
  Result := -1;
  if AquireThread=nil then exit;
  Result := AquireThread.comOKcnt;
end;

procedure TAlicatFlowControl.resetErrOKCounters;
begin
  if AquireThread=nil then exit;
  AquireThread.ResetCnts;
end;



procedure TAlicatFlowControl.ThreadStart;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling RESUME');
  AquireThread.ResetUserSuspend;
  AquireThread.Resume;     //TThread  //in case it was suspended
end;


procedure TAlicatFlowControl.ThreadStop;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling SUSPEND');
  AquireThread.SetUserSuspend;
end;


function TAlicatFlowControl.IsThreadRunning(): boolean;
begin
  Result := false;
  if AquireThread = nil then exit;
  Result := AquireThread.IsThreadRunning;
end;

function TAlicatFlowControl.getThreadStatus: string;
begin
  Result := 'NIL';
  if AquireThread = nil then exit;
  Result := AquireThread.getThreadStatusStr;
end;



procedure TAlicatFlowControl.UpdateDevicesInThread;
Var
  devsync: TFlowDevicesListThreadSafe;
  d: TFlowDevices;
begin
  if AquireThread = nil then exit;
  devsync := AquireThread.devicessynchro;
  if devsync = nil then exit;
  devsync.BeginWrite;
    devsync.ClearAll;
    for d:= low(TFlowDevices) to High(TFlowDevices) do
      begin
        if fdevarray[d].enabled then devsync.AddDev(d, fdevarray[d].addr );
      end;
  devsync.EndWrite;
end;


function TAlicatFlowControl.GetNDevsInThread: byte;
Var
  devsync: TFlowDevicesListThreadSafe;
begin
  Result := 0;
    if AquireThread = nil then exit;
  devsync := AquireThread.devicessynchro;
  if devsync = nil then exit;
  devsync.BeginRead;
    Result := devsync.GetNDev;
  devsync.EndRead;
end;


function TAlicatFlowControl.SendUserCmd(cmd: string): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  b, canadd: boolean;
  cmdrec: TFlowCmdArrayRec;
  nw: word;
begin
   Result := false;
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
      CanAdd := cmdsync.CanAdd();
      b := cmdsync.AddCmd( cmdrec );
      nw := cmdsync.nWaiting;
   cmdsync.endwrite;
   if not CanAdd  then logmsg('eeee TAlicatFlowControl.SetSetp cannot add CMD to CMDsynchro');
   if fDebug then logmsg('iiii TAlicatFlowControl.SetSetp - addded cmd, total waiting now: '+ IntToStr(nw) );
   Result := b;
end;


procedure TAlicatFlowControl.ReceiveReplyFromThread;       //reads reply from data.aswerlowlvl
//
Var
  copys : string;
  TSdata: TFlowDataThreadSafe;
begin
  if AquireThread=nil then exit;
  TSdata := AquireThread.flowdatasynchro;
  if TSdata=nil then exit;
  TSdata.BeginRead;
    copys := TSdata.aswerlowlvl + '';      //!!!!!!!!!! necessary to copy, not just assign reference - to be sure
  TSdata.EndRead;
  logmsg('TAlicatFlowControl.ReceiveReplyFromThread str=' + BinStrToPrintStr( copys));
  fUserCmdReplyS := copys;
  fUserCmdReplyTime := Now;
  fUserCmdReplyIsNew := true;
end;

function TAlicatFlowControl.GetLastCycleDurMS: longint;
begin
  if AquireThread=nil then exit;
  Result := AquireThread.fLastCycleMS;
end;


procedure TAlicatFlowControl.UpdateDev(dev: TFlowDevices; en: boolean; a: char; rngmin, rngmax: double);
begin
  with fdevarray[ dev ] do
    begin
      enabled := en;
      addr := a;
      minsccm := rngmin;
      maxsccm := rngmax;
    end;
end;



//****************************************************



constructor TFlowDataThreadSafe.Create;
Var
  d: TFlowDevices;
begin
  inherited;
  for d := Low(TFlowDevices) to High(TFlowDevices) do
      begin
        InitWithNAN( stats[d] );
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
  ndevs := 0;
end;


destructor TFlowDevicesListThreadSafe.Destroy;
begin
  ndevs := 0;
  setlength( devslist, 0 );
  inherited;
end;

procedure TFlowDevicesListThreadSafe.ClearAll;
begin
  ndevs := 0;
  setlength( devslist, 0 );
end;

procedure TFlowDevicesListThreadSafe.AddDev(dev: TFlowDevices; addr: char);
begin
  inc( ndevs );
  setlength( devslist, ndevs );
  devslist[ndevs-1] := dev;
  devsaddr[dev] := addr;
end;


function TFlowDevicesListThreadSafe.GetDev(Var dev: TFlowDevices; i: byte): boolean;  //returns true if OK
begin
  Result := false;
  if not( (i>=0) and (i<ndevs) ) then exit;
  dev := devslist[i];
  Result := true;
end;

function TFlowDevicesListThreadSafe.GetNDev: byte;
begin
  Result := ndevs;
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
  Result := 'Addr: ' + BinCharToStrPrint(rec.addr) + ' Range ' + FloatToStr( rec.minSccm) + ':' + FloatToStr( rec.maxSccm) ;
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

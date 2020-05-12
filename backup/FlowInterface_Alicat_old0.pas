unit FlowInterface_Alicat_old;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, ParseUtils, Logger, ConfigManager,
  HWAbstractDevicesNew2,
  cport ,   //in '..\cport\cport.pas'
  cportctl;  //in '..\cport\cportCtl.pas'

{create descendant of virtual abstract FLOW object and define its methods
especially including definition of configuration and setup methods}

Const
  CInterfaceVer = 'Alicat RS232 Flow interface 2015-10-19 (by Michal Vaclavu)';

  CFlowNotRespCount = 5;
  CFlowTimeoutConstMS = 5000;


Type


   TFlowStatus = record
        CommFlagSet: TCommDevFlagSet;
        end;
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


  TComPortThreadSafe = class (TMultiReadExclusiveWriteSynchronizer)
    public
      constructor Create;
      destructor Destroy; override;
    public
      ComPort: TComPort;    //!!!!!!main communication component
    private
      fcnterr: longint;    //counter of send msg/ recv msg errors
      fcntok: longint;
    public
      property comokcnt: longint read fcntok write fcntok;
      property comerrcnt: longint read fcnterr write fcnterr;
  end;

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




  TMyFlowAquireThread = class (TThread)       //TMultiReadExclusiveWriteSynchronizer.
    public
      constructor Create;
      procedure BeforeDestroy;
      destructor Destroy; override;
    public
      MySuspend: boolean;
      cmdsynchro: TCmdQueueThreadSafe; //controls access to cmd queue and variables
      //after finishig, signal can be sent through assigned method
      flowdatasynchro: TFlowDataThreadSafe;  //from here the data can be read anytime - cached buffer
                                               //!but still use beginread ... and endread methods to access)
                                               //the latest data should be there, expecting refresh interval every 500ms or so
      comportsynchro: TComPortThreadSafe;  //locked access because of possible change iof configuration - this is only reference to comport,
                                           //the comport is owned by the root - e.g. TAlicatFLowControlObject
      devicessynchro: TFlowDevicesListThreadSafe;
    public
      procedure Execute; override;
      procedure AssignComPortSynchro(comsync: TComportThreadSafe );
      procedure SetDebug( b: boolean);
    private
      procedure PollDevice(devaddr: char; dev: TFlowDevices);
      function MakeCmdDone( cmd: TFlowCmdArrayRec ): string;
    private
      procedure ComPortRxChar(Sender: TObject; Count: Integer);  //this is the event handler for receiving data !!!
      function IsEndOfPacket: boolean;
      procedure MyThreadProcessMessages;
      procedure DummyMethod;      
      function ActivelyWaitForReply(timeoutx: longword): boolean; //if timeout return false
      function ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
      function comSendLowLvl(s: string): boolean;  //only send
      function comRecvLowLvl(Var answer: string): boolean; //only receive   !!! do not use inside critical/locked section - needs to process messages - may dead lock
      function comSend(cmd: string; Var answer: string): boolean; //basic comm - sends and receives answer !!! do not use inside critical/locked section - needs to process messages - may dead lock
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
  end;

  //TSimpleEvent      //sleep

  TALicatFlowCtrlRec = record
    addr: char;
    minSccm: double;
    maxSccm: double;
    enabled: boolean;
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
      function Aquire(Var data: TFlowData; Var status: TCommDevFlagSet): boolean; override;
      function SetSetp(dev: TFlowDevices; val: double): boolean; override;
      function SetGas(dev: TFlowDevices; gas: TFlowGasType): boolean; override;
      function GetRange(dev: TFlowDevices): TRangeRecord; override;
    private
      fConStatus: TConnectStatus;
      flock: boolean;  //prevent multiple nesting calls to comm fucntions
      fDebug: boolean;
      fSetpCompatibMode: boolean;
      //fDevReady: boolean;
      procedure setDebug(b: boolean);
    public
      property ConStatus: TConnectStatus read fConStatus;
      property Debug: boolean read fDebug write setDebug;
      property SetpCompatibMode: boolean read fSetpCompatibMode write fSetpCompatibMode;
    private
      AquireThread: TMyFlowAquireThread;
      comportsynchro: TComPortThreadSafe;  //object created/owned here -> reference is assigned to the AquireThread
                                           // when accesing use beginwrite/endwrite
      fConfClient: TConfigClient;
    public
      //Comport operation, configuration
      function OpenComPort(): boolean;
      procedure CloseComPort;
      procedure SetupComPort;
      procedure SaveComPortConf(conffile: string);
      procedure LoadComPortConf(conffile: string);
      procedure getComPortConf;
      procedure setComPortConf;
      function isPortOpen(): boolean;
      function getPortName(): string;
      function getBaudRate(): string;
      procedure setBaudRate(brstr: string);
      function getErrCount(): longint;
      function getOKCount(): longint;
      procedure resetErrOKCounters;
      procedure LoadConfig;      
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
      procedure ReceiveReplyFromThread;       //"event handler" - reads reply from data.aswerlowlvl when beeing called as syncrhonize from thread
    public
      //flowcontrollers to iterate over - it must be public, because I want to load/save conf from Control Form
      //after update to this array - the new settings must updated inside the aquire thread (there it is private var)
      fdevarray: array[TFLowDevices] of TALicatFlowCtrlRec;
    public
      //
      procedure UpdateDev(dev: TFlowDevices; en: boolean; a: char; rngmin, rngmax: double);
      procedure DoAfterLoad; //process values after load process of config manager registered variables
      procedure SaveConfig;  // prepare variables to be saved config manager
    private
    //---- private variables declaration
      fsetp: array[TFlowDevices] of double;
      fConfManagerId: longint;
      fConfigManager: TLoadSaveConfigManager;
      //configuration storage (need to use varibale, so it can be asigned to config manager
      fComPortName: string;
      fComPortBR: string;
      fComPortDataBits: string;
      fComPortStopBits: string;
      fComPortParity: string;
      fComPortFlowCtrl: string;
      //
    private
      procedure ResetLastAquireTime;
      procedure leavemsg(s: string); //log msg and set return msg
    //*************************
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

uses Math, Windows, Forms, FormGlobalConfig;



//****************************
//          Aquire Thread
//****************************


constructor  TMyFlowAquireThread.Create;
begin
  inherited Create(true); //createsuspended=true
  freeonterminate := false;  //!!! i need to destroy synchro objects
  cmdsynchro := TCmdQueueThreadSafe.Create;
  flowdatasynchro := TFlowDataThreadSafe.Create;
  devicessynchro := TFlowDevicesListThreadSafe.Create;
  //
  comportsynchro := nil;  //assigned from AlicatFlowControlObject
  rxbuf := '';
  GetLocaleFormatSettings(0, fFormatSettings );    //TFormatSettings
  //For Alicat!!! define "." as deciaml separator
  fFormatSettings.DecimalSeparator := '.';
  fSynchroLockedByWait := false;
  MySuspend := true;
  logmsg('TMyFlowAquireThread.Create: done.');
end;


procedure TMyFlowAquireThread.BeforeDestroy;
begin
  devicessynchro.Destroy;
  flowdatasynchro.Destroy;
  cmdsynchro.Destroy;
  comportsynchro := nil;  //this is destroeyed elsewhere
  devicessynchro := nil;
  flowdatasynchro := nil;
  cmdsynchro := nil;
end;

destructor  TMyFlowAquireThread.Destroy;
begin  //TThread
  inherited;    //thread must be already terminated when calling iherited destroy
end;


procedure TMyFlowAquireThread.AssignComPortSynchro(comsync: TComportThreadSafe );
begin
  comportsynchro := comsync;
  //assign onRx event handler
  if comportsynchro<>nil then
    begin
      if comportsynchro.comport<>nil then
        begin
          comportsynchro.comport.SyncMethod := smNone;
          comportsynchro.comport.OnRxChar := ComPortRxChar;
          //new way since 2016-05-10 use SyncMethod =smNone -> that way every time char arrives, the method
          //inside comport object calls directly
        // my EVENT HANDLER -> SO NO NEED TO WAIT FOR ANY DMAN FU**ING MESSAGES anymore
        end;
    end;
end;

procedure TMyFlowAquireThread.SetDebug( b: boolean);
begin
  fDebug := b;
end;


procedure TMyFlowAquireThread.LeaveLogMsg(a: string);
//in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  syncmsg :='THREAD FLOW ' + a;
  Synchronize( SyncLeaveLogMsg );
end;

procedure TMyFlowAquireThread.LeaveWarningMsg(a: string);  //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  syncmsg := 'THREAD FLOW ' + a;
  Synchronize( SyncLeaveWarningMsg );
end;

procedure TMyFlowAquireThread.LeaveErrorMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
begin
  syncmsg := 'THREAD FLOW ' + a;
  Synchronize( SyncLeaveErrorMsg );
end;

procedure TMyFlowAquireThread.SyncLeaveLogMsg;     //this will serve as argument to synchronize - used internaly, for log use proc LeaveLogMsg
begin
  LogMsg( syncmsg );
end;

procedure TMyFlowAquireThread.SyncLeaveWarningMsg;  //dtto
begin
  LogWarning( syncmsg );
end;

procedure TMyFlowAquireThread.SyncLeaveErrorMsg;   //dtto
begin
  LogError( syncmsg );
end;





procedure TMyFlowAquireThread.Execute;
Const
  CTargetCycleTimeMS = 200;
Var
  n: byte;
  w: word;
  i: longint;
  b: boolean;
  ardev: array[byte] of TFlowDevices;
  araddr: array[byte] of char;
  cmd: TFlowCmdArrayRec;
  d0: TDateTime;
begin
  LeaveLogMsg('TMyFlowAquireThread.Execute: started');
  //TSemaphore             //tthread
  while not Terminated do
    begin
    d0 := Now();
    if (DevicesSynchro=nil) or (cmdsynchro=nil) or (flowdatasynchro=nil) or (comportsynchro=nil) then
      begin
        LeaveLogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        sleep(10000);
        continue;
      end;
    if MySuspend and (not Terminated) then  //I want to hold the Aquire - but suspend does have some side effects and termitate cannot be easily restarted
    begin
      sleep(100);      //TODO: not very elegant - future - use event waitfor...
      continue;
    end;
    if Terminated then break;
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
    //CLEAR BUFFERS!!!
    //com
    //
    if n>0 then
      begin
          for i:=0 to n-1 do
            begin
              //poll device
              PollDevice( araddr[i], ardev[i] );
            end;
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
    i := DateTimeToMS( TimeDeltaNow( d0 ) );
    if i<CTargetCycleTimeMS then sleep(CTargetCycleTimeMS-i);  //some sleep or something - only if whole process took less than NNN ms
    end; //while
  //
  LeaveLogMsg('TMyFlowAquireThread.Execute: Finished!!! EXECUTE ');
end;



procedure TMyFlowAquireThread.PollDevice(devaddr: char; dev: TFlowDevices);
Var
  com: TComPort;
  msg: string;
  b: boolean;
  toklist: TTokenList;
  d1, d2, d3, d4, d5: double;
  devid, gas: string;
  frec: TFlowRec;
  timeout, aquirevalid: boolean;
begin
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: addr: ' + devaddr + ' dev# ' + IntToStr(Ord(dev)) );
  aquirevalid := false;
  msg := devaddr + #13;
  b := comSendLowLvl( msg );
  //wait for reply
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: waiting...' );
  timeout := not ActivelyWaitForReply(500);
  //process reply
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: extract reply rxbuf=|'+ BinStrToPrintStr( rxbuf )+'|' );
  msg := ExtractReply(rxbuf);
  if fDebug then  LeaveLogMsg('TMyFlowAquireThread.PollDevice: parsestr' );
  ParseStrSimple(msg, toklist);
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
    b := false; //error: too few tokens
  //store data
  InitFlowRecWithNAN( frec );
  frec.timestamp := Now;
  if b then
    begin
      fcommtimeoutcnt[dev] := 0;
      //frec.pressure := ConvertPsiToBar( d1 ) - 1.0;          //need conversion to bar(relative)!!! ... ALicat returns Psi absolute
      frec.pressure := d1;          //... ALicat returns Psi absolute - conversion will be done inside the main Interface object!!!
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
  //store record to synchro object  - only if succesfull, otherwise leave old data (do not overwerrite with NAN
  flowdatasynchro.BeginWrite;
    //write flags every time, even if fail
    flowdatasynchro.stats[dev].flagSet := frec.flagSet;
    //data only if valid
    if aquirevalid then
       begin
         flowdatasynchro.stats[dev] := frec;
         flowdatasynchro.fLastSuccessAquireTime := frec.timestamp;
       end;
  flowdatasynchro.EndWrite;
end;


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




procedure TMyFlowAquireThread.ComPortRxChar(Sender: TObject; Count: Integer);
//this is the event handler for receiving data !!!
Var
 i, n, o: integer;
 s: string;
 com: TComPort;
 marklock: boolean;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then exit;
  if not com.Connected then exit;
  if fDebug then  LeaveLogMsg('TTT ComPortRxChar: n=' + IntToStr( Count));
  //synchro
  s := '';
  marklock := false;
  if not fSynchroLockedByWait then
   begin
     marklock := true;
     comportsynchro.BeginWrite;
   end;
    //read chars into internal buffer
    n := count;
    if com.Connected then com.ReadStr(s, n);
  //!!unlock if necessary
  if marklock then comportsynchro.EndWrite;
  //store
  rxbuf := rxbuf + s;
  //check if message is completed - stop condition
  if IsEndOfPacket then
    //end of line found, signal event
    begin
      //rxPacketEnd.SetEvent;    //DOES NOT WORK SOMEHOW - use of single evnet FREEZES PROGRAM
    end;
end;


function TMyFlowAquireThread.IsEndOfPacket: boolean;
Const
  CMarkEnd = #13;
begin
  Result := False;
  if length(rxbuf)=0 then exit;
  if Pos(CMarkEnd, rxbuf)>0 then Result := true else Result := false;
end;


procedure TMyFlowAquireThread.MyThreadProcessMessages;
var
  Msg: TMsg;
begin
      while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
end;

procedure TMyFlowAquireThread.DummyMethod;
begin
end;

function TMyFlowAquireThread.ActivelyWaitForReply(timeoutx: longword): boolean; //if timeout return false
Var
  d, d0: TDateTime;
  tout: boolean;
begin
  Result := false;
  d0 := Now();
  d := d0 + timeoutx/3600/24/1000;
  //lock access to comport
  if fSynchroLockedByWait then exit; //shoudl not ever happen
  if comportsynchro=nil then exit;

  fSynchroLockedByWait := true;
  comportsynchro.BeginWrite;
    //!!! mark that the port is locked
  tout := true;
  while d>Now() do
  begin
    //need to process received messages from system, because that is the way how this implementation of serial port works!!!
    //but should not use ApplicationProcessMessages inside a thread -> so I use my own loop fro processing
    //found here:  http://stackoverflow.com/questions/15467263/how-do-i-forcibly-process-messages-inside-a-thread (Remy Lebeau)
    //MyThreadProcessMessages; //try disable now when used syncmethod=smNone;
    //Synchronize( DummyMethod );  //NO hANGS!!! //just forces to wait for the main thread ti be sure entering message queue
    if IsEndOfPacket then
      begin
        tout := false;
        Result := true;
        break;
      end;
  end;
  comportsynchro.EndWrite;
  if not tout then if fDebug then   LeaveLogMsg('iiii TTTT TMyFlowAquireThread.ActivelyWaitForReply: got pakcet in(ms):'+ DateTimeMStoStr( TimeDeltaNow(d0)) );
  if tout then LeaveLogMsg('WWWW ActivelyWaitForReply: TIMEOUT!! ('+ IntToStr(timeoutx) +')');
  fSynchroLockedByWait := false;
end;                                                                       //WaitForSingleObject


function TMyFlowAquireThread.ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
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



procedure TMyFlowAquireThread.IncErrCnt; //does no begin/end write - expect it will be called only internally
begin
  if comportsynchro=nil then exit;
  comportsynchro.BeginWrite;
    comportsynchro.comerrcnt := comportsynchro.comerrcnt + 1;
  comportsynchro.EndWrite;
end;


procedure TMyFlowAquireThread.IncOKCnt;  //does no begin/end write
begin
  if comportsynchro=nil then exit;
  comportsynchro.BeginWrite;
    comportsynchro.comokcnt := comportsynchro.comokcnt + 1;
  comportsynchro.EndWrite;
end;


function TMyFlowAquireThread.comSendLowLvl(s: string): boolean;  //only send
Var
  com: TComPort;
  e: boolean;
begin
  Result := false;
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then exit;
  //LeaveLogMsg('TMyFlowAquireThread.comSend: msg="' + BinStrToPrintStr( s ) +'"' );
  comportsynchro.BeginWrite;
  if Com.Connected then
    begin
     e := true;
     Com.ClearBuffer(true, true);
     Com.WriteStr(s);
    end
  else
    begin
      e := false;
    end;
  comportsynchro.EndWrite;
  if not e then LeaveLogMsg('EEEE TMyFlowAquireThread.comSend: ComPort NOT CONNECTED' );
  Result := e;
end;


function TMyFlowAquireThread.comRecvLowLvl(Var answer: string): boolean;
//only receive   !!! do not use inside critical/locked section - needs to process messages - may dead lock
  //wait for reply
begin
end;

function TMyFlowAquireThread.comSend(cmd: string; Var answer: string): boolean;
//basic comm - sends and receives answer
//!!! do not use inside critical/locked section - needs to process messages - may dead lock
begin
end;





//****************************
//        Alicat flow control
//****************************


constructor TAlicatFlowControl.Create;
begin
  inherited;
  fName := CInterfaceVer; //'Alicat RS232 Flow Control';
  fDummy := false;
  comportsynchro := TComportThreadSafe.Create;
  AquireThread := TMyFlowAquireThread.Create;
  if AquireThread<>nil then AquireThread.AssignComPortSynchro(comportsynchro);
  fready := false;
  fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, 'AlicatFLOW' );
  logmsg('TAlicatFlowControl.Create: done.');
end;


destructor TAlicatFlowControl.Destroy;
Var i: integer;
begin
  fready := false;
  CloseComPort;
  // unreg variables references inside configmanager (but not destroy!!)
  fConfClient.Destroy;
  if AquireThread<> nil then
    begin
      AquireThread.Terminate;
      //!!! wait to terminate
      i :=100;
      while (not AquireThread.Terminated) do
        begin
          sleep(100);
          Dec(i);
          if i<1 then break; //force quit waiting if takes too long
        end;
      AquireThread.BeforeDestroy;
      AquireThread.Free;  //instead of Destory call FREE!!! as is described in the help
                          //destroy causes program hang on exit;
                          //- now freeonterminate is set FALSE, so I need to call free!!!
    end;
  //terminate comport
  comportsynchro.Destroy;
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
  fReady := false;
  fsetp[CFlowAnode] := 0;   //CFlowAnode, CFlowCathode, CFlowN2, CFlowRes
  fsetp[CFlowCathode] := 0;
  fsetp[CFlowN2] := 0;
  fsetp[CFlowRes] := 0;
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
  if not IsThreadRunning then
        begin
          logmsg('TAlicatFlowControl.Initialize: Thread is NOT running -> exit');
          exit;
        end;
  //reset last aquire time
  ResetLastAquireTime;
  //
  fUserCmdReplyIsNew := false;
  fready := true;
  Result := true;
  logmsg('TAlicatFlowControl.Initialize: Connected to AlicatRS232!!!' );
  logmsg('             .... Iface ver str: ' + CInterfaceVer );
end;


procedure TAlicatFlowControl.Finalize;
begin
  logmsg('TAlicatFlowControl.Finalize: Stopping thread...!!!' );
  ThreadStop;
  CloseComPort;
  fready  := false;
end;


procedure TAlicatFlowControl.ResetConnection;
//close port, open port - this should help it seems
Var
  com: TComPort;
begin
  logmsg('TAlicatFlowControl.ResetConnection: Closing and opening PORT!!!' );
  CloseComPort;
  Sleep(50);
  //Application.ProcessMessages;   //tapplication  //  //!!!!!!!!!!!!!!  FUJ FUJ
  OpenComPort;
end;


function TAlicatFlowControl.Aquire(Var data: TFlowData; Var status: TCommDevFlagSet): boolean;
//
Var
  d: TFlowDevices;
  TSdata: TFlowDataThreadSafe;
  lastaq : tDateTime;
begin
  Result := false;
  status := [];
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
  if TimeDeltaNowMS( lastaq ) > CFlowTimeoutConstMS then  Include(status, CConnectionLost);
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
  if AquireThread<>nil then AquireThread.SetDebug( b );
end;


procedure TAlicatFlowControl.LeaveMsg(s: string); //log msg - App log
begin
  logmsg('ii TAlicatFlowControl: '+ s);
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
Var com : TComPort;
begin
  if comportsynchro=nil then
    begin
      logerror('TAlicatFlowControl.SetupComPort:  comportsynchro=nil');
      exit;
    end;
  com := comportsynchro.ComPort;
  comportsynchro.BeginWrite;
    if com<>nil then com.ShowSetupDialog
    else
      begin
        logerror('TAlicatFlowControl.SetupComPort;:  comport=nil ');
        comportsynchro.EndWrite;
        exit;
      end;
  comportsynchro.EndWrite;
  logmsg('TAlicatFlowControl.SetupComPort;:  new config= ' + com.Port + ' par=' + ParityToStr( com.parity.Bits ) + ' baud=' + BaudRateToStr( com.BaudRate ));
  //ShowMessage('comport conf change');
end;

procedure TAlicatFlowControl.SaveComPortConf(conffile: string);
Var com : TComPort;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then begin logmsg('TAlicatFlowControl.SaveComPortConf:  comport=nil '); exit; end;
  comportsynchro.BeginWrite;   //exclusive access
    com.StoreSettings(stIniFile, conffile);
  comportsynchro.EndWrite;
end;


procedure TAlicatFlowControl.LoadComPortConf(conffile: string);
Var com : TComPort;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then begin logmsg('TAlicatFlowControl.LoadComPortConf:  comport=nil '); exit; end;
  comportsynchro.BeginWrite;
    com.LoadSettings(stIniFile, conffile);
  comportsynchro.EndWrite;
end;



function TAlicatFlowControl.IsPortOpen(): boolean;
Var
  com: TComPort;
begin
  Result := False;
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then exit;
    Result := com.Connected;
end;


function TAlicatFlowControl.OpenComPort(): boolean;
Var
  com: TComPort;
begin
  Result := False;
  if comportsynchro=nil then
    begin
      logerror('TAlicatFlowControl.OpenPort():  comportsynchro=nil');
      exit;
    end;
  com := comportsynchro.ComPort;
  if com=nil then
    begin
      LogError('TAlicatFlowControl.OpenPort(): comport=nil');
      exit;
    end;
  comportsynchro.BeginWrite;
    com.Open;
    com.SetDTR(true); //!!!!!!! ABSOLUTELY MUST BE SET otherwise partner device generaly will not send anything
    com.SetRTS(true);
    Result := com.Connected;
  comportsynchro.EndWrite;
end;


procedure TAlicatFlowControl.CloseComPort;
Var
  com: TComPort;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then
    begin
      LogError('TAlicatFlowControl.ClosePort: comport=nil');
      exit;
    end;
  comportsynchro.BeginWrite;
    com.Close;
  comportsynchro.EndWrite;
  CheckSynchronize(1);
  leavemsg('ClosePort - PORT CLOSED');
end;



function TAlicatFlowControl.getPortName(): string;
Var
  com: TComPort;
begin
  Result := '';
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then exit;
    Result := com.Port;
end;


function TAlicatFlowControl.getBaudRate(): string;
Var
  com: TComPort;
begin
  Result := '';
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  comportsynchro.BeginRead;
    Result := BaudRateToStr( Com.BaudRate ) ;
  comportsynchro.EndRead;
end;

procedure TAlicatFlowControl.setBaudRate(brstr: string);
Var
  com: TComPort;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then
    begin
      LogError('TAlicatFlowControl.setBaudRate comport=nil');
      exit;
    end;
  comportsynchro.BeginWrite;
    Com.BaudRate := StrToBaudRate( brstr ) ;
    leavemsg('setBaudRate: CHANGED to: '+ brstr);
  comportsynchro.EndWrite;
end;

procedure TAlicatFlowControl.getComPortConf;
Var
  com: TComPort;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then exit;
  comportsynchro.BeginRead;
    fComPortName := com.Port;
    fComPortBR := BaudRateToStr( Com.BaudRate ) ;
    fComPortStopBits := StopBitsToStr( Com.StopBits );
    fComPortDataBits := DataBitsToStr( Com.DataBits );
    fComPortParity := ParityToStr( Com.Parity.Bits );
    fComPortFlowCtrl := FlowControlToStr( Com.FlowControl.FlowControl );
  comportsynchro.EndRead;
end;

procedure TAlicatFlowControl.setComPortConf;
Var
  com: TComPort;
begin
  if comportsynchro=nil then exit;
  com := comportsynchro.ComPort;
  if com=nil then exit;
  comportsynchro.BeginWrite;
    com.Port := fComPortName;
    com.BaudRate := StrToBaudRate(fComPortBR);
    com.StopBits := StrToStopBits(fComPortStopBits);
    com.DataBits := StrToDataBits(fComPortDataBits);
    com.Parity.Bits := StrToParity(fComPortParity);
    com.FlowControl.FlowControl := StrToFlowControl( fComPortFlowCtrl );
  comportsynchro.EndWrite;
end;




function TAlicatFlowControl.getErrCount(): longint;
begin
  Result := -1;
  if comportsynchro=nil then exit;
  Result :=  comportsynchro.comerrcnt;
end;


function TAlicatFlowControl.getOKCount(): longint;
begin
  Result := -1;
  if comportsynchro=nil then exit;
  Result :=  comportsynchro.comokcnt;
end;

procedure TAlicatFlowControl.resetErrOKCounters;
begin
  if comportsynchro=nil then exit;
  comportsynchro.BeginWrite;
  comportsynchro.comokcnt := 0;
  comportsynchro.comerrcnt := 0;
  comportsynchro.EndWrite;
end;



procedure TAlicatFlowControl.ThreadStart;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling RESUME');
  AquireThread.MySuspend := false;
  AquireThread.Resume;     //TThread  //in case it was suspended
end;


procedure TAlicatFlowControl.ThreadStop;
begin
  if AquireThread = nil then exit;
  logmsg('TAlicatFlowControl.ThreadStart: calling SUSPEND');
  //AquireThread.Suspend;  //apparently can freeze if supsended in middle of communication
  //AquireThread.Terminate;   //cannot be restarted
  AquireThread.MySuspend := true;
end;


function TAlicatFlowControl.IsThreadRunning(): boolean;
begin
  Result := false;
  if AquireThread = nil then exit;
  if (not AquireThread.Terminated) and (not AquireThread.Suspended) and (not AquireThread.MySuspend) then Result := true;
end;

function TAlicatFlowControl.getThreadStatus: string;
begin
  Result := 'NIL';
  if AquireThread = nil then exit;
  if AquireThread.Suspended then Result := 'Suspended';
  if AquireThread.Terminated then Result := 'Terminated';
  if (AquireThread.Terminated) and (AquireThread.Suspended) then Result := 'Suspended+Terminated';
  if (not AquireThread.Terminated) and (not AquireThread.Suspended) then Result := 'Running...';
  if AquireThread.MySuspend then Result := Result + '/NoAquire';
end;



procedure TAlicatFlowControl.UpdateDevicesInThread;
Var
  devsync: TFlowDevicesListThreadSafe;
  d: TFlowDevices;
begin
  if AquireThread = nil then exit;
  devsync := AquireThread.devicessynchro;
  if devsync = nil then exit;
  CheckSynchronize(1);
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
    Result := devsync.GetNDev;
end;


function TAlicatFlowControl.SendUserCmd(cmd: string): boolean;
Var
  cmdsync: TCmdQueueThreadSafe;
  b, CanAdd: boolean;
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


procedure TAlicatFlowControl.LoadConfig;
begin
   fSetpCompatibMode := fConfClient.Load('SetpCompatibMode', false);
   fComPortName := fConfClient.Load('PortName', 'COM2');
   fComPortBR   := fConfClient.Load('BaudRate', '19200');
   fComPortDataBits  := fConfClient.Load('DataBits', '8');
   fComPortStopBits  := fConfClient.Load('StopBits', '1');
   fComPortParity    := fConfClient.Load('Parity', 'None');
   fComPortFlowCtrl  := fConfClient.Load('FlowControl', 'None');
   setComPortConf;
end;




procedure TAlicatFlowControl.DoAfterLoad; //process values after load process of config manager registered variables
begin
end;


procedure TAlicatFlowControl.SaveConfig;
begin
  getComPortConf;
  fConfClient.Save('SetpCompatibMode', fSetpCompatibMode);
  fConfClient.Save('PortName', fComPortName);
  fConfClient.Save('BaudRate', fComPortBR);
  fConfClient.Save('DataBits', fComPortDataBits);
  fConfClient.Save('StopBits', fComPortStopBits);
  fConfClient.Save('Parity', fComPortParity);
  fConfClient.Save('FlowControl', fComPortFlowCtrl);
end;

//****************************************************



constructor TComPortThreadSafe.Create;
begin
  inherited;
  comport := TComPort.Create(nil);
  //assign onRx event handler
  if comport<>nil then comport.OnRxChar := nil; //ComPortRxChar;
end;

destructor TComPortThreadSafe.Destroy;
begin
  comport.Destroy;
  inherited;
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
  //nextpoll[dev] := 0;
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

unit PTCInterface_BK8500;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, Windows,
  myutils, Logger, ConfigManager, MyParseUtils, StrUtils,
  FormGlobalConfig,
  HWAbstractDevicesV3, LoggerThreadSafe,
  MyAquireThreadRS232, MyComPort;


Const
 CPtcIfaceVer = 'BK8500 interface 2016-08-15';
 CPtcIfaceVerLong = CPtcIfaceVer +  'by Michal Vaclavu';

 CBKConfigSection = 'BK8500Interface';

 CDebug = false; //true;

 CBKMsgLen = 26;

type
//BK8500 status description

    TBKMode = (CBKCC, CBKCV, CBKCR, CBKCP);
    TBKFunction = (CBKFixed,  CBKShort, CBKTransient, CBKList, CBKBattery);

TBKStatus = record
   OutputOn: boolean;
   U: double;
   I: double;
   P: double;
   Mode: TBKMode;
   Func: TBKFunction;
   //from status reg
   Calculating: boolean;
   WaitingForTrigger: boolean;
   RemoteIsOn: boolean;
   LocalKeyOn: boolean;
   RemSensingIsON: boolean;
   TimerIsON: boolean;
   ReversedVoltage: boolean;
   OverV: boolean;
   OverC: boolean;
   OverP: boolean;
   OverTemp: boolean;
   IsCC: boolean;
   IsCV: boolean;
   IsCP: boolean;
   IsCR: boolean;
   NotRemoteConnect: boolean;
   Lastreg1: byte;
   Lastreg2: word;
end;



   TBK8500message = record
     data: array[0..CBKMsgLen-1] of byte;
     len: word;
   end;


  TBK8500Potentio = class (TPotentiostatObject)
    public
      constructor Create;
      destructor Destroy; override;
    public
    //inherited virtual functions - must override!
    //Basic Potenciostat control funcions - made available on all devices
      function AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean; override;
    //  returns electrical DATA and status
    //  this is the only fucntion that actualy aquires the status info (every time it is called)
    //  and after each call the internal status is updated and with it, also the corresponding flags if relevant!
    //  !!! range of voltage and current is checked (and flags set),
    //               but NO ACTION IS TAKEN to prevent overrange -> This should be done by HIGHER LEVEL control fucntion!!!!
      function SetCC( val: double): boolean; override;
      function SetCV( val: double): boolean; override;
      function TurnLoadON(): boolean; override;
      function TurnLoadOFF(): boolean; override;
    public
    //general control functions
      function IsAvailable(): boolean; override;        //indication that device is available = ready to be initialized (meaning can be communicated with)
                                                          //if false, it means the device cannot be initilized and cannot become ready
      function Initialize(): boolean; override;   //assuming the device is available and connected, try to set initial condition
                                                       //without initialization, the device should not become ready
      procedure Finalize; override;   //do tasks to  prepare for disconnecting
                                              // device will become not ready, if possible - object will disconnect the port beeing used for communication
      function GetFlags(): TPotentioFlagSet; override;   //flags may be device specific, example of common flag would be "Current Overrange" indicator
    //
    private
    //iherited internal fields (for properties)
    //fName: string;
    //fDummy: boolean;
    //fReady: boolean;
    //fRngV4SWLimit: TRangeRecord;
    //fRngV4HardLimit: TRangeRecord;
    //fRngActCurr: TPotentioRangeRecord;
    //fRngActVolt: TPotentioRangeRecord;
    //fRngActCurrId: byte;
    //fRngActVoltId: byte;
    //fRngCurrCount: byte;
    //fRngVoltCount: byte;
    //statistics
    //fLastAquireTimeMS: longint;
    public //inherited
    //general properties
    //property Name: string read fName;                   //short name or description of device
    //property IsDummy: boolean read fDummy;            //true if NOT a REAL device
    //property IsReady: boolean read fReady;            //is ready to provide data - if not, the device will not be accepting commands
    //                                                    must call  Initialize first, to make it ready
    //statistics
    //property LastAquireTimeMS: longint read fLastAquireTimeMS;
  //RANGE reporting and control
    protected
      //procedure SetRngCurrent(nr: byte); virtual; abstract;
      //procedure SetRngVoltage(nr: byte); virtual; abstract;
      //procedure SetRngV4SwLimit(rec: TRangeRecord); override;
      //procedure SetRngV4HardLimit(rec: TRangeRecord); virtual; abstract;
      //procedure GetRngArrayCurrent( Var ar:TPotentioRangeArray); virtual; abstract;
      //procedure GetRngArrayVoltage( Var ar:TPotentioRangeArray); virtual; abstract;
	  //RANGE reporting and control
	  protected
	    procedure SetRngCurrent(nr: byte); override;
	    procedure SetRngVoltage(nr: byte); override;
	    procedure SetRngV4SwLimit(rec: TRangeRecord); override;
	    procedure SetRngV4HardLimit(rec: TRangeRecord); override;
	  public
	    procedure GetRngArrayCurrent( Var ar:TPotentioRangeArray); override;
	    procedure GetRngArrayVoltage( Var ar:TPotentioRangeArray); override;
    public
    //
    public
      //procedure ResetConnection; //override;
    //
    private
      fConStatus: TInterfaceStatus;
      fFlagSet: TPotentioFlagSet;      
      fDebug: boolean;
      //configuration
      fRemoteSenseOn: boolean;
      fTimeout: longint;
      procedure setDebug(b: boolean);
    public
      property ConStatus: TInterfaceStatus read fConStatus;
      property Flags: TPotentioFlagSet read fFlagSet;
      property Debug: boolean read fDebug write setDebug;
      property BKRemoteSenseOn: boolean read fRemoteSenseOn write fRemoteSenseOn;
      property BKTimeout: longint read fTimeout write fTimeout;
    public
      procedure LoadConfig;
      procedure SaveConfig;  // prepare variables to be saved config manager
    public
      //Comport operation, configuration
      function OpenComPort(): boolean;
      procedure CloseComPort;
      procedure SetupComPort;
      //procedure getComPortConf;
      //procedure setComPortConf;
      function isPortOpen(): boolean;
      function getPortName(): string;
      function getBaudRate(): string;
      procedure setPortName(s: string);      
      procedure setBaudRate(brstr: string);
      function getErrCount(): longint;
      function getOKCount(): longint;
      procedure resetErrOKCounters;
      //others---
      //function Ping(): boolean; //try some simple command to check response
    public
      //thread control
      //procedure ThreadStart;
      //procedure ThreadStop;
      //function IsThreadRunning(): boolean;
      //function getThreadStatus: string;
      //procedure UpdateDevicesInThread;
      //function GetNDevsInThread: byte;
      //function SendUserCmd(cmd: string): boolean;
      //procedure ReceiveReplyFromThread;       //"event handler" - reads reply from data.aswerlowlvl when beeing called as syncrhonize from thread
      //function GetLastCycleDurMS: longint;

    private
      fConfClient: TConfigClient;
      fLog:  TMyLoggerThreadSafe;
      //
      fsetp: array[TFlowDevices] of double;
      //configuration storage (need to use varibale, so it can be asigned to config manager
      fComPortConf: TComPortConf;
      fIsConfigured: boolean;
    private
      //procedure ResetLastAquireTime;

    public
      //hw specific features and configuration for this class

      function GetLastMode(): TPotentioMode;
      function GetLastSp(): double;
      function bkPing: string;

    private
      //communication with device on higher hw level
      function BKOpen(): boolean;
      procedure BKClose();
      procedure BKTurnONOFF( enabled: boolean);
      procedure BKsetRemote();
      procedure BKReadUIStatus;
      procedure BKSetConstC(setp: double);
      procedure BKSetConstV(setp: double); {setp: voltage in V}
      procedure BKSetIniParams();
      procedure BKGetExtendedState();
    private
      //low level comm functions
      function BKsendcmd( Var cmd: Tbk8500message ): boolean;
      function BKReceiveMsg(Var msg: TBK8500message; timeout: longint): boolean; //returns true on success , fills internal bkrxbuf!!!
      function BKgetResult( Var res: Tbk8500message; Var rescode: integer ): boolean;
      function BKIsEndOfMessage(Const recvbuf: string): boolean;
      function BKSendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //needs isendofmessage fucntion

    private
      bklock: boolean;  //prevent multiple calls to comm fucntions (because during receive - waiting and calling app.procmessages)
      fComPort: TComPortThreadSafe;    //!!!!!!main communication component
      fPortConf: TComPortConf;
      bkrxbuf: TBK8500message;
      bktxbuf: TBK8500message;

      lastmode: TBKMode;
      lastsetp: double;

      lastres: boolean;
      lastmsg: string;
      countererr: longint;    //counter of send msg/ recv msg errors
      counterok: longint;     //ounter of send/recv msg success
    private
      //---error reporting and logging fucntion
      procedure IncErrCnt;
      procedure IncOKCnt;
      procedure bkmsg(s: string); //set lastmsg and log it at the same time  - into internal log
    public
      //last result
      LastU: double;
      LastI: double;
      LastP: double;
      LastTimestamp : double;  //now()
      BKStatus: TBKSTatus;
      LastCmdOK: boolean;
  end; //*************************



Var
   BKdebug:boolean;  //DEBUG!!!!!!!!!!!


// ---helper and conversion functions

function BKGeneralModetoInternal(fb:TPotentioMode): TBKMode;
function BKInternalModetoGeneral(mode:TBKMode): TPotentioMode;

procedure BKReportError(errlvl: byte; msg: string);

//---low level helper function --
function BKcalcchecksum(Var r: Tbk8500message): byte;
function BKcheckcommand(Var r: Tbk8500message): boolean;
function BKCmdtostring(Var cmd: Tbk8500message): string;
procedure BKPrepareEmptyCmd(Var cmd: Tbk8500message; addr:byte=0); {  sets first byte, address to 0, and emty all other bytes}
procedure BKFinishCmd(Var cmd: Tbk8500message);
procedure BKNumberTo4Bytes( n: longint; Var a, b, c, d: byte );
procedure BK4BytesToNumber(a, b, c, d: byte; Var n: longint);
procedure BKDecodeVal4ByteFromCmd( Var cmd: Tbk8500message; offs: byte; Var n: longint);
//------



Implementation



uses Math, Forms, DateUtils;


//---- private variables declaration

Var
   //Serial1 : TBlockSerial;
    BKlastcmd: Tbk8500message;
    BKlastResult: Tbk8500message;
    BKConnected: boolean;
    BKlastOK: boolean;
    BKlastResCode: integer;
    BKlastErrorMsg: string;
    BKDebugfile: text;



procedure BKReportError(errlvl: byte; msg: string);
begin
  logmsg('BKReport error: (' + IntToStr(errlvl) + ') ' + msg);
end;




//*************************










constructor TBK8500Potentio.Create;
begin
  inherited Create('BK8500 Electronic Load', CPtcIfaceVer, false);
  setIsReady(false);
  fConStatus := CISError;
  fFlagSet := [];
  fIsConfigured := false;
  // init config object
  fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, CBKConfigSection);
  //internal log
  fLog := TMyLoggerThreadSafe.Create('!ptc-bk8500-log_','');
  // com port
  fComport := TComPortThreadSafe.Create;
end;


destructor TBK8500Potentio.Destroy;
begin
  fComport.Destroy;
  fConfClient.Destroy;
  fLog.Destroy;
  inherited;
end;



function TBK8500Potentio.IsAvailable(): boolean;
begin
  Result := fIsConfigured;
end;




function TBK8500Potentio.Initialize: boolean;
Var
 b1, b2, b3: boolean;
begin
  logmsg('TBK8500Potentio.Initialize');
  Result := false;
  if IsReady then Finalize;
  setIsReady(false);
  lastmode:= CBKCC;
  lastsetp := 0.0;
  //open com port
  b1 := BKOpen;
  logmsg('TBK8500Potentio.Initialize: after open port ' + BoolToStr(b1) );
  if not b1 then
    begin
      bkmsg('TBK8500Potentio.Initialize: ComPort open failed');
      exit;
    end;
  //try simple comm with load to test communication
  //BKConnected := true;

  //force initial state
  //update present settings
  //TurnLoadOFF;
  //BKSetConstC( 0.0 );
  //SetSetpoint( 0.0 );
  //done
  BKtimeout := 1000;
  bkmsg('TBK8500Potentio.Initialize: Connected to BK8500 load Interface');
  bkmsg('TBK8500Potentio.Initialize: Interface info: ' + DevName + '| ' + InterfaceId );
  bkmsg('TBK8500Potentio.Initialize: OK & ready');
  setIsReady(true);
  Result := true;
end;


procedure TBK8500Potentio.Finalize;
begin
  setIsReady(false);
  BKConnected := false;
  CloseComPort;
end;






//basic control functions - override
function TBK8500Potentio.AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean;
//description of inputs "ain":  now stoed in configuration record
Const
  CThisProcName = 'AquireDataStatus';
Var
    V2raw, V4raw, Vrefraw, Iraw, SPraw: double;
    Ifin, Ufin: double;
    b1, b2, b3 : boolean;
    bfuse: boolean;
    i: integer;
    n: byte;
    t0: Longword;
begin
    Result := false;
    InitPtcRecWithNAN( rec, status );
    rec.timestamp := Now();
    setLastAcqTimeMS(-1);
    FlagUpdate(not fIsConfigured, CPtcNotConfigured, fFlagSet );
    FlagUpdate(not IsAvailable, CNotAvailable, fFlagSet );
    if not IsAvailable then
      begin
        exit;
      end;
    if IsReady then
      begin
       bkmsg('TBK8500Potentio.AquireDataStatus: NOT READY');
       exit;
      end;
    //no check for available necessary - it is done on the lower level
    b1 := false;
    b2 := false;
    t0 := TimeDeltaTICKgetT0;
    //aquire
    try
		  BKReadUIStatus;
    except
      on E: Exception do
        begin
          bkMsg('EEEE AquireDatastatus EXCEPTION: ' + E.message);
          exit;
        end;
    end;

		  if not LastCmdOK then
		  begin
		    bkmsg('TBK8500Potentio.AquireDataStatus: failed');
		    IncErrCnt;
		    exit;
		  end;
    setLastAcqTimeMS( TimeDeltaTICKNowMS(t0) );
  with rec do
    begin
        timestamp := Now;
        U := LastU;
        I := LastI;
        P := LastP;
        Uref := NaN;
   end;
    with Status do
      begin
       flagSet := fFlagSet;
       setpoint := lastsetp;
       mode := BKInternalModeToGeneral( BKStatus.Mode );
       isLoadConnected := BKStatus.OutputOn;
       //
       rangeCurrent := fRngCurrRec;
       rangeVoltage := fRngVoltRec;
       rngV4Safe := fRngV4SWLimit;
       rngV4hard :=  fRngV4HardLimit;
       //                                                          //set
       debuglogmsg := '[BK8500]|'+
                      'Output=' + BoolToStr(isLoadConnected) +
                      '|Mode=' + IntToStr(Ord(mode)) +
                      '|setp=' + FloatToStrF(setpoint, ffFixed, 4,2);
      end;

   if cDebug then bkmsg('TBK8500Potentio.AquireDataStatus: GetData OK.');
   Result := true;
end;





function TBK8500Potentio.SetCC( val: double): boolean;
begin
  if not IsReady then
    begin
     bkmsg('TBK8500Potentio.SetCC: NOT READY');
     exit;
    end;
  if CDebug then bkmsg('TBK8500Potentio.SetCC: in here');
  BKSetConstC( val);
  Result :=  LastCmdOK;
end;

function TBK8500Potentio.SetCV( val: double): boolean;
begin
  if not isReady then
    begin
     bkmsg('TBK8500Potentio.SetCV: NOT READY');
     exit;
    end;
  if CDebug then bkmsg('TBK8500Potentio.SetCV: in here');
  BKSetConstV(val);
  Result :=  LastCmdOK;
end;


function TBK8500Potentio.TurnLoadON: boolean;
begin
  if not isReady then
    begin
     bkmsg('TBK8500Potentio.TurnLoadON: NOT READY');
     exit;
    end;
  BKTurnONOFF( true );
  Result := LastCmdOK;
end;



function TBK8500Potentio.TurnLoadOFF: boolean;
begin
  if not isReady then
    begin
     bkmsg('TBK8500Potentio.TurnLoadOFF: NOT READY');
     exit;
    end;
  BKTurnONOFF( false );
  Result := LastCmdOK;
end;





//***********ranges  *****

procedure TBK8500Potentio.SetRngCurrent(nr: byte);
begin
  fRngVoltRec.low := 0;   fRngVoltRec.high := 30;
end;

procedure TBK8500Potentio.SetRngVoltage(nr: byte);
begin
  fRngVoltRec.low := 0;   fRngVoltRec.high := 15;
end;


procedure TBK8500Potentio.SetRngV4SwLimit(rec: TRangeRecord);
begin
  fRngV4SWLimit := rec;
  fRngV4HardLimit := rec;
end;

procedure TBK8500Potentio.SetRngV4HardLimit(rec: TRangeRecord);
begin
  fRngV4SWLimit := rec;
  fRngV4HardLimit := rec;
end;

procedure TBK8500Potentio.GetRngArrayCurrent( Var ar:TPotentioRangeArray);
begin
  setlength(ar, 0);
end;

procedure TBK8500Potentio.GetRngArrayVoltage( Var ar:TPotentioRangeArray);
begin
  setlength(ar, 0);
end;


//*********************



procedure TBK8500Potentio.setDebug(b: boolean);
begin
  fDebug := b;
  //if AquireThread<>nil then AquireThread.Debug := b;
end;



procedure TBK8500Potentio.LoadConfig;
Var
  fComPortConf: TComPortConf;
begin
   with fComPortConf do
     begin
       Name := fConfClient.Load('PortName', 'COM4');
       BR   := fConfClient.Load('BaudRate', '38400');
       DataBits  := fConfClient.Load('DataBits', '8');
       StopBits  := fConfClient.Load('StopBits', '1');
       Parity    := fConfClient.Load('Parity', 'None');
       FlowCtrl  := fConfClient.Load('FlowControl', 'None');
     end;
  fRemoteSenseOn := fConfClient.Load('fRemoteSenseOn', true );
  //
  fComPort.setComPortConf( fComPortConf );
  fIsConfigured := true;
end;

procedure TBK8500Potentio.SaveConfig;
Var
  fComPortConf: TComPortConf;
begin
  fComPort.getComPortConf(fComPortConf);
  with fComPortConf do
    begin
      fConfClient.Save('PortName', Name);
      fConfClient.Save('BaudRate', BR);
      fConfClient.Save('DataBits', DataBits);
      fConfClient.Save('StopBits', StopBits);
      fConfClient.Save('Parity', Parity);
      fConfClient.Save('FlowControl', FlowCtrl);
    end;
  fConfClient.Save('fRemoteSenseOn', fRemoteSenseOn );
end;



//-------------

//hw specific features and configuration
//function TBK8500Potentio.PotentioSetup(port:string; baud: longint): boolean;
//begin
//  ShoweMessage('not inmpleneted');
//end;

procedure TBK8500Potentio.SetupComPort;
begin
  if fComPort<>nil then fComPort.ShowSetupDialog;
end;

function TBK8500Potentio.isPortOpen(): boolean;
begin
  Result := false;
  if fComport=nil then
    begin
      bkmsg('TTBK8500Potentio.isPortOpen:  comport=nil');
      exit;
    end;
  Result := fComPort.IsPortOpen;
end;

function TBK8500Potentio.OpenComPort(): boolean;
begin
  Result := false;
  if fComport=nil then
    begin
      bkmsg('TTBK8500Potentio.OpenComPort:  comport=nil');
      exit;
    end;
  Result := fComPort.OpenPort;
end;

procedure TBK8500Potentio.CloseComPort;
begin
  if fComport=nil then
    begin
      bkmsg('TTBK8500Potentio.CloseComPort:  comport=nil');
      exit;
    end;
  fComPort.ClosePort;
end;

function TBK8500Potentio.getPortName(): string;
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  Result := pc.Name;
end;

procedure TBK8500Potentio.setPortName(s: string);
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  pc.Name := s;
  fComPort.setComPortConf( pc );
end;


function TBK8500Potentio.getBaudRate(): string;
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  Result := pc.BR;
end;

procedure TBK8500Potentio.setBaudRate(brstr: string);
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  pc.BR := brstr;
  fComPort.setComPortConf( pc );
end;









//procedure TBK8500Potentio.SetMode( mode: TPotentioMode );
//Var
// bkm: TBKMode;
//begin
//  bkm := PtcModetoInternal( mode );
//end;


function TBK8500Potentio.GetLastMode(): TPotentioMode;
begin
  Result := BKInternalModetoGeneral( lastmode );
end;


function TBK8500Potentio.GetLastSp(): double;
begin
  Result := lastsetp;
end;


//hw communication control
function TBK8500Potentio.getErrCount(): longint;
begin
  Result := countererr;
end;

function TBK8500Potentio.getOKCount(): longint;
begin
  Result := counterOK;
end;

procedure TBK8500Potentio.IncErrCnt;
begin
  Inc(countererr);
end;

procedure TBK8500Potentio.IncOKCnt;
begin
  Inc(counterOK);
end;

procedure TBK8500Potentio.resetErrOKCounters;
begin
  countererr := 0;
  counterOK := 0;
end;


function TBK8500Potentio.GetFlags(): TPotentioFlagSet;
begin
  Result := fFlagSet;
end;



function TBK8500Potentio.bkPing: string;
begin
  BKReadUIStatus;
  if BKlastOK then Result:='OK -  U= '+ FloatToStr( LastU )
  else
    Result := 'failed';
end;


procedure TBK8500Potentio.bkmsg(s: string); //set lastmsg and log it at the same time
begin
  lastmsg := 'BK8500: '+ s;
  fLog.LogMsg(lastmsg);
end;



//**************
//low level functions
//


procedure TBK8500Potentio.BKclose();
begin
  if BKconnected then
    begin
      bkmsg('BKClose: was BKConnected...');
      CloseComPort;
    end;
  BKconnected := false;
end;


function TBK8500Potentio.BKopen(): boolean;
begin
  BKConnected := false;
  Result := false;
  fConStatus := CISError;
  //check if initialized
  //connect
  Result := OpenComPort;
  BKConnected := Result;
  //check error
  if not Result then
    begin
      bkmsg('Serial conn  fail on: open');
      logerror('BK8500: COM  - failed open!');
      exit;
    end;
end;




function TBK8500Potentio.BKsendcmd( Var cmd: Tbk8500message ): boolean;
Var
  a: ansistring;
  i: byte;
  t1: Cardinal;
  timeout, b : boolean;
  sstr: string;
begin
  //lock critical section
  if bklock then
    begin
      exit;
       bkmsg('TBK8500Potentio.BKsendcmd: error - lock already engaged' );
    end
  else
    bklock := true; //!! important
  //
  //emptyerrorset := [];
  BKlastcmd := cmd;
  setlength(a, 26);
  for i:=0 to 25 do a[i+1] := AnsiChar( chr( cmd.data[i] ) );
  //flush comport buffer and !also my internal receive buffer
  fComPort.ClearInputBuffer;
  //ClearIntBuffer;
  bkrxbuf.len := 0;
  t1 := GetTickCount;
  sstr := a;
  b := fComPort.SendStringRaw( sstr );
  //check error
  if fDebug then bkmsg('send cmd took (ticks): ' + IntToStr( GetTickCount() - t1 ) + ' timeout ' + BoolToStr( timeout));
  BKLastOK := b;
  bkmsg('TBK8500Potentio.BKsendcmd: Finish send - result ' + BoolToStr(BKLastOk) );
  Result := BKLastOK;
  bklock := false;
end;

function TBK8500Potentio.BKIsEndOfMessage(Const recvbuf: string): boolean;
begin
  Result := False;
  Result := length(recvbuf)>= CBKMsgLen;
end;

function TBK8500Potentio.BKSendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //needs isendofmessage fucntion
Var
  n, i: longint;
  bs, br: boolean;
  //dtout: TDateTime;
  t0: longword;
  tout: boolean;
  s: string;
begin
  Result := false;
end;



function TBK8500Potentio.BKReceiveMsg(Var msg: TBK8500message; timeout: longint): boolean; //returns true on success , fills internal bkrxbuf!!!
//returns true on success , reads from  internal bkrxbuf!!!
Var i: integer;
    strt: TDateTime;
    t1: Cardinal;
    b: boolean;
    rstr: string;
  bs, br: boolean;
  //dtout: TDateTime;
  t0: longword;
  tout: boolean;
  s, reply: string;
begin
  Result := false;
  if bklock then
    begin
      exit;
       bkmsg('TBK8500Potentio.BKReceiveMsg: error - lock already engaged' );
    end
  else
    bklock := true; //!! important
  //
  //bkrxbuf.len := 0;
  if not BKConnected then
    begin
    bkmsg('TBK8500Potentio.BKReceiveMsg: BKConnected false' );
    bklock := false;
    exit;
    end;

     strt := Now;
     t1 := GetTickCount;

     //receive tiomeout
     //before sending prepare for receiving
     reply := '';
     tout := true;
     fcomport.RecvEnabled := true;
     t0 := TimeDeltaTICKgetT0;
     //receive
     while TimeDeltaTICKNowMS(t0)< timeout do
       begin
         br := fcomPort.ReadStringRaw(s);
         //if not br then continue;
         reply := reply + s;
         if BKIsEndOfMessage( reply ) then
           begin
             tout := false;
             break;
           end;
       end;
     fcomPort.RecvEnabled := false;   //do not expect any other incoming data

     Result := not tout;
   //convert to BK buf

   bkrxbuf.len := min( length(reply), 26);
   if bkrxbuf.len>0 then
     begin
       for i:=1 to bkrxbuf.len do
        begin
          bkrxbuf.data[i-1] := ord( reply[i] );
        end;
     end;

  if bkrxbuf.len < CBKMsgLen then
    begin
      bkmsg('TBK8500Potentio.BKReceiveMsg received less than expected amount of bytes - error exiting; reply was: ' + BinStrToPrintStr(reply) );
    end;

  if fDebug then bkmsg('TBK8500Potentio.BKReceiveMsg: receive took (ticks): ' + IntToStr( GetTickCount() - t1 ) + ' timeout ' + BoolToStr( tout));
  if fDebug then bkmsg('TBK8500Potentio.BKReceiveMsg: receive normal, len ' + IntToStr(bkrxbuf.len) );
  if fDebug and tout then bkmsg('TBK8500Potentio.BKReceiveMsg: TIMEOUT!!!! ' );

  //copy msg
  msg := bkrxbuf;
  //clear rx buffer
  bkrxbuf.len := 0;
  bklock := false;
end;




function TBK8500Potentio.BKgetResult( Var res: Tbk8500message; Var rescode: integer ): boolean;
{ parses return string - if the result was ok then returns true
in the "Res" this value is returned  -1=other error, 0=OK, 1= ...., 2= ...
//new version 2015-09-16 using BKgetMSG
}

Var
    i, len: integer;
    icmd, code: byte;
    r: string;
    b: boolean;
begin
  Result := false;
  rescode := -1;
  BKLastResCode := -1;
  //excpecting that before call to this function, the buffer had been cleared ...
  b := BKReceiveMsg(res, BKtimeout);
  if not b then
   begin
     bkmsg('TBK8500Potentio.BKgetResult: BKReceiveMsg failed');
     IncErrCnt;
     rescode := 2;
     Result := False;
     exit;
   end;
  // hech crc
  if not BKcheckcommand(res) then
   begin
     bkmsg('TBK8500Potentio.BKgetResult: checksum on received msg failed');
     IncErrCnt;
     rescode := 2;
     Result := False;
     exit;
   end;
  IncOKCnt;
  BKlastResult := res;
  rescode := 0;
  Result := true;
  BKLastResCode := rescode;
end;


{
TODO !!!!!!!!!!!!!!!!!!!!!!!
icmd := res.data[2];
  if icmd <> $12 then
   begin
     ShowMessage('icmd not $12');
     Result:= False; exit;
     end;
  //TODO:
  code := res.data[3];
  if code = $80 then rescode := 0
  else
  begin
   ShowMessage('code not $80');
    rescode := 1;
  end;
}









// ----------------------------------
// TBK8500 Potencio object



//////////////////////////////
{higher level commands...}
////////////////////////////////

procedure TBK8500Potentio.BKSetRemote();
Var
    cmd, res: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
begin
  BKLastOK := true;
  BKPrepareEmptyCmd( cmd );
  cmd.data[2] := $20;
  //set on or off depending on cofniguration
  if fRemoteSenseOn then
    cmd.data[3] := $01
  else
    cmd.data[3] := $00;
  BKFinishCmd( cmd );
  //
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if (not B) or (not b2)then BKLastOK := false;
  LastCmdOK := BKLastOK;
end;


procedure TBK8500Potentio.BKReadUIStatus();
Var
    cmd, resu: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
    v: longint;
    reg1: byte;
    reg2: word;
    VV : double;
    BK_TimeOfSending2, BK_TimeOfRecieving2: cardinal;
    BK_TimeOfSending, BK_TimeOfRecieving : Int64;
begin
  BKLastOK := true;
  //read display - 0x5F
  BK_TimeOfSending2 := GetTickCount();
  //BK_TimeOfSending := GetCPUTick();
  BKPrepareEmptyCmd( cmd );
  cmd.data[2] := $5F;
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( resu, rcode);
  BK_TimeOfRecieving2 := GetTickCount();
  //BK_TimeOfRecieving := GetCPUTick();
  //ShowMEssage( 'b ' + BoolToStr(b) + ' b2 ' + BoolToStr(b2));
  //
  if (not B) or (not b2)then BKLastOK := false;
  //tmp debug - write cmd to file
  if fDebug then
  begin
    bkmsg( DateTimeToStr(Now) + ' (ReadUI): send(' + BoolToStr(b) + ') recv(' + BoolToStr(b2) +')');
    bkmsg( BKCmdtostring(cmd) );
    bkmsg( BKCmdtostring(resu) );
    //Writeln(BKdebugfile, 'Elasped time for response: ', IntToStr(BK_TimeOfRecieving-BK_TimeOfSending));
    bkmsg( 'Elasped time for response: ' + IntToStr(BK_TimeOfRecieving2-BK_TimeOfSending2));
    bkmsg( '');
  end;
  //
  //parse result
  LastU:=0;
  LastI:=0;
  LastP:=0;
  //ShowMEssage( BoolToStr(bklastok) );
  if BKLastOK then begin
    //LastValid := true;
    LastTimestamp := now();
    //if rcode<>0 then exit;
    //getU    offs := 3;
    BKDecodeVal4ByteFromCmd(resu, 3, v);
    VV := v;  //in mV
    LastU := VV / 1000; //in V
    //getI   offs:=7;
    BKDecodeVal4ByteFromCmd(resu, 7, v);
    VV := v;  //in 0.1mA
    LastI := VV / 10000; //in A
    //getP  offs:=11;
    BKDecodeVal4ByteFromCmd(resu, 11, v);
    VV := v;  //in 1mW
    LastP := VV / 1000; //in W
  end else begin
    LastU:=NaN;
    LastI:=NaN;
    LastP:=NaN;
    //LastValid := false;
  end;
  //status registers
  reg1 :=  resu.data[15];
  reg2 :=  resu.data[16] + resu.data[17] * 256;
  BKStatus.Lastreg1 := reg1;
  BKStatus.Lastreg2 := reg2;
  //???????????!!!!!!!!!!!!!!!!!!!! TODO
      { status bytes (from 0x5F):
       ---------------
        Bit Meaning
      0 Calculate the new demarcation coefficient
      1 Waiting for a trigger signal
      2 Remote control state (1 means enabled)
      3 Output state (1 means ON)
      4 Local key state (0 means not enabled, 1 means enabled)
      5 Remote sensing mode (1 means enabled)
      6 LOAD ON timer is enabled
      7 Reserved
      The demand state register's bit meanings are:
      Bit Meaning
      0 Reversed voltage is at instrument's terminals (1 means yes)
      1 Over voltage (1 means yes)
      2 Over current (1 means yes)
      3 Over power (1 means yes)
      4 Over temperature (1 means yes)
      5 Not connect remote terminal
      6 Constant current
      7 Constant voltage
      8 Constant power
      9 Constant resistance }
    //
  with BKStatus do
     begin
     //U,I,P
       U := LastU;
       I := LastI;
       P := LastP;
     //status reg 1
       Calculating := BitIsSet(reg1, 0);
       WaitingForTrigger := BitIsSet(reg1, 1);
       RemoteIsOn := BitIsSet(reg1, 2);
       OutputOn := BitIsSet(reg1, 3);
       LocalKeyOn := BitIsSet(reg1, 4);
       RemSensingIsON :=  BitIsSet(reg1, 5);
       TimerisON := BitIsSet(reg1, 6);
      //status reg 2
      ReversedVoltage := BitIsSet(reg2, 0);
      OverV := BitIsSet(reg2, 1);
      OverC := BitIsSet(reg2, 2);
      OVerP := BitIsSet(reg2, 3);
      OverTemp := BitIsSet(reg2, 4);
      NotRemoteConnect := BitIsSet(reg2, 5);
      IsCC := BitIsSet(reg2, 6);
      IsCV := BitIsSet(reg2, 7);
      IsCP := BitIsSet(reg2, 8);
      IsCR := BitIsSet(reg2, 9);
     end;
  //debug
  //Writeln(ft, '  '+FloatToStr(BKLastU) + ' V ' + FloatToStr(BKLastI) + ' A ' + FloatToStr(BKLastP) + ' W ');
  //Writeln(ft, '');
  //close(ft);
  //
  //LastValid := true;
  LastCmdOK := BKlastOK;
end;


procedure TBK8500Potentio.BKSetConstC(setp: double);
{curr: current in A}
Var
    i: integer;
    offs: byte;
    cmd, res: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
    v: longint;
    reg1: byte;
    reg2: word;
    errcntsent, errcntrecv: integer;
begin
  BKLastOK := true;
  errcntsent := 0;
  errcntrecv := 0;
  //check that remote is on
  if not BKstatus.RemoteIsOn then
  begin
    BKsetRemote;
    //TODO:
  end;

  //set CC setpoint
  {
3 Lower low byte of current. 1 represents 0.1 mA.
4 Lower high byte of current.
5 Upper low byte of current.
6 Upper high byte of current.}

  v := trunc( abs( setp ) * 10000);
  BKPrepareEmptyCmd( cmd );
  with cmd do
    begin
    data[2] := $2A;
    offs := 3;
    BKNumberTo4Bytes( v, data[offs], data[offs+1], data[offs+2], data[offs+3] );
    end;
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  //tmp debug - write cmd to file
  if fDebug then
  begin
    Append(BKdebugfile);
    Writeln(BKdebugfile, DateTimeToStr(Now) + ' (set CC setp : '+ IntToStr(v) + '):' );
    Writeln(BKdebugfile, BKCmdtostring(cmd) );
    Writeln(BKdebugfile, BKCmdtostring(res) );
    Writeln(BKdebugfile, '');
    Close(BKdebugfile);
  end;
  //part 2: set CC mode
  BKPrepareEmptyCmd( cmd );
  cmd.data[2] := $28;
  cmd.data[3] := 0;  //CC mode
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  //tmp debug - write cmd to file
  if fDebug then
  begin
    Append(BKdebugfile);
    Writeln(BKdebugfile, DateTimeToStr(Now) + ' (set CC' );
    Writeln(BKdebugfile, BKCmdtostring(cmd) );
    Writeln(BKdebugfile, BKCmdtostring(res) );
    Writeln(BKdebugfile, '');
    Close(BKdebugfile);
  end;
  if (errcntsent>0) or (errcntrecv>0) then BKLastOK := false;
  LastCmdOK := BKLastOK;
end;


procedure TBK8500Potentio.BKSetConstV(setp: double);
{setp: voltage in V}
Var
    i: integer;
    cmd, res: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
    v: longint;
    offs: byte;
    errcntsent, errcntrecv: integer;
begin
  BKLastOK := true;
  errcntsent := 0;
  errcntrecv := 0;
  //check that remote is on
  if not BKstatus.RemoteIsOn then
  begin
    BKsetRemote;
    //TODO:
  end;
  //step 1: set CV setpoint
  {
  3 Lower low byte of voltage. 1 represents 1 mV.
  4 Lower high byte of voltage.
  5 Upper low byte of voltage.
  6 Upper high byte of voltage.
  }
  v := trunc( abs( setp ) * 1000);
  BKPrepareEmptyCmd( cmd );
  with cmd do
    begin
    data[2] := $2C;
    offs := 3;
    BKNumberTo4Bytes( v, data[offs], data[offs+1], data[offs+2], data[offs+3] );
    end;
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  //tmp debug - write cmd to file
  if fDebug then
  begin
    Append(BKdebugfile);
    Writeln(BKdebugfile, DateTimeToStr(Now) + ' (set CV setp : '+ IntToStr(v) + '):' );
    Writeln(BKdebugfile, BKCmdtostring(cmd) );
    Writeln(BKdebugfile, BKCmdtostring(res) );
    Writeln(BKdebugfile, '');
    Close(BKdebugfile);
  end;
  //step 2: set CV mode
  BKPrepareEmptyCmd( cmd );
  cmd.data[2] := $28;
  cmd.data[3] := 1;  //CV mode
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  //tmp debug - write cmd to file
  if fDebug then
  begin
    Append(BKdebugfile);
    Writeln(BKdebugfile, DateTimeToStr(Now) + ' (set CV)' );
    Writeln(BKdebugfile, BKCmdtostring(cmd) );
    Writeln(BKdebugfile, BKCmdtostring(res) );
    Writeln(BKdebugfile, '');
    Close(BKdebugfile);
  end;
  if (errcntsent>0) or (errcntrecv>0) then BKLastOK := false;
  LastCmdOK := BKLastOK;
end;


{procedure TBK8500Potentio.SetConstV(setp: double);
//setp: voltage in V
Var
    i: integer;
    cmd, res: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
    v: longint;
    offs: byte;
    reg1: byte;
    reg2: word;
    errcntsent, errcntrecv: integer;
begin
  BKLastOK := true;
  errcntsent := 0;
  errcntrecv := 0;
  //step 1: set CV setpoint
  //
  //3 Lower low byte of voltage. 1 represents 1 mV.
  //4 Lower high byte of voltage.
  //5 Upper low byte of voltage.
  //6 Upper high byte of voltage.
  //
  v := trunc( abs( setp ) * 1000);
  BKPrepareEmptyCmd( cmd );
  with cmd do
    begin
    data[2] := $2C;
    offs := 3;
    BKNumberTo4Bytes( v, data[offs], data[offs+1], data[offs+2], data[offs+3] );
    end;
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  //tmp debug - write cmd to file
  if fDebug then
  begin
    Append(BKdebugfile);
    Writeln(BKdebugfile, DateTimeToStr(Now) + ' (set CV setp : '+ IntToStr(v) + '):' );
    Writeln(BKdebugfile, BKCmdtostring(cmd) );
    Writeln(BKdebugfile, BKCmdtostring(res) );
    Writeln(BKdebugfile, '');
    Close(BKdebugfile);
  end;
  //step 2: set CV mode
  BKPrepareEmptyCmd( cmd );
  cmd.data[2] := $28;
  cmd.data[3] := 1;  //CV mode
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  //tmp debug - write cmd to file
  if fDebug then
  begin
    Append(BKdebugfile);
    Writeln(BKdebugfile, DateTimeToStr(Now) + ' (set CV)' );
    Writeln(BKdebugfile, BKCmdtostring(cmd) );
    Writeln(BKdebugfile, BKCmdtostring(res) );
    Writeln(BKdebugfile, '');
    Close(BKdebugfile);
  end;
  if (errcntsent>0) or (errcntrecv>0) then BKLastOK := false;
  LastCmdOK := BKLastOK;
end;
}

procedure TBK8500Potentio.BKTurnONOFF( enabled: boolean);
{enabled: 1 = laod ON 0 = load OFF}
Var
    cmd, res: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
    v: longint;
    reg1: byte;
    reg2: word;
begin
  //check that remote is on
  if not BKstatus.RemoteIsOn then
  begin
    BKsetRemote;
    //TODO:
  end;
  BKLastOK := true;
  BKPrepareEmptyCmd( cmd );
  cmd.data[2] := $21;
  if enabled then cmd.data[3] := 1  //1 is ON
         else cmd.data[3] := 0;  //OFF
  BKFinishCmd( cmd );
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if (not B) or (not b2)then BKLastOK := false;
  LastCmdOK := BKLastOK;
end;



//procedure BKReadStatus();
{ 0x5E Get function type (FIXED/SHORT/TRAN/LIST/BATTERY)
0x5F Read input voltage, current, power and relative state
Byte
0x29 Read the mode being used (CC, CV, CW, or CR)
}
{ 0x5E Get function type (FIXED/SHORT/TRAN/LIST/BATTERY)
0x5F Read input voltage, current, power and relative state
Byte
0x29 Read the mode being used (CC, CV, CW, or CR)
}
//begin
//end;




procedure TBK8500Potentio.BKSetIniParams();
{sends configuration commands to default state
  ...that is:    ...
0x22 Set the maximum voltage allowed
0x24 Set the maximum current allowed
0x26 Set the maximum power allowed
  Set CC mode current  ... to zero
0x28 Set CC, CV, CW, or CR mode  ... CC mode
0x32 Set CC mode transient current and timing  ??? disable transient
0x52 Disable/enable timer for LOAD ON
0x56 Enable/disable remote sensing   ... disable
 ...
0x5D Select FIXED/SHORT/TRAN/LIST/BATTERY function !!!!!!!  set to FIXED
}
Var
    i: integer;
    cmd, res: Tbk8500message;
    b, b2: boolean;
    rcode: integer;
    v: longint;
    offs: byte;
    reg1: byte;
    reg2: word;
    errcntsent, errcntrecv, errcnt3: integer;
begin
  BKLastOK := True;
  errcntsent := 0;
  errcntrecv := 0;
  errcnt3 := 0;
  //0a set remote mode
  BKSetRemote();
  if not BKLastOK then Inc(errcnt3);
  //
  //0b set load OFF
  BKTurnONOFF( false );
  if not BKLastOK then Inc(errcnt3);
  //
  //1) set fixed mode    $5D
  BKPrepareEmptyCmd(cmd); //sets first byte, address to 0, and emty all other bytes
  cmd.data[2] := $5D;
  cmd.data[3] := 0;
  BKFinishCmd(cmd);
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if not b then Inc(errcntsent);
  if not b2 then Inc(errcntrecv);
  //
  //2) set max current to 10A
  //
  BKPrepareEmptyCmd(cmd);
  cmd.data[2] := $24;
  v := 100000;
  with cmd do
     begin
     offs := 3;
     BKNumberTo4Bytes( v, data[offs], data[offs+1], data[offs+2], data[offs+3] );
     end;
  BKFinishCmd(cmd);
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if not b then Inc(errcntsent);
  if not b2 then Inc(errcntrecv);
  //
  //3) set max voltage to 15V
  //
  BKPrepareEmptyCmd(cmd);
  cmd.data[2] := $22;
  v := 15000;
  with cmd do
     begin
     offs := 3;
     BKNumberTo4Bytes( v, data[offs], data[offs+1], data[offs+2], data[offs+3] );
     end;
  BKFinishCmd(cmd);
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if not b then Inc(errcntsent);
  if not b2 then Inc(errcntrecv);
  //
  //4) disable timer
  //
  BKPrepareEmptyCmd(cmd);
  cmd.data[2] := $52;
  cmd.data[3] := 0;
  BKFinishCmd(cmd);
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if not b then Inc(errcntsent);
  if not b2 then Inc(errcntrecv);
  //
  //5) ENABLE remote sensing
  //
  BKPrepareEmptyCmd(cmd);
  cmd.data[2] := $56;
  cmd.data[3] := 1;    //TODO:!!!!!!!!!!!!!!!!!!
  BKFinishCmd(cmd);
  b := BKsendcmd(cmd);
  b2 := BKgetResult( res, rcode);
  if not b then Inc(errcntsent);
  if not b2 then Inc(errcntrecv);
  //
  //6) set CC and current to zero
  //
  BKSetConstC(0);
  if not BKLastOK then Inc(errcnt3);
  if (errcntsent>0) or (errcntrecv>0) or (errcnt3>0) then BKLastOK := false;
  LastCmdOK := BKLastOK;
end;


procedure TBK8500Potentio.BKGetExtendedState();
{sends configuration commands to default state
...that is:    ...
0x5E Get function type (FIXED/SHORT/TRAN/LIST/BATTERY)
0x5F Read input voltage, current, power and relative state
0x6A Get product's model, serial number, and firmware version
0x59 Read trigger source
0x57 Read the state of remote sensing
0x53 Read timer state for LOAD ON
//0x4F Read minimum voltage in battery testing
//0x35 Read CV mode transient parameters
//0x33 Read CC mode transient parameters
0x2D Read CV mode voltage
0x2B Read CC mode current
0x29 Read the mode being used (CC, CV, CW, or CR)
0x25 Read the maximum current allowed
0x23 Read the maximum voltage allowed
}
begin

end;


//---------------------------------------



function BKGeneralModetoInternal(fb:TPotentioMode): TBKMode;
begin
  case fb of
   CPotCC: Result := CBKCC;
   CPotCV: Result := CBKCV;
   CPotCP: Result := CBKCP;
   CPotCR: Result := CBKCR;
  else Result := CBKCC;
  end;
end;


function BKInternalModetoGeneral(mode:TBKMode): TPotentioMode;
begin
  case mode of
     CBKCC  : Result := CPotCC;
     CBKCV  : Result := CPotCV;
     CBKCP  : Result := CPotCP;
     CBKCR  : Result := CPotCR;
     else  Result := CPotERR;
  end;
end;






//-------low level helper function ------

function BKcalcchecksum(Var r: Tbk8500message): byte;
Var i: integer;
    s: longint;
begin
  s:=0;
  for i:=0 to 24 do s:= s + r.data[i];
  s := s mod 256;
  Result := s;
end;


function BKcheckcommand(Var r: Tbk8500message): boolean;
Var
   chksum: byte;
begin
  chksum := BKcalcchecksum( r);
  Result := False;
  if (chksum = r.data[25]) and (r.data[0]=$AA) then Result := True;
end;


procedure BKPrepareEmptyCmd(Var cmd: Tbk8500message; addr:byte=0);
  {  sets first byte, address to 0, and emty all other bytes}
Var i:integer;
begin
  with cmd do
    begin
         data[0] := $AA;
         data[1] := addr;
         for i:=2 to 25 do data[i] := 0;
         len := 26;
    end;
end;


procedure BKFinishCmd(Var cmd: Tbk8500message);
{fills in checksum}
begin
  cmd.data[25]:= BKcalcchecksum( cmd );
end;


function BKCmdtostring( Var cmd: Tbk8500message ): string;
Var
    c: byte;
    i, ll: longint;
    s, s1: string;
begin
  s := '';
  ll := cmd.len;
  if ll>26 then ll := 26;
  for i:=0 to ll-1 do
  begin
    c := cmd.data[i];
    s1 := IntToHex( c, 2 );
    if c = 0 then s1 := '..';
    s := s + s1 + ' ';
  end;
  Result := s;
end;


procedure BKNumberTo4Bytes( n: longint; Var a, b, c, d: byte );
{a is lowest byte}
begin
  a := n mod 256;
  b := (n shr 8) mod 256;
  c := (n shr 16) mod 256;
  d := (n shr 24) mod 256;
end;


procedure BK4BytesToNumber(a, b, c, d: byte; Var n: longint);
{a is lowest byte}
begin
  n := d;
  n := n*256 + c;
  n := n*256 + b;
  n := n*256 + a;
end;


procedure BKDecodeVal4ByteFromCmd( Var cmd: Tbk8500message; offs: byte; Var n: longint);
begin
  n := 0;
  if (offs>cmd.len - 4) then
  begin
    offs := 0;
    BKReportError(0, 'BKDecodeVal4ByteFromCmd / offs>cmd.len - 4');
    exit;
  end;
  BK4BytesToNumber(cmd.data[offs], cmd.data[offs+1], cmd.data[offs+2], cmd.data[offs+3], n);
end;



end.

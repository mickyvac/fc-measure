unit PTCInterface_KolPTC_DynamicDLL;

{note 19.7.2015 - changes in interdace - ptc.dll
v podstate jsem zrušil funkci Setup, sice funguje, ale jen docasne
Ptc_Setup(Feedback:integer; OutputRelayOn:boolean):boolean;

Na rízení jsou ted navrženy tyto funkce:

Function Ptc_Range(Range:integer):boolean; stdcall;
Function Ptc_Feedback(Feedback:integer):boolean; stdcall;
Function Ptc_Setpoint(Setpoint:double):boolean; stdcall;
Function Ptc_OutputEnabled(enabled:boolean):boolean; stdcall;

Range: 0=snímací odpor 10mOhm, 15A, 1=odpor 1 Ohm, cca do 100mA
Feedback: softwarový feedback, od nuly postupne V2, V4, VRef, I, Ix10
Setpoint: pro sw feedback
OutputEnabled: pripopojí nebo odpojí výstup (ovládá relé)
}

//comment the define, if you do not have the libraries and want to compile without KolPTC!!!!!
{$DEFINE PTCDLL}


{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs,
  myutils, Logger, ConfigManager, FormGlobalConfig,
  HWAbstractDevicesNew,
  Ptc_defines;

{create descendant of virtual abstract potentio object and define its methods
especially including definition of configuration and setup methods}

Const
  CKolPtcIfaceVer = 'KolPTC Interface 2015-12-31';
  CKolPtcIfaceVerLong = CKolPtcIfaceVer + '(by Michal Vaclavu)';

  CConfigSection = 'KolPTCInterface';

  CDebug = false; //true; //false; //true;

  CMaxBufferSize = 256;
  CMaxArrayofDoubleSize = 16;

Type

  TStaticArrayOfDouble = array[0..CMaxArrayofDoubleSize-1] of double;

  TKolPTCFeedback = (CPTCFbV2, CPTCFbV4, CPTCFbVref, CPTCFbI, CPTCFbIx10);
  TKolPTCRange = (CPTCRng500mA, CPTCRng15A );


  TKolPTCRegisters = ( CRegUndef, CRegADC, CRegV4Range, CRegRelayON, CRegSetpoint, CRegSwFeedback,
                      CRegProtectStatus, CRegLimSafe, CRegLimHard, CRegMonI, CRegCRC);
  TKolPTCChannels = ( CChV4, CChVref, CChV2, CChI, CChI10, CChSP );

  TKolPTCRegisterConfig = array [TKolPTCRegisters] of byte;
  TKolPTCChannelConfig = array [TKolPTCChannels] of byte;

  TKolBuffer = array of byte;
  TArrayOfDouble = array of double;

  TKolPTCChannelData = record
     Ain: array of double;
     Aout: array of double;
     nAin: byte;
     nAout: byte;
  end;

  TKolPTCStatus = record
     OutputOn: boolean;
     FuseActive: boolean;
     Setpoint: double;
     Feedback: integer; //internal representation of TKolPTCFeedback - use conversion func
     Range: integer; //internal representation of TKolPTCRange  - use conversion func
     FuseNew: byte;
     FuseHard: boolean;
     FuseSoft: boolean;
  end;

  TKolPTCExtendedStatus = record
     RegADC: TStaticArrayOfDouble;
     RegADC_n: byte;
     RegRelayOn: byte;
     RegSetpoint: double;
     RegSwFeedback: byte;
     RegProtectStat: byte;
     RegFuse_safe: TStaticArrayOfDouble;
     RegFuse_safe_n: byte;
     RegFuse_hard: TStaticArrayOfDouble;
     RegFuse_hard_n: byte;
     RegMonI: TStaticArrayOfDouble;
     RegMonI_n: byte;
     CRCstr: string;
     V4range: TPotentioRangeRecord;
  end;



  TKolPTCObject = class (TPotentiostatObject)
    //WATCH OUT: if HW or SW fuse was triggered - user will need to correct the cause and call "Reset Fuse",
    //           fuse is signalled in the flag set
    public
      constructor Create;
      destructor Destroy; override;
    public
    //inherited virtual functions - must override!
      function AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean; override;
    //  returns electrical DATA and status
    //  this is the only fucntion that actualy aquires the status info (every time it is called)
    //  and after each call the internal status is updated and with it, also the corresponding flags if relevant!
    //  !!! range of voltage and current is checked (and flags set),
    //               but NO ACTION IS TAKEN to prevent overrange -> This should be done by HIGHER LEVEL control fucntion!!!!
      function AquireStatus(Var Status: TPotentioStatus): boolean; override;  //quickly retrieves only status
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
    //fAvailable: boolean;
    //fReady: boolean;
    //fRngActCurr: TPotentioRangeRecord;
    //fRngActVolt: TPotentioRangeRecord;
    //fRngActCurrId: byte;
    //fRngActVoltId: byte;
    //fRngCurrCount: byte;
    //fRngVoltCount: byte;
    public
      //HW specific features control methods
      function Connect(): boolean;  //Call to this to load DLL and assign control functions ... necessary to became availalble
      procedure ExitDll;      
      function ResetFuses(): boolean;
      function SetFeedback( fb: TKolPTCFeedback ): boolean;
      function SetRange( r: TKolPTCRange ): boolean;
      function SetSetpoint( sp: double ): boolean;
      function SetOutputRelay( enabled: boolean): boolean;
      function SetSafetyRangeV4(lowlim, highlim: double): boolean;
       //advanced HW specific status aquiring methods
       //all methods return true/false telling about result, data are passed by reference
      function ReadChannels(Var chdata: TKolPTCChannelData): boolean;
      function ReadStatus(Var st: TKolPTCStatus): boolean;  //status inlcuding fuse status
      function ReadPTCStatusExtended(Var extst: TKolPTCEXtendedStatus): boolean;  //read maximum info status from PTC registers, including V4range
      function ReadFuseState(Var fuse: boolean): boolean; //partially obsolete
      function ReadV4range(Var rrec: TPotentioRangeRecord): boolean;   //partially obsolete
      //general register access
      function ReadRegister(regnr: word; Var buf: TKolBuffer; Var retlen: word): boolean;
      //size is dynamic, adjustable, expect common size (max CBufMaxsize )
      function WriteRegister(regnr: word; Var bytes: ansistring  ): boolean;  //size is dynamic
      function ReadRegADC(Var ad: TArrayOfDouble): boolean;
      function ReadRegRelayOn(Var val: byte): boolean;
      function ReadRegSetpoint(Var val: double): boolean;
      function ReadRegSwFeedback(Var val: byte): boolean;
      function ReadRegProtectStatus(Var val: byte): boolean;
      function ReadRegFwFuseHard(Var ad: TArrayOfDouble): boolean;
      function ReadRegFwFuseSoft(Var ad: TArrayOfDouble): boolean;
      function ReadRegMonI(Var ad: TArrayOfDouble): boolean;
      function ReadRegCRC(Var crc: string): boolean;
    public
      function GetHWIdstr: string;  //returns dll/firmware version
    private
      //internal access lock control  and helper functions to check state before sending command
      kolPtcLock: boolean;  //for future - prevents multiple simultaneous call to PTC library
      function CheckConnectedLeaveMsg( where: string ): boolean;
      function LockAndCheckConnectedLeaveMsg( where: string ): boolean;
      function TryToLockIfNotLeaveMsg( where: string ): boolean;
      procedure Unlock;
    private
      //internal configuration, stored into ini file
      fConfClient: TConfigCLient;
      fConfManagerId: longint;
      fFormatSettings:  TFormatSettings;   //internal default format used
      fRegConfig: TKolPTCRegisterConfig;
      fDefRegConfig: TKolPTCRegisterConfig;
      fRegVersionID: string;  //to verify that the firmaware has same version as the internal config is meant to be used with
      fChannelConfig: TKolPTCChannelConfig;
      //fAutoSwitchRng: boolean;
      fRetryCount: byte;
      fBufferedRead: boolean;
      fConstUFeedback: TKolPTCFeedback; //in internal KolPTC representation - when switch to Ufeedback, use this one
      fConstIFeedback: TKolPTCFeedback; //in internal KolPTC representation - when switch to Ifeedback, use this one
      fV4SafetyRange: TPotentioRangeRecord;
      fRegWriteEnabled: boolean;  //do not write into registers, until the firmware version has been checked!!!!
      //config load save methods
    private
      //configuration and initialization
      fConfigured: boolean;  //because of different versions of HW - first register numbers should be initialized and this flag marked
      fDllLoaded: boolean;
      fDllFuncAssigned: boolean;
    private
      //kolPTC info object
      fPtcInfo: TPtcInfo;
    public
      //configuration and initialization
      procedure LoadConfig;
      procedure SaveConfig;      
      procedure InitRegConfigWithDef(Var RegConf: TKolPTCRegisterConfig );
      //procedure AssignConfigManager( Var cm: TLoadSaveConfigManager );  //use this to partially automate storing/loading of configuration from PTC control form
      function LoadDll: boolean;
      procedure UnLoadDll;
      function AssignDllFunctions: boolean;
      //
      procedure SetupRegConfig( r: TKolPTCRegisters; val: byte );
      procedure SetupChannelConfig( ch: TKolPTCChannels; val: byte );
      procedure MarkAsConfigured; //signal that configuration was done (maybe still check integrity) to mark configured flag
    public
      //conversion functions
      function InternalFBToKol(i: integer ): TKolPTCFeedback;
      function InternalRngToKol(i: integer ): TKolPTCRange;
    private
      //low level communication
      function Ptc_SendCmdarray( Var ab: array of byte; alen: byte ): boolean;
      function Ptc_SendCmdWrapper( s: string ): boolean;
    private
      // internal more extended use
      function SetCCx( val: double; forceturnon: boolean = false; forcechangefb: boolean = false): boolean;
      function SetCVx( val: double; forceturnon: boolean = false; forcechangefb: boolean = false): boolean;
      //helper conversion fucntions
      function FBtoInternal(fb:TKolPTCFeedback): integer;
      function RangeToInternal(r: TKolPTCRange): integer;
      function FBtoMode(fb:TKolPTCFeedback): TPotentioMode;
      function KolRngToRngRec( kr: TKolPTCRange): TPotentioRangeRecord;
      //
      procedure kolMsg(s: string); //set lastmsg and log it at the same time
      procedure kolErrorMsg(s: string); //set lastmsg and log it at the same time
      function kolAssert(ex: boolean; s: string): boolean; //if ex is FALSE leaves warning message; returns true if Assert OK
      //
      //rubbish TODO
      function GetDataBuffered(Var Rec: TPotentioRec; Var Status: TPotentioStatus): boolean;
      procedure WaitForSetpointCurr;
      function DecreaseCurrent(): boolean;
      //
    private
      fFlagSet: TPotentioFlagSet;
      //more stuff
      fPTCdebug: boolean;  //DEBUG!!!!!!!!!!! for more info messages
      flastOCV: double;
      //last known data and parametrs from PTC
      fLastPTCdata: TPotentioRec;
      fLastPTCStatus: TPotentioStatus;
      fLastKolPtcStatus: TKolPTCStatus;
      //fLastKolPtcExtStatus: TKolPTCExtendedStatus;
      //fLastChannelData: TKolPTCChannelData;
      //error counters
      fCommCntTotal: longint;
      fCommErrCorrectedCnt: longint;
      fCommErrNotCorrCnt: longint;
      //
      procedure WriteRetryCount( c: byte );   //make sure c is at least 1
    public
      //exported properties
      property IsConfigured: boolean read fConfigured;
      property IsDLLloaded: boolean read fDllFuncAssigned;
      property ConfigRegisters: TKolPTCRegisterConfig read fRegConfig;
      property ConfigChannels: TKolPTCChannelConfig read fChannelConfig;
      property BufferedRead: boolean read fBufferedRead write fBufferedRead;
      property LastOCV: double read FLastOCV;
      property DebugEnabled: boolean read fPTCdebug write  fPTCdebug;
      property Flags: TPotentioFlagSet read fFlagSet;
      //
      property CommCntTotal: longint read fCommCntTotal;
      property CommCntErrCorrected: longint read fCommErrCorrectedCnt;
      property CommCntErrNotCorr: longint read fCommErrNotCorrCnt;
      //
      property ConstUFeedback: TKolPTCFeedback read fConstUFeedback write fConstUFeedback;
      property ConstIFeedback: TKolPTCFeedback read fConstIFeedback write fConstIFeedback;
      property RetryCount : byte read fRetryCount write WriteRetryCount;
      property FWVersionCRC: string read fRegVersionID write fRegVersionID;
      //property AutoSwitchRng: boolean read fAutoSwitchRng write fAutoSwitchRng;
  end; //*************************



Type

TVarType = (CVarInt, CVarFloat, CVarBool, CVarString, CVarArray, CVarPointer);

TArgRecord = record
               pa: Pointer;
               atype: TVarType;
             end;

TArgArray = array of TArgRecord;

TBoolFunc = function(): boolean;
PBoolFunc = ^TBoolFunc;


function RetryCallUntilOK( Pfn: PBoolFunc; argc: byte; ArgArray: TArgArray; retryc: byte): boolean;
//pfn: pointer to function that returns boolean (interface functions inptc.dll)
//tries to repeat call until geting true as result- in order to overcome communication errors and so


function KolFBToStr( fb:TKolPTCFeedback ): string;
function KolRangetoStr(r: TKolPTCRange): string;

function kolbuftostr(Var buf: TKolBuffer ): string;


function processKol1Byte( Var kbuf: TKolBuffer; Var klen: word; Var res: byte): boolean;
function processKolArrayOfDouble( Var kbuf: TKolBuffer; Var klen: word; Var ad: TArrayOfDouble): boolean;


procedure CopyDynArrayToStatic( Var adyn: TArrayOfDouble; Var astat: TStaticArrayOfDouble; Var statlen: byte);

Implementation

uses Math, DateUtils, Windows;



const
    PTC_DLL_Name = 'Ptc.dll';


//usage of external functions in PTC.DLL
{
 SAFE is to call anytime only "ptc_isconnected"!!!
 until at least 10.10.2015: if not connecetd, calling other function causes undefined state and errors (memory leaks and so on)
}

//Ptc_Exit; //call Ptc_exit onyl when cloasing app - bacause it will kill
            //dll background app, and only way to get it back is restart application (reload dll)
            //so for that there is new method exitDll


//********************
//kolPTC ptc.dll interface - prepared for dynamic loading
//before using, program must make sure, that all functions are assigned ....!!!!!!
//********************


Var

dllHandle : cardinal;

Ptc_Exit:                Procedure; stdcall;
Ptc_IsConnected:         Function(): boolean; stdcall;
Ptc_GetInfo:             Function(info:PPtcInfo): boolean; stdcall;
Ptc_GetAinAout:          Function(AinBuffer:PDouble; AoutBuffer:PDouble): boolean; stdcall;
Ptc_GetAinAout_Buffered: Function(AinBuffer:PDouble; AoutBuffer:PDouble): boolean; stdcall;
Ptc_SetAout:             Function(index:integer; count:integer; AoutBuffer:PDouble): boolean; stdcall;
Ptc_Range:               Function(Range:integer): boolean; stdcall;
Ptc_Feedback:            Function(Feedback:integer): boolean; stdcall;
Ptc_Setpoint:            Function(Setpoint:double): boolean; stdcall;
Ptc_OutputEnabled:       Function(enabled:boolean): boolean; stdcall;
Ptc_ResetFuse:           Function(): boolean; stdcall;
Ptc_ReadFuse:            Function(fuse:PBoolean): boolean; stdcall;
Ptc_ReadStatus:          Function(Setpoint:PDouble; Range:PInteger; Feedback:PInteger; OutputRelayOn:PBoolean; fuse:PBoolean): boolean; stdcall;
Ptc_SendCmd:             Function(cmdBuffer:PByte; cmdLen:integer; ansFlags:PByte; ansBuffer:PByte; ansLen:PByte): boolean; stdcall;


{
PTC setup details
  Range: 0=snímací odpor 10mOhm, 15A, 1=odpor 1 Ohm, cca do 100mA
  Feedback: softwarový feedback, od nuly postupne V2, V4, VRef, I, Ix10
}

Const
    CKolPTCRangeR10mOhm = 0;
    CKolPTCRangeR1Ohm = 1;

    CKolPTCFeedbackV2 = 0;
    CKolPTCFeedbackV4 = 1;
    CKolPTCFeedbackVRef = 2;
    CKolPTCFeedbackI = 3;
    CKolPTCFeedbackIx10 = 4;


//----------------------------

constructor TKolPTCObject.Create;
begin
  inherited;
  //basic prop ini
  fName := CKolPtcIfaceVer;
  fDummy := false;
  fReady := false;
  InitRegConfigWithDef( fRegConfig );
  //special proeprties ini
  fRegVersionID := 'NULL';
  fRegWriteEnabled := false;
  fConfigured := false;
  dllHandle := 0;
  fDllLoaded := false;
  fDllFuncAssigned := false;
  //fnumeric ormat
  GetLocaleFormatSettings(0, fFormatSettings);
  fFormatSettings.DecimalSeparator := '.';
  //default configuratio
  fRetryCount := 2;
  fConstUFeedback := CPTCFbV4;
  fConstIFeedback := CPTCFbI;
  // init config object
  fConfClient := TConfigClient.Create( GlobalConfig.ConfigServerHW, CConfigSection);
  //init dynamic arrays
  
end;


destructor TKolPTCObject.Destroy;
begin
  fConfClient.Destroy;
  inherited;
end;


//--------------------------------------------


function TKolPTCObject.IsAvailable: boolean;
begin
  Result := false;
  if (not fDllLoaded) or (not fDllFuncAssigned) or (not fConfigured) then
  begin
    fFlagSet := fFlagSet + [CPtcNotConfigured];        //set operations
    exit;
  end;
  try
    Result := Ptc_IsConnected;
  except
    on E: Exception do
      begin
        Result := false;
        kolErrorMsg( 'TKolPTCObject.IsAvailable: Got exception on Ptc_IsConnected: ' + E.Message);
      end;
  end;
end;


function TKolPTCObject.Connect(): boolean;
//For KolPTC I need first to have DLL LOADED - since it is dynamic, this will do it - it is neccessary to even check if it is available
Const
  CThisProcName = 'TKolPTCObject.Connect: ';
begin
{$R-}
  Result := false;
  //load dll
  LoadDll;
  if not AssignDllFunctions then exit;
  logmsg(' ' + CThisProcName + ' LoadDLL&Assign proc: success!');
  Result := False;
end;

function TKolPTCObject.Initialize: boolean;
{19.7.2015: Zahájení muže vypadat tak, že nastavíš range, feedback a setpoint a pak povolíš výstup a on najede sám.
Feedback lze na chodu zmenit, setpoint se tam automaticky zmení taky tak, aby se "nic nestalo".
}
Const
  CThisProcName = 'TKolPTCObject.Initialize: ';
  toutsecs = 1;
  waitdelay = false;
Var
  timeout: TDateTime;
  kolextstatus: TKolPTCExtendedStatus;
  b: boolean;
  crcs, s: string;
begin
{$R-}
  Result := false;
  kolptclock := false;
  fRegWriteEnabled := false;
  fReady := false;
  fLastOCV := NAN;
  //TODO show form with countodwn
  logmsg(' ' + CThisProcName + ' Start');
  //if necessary try to connect dll
  if not fDllFuncAssigned then Connect;
  //
  timeout := Now() + toutsecs/3600/24;
  while waitdelay and (not IsAvailable() ) do
  begin
    delayms(100);
    if Now()>timeout then break;
  end;

  if not IsAvailable() then
  begin
    //at the beggining during init it takes time to load dll window -
    //do not report error if initflag
    if GlobalConfig<>nil then if GlobalConfig.initflag then exit;
    kolerrormsg(CThisProcName + 'KolPTC not available, exiting');
    exit;
  end;
  //GET PTC_INFO - neccessary for aquiring data and contains info
  if not Ptc_GetInfo( @fPtcInfo ) then
    begin
      kolerrormsg(CThisProcName + 'PtcInfo: failed, cannot continue, exiting!');
      exit;
    end;
  //
  //force initial state

  //  PTC is not yet declared ready - use only direct internal commands
  b:= false;
  kolmsg( '>> crc read');
  b := ReadRegCRC( crcs );
   kolmsg( '  crc done ' + boolToStr(b));
  if crcs<>fRegVersionID then
    begin
      s := 'KolPTC: Config IS valid for DIFFERENT Firmware version (CRC do not match)!!!  Will abort.';
      ShowMessage(s);
      kolerrormsg(CThisProcName + s);
      exit;
    end;
  //
  kolmsg(CThisProcName + ': CRC config check -> MATCH -> enable write to registers and continue init');
  fRegWriteEnabled := true;

  b := ReadPTCStatusExtended( kolextstatus );
  //check CRC of FW and if matches with thet of configuration set, enable write
  if not b then
    begin
      kolErrormsg(CThisProcName + 'ReadStatus FAILED!, cannot continue');
      exit;
    end;
  // if not match do not allow ready and showmessage
  if false and (kolextstatus.CRCstr <> fRegVersionID) then
    begin
      kolErrormsg(CThisProcName + 'Config setup is for DIFFERENT VERSION OF FIRMWARE -  CANNOT CONTINUE, WILL EXIT');
      ShowMessage(CThisProcName + ': HW Firmware version is different than expected - check PTC setup, cannot continue!!');
      exit;
    end;
  //allow reg writing
  fRegWriteEnabled := true;

  //update present settings
  logmsg(CThisProcName + 'TurnLoadOFF');
  SetOutputRelay( false );
  logmsg(CThisProcName + 'SetRange 15A');
  SetRange( CPTCRng15A );
  logmsg(CThisProcName + 'SetFeedback: I');
  SetFeedback( CPTCFbI );
  logmsg(CThisProcName + 'SetSetpoint 0.0');
  SetSetpoint( 0.0 );
  logmsg(CThisProcName + 'SetV4range: -0.1, 1.5');
  SetSafetyRangeV4(-0.1, 1.5);
  //done
  kolmsg('TKolPTCObject.Initialize: Connected to kolPTC!!! This is interface: ' + CKolPtcIfaceVerLong );
  kolmsg('  HW info: ' + GetHWIdstr );
  kolmsg('  KolPTC OK & ready');
  fReady := true;
  Result := true;
end;

procedure TKolPTCObject.Finalize;
begin
  kolmsg('Disconnecting PTC');
  fRegWriteEnabled := false;
  if fReady then
    if Ptc_IsConnected then
      begin
        TurnLoadOFF;
      end;
  fReady := false;
  //if fDllFuncAssigned then Ptc_Exit;  //DO NOT USE PTC EXIT
  //Ptc_Exit; //call Ptc_exit onyl when cloasing app - bacause it will kill
  //           //dll background formp, and only way to get it back is completely restart the application (reload dll)
  //
  //fDllFuncAssigned := false;
  //UnLoadDll;
end;



function TKolPTCObject.GetFlags(): TPotentioFlagSet;
begin
  Result := fFlagSet;
end;


//--------------------------------

//basic control functions
function TKolPTCObject.AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean;
//description of inputs "ain":  now stoed in configuration record
Const
  CThisProcName = 'AquireDataStatus';
Var
    chdata: TKolPTCChannelData;
    kolstat: TKolPTCStatus;
    V2raw, V4raw, Vrefraw, Iraw, SPraw: double;
    Ifin, Ufin: double;
    b1, b2, b3 : boolean;
    bfuse: boolean;
    i: integer;
    n: byte;
begin
    Result := false;
    InitPtcRecWithNAN( rec, status );
    rec.timestamp := Now();
    //no check for available necessary - it is done on the lower level
    //aquire channels
    b1 := ReadChannels( chdata );
    //aquire basic status
    b2 := ReadStatus( kolstat );
    if not (b1 and b2) then
      begin
        //aquire failed
        kolmsg( CThisProcName + 'FAILED - exiting' );
        exit;
      end;

    //CHANNELS
    //use channel configuration to get values from raw data
    //
    //Current - TODO can decide if use I or Ix10 depending on range
    n := fChannelConfig[ CChI ];
    if not kolAssert( (n+1)<=chdata.nAin, '(n+1)<=chdata.nAin') then exit;
    Iraw := chdata.ain[ n ];
    //
    //Voltage
    n := fChannelConfig[ CChV4 ];
    if not kolAssert( (n+1)<=chdata.nAin, '(n+1)<=chdata.nAin') then exit;
    V4raw := chdata.ain[ n ];
    n := fChannelConfig[ CChVref ];
    if not kolAssert( (n+1)<=chdata.nAin, '(n+1)<=chdata.nAin') then exit;
    Vrefraw := chdata.ain[ n ];
    //
    //process U, I if necessary
    Ufin := V4raw;
    Ifin := Iraw;
    with rec do
    begin
        timestamp := Now;
        U := Ufin;
        I := Ifin;
        P := Ufin * Ifin;
        Uref := Vrefraw;
    end;
    //Setpoint @ Aout
    n := fChannelConfig[ CChSP ];
    if not kolAssert( (n+1)<=chdata.nAout, '(n+1)<=chdata.nAout') then exit;
    SPraw := chdata.aout[ n ];
    //
    // keep track of last OCV
    if not kolstat.OutputOn then FlastOCV := Ufin;
    //store as last known data
    fLastPTCdata := rec;
    //
    //STATUS
    fLastKolPtcStatus := kolstat;
    Exclude(fFlagSet, CPtcFuseActivated);
    if kolstat.FuseActive then Include(fFlagSet, CPtcFuseActivated);
    //
    with Status do
      begin
       flagSet := fFlagSet;
       setpoint := kolstat.Setpoint;
       mode := FBtoMode( InternalFBToKol( kolstat.Feedback ) );
       isLoadConnected := kolstat.OutputOn;
       rangeCurrent := KolRngToRngRec( InternalRngToKol( kolstat.Range ) );
       rangeVoltage := CPTCZeroRng;
       //                                                          //set
       debuglogmsg := 'Output=' + BoolToStr(isLoadConnected) + '|Fuse=' + BoolToStr(CPtcFuseActivated in flagSet) +
                      '|Mode=' + IntToStr(Ord(mode)) + '|setp=' + FloatToStrF(setpoint, ffFixed, 4,2) +
                      '|Ain=' + ArrayToString(chdata.Ain, chdata.nAin) +
                      '|Aout=' + ArrayToString(chdata.Aout, chdata.nAout);
      end;
  //store as last known data
  fLastPTCStatus := Status;
  //TODO: check flag indicators (overrange)
  //check overrange (but only set flag, do nothing about it)
  //U
  Exclude(fFlagSet, CPtcOverRangeVoltage);
  if (Ufin < fRngActVolt.low) or (Ufin > fRngActVolt.high) then Include(fFlagSet, CPtcOverRangeVoltage);
  //I
  Exclude(fFlagSet, CPtcOverRangeCurrent);
  if (Ifin < fRngActCurr.low) or (Ifin > fRngActCurr.high) then Include(fFlagSet, CPtcOverRangeCurrent);
  //
  //finished
  Result := true;
end;



function TKolPTCObject.AquireStatus(Var Status: TPotentioStatus): boolean; //quickly retrieves only status
Const
  CThisProcName = 'AquireStatus';
Var
    kolstat: TKolPTCStatus;
    b2: boolean;
    i: integer;
    n: byte;
    rec: TPotentioRec; //dummy
begin
    Result := false;
    InitPtcRecWithNAN( rec, status );
    //no check for available necessary - it is done on the lower level
    //aquire basic status
    b2 := ReadStatus( kolstat );
    if not (b2) then
      begin
        //aquire failed
        kolmsg( CThisProcName + 'FAILED - exiting' );
        exit;
      end;
    //STATUS
    fLastKolPtcStatus := kolstat;
    Exclude(fFlagSet, CPtcFuseActivated);
    if kolstat.FuseActive then Include(fFlagSet, CPtcFuseActivated);
    //
    with Status do
      begin
       flagSet := fFlagSet;
       setpoint := kolstat.Setpoint;
       mode := FBtoMode( InternalFBToKol( kolstat.Feedback ) );
       isLoadConnected := kolstat.OutputOn;
       rangeCurrent := KolRngToRngRec( InternalRngToKol( kolstat.Range ) );
       rangeVoltage := CPTCZeroRng;
       //                                                          //set
       debuglogmsg := 'N/A';
      end;
  //store as last known data
  fLastPTCStatus := Status;
  //finished
  Result := true;
end;


function TKolPTCObject.SetCC( val: double): boolean;
begin
  Result :=  SetCCx( val);
end;


function TKolPTCObject.SetCV( val: double): boolean;
begin
  if CDebug then kolmsg('SetCV: in here');
  Result :=  SetCVx( val);
end;


procedure TKolPTCObject.WaitForSetpointCurr;
Const
  Ctimeout = 20000;
  Cepsilon = 0.05;  //5%
Var
  tstrt: TDateTime;
  done: boolean;
  rec: TPotentioRec;
  status: TPotentioStatus;
  b: boolean;
  dif, dd: double;
begin
  tstrt := now;
  done := false;
  while (MilliSecondsBetween(Now, tstrt) < ctimeout) and not done do
    begin
      b := AquireDataStatus(Rec, Status);
      dif := fLastPTCStatus.setpoint - Rec.I;
      if dif < fLastPTCStatus.setpoint * Cepsilon then
        begin
          done := true;
          break;
        end;
    end;
end;







function TKolPTCObject.TurnLOADON: boolean;
Var
  b: boolean;
begin
  Result := false;
  if CDebug then kolmsg('TKolPTCObject.TurnLOAD ON' );
  b := SetOutputRelay( true );
  if not b then kolerrormsg('Turn on: failed');
  Result := b;
end;


function TKolPTCObject.TurnLOADOFF: boolean;
Var
  b: boolean;
begin
  Result := false;
  if CDebug then logmsg('TKolPTCObject.TurnLOAD OFF' );
  b := SetOutputRelay( false );
  if not b then  kolerrormsg('Turn oFF: failed');
  Result := b;
end;



function TKolPTCObject.DecreaseCurrent: boolean;
Var
  b: boolean;
begin
  Result := false;
  if not Ptc_IsConnected then
  begin
   kolerrormsg('Decrease current: PTC not available');
   exit;
  end;
  if CDebug then logmsg('TKolPTCObject.DecreaseCurrent');
  //
  if ( (fLastPTCStatus.mode=CpoTCC)  ) then
     begin
       b := Ptc_Setpoint(0.0);
       if not b then kolerrormsg('TKolPTCObject.DecreaseCurrent SetCC: setsetpoiont failed');
     end
  else if ( (fLastPTCStatus.mode=CpoTCV) ) and ( not isnan(FlastOCV) ) then
     begin
      //TODO: !!!!!!!!!  jsut to be safe this is hard limit for FlastOCV - it should not be here in normal case
       //if FlastOCV > 1.3 then FlastOCV := 1.3;
       //if FlastOCV < 0.8 then FlastOCV := 0.8;
       //TODO: end
       b := Ptc_Setpoint(FlastOCV);
       if not b then kolerrormsg('TKolPTCObject.DecreaseCurrent SetCV: setsetpoiont failed');
     end
  else
    begin
      kolerrormsg('TKolPTCObject.DecreaseCurrent: error in last mode or no FlastOCV valid - doing nothing');
    end;
  //TODO: delay more - best until setpoint is reached
  DelayMS(1000);
  Result := true;
end;





// internal aquiring functions

function TKolPTCObject.ReadChannels(Var chdata: TKolPTCChannelData): boolean;
Const
  CThisProcName = 'ReadChannels';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  chdata.nAin := 0;
  chdata.nAout := 0;
  if not LockAndCheckConnectedLeaveMsg( CThisProcName ) then  exit;
  //prepare buffer
  SetLength(chdata.Ain, fPTCinfo.ainCount);
  SetLength(chdata.Aout, fPTCinfo.aoutCount);
  chdata.nAin :=  fPTCinfo.ainCount;
  chdata.nAout :=  fPTCinfo.aoutCount;
{$R-}
  for c:=1 to fRetryCount do
    begin
      //
      if fBufferedRead then
        begin
          b := Ptc_GetAinAout_Buffered( @(chdata.Ain[0]), @(chdata.Aout[0]) );     //read last known values form buffer
          if CDebug then logmsg(CThisProcName + ' Ptc_GetAinAout_BUFFERED' + ArrayToString(chdata.Ain, fPTCinfo.ainCount) + ' ' + ArrayToString(chdata.Aout, fPTCinfo.aoutCount) );
        end
      else
        begin
          b := Ptc_GetAinAout( @(chdata.Ain[0]), @(chdata.Aout[0]) ); //read values directly from xADDA
          if CDebug then logmsg(CThisProcName +  ' Ptc_GetAinAout ' + ArrayToString(chdata.Ain, fPTCinfo.ainCount) + ' ' + ArrayToString(chdata.Aout, fPTCinfo.aoutCount) );
        end;
      //
      Inc(fCommCntTotal);
      if b then break;
      Inc(fCommErrCorrectedCnt);
      logmsg(CThisProcName + ' ... retry failed at (' + IntToStr(c) +')' );
    end;
//{$R+}
  if not b then
    begin
      kolerrormsg(CThisProcName + ': failed even after several retries!');
      Inc(fCommErrNotCorrCnt);
    end;
  //store as last known data
  //if b then fLastChanneldata := chdata;
  Unlock;
  Result := b;
end;


function TKolPTCObject.ReadStatus(Var st: TKolPTCStatus): boolean;
Const
  CThisProcName = 'ReadStatus';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  st.FuseActive := true; //default if fail
  if not LockAndCheckConnectedLeaveMsg( CThisProcName ) then  exit;
  for c:=1 to fRetryCount do
    begin
      //
      b := Ptc_ReadStatus(@st.Setpoint, @st.Range, @st.Feedback, @st.OutputOn, @st.FuseActive);
      //
      Inc(fCommCntTotal);
      if b then break;
      Inc(fCommErrCorrectedCnt);
      logmsg(CThisProcName + ' ... retry failed at (' + IntToStr(c) +')' );
    end;
  if not b then
    begin
      kolerrormsg(CThisProcName + ': failed even after several retries!');
      Inc(fCommErrNotCorrCnt);
    end;
  Unlock;
  //store as last known data
  if b then fLastKolPtcStatus := st;
  Result := b;
end;

function TKolPTCObject.ReadPTCStatusExtended(Var extst: TKolPTCEXtendedStatus): boolean;  //read maximum info status from PTC registers
Const
  CThisProcName = 'ReadStatusExt';
Var
  b: boolean;
  ad: TArrayOfDouble;
begin
  Result := false;
  SetLength(ad, 0);
  b := true;
  b := b and ReadRegADC( ad );
  CopyDynArrayToStatic(ad, extst.RegADC, extst.RegADC_n);
  b := b and  ReadRegRelayOn( extst.RegRelayOn );
  b := b and  ReadRegSetpoint( extst. RegSetpoint);
  b := b and  ReadRegSwFeedback( extst.RegSwFeedback );
  b := b and ReadRegProtectStatus( extst.RegProtectStat );
  //
  b := b and   ReadRegFwFuseSoft( ad );
  CopyDynArrayToStatic(ad, extst.RegFuse_safe, extst.RegFuse_safe_n);
  //
  b := b and   ReadRegFwFuseHard( ad );
  CopyDynArrayToStatic(ad, extst.RegFuse_hard, extst.RegFuse_hard_n);
  //
  b := b and ReadRegMonI( ad );
  CopyDynArrayToStatic(ad, extst.RegMonI, extst.RegMonI_n);
  //
  b := b and   ReadRegCRC( extst.CRCstr );
  b := b and ReadV4range( extst.V4range );
  Result := b;
end;





function TKolPTCObject.ReadFuseState(Var fuse: boolean): boolean;
Const
  procident = 'ReadFuseState';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  fuse := false;
  for c:=1 to fRetryCount do
    begin
      b := Ptc_ReadFuse( @fuse );
      if b then break;
      Inc(fCommErrCorrectedCnt);
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed');
      Inc(fCommErrNotCorrCnt);
    end;
  if CDebug then logmsg('DII TKolPTCObject.GetFuseState res=' + BoolToStr(fuse) );
  //update flags!!!
  if fuse then fFlagSet := fFlagset + [CPtcFuseActivated] else fFlagSet := fFlagset - [CPtcFuseActivated];
  //finish
  Unlock;
  Result := b;
end;


function TKolPTCObject.ReadRegister(regnr: word; Var buf: TKolBuffer; Var retlen: word): boolean;
Const
  procident = 'ReadReagister: ';
Var
  b, br: boolean;
  c, cmdb: byte;
  len, flags: byte;
  s: string;
  rets, aout, acmd, apar ,av4reg,av4min,av4max : ansistring;
  tmpbuf: TKolBuffer;
  tmpl: word;
  i: longint;
begin
  Result := false;
  retlen := 0;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;          //!!!!!!!!!!!!!check
  //
  setlength(tmpbuf, CMaxBufferSize);
  //example for read reg 48:    11 00 30 01
  cmdb := $11;
  acmd := #$11;   //dec 17   =read register
  av4reg := chr( regnr div 256) + chr( regnr mod 256 );
  apar := #01;
  aout := acmd + av4reg + apar;
  //
  if fPTCdebug then kolmsg( procident + 'sending '+ BinStrToPrintStr( aout ) );
  for c:=1 to fRetryCount do
    begin
      // send
      b := Ptc_SendCmd(PByte(@aout[1]), length(aout), @flags, PByte(@tmpbuf[0]), @tmpl);
      //
      Inc(fCommCntTotal);
      if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if fPTCdebug then kolmsg( procident + 'result='+ BoolToStr(b) + ' len=' + IntToStr( tmpl) + ' reply=' + BinStrToPrintStr( kolbuftostr( tmpbuf ) ) );
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  br := false;
  if b then
  begin  //check answer, if result OK, return only stripped result message
    if (tmpl>=1) then   // if (buf[0] = cmdb) and (tmpl>=1) then
      begin
        retlen := tmpl;
        setlength(buf, retlen);
        for i:=0 to tmpl-1 do buf[i] := tmpbuf[i];
        br := true;
      end;
  end;
  Result := br;
  Unlock;
end;


function TKolPTCObject.WriteRegister(regnr: word; Var bytes: ansistring  ): boolean;
Const
  procident = 'WriteRegister';
Var
  b: boolean;
  c: byte;
  retlen, flags: byte;
  s: string;
  rets, aout, acmd, apar ,av4reg,av4min,av4max : ansistring;
  buf: TKolBuffer;
begin
  Result := false;
  if not fRegWriteEnabled then
    begin
      kolerrormsg(procident + ': RegWrite NOT enabled!');
      exit;
    end;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  acmd := #$15; //#21;
  av4reg := chr( regnr div 256) + chr( regnr mod 256 ) + #0#0;
  aout := acmd + av4reg + bytes;
  setlength(buf, CMaxBufferSize);
  //
  //
  for c:=1 to fRetryCount do
    begin
      // send
      b := Ptc_SendCmd(PByte(@aout[1]), length(aout), @flags, PByte(@buf[0]), @retlen);
      //
      Inc(fCommCntTotal);
      if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  Unlock;
  Result := b;
end;


function processKolArrayOfDouble( Var kbuf: TKolBuffer; Var klen: word; Var ad: TArrayOfDouble): boolean;
Var
  i, n: longint;
begin
  Result := false;
  //will reset array size at the end, to avoid unnecessary dealocation
  n := klen div 4;
  //answer is sequence of doubles
  if (klen>=1) and (klen = n * 4) then
    begin
      SetLength(ad, n);
      for i:=0 to n-1 do
        begin
          ad[i] := BinToFloatLE( kbuf, i*4);
        end;
      Result := true;
    end
  else
    begin //error
      SetLength(ad, 0);
    end;
end;

function processKol1Byte( Var kbuf: TKolBuffer; Var klen: word; Var res: byte): boolean;
Var
  i, n: longint;
begin
  Result := false;
  res := High( byte);
  //will reset array size at the end, to avoid unnecessary dealocation
  //answer is one byte
  if klen>=1 then
    begin
      res := kbuf[0];
      Result := true;
    end;
end;


function processKolHexString( Var kbuf: TKolBuffer; Var klen: word; Var res: string): boolean;
Var
  i, n: longint;
  u32: longword;
begin
  Result := false;
  res := '';
  //will reset array size at the end, to avoid unnecessary dealocation
  //answer is one byte
  if klen>=1 then
    begin
      u32 := BinToUint32LE( kbuf, 0);
      res := IntToHex(u32, 8);
      Result := true;
    end;
end;



function TKolPTCObject.ReadRegADC(Var ad: TArrayOfDouble): boolean;
Const
  procident = 'ReadRegADC ';
Var
  b: boolean;
  kbuf: TKolBuffer;
  klen: word;
  reg: byte;
begin
  Result := false;
  reg := fRegConfig[CRegADC];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      Result := processKolArrayOfDouble( kbuf, klen, ad);
    end;
  if fPTCdebug then kolmsg( procident + ' result=' +  DynArrayToStr( ad ) );
  If not Result then  kolMsg( procident + 'got result bad format');
end;


function TKolPTCObject.ReadRegRelayOn(Var val: byte): boolean;
Const
  procident = 'ReadRegRelayOn ';
Var
  b: boolean;
  reg: byte;
  kbuf: TKolBuffer;
  klen: word;
begin
  Result := false;
  val := 255;
  reg := fRegConfig[CRegRelayON];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      Result := processKol1byte( kbuf, klen, val);
    end;
  if fPTCdebug then kolmsg( procident + ' result=' +  IntToStr( val ) );
  If not Result then  kolMsg( procident + 'got result bad format');
end;



function TKolPTCObject.ReadRegSetpoint(Var val: double): boolean;
Const
  procident = 'ReadRegSetpoint ';
Var
  b, b2: boolean;
  reg: byte;
  kbuf: TKolBuffer;
  klen: word;
  ad: TArrayOfDouble;
begin
  Result := false;
  val := NAN;
  reg := fRegConfig[CRegSetpoint];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      b2 := processKolArrayOfDouble( kbuf, klen, ad);
      if b2 and (klen>=1) then
        begin
          val := kbuf[0];
          Result := true;
        end;
    end;
  if fPTCdebug then kolmsg( procident + ' result=' +  FloatToStr( val ) );
  If not Result then  kolMsg( procident + 'got result bad format');
end;


function TKolPTCObject.ReadRegSwFeedback(Var val: byte): boolean;
Const
  procident = 'ReadRegSwFeedback ';
Var
  b: boolean;
  reg: byte;
  kbuf: TKolBuffer;
  klen: word;
begin
  Result := false;
  val := 255;
  reg := fRegConfig[CRegSwFeedback];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      Result := processKol1byte( kbuf, klen, val);
    end;
  if fPTCdebug then kolmsg( procident + ' result=' +  IntToStr( val ) );
  If not Result then  kolMsg( procident + 'got result bad format');
end;


function TKolPTCObject.ReadRegProtectStatus(Var val: byte): boolean;
Const
  procident = 'ReadRegProtectStatus ';
Var
  b: boolean;
  reg: byte;
  kbuf: TKolBuffer;
  klen: word;
begin
  Result := false;
  val := 255;
  reg := fRegConfig[CRegProtectStatus];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  if b then
    begin
      Result := processKol1byte( kbuf, klen, val);
    end;
  if fPTCdebug then kolmsg( procident + ' result=' +  IntToStr( val ) );
  If not Result then  kolMsg( procident + 'got result bad format');
end;


function TKolPTCObject.ReadRegMonI(Var ad: TArrayOfDouble): boolean;
Const
  procident = 'ReadRegMonI ';
Var
  b: boolean;
  kbuf: TKolBuffer;
  klen: word;
  reg: byte;
begin
  Result := false;
  reg := fRegConfig[CRegMonI];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      Result := processKolArrayOfDouble( kbuf, klen, ad);
    end;

  if fPTCdebug then kolmsg( procident + ' result=' +  DynArrayToStr( ad ) );
  If not Result then  kolMsg( procident + 'got result bad format');
end;



function TKolPTCObject.ReadRegCRC(Var crc: string): boolean;
Const
  procident = 'ReadRegCRC ';
Var
  b: boolean;
  reg: byte;
  kbuf: TKolBuffer;
  klen: word;
  u32: longword;
begin
  Result := false;
  crc := '';
  reg := fRegConfig[CRegCRC];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  if fPTCdebug then kolmsg( procident + ' result len=' +  IntToStr(klen) );
  //answer is sequence of doubles
  if b and (klen>=4) then
    begin
      u32 := BinToUint32LE( kbuf, 0);
      crc := IntToHex(u32, 8);
      Result := true;
    end;
   if fPTCdebug then kolmsg( procident + ' result=' +  crc );
  If not Result then  kolMsg( procident + 'got result bad format');
end;








function TKolPTCObject.ReadRegFwFuseHard(Var ad: TArrayOfDouble): boolean;
Const
  procident = 'ReadRegFwFuseHard ';
Var
  b: boolean;
  kbuf: TKolBuffer;
  klen: word;
  reg: byte;
begin
  Result := false;
  reg := fRegConfig[CRegLimHard];
  if fPTCdebug then kolmsg('>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      Result := processKolArrayOfDouble( kbuf, klen, ad);
    end;
  If not Result then  kolMsg( procident + 'got result bad format');
end;


function TKolPTCObject.ReadRegFwFuseSoft(Var ad: TArrayOfDouble): boolean;
Const
  procident = 'ReadRegFwFuseSoft ';
Var
  b: boolean;
  kbuf: TKolBuffer;
  klen: word;
  reg: byte;
begin
  Result := false;
  reg := fRegConfig[CRegLimSafe];
  if fPTCdebug then kolmsg( '>> ' + procident + ' read reg  ' +  IntToStr( reg ) );
  //
  b := ReadRegister(reg,  kbuf, klen);
  //answer is sequence of doubles
  if b then
    begin
      Result := processKolArrayOfDouble( kbuf, klen, ad);
    end;
  If not Result then  kolMsg( procident + 'got result bad format');
end;



//-----------------------------


function TKolPTCObject.ReadV4range(Var rrec: TPotentioRangeRecord): boolean;
Const
  procident = 'ReadV4range';
Var
  b: boolean;
  c: byte;
  fs:  TFormatSettings;
  len, flags: byte;
  s: string;
  buf: array of byte;
  rets, ax, acmd, apar ,av4reg,av4min,av4max : ansistring;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  rrec := CPTCZeroRng;
  //
  GetLocaleFormatSettings(0, fs);
  fs.DecimalSeparator := '.';
  setlength(buf, 255);
  setlength(rets, 255);
  //example for read reg 48:    11 00 30 01
  acmd := #17;   //$11
  av4reg := #0+chr( fRegConfig[CRegV4Range] );
  apar := #01;
  ax := acmd + av4reg + apar;
  //
  for c:=1 to fRetryCount do
    begin
      // send
      b := Ptc_SendCmd(PByte(@ax[1]), length(ax), @flags, PByte(@buf[0]), @len);
      //
      Inc(fCommCntTotal); if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  Unlock;
  //process reply
  //logproject( 'ReadV4range - result: flags ' + IntToStr( flags ) + ' len ' + IntToStr( len ) + ' buf[0] ' + IntToStr( buf[0] ) );
  //logproject ('ReadV4range - result buf: ' + BinaryArrayToHexStr( buf, len ) );
  if b and (len=8) then
    begin
    rrec.low := BinToFloatLE( buf, 0);
    rrec.high := BinToFloatLE( buf, 4);
    end;
  Result := b;
end;







function TKolPTCObject.GetHWIdStr: string;
begin
  if not IsAvailable then
  begin
      Result := 'PTC not available';
      exit;
  end;
  Result := '>>KolPTC<< Firmware: ' +  string(fPTCinfo.fw)+ ' | Vendor: ' + string(fPTCinfo.fwVendor) + ' | Version: '+ string(fPTCinfo.fwVersion);
end;



// kolptc internal set methods



function TKolPTCObject.ResetFuses(): boolean;       Const
  procident = 'ResetFuses';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  kolMsg('IIII ResetFuses');
  for c:=1 to fRetryCount do
    begin
      b := Ptc_ResetFuse;
      Inc(fCommCntTotal);
      if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed');
      Inc(fCommErrNotCorrCnt);
    end;
  Unlock;
  //here I will not update flags - in this case wait for next aquire of status
  Result := b;
end;


function TKolPTCObject.SetFeedback( fb: TKolPTCFeedback ): boolean;
Const
  procident = 'SetFBsource';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  kolmsg('IIII Setting Feedback (' + IntToStr( ord(fb) ) + ')');
  //
  for c:=1 to fRetryCount do
    begin
      b := Ptc_Feedback( FBtoInternal(fb) );
      Inc(fCommCntTotal);
      if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  //TODO: WAIt for fb stabil!!!!!!!!!
  //delayms(50);
  Unlock;
//store updated value
  if b then fLastPTCStatus.mode := FBtoMode( fb );
  Result := b;
end;


function TKolPTCObject.SetRange( r: TKolPTCRange ): boolean;
Const
  procident = 'SetRange';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  kolmsg('IIII Setting Range (' + IntToStr( ord(r) ) + ')');
  //
  for c:=1 to fRetryCount do
    begin
      b := Ptc_Range( RangeToInternal(r) );
      //
      Inc(fCommCntTotal); if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  Unlock;
  //!!! update range reporting variable
  if b then
    begin
      fRngActCurr := KolRngToRngRec( r );
    end;
  Result := b;
end;


function TKolPTCObject.SetSetpoint( sp: double ): boolean;
Const
  procident = 'SetSetpoint';
Var
  b: boolean;
  c: byte;
  adj: boolean;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  kolmsg('IIII Setting SETPOINT ('  + FloatToStr( sp ) + ')');
  //
  //!!!!!!!!!!!!!!!!!
  //here is only place where this low level function can try to prevent overrange
  //- compare setpoint with actual range and if is out, then adjust!!!
  adj := false;
  case fLastPTCStatus.mode of
    CPotCC: begin
              if (sp < fRngActCurr.low) then begin adj:= true; sp := fRngActCurr.low; end;
              if (sp > fRngActCurr.high) then begin adj:= true; sp := fRngActCurr.high; end;
            end;
    CPotCV: begin
              if (sp < fRngActVolt.low) then begin adj:= true; sp := fRngActVolt.low; end;
              if (sp > fRngActVolt.high) then begin adj:= true; sp := fRngActVolt.high; end;
            end;
  end;
  if adj then logwarning('KolPTC SetSetpoint - SETPOINT WAS ADJUSTED because out of range - new val is: ' + FloatToStr( sp ) );
  //
  for c:=1 to fRetryCount do
    begin
      b := Ptc_Setpoint(sp );
      //
      Inc(fCommCntTotal); if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  //store updated value
  if b then fLastPTCStatus.setpoint := sp;
  //TODO: WAIt for fb stabil!!!!!!!!!
  //delayms(50);
  Unlock;
  Result := b;
end;


function TKolPTCObject.SetOutputRelay( enabled: boolean): boolean;
Const
  procident = 'SetOutputRelay';
Var
  b: boolean;
  c: byte;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  kolmsg('IIII Setting OUTPUT RELAY ('  + IfThenElse( enabled, 'ON','off') + ')');
  //
  for c:=1 to fRetryCount do
    begin
      b := Ptc_OutputEnabled( enabled );
      //
      Inc(fCommCntTotal); if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  //TODO: WAIt for fb stabil!!!!!!!!!
  //delayms(50);
  Unlock;
  //store updated value
  if b then fLastPTCStatus.isLoadConnected := enabled;
  Result := b;
end;


function TKolPTCObject.SetSafetyRangeV4(lowlim, highlim: double): boolean;
Const
  procident = 'SetSafetyRangeV4';
Var
  b: boolean;
  c: byte;
  fs:  TFormatSettings;
  buf: array of byte;
  s: string;
  ax, acmd,av4reg,av4min,av4max : ansistring;
begin
  Result := false;
  if not LockAndCheckConnectedLeaveMsg( procident ) then  exit;
  kolmsg('IIII ' + procident + ' (' + FloatToStr( lowlim ) + ', ' + FloatToStr( highlim )+')');
  //
  GetLocaleFormatSettings(0, fs);
  fs.DecimalSeparator := '.';
  setlength(buf, 255);
   //example set V4 range -0.1 1.6             //#189#204#204#205#63#204#204#205
   // data := #$03#$04;
   // Ptc_SendCmd(PByte(@data[1]), length(data), nil, nil, nil);
  acmd := #21;
  av4reg := #0+chr( fRegConfig[CRegV4Range] )+#0#0;
  av4min := floattobinLE(lowlim);
  av4max := floattobinLE(highlim);
  ax := acmd + av4reg + av4min + av4max;
  //
  for c:=1 to fRetryCount do
    begin
      // send
      b := Ptc_SendCmd(PByte(@ax[1]), length(ax), nil, nil, nil);
      //
      Inc(fCommCntTotal); if not b then Inc(fCommErrCorrectedCnt);
      if b then break;
    end;
  if not b then
    begin
      kolerrormsg(procident + ': failed!');
      Inc(fCommErrNotCorrCnt);
    end;
  Unlock;
  //store updated value
  if b then
    begin
      fRngActVolt.low := lowlim;
      fRngActVolt.high := highlim;
    end;
  Result := b;
end;




function TKolPTCObject.SetCCx( val: double; forceturnon: boolean = false; forcechangefb: boolean = false): boolean;
// TODO: turning on the connection to Load
//TODO:  check status for correct sequence, consider turnoff for changing from voltage
Const
  procident = 'SetCCx ';
Var
  Icoef, newsetp: double;
  bsp, bmode, bturnon: boolean;
begin
  Result := false;
  if not CheckConnectedLeaveMsg( procident ) then exit;
  if CDebug then kolmsg( procident +' (' + FloatToStr( val ) + ')' );
  //new setpoint if correction needed
  Icoef := 1.0; //Icoef := 0.1;    //TODO: !!!!
  newsetp := val * ICoef;

  bmode := true;
  if (fLastPTCStatus.mode <> CpotCC) or forcechangefb then //need switch fb
   begin
    if CDebug then kolmsg( procident + 'will set feedback (' + IntToStr( Ord( FBToInternal( fConstIFeedback ) ) ) + ')' );
    bmode := SetFeedback( fConstIFeedback )
   end;
  if not bmode then
      begin
       kolerrormsg(procident + ': setFB needed and failed, cannot continue');
       exit;
      end;
  //send new setpoint
  bsp := SetSetpoint( newsetp );
  if not bsp then
      begin
       kolerrormsg(procident + ': SetSP failed, cannot continue');
       exit;
      end;
  //turnon if necessary
  bturnon := true;
  if forceturnon then
   begin
    if CDebug then kolmsg( procident + 'will turn relay ON' );
    bturnon := SetOutputRelay( true );
   end;
  if not bturnon then
      begin
       kolerrormsg(procident + ': turnon requested and failed');
      end;
  Result := bmode and bsp and bturnon;
end;


function TKolPTCObject.SetCVx( val: double; forceturnon: boolean = false; forcechangefb: boolean = false): boolean;
// TODO: consider also turning on load
//TODO:  check status for correct sequence, consider turnoff for changing from voltage
Const
  procident = 'SetCVx ';
Var
  Vcoef, newsetp: double;
  bsp, bmode, bturnon: boolean;
begin
  Result := false;
  if not CheckConnectedLeaveMsg( procident ) then exit;
  if CDebug then kolmsg( procident +' (' + FloatToStr( val ) + ')' );
  //new setp
  Vcoef := 1.;    //TODO: !!!!
  newsetp := val * VCoef;
  //
  bmode := true;
  if (fLastPTCStatus.mode <> CpotCV) or forcechangefb then //need switch fb
   begin
    if CDebug then kolmsg( procident + 'will set feedback (' + IntToStr( Ord( FBToInternal( fConstUFeedback ) ) ) + ')' );
    bmode := SetFeedback( fConstUFeedback )
   end;
  if not bmode then
      begin
       kolerrormsg(procident + ': setFB needed and failed, cannot continue');
       exit;
      end;
  //send new setpoint
  bsp := SetSetpoint( newsetp );
  if not bsp then
      begin
       kolerrormsg(procident + ': SetSP failed, cannot continue');
       exit;
      end;
  //turnon if necessary
  bturnon := true;
  if forceturnon then
   begin
    if CDebug then kolmsg( procident + 'will turn relay ON' );
    bturnon := SetOutputRelay( true );
   end;
  if not bturnon then
      begin
       kolerrormsg(procident + ': turnon requested and failed');
      end;
  Result := bmode and bsp and bturnon;
end;

















//-------------------------------



function TKolPTCObject.CheckConnectedLeaveMsg( where: string ): boolean;
//helper - when not connected returns false and logs message
begin
 Result := false;
 if (not fDllFuncAssigned) or (not fDllLoaded) then exit;
 if not Ptc_IsConnected then
  begin
   kolerrormsg(' KOLPTC-CheckIsConnected: in "' +where+ '"- PTC was not available!');
   exit;
  end;
 Result := true;
end;

function TKolPTCObject.LockAndCheckConnectedLeaveMsg( where: string ): boolean;
//helper - when not connected returns false and logs message
begin
 Result := false;
 if kolptclock then
   begin
     kolerrormsg(' KOLPTC-LockAndCheckIsConnected: in "' + where + '"- lock is already ENGAGED');
     exit;
   end
 else kolptclock := true;
 if not CheckConnectedLeaveMsg( where ) then
   begin
     kolptclock := false;
     exit;
   end;
 Result := true;
end;

function TKolPTCObject.TryToLockIfNotLeaveMsg( where: string ): boolean;
//helper - lock access to kolPTC communication
begin
 Result := false;
 if kolptclock then
   begin
     kolerrormsg(' KOLPTC-TryToLock: in "' + where + '"- lock is already ENGAGED');
     exit;
   end
 else kolptclock := true;
 Result := true;
end;


procedure TKolPTCObject.Unlock;
//helper - when not connected returns false and logs message
begin
  kolptclock := false;
end;







procedure TKolPTCObject.SetupRegConfig( r: TKolPTCRegisters; val: byte );
begin
  fRegConfig[r] := val;
  logmsg('TKolPTCObject.SetupRegConfig: setting reg ' + IntToStr( Ord(r) ) + ' to ' + IntToStr( val ) );
  if val = 0 then LogWarning( 'TKolPTCObject.SetupRegConfig: register val of 0 is invalid - default will be used instead');
end;

procedure TKolPTCObject.SetupChannelConfig( ch: TKolPTCChannels; val: byte );
begin
  fChannelConfig[ch] := val;
end;

procedure TKolPTCObject.MarkAsConfigured; //signal that configuration was done (maybe still check integrity) to mark configured flag
//TODO: check if all reg config is OK!
begin
  fConfigured := true;
end;



procedure TKolPTCObject.InitRegConfigWithDef(Var RegConf: TKolPTCRegisterConfig );
Var
 it: TKolPTCRegisters;
begin
  //to be sure, ini all reg to 0;
  for it:= Low(TKolPTCRegisters) to High(TKolPTCRegisters) do RegConf[it] := 0;
  //assign known values
  RegConf[ CRegADC ] := 19;
  RegConf[ CRegV4Range ] := 52;
  RegConf[ CRegRelayON ] := 39;
  RegConf[ CRegSetpoint ] := 40;
  RegConf[ CRegSwFeedback ] := 41;
  RegConf[ CRegProtectStatus ] := 29;
  RegConf[ CRegLimSafe ] := 31;
  RegConf[ CRegLimHard ] := 32;
  RegConf[ CRegMonI ] := 27;
  RegConf[ CRegCRC ] := 0;
end;


//config load save methods
procedure TKolPTCObject.LoadConfig;
begin
  if fConfClient=nil then exit;
  InitRegConfigWithDef( fDefRegConfig );
  //
  //feedback selection atc.
  //buffered read, fRetryCount: byte;
  fBufferedRead := fConfClient.Load( 'BufferedRead', false );
  fRetryCount := fConfClient.Load( 'RetryCount', 3 );
  //constufb, constifb
  fConstUFeedback := TKolPTCFeedback( fConfClient.Load(  'ConstUFeedback', 0 ) );  //internal KolPTC constant as byte
  fConstIFeedback :=  TKolPTCFeedback( fConfClient.Load(  'ConstIFeedback', 3 ) );  //internal KolPTC constant as byte
  //v4rngfrom, v4rngto
  fV4SafetyRange.low := fConfClient.Load( 'V4SafetyRngMin', -0.1);
  fV4SafetyRange.high := fConfClient.Load( 'V4SafetyRngMax', 1.4 );
  //version CRC the config is valid with (FW CRC)
  fRegVersionID := fConfClient.Load(  'RegConfigCRCVersion', 'X' );
  //registers
  fRegConfig[CRegADC] := fConfClient.Load( 'CRegADC',    fDefRegConfig[CRegADC] );
  fRegConfig[CRegRelayON] := fConfClient.Load(  'CRegRelayON',    fDefRegConfig[CRegRelayON]);
  fRegConfig[CRegSetpoint] := fConfClient.Load(  'CRegSetpoint',    fDefRegConfig[CRegSetpoint] );
  fRegConfig[CRegSwFeedback] := fConfClient.Load(  'CRegSwFeedback',    fDefRegConfig[CRegSwFeedback] );
  fRegConfig[CRegProtectStatus] := fConfClient.Load(  'CRegProtectStatus',    fDefRegConfig[CRegProtectStatus] );
  fRegConfig[CRegLimSafe] := fConfClient.Load(  'CRegLimSafe',     fDefRegConfig[CRegLimSafe] );
  fRegConfig[CRegLimHard] := fConfClient.Load(  'CRegLimHard',      fDefRegConfig[CRegLimHard] );
  fRegConfig[CRegMonI] := fConfClient.Load(  'CRegMonI',     fDefRegConfig[CRegMonI] );
  //regCRC is not saved
  fRegConfig[CRegV4Range] := fConfClient.Load( 'CRegV4Range',   52  );
  //channels
  fChannelConfig[CChV4] := fConfClient.Load(  'CChV4',     1);
  fChannelConfig[CChVref] := fConfClient.Load(  'CChVref', 2 );
  fChannelConfig[CChV2] := fConfClient.Load(  'CChV2',     0 );
  fChannelConfig[CChI] := fConfClient.Load(  'CChI',       4 );
  fChannelConfig[CChI10] := fConfClient.Load(  'CChI10',   5 );
  fChannelConfig[CChSP] := fConfClient.Load(  'CChSP',     1 );
end;


procedure TKolPTCObject.SaveConfig;
begin
  if fConfClient=nil then exit;
  //feedback selection atc.
  //buffered read, fRetryCount: byte;
  fConfClient.Save( 'BufferedRead', fBufferedRead );
  fConfClient.Save( 'RetryCount', fRetryCount );
  //constufb, constifb
  fConfClient.Save(  'ConstUFeedback', Integer(fConstUFeedback) );  //internal KolPTC constant as byte
  fConfClient.Save(  'ConstIFeedback', Integer(fConstIFeedback) );  //internal KolPTC constant as byte
  //v4rngfrom, v4rngto
  fConfClient.Save( 'V4SafetyRngMin',fV4SafetyRange.low);
  fConfClient.Save( 'V4SafetyRngMax', fV4SafetyRange.high);
  //version CRC the config is valid with (FW CRC)
  fConfClient.Save(  'RegConfigCRCVersion', fRegVersionID );
  //registers
  fConfClient.Save( 'CRegADC',   fRegConfig[CRegADC] );
  fConfClient.Save(  'CRegRelayON',    fRegConfig[CRegRelayON]);
  fConfClient.Save(  'CRegSetpoint',     fRegConfig[CRegSetpoint] );
  fConfClient.Save(  'CRegSwFeedback',   fRegConfig[CRegSwFeedback] );
  fConfClient.Save(  'CRegProtectStatus',   fRegConfig[CRegProtectStatus] );
  fConfClient.Save(  'CRegLimSafe',     fRegConfig[CRegLimSafe] );
  fConfClient.Save(  'CRegLimHard',       fRegConfig[CRegLimHard] );
  fConfClient.Save(  'CRegMonI',      fRegConfig[CRegMonI] );
  //regCRC is not saved
  fConfClient.Save( 'CRegV4Range',  fRegConfig[CRegV4Range]  );
  //channels
  fConfClient.Save(  'CChV4',    fChannelConfig[CChV4]);
  fConfClient.Save(  'CChVref', fChannelConfig[CChVref] );
  fConfClient.Save(  'CChV2',   fChannelConfig[CChV2] );
  fConfClient.Save(  'CChI',     fChannelConfig[CChI] );
  fConfClient.Save(  'CChI10',   fChannelConfig[CChI10] );
  fConfClient.Save(  'CChSP',   fChannelConfig[CChSP] );
end;


function TKolPTCObject.Ptc_SendCmdWrapper( s: string ): boolean;
Var
  bufin, bufout: array of byte;
  k, lin, loutmax: integer;
  ansflags: Byte;
  lout: byte;
  b: boolean;
  i: longint;
  sout: string;
begin
  Result := false;
  if kolptclock then exit else kolptclock := true;
  if not CheckConnectedLeaveMsg( 'Ptc_SendCmdWrapper' ) then exit;
  lin := length(s);
  loutmax := 255;
  setlength(bufin, lin);
  setlength(bufout, loutmax);
  logmsg('  II: TKolPTCObject.Ptc_SendCmdWrapper: sending msg('+ IntToStr(lin) + '): "' + s + '"' );
  //copy message
  for i:=0 to lin-1 do
    begin
      bufin[i] := CharToByte( s[i+1] );
    end;
  //send
  //Function Ptc_SendCmd(cmdBuffer:PByte; cmdLen:integer; ansFlags:PByte; ansBuffer:PByte; ansLen:PByte):boolean; stdcall; external PTC_DLL_Name name 'Ptc_SendCmd';
  b := Ptc_SendCmd(@bufin, lin, @ansflags, @bufout, @lout);
  //copy out message
  setlength(sout, lout);
  for i:=0 to lout-1 do
    begin
      sout[i] := ByteToChar( bufout[i] );
    end;
  logmsg('  II: TKolPTCObject.Ptc_SendCmdWrapper: result msg('+ IntToStr(lout) + '): "' + sout + '"' );
  Result := b;
  kolptclock := false;
end;


function TKolPTCObject.Ptc_SendCmdArray( Var ab: array of byte; alen: byte ): boolean;
Var
  bufin, bufout: array of byte;
  k, lin, loutmax: integer;
  ansflags: Byte;
  lout: byte;
  b: boolean;
  i: longint;
begin
  Result := false;
  if kolptclock then
  begin
    exit;
  end
  else kolptclock := true;
  if not Ptc_IsConnected then
  begin
   kolerrormsg('TKolPTCObject.Ptc_SendCmdWrapper: PTC not available');
   exit;
  end;
  lin := alen;
  loutmax := 255;
  setlength(bufin, lin);
  setlength(bufout, loutmax);
  //copy message
  for i:=0 to lin-1 do
    begin
      bufin[i] := ab[i];
    end;
  //send
  //Function Ptc_SendCmd(cmdBuffer:PByte; cmdLen:integer; ansFlags:PByte; ansBuffer:PByte; ansLen:PByte):boolean; stdcall; external PTC_DLL_Name name 'Ptc_SendCmd';
  b := Ptc_SendCmd(@bufin, lin, @ansflags, @bufout, @lout);
  Result := b;
  kolptclock := false;
end;


// --------------------  conversion  ----


function TKolPTCObject.FBtoInternal(fb:TKolPTCFeedback): integer;
begin
  Result:= 0;
  if fb=CPTCFbV2 then Result:= CKolPTCFeedbackV2
  else if fb=CPTCFbV4 then Result:= CKolPTCFeedbackV4
  else if fb=CPTCFbVref  then Result:= CKolPTCFeedbackVRef
  else if fb=CPTCFbI then Result:= CKolPTCFeedbackI
  else if fb=CPTCFbIx10 then Result:= CKolPTCFeedbackIx10;
end;

function KolFBToStr( fb:TKolPTCFeedback ): string;
begin
  Result:= '';
  if fb=CPTCFbV2 then Result:= 'V2'
  else if fb=CPTCFbV4 then Result:= 'V4'
  else if fb=CPTCFbVref  then Result:= 'Vref'
  else if fb=CPTCFbI then Result:= 'I'
  else if fb=CPTCFbIx10 then Result:= 'Ix10';
end;

function KolRangetoStr(r: TKolPTCRange): string;
begin
  Result:= '';
  if r=CPTCRng15A then Result:= '15 A'
  else if r=CPTCRng500mA then Result:= '500 mA';
end;


function TKolPTCObject.RangeToInternal(r: TKolPTCRange): integer;
begin
  Result:= 0;
  if r=CPTCRng15A then Result:= CKolPTCRangeR10mOhm
  else if r=CPTCRng500mA then Result:= CKolPTCRangeR1Ohm;
end;



function TKolPTCObject.InternalFBToKol(i: integer ): TKolPTCFeedback;
begin
  Result := High(TKolPTCFeedback);
  if i = CKolPTCFeedbackV2 then Result := CPTCFbV2
  else if i = CKolPTCFeedbackV4 then Result:= CPTCFbV4
  else if i = CKolPTCFeedbackVRef then Result := CPTCFbVref
  else if i = CKolPTCFeedbackI then Result := CPTCFbI
  else if i = CKolPTCFeedbackIx10 then Result := CPTCFbIx10;
end;



function TKolPTCObject.InternalRngToKol(i: integer ): TKolPTCRange;
begin
  Result := High(TKolPTCRange);
  if i = CKolPTCRangeR10mOhm  then Result:= CPTCRng15A
  else if i = CKolPTCRangeR1Ohm then Result:= CPTCRng500mA;
end;


function TKolPTCObject.FBtoMode(fb:TKolPTCFeedback): TPotentioMode;
begin
  Result := CPotERR;
  if (fb = CPTCFbV2) or (fb = CPTCFbV4) or   (fb = CPTCFbVref) then Result := CPotCV;
  if (fb = CPTCFbI) or (fb =  CPTCFbIx10 ) then  Result := CPotCC;
end;


function TKolPTCObject.KolRngToRngRec( kr: TKolPTCRange): TPotentioRangeRecord;
begin
  Result := CPTCZeroRng;
  case kr of
    CPTCRng15A: begin
                  Result.low := -15.0;
                  Result.high := 15.0;
                end;
    CPTCRng500mA: begin
                  Result.low := -0.5;
                  Result.high := 0.5;
                  end;
  end;
end;


procedure TKolPTCObject.WriteRetryCount( c: byte );   //make sure c is at least 1
begin
  if c<1 then c := 1;
  fRetryCount := c;
end;



procedure TKolPTCObject.kolmsg(s: string); //set lastmsg and log it at the same time
begin
  logmsg('KolPTC: '+ s);
end;

procedure TKolPTCObject.kolerrormsg(s: string); //set lastmsg and log it at the same time
begin
  logerror('KolPTC: '+ s);
end;


function TKolPTCObject.kolAssert(ex: boolean; s: string): boolean; //if ex is FALSE leaves warning message; returns true if Assert OK
begin
  Result := ex;
  if not ex then logmsg('KolPTC-Assert failed: '+ s);
end;



function kolbuftostr(Var buf: TKolBuffer ): string;
Var i, l: longint;
begin
  Result := '';
  l := Length(buf);
  if l=0 then exit;
  for i:=0 to l do Result := Result + chr( buf[i] );
end;


//--------------------------------
//   DLL Handling
//--------------------------------

function TKolPTCObject.LoadDll: boolean;
begin
  fDllLoaded := false;
  dllHandle := LoadLibrary( PTC_DLL_Name );       //windows.h
  if dllHandle <> 0 then
    begin
      fDllLoaded := true;
    end
  else
    begin
      kolErrorMsg('EEEE TKolPTCObject.LoadDll {Ptc.dll) failed!');
      ShowMessage('ERROR: LoadDll {Ptc.dll) failed! KolPTC will not work!!!');
    end;
end;

procedure TKolPTCObject.UnLoadDll;
begin
  fDllLoaded := false;
  if dllHandle<>0 then FreeLibrary(dllHandle);
  dllHandle := 0;
end;

function TKolPTCObject.AssignDllFunctions: boolean;
type
  Tproc = Procedure;
  PProc = ^TProc;
Var
  pp: array[0..100] of PProc;
  n: byte;
  i, errcnt: byte;
  errstr : string;
begin
  Result := false;
  fDllFuncAssigned := false;
  if (not fDllLoaded) or (dllHandle = 0) then
    begin
      kolErrorMsg( 'TKolPTCObject.AssignDllFunctions:   DLL not loaded');
      exit;
    end;
  //not checking for enough space in array, adjust max number of elements manually!!!!!
  n := 0;
  pp[n] := GetProcAddress(dllHandle, 'Ptc_Exit');        @Ptc_Exit := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_IsConnected'); @Ptc_IsConnected := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_GetInfo');     @Ptc_GetInfo := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_GetAinAout');  @Ptc_GetAinAout := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_GetAinAout_Buffered'); @Ptc_GetAinAout_Buffered := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_SetAout');    @Ptc_SetAout := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_Range');      @Ptc_Range := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_Feedback');   @Ptc_Feedback := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_Setpoint');   @Ptc_Setpoint := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_OutputEnabled');  @Ptc_OutputEnabled := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_ResetFuse');    @Ptc_ResetFuse := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_ReadFuse');     @Ptc_ReadFuse := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_ReadStatus');  @Ptc_ReadStatus := pp[n];  Inc(n);
  pp[n] := GetProcAddress(dllHandle, 'Ptc_SendCmd');       @Ptc_SendCmd := pp[n];  Inc(n);
  //
  //check if all are assigned
  errcnt := 0;
  errstr := '';
  for i:=0 to n-1 do
    begin
      if not Assigned(pp[i]^) then
        begin
          inc(errcnt);
          errstr := errstr + ', ' + IntToStr(i);
        end;
    end;
  if errcnt = 0 then
    begin
      fDllFuncAssigned := true;
      Result := true;
      kolMsg( 'TKolPTCObject.AssignDllFunctions: assign fucntions from DLL: OK');
    end
  else
    begin
      kolErrorMsg('TKolPTCObject.AssignDllFunctions:  got ' + IntToStr(errcnt) + ' assign failures - on indexes: ' + errstr);
    end;
end;

//--------------------------------


function RetryCallUntilOK( Pfn: PBoolFunc; argc: byte; ArgArray: TArgArray; retryc: byte): boolean;
//pfn: pointer to function that returns boolean (interface functions inptc.dll)
//tries to repeat call until geting true as result- in order to overcome communication errors and so
Var
  b: boolean;
begin
  Result := false;
  if Pfn=nil then exit;
  while retryc>0 do
    begin
    end;
end;






procedure CopyDynArrayToStatic( Var adyn: TArrayOfDouble; Var astat: TStaticArrayOfDouble; Var statlen: byte);
Var
 i,n: longint;
begin
  n := Length(adyn);
  if n>CMaxArrayofDoubleSize then n :=  CMaxArrayofDoubleSize;
  statlen := n;
  if n=0 then exit;
  for i:=0 to n-1 do astat[i] := adyn[i];
end;








//---------------------------trash -----

function TKolPTCObject.GetDataBuffered(Var Rec: TPotentioRec; Var Status: TPotentioStatus): boolean;
Var
  oldb: boolean;
begin
  oldb := FBufferedRead;
  FBufferedRead := true;
  if CDebug then kolmsg('in getdata buffered');
  Result := AquireDataStatus(Rec, Status);
  if CDebug then kolmsg('out getdata buffered');
  FBufferedRead := oldb;
end;



procedure TKolPTCObject.ExitDll;
begin
  kolmsg('TKolPTCObject.ExitDll Calling ptc_exit');
  if Assigned(Ptc_Exit) then Ptc_Exit;
end;


end.

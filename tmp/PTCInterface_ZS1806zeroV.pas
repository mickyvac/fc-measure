unit PTCInterface_ZS1806zeroV;

{
   PTCInterface_M97XX.pas
   Copyright 2017 Michal Vaclavu <michal.vaclavu@gmail.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
}


{

 if not Assigned(self) then  !!!!!!!!!!!!!!!
}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, Windows, ExtCtrls, Graphics,
  Logger, ConfigManager, MyParseUtils, myutils, StrUtils, MyThreadUtils,
  MyScheduler, MyJobThreadSafeManager,
  FormGlobalConfig,
  HWAbstractDevicesV3,
  MyAcquireThreadNEW_RS232, MyComPort, ZSXX_LowLevel_Interface;


Const
 CIfaceVer = 'ZS1806_RS232';

 CControlsSection = 'ControlsSection';

 //CConfigSection = 'M97XXInterface';

 CDebug = false; //true;
 CDebugVarName = '_chkDEBUGvar';
 CDefTargetCycleTimeMS: longint = 500;

 idEnforceDesiredState = 'EnforceDesiredState';

type

  TZSxxStateRec = record
    CVsetp: single;
    CCsetp: single;
    CCCVsetp: single;
    mode: TPotentioMode;
    remotesenes: boolean;
    OutputON: boolean;
    remotectrlOn: boolean;
  end;


  TPtcCmdType = (CPtcCmdUNDEF, CPtcSetCC, CPtcSetCV, CPtcSetOutON, CPtcSetOutOFF,
                  CPtcSetRangeV, CPtcSetRangeI, CPtcSetULimits, CPtcSetILimits,
                  CPtcJobObject, CPtcJobDirectCmd);

  TPtcCmdObj = class (TObject)
    public
      constructor Create(t:TPtcCmdType);
      destructor Destroy; override;
    public
      ftype: TPtcCmdType;
      p1: TMVVariantThreadSafe;
      p2: TMVVariantThreadSafe;
      forceupdate: boolean;
      o: TObject;
  end;



  TZS1806_PTCInterface = class (TPotentiostatObject)
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
      function IsWarning(): boolean;
      function IsFuseActive(): boolean;
      function WarningMsg: string;
      function FuseMsg: string;
      function ResetFUSE: boolean;
      function getIsReady: boolean; override;
    public
      function GenFileInfoHeaderBasic: string; override;
      function GenFileInfoHeaderIncludeDC: string; override;
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
    protected
      function fSetCC( val: double; force: boolean = false): boolean;
      function fSetCV( val: double; force: boolean = false): boolean;
      function fTurnLoadON(force: boolean = false): boolean;
      function fTurnLoadOFF(force: boolean = false): boolean;
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
      //function getConStatus: TInterfaceStatus;
      fxq: TMVQueueThreadSafe;
    private
      fDesiredState: TZSxxStateRec;
      fLastPTCdata: TPotentioRec;
      fLastPTCStatus: TPotentioStatus;
      //configuration
      friDebug: TRegistryItem;
      procedure setDebug(b: boolean);
      function getDebug(): boolean;
    public
      //property ConStatus: TInterfaceStatus read getConStatus;
      //property Flags: TPotentioFlagSet read fFlagSet;
      property Debug: boolean read getDebug write setDebug;
    private
     friPortName: TRegistryItem;
     friBR: TRegistryItem;
     friDataBits: TRegistryItem;
     friStopBits: TRegistryItem;
     friParity: TRegistryItem;
     friFlowCtrl: TRegistryItem;
     friEnforceState: TRegistryItem;
    public
      procedure LoadConfig;
      procedure SaveConfig;
      procedure CreateGUI(Var pan: TPanel); //override;
      procedure RefreshGUI;
      //procedure HandleBroadcastSignals(sig: TMySignal);
    public
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
      fZSIface: TZSXXlowlevelIface;
      fComPort: TComPortThreadSafe;
      fLog:  TLoggerThreadSafeNew;
      fAcquireThread: TAcquireThreadV2_RS232;
      fCmdQueue: TMVQueueThreadSafe;
      fDataRegistry: TMyRegistryNodeObject;   //stores data and status - access methods are THREADSAFE!!!
    private
      fReady: TMVVariantThreadSafe;
      fDoingInitCnt: TMVVariantThreadSafe;  //indication of init in progress and number of retries - if valint=0 or not valbool then init is done.
      fReconnectTry: TMVVariantThreadSafe;
      fLastAcqElapsedMS: TMVVariantThreadSafe;
    private  //GUI
      fPanelRef: TPanel;
      fInfoLabel: TLabel;
      fButtonConfPort: TButton;
      fMemo: TMemo;
      fConsoleMemo: TMemo;
      fUserCmdEdit: TEdit;
      fUserCmdBut: TButton;
      fGUIassigned: boolean;
      fIsConfigured: boolean;
      //fComPortConf: TComPortConf;
      //fIsonfigured: boolean;
    public //GUI
      procedure GUIOnClickConfPort(Sender: TObject);  //
      procedure fIfaceLogProc(s: string);
      procedure fGUIuserCMDclick(Sender: TObject);
      procedure fGUIuserReceiveReply(rep: string);
      procedure DoUserCmd(cmd: string; logfunc: TLogProcedureThreadSafe);
      procedure fUserCmdProcessJob( j: TJobThreadSafe);
    private
      procedure fInsideThreadExecuteSequence;
      procedure fInsideThreadAcquire;
      procedure fInsideThreadProcessCmd;
    private
      fRegSection: string;
      friTargetCycleTimeMS: TRegistryItem;

    private
      //procedure ResetLastAquireTime;
      procedure _LogMsg(a: string);   //internal thread safe log
    public

    private
      //bklock: boolean;  //prevent multiple calls to comm fucntions (because during receive - waiting and calling app.procmessages)

      //lastsetp: double;

      //lastres: boolean;
      //lastmsg: string;
      //countererr: longint;    //counter of send msg/ recv msg errors
      //counterok: longint;     //ounter of send/recv msg success
    private
      //---error reporting and logging fucntion
      //procedure IncErrCnt;
      //procedure IncOKCnt;
      //procedure bkmsg(s: string); //set lastmsg and log it at the same time  - into internal log
    public
      //last result
      LastU: double;
      LastI: double;
      LastP: double;
      LastTimestamp : double;  //now()
      LastCmdOK: boolean;
    private
      //GUI helper
      fHelperLastBottomY: integer;
      procedure HelperCreateCheckboxAssignVariable(lbl: string; xpos: integer; hght: integer; regvarname: string);
    public
      procedure HandlerCheckBoxClick(Sender: TObject);


  end; //*************************



Implementation



uses Math, Forms, DateUtils;


//---- private variables declaration


procedure BKReportError(errlvl: byte; msg: string);
begin
  logmsg('BKReport error: (' + IntToStr(errlvl) + ') ' + msg);
end;




//*************************










constructor TZS1806_PTCInterface.Create;
begin
  inherited Create( 'ZS1806 Electronic Load', CIfaceVer, false);
  fGUIassigned := false;
  fIsConfigured := false;
  // main objects
  fLog := TLoggerThreadSafeNew.Create;
  if fLog<>nil then fLog.StartLogFilePrefix('!ptc-M97xx_','.txt');
  fComport := TComPortThreadSafe.Create;
  if fComport<>nil then
    begin
      fComport.AssignLogProc( _LogMsg );
    end;
  //
  fDataRegistry := TMyRegistryNodeObject.Create('ZS1806_DataAndStatus');   //stores data and status - access methods are THREADSAFE!!!
  //
  fZSIface := TZSXXlowlevelIface.Create( fDataRegistry );
  if fZSIface<>nil then
    begin
      fZSIface.AssignComPort(fComPort);
      fZSIface.AssignLogProc(fIfaceLogProc);
    end;
  //

  //
  fReady := TMVVariantThreadSafe.Create(false);
  fDoingInitCnt := TMVVariantThreadSafe.Create( 0 );  //number of retries
  fReconnectTry := TMVVariantThreadSafe.Create( 0 );
  fLastAcqElapsedMS := TMVVariantThreadSafe.Create( -1 );
  friDebug := fDataRegistry.GetOrCreateItem(CDebugVarName);
  //
  fCmdQueue := TMVQueueThreadSafe.Create;
  fAcquireThread := TAcquireThreadV2_RS232.Create( fInsideThreadExecuteSequence, fComPort, fLog, nil);
  //
  //GlobalConfig.RegisterF8orBroadcastSignals( HandleBroadcastSignals );
  //assign shortcut to important variables of interface registry
  fRegSection := CIfaceVer;
  friTargetCycleTimeMS := RegistryHW.NewItemDef(fRegSection, 'TargetCycleTimeMS', 300);

  fxq := TMVQueueThreadSafe.Create;
end;


destructor TZS1806_PTCInterface.Destroy;
begin
  MyDestroyAndNil( fAcquireThread );
  MyDestroyAndNil( fZSIface );
  MyDestroyAndNil( fComport);
  MyDestroyAndNil( fDataRegistry);
  MyDestroyAndNil( fReady);
  MyDestroyAndNil( fDoingInitCnt);
  MyDestroyAndNil( fReconnectTry);
  MyDestroyAndNil( fLastAcqElapsedMS);
  MyDestroyAndNil( fCmdQueue );
  MyDestroyAndNil( fLog );

 fxq.Destroy;

  inherited;
end;



function TZS1806_PTCInterface.IsAvailable(): boolean;
begin
  Result := fIsConfigured and (fAcquireThread<>nil) and (fComport<>nil) and (fAcquireThread<>nil) and  (fDataRegistry<>nil);
end;




function TZS1806_PTCInterface.Initialize: boolean;
Var
  b: boolean;
begin
  Result := false;
  if (fAcquireThread = nil) or (fReady = nil ) or (fDoingInitCnt = nil) then exit;
  if not fIsconfigured then LoadConfig;
  if not fIsconfigured then exit;
  //
  if fReady.valBool then Finalize;
  fReady.valBool := false;
  fAcquireThread.OpenClient;
  fDoingInitCnt.valInt := 3;  //number of retrie to connect
  fReconnectTry.valInt := 0;
  fAcquireThread.ResetUserSuspend;
  Result := true;
  logmsg('TZS1806_PTCInterface.Initialize: .... Iface ver str: ' + CIfaceVer );
end;



procedure TZS1806_PTCInterface.Finalize;
begin
  _logmsg('Finalize...waiting for thread suspend!!!' );
  if (fAcquireThread = nil)  or (fReady = nil ) then exit;
  fReady.valBool := false;
  fDoingInitCnt.valInt := 0;
  fAcquireThread.SetUserSuspend;
  fAcquireThread.CloseClient;
  //
  while (fAcquireThread.IsThreadRunning) do begin sleep(10); end;
  _logmsg('TAlicatFlowControl.Finalize...Done.' );
end;



//*********************




procedure TZS1806_PTCInterface.fInsideThreadExecuteSequence;
Const
  ThisProc = 'fInsideThreadExecuteSequence';
Var
  t0a, t0b, dta, dtb, dt, targettimecmp: longword;
  b1, conOK, afterInit, didchange: boolean;
  xs: string;
  actmode: TPotentioMode;
  fEnforce: boolean;
begin
  //check ready or do init
  if (fDoingInitCnt=nil) or (fReady=nil) or (fComPort=nil) then
      begin
        _LogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        sleep(1000);
        exit;
      end;
    //check if iface became ready after init was called
  afterinit := false;
  if fDoingInitCnt.valBool and (not fready.valBool) then
    begin
       _LogMsg( 'Doing init - was not READY' );
      conOK := false;
      if not fComPort.IsPortOpen then
        begin
          fAcquireThread.OpenClient;
          exit;
        end;
      conOK := fZSIface.VerifyConnection;
      fready.valBool := conOK;
      afterinit := true;
      if not conOK then fDoingInitCnt.valInt := fDoingInitCnt.valInt - 1 else fDoingInitCnt.valInt := 0;
      _LogMsg( 'Doing init - verify connection result: ' + BoolToStr( conOK) + ' # of test ' + IntToStr(fDoingInitCnt.valInt) );
    end
  else if fReady.valBool then //check if connection is not lost
    begin
      if not fComPort.IsPortOpen then
        begin
          if fReconnectTry.valInt > 10 then
            begin
             fReady.valBool := false;
             _LogMsg( 'Connection LOST - reconnect failed 10x' );
             exit;
            end;
          fAcquireThread.OpenClient;
          fReconnectTry.valInt := fReconnectTry.valInt + 1;
          exit;
        end;
    end;
  if not fReady.valBool then exit;
  fReconnectTry.valInt := 0;
  //
  //
  t0a := TimeDeltaTICKgetT0;
  //
  //acquire status data
  b1 := false;
  try
    //fInsideThreadAcquire;
     if debug then _LogMsg('==acquire');
     b1 := fZSIface.AcquireStatus;
  except on E: Exception do begin _LogMsg('EXCEPTION: ' +  ThisProc + ': ' + E.Message) end;
  end;
  if not b1 then _LogMsg('InsideThreadAcquire: AquireStatus Failed');
  //if jsut after init the adjust desired state to current state!
  fEnforce := friEnforceState.valBool;


  if b1 and afterinit then
    begin
      //fDesiredState.mode :=  TM97xxMode( fM97xxIface.Data.valInt[ IdM97HL_Mode  ] );
      //fDesiredState.CVsetp := fZSIface.HLGetLastSetpointU;
      //fDesiredState.CCsetp := fM97xxIface.HLGetLastSetpointI;
      //fDesiredState.CCCVsetp := fRngV4SWLimit.low;
      //fDesiredState.OutputON := fM97xxIface.HLgetOutputOn;
      //fDesiredState.remotesenes := fM97xxIface.HLgetRemoteSenseOn;
    end;
  //verify setup is matching desired state
  if b1 and (not   afterinit) and ( fEnforce ) then
    begin
{
      if fDesiredState.OutputON <> fM97xxIface.HLgetOutputOn then
        begin
          if fDesiredState.OutputON then fTurnLoadON(true) else fTurnLoadOFF(true);
          xs := '  Load State was different than expected: OUTPUT ON was'  + BoolToStr( fM97xxIface.HLgetOutputOn);
          _LogMsg(xs);
          LogWarning(xs);
        end;
      actmode := TM97xxMode( fM97xxIface.Data.valInt[ IdM97HL_Mode  ] );
      if fDesiredState.mode <> actmode then
        begin
          didchange := true;
          if (fDesiredState.mode = CM97xxModeCC) then
             fSetCC( fDesiredState.CCsetp, true );
          if fDesiredState.mode = CM97xxModeCV then
             fSetCV( fDesiredState.CVsetp, true );
          if (fDesiredState.mode = CM97xxModeCCCV) then
            if (actmode = CM97xxModeCCCVchangingToCV) then didchange := false
            else fSetCC( fDesiredState.CCsetp, true );
          if didchange then
            begin
              xs := '  Load State was different than expected: MODE was '  + fM97xxIface.Data.valstr[ IdM97HL_Mode  ];
              _LogMsg(xs);
              LogWarning(xs);
            end;
        end;
      if ( (fDesiredState.mode = CM97xxModeCC) or (fDesiredState.mode = CM97xxModeCCCV) ) and (fDesiredState.CCsetp<> fM97xxIface.HLGetLastSetpointI) then
        begin
             fSetCC( fDesiredState.CCsetp, true );
           //
          xs := '  Load State was different than expected: SETP - CC'  + FloatToStr( fM97xxIface.HLGetLastSetpointI );
          _LogMsg(xs);
          LogWarning(xs);
        end;
      if (fDesiredState.mode = CM97xxModeCV) and (fDesiredState.CVsetp<> fM97xxIface.HLGetLastSetpointU) then
        begin
          fSetCV( fDesiredState.CVsetp, true );
          //
          xs := '  Load State was different than expected: SETP - CV'  + FloatToStr( fM97xxIface.HLGetLastSetpointU );
          _LogMsg(xs);
          LogWarning(xs);
        end;
        }
    end;

  //special case for this M97xx load - check for undefined state with CCCV mode  - "undocumented mode 35"

{  if b1 and ( fM97xxIface.Data.valInt[ IdM97SETMODE ] = CM97CmdCCCVchangingToCV ) then
    begin
      // normally the load is for some time hangling the protection intitiation
      //but apparently sometimes it fails ... and ends in state, where maximum current is flowing - fully open
      //!!! must check against this special condition AND ACT ONLY IN THIS SPECIAL CASE
      //otherwise this action will disrupt normal transition to CV protection !!!!!!
      //try turn off and ON again - but only if setpoint is lower than actuall  current
        if fM97xxIface.Data.valInt[ IdM97I ] > fM97xxIface.Data.valInt[ IdM97IFIX ] then
          begin
            fTurnLoadON( true );
            fTurnLoadOFF( true );
            xs := '  detected undefined state in CCCV mode';
            _LogMsg(xs);
          end;
    end;
 }
  //
  dta := TimeDeltaTICKNowMS( t0a );
  t0b := TimeDeltaTICKgetT0;
  //
  //process commands
  try
    fInsideThreadProcessCmd;
  except on E: Exception do begin _LogMsg('EXCEPTION: ' +  ThisProc + ': ' +  E.Message) end;
  end;
  dtb := TimeDeltaTICKNowMS( t0b );
  dt := TimeDeltaTICKNowMS( t0a );
  //
  //sleep/delay to get defined acquire frequency
  if friTargetCycleTimeMS<>nil then targettimecmp := friTargetCycleTimeMS.valInt else targettimecmp := CDefTargetCycleTimeMS;
  if dt<(targettimecmp-10) then sleep(targettimecmp - dt);
  fLastAcqElapsedMS.valInt := dt;
end;



procedure TZS1806_PTCInterface.fInsideThreadAcquire;
begin
end;



procedure TZS1806_PTCInterface.fInsideThreadProcessCmd;
Const
  ThisProc = 'fInsideThreadProcessCmd ';
Var
  n: byte;
  w: word;
  i, k: longint;
  b, didchange: boolean;
  f, g: single;
  cmdo: TPtcCmdObj;
  forceupd: boolean;
  jdc: TJobDirectCommand;
  bb: boolean;
begin
  if (fZSIface=nil) or (fready=nil) or (fCmdQueue=nil) then
      begin
        _LogMsg('Some of "synchro" objects is NIL - exit');
        exit;
      end;
  if not fready.valBool then exit;
  //if debug then _LogMsg('==process cmds | in queue: ' + IntToStr(fCmdQueue.Count) );
  //
  while fCmdQueue.Count > 0 do
    begin
      cmdo := TPtcCmdObj( fCmdQueue.Pop );
      if cmdo<>nil then
        begin
          forceupd := cmdo.forceupdate;
          didchange := false;
          //
          case cmdo.ftype of
             CPtcSetCC:
                begin
                  f := cmdo.p1.valDouble;
                  g := fRngV4SWLimit.low;
                  didchange := false;
                  //
                  if (f<>fDesiredState.CCsetp) or forceupd then
                    begin
                      fZSIface.SetIsetp( f );
                      didchange := true;
                    end;
                  if g<>fDesiredState.CCCVsetp then
                    begin
                      fZSIface.SetUlimit( g );    //!!!!!!!!!!!!!!TODO thread safe
                      didchange := true;
                    end;

                  //watch OUT the load need to send set mode after change of septopint!!! //if (fDesiredState.mode <> CM97xxModeCCCV) or forceupd then
                  if didchange or forceupd then
                    begin
                     DelayMS(10);
                     fZSIface.SetModeCC;
                    end;
                  //
                  fDesiredState.CCsetp := f;
                  fDesiredState.CCCVsetp := g;
                  fDesiredState.mode := CPotCC;
                  //
                  _LogMsg(ThisProc + ' setCCCV ' + FloatToStr( f) + ' CV limit ' + FloatToStr( fRngV4SWLimit.low) );
                end;
             CPtcSetCV:
                begin
                  f := cmdo.p1.valDouble;
                  didchange := false;
                  if (f<>fDesiredState.CVsetp) or forceupd then
                    begin
                     fZSIface.SetUsetp( f );
                     didchange := true;
                    end;
                  //if (fDesiredState.mode <> CM97xxModeCV) or forceupd then
                  if didchange or forceupd then
                    begin
                     DelayMS(10);
                     fZSIface.SetModeCV;
                    end;
                  //
                  fDesiredState.CVsetp := f;
                  fDesiredState.mode := CPotCV;
                  //
                  _LogMsg(ThisProc + ' setCV ' + FloatToStr( f) );
                end;
             CPtcSetOutON:
                begin
                  if (not fDesiredState.OutputON) or forceupd then
                    begin
                     fZSIface.SetInputON;
                    end;
                  //
                  fDesiredState.OutputON := true;
                  //
                  _LogMsg(ThisProc + ' set INPUT ON ');
                end;
             CPtcSetOutOFF:
                begin
                  if (fDesiredState.OutputON) or forceupd then    //prevents multiple sequential calls
                    begin
                      fZSIface.SetInputOFF;
                    end;
                  //
                  fDesiredState.OutputON := false;
                  //
                  _LogMsg(ThisProc + ' set INPUT OFF ');
                end;
             //general job proccessing
             CPtcJobDirectCmd:
               begin
                 jdc := TJobDirectCommand( cmdo.o);
                 if jdc<>nil then
                   begin
                     bb := fZSIface.RunUserCommand( jdc.Cmd, jdc.Reply, jdc.elapsedMS );
                     if bb then jdc.ResultCode := CJOK else  jdc.ResultCode := CJError;
                     jdc.FinishJob;
                     MainJobManager.AddJobReport(jdc);
                     fxq.Add(jdc);
                     jdc.SmartDestroy;  //expecting smart destroy with referencecounting
                     jdc := nil;
                     jdc := TJobDirectCommand( fxq.Pop );
                   end;
               end;
          end; //case
          cmdo.Destroy;
        end;
    end;
//  b := fM97xxIface.AcquireStatus;
  //if not b then _LogMsg('InsideThreadAcquire: AquireStatus Failed');
end;

{
  begin
    if (fdevicessynchro=nil) or (fcmdsynchro=nil) or (fDataRegistry=nil) then
      begin
        _LogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        exit;
      end;
   if not fready then exit;
    //
  try
   cmdstrlist := TStringList.Create;
   replylist := TStringList.Create;
    fcmdsynchro.BeginRead;
      w := fcmdsynchro.nWaiting;
      for i:=0 to w-1 do
        begin
           b := fcmdsynchro.PopCmd( cmd );
           if b then cmdstrlist.Add( MakeCmdStr( cmd ) );
        end;
    fcmdsynchro.EndRead;
    if cmdstrlist.Count>0 then b := fTCPclient.QueryDoCommands(cmdstrlist, replylist);
   //
   cmdstrlist.Destroy;
   replylist.Destroy;
 except
    on E: Exception do begin _LogMsg('E: ' +  E.Message) end;
 end;
end;

}



//*******************************





//basic control functions - override
function TZS1806_PTCInterface.AquireDataStatus(Var rec: TPotentioRec; Var Status: TPotentioStatus): boolean;
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
    fFlagSet: TPotentioFlagSet;
    xImode: TPotentioMode;
    xIsetp: double;
begin
    Result := false;
    InitPtcRecWithNAN( rec, status );
    fFlagSet := [];
    FlagUpdate(not fIsConfigured, CPtcNotConfigured, fFlagSet );
    FlagUpdate(not IsAvailable, CNotAvailable, fFlagSet );
    if not IsAvailable then
      begin
        exit;
      end;
    if not fReady.valBool then exit;
    //no check for available necessary - it is done on the lower level
    b1 := false;
    b2 := false;
  with rec do
    begin
        timestamp := fZSIface.Data.TS[ IdHHAcquireStatReply ];
        U := fZSIface.Data.valDouble[ IdHHvalU  ];
        I := fZSIface.Data.valDouble[ IdHHvalI  ];
        P := fZSIface.Data.valDouble[ IdHHvalP  ];
        Uref := NaN;
   end;
   fFlagSet := GetFlags();
   xImode := TPotentioMode( fZSIface.Data.valInt[ IdHHmodeStr  ] );
   xIsetp := fZSIface.Data.valDouble[ IdHHspI  ];
    with Status do
      begin
       flagSet := fFlagSet;
       mode := xImode;
       setpoint := xIsetp;
       isLoadConnected := fZSIface.getOutputOn;
       //
       rangeCurrent := fRngCurrRec;
       rangeVoltage := fRngVoltRec;
       rngV4Safe := fRngV4SWLimit;
       rngV4hard :=  fRngV4HardLimit;
       //                                                          //set
       debuglogmsg := '[ZS1806]|'+
                      'Output=' + BoolToStr(isLoadConnected) +
                      '|Mode=' + IntToStr(Ord(mode)) +
                      '|setp=' + FloatToStrF(setpoint, ffFixed, 4,2);
      end;
   setLastAcqTimeMS( fLastAcqElapsedMS.valInt );
   //
   fLastPTCdata := rec;
   fLastPTCStatus := Status;
   //
   if cDebug then _logmsg('TZS1806_PTCInterface.AquireDataStatus: GetData OK.');
   Result := true;
end;



function TZS1806_PTCInterface.GetFlags(): TPotentioFlagSet;
begin
  Result := [];
  FlagUpdate(not fIsConfigured, CPtcNotConfigured, Result );
  FlagUpdate(not IsAvailable, CNotAvailable, Result );
  FlagUpdate(fZSIface=nil, CInternalError, Result );
  if fZSIface=nil then exit;

  FlagUpdate(not IsAvailable, CNotAvailable, Result );
  FlagUpdate(not IsAvailable, CNotAvailable, Result );
  FlagUpdate(not IsAvailable, CNotAvailable, Result );
  FlagUpdate(not IsAvailable, CNotAvailable, Result );
end;






function TZS1806_PTCInterface.SetCC( val: double): boolean;
begin
  Result := fSetCC( val );
end;

function TZS1806_PTCInterface.fSetCC( val: double; force: boolean = false): boolean;
Const
  ThisProc = 'SetCC ';
Var
  cmdo: TPtcCmdObj;
begin
  if not fReady.valbool or (fCmdQueue=nil) then
    begin
     LogMsg(ThisProc + 'NOT READY');
     exit;
    end;
  cmdo := TPtcCmdObj.Create( CPtcSetCC );
  if cmdo<>nil then
    begin
      cmdo.p1.valDouble := val;
      cmdo.forceupdate := force;
      fCmdQueue.Add(cmdo);
    end;
  Result := true;
end;





function TZS1806_PTCInterface.SetCV( val: double): boolean;
begin
  Result := fSetCV( val );
end;

function TZS1806_PTCInterface.fSetCV( val: double; force: boolean = false): boolean;
Const
  ThisProc = 'SetCV ';
Var
  cmdo: TPtcCmdObj;
begin
  if not fReady.valbool or (fCmdQueue=nil) then
    begin
     LogMsg(ThisProc + 'NOT READY');
     exit;
    end;
  cmdo := TPtcCmdObj.Create( CPtcSetCV );
  if cmdo<>nil then
    begin
      cmdo.p1.valDouble := val;
      cmdo.forceupdate := force;
      fCmdQueue.Add(cmdo);
    end;
  Result := true;
end;

function TZS1806_PTCInterface.TurnLoadON: boolean;
begin
  Result := fTurnLoadON();
end;

function TZS1806_PTCInterface.fTurnLoadON(force: boolean = false): boolean;
Const
  ThisProc = 'TurnLoadON ';
Var
  cmdo: TPtcCmdObj;
begin
  if not fReady.valbool or (fCmdQueue=nil) then
    begin
     LogMsg(ThisProc + 'NOT READY');
     exit;
    end;
  cmdo := TPtcCmdObj.Create( CPtcSetOutON );
  if cmdo<>nil then
    begin
      cmdo.forceupdate := force;
      fCmdQueue.Add(cmdo);
    end;
  Result := true;
end;

function TZS1806_PTCInterface.TurnLoadOFF: boolean;
begin
  Result := fTurnLoadOFF;
end;

function TZS1806_PTCInterface.fTurnLoadOFF(force: boolean = false): boolean;
Const
  ThisProc = 'TurnLoadOFF ';
Var
  cmdo: TPtcCmdObj;
begin
  if not fReady.valbool or (fCmdQueue=nil) then
    begin
     LogMsg(ThisProc + 'NOT READY');
     exit;
    end;
  cmdo := TPtcCmdObj.Create( CPtcSetOutOFF );
  if cmdo<>nil then
    begin
      cmdo.forceupdate := force;
      fCmdQueue.Add(cmdo);
    end;
  Result := true;
end;


//  --------------


function TZS1806_PTCInterface.IsWarning(): boolean;
begin
  Result := false;
end;

function TZS1806_PTCInterface.IsFuseActive(): boolean;
begin
  Result := false;
end;

function TZS1806_PTCInterface.WarningMsg: string;
begin
  Result := '';
end;

function TZS1806_PTCInterface.FuseMsg: string;
begin
  Result := '';
end;

function TZS1806_PTCInterface.ResetFUSE: boolean;
begin
  Result := true;
end;


function TZS1806_PTCInterface.getIsReady: boolean;
begin
  if fReady<>nil then Result := fReady.valBool else Result := false;
end;



function TZS1806_PTCInterface.GenFileInfoHeaderBasic: string;
begin
  Result := '[PTC Status]'#13#10
            + 'ID=Potenciostat '+ NameLongId + #13#10
            + 'Range='+ TRangeRecordToStr( fLastPTCStatus.rangeCurrent) + '|' + TRangeRecordToStr( fLastPTCStatus.rangevoltage) +#13#10
            + 'Feedback='+ PTCModeToStr( fLastPTCStatus.mode )+#13#10
            + 'Autocalib=NA'#13#10
            + 'AutoRange=NA'#13#10
end;


function TZS1806_PTCInterface.GenFileInfoHeaderIncludeDC: string;
begin
  Result := GenFileInfoHeaderBasic
            + 'OutputEnabled='+ BoolToStr( fLastPTCStatus.isLoadConnected )+#13#10
            + 'Feedback='+ PTCModeToStr( fLastPTCStatus.Mode )+#13#10
            + 'Setpoint='+ BoolToStr( fLastPTCStatus.isLoadConnected )+#13#10
            + 'Vout=NA'+#13#10
            + 'Vsense='+ FloatToStrF( fLastPTCdata.U , ffFixed, 4,2)+#13#10
            + 'Vref='+ FloatToStrF( fLastPTCdata.Uref , ffFixed, 4,2)+#13#10
            + 'I='+ FloatToStrF( fLastPTCdata.I , ffFixed, 4,2)+#13#10

end;




//***********ranges  *****

procedure TZS1806_PTCInterface.SetRngCurrent(nr: byte);
begin
  fRngVoltRec.low := 0;   fRngVoltRec.high := 30;
end;

procedure TZS1806_PTCInterface.SetRngVoltage(nr: byte);
begin
  fRngVoltRec.low := 0;   fRngVoltRec.high := 15;
end;


procedure TZS1806_PTCInterface.SetRngV4SwLimit(rec: TRangeRecord);
begin
  fRngV4SWLimit := rec;
  fRngV4HardLimit := rec;
end;

procedure TZS1806_PTCInterface.SetRngV4HardLimit(rec: TRangeRecord);
begin
  fRngV4SWLimit := rec;
  fRngV4HardLimit := rec;
end;

procedure TZS1806_PTCInterface.GetRngArrayCurrent( Var ar:TPotentioRangeArray);
begin
  setlength(ar, 0);
end;

procedure TZS1806_PTCInterface.GetRngArrayVoltage( Var ar:TPotentioRangeArray);
begin
  setlength(ar, 0);
end;




//***********************


procedure TZS1806_PTCInterface.setDebug(b: boolean);
begin
  if friDebug<>nil then friDebug.valBool := b;
  if fZSIface<>nil then  fZSIface.Debug := b;
  if fComPort<>nil then fComPort.Debug := b;
end;

function TZS1806_PTCInterface.getDebug(): boolean;
begin
  if friDebug<>nil then Result := friDebug.valBool else Result := false;
end;

procedure TZS1806_PTCInterface._LogMsg(a: string);
begin   //internal thread safe log
  if fLog<>nil then fLog.LogMsg(a);
end;




{   TComPortConf = record
      Name: string;
      BR: string;
      DataBits: string;
      StopBits: string;
      Parity: string;
      FlowCtrl: string;
  end;}

procedure TZS1806_PTCInterface.LoadConfig;
Var
  fPConf: TComPortConf;
begin
  fComPort.getComPortConf( fPConf );
  friPortName := RegistryHW.NewItemDef(fRegSection, 'COMPortName', 'COM9');
  friBR := RegistryHW.NewItemDef(fRegSection, 'COMBR', '57600');
  friDataBits := RegistryHW.NewItemDef(fRegSection, 'COMDataBits', fPConf.DataBits);
  friStopBits := RegistryHW.NewItemDef(fRegSection, 'COMStopBits', fPConf.StopBits);
  friParity := RegistryHW.NewItemDef(fRegSection, 'COMParity', fPConf.Parity);
  friFlowCtrl := RegistryHW.NewItemDef(fRegSection, 'COMFlowCtrl', fPConf.FlowCtrl);
  with fPConf do
    begin
      Name := friPortName.valStr;
      BR := friBR.valStr;
      DataBits := friDataBits.valStr;
      StopBits := friStopBits.valStr;
      Parity := friParity.valStr;
      FlowCtrl := friFlowCtrl.valStr;
    end;
  fComPort.setComPortConf( fPConf );
  //

  friEnforceState := RegistryHW.NewItemDef(fRegSection, idEnforceDesiredState, true);

{
  fRemoteSenseOn := fConfClient.Load('fRemoteSenseOn', true );
  //
;}
  fIsConfigured := true;
end;

procedure TZS1806_PTCInterface.SaveConfig;
Var
  fPConf: TComPortConf;
begin
  fComPort.getComPortConf( fPConf );
  with fPConf do
    begin
       friPortName.valStr := Name ;
       friBR.valStr := BR;
       friDataBits.valStr := DataBits;
       friStopBits.valStr := StopBits;
       friParity.valStr := Parity;
       friFlowCtrl.valStr := FlowCtrl;
    end;
  //
  //fConfClient.Save('fRemoteSenseOn', fRemoteSenseOn );
end;


procedure TZS1806_PTCInterface.HelperCreateCheckboxAssignVariable(lbl: string; xpos: integer; hght: integer; regvarname: string);
Var
  chk: TCheckBox;
begin
  if fPanelRef = nil then exit;
  chk := TCheckBox.Create(nil);
  with chk do
    begin
      Parent := fPanelRef;
      Name := regvarname;
      Caption := lbl;
      height := hght;
      top := fHelperLastBottomY;
      left := xpos;
      font.Color := clRed;
      OnClick := HandlerCheckBoxClick;
    end;
  fHelperLastBottomY := fHelperLastBottomY + hght + 1;
end;


procedure TZS1806_PTCInterface.HandlerCheckBoxClick(Sender: TObject);
  procedure _UpdateDebug;
  begin
    debug := fDataRegistry.valBool[ CDebugVarName ];
  end;

Var
  s: string;
  b: boolean;
  chk: TCheckbox;
  ri: TRegistryItem;
begin
  if Sender=nil then exit;
  if not( Sender is TCheckBox ) then exit;
  chk := TCheckBox( Sender );
  s := chk.Name;
  UniqueString( s );
  b := chk.Checked;
  fDataRegistry.valBool[ s ] := b;
  //
  _UpdateDebug;  //prasarna - docasne
end;

procedure TZS1806_PTCInterface.CreateGUI(Var pan: TPanel);
var
 w,h: integer;
begin
  fPanelRef := pan;
  if fPanelRef = nil then exit;
  fGUIassigned := true;
  //
  w := fPanelRef.Width;
  h := fPanelRef.Height;
  fInfoLabel := TLabel.Create(nil);
  with fInfoLabel do
    begin
      Parent := fPanelRef;
      autosize := false;
      height := 20;
      top := 1;
      left := 1;
      width := w - 5;
      font.Color := clLime;
      Color := clBlack;
    end;
  fButtonConfPort := TButton.Create(nil);
  with fButtonConfPort do
    begin
      Parent := fPanelRef;
      height := 20;
      top := 22;
      left := 1;
      width := 250;
      Caption := 'Configure COM port';
      OnClick := GUIOnClickConfPort;  //TNotifyEvent
    end;

  fHelperLastBottomY := 44;
  HelperCreateCheckboxAssignVariable('Debug log ON', 1, 20, CDebugVarName);

  fHelperLastBottomY := 66;

 fUserCmdEdit := TEdit.Create(nil);
  with fUserCmdEdit do
    begin
      Parent := fPanelRef;
      top := fHelperLastBottomY;
      left := 1;
      width := w - 100;
      height := 20;
    end;

 fUserCmdBut := TButton.Create(nil); ;
  with fUserCmdBut do
    begin
      Parent := fPanelRef;
      Caption := 'Send direct cmd';
      OnClick := fGUIuserCMDclick;
      width := 90;
      height := 20;
      top := fHelperLastBottomY;
      left := fPanelRef.Width - 95;
    end;


 fHelperLastBottomY := 88;

  fMemo := TMemo.Create(nil);
  with fMemo do
    begin
      Parent := fPanelRef;
      top := fHelperLastBottomY;
      left := 1;
      width := fPanelRef.Width div 2 - 2;
      height := fPanelRef.Height - fHelperLastBottomY - 30;
    end;

   fConsoleMemo := TMemo.Create(nil);
  with fConsoleMemo do
    begin
      Parent := fPanelRef;
      top := fHelperLastBottomY;
      left := 1 + fMemo.Width + 2;
      width := fPanelRef.Width div 2 - 2;
      height := fPanelRef.Height - fHelperLastBottomY - 30;
    end;

end;

procedure TZS1806_PTCInterface.GUIOnClickConfPort(Sender: TObject);
begin
  Finalize;
  if fComPort<>nil then fComPort.ShowSetupDialog;
end;

procedure TZS1806_PTCInterface.fIfaceLogProc(s: string);
begin
  if fLog<>nil then fLog.LogMsg('ZS-Iface:' + s );
  //add to iface memo!!!!!!

end;

procedure TZS1806_PTCInterface.fGUIuserCMDclick(Sender: TObject);
Var
  cmd: string;
begin
  if Sender<>fUserCmdBut then exit;
  if fUserCmdEdit=nil then Exit;
  cmd := fUserCmdEdit.Text;
  DoUserCmd( cmd, fGUIuserReceiveReply);
end;


procedure TZS1806_PTCInterface.fGUIuserReceiveReply(rep: string);
begin
  if fConsoleMemo<>nil then fConsoleMemo.Lines.Add( rep );
end;


procedure TZS1806_PTCInterface.fUserCmdProcessJob( j: TJobThreadSafe);
Var
  s: string;
  jdc: TJobDirectCommand;
begin
  if j=nil then Exit;
  if not (j is TJobDirectCommand) then exit;
  jdc := TJobDirectCommand( j );
  if not( Assigned(jdc.ReplyHandler)) then exit;
  s := IntToStr( jdc.elapsedMS );
  if jdc.ResultCode<> CJOK then s := s + 'FAILED! >'
  else s := s + 'OK >';
  s := s + jdc.Reply;
  jdc.ReplyHandler( s );
end;



procedure TZS1806_PTCInterface.DoUserCmd(cmd: string; logfunc: TLogProcedureThreadSafe);
Var
 j: TJobDirectCommand;
 cmdo: TPtcCmdObj;
begin
  if fConsoleMemo<>nil then fConsoleMemo.Lines.Add( DateTimeToStr( NOw) + ' > ' + cmd );
  //
  j := TJobDirectCommand.Create(nil, fUserCmdProcessJob);   //destroyed should be in MinJobManager after processing
  j.cmd := cmd;
  j.reply := '';
  j.elapsedMS := 0;
  j.ReplyHandler := logfunc;
  //
  cmdo := TPtcCmdObj.Create( CPtcJobDirectCmd );
  if cmdo<>nil then
    begin
      cmdo.o := j;
      fCmdQueue.Add(cmdo);
    end;
end;




procedure TZS1806_PTCInterface.RefreshGUI;
Var
  pc: TComPortConf;
  sl: TStringList;
begin
  if fPanelRef = nil then exit;
  if not fGUIassigned then exit;

  if fComPort<>nil then fComPort.getComPortConf(pc);
  if fInfoLabel<>nil then
    begin
      fInfoLabel.Caption := 'RS232 port ' + pc.Name + ':' + ' BR ' + pc.BR + ' connected: ' + BoolToStr( fComPort.IsPortOpen );
    end;
  if fMemo<>nil then
    begin
      fMemo.Lines.Clear;
      fMemo.Lines.Add( 'Thread: ' +  fAcquireThread.getThreadStatusStr );
      fMemo.Lines.Add( 'Interface READY: ' + BoolToStr( IsReady ) );
      fMemo.Lines.Add( 'Debug enabled: ' + BoolToStr( Debug ) );
      //fMemo.Lines.Add(  'Setpoint: ' + fDataRegistry.valstr[ IdHHPMAX  ] );
      //fMemo.Lines.Add(  'ModeHighLvl-RAW: ' + fDataRegistry.valstr[ IdM97HL_ModeRaw  ]);
      //fMemo.Lines.Add(  'ModeHighLvl-converted: ' + fDataRegistry.valstr[ IdM97HL_Mode  ] + ' ' + M97XXModeToStr( fM97xxIface.HLgetLastMode ) );
      fMemo.Lines.Add(  'ModeLowLvl: ' + fDataRegistry.valstr[ IdHHmodeStr  ] );
      fMemo.Lines.Add(  'OutputIsON: ' + fDataRegistry.valstr[ IdHHinputState  ] );
      //fMemo.Lines.Add(  'RemoteSensingON: ' + fDataRegistry.valstr[ IdM97HL_RemoteSENSE  ] );
      if friEnforceState<>nil then fMemo.Lines.Add(  'EnforceState: ' + friEnforceState.valstr );


      if debug then fMemo.Lines.Add(  'Cmd queue size: ' + IntToStr( fCmdQueue.Count ) );
      if debug then
        begin
          fMemo.Lines.Add( '');
          sl := TStringList.Create;
          if fDataRegistry<>nil then fDataRegistry.DumpAsStrignList( sl );
          fMemo.Lines.AddStrings( sl );
          //data
          sl.Destroy;
        end;
    end;

  //RefreshGUIObjects;
end;


//-------------

//hw specific features and configuration
//function TZS1806_PTCInterface.PotentioSetup(port:string; baud: longint): boolean;
//begin
//  ShoweMessage('not inmpleneted');
//end;

{procedure TZS1806_PTCInterface.SetupComPort;
begin
  if fComPort=nil then exit;
  if  fReady.valbool then ClientClose;
  fReady.valbool := false;
  fComPort.ShowSetupDialog;
end;

function TZS1806_PTCInterface.isPortOpen(): boolean;
begin
  Result := false;
  if fComport=nil then
    begin
      logmsg('isPortOpen:  comport=nil');
      exit;
    end;
  Result := fComPort.IsPortOpen;
end;

function TZS1806_PTCInterface.OpenComPort(): boolean;
begin
  Result := false;
  if fComport=nil then
    begin
      logmsg('TTBK8500Potentio.OpenComPort:  comport=nil');
      exit;
    end;
  Result := fComPort.OpenPort;
end;

procedure TZS1806_PTCInterface.CloseComPort;
begin
  if fComport=nil then
    begin
      logmsg('TTBK8500Potentio.CloseComPort:  comport=nil');
      exit;
    end;
  fComPort.ClosePort;
end;

function TZS1806_PTCInterface.getPortName(): string;
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  Result := pc.Name;
end;

procedure TZS1806_PTCInterface.setPortName(s: string);
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  pc.Name := s;
  fComPort.setComPortConf( pc );
end;


function TZS1806_PTCInterface.getBaudRate(): string;
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  Result := pc.BR;
end;

procedure TZS1806_PTCInterface.setBaudRate(brstr: string);
Var
  pc: TComPortConf;
begin
  fComPort.getComPortConf( pc );
  pc.BR := brstr;
  fComPort.setComPortConf( pc );
end;





function TZS1806_PTCInterface.GetLastMode(): TPotentioMode;
begin
  Result := M9 BKInternalModetoGeneral( lastmode );
end;


function TZS1806_PTCInterface.GetLastSp(): double;
begin
  Result := lastsetp;
end;
}





// ----------------------------------
// TBK8500 Potencio object



//////////////////////////////
{higher level commands...}
////////////////////////////////


//---------------------------------------



constructor TPtcCmdObj.Create(t:TPtcCmdType);
begin
  ftype := t;
  p1 := TMVVariantThreadSafe.Create(NAN);
  //p1.ChangeTo(CMVfloat);      //TMVDataobjectType
  p2 := TMVVariantThreadSafe.Create(NAN);
  o := nil;
  forceupdate := false;
end;

destructor TPtcCmdObj.Destroy;
begin
  if p1<>nil then p1.Destroy;
  if p2<>nil then p2.Destroy;
end;



end.

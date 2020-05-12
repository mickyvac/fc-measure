unit PLIxx_LowLevel_Interface;

interface

uses Classes, strutils, SysUtils,
     Logger, myutils, MyComPort, MyThreadUtils, MVConversion,
     COnfigManager, HWAbstractDevicesV3;

type

TPLIzzSpeed = (CHHZSspeed_Low, CHHZSspeed_Med, CHHZSspeed_High);


TPLIXXlowlevelIface = class (TObject)
    public
      constructor Create(datareg: TMyRegistryNodeObject; chanaddr: byte = 1; commtoutMS: longint = 1000; termstr: string = #10);
      destructor Destroy; override;
   published
    public
      procedure AssignComPort(Com: TComPortThreadSafe);
      procedure AssignLogProc(log: TLogProcedureThreadSafe);
    public
      function VerifyConnection: boolean;
      function RunInitializeSequence: boolean;
      function RunUserCommand(cmd: string; Var rep: string; Var elapsMS: longword): boolean;
    public
      function AcquireStatus: Boolean;  //data and status placed into registry, only most important status and data
	    function AcquireExtendedStatus: boolean; //data and status placed into registry, except of things read in AquireStatus reads also version string and etc...
      function getOutputOn: boolean; //returns true if output enabled
      function getMode: TPotentioMode; //returns actual working mode
      function getSetpoint: double; //returns setpoint for actual working mode (note this load has independent setpoints for each mode)
    public
      function SetUsetp(u: double): Boolean;
      function SetIsetp(i: double): Boolean;
      function SetPsetp(p: double): Boolean;
      function SetRsetp(r: double): Boolean;
      function SetModeCC: Boolean;
      function SetModeCV: Boolean;
      function SetModeCR: Boolean;
      function SetModeCP: Boolean;
      function SetIlimit(ss: double): Boolean;
      function SetUlimit(ss: double): Boolean;
      function SetInputON: Boolean;
      function SetInputOFF: Boolean;
    public
      function SendRST: boolean;
      function SwitchToLocalControl: boolean;        //GTL
      function GetQUESstatus(Var w: word): boolean;
      function SetControlSpeed(z: TPLIzzSpeed): boolean;       //SYST:SPE  SLOW|FAST|MED
      function GetIdInfo: boolean;  //CHAN 1;*IDN?CHAN 255;*IDN?;CHAN 1     //in initialize!
      //MEAS:EXT         //external analog control input!!!
      //SETup:ADC   //slow|fast  not availbale
      //SET?         //in initialize!      ex: =A:1,C1:50.0000,C2:150.0000,V1:20.0000,V2:60.0000,R1:13.3333,R2:4.4444,P1:1400.0000,P2:4200.0000;
      //SYST:CONT?
      //SYST:ERR?

      //*CLS
      //SYST:ERR?

    public
      procedure setDebug(b: boolean);
    private
      fComPort: TComPortThreadSafe;
      fLogProc: TLogProcedureThreadSafe;
      fTimeoutMS: longword;
      fTermStr: string;
      fDevAddr: byte;
      fDataReg: TMyRegistryNodeObject;
      fLogComm: boolean;
      fAddChanNr: TRegistryItem;
      fFormatS: TFormatSettings;
      fReplyList: TStringList;
  private
    procedure setDubug(const Value: boolean);
  public
      property ComTimeout: longword read fTimeoutMS write fTimeoutMS;
      property DevAddr: byte read fDevAddr write fDevAddr;
      property Data: TMyRegistryNodeObject read fDataReg;
      property Debug: boolean read fLogComm write setDubug;
      property TermStr: string read fTermStr write fTermStr;

  private
      function fFloatToStr( d:double): string;  //format flaot to acceptable format
      function ModeLowLVLToMode(s: string): TPotentioMode;
      procedure fLog(s: string);
      function ZSSendcmd(cmd: string; Var rep: string; Var elapsMS: longword; addchident: boolean = false): boolean;
      function ZSSendcmdNOreply(cmd: string; Var elapsMS: longword; addchident: boolean = false): boolean;
      function ZSSendcmdMulti(cmd: string; ncmd: integer; Var rep: TStringList; Var elapsMS: longword; addchident: boolean = false): boolean;
    end;



Const
  CIdPrefix = '_PLI_';

  IdHHAddChanNr: string = 'IdHHAddChanNr';
  IdHHAcquireStatQuery: string = 'IdHHAcquireStatQuery';
  IdHHAcquireStatReply: string = 'IdHHAcquireStatReply';

  IdHHvalU: string = CIdPrefix +'U';
  IdHHvalI: string = CIdPrefix +'I';
  IdHHvalP: string = CIdPrefix +'P';
  IdHHvalR: string = CIdPrefix +'R';
  IdHHinputState: string = CIdPrefix +'input';
  IdHHmodeStr: string = CIdPrefix +'Mode';
  IdHHmodeHighLVLasInt: string = CIdPrefix +'ModeHLVL';
  IdHHspU: string = CIdPrefix +'setpU';
  IdHHspI: string = CIdPrefix +'setpI';
  IdHHspP: string = CIdPrefix +'setpP';
  IdHHspR: string = CIdPrefix +'setpR';
  IdHHlimitU: string = CIdPrefix +'limitU';
  IdHHlimitI: string = CIdPrefix +'limitI';
  IdHHerror: string = CIdPrefix +'error';

  IdHHstrCtrlSpeed: string = CIdPrefix +'controlSpeed';

  IdHHstrIDsystem: string = CIdPrefix +'strIDsystem';
  IdHHstrIDcomm: string = CIdPrefix +'strIDcomm';
  IdHHstrDEVconf: string = CIdPrefix +'strDEVconf';

   //timestamps
  IdHHtimestampAcquire: string = CIdPrefix +'timestampAcq';


implementation

Uses Math, MyParseUtils;


constructor TPLIXXlowlevelIface.Create(datareg: TMyRegistryNodeObject; chanaddr: byte = 1; commtoutMS: longint = 1000; termstr: string = #10);
begin
  inherited Create;
  fComPort := nil;
  fLogProc := nil;
  fTimeoutMS := commtoutMS;
  fTermStr := termstr;
  fDevAddr := chanaddr;
  fDataReg := datareg;
  fLogComm := true;
  fAddChanNr := nil;
  GetLocaleFormatSettings(0,fFormatS);
  fFormatS.DecimalSeparator := '.';
  fFormatS.ThousandSeparator := ',';
  freplyList := TStringList.Create;
  if fDataReg<>nil then fAddChanNr := fDataReg.GetOrCreateItem( IdHHAddCHanNr );
end;


destructor TPLIXXlowlevelIface.Destroy;
begin
  fComPort := nil;
  fLogProc := nil;
  fDataReg := nil;
  fReplyList.Destroy;
  inherited;
end;


procedure TPLIXXlowlevelIface.AssignComPort(Com: TComPortThreadSafe);
begin
  fComPort := com;
end;

procedure TPLIXXlowlevelIface.AssignLogProc(log: TLogProcedureThreadSafe);
begin
  fLogProc := log;
end;



function TPLIXXlowlevelIface.ZSSendcmd(cmd: string; Var rep: string; Var elapsMS: longword; addchident: boolean = false): boolean;
begin
  Result := false;
  rep := '';
  if fComPort = nil then exit;
  //add terminating string and if set, prepend channel identificator
  //if addchident then cmd := 'CHAN '+IntToStr(fDevAddr)+ ';'  + cmd;
  cmd := cmd + fTermStr;  //!!!!!!!
  if fLogComm then fLog('>> '+ BinStrToPrintStr(cmd) );
  Result := fComPort.QueryHighLVLSingleTerm(cmd, rep, fTermStr, fTimeoutMS, elapsMS);
  if fLogComm then fLog( IntToStr( elapsMS ) + '  << '+ rep);
end;

function TPLIXXlowlevelIface.ZSSendcmdNOreply(cmd: string; Var elapsMS: longword; addchident: boolean = false): boolean;
begin
  Result := false;
  elapsMS := 0;
  if fComPort = nil then exit;
  //add terminating string and if set, prepend channel identificator
  //if addchident then cmd := 'CHAN '+IntToStr(fDevAddr)+ ';'  + cmd;
  cmd := cmd + fTermStr;  //!!!!!!!
  if fLogComm then fLog('>> '+ BinStrToPrintStr(cmd) );
  Result := fComPort.SendStringRaw(cmd);
end;



function TPLIXXlowlevelIface.ZSSendcmdMulti(cmd: string; ncmd: integer; Var rep: TStringList; Var elapsMS: longword; addchident: boolean = false): boolean;
begin
  Result := false;
  if rep=nil then exit;
  if fComPort = nil then exit;
  //add terminating string and if set, prepend channel identificator
  //if addchident then cmd := 'CHAN '+IntToStr(fDevAddr)+ ';'  + cmd;
  cmd := cmd + fTermStr;  //!!!!!!!
  if fLogComm then fLog('>> (N='+ IntToStr(ncmd) +') '+ BinStrToPrintStr(cmd) );
  Result := fComPort.QueryHighLvlGetMultiTerminators(cmd, rep, fTermStr, ncmd, fTimeoutMS, elapsMS);
  if fLogComm then fLog( IntToStr( elapsMS ) + '  << '+ rep.GetText);
end;



function TPLIXXlowlevelIface.SendRST: boolean;
Var
  cmd: string;
  elapsMS: longword;
begin
  cmd := '*RST';
  Result := ZSSendcmdNOreply(cmd, elapsMS, false);
end;


function TPLIXXlowlevelIface.SwitchToLocalControl: boolean;        //GTL
Var
  cmd: string;
  elapsMS: longword;
begin
  cmd := 'SYST:LOC';
  Result := ZSSendcmdNOreply(cmd, elapsMS, false);
end;


function TPLIXXlowlevelIface.RunInitializeSequence: boolean;
begin
  Result := GetIdInfo;
  fLog('RunInitializeSequence... result: ' + BoolToStr( Result ));
end;


function TPLIXXlowlevelIface.VerifyConnection: boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
  b: boolean;
begin
  //Result := true; exit;
  fLog('VerifyConnection...');
  Assert(fDataReg<>nil);
  cmd := '*IDN?';
  b := ZSSendcmd(cmd, rep, elapsMS, false);
  Result := b and SameStr( rep, fDataReg.valStr[ IdHHstrIDsystem ] );
  fLog('  got reply: ' + BinStrToPrintStr(rep) + ' CHECK=' + BoolToStr( Result) );
end;


function TPLIXXlowlevelIface.GetIdInfo: boolean;  //CHAN 1;*IDN?CHAN 255;*IDN?;CHAN 1     //in initialize!
Var
  cmd: string;
  elapsMS, elapsMS2, elapsMS3: longword;
  rep: string;
  b1, b2, b3: boolean;
begin
  Result := false;
  fLog('GetIdInfo...');
  if (fDataReg=nil) or (fReplyList=nil) then exit;
  //
  cmd := '*IDN?'; //cmd := 'CHAN 1;*IDN?';
  b1 := ZSSendcmd(cmd, rep, elapsMS, false);
  fLog('  cmd: ' + BinStrToPrintStr(cmd) + ' Result=' + BoolToStr(b1) + ' answer: ' + BinStrToPrintStr( rep ));
  //process rep
  //example
  //     HOECHERL&HACKL,ZS1806NV,12834D-0917,ZS_AI_07.02-F-04
  //     HOECHERL&HACKL,IF-RS232-RS485,0,ZS_SCPI_06.07-RS232_HW06
  //     =A:1,C1:50.0000,C2:150.0000,V1:20.0000,V2:60.0000,R1:13.3333,R2:4.4444,P1:1400.0000,P2:4200.0000;
  if b1 then
    begin
      fDataReg.SetOrCreateItem(IdHHstrIDsystem, rep);
      //parse dev conf
    end;
  //
  {
  cmd := 'CHAN 255;*IDN?;CHAN 1';
  b2 :=  ZSSendcmd(cmd, rep, elapsMS2, false);
  fLog('  cmd: ' + BinStrToPrintStr(cmd) + ' Result=' + BoolToStr(b2) + ' answer: ' + BinStrToPrintStr( rep ));
  if b2 then
    begin
      fDataReg.SetOrCreateItem(IdHHstrIDcomm, rep);
      //parse dev conf
    end;
  //    }
  cmd := 'SYST:VERS?';
  b3 := ZSSendcmd(cmd, rep, elapsMS3, false);
  fLog('  cmd: ' + BinStrToPrintStr(cmd) + ' Result=' + BoolToStr(b3) + ' answer: ' + BinStrToPrintStr( rep ));
  if b3  then
    begin
      fDataReg.SetOrCreateItem(IdHHstrDEVconf, rep);
    end;
  //
  Result := b1 and b2 and b3;
end;



function TPLIXXlowlevelIface.GetQUESstatus(Var w: word): boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
  b: boolean;
begin
  Assert(fDataReg<>nil);
  cmd := 'IDN?';
  b := ZSSendcmd(cmd, rep, elapsMS, false);
  Result := b and SameStr( rep, fDataReg.valStr[ IdHHstrIDsystem ] );
end;


function TPLIXXlowlevelIface.SetControlSpeed(z: TPLIzzSpeed): boolean;
//SYST:SPE  SLOW|FAST|MED
Var
  cmd: string;
  elapsMS: longword;
begin
  cmd := 'FUNC:SPE ';
  case z of
    CHHZSspeed_Low: cmd:= cmd + 'SLOW';
    CHHZSspeed_Med: cmd:= cmd + 'MED';
    CHHZSspeed_High: cmd:= cmd + 'FAST';
  end;
  Result := ZSSendcmdNOreply(cmd, elapsMS, false);
end;



procedure TPLIXXlowlevelIface.setDubug(const Value: boolean);
begin
  fLogComm := Value;
end;


function TPLIXXlowlevelIface.RunUserCommand(cmd: string; Var rep: string; Var elapsMS: longword): boolean;
begin

  Result := ZSSendcmd(cmd, rep, elapsMS);
end;



function TPLIXXlowlevelIface.AcquireStatus: Boolean;  //data and status placed into registry, only most important status and data
//volt curr, power, mode, input, limits,
Var
  cmd, reps: string;
  elapsMS: longword;
  xp, ncmd: integer;
  modestr, xs: string;
  b1, b2, bp: boolean;
begin
  Result := false;
  if (fDataReg=nil) or (fReplyList=nil) then exit;
  cmd := 'INP?;:FUNC:MODE?;:MEAS:CURR?;:MEAS:VOLT?;:MEAS:RES?;:MEAS:POW?;:CURR?;:VOLT?;:CURR:PROT?;:VOLT:PROT?';
  //do not add more, the reply may be mto long ...?
  ncmd := 10;
  //Result := ZSSendcmdMulti(cmd, ncmd, fReplyList, elapsMS, false); //pli returns as one repply terminated once
  b1 := ZSSendcmd(cmd, reps, elapsMS, false);
  //parse into stringlist
  fReplyList.Clear;
  bp := ParseStrSepStrlist(reps, ';', fReplyList);
  //SplitStrSimple(toklist[i].s, s1, s2);
  //process rep
  Result := b1 and bp;
  if Result then
    begin
      Assert( fReplyList.Count >= ncmd );
      xp := 0;
      fDataReg.SetOrCreateItem(IdHHinputState, fReplyList[xp]);  Inc(xp);
      modestr := fReplyList[xp]; Inc(xp);
      fDataReg.SetOrCreateItem(IdHHvalI, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHvalU, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHvalR, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHvalP, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHspI, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHspU, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHlimitI, fReplyList[xp]); Inc(xp);
      fDataReg.SetOrCreateItem(IdHHlimitU, fReplyList[xp]); Inc(xp);
      // mode
     fDataReg.SetOrCreateItem(IdHHmodeStr, modestr);
      fDataReg.SetOrCreateItem(IdHHmodeHighLVLasInt, Integer(ModeLowLVLToMode(modestr)) );
      //
      fDataReg.SetOrCreateItem(IdHHAcquireStatQuery, cmd);
      fDataReg.SetOrCreateItem(IdHHAcquireStatReply, fReplyList.GetText);
    end;

   //;:SYST:SPE?';//SYST:ERR?
end;


function TPLIXXlowlevelIface.AcquireExtendedStatus: boolean; //
Var
  cmd, rep: string;
  elapsMS: longword;
  b: boolean;
  b1,b2: boolean;
begin
  b1 := AcquireStatus;
  cmd := 'FUNC:SPE?;';
  b2 := ZSSendcmd(cmd, rep, elapsMS, false);
  fDataReg.SetOrCreateItem( IdHHstrCtrlSpeed, rep);
  Result := b1 and b2;
end;


function TPLIXXlowlevelIface.getOutputOn: boolean; //returns true if output enabled
begin
  Result := fDataReg.valBool[ IdHHinputState ];
end;

function TPLIXXlowlevelIface.getMode: TPotentioMode; //returns actual working mode
begin
  Result := TPotentioMode( fDataReg.valInt[ IdHHmodeHighLVLasInt ] );
end;


function TPLIXXlowlevelIface.getSetpoint: double; //returns setpoint for actual working mode (note this load has independent setpoints for each mode)
begin
  case getMode of
    CPotCC:   Result := fDataReg.valDouble[ IdHHspI ];
    CPotCV:   Result := fDataReg.valDouble[ IdHHspU ];
    CPotCR:   Result := fDataReg.valDouble[ IdHHspR ];
    CPotCP:   Result := fDataReg.valDouble[ IdHHspP ];
    else Result := NAN;
  end;
end;




function TPLIXXlowlevelIface.SetUsetp(u: double): Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'VOLT ' + fFloatToStr(u)+ ';:VOLT?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;



function TPLIXXlowlevelIface.SetIsetp(i: double): Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'CURR ' + fFloatToStr(i) + ';:CURR?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;


function TPLIXXlowlevelIface.SetPsetp(p: double): Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'POW ' + fFloatToStr(p) + ';:POW?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;

function TPLIXXlowlevelIface.SetRsetp(r: double): Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'RES ' + fFloatToStr(r) + ';:RES?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;


function TPLIXXlowlevelIface.SetModeCC: Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'FUNC:MODE CURR;:FUNC:MODE?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;

function TPLIXXlowlevelIface.SetModeCV: Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'FUNC:MODE VOLT;:FUNC:MODE?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);

end;

function TPLIXXlowlevelIface.SetModeCR: Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'FUNC:MODE:RES;:FUNC:MODE?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;

function TPLIXXlowlevelIface.SetModeCP: Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'FUNC:MODE:POW;:FUNC:MODE?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;

function TPLIXXlowlevelIface.SetIlimit(ss: double): Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'CURR:PROT ' + fFloatToStr(ss)+';:CURR:PROT?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;

function TPLIXXlowlevelIface.SetUlimit(ss: double): Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'VOLT:PROT ' + fFloatToStr(ss)+';:VOLT:PROT?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);

end;


function TPLIXXlowlevelIface.SetInputON: Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'INP ON;:INP?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;


function TPLIXXlowlevelIface.SetInputOFF: Boolean;
Var
  cmd, rep: string;
  elapsMS: longword;
begin
  cmd := 'INP OFF;:INP?';
  Result := ZSSendcmd(cmd, rep, elapsMS, false);
end;




{

*RST?

*IDN?   //ident
CHAN 255;*IDN?    //rs232 ident do not to forget change chan
CHAN 1;*IDN?

CURR:PROT:TRIP?



*STB?   //status byte

GTL   //swith to local

*TST?  /selftest nonzero error


 }



function TPLIXXlowlevelIface.fFloatToStr( d:double): string;  //format flaot to acceptable format
begin
  Result := FloatToStrF(d, ffExponent, 7, 2,fFormatS);  //precision - about single
end;


function TPLIXXlowlevelIface.ModeLowLVLToMode( s: string): TPotentioMode;  //format flaot to acceptable format
Var
 xs: string;
begin
  xs := UpperCase( TRIM(S));
  if  SameStr(xs, 'CURR') then Result := CPotCC
  else if SameStr(xs,  'VOLT') then  Result := CPotCV
  else if SameStr(xs,  'POW') then  Result := CPotCP
  else if SameStr(xs,  'RES') then  Result := CPotCR
  else Result := CPotERR;
end;



//*******************************************

procedure TPLIXXlowlevelIface.fLog(s: string);
begin
  if Assigned( fLogProc ) then fLogProc(s);
end;


procedure TPLIXXlowlevelIface.setDebug(b: boolean);
begin
  fLogComm := b;
  if fComPort<>nil then fComPort.Debug := b;
  
end;





end.

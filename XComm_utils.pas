unit XComm_utils;

interface

uses generics.collections, types, SyncObjs;

const
  //Flags
    XC_Flags_Answer           = $C0;
    XC_Flags_Command          = $80;
    XC_Flags_Event            = $40;
    XC_Flags_Multicast        = $08;
    XC_Flags_SuppressAnswer   = $04;

  //Registry
    XC_Registry_ReadRaw       = #$10;
    XC_Registry_Read          = #$11;
    XC_Registry_ReadByName    = #$12;
    XC_Registry_GetInfo       = #$13;
      RegistryInfo_Size           = #$00;
      RegistryInfo_Structure      = #$01;
      RegistryInfo_FindByName     = #$02;
      RegistryInfo_DefaultValue   = #$03;
      RegistryInfo_EnumsCount     = #$04;
      RegistryInfo_EnumLen        = #$05;
      RegistryInfo_EnumItems      = #$06;
    XC_Registry_WriteRaw      = #$14;
    XC_Registry_Write         = #$15;
    XC_Registry_WriteByName   = #$16;
    XC_Registry_Action        = #$17;
      RegistryAction_Backup       = #$01;  // <U32 password=0x12345678> -> <U8 res>
      RegistryAction_Restore      = #$02;  // <U32 password=0x12345678> -> <U8 res>
      RegistryAction_Log          = #$03;
      RegistryAction_SetDefaults  = #$04;


//function CRC16(s:ansistring):word;
function calcCrc(buffer:AnsiString):word;
function crc16(buffer:AnsiString;Polynom,Initial:word):word;
function getPacketSrc(packet:AnsiString):integer;
function getPacketDst(packet:AnsiString):integer;
function getPacketFlags(packet:AnsiString):integer;
function getPacketCMD(packet:AnsiString):integer;
function getPacketCRC(packet:AnsiString):integer;
function getPacketData(packet:AnsiString):AnsiString;

function ByteToBin(b:byte):AnsiString;
function BinToByte(s:AnsiString; index:integer=1):byte;
function WordToBin(w:word):AnsiString;
function BinToWord(s:AnsiString; index:integer=1):word;
function CardinalToBin(c:Cardinal):AnsiString;
function CardinalToBin_L(c:Cardinal):AnsiString;
function BinToCardinal(s:AnsiString; index:integer=1):Cardinal;
function BinToCardinal_L(s:AnsiString; index:integer=1):Cardinal;
function U24ToBin(c:Cardinal):AnsiString;
function BinToU24(s:AnsiString; index:integer=1):Cardinal;
function BinToSignedInt(s:AnsiString; index:integer=1; size:integer=1):Int64;
function FloatToBin(float:single):AnsiString;
function FloatToBin_L(float:single):AnsiString;
function BinToFloat(s:AnsiString; index:integer=1):single;
function BinToFloat_L(s:AnsiString; index:integer=1):single;

function RREd(d:double):double; //repair round error
function RREs(s:single):single; //repair round error

type
    TPacketType = (ptCommand, ptAckAnswer, ptNakAnswer, ptEvent, ptAscii, ptUnknown);
    TBroadcast = (bcNone, bcNormal, bcGroup);
    TPacketInfo = record
        packet:AnsiString;
        valid:boolean;
        typ:TPacketType;
        src,dst:integer;
        flags:byte;
        broadcast:TBroadcast;
        cmd:byte;
        dataLen:integer;
        data:AnsiString;
        tag:AnsiString;
        function parse(aPacket:AnsiString; aTag:AnsiString=''):boolean;
    end;

type TXComm = class
    queueCmd:TQueue<AnsiString>;
    queueAnswer:TQueue<TPacketInfo>;
    pending:AnsiString;
    src:integer;
    adr:integer;
    lock:TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    function makeCMD(flags,cmd:byte; data:ansistring=''):AnsiString;
    procedure enqueueCMD(cmd:byte; data:ansistring=''); overload;
    procedure enqueueCMD(flags,cmd:byte; data:ansistring=''); overload;
    function getFromCmdQueue:AnsiString;
    procedure clearAnswerQueue;
    procedure clear;
    function getFromAnswerQueue(var answer:TPacketInfo):boolean;
    procedure onAnswer(anAnswer:AnsiString);
end;

implementation

uses Math, StrUtils, kolUtils, SysUtils;

function TPacketInfo.parse(aPacket:AnsiString; aTag:AnsiString=''):boolean;
begin
    packet := aPacket;
    tag := aTag;
    if length(packet)>=8 then begin
        valid := true;
        dst := getPacketDst(aPacket);
        src := getPacketSrc(aPacket);
        flags := getPacketFlags(aPacket);
        if dst=0 then broadcast:=bcNormal
        else if flags AND $08 > 0 then broadcast:=bcGroup
        else broadcast := bcNone;
        cmd := getPacketCMD(aPacket);
        data := getPacketData(aPacket);
        dataLen := Length(data);

        typ := ptUnknown;
        if flags AND $10 = 0 then  begin
            case flags AND $E0 of
                $80       : typ := ptCommand;
                $C0       : typ := ptAckAnswer;
                $E0       : typ := ptNakAnswer;
                $40, $60  : typ := ptEvent;
            end;
        end else begin
            case flags of
                $30       : typ := ptAscii;
            end;
        end;

    end else begin
        FillChar(self, sizeof(TPacketInfo), 0);
    end;
    Result := valid;
end;

constructor TXComm.Create;
begin
    queueCmd := TQueue<AnsiString>.Create;
    queueAnswer := TQueue<TPacketInfo>.Create;
    lock := TCriticalSection.Create;
end;

destructor TXComm.Destroy;
begin
    lock.Free;
    queueCmd.Free;
    queueAnswer.Free;
end;

procedure TXComm.onAnswer(anAnswer:AnsiString);
var ans:TPacketInfo;
begin
    ans.parse(anAnswer, pending);
    lock.Enter;
    queueAnswer.Enqueue(ans);
    lock.Leave;
end;

function TXComm.makeCMD(flags,cmd:byte; data:ansistring=''):AnsiString;
begin
    result := '';
    result := result + WordToBin(adr AND $FFF OR (flags AND $F0 shl  8));
    result := result + WordToBin(src AND $FFF OR (flags AND $0F shl 12));
    result := result + AnsiChar(6+length(data));
    result := result + AnsiChar(cmd);
    result := result + data;
    result := result + WordToBin(calcCrc(result));
end;

procedure TXComm.enqueueCMD(cmd:byte; data:ansistring='');
begin
    queueCmd.Enqueue(makeCMD(XC_Flags_Command, cmd, data));
end;

procedure TXComm.enqueueCMD(flags,cmd:byte; data:ansistring='');
begin
    lock.Enter;
    queueCmd.Enqueue(makeCMD(flags,cmd, data));
    lock.Leave;
end;

procedure TXComm.clearAnswerQueue;
begin
    queueAnswer.Clear;
end;

procedure TXComm.clear;
begin
    queueAnswer.Clear;
    queueCmd.Clear;
    pending := '';
end;

function TXComm.getFromCmdQueue:AnsiString;
begin
    lock.Enter;
    if queueCmd.Count>0 then result := queueCmd.Extract
                        else result := '';
    pending := Result;
    lock.Leave;
end;

function TXComm.getFromAnswerQueue(var answer:TPacketInfo):boolean;
begin
    lock.Enter;
    result := queueAnswer.Count>0;
    if result then answer := queueAnswer.Extract;
    lock.Leave;
end;

function crc16(buffer:AnsiString;Polynom,Initial:word):word;
var i,j: Integer;
begin
  Result:=Initial;
  for i:=1 to Length(Buffer) do begin
    Result:=Result xor (ord(buffer[i]) shl 8);
    for j:=0 to 7 do begin
      if (Result and $8000)<>0 then Result:=(Result shl 1) xor Polynom
      else Result:=Result shl 1;
    end;
  end;
  Result:=Result and $ffff;
end;

function calcCrc(buffer:AnsiString):word;
begin
  result := crc16(buffer, $1021, $0000);
end;

function getPacketCMD(packet:AnsiString):integer;
begin
    result := -1;
    if length(packet)<6 then exit;
    result := byte(packet[6]);
end;

function getPacketCRC(packet:AnsiString):integer;
begin
    result := -1;
    if length(packet)<6 then exit;
    result := BinToWord(packet, length(packet)-1);
end;

function getPacketSrc(packet:AnsiString):integer;
begin
    result := -1;
    if length(packet)<6 then exit;
    result := BinToWord(packet, 3) AND $FFF;
end;

function getPacketDst(packet:AnsiString):integer;
begin
    result := -1;
    if length(packet)<6 then exit;
    result := BinToWord(packet, 1) AND $FFF;
end;

function getPacketFlags(packet:AnsiString):integer;
begin
    result := -1;
    if length(packet)<6 then exit;
    result := BinToByte(packet, 1) AND $F0 + (BinToByte(packet, 3) AND $F0) shr 4;
end;

function getPacketData(packet:AnsiString):AnsiString;
begin
    result := '';
    if length(packet)<6 then exit;
    result := copy(packet, 7, length(packet)-8);
end;



function WordToBin(w:word):AnsiString;
begin
    result := AnsiChar(Hi(w)) + AnsiChar(Lo(w));
end;

function BinToWord(s:AnsiString; index:integer=1):word;
begin
    if index+1<=length(s) then
        result := byte(s[index])*256 + byte(s[index+1])
    else if index<=length(s) then
        result := byte(s[index+1])
    else
        result := 0;
end;

function ByteToBin(b:byte):AnsiString;
begin
    result := AnsiChar(b);
end;

function BinToByte(s:AnsiString; index:integer=1):byte;
begin
    if length(s)<index then result := 0
                       else result := byte(s[index]);
end;

function CardinalToBin(c:Cardinal):AnsiString;
begin
    result :=
        AnsiChar((c shr 24) and $ff) +
        AnsiChar((c shr 16) and $ff) +
        AnsiChar((c shr  8) and $ff) +
        AnsiChar((c       ) and $ff);
end;

function CardinalToBin_L(c:Cardinal):AnsiString;
begin
    result :=
        AnsiChar((c       ) and $ff) +
        AnsiChar((c shr  8) and $ff) +
        AnsiChar((c shr 16) and $ff) +
        AnsiChar((c shr 24) and $ff);
end;

function BinToCardinal(s:AnsiString; index:integer=1):Cardinal;
var i:integer;
begin
    s := copy(s, index, 4);
    for i:=length(s)+1 to 4 do s:=#0+s;

    result := Byte(s[1]) * $01000000
            + Byte(s[2]) * $00010000
            + Byte(s[3]) * $00000100
            + Byte(s[4]) * $00000001;
end;

function BinToCardinal_L(s:AnsiString; index:integer=1):Cardinal;
var i:integer;
begin
    s := copy(s, index, 4);
    for i:=length(s)+1 to 4 do s:=s+#0;

    result := Byte(s[4]) * $01000000
            + Byte(s[3]) * $00010000
            + Byte(s[2]) * $00000100
            + Byte(s[1]) * $00000001;
end;

function U24ToBin(c:Cardinal):AnsiString;
begin
    result :=
        AnsiChar((c shr 16) and $ff) +
        AnsiChar((c shr  8) and $ff) +
        AnsiChar((c       ) and $ff);
end;

function BinToU24(s:AnsiString; index:integer=1):Cardinal;
var i:integer;
begin
    s := copy(s, index, 4);
    for i:=length(s)+1 to 4 do s:=#0+s;

    result := Byte(s[1]) * $00010000
            + Byte(s[2]) * $00000100
            + Byte(s[3]) * $00000001;
end;

function BinToSignedInt(s:AnsiString; index:integer=1; size:integer=1):Int64;
var i:integer;
    neg:boolean;
begin
    Result := 0;
    s := copy(s, index, size);
    if s='' then exit;
    neg := byte(s[1]) AND $80 > 0;
    s := AnsiString(StrToHexStr(s,''));
    if neg then
        for i:=(length(s) div 2)+1 to 8 do s:='FF'+s;
    result := StrToInt64('$'+string(s));
end;

function FloatToBin(float:single):AnsiString;
var i:integer;
begin
    SetLength(result, 4);
    for i:=0 to 3 do result[i+1] := (PAnsiChar(@float) + i)^;
    result := ReverseAnsiString(result);
end;

function FloatToBin_L(float:single):AnsiString;
var i:integer;
begin
    SetLength(result, 4);
    for i:=0 to 3 do result[i+1] := (PAnsiChar(@float) + i)^;
end;

function BinToFloat(s:AnsiString; index:integer=1):single;
begin
    s := ReverseAnsiString(copy(s, index, 4));
    try
        result := PSingle(@s[1])^;
    except
        result := NaN;
    end;
end;

function BinToFloat_L(s:AnsiString; index:integer=1):single;
begin
    result := PSingle(@s[1])^;
end;

//------------------------------------------------------------------------------
function RREd(d:double):double; //repair round error
//------------------------------------------------------------------------------
begin
    if IsNan(d) then begin result := d; exit; end;
    if d=0 then result := 0
           else result := RoundTo(d, round(Log10(abs(d))-11));
end;

//------------------------------------------------------------------------------
function RREs(s:single):single; //repair round error
//------------------------------------------------------------------------------
begin
    if IsNan(s) then begin result := s; exit; end;
    if s=0 then result := 0
           else result := RoundTo(s, EnsureRange(round(Log10(abs(s))-6),-20,20));
end;


initialization

finalization

end.

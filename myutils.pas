unit myutils;

interface

uses Classes, Graphics, DateUtils;

type TBytes = array of byte;

procedure MyDestroyAndNil(Var o); //safely checks for nil/ destroyes object, and sets var to NIL

// --- general utils
function BitIsSet(w: longint; bitnr: byte): boolean;

function IfThenElse(b: boolean; d1: double; d2: double): double; overload;
function IfThenElse(b: boolean; i1: longint; i2: longint): longint; overload;
function IfThenElse(b: boolean; res1: string; res2: string): string; overload;

//function UpdateFlagInSet;

function Min(a, b: real): real;
function Max(a, b: real): real;


//make sure that val is inseide provided range - and returns true if it was OK inside or false if it was outside
function MakeSureIsInRange(Var n: longint; low: longint; high: longint): boolean; overload;
function MakeSureIsInRange(Var d: double; low: double; high: double): boolean; overload;
function MakeSureIsInRange(Var n: byte; low: byte; high: byte): boolean; overload;
function MakeSureIsInRange(Var n: word; low: word; high: word): boolean; overload;


function mymin(a, b: double): double; //expect NAN value possible
function mymax(a, b: double): double; //expect NAN value possible


function CompareEpsilonAbiggerB(A, B, eps: double): boolean; //expect NAN value possible
function CompareEpsilonAequalB(A, B, eps: double): boolean; //expect NAN value possible

function ConvertPsiToBar( ppsi: double ): double;

function PointerToStr( P: Pointer): string;

function BoolToDouble( b: boolean): double;
function CharToByte(c: char): byte;
function AnsiCharToByte(c: Ansichar): byte;
function ByteToChar(n: byte): char;
function ByteToAnsiChar(n: byte): Ansichar;
function ByteToHexStr(n: byte): string;

function HexStrToByte(s: string): byte;
function HexStrToLongwordLE(s: string): LongWord;
function HexStrToLongwordBE(s: string): LongWord;


procedure SingleTo4Bytes(f: single; Var b1, b2, b3, b4: byte);
function FourBytesToSingle(b1, b2, b3, b4: byte): single;

//the following funciton taken from XcommUtils.pas by Jiri Libra
function FloatToBinLE(float:single): AnsiString; overload;
procedure SingleToBinArrayLE(float:single; Var b: TBytes);

function BinToFloatLE(s: Ansistring; pos: word): single; overload;
function BinToFloatLE(Var b: array of byte; pos: word): single; overload;

function BinToUint32LE(Var b: array of byte; pos: word): longword;
function BinToUint16LE(Var b: array of byte; pos: word): word;
function BinToByte(Var b: array of byte; pos: word): byte;

procedure DelayMS( d:longint );

function DateTimeMStoStr( t: tDateTime ): string;
function DateTimeToStrMV( t: tDateTime ): string;  //checks for NAN! system fucntion crashes with NAN
function TimeDeltaNow( t0: tDateTime ): TDateTime;
function TimeDeltaNowMS( t0: tDateTime ): longword;
function DateTimeToMS( t: tDateTime ): longword;

function TimeDeltaTICKgetT0: longword;
function TimeDeltaTICKNowMS( ticks0: longword): longword;

function Backslash: string;

procedure StrAdd(Var s: string; a: string);


Function TrimHexaStrLowercase(s: string): string;
Function MyHexStrToBin(hs: string): string;
Function MyWordToBinLE(w: word): string;

function BinaryStrTostring( a: AnsiString ): string;
function BinaryArrayToBinStr(a: array of byte; n: word): Ansistring;
function BinaryArrayToHexStr(a: array of byte; n: word): string;
procedure BinStrToBinArray(databin: string; Var a: TBytes);

procedure SetLenAndZeroBytes(Var a: TBytes; n: integer);
procedure ByteArrayFromWordLE(Var a: TBytes; w: word);
procedure ByteArrayFromWordBE(Var a: TBytes; w: word);



function ArrayToString(Var a: array of double; n: word): string; overload;
function ArrayToString(Var a: array of longint; n: word): string; overload;

function DynArrayToStr(Var a: array of double): string; overload;
function DynArrayToStr(Var a: array of longint): string; overload;


function AddLeadingZeroes(const aNumber: longint; const  Length : integer) : string;
function DateNowToStr: string;
function MyTrim(s: string): string;
procedure CopyPcharToStr(Var s: string; Buf: pchar; DataLen: integer);

function BinCharToStrPrint( ch: char): string;
function BinStrToPrintStr( s: string): string;
function BinStrToPrintStrHexa( s: string): string;

function GetCharFromStrSafe(s: string; n: longword): char;

function MakeSureDirExist( path: string ): boolean;

//procedure IncText( Var t: string);


procedure MyProcessMessages;
 //should not use ApplicationProcessMessages inside a thread -> so I use my own loop fro processing
 //found here:  http://stackoverflow.com/questions/15467263/how-do-i-forcibly-process-messages-inside-a-thread (Remy Lebeau)



procedure GetSerialPortsOnSystem(var Strings: TStrings);
{return list of strings contanining available com portr device on system
maybe works OK only on Windows}


procedure HSLtoRGB(H,S,L: double; Var rr,gg,bb: byte); //hue, saturation, lumonsity - h,s,l: from <0,1>
function HSLtoTColor(H,S,L: double): TColor;

function GenerateRainbowColor(step: integer; total: integer): TColor;




function CRC16CCITT(bytes: TBytes): Word;

function CRC16ModbusA(msg: TBytes): Word; overload;
function CRC16ModbusA(msg: string): Word; overload;
function CRC16ModbusStrBE(msg: TBytes): string; overload;
function CRC16ModbusStrBE(msg: string): string; overload;



//some colors    $00BBGGRR   (hexa)
const
  clOrange = $0000A5FF;   //RGB #FFA500
  clGold =   $0000D7FF;

  clVeryLightRed = $00DEDEFA;
  clVeryLightBlue = $00FADEDE;
  clDesaturatedYellow = $0092FFFF;

  CMyAlphaNumSet = ['A'..'Z', 'a'..'z', '0'..'9'] + ['+', '-', '.', ','] + [' '..'~'];  //  [' '..'~'] #32 .. #126 all printable chars


implementation

Uses SysUtils, StrUtils, Math, Windows;


function IfThenElse(b: boolean; d1: double; d2: double): double;
begin
  if b then Result := d1 else Result := d2;
end;

function IfThenElse(b: boolean; i1: longint; i2: longint): longint;
begin
  if b then Result := i1 else Result := i2;
end;

function IfThenElse(b: boolean; res1: string; res2: string): string;
begin
  if b then Result := res1 else Result := res2;
end;



function BitIsSet(w: longint; bitnr: byte): boolean;
Var
 x: longint;
begin
  x := 1 shl bitnr;
  Result := (w and x) > 0;
end;


function Min(a, b: real): real;
begin
  Result := b;
  if (a<=b) then Result := a;
end;


function Max(a, b: real): real;
begin
  Result := b;
  if (a>=b) then Result := a;
end;

function mymin(a, b: double): double; //expect NAN value possible
begin
  Result := a;
  if isnan(a) then Result := b
  else if isnan(b) then Result := a
  else
    if (b<a) then Result := b;
end;

function mymax(a, b: double): double; //expect NAN value possible
begin
  Result := a;
  if isnan(a) then Result := b
  else if isnan(b) then Result := a
  else
    if (b>a) then Result := b;
end;


function CompareEpsilonAbiggerB(A, B, eps: double): boolean; //expect NAN value possible
begin
  Result := false;
  if isNAN(a) or isNAN(b) or IsNAN(eps) then exit;
  if (A-eps)>B then Result := true;
end;


function CompareEpsilonAequalB(A, B, eps: double): boolean; //expect NAN value possible
begin
  Result := false;
  if isNAN(a) or isNAN(b) or IsNAN(eps) then exit;
  if (abs(A-B) < abs(eps)) then Result := true;
end;


function ConvertPsiToBar( ppsi: double ): double;
Const
  CPsiPa = 14.503773773; //14.695948804;
begin
  Result := ppsi / CPsiPa - 1.0;
end;


function PointerToStr( P: Pointer): string;
begin
  Result := IntToHex( Integer(P), 4);
end;

function BoolToDouble( b: boolean): double;
begin
  Result := 0.0;
  if b then Result := 1.0
end;


procedure StrAdd(Var s: string; a: string);
begin
  s := s + a;
end;

function CharToByte(c: char): byte;
Var
  code: byte;
begin
  code := ord(c);
  Result := code;
end;

function AnsiCharToByte(c: Ansichar): byte;
Var
  code: byte;
begin
  code := ord(c);
  Result := code;
end;


function ByteToChar(n: byte): char;
Var
  code: byte;
begin
  Result := chr(n);
end;

function ByteToAnsiChar(n: byte): Ansichar;
Var
  code: byte;
begin
  Result := Ansichar( chr(n) );
end;



function ByteToHexStr(n: byte): string;
begin
  Result := IntToHex(n, 2);   //bintohex
end;

function HexStrToByte(s: string): byte;
Var
  len, x: longint;
  buf: char;
begin
  len := length(s);
  //setlength(buf, len);
  try
    x := HexToBin(Pchar(s), @buf, 1);
    Result := CharToByte( buf );
  except
    Result := 0;
  end;
end;

function HexStrToLongwordLE(s: string): LongWord;
Var
  len, x: longint;
  buf: char;
  xs, fs: string;
begin
  xs := MyHexStrToBin(s);
  len := length(xs);
  case length(xs) of
    3: fs := #0+ xs;
    2: fs := #0#0+ xs;
    1: fs := #0#0#0+ xs;
    0: fs := #0#0#0#0;
    else fs := leftstr(xs, 4);
  end;
  Assert( (length(fs)=4) and (len>=0) );
  Result := (Ord(fs[1]) shl 24) + (Ord(fs[2]) shl 16) + (Ord(fs[3]) shl 8) + + (Ord(fs[4]));
end;

function RightFillStr(s: string; n: longword; ch: char): string;
//adds chars or srops stri to have length exactly n
Var
  len, x: longword;
  ss: string;
begin
  len := length(s);
  Result := s;
  if len<n then
    begin
      ss := '';
      for x := len to n - 1  do ss := ss + ch;
      Result := s + ss;
    end;
  if len>n then Setlength(Result, n);
end;



function HexStrToLongwordBE(s: string): LongWord;
Var
  len, x: longint;
  buf: char;
  xs, fs: string;
begin
  xs := MyHexStrToBin(s);
  fs := RightFillStr(xs, 4, #0);
  len := length(xs);
  Assert( (length(fs)=4) and (len>=0) );
  Result := (Ord(fs[4]) shl 24) + (Ord(fs[3]) shl 16) + (Ord(fs[2]) shl 8) + (Ord(fs[1]));
end;



procedure SingleTo4Bytes(f: single; Var b1, b2, b3, b4: byte);
type
  a = array[ 1 .. 4] of byte;
var
  x : single; y : a;
begin
  x := f;
  y := a(x);
  b1 := y[1];
  b2 := y[2];
  b3 := y[3];
  b4 := y[4];
end;


function FourBytesToSingle(b1, b2, b3, b4: byte): single;
type
  a = array[ 1 .. 4] of byte;
var
  x : single;
  y : a;
begin
  y[1] := b1;
  y[2] := b2;
  y[3] := b3;
  y[4] := b4;
  x := single(y);
  Result := x;
end;


function FloatToBinLE(float:single):AnsiString;
var i:integer;
begin
    SetLength(result, 4);
    for i:=0 to 3 do result[4-i] := (PAnsiChar(@float) + i)^;
end;

procedure SingleToBinArrayLE(float:single; Var b: TBytes);
var i:integer;
begin
  SetLength(b, 4);
  for i:=0 to 3 do b[3-i] := Ord( (PAnsiChar(@float) + i)^ );
end;

function BinToFloatLE(s: Ansistring; pos: word): single;
type
  a = array[ 1 .. 4] of byte;
var
  y : a;
begin
  Result := NAN;
  if (length(s)< pos + 3) then exit;
  y[1] := ord(s[pos+3]);
  y[2] := ord(s[pos+2]);
  y[3] := ord(s[pos+1]);
  y[4] := ord(s[pos]);
  Result := single(y);
end;

function BinToFloatLE(Var b: array of byte; pos: word): single;
type
  a = array[1 .. 4] of byte;
var
  y : a;
begin
  Result := NAN;
  if (length(b)< pos + 3 + 1) then exit;
  y[1] := b[pos+3];
  y[2] := b[pos+2];
  y[3] := b[pos+1];
  y[4] := b[pos];
  Result := single(y);
end;


function BinToUint32LE(Var b: array of byte; pos: word): longword;
begin
  Result := 0;
  if length(b)< (pos + 3 + 1) then exit;
  Result := b[pos+3] + (b[pos+2]) shl 8 + (b[pos+1]) shl 16 + (b[pos+0]) shl 24;
end;

function BinToUint16LE(Var b: array of byte; pos: word): word;
begin
  Result := 0;
  if length(b)< (pos + 2) then exit;
  Result := b[pos+1] + (b[pos]) shl 8;
end;

function BinToByte(Var b: array of byte; pos: word): byte;
begin
  Result := 0;
  if length(b)< (pos + 1) then exit;
  Result := b[pos];
end;

function MakeSureIsInRange(Var n: longint; low: longint; high: longint): boolean;
//make sure that val is inseide provided range - and returns true if it was OK inside or false if it was outside
begin
  Result := true;
  if n<=low then begin n:= low; Result := false; end;
  if n>=high then begin n:= high; Result := false; end;
end;

function MakeSureIsInRange(Var n: byte; low: byte; high: byte): boolean;
//make sure that val is inseide provided range - and returns true if it was OK inside or false if it was outside
begin
  Result := true;
  if n<=low then begin n:= low; Result := false; end;
  if n>=high then begin n:= high; Result := false; end;
end;

function MakeSureIsInRange(Var n: word; low: word; high: word): boolean;
//make sure that val is inseide provided range - and returns true if it was OK inside or false if it was outside
begin
  Result := true;
  if n<=low then begin n:= low; Result := false; end;
  if n>=high then begin n:= high; Result := false; end;
end;


function MakeSureIsInRange(Var d: double; low: double; high: double): boolean;
//make sure that val is inseide provided range - and
//returns true if it was OK inside or false if it was outside
begin
  Result := true;
  if d<=low then begin d := low; Result := false; end;
  if d>=high then begin d := high; Result := false; end;
end;



procedure DelayMS( d: longint );
Var
  n: TDateTime;
  i: integer;
begin
    n := Now + d / 24/3600/1000;
    i := 1;
    while (Now < n) do i := i * 1;
end;




function DateTimeMStoStr( t: tDateTime ): string;
begin
  Result := IntToStr( Round( t * 24 * 3600 * 1000) );
end;


function DateTimeToStrMV( t: tDateTime ): string;  //checks for NAN! system fucntion crashes with NAN
begin
  try
    begin
     if not IsNan(t) then DateTimeToStr(t)
     else Result := 'NAN';
    end;
  except
    on E: Exception do Result := 'NAN';
  end;
end;


function TimeDeltaNow( t0: tDateTime ): TDateTime;
begin
  Result := Now() - t0;
end;


function DateTimeToMS( t: tDateTime ): longword;
begin
  try
    Result := Round( t * 24 * 3600 * 1000);
  except
    Result := 0;
  end;
end;

function TimeDeltaNowMS( t0: tDateTime ): longword;
begin
  try
    Result := MilliSecondsBetween( Now(), t0);
  except
    Result := 0;
  end;
end;

function TimeDeltaTICKgetT0: longword;
begin
  Result := GetTickCount;
end;

function TimeDeltaTICKNowMS( ticks0: longword): longword;
Var
 w: longword;
begin
  w := GetTickCount;
  if w>ticks0 then Result := GetTickCount - ticks0 else Result := 0;
end;




//*******************************


Function TrimHexaStrLowercase(s: string): string;
Var
 i, len: integer;
begin
  Result := '';
  for i:=1 to length(s) do
    begin
      if s[i] in ['0'..'9','a'..'f'] then Result := Result + s[i]      //set
      else if s[i] in ['A'..'F'] then  Result := Result + LowerCase(s[i])
      else if s[i] = '.' then Result := Result + '0';  // . means 0
    end;
end;



Function MyHexStrToBin(hs: string): string;
Var
 s, r: string;
 len, i: longint;
begin
  s := TrimHexaStrLowercase(hs);
  len := length(s) div 2;
  setlength(r, len);
  for i:=0 to len-1 do r[i] := #0;
  HextoBin(PChar(s), Pchar(r), len);
  Result := r;
end;

Function MyWordToBinLE(w: word): string;
Var
 s, r: string;
begin
  Result := chr(w shr 8) + chr(w and $FF);
end;








//-------------------


function BinaryArrayToBinStr(a: array of byte; n: word): Ansistring;
Var
    c: byte;
    i, ll: longint;
    s: Ansistring;
begin
  s := '';
  for i:=0 to n-1 do
  begin
    s := s + chr(a[i]);
  end;
  Result := s;
end;

function BinaryArrayToHexStr(a: array of byte; n: word): string;
Var
    c: byte;
    i: longint;
    s, s1: string;
begin
  s := '';
  for i:=0 to n-1 do
  begin
    s1 := IntToHex( a[i], 2 );
    if a[i] = 0 then s1 := '..';
    s := s + s1 + ' ';
  end;
  Result := s;
end;

procedure BinStrToBinArray(databin: string; Var a: TBytes);
Var
    i: longint;
begin
  setlength(a, length(databin) );
  for i:=0 to length(databin)-1 do
  begin
    a[i] := ord(databin[i+1]);
  end;
end;


procedure SetLenAndZeroBytes(Var a: TBytes; n: integer);
Var
    i: longint;
begin
  setlength(a, n);                             //tbytes
  for i:=0 to n-1 do a[i] := 0;
end;



procedure ByteArrayFromWordLE(Var a: TBytes; w: word);
begin
  setlength(a, 2);                             //tbytes
  a[0] := w shl 8;
  a[1] := w and $FF;
end;

procedure ByteArrayFromWordBE(Var a: TBytes; w: word);
begin
  setlength(a, 2);                             //tbytes
  a[0] := w and $FF;
  a[1] := w shl 8;
end;




function BinaryStrTostring( a: AnsiString ): string;
Var
    c: byte;
    i, ll: longint;
    s, s1: string;
begin
  s := '';
  ll := length(a);
  for i:=0 to ll-1 do
  begin
    c := ord(a[i]);
    s1 := IntToHex( c, 2 );
    if c = 0 then s1 := '..';
    s := s + s1 + ' ';
  end;
  Result := s;
end;


function ArrayToString(Var a: array of double; n: word): string;
var i: word;
begin
  Result := '[';
  for i:=0 to n-1 do
    begin
      Result := Result + FloatToStrF(a[i], ffFixed, 4,3);
      if i<n-1 then Result := Result +';';
    end;
  Result := Result + ']';
end;

function ArrayToString(Var a: array of longint; n: word): string;
var i: word;
begin
  Result := '[';
  for i:=0 to n-1 do Result := Result + IntToStr(a[i])+';';
  Result := Result + ']';
end;



function DynArrayToStr(Var a: array of double): string; overload;
var i, len: longint;
begin
  Result := '[';
  len := Length(a);
  for i:=0 to len-1 do
    begin
      Result := Result + FloatToStrF(a[i], ffFixed, 4,3);
      if i<len-1 then Result := Result +';';
    end;
  Result := Result + ']';
end;

function DynArrayToStr(Var a: array of longint): string; overload;
var i, len: longint;
begin
  Result := '[';
  len := Length(a);
  for i:=0 to len-1 do
    begin
      Result := Result + IntToStr(a[i])+',';
      if i<len-1 then Result := Result +',';
    end;
  Result := Result + ']';
end;

function AddLeadingZeroes(const aNumber: longint; const  Length : integer) : string;
begin
   result := SysUtils.Format('%.*d', [Length, aNumber]) ;
end;


function DateNowToStr: string;
Var
  format: TFormatSettings;
  dat : TDateTime;
begin
  GetLocaleFormatSettings(0, format);
  format.LongDateFormat := 'yyyy-mm-dd';
  format.ShortDateFormat := 'yyyy-mm-dd';
  format.ShortTimeFormat := '';
  dat := Now;
  Result := DateToStr(dat,format);
end;

function MyTrim(s: string): string;
Var
 s1, s2: string;
begin
  s1 := Trim(s);
  s2 := AnsiReplaceStr(s1, '/', '');
  s1 := s2;
  s2 := AnsiReplaceStr(s1, '\', '');
  s1 := s2;
  s2 := AnsiReplaceStr(s1, '*', '');
  s1 := s2;
  s2 := AnsiReplaceStr(s1, '?', '');
  s1 := s2;
  s2 := AnsiReplaceStr(s1, '.', '');
  s1 := s2;
  Result := Trim(s1);
end;

function MyTrimWhite(s: string): string;
Var
 s1, s2: string;
begin
  s1 := Trim(s);
  Result := Trim(s1);
end;



procedure CopyPcharToStr(Var s: string; Buf: pchar; DataLen: longint);
Var i: longint;
begin
  s := '';
  for i:=0 to datalen-1 do
    begin
      s := s + (buf+i)^;
    end;
end;

function BinCharToStrPrint( ch: char): string;
begin
  if ch in CMyAlphanumSet then Result := '''' + ch + ''''
  else
    Result := '#'+IntToStr( Ord(ch) );
end;


function BinStrToPrintStr( s: string): string;
Var
  i, n: longword;
  lastprintable, lastnonprintable: boolean;
  ch: char;
begin
  n := length(s);
  Result := '';
  if n=0 then exit;
  lastprintable := false;
  lastnonprintable := false;
  for i:=1 to n do
    begin
      ch := s[i];
      if (ch in CMyAlphanumSet) or ( (Ord(ch)>=32) and (ord(ch)<=126) ) then
        begin
          if not lastprintable then Result := Result + '''' + ch else Result := Result + ch;
          lastprintable := true;
          lastnonprintable := false;
        end
      else
        begin
          if lastprintable then Result := Result + '''';
          Result := Result + '#'+IntToStr( Ord(ch) );
          lastprintable := false;
          lastnonprintable := true;
        end;
    end;
  if lastprintable then Result := Result + ''''; //finishing aposstrophe
end;


function BinStrToPrintStrHexa( s: string): string;
Var
  i, n: longword;
  lastprintable, lastnonprintable: boolean;
  ch: char;
begin
  n := length(s);
  Result := '';
  if n=0 then exit;
  for i:=1 to n do
    begin
      Result := Result + IntToHex( Ord(s[i]), 2) + ' ';
    end;
end;



function GetCharFromStrSafe(s: string; n: longword): char;
begin
  if length(s)<n then
    begin
      Result := #0;
      exit;
    end;
  Result := s[n];
end;


function Backslash: string;
begin
  Result := '\';
end;

function MakeSureDirExist( path: string ): boolean;
begin  //MkDir
  Result := false;
  {$I-}
  if not DirectoryExists(path) then
    begin
      //create directory
      if not CreateDir(path) then exit;
      //sysutils: function ForceDirectories(Dir: string): Boolean;
    end;
  if (IoResult <> 0) then  exit;
  {$I+}
  Result := true;
end;


procedure MyProcessMessages;
 //but should not use ApplicationProcessMessages inside a thread -> so I use my own loop fro processing
 //found here:  http://stackoverflow.com/questions/15467263/how-do-i-forcibly-process-messages-inside-a-thread (Remy Lebeau)
var
  Msg: TMsg;
begin
      while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
end;



procedure GetSerialPortsOnSystem(var Strings: TStrings);
//Var
  //listcom: string;
  //i: integer;
begin
{$IFDEF WINDOWS}
  //listcom := GetSerialPortNames;  //comma separated list
  //
  // ExtractStrings
{$ENDIF}
end;

function HSLtoTColor(H,S,L: double): TColor;
Var r,g,b: byte;
 function RGB(r,g,b: byte): TColor;
 begin
   Result :=  r + g * 256 + b * 256 * 256;
 end;

begin
  HSLtoRGB(H,S,L, r,g,b);
  Result := RGB(r, g, b);
end;


procedure HSLtoRGB(H,S,L: double; Var rr,gg,bb: byte);
//HSL = hue, saturation, lumonsity: from <0,1>
Var
  r,g,b: double;
  hh: double;
  C, X, m, frac, p, q: double;
  sextant: byte;
   function hue2rgb(p, q, t: double): double;
   begin
            if(t < 0) then t := t + 1;
            if(t > 1) then t := t - 1;
            Result := p;
            if(t < 1/6) then Result := p + (q - p) * 6 * t
            else if(t < 1/2) then Result := q
            else if(t < 2/3) then Result := p + (q - p) * (2/3 - t) * 6;
   end;
begin
    if (S <= 0) then
      begin
        r := L;
        g := L;
        b := L;
        // achromatic
      end
    else
      begin
        q := IfThen((L < 0.5), (L + L * S),  (L + S - L * S) );
        p := 2 * L - q;
        //
        r := hue2rgb(p, q, H + 1/3);
        g := hue2rgb(p, q, H);
        b := hue2rgb(p, q, H - 1/3);
      end;
  //out
  rr := trunc( r * 255 );
  gg := trunc( g * 255 );
  bb := trunc( b * 255 );
end;



function GenerateRainbowColor(step: integer; total: integer): TColor;
//inspired by html color picker - generate color from rainbow palette
Var d, e, r: double;
begin
  d := step;
  e := total;
  try
    r := abs(d/e);
  except
    on E:Exception do begin r := 1 end;
  end;
  if r>=1 then r := 1;
  Result := HSLtoTColor( r, 1, 0.5);
end;




function CRC16CCITT(bytes: TBytes): Word;
const
  polynomial = $1021;   // 0001 0000 0010 0001  (0, 5, 12)
var
  crc: Word;
  I, J: Integer;
  b: Byte;
  bit, c15: Boolean;
begin
  crc := $FFFF; // initial value
  for I := 0 to High(bytes) do
  begin
    b := bytes[I];
    for J := 0 to 7 do
    begin
      bit := (((b shr (7-J)) and 1) = 1);
      c15 := (((crc shr 15) and 1) = 1);
      crc := crc shl 1;
      if (c15 and (not bit)) or ((not c15) and bit ) then crc := crc xor polynomial;
    end;
  end;
  Result := crc and $ffff;
end;



function CRC16ModbusA(msg: TBytes): Word;
//taken from http://control.com/thread/1026149685
{MODBUS CRC-16 ObjectPascal (Delphi) Routine by Panu-Kristian Poiksalo 2003
This function calculates a checksum STRING for a message STRING for maximum
usability for me... example call for this function would be something like...
var message:string;
begin
message:=#1#5#0#0#255#0;
ModbusSerialPort.Output:= message + crc16string (message);
end;
happy coding! send me a greeting at bancho@microdim.net when you get it to
work and share this code freely with everyone at any web site!}
//function crc16string(msg:string):string;

var crc: word;
    n,i: integer;
    b:byte;
begin
	crc := $FFFF;
	for i:=0 to length(msg)-1 do begin
	  b:=msg[i];
	  crc := crc xor b;
	  for n:=1 to 8 do begin
	    if (crc and 1)<>0
	      then crc:=(crc shr 1) xor $A001
  	  else crc:=crc shr 1;
	    end;
	  end;
	//result := chr(crc and $ff)+ chr(crc shr 8);
  Result := crc;
end;


function CRC16ModbusA(msg: string): Word;
//taken from http://control.com/thread/1026149685
{MODBUS CRC-16 ObjectPascal (Delphi) Routine by Panu-Kristian Poiksalo 2003
This function calculates a checksum STRING for a message STRING for maximum
usability for me... example call for this function would be something like...
var message:string;
begin
message:=#1#5#0#0#255#0;
ModbusSerialPort.Output:= message + crc16string (message);
end;
happy coding! send me a greeting at bancho@microdim.net when you get it to
work and share this code freely with everyone at any web site!}
//function crc16string(msg:string):string;

var crc: word;
    n,i: integer;
    b:byte;
begin
	crc := $FFFF;
	for i:=1 to length(msg) do begin
	  b:= ord(msg[i]);
	  crc := crc xor b;
	  for n:=1 to 8 do begin
	    if (crc and 1)<>0
	      then crc:=(crc shr 1) xor $A001
  	  else crc:=crc shr 1;
	    end;
	  end;
	//result := chr(crc and $ff)+ chr(crc shr 8);
  Result := crc;
end;


function CRC16ModbusStrBE(msg: TBytes): string;
Var
 crc: word;
begin
  crc := CRC16ModbusA( msg);
  Result :=  chr(crc and $ff) + chr(crc shr 8);
end;


function CRC16ModbusStrBE(msg: string): string;
Var
 ba: TBytes;
 i: integer;
 crc: word;
begin
  //setlength(ba, length(msg));
  //for i:=1 to length(msg) do ba[i-1] := CharToByte( msg[i] );
  crc := CRC16ModbusA( msg );
  Result :=  chr(crc and $ff) + chr(crc shr 8);
end;



procedure MyDestroyAndNil(Var o); //safely checks for nil/ destroyes object, and sets var to NIL
var
  Temp: TObject;
begin
  if Pointer(O)=nil then exit;
  Temp := TObject(o);
  Temp.Destroy;
  Pointer(O) := nil;
end;



function GetCPUTick(): Int64;
asm
   DB $0F,$31 // this is RDTSC command. Assembler, built in Delphi,
              // does not support it,
              // that is why one needs to overcome this obstacle.
end;


end.

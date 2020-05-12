{
   MVconversion.pas
   
   Copyright 2016 Michal Vaclavu <michal.vaclavu@gmail.com>
   
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


unit MVconversion;


interface

uses Classes, DateUtils, SysUtils, MyUtils;


function MyStrToFloatDef(s: string; def: double): double; //accepts both decimal . and , !!!! not dependent on system locale settings
function MyStrToFloat(s: string): double;

function MyXStrToInt( val: string): longint;

function MVIntToStr(i: longint): string;
function MVIntToBool(i: longint): boolean;

function MVStrToInt(s: string): longint;
function MVStrToFloat(s: string): double;
function MVStrToBool(s: string): boolean;

function MVFloatToInt(d: double): longint;
function MVFloatToStr(d: double): string;
function MVFloatToBool(d: double): boolean;

function MVBoolToInt(b: boolean): longint;
function MVBoolToStr(b: boolean): string;




Var

  _DefaultFormatSettings, _fsDot, _fsComma :  TFormatSettings;
  _FloatToBoolEpsilon: double = 1e-6;
  _DefStrToIntVal: longint = 0;  //High(longint);


implementation

Uses Math, StrUtils;


function MyStrToFloatDef(s: string; def: double): double; //accepts both decimal . and , !!!! not dependent on system locale settings
Var
  f1, f2, f3: Extended;
  b1, b2, b3: boolean;
begin
 //first try convert with locale set to ".", if fails, then try convert with ","
  Result := def;//Result := NAN;
  b1 := false;
  b2 := false;
  b3 := false;
  //try
      //texttofloat should not thorw any exception!!!!
      b1 := TextToFloat(PChar(s), f1, fvExtended, _DefaultFormatSettings);
      if not b1 then
        begin
          b2 := TextToFloat(PChar(s), f2, fvExtended, _fsDot);
          if not b2 then b3 := TextToFloat(PChar(s), f3, fvExtended, _fsComma);
        end;
      //
      if b1 then Result := f1
      else if b2 then Result := f2
      else if b3 then Result := f3
      else Result := def;
  //except on E: Exception do  begin  end;
  //end;
end;


function MyStrToFloat(s: string): double; //accepts both decimal . and , !!!! not dependent on system locale settings
begin
  Result := MyStrToFloatDef(s, NAN);
end;



function MyXStrToInt( val: string): longint;
begin
  try
    Result := StrToIntDef(val, _DefStrToIntVal);
  except
    on E: Exception do
      begin
        Result := _DefStrToIntVal;
      end;
  end;
end;


//-----------------------


function MVIntToStr(i: longint): string;
begin
  Result:= IntToStr(i);
end;

function MVIntToBool(i: longint): boolean;
begin
  Result := i<>0;
end;



function MVStrToInt(s: string): longint;
begin
  Result:= MyXStrToInt(s);
end;


function MVStrToFloat(s: string): double;
begin
  Result:= MyStrToFloatDef(s, NAN);
end;


function MVStrToBool(s: string): boolean;
Var ss: string;
begin
  Result := true;
  ss := Lowercase(Trim(s));
  if (ss='0') or (ss='false') or (ss='null') then Result := false;
end;


function MVFloatToInt(d: double): longint;
begin
  Result:= Trunc( d );
end;

function MVFloatToStr(d: double): string;
begin
  Result:= FloatToStr( d );
end;

function MVFloatToBool(d: double): boolean;
begin
  Result := CompareEpsilonAequalB( d, 0.0,  _FloatToBoolEpsilon );
end;



function MVBoolToInt(b: boolean): longint;
begin
  Result := ifthen( b, 1, 0);
end;

function MVBoolToStr(b: boolean): string;
begin
  Result := IfThen( b, '1', '0');
end;






Initialization

  GetLocaleFormatSettings(0, _DefaultFormatSettings);
  
   _fsDot := _DefaultFormatSettings;
   _fsDot.DecimalSeparator := '.';
   _fsDot.ThousandSeparator := ',';

   _fsComma := _DefaultFormatSettings;
   _fsComma.DecimalSeparator := ',';
   _fsComma.ThousandSeparator := '.';

END.


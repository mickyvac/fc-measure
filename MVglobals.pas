{
   MVglobals.pas
   
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


unit MVglobals;


interface

uses Classes, DateUtils, SysUtils,
     myvariant;



class TMVGlobals
    //for now uses simple Tstringlist keyval pairs fucntionality ->>> in future modify to uses hashing to fast access items named by string
	public
		constructor Create;
		destructor Destroy; override;
	public
		function Add( name: string; v: TMVSimpleVariant ): boolean;
		function GetByName( name: string ): TMVSimpleVariant;
    fucntion GetById( id: longint ): TMVSimpleVariant;
	private
		



end;




  Result := false;
  if sl=nil then exit;
  b1 := ParseStrSep( replydata, ';', toklist );
  if not b1 then exit;
  sl.Clear;
  if length( toklist)<1 then
    begin
      Result := true;
      exit;
    end;
  b := true;
  try
    for i:=0 to length( toklist)-1 do
      begin
        bx := DivideReplyIntoParts( toklist[i].s, ns, vs);
        b := b and bx;
        sl.Add(ns + '='+ vs);
      end;
  except
    Result := false;
    sl.Clear;
    exit;
  end;
  Result := b;
  
  
  
  





implementation


BEGIN
	
	
END.


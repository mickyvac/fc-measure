unit MyContainers;

{
   MyContainers.pas
   
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


interface

uses myThreadUtils;

type

TMyStringQueueThreadSafe = class (TMyLockableObject)
  public
    constructor Create( size: longint=1000);
    destructor Destroy; override;
    //tqueue
  public
    function PushMsg(const s: string; force: boolean = false): boolean;
    function PopMsg(Var s: string): boolean;
    function PeekMsg(Var s: string; n: longint = 0): boolean;  //n=optional pos of string  0..count-1
    function CanAdd: boolean;
    function Clear: boolean;
    function Count: longint;
  private
    function iCanAdd(donotlock: boolean = false): boolean;
    function iCount(donotlock: boolean = false): longint;
  private
    fstrlist: array of string;
    fpstrt: longint;
    fpend: longint;
    fsize: longint;
    flocktout: longint;
end;


implementation



Uses myUtils;

constructor TMyStringQueueThreadSafe.Create( size: longint=1000);
begin
  inherited Create;
  MakeSureIsInRange(size, 10, 10000);
  fsize := size;
  setlength(fstrlist, fsize);       //useful capacity is fsize-1
  fpstrt := 0;
  fpend := 0;
  //strpos == endpos =-> empty
  flocktout := 500;
end;


destructor TMyStringQueueThreadSafe.Destroy;
begin
  fsize := 0;
  setlength(fstrlist, 0);
  inherited;
end;

function TMyStringQueueThreadSafe.PushMsg(const s: string; force: boolean = false): boolean;
begin
  Result := false;
  Lock;
  try      //critical section
	  if (not iCanAdd(true)) and (not force) then begin Unlock; exit; end;
	  if not iCanAdd(true) then
      begin
    	  Inc( fpstrt );
	      if fpstrt >= fsize then fpstrt := 0;
      end;
	  if not iCanAdd(true) then begin Unlock; exit; end;
	  fstrlist[ fpend ] := s + '';   ///!!!!!!!!!!!!!force copy string
	  Inc(fpend);
	  if fpend>=fsize then fpend := 0;
  finally
    Unlock;
  end;
  Result := true;
end;


function TMyStringQueueThreadSafe.PopMsg(Var s: string): boolean;
begin
  Result := false;
  s := '';
  Lock;  //critical section
  try
	  if fpstrt=fpend then begin Unlock; exit; end;  //meaning array is empty
	  s := fstrlist[fpstrt] + '';  ///!!!!!!!!!!!!!force copy string
	  Inc( fpstrt );
	  if fpstrt >= fsize then fpstrt := 0;
  finally
    Unlock;
  end;
  Result := true;
end;


function TMyStringQueueThreadSafe.PeekMsg(Var s: string; n: longint = 0): boolean;  //n=optional pos of string  0..count-1
Var
 i: longint;
begin
  Result := false;
  s := '';
  Lock;
  try   //critical section
	  if n > iCount(true) -1 then begin Unlock; exit; end;
	  i := (fpstrt + n) mod fsize;
	  if i>fpend then begin Unlock; exit; end; //assert
	  s := fstrlist[i] + '';  ///!!!!!!!!!!!!!force copy string
  finally
    Unlock;
  end;
  Result := true;
end;


function TMyStringQueueThreadSafe.Clear: boolean;
begin
  Result := false;
  Lock;
  try   //critical section
    fpend := fpstrt;
  finally
    Unlock;
  end;
  Result := true;
end;

function TMyStringQueueThreadSafe.CanAdd: boolean;
begin
  Lock;
  try
    Result := iCanAdd;
  finally
    Unlock;
  end;
end;

function TMyStringQueueThreadSafe.iCanAdd(donotlock: boolean = false): boolean;
begin
  Result := false;
  Result := iCount(true) < fsize -1; //the useful maximum capacity is Asize-1 (at full, one index is unsued due to easy impl)
end;

function TMyStringQueueThreadSafe.Count: longint;
begin
  Lock;
  try
    Result := iCount;
  finally
    Unlock;
  end;
end;

function TMyStringQueueThreadSafe.iCount(donotlock: boolean = false): longint;
begin
  Result := -1;
  try  //if fpend<fpstrt then Result := fpend + fsize - fpstrt
    Result := (fpend - fpstrt) mod fsize;
  except
  end;
end;




end.

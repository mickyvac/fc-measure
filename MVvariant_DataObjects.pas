{
   MVvariant_DataObjects.pas
   
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


unit MVvariant_DataObjects;


interface

uses Classes, DateUtils, SysUtils, math,
     MVConversion;




type
  TMVDaTaObjectType = (CMVNULL, CMVint, CMVstr, CMVfloat, CMVbool, CMVobjref);


TMVObject = class
  public
    id: longword;
end;



TMVUniversalObjectRef = class (TObject)
  public
        constructor Create();
        destructor Destroy; override;
  protected
     fpayload: TObject;
  protected
      function GetTypeIdStr(): string; virtual; abstract;
  public
    property typeof: string read GetTypeIdStr;
    property payloadraw: TObject read fpayload;
end;




TMVDataObject = class
  public
    constructor Create;
    destructor Destroy; override;
	public
		ftype: TMVDaTaObjectType;
	public
		function AsString: string; virtual; abstract;
		function AsInt: longint; virtual; abstract;
		function AsDouble: double; virtual; abstract;
		function AsBool: boolean; virtual; abstract;
	public
		procedure Assign(i: longint); overload; virtual; abstract;
		procedure Assign(s: string); overload; virtual; abstract;
		procedure Assign(d: double); overload; virtual; abstract;
		procedure Assign(b: boolean); overload; virtual; abstract;
    procedure AssignNULL; overload; virtual; abstract;
  private
		procedure SetInt(i: longint);
		procedure SetStr(s: string);
		procedure SetDouble(d: double);
		procedure SetBool(b: boolean);
  public
    property valint: integer read AsInt write SetInt;
    property valstr: string read AsString write SetStr;
    property valbool: boolean read AsBool write SetBool;
    property valdouble: double read AsDouble write SetDouble;

end;


TMVDataObjectInt = class (TMVDataObject)
  public
    constructor Create(i: longint);
    destructor Destroy; override;
	protected
		payload: longint;
	public
		function AsString: string; override;
		function AsInt: longint; override;
		function AsDouble: double; override;
		function AsBool: boolean; override;
	public
		procedure Assign(i: longint); overload; override;
		procedure Assign(s: string); overload; override;
		procedure Assign(d: double); overload; override;
		procedure Assign(b: boolean); overload; override;
    procedure AssignNULL; overload; override;
end;


TMVDataObjectFloat = class (TMVDataObject)
    public
        constructor Create(d: double);
        destructor Destroy; override;
	protected
		payload: double;
	public
		function AsString: string; override;
		function AsInt: longint; override;
		function AsDouble: double; override;
		function AsBool: boolean; override;
	public
		procedure Assign(i: longint); overload; override;
		procedure Assign(s: string); overload; override;
		procedure Assign(d: double); overload; override;
		procedure Assign(b: boolean); overload; override;
    procedure AssignNULL; overload; override;
end;

TMVDataObjectStr = class (TMVDataObject)
    public
        constructor Create(s: string);
        destructor Destroy; override;
	protected
		payload: string;
	public
		function AsString: string; override;
		function AsInt: longint; override;
		function AsDouble: double; override;
		function AsBool: boolean; override;
	public
		procedure Assign(i: longint); overload; override;
		procedure Assign(s: string); overload; override;
		procedure Assign(d: double); overload; override;
		procedure Assign(b: boolean); overload; override;
    procedure AssignNULL; overload; override;
end;


TMVDataObjectBool = class (TMVDataObject)
    public
        constructor Create(b: boolean);
        destructor Destroy; override;
	protected
		payload: boolean;
	public
		function AsString: string; override;
		function AsInt: longint; override;
		function AsDouble: double; override;
		function AsBool: boolean; override;
	public
		procedure Assign(i: longint); overload; override;
		procedure Assign(s: string); overload; override;
		procedure Assign(d: double); overload; override;
		procedure Assign(b: boolean); overload; override;
    procedure AssignNULL; overload; override;
end;


TMVDataObjectNull = class (TMVDataObject)
  public
        constructor Create();
        destructor Destroy; override;
  protected
    payload: pointer;
	public
		function AsString: string; override;
		function AsInt: longint; override;
		function AsDouble: double; override;
		function AsBool: boolean; override;
	public
		procedure Assign(i: longint); overload; override;
		procedure Assign(s: string); overload; override;
		procedure Assign(d: double); overload; override;
		procedure Assign(b: boolean); overload; override;
    procedure AssignNULL; overload; override;
end;






TMVDataObjectReference = class (TMVDataObject)
  public
        constructor Create(ref: TMVUniversalObjectRef);
        destructor Destroy; override;
  protected
    payload: TMVUniversalObjectRef;
	public
		function AsString: string; override;
		function AsInt: longint; override;
		function AsDouble: double; override;
		function AsBool: boolean; override;
	public
		procedure Assign(i: longint); overload; override;
		procedure Assign(s: string); overload; override;
		procedure Assign(d: double); overload; override;
		procedure Assign(b: boolean); overload; override;
    procedure AssignNULL; overload; override;
  public
    function GetObjectRef: TMVUniversalObjectRef;
    procedure SetObjectRef(ref: TMVUniversalObjectRef);
end;



//============================



{
class TMVSimpleObject    //array,  record
end;


class TMVComplexObject    //array,  record, hardlink to another object
end;
}


TMVSimpleVariant = class (TObject)
  public
      constructor Create(i: longint); overload;
      constructor Create(s: string); overload;
      constructor Create(d: double); overload;
      constructor Create(b: boolean); overload;
      constructor CreateNULL; overload;
      constructor Create(o: TMVUniversalObjectRef); overload;
//
      constructor Create(t: TMVDaTaObjectType; v: TMVSimpleVariant); overload;  //copy create
      constructor Create(v: TMVSimpleVariant); overload;  //copy create
      destructor Destroy; override;
  public
     procedure Assign(i: longint); overload; virtual;
     procedure Assign(s: string); overload; virtual;
     procedure Assign(d: double); overload; virtual;
     procedure Assign(b: boolean); overload; virtual;
//     procedure Assign(o: TMVSimpleObject); overload;
     procedure Assign(v: TMVSimpleVariant); overload;
  public
     procedure ChangeTo(t: TMVDaTaObjectType);
  public
     procedure ReplaceAssign(i: longint); overload; virtual;
     procedure ReplaceAssign(s: string); overload; virtual;
     procedure ReplaceAssign(d: double); overload; virtual;
     procedure ReplaceAssign(b: boolean); overload; virtual;
  public
     function GetStr: string; virtual;
     function GetInt: longint; virtual;
     function GetDouble: double; virtual;
     function GetBool: boolean; virtual;
  public
     function GetObjRef(): TMVUniversalObjectRef; virtual;
  public
     function CopyOf: TMVSimpleVariant; virtual;
  protected
     fdata: TMVDataObject;
     ftype: TMVDaTaObjectType;
     fRO: boolean;
  private
    procedure SetInt(i: longint); virtual;
	  procedure SetStr(s: string); virtual;
   	procedure SetDouble(d: double); virtual;
  	procedure SetBool(b: boolean); virtual;
  public
    property valInt: integer read GetInt write SetInt;
    property valStr: string read GetStr write SetStr;
    property valDouble: double read GetDouble write SetDouble;
    property valBool: boolean read GetBool write SetBool;
    //
    property valObjRef: TMVUniversalObjectRef read GetObjRef;
    //
    property typeof: TMVDaTaObjectType read ftype;
    property ronly: boolean read fRO write fRO; 
end;


Var
  _NULLVariant: TMVSimpleVariant;

implementation



//================================================



constructor TMVSimpleVariant.Create(i: longint);
begin
  inherited Create;
  ftype := CMVint;
  fRO := false;
  fdata := TMVDataObjectInt.Create(i);
end;

constructor TMVSimpleVariant.Create(s: string);
begin
  inherited Create;
  ftype := CMVstr;
  fRO := false;
  fdata := TMVDataObjectStr.Create(s);
end;

constructor TMVSimpleVariant.Create(d: double);
begin
  inherited Create;
  ftype := CMVfloat;
  fRO := false;
  fdata := TMVDataObjectFloat.Create(d);
end;

constructor TMVSimpleVariant.Create(b: boolean);
begin
  inherited Create;
  ftype := CMVbool;
  fRO := false;
  fdata := TMVDataObjectBool.Create(b);
end;

constructor TMVSimpleVariant.CreateNULL;
begin
  inherited Create;
  ftype := CMVNULL;
  fRO := false;
  fdata := TMVDataObjectNULL.Create();
end;

constructor TMVSimpleVariant.Create(t: TMVDaTaObjectType; v: TMVSimpleVariant); //copy create
begin
  if (v=nil) or (t = CMVNULL) then
    begin
      CreateNULL;
      exit;
    end;
  inherited Create;
  ftype := v.typeof;
  fRO := v.ronly;
  case ftype of
    CMVint: fdata := TMVDataObjectInt.Create( v.GetInt );
    CMVstr: fdata := TMVDataObjectStr.Create( v.GetStr );
    CMVfloat: fdata := TMVDataObjectFloat.Create( v.GetDouble );
    CMVbool: fdata := TMVDataObjectBool.Create( v.GetBool );
    CMVobjref: fdata := TMVDataObjectReference.Create( v.GetObjRef );
    else fdata := TMVDataObjectNULL.Create();
  end;
end;

constructor TMVSimpleVariant.Create(v: TMVSimpleVariant); //copy create
begin
  if v<>nil then Create(v.typeof, v)
  else CreateNULL;
end;



constructor TMVSimpleVariant.Create(o: TMVUniversalObjectRef);
begin
  inherited Create;
  ftype := CMVobjref;
  fRO := false;
  fdata := TMVDataObjectReference.Create(o);

end;

destructor TMVSimpleVariant.Destroy;
begin
  if fdata<>nil then fdata.Destroy;
end;

procedure TMVSimpleVariant.Assign(i: longint);
begin
  if fRO then exit;
  if fdata=nil then
    begin
      ftype := CMVint;
      fdata := TMVDataObjectInt.Create(i);
    end
  else   fdata.Assign(i);
end;

procedure TMVSimpleVariant.Assign(s: string);
begin
  if fRO then exit;
  if fdata=nil then
    begin
      ftype := CMVstr;
      fdata := TMVDataObjectStr.Create(s);
    end
  else fdata.Assign(s);
end;

procedure TMVSimpleVariant.Assign(d: double);
begin
  if fRO then exit;
  if fdata=nil then
    begin
      ftype := CMVfloat;
      fdata := TMVDataObjectFloat.Create(d);
    end
  else fdata.Assign(d);
end;

procedure TMVSimpleVariant.Assign(b: boolean);
begin
  if fRO then exit;
  if fdata=nil then
    begin
      ftype := CMVbool;
      fdata := TMVDataObjectBool.Create(b);
    end
  else fdata.Assign(b);
end;

//procedure TMVSimpleVariant.Assign(o: TMVSimpleObject);

procedure TMVSimpleVariant.Assign(v: TMVSimpleVariant);
begin
  if v=nil then v := _NULLVariant;
  if fRO then exit;
  if fdata=nil then
    begin
      ftype := v.typeof;
      case v.typeof of
        CMVint: fdata := TMVDataObjectInt.Create( v.GetInt );
        CMVstr: fdata := TMVDataObjectStr.Create( v.GetStr );
        CMVfloat: fdata := TMVDataObjectFloat.Create( v.GetDouble );
        CMVbool: fdata := TMVDataObjectBool.Create( v.GetBool );
        else fdata := TMVDataObjectNULL.Create();
      end;
    end
  else
    begin
      case v.typeof of
        CMVint: fdata.Assign( v.GetInt );
        CMVstr: fdata.Assign( v.GetStr );
        CMVfloat: fdata.Assign( v.GetDouble );
        CMVbool: fdata.Assign( v.GetBool );
        else fdata.AssignNULL;
      end;
    end;
end;


function TMVSimpleVariant.GetStr: string;
begin
  if fdata<>nil then Result := fdata.AsString
  else Result := _NULLVariant.GetStr
end;

function TMVSimpleVariant.GetInt: longint;
begin
  if fdata<>nil then Result := fdata.AsInt
  else Result := _NULLVariant.GetInt;
end;

function TMVSimpleVariant.GetObjRef: TMVUniversalObjectRef;
begin
  if fdata=nil then Result := NIL
  else
    begin
      if fdata.ftype<>CMVobjref then Result := NIL
      else Result := TMVDataObjectReference(fdata).GetObjectRef();
    end;
end;

function TMVSimpleVariant.GetDouble: double;
begin
  if fdata<>nil then Result := fdata.AsDouble
  else Result := _NULLVariant.GetDouble;
end;

function TMVSimpleVariant.GetBool: boolean;
begin
  if fdata<>nil then Result := fdata.AsBool
  else Result := _NULLVariant.GetBool;
end;



procedure TMVSimpleVariant.SetInt(i: longint);
begin
  if fRO then exit;
  if fdata<>nil then fdata.Assign(i);
end;

procedure TMVSimpleVariant.SetStr(s: string);
begin
  if fRO then exit;
  if fdata<>nil then fdata.Assign(s);
end;

procedure TMVSimpleVariant.SetDouble(d: double);
begin
  if fRO then exit;
  if fdata<>nil then fdata.Assign(d);
end;

procedure TMVSimpleVariant.SetBool(b: boolean);
begin
  if fRO then exit;
  if fdata<>nil then fdata.Assign(b);
end;



procedure TMVSimpleVariant.ChangeTo(t: TMVDaTaObjectType);
Var
  newdata, olddata: TMVDataObject;
begin
  if t=ftype then exit;  //no need to change
  if fRO then exit;  //if set READ ONLY
  case t of
        CMVint: newdata := TMVDataObjectInt.Create( GetInt );
        CMVstr: newdata := TMVDataObjectStr.Create( GetStr );
        CMVfloat: newdata := TMVDataObjectFloat.Create( GetDouble );
        CMVbool: newdata := TMVDataObjectBool.Create( GetBool );
        else newdata := TMVDataObjectNull.Create;
  end;
  olddata := fdata;
  ftype := t;
  fdata := newdata;
  if olddata<>nil then olddata.Destroy;
end;


procedure TMVSimpleVariant.ReplaceAssign(i: longint);
begin
  ChangeTo( CMVint );
  Assign(i);
end;

procedure TMVSimpleVariant.ReplaceAssign(s: string);
begin
  ChangeTo( CMVstr );
  Assign(s);
end;

procedure TMVSimpleVariant.ReplaceAssign(d: double);
begin
  ChangeTo( CMVfloat );
  Assign(d);
end;

procedure TMVSimpleVariant.ReplaceAssign(b: boolean);
begin
  ChangeTo( CMVbool );
  Assign(b);
end;


function TMVSimpleVariant.CopyOf: TMVSimpleVariant;
begin
  if fdata=nil then ftype := CMVNULL;
  //
      case ftype of
        CMVint: Result := TMVSimpleVariant.Create( GetInt );
        CMVstr: Result := TMVSimpleVariant.Create( GetStr );
        CMVfloat: Result := TMVSimpleVariant.Create( GetDouble );
        CMVbool: Result := TMVSimpleVariant.Create( GetBool );
        CMVobjref: Result := TMVSimpleVariant.Create( GetObjRef );
        else Result := TMVSimpleVariant.CreateNULL;
      end;
end;


//==========dat objects =======================

constructor TMVDataObject.Create;
begin
  inherited;
	ftype := CMVNULL;
end;

destructor TMVDataObject.Destroy;
begin
	inherited;
end;

		procedure TMVDataObject.SetInt(i: longint);
    begin
      Assign(i);
    end;

		procedure TMVDataObject.SetStr(s: string);
    begin
      Assign(s);
    end;

		procedure TMVDataObject.SetDouble(d: double);
    begin
      Assign(d);
    end;

		procedure TMVDataObject.SetBool(b: boolean);
    begin
      Assign(b);
    end;


// ******


constructor TMVDataObjectInt.Create(i: longint);
begin
	inherited Create;
	ftype := CMVint;
	payload := i;
end;

destructor TMVDataObjectInt.Destroy;
begin
	inherited;
end;

function TMVDataObjectInt.AsString: string;
begin
	Result := MVIntToStr( payload );
end;

function TMVDataObjectInt.AsInt: longint;
 begin
	Result := payload;
end;

function TMVDataObjectInt.AsDouble: double; 
begin
	Result := payload;
end;

function TMVDataObjectInt.AsBool: boolean; 
begin
	Result := MVIntToBool( payload ); 
end;

procedure TMVDataObjectInt.Assign(i: longint);
begin
	payload := i; 
end;

procedure TMVDataObjectInt.Assign(s: string); 
begin
	payload := MVStrToInt(s); 
end;

procedure TMVDataObjectInt.Assign(d: double);
begin
	payload := MVFloatToInt(d); 
end;

procedure TMVDataObjectInt.Assign(b: boolean);
begin
	payload := MVBoolToInt(b); 
end;

procedure TMVDataObjectInt.AssignNULL;
begin
  payload := _NULLVariant.GetInt;
end;

// float



constructor TMVDataObjectFloat.Create(d: double);
begin
	inherited Create;
	ftype := CMVfloat;
	payload := d;
end;

destructor TMVDataObjectFloat.Destroy;
begin
	inherited;
end;

function TMVDataObjectFloat.AsString: string; 
begin
	Result := MVFloatToStr( payload ); 
end;

function TMVDataObjectFloat.AsInt: longint; 
begin
	Result := MVFloatToInt( payload ); 
end;

function TMVDataObjectFloat.AsDouble: double;
begin
	Result := payload;
end;

function TMVDataObjectFloat.AsBool: boolean; 
begin
	Result := MVFloatToBool( payload ); 
end;


procedure TMVDataObjectFloat.Assign(i: longint); 
begin
	payload := i; 
end;

procedure TMVDataObjectFloat.Assign(s: string); 
begin
	payload := MVStrToFloat( s ); 
end;

procedure TMVDataObjectFloat.Assign(d: double);
begin
	payload := d; 
end;

procedure TMVDataObjectFloat.Assign(b: boolean);
begin
	payload := MVBoolToInt(b); 
end;

procedure TMVDataObjectFloat.AssignNULL;
begin
  payload := _NULLVariant.GetDouble;
end;

//str


constructor TMVDataObjectStr.Create(s: string);
begin
	inherited Create;
	ftype := CMVstr;
	payload := s+'';    //COPY!!!!
  UniqueString( payload );
end;

destructor TMVDataObjectStr.Destroy;
begin
  payload := '';
	inherited;
end;

function TMVDataObjectStr.AsString: string;
begin
	Result := payload + '';   //!!!! copy    UniqueString
end;

function TMVDataObjectStr.AsInt: longint;
Var
 tmp: string;
begin
  tmp := payload + '';
	Result := StrToIntDef(tmp, 0); //MVStrToInt( payload );
end;

function TMVDataObjectStr.AsDouble: double;
Var
 tmp: string;
begin
  tmp := payload + '';
	Result := MVStrToFloat( tmp );
end;

function TMVDataObjectStr.AsBool: boolean;
Var
 tmp: string;
begin
  tmp := payload + '';
	Result := MVStrToBool( tmp );
end;


procedure TMVDataObjectStr.Assign(i: longint);
begin
	payload := MVIntToStr(i) + '';
end;

procedure TMVDataObjectStr.Assign(s: string);
begin
	payload := s + '';  //!!!! copy  UniqueString
end;

procedure TMVDataObjectStr.Assign(d: double);
begin
	payload := MVFloatToStr(d) + '';
end;

procedure TMVDataObjectStr.Assign(b: boolean);
begin
	payload := MVBoolToStr(b) + '';
end;

procedure TMVDataObjectStr.AssignNULL;
begin
  payload := _NULLVariant.GetStr;
end;

//bool


constructor TMVDataObjectBool.Create(b: boolean);
begin
	inherited Create;
	ftype := CMVbool;
	payload := b;
end;

destructor TMVDataObjectBool.Destroy; 
begin
	inherited;
end;

function TMVDataObjectBool.AsString: string;
begin
	Result := MVBoolToStr( payload );
end;
 
function TMVDataObjectBool.AsInt: longint;
 begin
	Result := MVBoolToInt( payload );
end;

function TMVDataObjectBool.AsDouble: double; 
begin
	Result := MVBoolToInt( payload ) ; 
end;

function TMVDataObjectBool.AsBool: boolean;
begin
	Result := payload;
end;

procedure TMVDataObjectBool.Assign(i: longint);
begin
	payload := MVIntToBool(i); 
end;

procedure TMVDataObjectBool.Assign(s: string); 
begin
	payload := MVStrToBool(s); 
end;

procedure TMVDataObjectBool.Assign(d: double);
begin
	payload := MVFloatToBool(d);
end;

procedure TMVDataObjectBool.Assign(b: boolean);
begin
	payload := b;
end;

procedure TMVDataObjectBool.AssignNULL;
begin
  payload := _NULLVariant.GetBool;
end;

//NULL

constructor TMVDataObjectNull.Create();
begin
	inherited Create;
	ftype := CMVNULL;
	payload := NIL;
end;

destructor TMVDataObjectNull.Destroy;
begin
	inherited;
end;

function TMVDataObjectNull.AsString: string;
begin
	Result := 'NULL';
end;
function TMVDataObjectNull.AsInt: longint;
begin
	Result := 0;
end;
function TMVDataObjectNull.AsDouble: double;
begin
	Result := NAN;
end;
function TMVDataObjectNull.AsBool: boolean;
begin
	Result := false;
end;
procedure TMVDataObjectNull.Assign(i: longint);
begin
end;
procedure TMVDataObjectNull.Assign(s: string);
begin
end;
procedure TMVDataObjectNull.Assign(d: double);
begin
end;
procedure TMVDataObjectNull.Assign(b: boolean);
begin
end;
procedure TMVDataObjectNull.AssignNULL;
begin
end;



{ TMVUniversalObjectRef }

constructor TMVUniversalObjectRef.Create;
begin
  inherited;
  fpayload := NIL;
end;

destructor TMVUniversalObjectRef.Destroy;
begin
  if fpayload<>nil then fpayload.Destroy;
  inherited;
end;




{ TMVDataObjectReference }
constructor TMVDataObjectReference.Create(ref: TMVUniversalObjectRef);
begin
  inherited Create();
  payload := ref;
end;

destructor TMVDataObjectReference.Destroy;
begin
  //does not take care of the assigned object (must be taken care of in the creator]
  inherited;
end;



function TMVDataObjectReference.AsBool: boolean;
begin
  Result :=  payload<>NIL;
end;

function TMVDataObjectReference.AsDouble: double;
begin
  Result := NAN;
end;

function TMVDataObjectReference.AsInt: longint;
begin
   Result := ifThen(payload<>NIL, 1, 0);
end;

function TMVDataObjectReference.AsString: string;
begin
    if payload<>NIL then
      Result := 'object('+  payload.GetTypeIdStr   + ')'
    else
      Result := 'object(NULL)';
end;


procedure TMVDataObjectReference.Assign(s: string);
begin
end;

procedure TMVDataObjectReference.Assign(i: Integer);
begin
end;

procedure TMVDataObjectReference.Assign(b: boolean);
begin
end;

procedure TMVDataObjectReference.Assign(d: double);
begin
end;

procedure TMVDataObjectReference.AssignNULL;
begin
  payload := NIL;
end;

function TMVDataObjectReference.GetObjectRef: TMVUniversalObjectRef;
begin
  Result := payload;
end;

procedure TMVDataObjectReference.SetObjectRef(ref: TMVUniversalObjectRef);
begin
  payload := ref;
end;









Initialization

  _NULLVariant := TMVSimpleVariant.CreateNULL;
  _NULLVariant.ronly :=  TRUE;


Finalization

  _NULLVariant.Destroy;

END.


unit MyThreadUtils;

interface

Uses Sysutils, MVvariant_DataObjects, Classes, IniFiles, Contnrs, SyncObjs;

type

  TLogProcedureThreadSafe = procedure(s: string) of object;
  TLogProcedureThreadSafeLevel = procedure(s: string; lvl: byte) of object;

  TMyLockableObject = class (TObject)    //should provide thread safe to storage objects using locking
  public
    constructor Create;     //timeout - if cannot obtain lock for long time, assume it is OK and continue as if lock obtained
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    procedure BeginWrite; //remap
    procedure EndWrite;
    procedure BeginRead;
    procedure EndRead;
  private
    fLock: boolean;
    fCS: TCriticalSection;
  public
    property IsLocked: boolean read fLock;
  end;





  TMVVariantThreadSafe = class( TMyLockableObject )
  public
      constructor Create(i: longint); overload;
      constructor Create(s: string); overload;
      constructor Create(d: double); overload;
      constructor Create(b: boolean); overload;
      constructor Create(v: TMVSimpleVariant); overload;  //copy create
      destructor Destroy; override;
  public
     procedure ChangeTo(t: TMVDaTaObjectType);
  public
     function CopyOf: TMVVariantThreadSafe;
  protected
     fdata: TMVSimpleVariant;
  private
     function GetStr: string; virtual;
     function GetInt: longint; virtual;
     function GetDouble: double; virtual;
     function GetBool: boolean; virtual;
    procedure SetInt(i: longint); virtual;
	  procedure SetStr(s: string); virtual;
   	procedure SetDouble(d: double); virtual;
  	procedure SetBool(b: boolean); virtual;
     function GetType: TMVDaTaObjectType; virtual;
  public
    property valInt: integer read GetInt write SetInt;
    property valStr: string read GetStr write SetStr;
    property valDouble: double read GetDouble write SetDouble;
    property valBool: boolean read GetBool write SetBool;
    //
    property typeof: TMVDaTaObjectType read GetType;
end;


TMVStringListThreadSafe = class( TMyLockableObject )
//some inspiration from   TThreadStringList by  Author: Tilo Eckert   2004 http://www.swissdelphicenter.ch/de/showcode.php?id=2167
  public
      constructor Create(UseHashed: boolean = false);
      destructor Destroy; override;
  protected
     fList: TStringList;           //THashedStringList
     fLastModified: TDateTime;
  private
    function GetCapacity: Integer;
    procedure SetCapacity(capa: Integer);
    function GetCount: Integer;
    function GetDelimiter: Char;
    procedure SetDelimiter(delim: Char);
    function GetDelimitedText: string;
    procedure SetDelimitedText(const S: string);
    function GetNames(Index: Integer): string;
    function GetValuesIx(Index: Integer): string;
    procedure SetValuesIx(Index: Integer; S: string);
    function GetValues(const Name: string): string;
    procedure SetValues(const Name: string; S: string);
    function GetStrings(Index: Integer): string;
    procedure SetStrings(Index: Integer; S: string);
    function GetObject(Index: Integer): TObject;
    procedure SetObject(Index: Integer; obj: TObject);
    function GetAsText: string;
    function GetLastModified: TDateTime;
  public
    function Add(const S: string): Integer;
    procedure AddStrings(Strings: TStrings);
    procedure GetCopyStrList(Var sl: TStringList);
    procedure Delete(Index: Integer);
    procedure Clear;
    function IndexOfName(const Name: string): Integer;
  public
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property Delimiter: Char read GetDelimiter write SetDelimiter;
    property DelimitedText: string read GetDelimitedText write SetDelimitedText;
    property Names[Index: Integer]: string read GetNames;
    property ValuesByIndex[Index: Integer]: string read GetValuesIx write SetValuesIx;
    property ValuesByName[const Name: string]: string read GetValues write SetValues;
    property Strings[Index: Integer]: string read GetStrings write SetStrings; default;
    property Objects[Index: Integer]: TObject read GetObject write SetObject;
    property Text: string read GetAsText;
    property LastModified: TDateTime read GetLastModified;
end;







TMVQueueThreadSafe = class ( TMyLockableObject )
//acccess is thread safe
//does not cares about creating and destroying the objects ... only clear and destroy will call destroy on the objects.
//so when using pop you must take care of destroying
//peek returns reference, but the objects must stay valid!!!
//if you want to destroy objects yourself, make sure you pop them all out of the queue before calling destroy
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Add(o: pointer);
    function Pop: TObject;
    function Peek: TObject;
    procedure Clear;
    function Count: longint;
    procedure SetEnabledState( b: boolean); //disable to prevent from receiving any more objects
  //private
  //  function getItem(ix: longint): TObject;
  //public
  //  property Items[index: longint]: Tobject read getItem; default;
  public
    fQ: TQueue;
    fEnabled: boolean;
end;








TMVStringObj = class (TObject)  //need it for the STRINGqueue object
  public
    constructor Create( s: string);
    destructor Destroy; override;
  private
    fstr: string;
  property s: string read fstr;
end;




TMVStringQueueThreadSafe = class (TObject)//(TQueueTHreadSafe)
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure PushMsg( s: string);
    function PopMsg: string;
    function PeekMsg: string;
    function IsEmpty: boolean;
    function Count: longint;
    procedure Clear;
  private
    fQTS: TMVQueueThreadSafe;
end;



implementation

uses myutils;


constructor TMyLockableObject.Create;
begin
  inherited Create;
  fCS := TCriticalSection.Create;
  fLock := false;
end;

destructor TMyLockableObject.Destroy;
begin
  if not fLock then fCS.Destroy;
  inherited;
end;

procedure TMyLockableObject.Lock;
begin
  fCS.Acquire;
  fLock := true;
end;

procedure TMyLockableObject.UnLock;
begin
  fLock := false;
  fCS.Release;
end;


procedure TMyLockableObject.BeginWrite; //remap
begin
  Lock;
end;
procedure TMyLockableObject.EndWrite;
begin
  UnLock;
end;
procedure TMyLockableObject.BeginRead;
begin
  Lock;
end;
procedure TMyLockableObject.EndRead;
begin
  UnLock;
end;





//------------------------------------------------------------------------

constructor TMVVariantThreadSafe.Create(i: longint);
     begin
       inherited Create;
       fdata := TMVSimpleVariant.Create(i);
     end;

constructor TMVVariantThreadSafe.Create(s: string);
     begin
       inherited Create;
       fdata := TMVSimpleVariant.Create(s);
     end;

constructor TMVVariantThreadSafe.Create(d: double);
     begin
       inherited Create;
       fdata := TMVSimpleVariant.Create(d);
     end;

constructor TMVVariantThreadSafe.Create(b: boolean);
     begin
       inherited Create;
       fdata := TMVSimpleVariant.Create(b);
     end;

constructor TMVVariantThreadSafe.Create(v: TMVSimpleVariant);
     begin
       inherited Create;
       fdata := TMVSimpleVariant.Create(v);
     end;

destructor TMVVariantThreadSafe.Destroy;
     begin
       if fdata<>nil then fdata.Destroy;
       inherited;
     end;


     procedure TMVVariantThreadSafe.ChangeTo(t: TMVDaTaObjectType);
     begin
       Lock;
        if fdata<>nil then fdata.ChangeTo(t);
       Unlock;
     end;


     function TMVVariantThreadSafe.CopyOf: TMVVariantThreadSafe;
     begin
       Result := nil;
       Lock;
        Result := TMVVariantThreadSafe.Create( fdata );
       Unlock;
     end;

     function TMVVariantThreadSafe.GetStr: string;
     begin
       Lock;
         if fdata<>nil then Result := fdata.valStr + ''
         else Result := _NULLVariant.valStr + '';
       Unlock;
     end;

     function TMVVariantThreadSafe.GetInt: longint;
     begin
       Lock;
         if fdata<>nil then  Result := fdata.valInt else Result := _NULLVariant.valInt;
       Unlock;
     end;

     function TMVVariantThreadSafe.GetDouble: double;
     begin
       Lock;
         if fdata<>nil then Result := fdata.valDouble else Result := _NULLVariant.valDouble;
       Unlock;
     end;

     function TMVVariantThreadSafe.GetBool: boolean;
     begin
       Lock;
         if fdata<>nil then Result := fdata.valBool else Result := _NULLVariant.valBool;
       Unlock;
     end;

    procedure TMVVariantThreadSafe.SetInt(i: longint);
     begin
       Lock;
         if fdata<>nil then fdata.valInt := i;
       Unlock;
     end;

	  procedure TMVVariantThreadSafe.SetStr(s: string);
     begin
       Lock;
         if fdata<>nil then fdata.valStr := s;
       Unlock;
     end;

   	procedure TMVVariantThreadSafe.SetDouble(d: double);
     begin
       Lock;
         if fdata<>nil then fdata.valDouble := d;
       Unlock;
     end;

  	procedure TMVVariantThreadSafe.SetBool(b: boolean);
     begin
       Lock;
         if fdata<>nil then fdata.valBool := b;
       Unlock;
     end;

     function TMVVariantThreadSafe.GetType: TMVDaTaObjectType;
     begin
       Lock;
         if fdata<>nil then Result := fdata.typeof else Result := CMVNULL;
       Unlock;
     end;


//************************************ thread safe string list





constructor TMVStringListThreadSafe.Create(UseHashed: boolean = false);
begin
  inherited create;
  if UseHashed then
    fList := THashedStringList.Create
  else
    fList := TStringList.Create;
  fLastModified := Now;
end;

destructor TMVStringListThreadSafe.Destroy;
begin
  Lock;
  if fList<>nil then fList.Destroy;
  Unlock;
  inherited;
end;


function TMVStringListThreadSafe.Add(const S: string): Integer;
begin
  Result := -1;
  if fList=nil then exit;
  Lock;
    Result := fList.Add( S + '' );    //!!!!COPY
    fLastModified := Now;
  Unlock;
end;

procedure TMVStringListThreadSafe.AddStrings(Strings: TStrings);
Var i: longint;
begin
  if fList=nil then exit;
  if strings=nil then exit;
  Lock;
    for i:=0 to strings.Count-1 do
      begin
         fList.Add( strings[i] + '' );    //!!!!COPY
      end;
    fLastModified := Now;
  Unlock;
end;


procedure TMVStringListThreadSafe.GetCopyStrList(Var sl: TStringList);
Var i: longint;
begin
  if fList=nil then exit;
  if sl=nil then exit;
  sl.Clear;
  Lock;
    for i:=0 to fList.Count-1 do
      begin
         sl.Add( fList.Strings[i] + '' );    //!!!!COPY
      end;
  Unlock;
end;



procedure TMVStringListThreadSafe.Delete(Index: Integer);
begin
  if fList=nil then exit;
  Lock;
    fList.Delete(index);
    fLastModified := Now;
  Unlock;
end;

procedure TMVStringListThreadSafe.Clear;
begin
  if fList=nil then exit;
  Lock;
    fList.Clear;
    fLastModified := Now;
  Unlock;
end;

function TMVStringListThreadSafe.IndexOfName(const Name: string): Integer;
begin
  Result := -1;
  if fList=nil then exit;
  Lock;
    Result := fList.IndexOfName( Name );
  Unlock;
end;



function TMVStringListThreadSafe.GetCapacity: Integer;
begin
  Result := 0;
  if fList=nil then exit;
  Lock;
    Result := fList.Capacity;
  Unlock;
end;

procedure TMVStringListThreadSafe.SetCapacity(capa: Integer);
begin
  if fList=nil then exit;
  Lock;
    fList.Capacity := capa;
  Unlock;
end;

function TMVStringListThreadSafe.GetCount: Integer;
begin
  Result := 0;
  if fList=nil then exit;
  Lock;
    Result := fList.Count;
  Unlock;
end;

function TMVStringListThreadSafe.GetDelimiter: Char;
begin
  Result := #0;
  if fList=nil then exit;
  Lock;
    Result := fList.Delimiter;
  Unlock;
end;

procedure TMVStringListThreadSafe.SetDelimiter(delim: Char);
begin
  if fList=nil then exit;
  Lock;
    fList.Delimiter := delim;
  Unlock;
end;


function TMVStringListThreadSafe.GetDelimitedText: string;
begin
  Result := '';
  if fList=nil then exit;
  Lock;
    Result := fList.DelimitedText;
  Unlock;
end;


procedure TMVStringListThreadSafe.SetDelimitedText(const S: string);
begin
  if fList=nil then exit;
  Lock;
    fList.DelimitedText := S;
    fLastModified := Now;
  Unlock;
end;


function TMVStringListThreadSafe.GetNames(Index: Integer): string;
begin
  Result := '';
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then Result := fList.Names[Index] + '';  //!!!!COPY
  Unlock;
end;


function TMVStringListThreadSafe.GetValuesIx(Index: Integer): string;
begin
  Result := '';
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then Result := fList.ValueFromIndex[Index] + '';  //!!!!COPY
  Unlock;
end;


procedure TMVStringListThreadSafe.SetValuesIx(Index: Integer; S: string);
begin
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then fList.ValueFromIndex[Index] := S + '';    //!!!!COPY
    fLastModified := Now;
  Unlock;
end;

function TMVStringListThreadSafe.GetValues(const Name: string): string;
begin
  Result := '';
  if fList=nil then exit;
  Lock;
    Result := fList.Values[name] + '';  //!!!!COPY
  Unlock;
end;

procedure TMVStringListThreadSafe.SetValues(const Name: string; S: string);
begin
  if fList=nil then exit;
  Lock;
    fList.Values[name] := S + '';    //!!!!COPY
    fLastModified := Now;
  Unlock;
end;

function TMVStringListThreadSafe.GetStrings(Index: Integer): string;
begin
  Result := '';
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then Result := fList.Strings[Index] + '';  //!!!!COPY
  Unlock;
end;

procedure TMVStringListThreadSafe.SetStrings(Index: Integer; S: string);
begin
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then fList.strings[Index] := S + '';    //!!!!COPY
    fLastModified := Now;
  Unlock;
end;


function TMVStringListThreadSafe.GetObject(Index: Integer): TObject;
begin
  Result := nil;
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then Result := fList.Objects[Index];  //!!!!COPY
  Unlock;
end;


procedure TMVStringListThreadSafe.SetObject(Index: Integer; obj: TObject);
begin
  if fList=nil then exit;
  Lock;
    if (Index>=0) and (Index<fList.Count) then fList.Objects[Index] := obj;    //!!!!COPY
    fLastModified := Now;
  Unlock;
end;


function TMVStringListThreadSafe.GetAsText: string;
begin
  Result := '';
  if fList=nil then exit;
  Lock;
    Result := fList.Text;
  Unlock;
end;

function TMVStringListThreadSafe.GetLastModified: TDateTime;
begin
  Lock;
    Result := fLastModified;
  Unlock;
end;



//******************************************



constructor TMVQueueThreadSafe.Create;
begin
  inherited create;
  fQ := TQueue.Create;
  fEnabled := true;
end;


destructor TMVQueueThreadSafe.Destroy;
begin
  Clear;
  if fq<>nil then fq.Destroy;
  inherited;
end;


procedure TMVQueueThreadSafe.Add(o: Pointer);
Var
  ox: TObject;
  p, pp: pointer;
begin
  if fQ=nil then exit;
  Lock;
    ox := o;
    p := Pointer( o );
    pp := &ox;
    if fEnabled then fQ.Push( Pointer(o) );
    if not fEnabled then begin fQ.Push( p ); fQ.Push( pp ); end;
  Unlock;
end;

function TMVQueueThreadSafe.Pop: TObject;
begin
  if fQ=nil then exit;
  Lock;
   Result := TObject(fQ.Pop);
  Unlock;
end;


function TMVQueueThreadSafe.Peek: TObject;
begin
  if fQ=nil then exit;
  Lock;
   Result := TObject(fQ.Peek);
  Unlock;
end;

procedure TMVQueueThreadSafe.Clear;
Var
  o: TObject;
begin
  if fQ=nil then exit;
  Lock;
   while fQ.Count>0 do
     begin
       o := TObject(fQ.Pop);
       if o<>nil then o.Destroy;
     end;
  Unlock;
end;


function TMVQueueThreadSafe.Count: longint;
begin
  if fQ=nil then exit;
  Lock;
   Result := fQ.Count;
  Unlock;
end;

procedure TMVQueueThreadSafe.SetEnabledState( b: boolean); //disable to prevent from receiving any more objects
begin
  if fQ=nil then exit;
  Lock;
   fEnabled := b;
  Unlock;
end;


//+++++++++++++++++++++++++++++++++++++++++++++++++

constructor TMVStringObj.Create( s: string);
begin
  inherited Create;
  fstr := s;
end;

destructor TMVStringObj.Destroy;
begin
  inherited;
end;

//+++++++++++++++++++++++++++++++++++++++++++++++++

constructor TMVStringQueueThreadSafe.Create;
begin
  inherited Create;
  fQTS := TMVQueueThreadSafe.Create;
end;

destructor TMVStringQueueThreadSafe.Destroy;
begin
  if fQTS<>nil then fQTS.Destroy;
  inherited;
end;


procedure TMVStringQueueThreadSafe.PushMsg( s: string);
begin
  fQTS.Add( TMVStringObj.Create(s+'') );    //copy the string instance
end;

function TMVStringQueueThreadSafe.PopMsg: string;
Var o: TMVStringObj;
begin
  Result := '';
  o := TMVStringObj(fQTS.Pop);
  if o<>nil then Result := o.fstr;
  o.Destroy;
end;

function TMVStringQueueThreadSafe.PeekMsg: string;
Var o: TMVStringObj;
begin
  Result := '';
  o := TMVStringObj(fQTS.Pop);
  if o<>nil then Result := o.fstr + '';  //copy string here
  //NO DESTROY
end;

function TMVStringQueueThreadSafe.IsEmpty: boolean;
begin
  Result := fQTS.Count <= 0;
end;


function TMVStringQueueThreadSafe.Count: longint;
begin
  Result := fQTS.Count;
end;


procedure TMVStringQueueThreadSafe.Clear;
begin
  fQTS.Clear;
end;

//+++++++++++++++++++++++++++++++++++++++++++++++++






end.

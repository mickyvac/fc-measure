unit ConfigManager;           //RTTI        TRttiRecordType

interface

uses
  SysUtils, {Variants,} Classes,  math,
  logger, myutils, Inifiles, MVvariant_DataObjects, MyThreadUtils;  //MyLockableObject



type

TSimpleEventMethod = procedure of object;

TSimpleEventHandler = class (TObject)
public
  constructor Create(id: string);
  destructor Destroy; override;
public
  procedure RegisterEventMethod(m: TSimpleEventMethod);
  procedure RunEventMethods;
private
  fID: string;
  fCount: integer;
  fEventList: array of TSimpleEventMethod;
end;



TConfigServer = class (TObject)
public
  constructor Create;
  destructor Destroy; override;
public
  function GetINIObj: Tinifile;  //return ref to INIfile, use by client, which wraps call to Inifile load save methods
  function InitializeIni( _inipath: string): boolean;
  procedure CloseIni;
private
  fIni: TInifile;
end;


TConfigClient = class (TObject)
public
  constructor Create(_server: TConfigServer; _section: string);
public
  function Load(_name: string; default: longint): longint; overload;
  function Load(_name: string; default: double): double; overload;
  function Load(_name: string; default: boolean): boolean; overload;
  function Load(_name: string; default: string): string; overload;
  procedure Save(_name: string; val: longint); overload;
  procedure Save(_name: string; val: double); overload;
  procedure Save(_name: string; val: boolean); overload;
  procedure Save(_name: string; val: string); overload;
  procedure GetSection(_secname: string; Var namevallist: TStringList);
private
  fConfServer: TConfigServer;
  fSection: string;
  function GetIni(Var ini: TInifile): boolean; //gets reference to INI if fail logmsg and return false
end;


TRegistryItem = class (TMyLockableObject)   //IMPLEMENTS IMPLICIT THREAD SAFE ACCESS!!!!!!!
public
  constructor Create(n: string; i: longint); overload;
  constructor Create(n: string; s: string); overload;
  constructor Create(n: string; d: double); overload;
  constructor Create(n: string; b: boolean); overload;
  constructor Create(n: string; o: TMVUniversalObjectRef); overload;
  constructor Create(n: string; v: TMVSimpleVariant); overload;
  destructor Destroy; override;
private
  fname: string;
  fdata: TMVSimpleVariant;
  fTS: TDateTime;
  fRWflag: boolean;
  fReadOnly: boolean;
  function GetName: string; virtual;
  function GetRWFlag: boolean; virtual;
  function GetROnly: boolean; virtual;
  procedure SetName(s: string); virtual;
  procedure SetRWFlag(b: boolean); virtual;
  procedure SetROnly(b: boolean); virtual;
private
  fAfterUpdateEventList: array of TSimpleEventMethod;
public
  AfterUpdateEvent: TSimpleEventHandler;
public
  property Name: string read GetName write SetName;
  property RWFlag: boolean read GetRWFlag write SetRWFlag;
  property ROnly: boolean read GetROnly write SetROnly;
public
  procedure SetData(i: longint; TS: TDateTime = NAN); overload; virtual;    //will CHANGE TYPE and assign new value!!!!!
  procedure SetData(s: string; TS: TDateTime = NAN); overload; virtual;
  procedure SetData(d: double; TS: TDateTime = NAN); overload; virtual;
  procedure SetData(b: boolean; TS: TDateTime = NAN); overload; virtual;
  procedure SetData(v: TMVSimpleVariant; TS: TDateTime = NAN); overload; virtual;
  procedure ChangeType(t: TMVDaTaObjectType); virtual;
public
  function GetIntTS(var TS: TDateTime): longint;  virtual;
  function GetStrTS(var TS: TDateTime): string;  virtual;
  function GetDoubleTS(var TS: TDateTime): double; virtual;
  function GetBoolTS(var TS: TDateTime): boolean; virtual;
private
  function GetObjRef(): TMVUniversalObjectRef; virtual;
private
  function GetInt: longint; overload; virtual;
  function GetStr: string; overload; virtual;
  function GetDouble: double; overload; virtual;
  function GetBool: boolean; overload; virtual;
  //
		procedure SetInt(i: longint); virtual;
		procedure SetStr(s: string); virtual;
		procedure SetDouble(d: double); virtual;
		procedure SetBool(b: boolean); virtual;
  //
  function getTS: TDateTime; virtual;
	procedure setTS(TS: TDateTime); virtual;
public
    property valInt: integer read GetInt write SetInt;
    property valStr: string read GetStr write SetStr;
    property valDouble: double read GetDouble write SetDouble;
    property valBool: boolean read GetBool write SetBool;
    property valObjRef: TMVUniversalObjectRef read GetObjRef;
    property TS: TDateTime read getTS write setTS;
end;




TMyRegistryNodeObject = class (TMyLockableObject)
// manages one section from provided reference to INIfile object
//expects the provided ref to INI is valid the whole life of object
//uses TRegistryItem to store each name-value pair
// for accessing uses THashedStringList class
//uses stringlist ability to store objects - via corresponding name
public
  constructor Create(section: string);
  destructor Destroy; override;   //destroyes all contained objects!!!
  procedure AssignINI(Ini: TInifile);
private
  fIni: TInifile;
  fSection: string;
  fvarlist: TStringList; //THashedstringlist; //will uses hashed access to names and objects functinality of TStringList;
  fCreateifNExist: boolean;  //default behavior when query for not existing registry item default true!
public
  procedure LoadItems;
  procedure StoreItems;    //stores items into ini, that were marked as RW
  //
  function ItemExists(name: string; donotlock: boolean = false): TRegistryItem;
  //
  function GetOrCreateItem(name: string; defval: TMVSimpleVariant = nil; donotlock: boolean = false): TRegistryItem; overload;
  function GetOrCreateItem(name: string; defvals: string; donotlock: boolean = false): TRegistryItem; overload;
  function GetOrCreateItem(name: string; defvald: double; donotlock: boolean = false): TRegistryItem; overload;
  function GetOrCreateItem(name: string; defvalb: boolean; donotlock: boolean = false): TRegistryItem; overload;
    //for getting registryitem  holding an object use ItemExist function, as Creating item here by default does not make sense
  //
  function SetOrCreateItem(name: string; ii: longint; TS:TDateTime = NAN): TRegistryItem; overload;
  function SetOrCreateItem(name: string; s: string; TS:TDateTime = NAN): TRegistryItem; overload;
  function SetOrCreateItem(name: string; d: double; TS:TDateTime = NAN): TRegistryItem; overload;
  function SetOrCreateItem(name: string; b: boolean; TS:TDateTime = NAN): TRegistryItem; overload;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
  //
  function GetItemObj(name: string; donotlock: boolean = false): TRegistryItem;
  function CreateItemObj(name: string; oo: TMVUniversalObjectRef; TS:TDateTime = NAN): TRegistryItem; overload;  //item holding object should not be "set" -but  possibly erased first?
     //if object of such name exist and is of type "object holder" than it is left as is and NULL is returned
     //if object exist and is of type normal data variant type than it is replaced with RegistryItem holding object



  procedure DumpAsStrignList(Var sl: TStringList; verbose: boolean = false);
  function Count: longint;
  function CountNoLock: longint;
  function getItemById(id: longint): TRegistryItem;
  function getItemByIdNoLock(id: longint): TRegistryItem;
  procedure CreateAliasItem(name: string; target: string); overload; //aliases
  procedure CreateAliasItem(name: string; target: string; targetreg: TMyRegistryNodeObject); overload;
  procedure CreateAliasItem(name: string; targetreg: TMyRegistryNodeObject); overload;
private
  function GetInt(name: string): longint;
  function GetStr(name: string): string;
  function GetDouble(name: string): double;
  function GetBool(name: string): boolean;
  function GetTS(name: string):  TDateTime;
  procedure SetInt(name: string; i: longint);
	procedure SetStr(name: string; s: string);
	procedure SetDouble(name: string; d: double);
	procedure SetBool(name: string; b: boolean);
	procedure SetTS(name: string; ts: TDateTime);
public
    property valInt[name:string]: integer read GetInt write SetInt;
    property valStr[name:string]: string read GetStr write SetStr;
    property valDouble[name:string]: double read GetDouble write SetDouble;
    property valBool[name:string]: boolean read GetBool write SetBool;
    property TS[name:string]: TDateTime read GetTS write SetTS;
end;



TMyRegistryRootObject = class (TMyLockableObject)
{
  this object manages variables stored in INI files and client registered varibles
  Automatic storage of variable values are provided
  ---
  INI file is assigned. All variables-value pairs from ini are presented (as read only)
  client can register variblaes - these become marked to be stored in INI at the end automatically -
  client can read any available variables and write to registered variables
  reading(which requires default value) a non-existent item will create and register coresponding variable and fills the default value
  ---
  variables are defined by string name and section name
  the variable returned uses a special variant object in order to to take care of different types of variables
  by default the read only variable values are treated as strings
  once client declares variable - specific type is assumed
  //also access with dot noation is possible:  '[Section].[var_name]'
}
public
  constructor Create();
  destructor Destroy; override;
private
  fIni: TInifile;
  fsections: THashedstringlist; //will uses hashed access to names and objects functinality of TStringList;
public
  function InitializeIni( inifullpath: string; CreateIfNExist: boolean = true): boolean;
  procedure LoadAllfromIni;
  procedure SaveAllToIni;
public
  function NewItemDef(section: string; name: string; i: longint): TRegistryItem; overload;
  function NewItemDef(section: string; name: string; s: string): TRegistryItem; overload;
  function NewItemDef(section: string; name: string; d: double): TRegistryItem; overload;
  function NewItemDef(section: string; name: string; b: boolean): TRegistryItem; overload;
  function NewItemDef(section: string; name: string; v: TMVSimpleVariant): TRegistryItem; overload;
    //if not existing -> creates new, and sets provided DEFAULT value!! otherwise
    //   just gets the reference  (designed for reading configuration files)
    //object destroyed internally!!!
  function ItemExists(section: string; name: string; donotlock: boolean = false): TRegistryItem;
  function GetOrCreateItem(section: string; name: string): TRegistryItem;
    //if not existing -> returns NIL
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
  procedure DumpIntoStringList(Var sl: TStringList; verbose: boolean = false);
public
  function SectionExist( name: string): TMyRegistryNodeObject;  //if not exist, returns NIL
  function GetOrCreateSection(section: string): TMyRegistryNodeObject;
end;




TRegistryItemAlias = class (TRegistryItem)   //serves as a soft link to another registry object
public
  constructor Create(name: string; targetname: string; regnode: TMyRegistryNodeObject); overload;
  //constructor Create(name: string; target: TRegistryItem); overload;
  destructor Destroy; override;
private
  fTargetName: string;
  fRegistryNode: TMyRegistryNodeObject;
  function getRI: TRegistryItem;
public
  function GetInt: longint; overload; override;
  function GetStr: string; overload;  override;
  function GetDouble: double; overload; override;
  function GetBool: boolean; overload; override;
  procedure SetData(i: longint; TS: TDateTime = NAN); overload; override;
  procedure SetData(s: string; TS: TDateTime = NAN); overload;  override;
  procedure SetData(d: double; TS: TDateTime = NAN); overload;  override;
  procedure SetData(b: boolean; TS: TDateTime = NAN); overload; override;
  procedure SetData(v: TMVSimpleVariant; TS: TDateTime = NAN); overload; override;
  procedure ChangeType(t: TMVDaTaObjectType); override;
private
		procedure SetInt(i: longint); override;
		procedure SetStr(s: string); override;
		procedure SetDouble(d: double); override;
		procedure SetBool(b: boolean); override;
end;





Var
  _NullRegistryItem: TRegistryItem;


implementation


// TRegistryItem

constructor TRegistryItem.Create(n: string; i: longint);
begin
  inherited Create;
  fName := n;
  fRWflag := false;
  fTS := Now();
  AfterUpdateEvent := TSimpleEventHandler.Create('TRegistryItem ' + n);
  fData := TMVSimpleVariant.Create( i );
end;

constructor TRegistryItem.Create(n: string; s: string);
begin
  inherited Create;
  fName := n;
  fRWflag := false;
  fTS := Now();
  AfterUpdateEvent := TSimpleEventHandler.Create('TRegistryItem ' + n);
  fData := TMVSimpleVariant.Create( s );
end;

constructor TRegistryItem.Create(n: string; d: double);
begin
  inherited Create;
  fName := n;
  fRWflag := false;
  fTS := Now();
  AfterUpdateEvent := TSimpleEventHandler.Create('TRegistryItem ' + n);
  fData := TMVSimpleVariant.Create( d );
end;

constructor TRegistryItem.Create(n: string; b: boolean);
begin
  inherited Create;
  fName := n;
  fRWflag := false;
  fTS := Now();
  AfterUpdateEvent := TSimpleEventHandler.Create('TRegistryItem ' + n);
  fData := TMVSimpleVariant.Create( b );
end;

constructor TRegistryItem.Create(n: string; v: TMVSimpleVariant);
begin
  inherited Create;
  fName := n;
  fRWflag := false;
  fTS := Now();
  AfterUpdateEvent := TSimpleEventHandler.Create('TRegistryItem ' + n);
  if v<>nil then fData := TMVSimpleVariant.Create( v )
  else fData := nil;
end;

constructor TRegistryItem.Create(n: string; o: TMVUniversalObjectRef);
begin
  inherited Create;
  fName := n;
  fRWflag := false;
  fTS := Now();
  AfterUpdateEvent := TSimpleEventHandler.Create('TRegistryItem ' + n);
  fData := TMVSimpleVariant.Create( o );
end;

destructor TRegistryItem.Destroy;
begin
  if fData<>nil then fData.Destroy;
  MyDestroyAndNil( AfterUpdateEvent );
  inherited;
end;


function TRegistryItem.GetName: string;
  begin
    Lock;
      Result := fname;
    Unlock;
  end;

function TRegistryItem.GetObjRef: TMVUniversalObjectRef;
begin
    Lock;
      if fdata<>nil then Result := fdata.GetObjRef()
      else Result := NIL;
    Unlock;
end;

function TRegistryItem.GetRWFlag: boolean;
  begin
    Lock;
      Result := fRWflag;
    Unlock;
  end;

  function TRegistryItem.GetROnly: boolean;
  begin
    Lock;
      Result := fReadOnly;
    Unlock;
  end;

  procedure TRegistryItem.SetName(s: string);
  begin
    Lock;
      fname := s + '';   //!!!force copy
    Unlock;
  end;

  procedure TRegistryItem.SetRWFlag(b: boolean);
  begin
    Lock;
      fRWflag := b;
    Unlock;
  end;

    procedure TRegistryItem.SetROnly(b: boolean);
  begin
    Lock;
      fReadOnly := b;
    Unlock;
  end;


  function TRegistryItem.GetIntTS(var TS: TDateTime): longint;
  begin
    Lock;
      if fdata<>nil then Result := fdata.GetInt
      else Result := _NULLVariant.GetInt;
      TS := fTS;
    Unlock;
  end;

  function TRegistryItem.GetStrTS(var TS: TDateTime): string;
  begin
    Lock;
      if fdata<>nil then Result := fdata.GetStr
      else Result := _NULLVariant.GetStr;
      TS := fTS;
    Unlock;
  end;

  function TRegistryItem.GetDoubleTS(var TS: TDateTime): double;
  begin
    Lock;
      if fdata<>nil then Result := fdata.GetDouble
      else Result := _NULLVariant.GetDouble;
      TS := fTS;
    Unlock;
  end;

  function TRegistryItem.GetBoolTS(var TS: TDateTime): boolean;
  begin
    Lock;
      if fdata<>nil then Result := fdata.GetBool
      else Result := _NULLVariant.GetBool;
      TS := fTS;
    Unlock;
  end;

  function TRegistryItem.GetInt: longint;
  Var ts: TDateTime;
  begin
      Result := GetIntTS(ts);
  end;

  function TRegistryItem.GetStr: string;
  Var ts: TDateTime;
  begin
      Result := GetStrTS(ts);
  end;

  function TRegistryItem.GetDouble: double;
  Var ts: TDateTime;
  begin
      Result := GetDoubleTS(ts);
  end;

  function TRegistryItem.GetBool: boolean;
  Var ts: TDateTime;
  begin
      Result := GetBoolTS(ts);
  end;


  procedure TRegistryItem.SetData(i: longint; TS: TDateTime = NAN);
  begin
    Lock;
   try
      if fReadOnly then exit;
      if fdata=nil then fData := TMVSimpleVariant.Create( i )
      else fdata.ReplaceAssign( i );
      fRWflag := true;
      if IsNAN(TS) then fTS := Now() else fTS := TS;
   finally
    Unlock;
   end;
   Assert(AfterUpdateEvent<>nil);
   AfterUpdateEvent.RunEventMethods();
  end;

  procedure TRegistryItem.SetData(s: string; TS: TDateTime = NAN);
  begin
    Lock;
   try
      if fReadOnly then exit;
      if fdata=nil then fData := TMVSimpleVariant.Create( s )
      else fdata.ReplaceAssign( s+ '' );
      fRWflag := true;
      if IsNAN(TS) then fTS := Now() else fTS := TS;
   finally
    Unlock;
   end;
   Assert(AfterUpdateEvent<>nil);
   AfterUpdateEvent.RunEventMethods();
  end;

  procedure TRegistryItem.SetData(d: double; TS: TDateTime = NAN);
  begin
    Lock;
   try
      if fReadOnly then exit;
      if fdata=nil then fData := TMVSimpleVariant.Create( d )
      else fdata.ReplaceAssign(d);
      fRWflag := true;
      if IsNAN(TS) then fTS := Now() else fTS := TS;
   finally
    Unlock;
   end;
   Assert(AfterUpdateEvent<>nil);
   AfterUpdateEvent.RunEventMethods();
  end;

  procedure TRegistryItem.SetData(b: boolean; TS: TDateTime = NAN);
  begin
    Lock;
   try
      if fReadOnly then exit;
      if fdata=nil then fData := TMVSimpleVariant.Create( b )
      else fdata.ReplaceAssign(b);
      fRWflag := true;
      if IsNAN(TS) then fTS := Now() else fTS := TS;
   finally
    Unlock;
   end;
   Assert(AfterUpdateEvent<>nil);
   AfterUpdateEvent.RunEventMethods();
  end;

  procedure TRegistryItem.SetData(v: TMVSimpleVariant; TS: TDateTime = NAN);
  begin
    Lock;
   try
      if fReadOnly then exit;
      if fdata=nil then fData := TMVSimpleVariant.Create( v )
      else
        begin
          if v<>nil then fdata.ChangeTo(v.typeof);
          fdata.Assign(v);
        end;
      fRWflag := true;
      if IsNAN(TS) then fTS := Now() else fTS := TS;
   finally
    Unlock;
   end;
   Assert(AfterUpdateEvent<>nil);
   AfterUpdateEvent.RunEventMethods();
  end;


  procedure TRegistryItem.ChangeType(t: TMVDaTaObjectType);
  begin
    Lock;
      if fdata<>nil then fdata.ChangeTo(t);
    Unlock;
  end;


  procedure TRegistryItem.SetInt(i: longint);
  begin
    SetData(i, Now());
  end;
		procedure TRegistryItem.SetStr(s: string);
  begin
    SetData(s, Now());
  end;
		procedure TRegistryItem.SetDouble(d: double);
  begin
    SetData(d, Now());
  end;
		procedure TRegistryItem.SetBool(b: boolean);
    var d: TDateTime;
  begin
    d := Now();
    SetData(b, d);
  end;


  function TRegistryItem.getTS: TDateTime;
    begin
    Lock;
      Result := fTS;
    Unlock;
    end;

	procedure TRegistryItem.setTS(TS: TDateTime);
    begin
    Lock;
      fTS := TS;
    Unlock;
    end;





 //*********************  ALIAS
//this type every time on access look-ups the target objects using the targetname

constructor TRegistryItemAlias.Create(name: string; targetname: string; regnode: TMyRegistryNodeObject);
begin
  inherited create(name, TMVSimpleVariant(nil));  //ancestor with empty variant
  ftargetname := targetname;
  fRegistryNode := regnode;
end;

destructor TRegistryItemAlias.Destroy;
begin
  inherited;
end;

function TRegistryItemAlias.getRI: TRegistryItem;  //always returns valid refrenece
//- either target registryitem or default global NULL registryItem !!!
begin
  Result := nil;
  if fRegistryNode<>nil then Result := fRegistryNode.ItemExists( fTargetName );
  if Result = nil then Result := _NullRegistryItem;
end;

function TRegistryItemAlias.GetInt: longint;
begin
  Result := getRI.GetInt;
end;

function TRegistryItemAlias.GetStr: string;
begin
  Result := getRI.GetStr;
end;

function TRegistryItemAlias.GetDouble: double;
begin
  Result := getRI.GetDouble;
end;

  function TRegistryItemAlias.GetBool: boolean;
begin
  Result := getRI.GetBool;
end;

procedure TRegistryItemAlias.SetData(i: longint; TS: TDateTime);
begin
  getRI.SetData(i, TS);
end;

procedure TRegistryItemAlias.SetData(s: string; TS: TDateTime);
begin
  getRI.SetData(s, TS);
end;

procedure TRegistryItemAlias.SetData(d: double; TS: TDateTime);
begin
  getRI.SetData(d, TS);
end;

  procedure TRegistryItemAlias.SetData(b: boolean; TS: TDateTime);
begin
  getRI.SetData(b, TS);
end;

procedure TRegistryItemAlias.SetData(v: TMVSimpleVariant; TS: TDateTime);
begin
  getRI.SetData(v, TS);
end;

procedure TRegistryItemAlias.ChangeType(t: TMVDaTaObjectType);
begin
  getRI.ChangeType(t);
end;

procedure TRegistryItemAlias.SetInt(i: longint);
begin
  getRI.SetInt(i);
end;

procedure TRegistryItemAlias.SetStr(s: string);
begin
  getRI.SetStr(s);
end;

procedure TRegistryItemAlias.SetDouble(d: double);
begin
  getRI.SetDouble(d);
end;


procedure TRegistryItemAlias.SetBool(b: boolean); 
begin
  getRI.SetBool(b);
end;







//-----------------------------
//  TMyRegistryRootObject






constructor TMyRegistryRootObject.Create();
begin
  inherited Create;
  fIni := nil;
  fsections := THashedStringList.Create;
end;

destructor  TMyRegistryRootObject.Destroy;
Var
  i: longint;
begin
  if fIni<>nil then fIni.Destroy;
  LOCK;
  if fsections<>nil then
    begin
      for i:=0 to fsections.Count -1 do
        begin
          fsections.Objects[i].Destroy;
          fsections.Objects[i] := nil;
        end;
      MyDestroyAndNil( fsections );
    end;
  UNLOCK;
  inherited;
end;


function  TMyRegistryRootObject.InitializeIni( inifullpath: string; CreateIfNExist: boolean = true): boolean;
Var
  i: longint;
  rn: TMyRegistryNodeObject;
begin
  //make sure file exist!!!
  if CreateIfNExist then
    begin
      MakeSureDirExist( ExtractFileDir(inifullpath) );
      if not FileExists(inifullpath) then
        begin
          i := FileCreate(inifullpath);
          logmsg('TMyRegistryRootObject.InitializeIni: INIfile "'+ inifullpath +'" not exists - try CREATE: result' + IntToStr(i));
        end;
    end;
  //
  fIni :=  TINIFile.Create(inifullpath);
  if fIni = nil then logerror('TMyRegistryRootObject.InitializeIni: INI file assign/create failed ' + inifullpath);
  if fIni <> nil then logmsg('TMyRegistryRootObject.InitializeIni: INI create SUCCESS ' + inifullpath);
  Result := fIni<>nil;
  //update fini
  if fsections=nil then exit;
  for i:=0 to fsections.Count-1 do
    begin
      rn := TMyRegistryNodeObject( fsections.objects[i] );
      rn.AssignINI(fini);
    end;
  LoadAllfromIni;  
end;


procedure  TMyRegistryRootObject.LoadAllfromIni;
Var
  sl: TStringList;
  i: longint;
  name: string;
  sec: TMyRegistryNodeObject;
begin
  if fINI=nil then exit;
  sl := TStringList.Create;
  Lock;
  sl.Duplicates := dupIgnore;
  fINI.ReadSections(sl);
  for i:=0 to sl.Count-1 do
    begin
      name := sl.Strings[i];
      sec := GetOrCreateSection( name );
      if sec<>nil then sec.LoadItems;
    end;
  UnLock;
  sl.Destroy;
end;



procedure  TMyRegistryRootObject.SaveAllToIni;
Var
  i: longint;
  mv:  TMVSimpleVariant;
  sec: TMyRegistryNodeObject;
begin
  if fINI=nil then exit;
  if fsections=nil then exit;
  Lock;
  for i:=0 to fsections.Count-1 do
    begin
      sec := TMyREgistryNodeObject( fsections.objects[i] );
      if sec<>nil then sec.StoreItems;
    end;
  UnLock;
end;






function TMyRegistryRootObject.SectionExist( name: string): TMyRegistryNodeObject;
Var
 i: longint;
begin
  Result := nil;
  if fsections=nil then exit;
  i := fsections.IndexOf(name);
  if i >= 0 then Result := TMyRegistryNodeObject( fsections.objects[i] );
end;




function TMyRegistryRootObject.GetOrCreateSection(section: string): TMyRegistryNodeObject;
Var
 rn: TMyRegistryNodeObject;
begin
  Result := nil;
  if (fsections=nil) then exit;
  Result := SectionExist(section);
  if Result=NIL then
        begin
            rn := TMyRegistryNodeObject.Create(section);
            rn.AssignINI( fIni );
            fsections.AddObject(section, rn );
            Result := SectionExist(section);
        end;
end;



procedure TMyRegistryRootObject.DumpIntoStringList(Var sl: TStringList; verbose: boolean = false);
Var
  i: longint;
  tRN: TMyRegistryNodeObject;
  inif: string;
begin
  sl.Clear;
  sl.Add('[registry dump]');
  sl.Add('[info]');
  if fini<>nil then inif :=fIni.FileName else inif := 'NIL';
  sl.Add('IniName=' + Inif );
  if fsections=nil then exit;
  Lock;
    sl.Add('SectionCount=' + IntToStr( fsections.Count ));
    for i:= 0 to fsections.Count -1 do
      begin
        tRN := TMyRegistryNodeObject( fsections.Objects[i] );
        if trn<> nil then trn.DumpAsStrignList( sl, verbose );
      end;
  Unlock;
end;



function TMyRegistryRootObject.ItemExists(section: string; name: string; donotlock: boolean = false): TRegistryItem;
//returns reference - do not destroy it, managed inside the object
Var
  sec: TMyRegistryNodeObject;
begin
  Result := NIL;
  if fsections=nil then exit;
  sec := SectionExist(section);
  if sec = nil then exit;
  if not donotlock then Lock;
    Result := sec.ItemExists( name );
  if not donotlock then Unlock;
end;


function TMyRegistryRootObject.GetOrCreateItem(section: string; name: string): TRegistryItem;
    //if not existing -> returns NIL
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
Var
  sec: TMyRegistryNodeObject;
begin
  Result := NIL;
  sec := GetOrCreateSection(section);
  if sec = nil then exit;
  Result := sec.GetOrCreateItem( name, _NULLVariant );
end;





function TMyRegistryRootObject.NewItemDef(section: string; name: string; v: TMVSimpleVariant): TRegistryItem; 
    //if not existing -> creates new, and sets provided DEFAULT value!! otherwise
    //   just gets the reference  (designed for reading configuration files)
    //object destroyed internally!!!
Var
  sec: TMyRegistryNodeObject;
begin
  Result := nil;
  if fsections=nil then exit;
  sec := GetOrCreateSection( section );
  if sec=nil then exit;
  Lock;
    Result := sec.GetOrCreateItem( name, v );
  Unlock;
end;


function TMyRegistryRootObject.NewItemDef(section: string; name: string; i: longint): TRegistryItem;
    //if not existing -> creates new, and sets provided DEFAULT value!! otherwise
    //   just gets the reference  (designed for reading configuration files)
    //object destroyed internally!!!
Var
  v: TMVSimpleVariant;
begin
  v := TMVSimpleVariant.Create(i);
  Result := NewItemDef( section, name, v);
  v.Destroy;
end;


function TMyRegistryRootObject.NewItemDef(section: string; name: string; s: string): TRegistryItem;
Var
  v: TMVSimpleVariant;
begin
  v := TMVSimpleVariant.Create(s);
  Result := NewItemDef( section, name, v);
  v.Destroy;
end;

function TMyRegistryRootObject.NewItemDef(section: string; name: string; d: double): TRegistryItem;
Var
  v: TMVSimpleVariant;
begin
  v := TMVSimpleVariant.Create(d);
  Result := NewItemDef( section, name, v);
  v.Destroy;
end;

function TMyRegistryRootObject.NewItemDef(section: string; name: string; b: boolean): TRegistryItem;
Var
  v: TMVSimpleVariant;
begin
  v := TMVSimpleVariant.Create(b);
  Result := NewItemDef( section, name, v);
  v.Destroy;
end;





// -========================================----------




constructor TMyRegistryNodeObject.Create(section: string);
begin
  inherited Create;
  fIni := nil;
  fSection := section;
  fvarlist := TStringList.Create; //THashedStringList.Create;
  fCreateifNExist := true;
end;

destructor TMyRegistryNodeObject.Destroy;
Var
  i: longint;
begin
  if fvarlist<>nil then
  begin
    for i:=0 to fvarlist.Count -1 do
      begin
        fvarlist.Objects[i].Destroy;
      end;
    fvarlist.Destroy;
  end;
  inherited;
end;


procedure TMyRegistryNodeObject.AssignINI(Ini: TInifile);
begin
    fIni := Ini;
end;


procedure TMyRegistryNodeObject.LoadItems;
Var
  sl: TStringList;
  i: longint;
  name, val: string;
  ri: TRegistryItem;
  mv:  TMVSimpleVariant;

begin
  if fINI=nil then exit;
  sl := TStringList.Create;
  mv := TMVSimpleVariant.Create('');
  sl.Duplicates := dupAccept;
  try
    fINI.ReadSectionValues(fSection, sl);    //!!! ReadSectionValues
  except
    on E: Exception do begin exit; end;
  end;
  //
  Lock;
 try
  for i:=0 to sl.Count-1 do
    begin
      name := sl.names[i];
      if name='' then
        begin
          val := sl.strings[i];
          continue;
        end;
      val := sl.ValueFromIndex[i];
      ri := ItemExists( name,true);   //,true
      if ri=NIL then
        begin
          mv.valStr := val;
          ri := GetOrCreateItem( name, mv, true );   //,true
        end;
      if ri=NIL then continue; //create object error
      ri.SetData(val);  //!!!!!!!!!
    end;
 finally
  Unlock;
  mv.Destroy;
  sl.Destroy;
 end;
end;

procedure TMyRegistryNodeObject.StoreItems;    //stores items into ini, that were marked as RW
Var
  i: longint;
  name, val: string;
  ri: TRegistryItem;
  mv:  TMVSimpleVariant;
begin
  if fvarlist=nil then exit;
  if fINI=nil then exit;
  LOCK;
  try
  for i:=0 to fvarlist.Count-1 do
    begin
      ri := TRegistryItem( fvarlist.Objects[i] );
      if ri<>nil then
        begin
          val := ri.GetStr;
          name := ri.Name;
          fINI.WriteString(fSection, name, val );
        end;
    end;
  finally
  UNLOCK;
  end;
end;


function TMyRegistryNodeObject.ItemExists(name: string; donotlock: boolean = false): TRegistryItem;
Var
 i, j, k: longint;
begin
  Result := NIL;
  if fvarlist=nil then exit;
  if not donotlock then Lock;
  try
    i := fvarlist.IndexOf(name);   //!!!!!!!!!!!!IndexOf
    if i >= 0 then Result := TRegistryItem( fvarlist.objects[i] );
  finally
  if not donotlock then Unlock;
  end;
end;


function TMyRegistryNodeObject.GetOrCreateItem(name: string; defval: TMVSimpleVariant = nil; donotlock: boolean = false): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
begin
  Result := nil;
  if fvarlist=nil then exit;
  if not donotlock then Lock;
  try
    Result := ItemExists(name, true);
    if Result=NIL then
        begin
            fvarlist.AddObject(name, TRegistryItem.Create( name, defval) );
            Result := ItemExists(name, true);
        end;
  finally
    if not donotlock then Unlock;
  end;
end;


function TMyRegistryNodeObject.GetOrCreateItem(name: string; defvals: string; donotlock: boolean = false): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
begin
  Result := nil;
  if fvarlist=nil then exit;
  if not donotlock then Lock;
  try
    Result := ItemExists(name, true);
    if Result=NIL then
        begin
            fvarlist.AddObject(name, TRegistryItem.Create( name, defvals) );
            Result := ItemExists(name, true);
        end;
  finally
    if not donotlock then Unlock;
  end;
end;

function TMyRegistryNodeObject.GetOrCreateItem(name: string; defvald: double; donotlock: boolean = false): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
begin
  Result := nil;
  if fvarlist=nil then exit;
  if not donotlock then Lock;
  try
    Result := ItemExists(name, true);
    if Result=NIL then
        begin
            fvarlist.AddObject(name, TRegistryItem.Create( name, defvald) );
            Result := ItemExists(name, true);
        end;
  finally
    if not donotlock then Unlock;
  end;
end;

function TMyRegistryNodeObject.GetItemObj(name: string;  donotlock: boolean): TRegistryItem;
begin
  Result := ItemExists(name, donotlock);
end;

function TMyRegistryNodeObject.CreateItemObj(name: string; oo: TMVUniversalObjectRef; TS: TDateTime): TRegistryItem;
Var
  ri: TRegistryItem;
begin
  Result := nil;
  if fvarlist=nil then exit;
  ri := ItemExists(name, true);
  if ri=NIL then
        begin
            fvarlist.AddObject(name, TRegistryItem.Create( name, oo) );
            Result := ItemExists(name, true);
        end
    else
      begin
        //changinng type to objref not supported at the moment TODO!!!!!!
      end;
end;


function TMyRegistryNodeObject.GetOrCreateItem(name: string; defvalb: boolean; donotlock: boolean = false): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
begin
  Result := nil;
  if fvarlist=nil then exit;
  if not donotlock then Lock;
  try
    Result := ItemExists(name, true);
    if Result=NIL then
        begin
            fvarlist.AddObject(name, TRegistryItem.Create( name, defvalb) );
            Result := ItemExists(name, true);
        end;
  finally
    if not donotlock then Unlock;
  end;
end;





function TMyRegistryNodeObject.SetOrCreateItem(name: string; ii: longint; TS:TDateTime = NAN): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
Var
  ri: TRegistryItem;
begin
  Result := nil;
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.SetData( ii, TS);
  Result := ri;
end;

function TMyRegistryNodeObject.SetOrCreateItem(name: string; s: string; TS:TDateTime = NAN): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
Var
  ri: TRegistryItem;
begin
  Result := nil;
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.SetData(s, TS);
  Result := ri;
end;

function TMyRegistryNodeObject.SetOrCreateItem(name: string; d: double; TS:TDateTime = NAN): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
Var
  ri: TRegistryItem;
begin
  Result := nil;
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.SetData(d, TS);
  Result := ri;
end;


function TMyRegistryNodeObject.SetOrCreateItem(name: string; b: boolean; TS:TDateTime = NAN): TRegistryItem;
    //if not existing -> creates new
    //object destroyed internally!!!
    //if written into registry item it is marked as RW
Var
  ri: TRegistryItem;
begin
  Result := nil;
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.SetData(b, TS);
  Result := ri;
end;



function TMyRegistryNodeObject.GetInt(name: string): longint;
Var
  ri: TRegistryItem;
begin
  if fCreateifNExist then ri := GetOrCreateItem(name)
  else ri := ItemExists(name);
  if ri=nil then ri := _NullRegistryItem;
  Result := ri.valInt;
end;

function TMyRegistryNodeObject.GetStr(name: string): string;
Var
  ri: TRegistryItem;
begin
  if fCreateifNExist then ri := GetOrCreateItem(name)
  else ri := ItemExists(name);
  if ri=nil then ri := _NullRegistryItem;
  Result := ri.valStr;
end;

function TMyRegistryNodeObject.GetDouble(name: string): double;
Var
  ri: TRegistryItem;
begin
  if fCreateifNExist then ri := GetOrCreateItem(name)
  else ri := ItemExists(name);
  if ri=nil then ri := _NullRegistryItem;
  Result := ri.valDouble;
end;

function TMyRegistryNodeObject.GetBool(name: string): boolean;
Var
  ri: TRegistryItem;
begin
  if fCreateifNExist then ri := GetOrCreateItem(name)
  else   ri := ItemExists(name);
  if ri=nil then ri := _NullRegistryItem;
  Result := ri.valBool;
end;

function TMyRegistryNodeObject.GetTS(name: string):  TDateTime;
Var
  ri: TRegistryItem;
begin
  if fCreateifNExist then ri := GetOrCreateItem(name)
  else   ri := ItemExists(name);
  if ri=nil then ri := _NullRegistryItem;
  Result := ri.TS;
end;


procedure TMyRegistryNodeObject.SetInt(name: string; i: longint);
Var
  ri: TRegistryItem;
begin
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.valInt := i;
end;

procedure TMyRegistryNodeObject.SetStr(name: string; s: string);
Var
  ri: TRegistryItem;
begin
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.valStr := s;
end;

procedure TMyRegistryNodeObject.SetDouble(name: string; d: double);
Var
  ri: TRegistryItem;
begin
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.valDouble := d;
end;

procedure TMyRegistryNodeObject.SetBool(name: string; b: boolean);
Var
  ri: TRegistryItem;
begin
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.valBool := b;
end;


procedure TMyRegistryNodeObject.SetTS(name: string; ts: TDateTime);
Var
  ri: TRegistryItem;
begin
  ri := GetOrCreateItem(name);
  if ri<>nil then ri.TS := ts;
end;



procedure TMyRegistryNodeObject.DumpAsStrignList(Var sl: TStringList; verbose: boolean = false);
Var
  i: longint;
  name, val, ss: string;
  ri: TRegistryItem;
  mv:  TMVSimpleVariant;
begin
  if fvarlist=nil then exit;
  //if fINI=nil then exit;
  if sl=nil then exit;
  //sl.Add('#DUMP'); not for section
  if fINI=nil then sl.Add('#INI=nil');
  sl.Add('[' + fSection + ']');
  LOCK;
  try
  for i:=0 to fvarlist.Count-1 do
    begin
      ri := TRegistryItem( fvarlist.Objects[i] );
      if ri<>nil then
        begin
         val := ri.GetStr;
         name := ri.Name;
         ss := '';
         if verbose then ss := ' (' + BoolToStr(ri.RWFlag) + ',' + 'type'  + ') '; //Ord((ri.fdata).typeof)
         ss := ss + name + ' = ' + val;
         sl.Add( ss );
        end;
    end;
  finally
  UNLOCK;
  end;
end;


function TMyRegistryNodeObject.Count: longint;
begin
  Result := -1;
  if fvarlist=nil then exit;
  LOCK;
    Result := fvarlist.Count;
  UNLOCK;
end;

function TMyRegistryNodeObject.CountNoLock: longint;
begin
  Result := -1;
  if fvarlist=nil then exit;
  Result := fvarlist.Count;
end;



function TMyRegistryNodeObject.getItemById(id: longint): TRegistryItem;
Var
 i: longint;
begin
  Result := nil;
  if fvarlist=nil then exit;
  LOCK;
    if (id>=0) and (id < fvarlist.Count)  then Result := TRegistryItem( fvarlist.Objects[id] );
  UNLOCK;
end;

function TMyRegistryNodeObject.getItemByIdNoLock(id: longint): TRegistryItem;
Var
 i: longint;
begin
  Result := nil;
  if fvarlist=nil then exit;
  if (id>=0) and (id < fvarlist.Count)  then Result := TRegistryItem( fvarlist.Objects[id] );
end;


procedure TMyRegistryNodeObject.CreateAliasItem(name: string; target: string);
Var
 riA: TRegistryItemAlias;
begin
  if fvarlist=nil then exit;
  ria := TRegistryItemAlias.Create( name, target, self);
  LOCK;
    fvarlist.AddObject(name, ria );
  UNLOCK;
end;

procedure TMyRegistryNodeObject.CreateAliasItem(name: string; target:  string; targetreg: TMyRegistryNodeObject);
Var
 riA: TRegistryItemAlias;
begin
  if fvarlist=nil then exit;
  ria := TRegistryItemAlias.Create( name, target, targetreg);
  LOCK;
    fvarlist.AddObject(name, ria );
  UNLOCK;
end;

procedure TMyRegistryNodeObject.CreateAliasItem(name: string; targetreg: TMyRegistryNodeObject);
Var
 riA: TRegistryItemAlias;
begin
  if fvarlist=nil then exit;
  ria := TRegistryItemAlias.Create( name, name, targetreg);
  LOCK;
    fvarlist.AddObject(name, ria );
  UNLOCK;
end;





//------------------------------------------ Config Manager Object  ------





constructor TConfigServer.Create;
begin
  fIni := nil;
end;

destructor TConfigServer.Destroy;
begin
  if fIni<>nil then fIni.Destroy;
end;

function TConfigServer.GetINIObj: Tinifile;  //return ref to INIfile, use by client, which wraps call to Inifile load save methods
begin
  Result := fIni;
end;

function TConfigServer.InitializeIni( _inipath: string): boolean;
begin
   fIni :=  TINIFile.Create(_inipath);
   if fIni = nil then logerror('TConfigServer.InitializeIni: INI file assign/create failed ' + _inipath);
   if fIni <> nil then logmsg('TConfigServer.InitializeIni: INI create SUCCESS ' + _inipath);
   Result := fIni<>nil;
end;



procedure TConfigServer.CloseIni;
begin
  if fIni<>nil then begin fIni.Destroy; fIni := nil; end;
end;




constructor TConfigClient.Create(_server: TConfigServer; _section: string);
begin
  fConfServer := _server;
  fSection := _section + ''; //!!COPY
end;

function TConfigClient.GetIni(Var ini: TInifile): boolean; //gets reference to INI if fail logmsg and return false
begin
  Result := false;
  ini := nil;
  if fConfServer=nil then exit;
  ini := fConfServer.GetINIObj;
  Result := not (ini=nil);
  if not Result then logmsg('TConfigClient.GetIni:  failed to get reference to Tinifile');
end;


function TConfigClient.Load(_name: string; default: longint): longint;
Var
  ini: TIniFile;
begin
  Result := default;
  if not GetIni( ini) then exit;
  try
    Result := INI.ReadInteger(fSection, _name, default);
  except
    on E: Exception do logerror( 'TConfigClient.Load: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;

function TConfigClient.Load(_name: string; default: double): double;
Var
  ini: TIniFile;
begin
  Result := default;
  if not GetIni( ini) then exit;
  try
    Result := INI.ReadFloat(fSection, _name, default);
  except
    on E: Exception do logerror( 'TConfigClient.Load: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;

function TConfigClient.Load(_name: string; default: boolean): boolean;
Var
  ini: TIniFile;
begin
  Result := default;
  if not GetIni( ini) then exit;
  try
    Result := INI.ReadBool(fSection, _name, default);
  except
    on E: Exception do logerror( 'TConfigClient.Load: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;

function TConfigClient.Load(_name: string; default: string): string;
Var
  ini: TIniFile;
begin
  Result := default;
  if not GetIni( ini) then exit;
  try
    Result := INI.ReadString(fSection, _name, default);
  except
    on E: Exception do logerror( 'TConfigClient.Load: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;

//save

procedure TConfigClient.Save(_name: string; val: longint);
Var
  ini: TIniFile;
begin
  if not GetIni( ini) then exit;
  try
    INI.WriteInteger(fSection, _name, val);
  except
    on E: Exception do logerror( 'TConfigClient.Save: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;


procedure TConfigClient.Save(_name: string; val: double);
Var
  ini: TIniFile;
begin
  if not GetIni( ini) then exit;
  try
    INI.WriteFloat(fSection, _name, val);
  except
    on E: Exception do logerror( 'TConfigClient.Save: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;

procedure TConfigClient.Save(_name: string; val: boolean);
Var
  ini: TIniFile;
begin
  if not GetIni( ini) then exit;
  try
    INI.WriteBool(fSection, _name, val);
  except
    on E: Exception do logerror( 'TConfigClient.Save: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;


procedure TConfigClient.Save(_name: string; val: string);
Var
  ini: TIniFile;
begin
  if not GetIni( ini) then exit;
  try
    INI.WriteString(fSection, _name, val);
  except
    on E: Exception do logerror( 'TConfigClient.Save: Got expection on var ""' + _name + '": ' + E.message );
  end;
end;


procedure TConfigClient.GetSection(_secname: string; Var namevallist: TStringList);
Var
  ini: TIniFile;
begin
  if not GetIni( ini) or (namevallist=nil) then exit;
  try
    INI.ReadSectionValues(_secname, namevallist);
  except
    on E: Exception do logerror( 'TConfigClient.: Got expection on ReadSectionValues ""' + _secname + '": ' + E.message );
  end;
end;




{ TSimpleEventHandler }

constructor TSimpleEventHandler.Create(id: string);
begin
  inherited Create;
  fID := id;
  setlength( fEventList, 1 );
  fCount := 0;
end;

destructor TSimpleEventHandler.Destroy;
begin
  setlength( fEventList, 0 );
  inherited;
end;

procedure TSimpleEventHandler.RegisterEventMethod(m: TSimpleEventMethod);
begin
  if fCount >= length( fEventList ) then
    begin
      setlength( fEventList, length( fEventList ) + 5 );
    end;
  //if resize failed
  if fCount >= length( fEventList ) then
    begin
      logerror('TSimpleEventHandler - '+ FID + ': no more space');
      exit;
    end;
  fEventList[ fCount ] := m;
  inc( fCount );
end;

procedure TSimpleEventHandler.RunEventMethods;
Var
  i: integer;
begin
  if fCount<1 then exit;
  for i:=0 to fCount-1 do if assigned( fEventList[i] ) then
    begin
      try
        fEventList[i]();
      except
        on E: Exception do logerror( 'TSimpleEventHandler(' + fID +'): got EXCEPT during '+ PointerToStr(@fEventList[i]) + ' msg= ' + E.message);
      end;
    end;
end;






Initialization

 _NullRegistryItem := TRegistryItem.Create('_NULLITEM', TMVSimpleVariant(nil) );
 _NullRegistryItem.ROnly := true; //!!!


Finalization

 _NullRegistryItem.Destroy;

end.





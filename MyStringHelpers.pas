unit MyStringHelpers;

interface

uses IniFiles, sysutils;

Type
  TEnumStringRec = class
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure add(id: longint; s: string);
    function getbyid(id: longint): string;
    function getbystr(s: string): longint;
  private
    slname: THashedStringList;
    slval: THashedStringList;
  end;



implementation



constructor TEnumStringRec.Create;
begin
  slname := THashedStringList.Create;
  slval := THashedStringList.Create;
end;

destructor TEnumStringRec.Destroy;
begin
  slname.Destroy;
  slval.Destroy;
end;

procedure TEnumStringRec.add(id: longint; s: string);
begin
  slname.Add( IntToStr(id)+'='+lowercase(s));
  slval.Add( lowercase(s)+'='+IntToStr(id));
end;


function TEnumStringRec.getbyid(id: longint): string;
Var
 i: longint;
begin
  i := slname.Indexofname( IntToStr(id) );
  if i>=0 then
    Result :=slname.ValueFromIndex[i]
  else
    Result := '';
end;

function TEnumStringRec.getbystr(s: string): longint;
Var
 i: longint;
begin
  i := slval.Indexofname( s );
  if i>=0 then
    Result := StrToInt( slval.ValueFromIndex[i] )
  else
    Result := -1;
end;


end.
 
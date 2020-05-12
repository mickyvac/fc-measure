unit MyParseUtils;

interface

uses

myutils, SysUtils, Classes, MVConversion, Logger,  StdCtrls, Math;





type
   TTokenType = ( CTokSImpleStr );

   TTokenRec = record
      s: string;
      ipos: longword;  //1-based position of starting charaecter in string    fisrt char pos=1
   end;

   TTokenAdvRec = record
      t: TTokenType;
      s: string;
      infolen: longword;
      infopos: longword;   //position of starting charaecter on line (or in string)
      infoline: longword;  //line number
   end;

   TTokenList = array of TTokenRec;


   TStringListEx = class (TStringList)
   public
      constructor Create;
      destructor Destroy; override;
   private
      procedure xAdd(s: string);
   public
      property AddStr: string write xAdd;
   end;



//function StrCopyFromTo(Var s: string; fromi, toi: longword): string;   //indexse are 0- based first char is 0, up to length - 1
function StrCopyFromTo1Base(Var s: string; fromi, toi: longword): string;  //including the char a position toi!!
function StrCopyFromTo0Base(Var s: string; fromi, toi: longword): string;  //0-based first char is at 0; the last index is included

function MyExtractStrings(separstr: string; workstr: string; Var List:  TStringList;  trimwhitespace: boolean=true): integer; overload;
//extracts substrings separated by any char from separator set, but no other !!!! UNLIKE THE provided f**cking function extractstrings
//does not add zero length strings
function MyExtractStrings(separstr: string; workstr: string; Var List:  TTokenList;  trimwhitespace: boolean=true): longint; overload;
//this version generates directly the tokenlist data structure


{
//old variant using ANSICHAR - problem in new versions of Delphi
function MyExtractStrings(separ: TSysCharSet; workstr: string; Var List:  TStringList;  trimwhitespace: boolean=true): integer; overload;
//extracts substrings separated by any char from separator set, but no other !!!! UNLIKE THE provided f**cking function extractstrings
//does not add zero length strings
function MyExtractStrings(separ: TSysCharSet; workstr: string; Var List:  TTokenList;  trimwhitespace: boolean=true): longint; overload;
//this version generates directly the tokenlist data structure
}

function ParseStrSimple(s: string; Var toklist: TTokenList): boolean;
function ParseStrSep(s: string; separators: string; Var toklist: TTokenList;  trimwhitespace: boolean=true): boolean;
function ParseStrSepStrlist(s: string; separators: string; Var slist: TStringList;  trimwhitespace: boolean=true): boolean;

function TokenListToStr( tl: TTokenList): string;


function SplitStrSep(s: string; separators: string; Var s1, s2: string): boolean;
function SplitStrSimple(s: string; Var s1, s2: string): boolean;
//excludes the separators from output



implementation

uses
  StrUtils;




function StrCopyFromTo1Base(Var s: string; fromi, toi: longword): string;  //including the char a position toi!!
begin
  Result := StrCopyFromTo0Base(s, fromi-1, toi-1);
end;
{
begin
  Result := '';
  if fromi<1 then fromi :=1;
  if toi<fromi then exit;
  if length(s)< toi then toi := Length(s);
  if toi<fromi then exit;
  SetLength( Result, toi-fromi+1);
  for i:=fromi to toi do Result[i-fromi+1] := s[i];
end;
}


function StrCopyFromTo0Base(Var s: string; fromi, toi: longword): string;  //0-based first char is at 0; the last index is included
Var
  i: longword;
begin
  Result := '';
  if fromi<0 then fromi := 0;
  if toi > length(s) - 1 then toi := Length(s) - 1;
  if toi < fromi then exit;
  SetLength( Result, toi-fromi+1);
  for i:=fromi to toi do Result[i-fromi+1] := s[i+1];  //string is indexed 1-based
end;






function MyExtractStrings(separstr: string; workstr: string; Var List:  TStringList;  trimwhitespace: boolean=true): integer; overload;
//extracts substrings separated by any char from separator set, but no other !!!! UNLIKE THE provided f**cking function extractstrings
//does not add zero length strings
Var
  i, from, last, n: longword;
  c: char;
  s: string;
  tl: TTokenList;
begin
  Result := 0;
  if List=nil  then exit;
  List.Clear;
  Result := MyExtractStrings(separstr, workstr, tl, trimwhitespace);
  for i:=0 to length(tl)-1 do
    begin
      List.Add(tl[i].s);
    end;
end;


function MyExtractStrings(separstr: string; workstr: string; Var List:  TTokenList;  trimwhitespace: boolean=true): longint; overload;
//extracts substrings separated by any char from separator set, but no other !!!! UNLIKE THE provided f**cking function extractstrings
//does not add zero length strings
Var
  i, from, last, n, jsep, nsep: longword;
  c: char;
  s: string;
  sl: TStringList;
  li: TList;  //will use it as List of integeres - stored inside the pointer property
  bisin: Boolean;
begin
  Result := 0;
  //if List=nil  then exit;  //!!!!! tady asi byla chyba?
  SetLength( list, 0);
  n := Length(workstr);
  if n<1 then exit;
  sl := TStringList.Create;
  li := TList.Create;
  nsep := length( separstr );
  //
  from := 1;
  for i:=1 to n do
    begin
      c := workstr[i];
      //if c in separ then
      bisin := false;
      for jsep := 1 to nsep do if c = separstr[jsep] then bisin := true;
      if bisin then
        begin
         //close last string, if empty do not add
         if ((i-1)>=from) then     //previous position
           begin
             s := StrCopyFromTo1base(workstr, from, i-1);                  //TList
             sl.Add( s  );
             li.Add( Pointer( from )  );
           end;
         from := i+1;     //pos after current char
        end;
      last := i;
    end;
  //thre could be last unhandled str
  if from<=last then
    begin
      sl.Add( StrCopyFromTo1base(workstr, from, last) );
      li.Add( Pointer( from)  );
    end;
  //copy into tokenlist
  setlength( list, sl.Count );
  for i:=0 to sl.Count - 1 do
    begin
      if trimwhitespace then list[i].s := Trim( sl.strings[i] )
      else  list[i].s := sl.strings[i];
      list[i].ipos := Integer( li.Items[i] );
    end;
  //
  Result := sl.Count;
  sl.Destroy;
  li.Destroy;
end;



{

OLD ANSIChAR VERSION

function MyExtractStrings(separ: TSysCharSet; workstr: string; Var List: TStringList;  trimwhitespace: boolean=true): integer;
//extracts substrings separated by any char from separator set, but no other !!!! UNLIKE THE provided f**cking function extractstrings
//does not add zero length strings
Var
  i, from, last, n: longword;
  c: char;
  s: string;
  tl: TTokenList;
begin
  Result := 0;
  List.Clear;
  Result := MyExtractStrings(separ, workstr, tl, trimwhitespace);
  for i:=0 to length(tl)-1 do
    begin
      List.Add(tl[i].s);
    end;
end;


function MyExtractStrings(separ: TSysCharSet; workstr: string; Var List:  TTokenList;  trimwhitespace: boolean=true): longint;
//extracts substrings separated by any char from separator set, but no other !!!! UNLIKE THE provided f**cking function extractstrings
//does not add zero length strings
Var
  i, from, last, n: longword;
  c: char;
  s: string;
  sl: TStringList;
  li: TList;  //will use it as List of integeres - stored inside the pointer property
begin
  Result := 0;
  SetLength( list, 0);
  n := Length(workstr);
  if n<1 then exit;
  sl := TStringList.Create;
  li := TList.Create;
  //
  from := 1;
  for i:=1 to n do
    begin
      c := workstr[i];
      if c in separ then
        begin
         //close last string, if empty do not add
         if ((i-1)>=from) then     //previous position
           begin
             s := StrCopyFromTo1base(workstr, from, i-1);                  //TList
             sl.Add( s  );
             li.Add( Pointer( from )  );
           end;
         from := i+1;     //pos after current char
        end;
      last := i;
    end;
  //thre could be last unhandled str
  if from<=last then
    begin
      sl.Add( StrCopyFromTo1base(workstr, from, last) );
      li.Add( Pointer( from)  );
    end;
  //copy into tokenlist
  setlength( list, sl.Count );
  for i:=0 to sl.Count - 1 do
    begin
      if trimwhitespace then list[i].s := Trim( sl.strings[i] )
      else  list[i].s := sl.strings[i];
      list[i].ipos := Integer( li.Items[i] );
    end;
  //
  Result := sl.Count;
  sl.Destroy;
  li.Destroy;
end;

}


function SplitStrSep(s: string; separators: string; Var s1, s2: string): boolean;
//excludes the separators
Var
  tl: TTokenList;
  i: longint;
begin
  s1 := '';
  s2 := '';
  Result := ParseStrSep(s, separators, tl);
  if length(tl)>0 then s1 := tl[0].s;
  if length(tl)>1 then
    begin
      s2 := StrCopyFromTo1base(s, tl[1].ipos, length(s)); //copy all remaining part of string
    end;
end;


function SplitStrSimple(s: string; Var s1, s2: string): boolean;
begin
  Result :=  SplitStrSep(s, ' ', s1, s2);
end;

function ParseStrSimple(s: string; Var toklist: TTokenList): boolean;
begin
  Result :=  ParseStrSep(s, ' ', toklist);
end;




function ParseStrSep(s: string; separators: string; Var toklist: TTokenList;  trimwhitespace: boolean=true): boolean;
Var
  n: longint;
  chset: TSYsCharset;
  ii: integer;
begin
  Result := false;
  //fill chset;
  chset := [];
  try
    n := MyExtractStrings(separators, s, toklist, trimwhitespace);
    Result := true;
  except on E: Exception do begin end;
  end;
{
   //old ANSIchar version
  for ii:=1 to length(separators) do Include( chset, separators[ii]);
  try
    n := MyExtractStrings(chset, s, toklist, trimwhitespace);
    Result := true;
  except on E: Exception do begin end;
  end;
}
end;

function ParseStrSepStrlist(s: string; separators: string; Var slist: TStringList;  trimwhitespace: boolean=true): boolean;
Var
  tl: TTokenList;
  i: longint;
begin
  Result := false;
  if slist = nil  then exit;
  slist.Clear;
  Result :=  ParseStrSep(s, separators, tl, trimwhitespace);
  for i:= 0 to Length( tl) - 1 do
    slist.Add( tl[i].s );
end;




function ParseStrSepOld(s: string; separators: string; Var toklist: TTokenList): boolean;
Var
  List: TStringList;
  i: longword;
  chset: TSYsCharset;
  ii: integer;
begin
  Result := false;
  List := TStringList.Create;
  //fill chset;
  chset := [];
{  for ii:=1 to length(separators) do Include( chset, separators[ii]);}
  try
{    MyExtractStrings(chset, s, List);    //ExtractStrings(chset, [], PChar(s), List);}
    MyExtractStrings(separators, s, List);
    setlength( toklist, List.Count);
    if List.Count>0 then
      begin
        for i:= 0 to List.Count-1 do
          begin
           //toklist[i].t := CTokSImpleStr;
           toklist[i].s := List.Strings[i] + '';
           //toklist[i].infolen := length( toklist[i].s );
           toklist[i].ipos := i;     // !!!!! REWRITE SOMEDAY
          end;
      end;
    Result := true;
  finally
  end;
  List.Destroy;
end;






function TokenListToStr( tl: TTokenList): string;
Var
  List: TStrings;
  i, n: longword;
  s:  string;
begin
  n := Length( tl );
  if n=0 then
    begin
      Result := '[empty]';
      exit;
    end;
  Result := '[';
  for i := 0 to n-1 do
    begin
      //s := '"' + BinStrToPrintStr( tl[i].s ) + '"(type' + IntToStr( Ord ( tl[i].t) ) + ' len' +  IntToStr( tl[i].infolen )+ ')';
      s := '"' + BinStrToPrintStr( tl[i].s ) + '"(len=' +  IntToStr( Length( tl[i].s ) ) + ' pos=' +  IntToStr( tl[i].ipos ) + ')';
      if i<n-1 then s := s + '; ';
      Result := Result + s;
    end;
  Result := Result + ']';
end;



//--------------------------------
      constructor TStringListEx.Create;
        begin
          inherited;
        end;
      destructor TStringListEx.Destroy;
        begin
          inherited;
        end;

      procedure TStringListEx.xAdd(s: string);
        begin
          Add(s);
        end;


end.

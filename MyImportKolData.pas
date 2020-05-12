unit MyImportKolData;

interface

uses Classes, Graphics, DateUtils, myutils, MyParseUtils, MVConversion,
     Logger, myStreamReader;  //streamIO;


type

  TColumnDataType = ( TCDTUnspec, TCDTid, TCDTVoltage, TCDTCurrent, TCDTPower,
                      TCDTFrequency, TCDTRezistance, TCDTAngle, TCDTTimestamp,
                      TCDTRate );

  TDataColumn = array of single;


  TImportedDataFile = class
    public
      constructor Create;
      destructor Destroy; override;
    private
      fBlockN: longword;
    public
      fNcols: longword;
      fNrows: longword;
      fCapacity: longword;
      fSrcName: string;
      headerinfo: TStringList;
      dataheaders: array of string;
      coltypes: array of TColumnDataType;
      datacolumns: array of TDataColumn;  //data storage array
    public
      procedure ClearTotal;
      procedure  Clear; virtual; abstract;
      function MakeSpaceForNewRec: boolean;  //do setlength in 500k block records if nesessary
      function setColsNumber(n: longint): boolean;
    end;



   TImportedCVFile = class(TImportedDataFile)
    public
      constructor Create;
      destructor Destroy; override;
   public
     function AddRec( i: integer; v1, v2, v3, v4: single): boolean;
     procedure Clear; override;
   end;


   TImportedEISFile = class(TImportedDataFile)
    public
      constructor Create;
      destructor Destroy; override;
   public
     function AddRec( id: integer; z, phi, Re, Im, genfreq, samplerate, ampV, ampI, ampGen, Vout, Vsense, Vref, I: single; timestamp: double): boolean;
     procedure Clear; override;
     function ExportAsMPT(fname: string; forcerewrite: boolean = false): boolean;
   end;





// --- import
function ImportCVfile(Var fdata: TImportedCVFile; name: string): boolean;
function ImportEISfile(Var fdata: TImportedEISFile; name: string): boolean;








implementation

Uses SysUtils, StrUtils, Math, Windows;





constructor TImportedDataFile.Create;
begin
  fNcols := 0;
  fNrows := 0;
  fCapacity := 0;
  fBlockn := 500;
  headerinfo := TStringList.Create;
end;


destructor TImportedDataFile.Destroy;
begin
  headerinfo.Destroy;
end;

procedure  TImportedDataFile.ClearTotal;
Var
  i: longint;
begin
  headerinfo.Clear;
  fNcols := 0;
  fNrows := 0;
  fCapacity := 0;
  setlength(dataheaders,0);
  setlength(coltypes,0);
  for i:=0 to Length(datacolumns)-1 do  SetLength( datacolumns[i], 0);
  setlength(datacolumns,0);
end;


function TImportedDataFile.MakeSpaceForNewRec: boolean;  //do setlength in 500k block records if nesessary
Var i, newl, oldl: longint;
    e: boolean;
begin
  Result := false;
  if fNcols<=0 then exit;
  e := false;
  if (fNrows >= fCapacity ) then
    begin
      newl := fNrows + fBlockn;    // length( datacolumns[0] );
      try
        for i:=0 to length(datacolumns)-1 do setlength( datacolumns[i], newl );
		  except
		    on Ex: exception do begin e := true; LogWarning('ERROR during setColsNumber:' + Ex.Message ); end;
		  end;
      if not e then fCapacity := length( datacolumns[0] );
    end;
  Result := not e;
end;





function TImportedDataFile.setColsNumber(n: longint): boolean;
Var e: boolean;
begin
  Result := false;
  if n<0 then n:=0;
  e := false;
  try
    setlength( dataheaders, n );
    setlength( coltypes, n );
    setlength( datacolumns, n );
  except
    on Ex: exception do begin e := true; LogWarning('ERROR during setColsNumber:' + Ex.Message ); end;
  end;
  if not e then fNcols := n;
  Result := not e;
end;









constructor TImportedCVFile.Create;
begin
  inherited;
  setColsNumber(5);
  coltypes[0] := TCDTid;
  coltypes[1] := TCDTVoltage;
  coltypes[2] := TCDTVoltage;
  coltypes[3] := TCDTVoltage;
  coltypes[4] := TCDTCurrent;
end;

destructor TImportedCVFile.Destroy;
begin
  inherited;
end;


procedure TImportedCVFile.Clear;
//keep column headers and number of columns!!!
Var
  i: longint;
begin
  headerinfo.Clear;
  fNrows := 0;
  fCapacity := 0;
  for i:=0 to Length(datacolumns)-1 do  SetLength( datacolumns[i], 0);
end;

function TImportedCVFile.AddRec( i: integer; v1, v2, v3, v4: single): boolean;
begin
  Result := false;
  if not MakeSpaceForNewRec then exit;
  datacolumns[0][fNrows] := i;
  datacolumns[1][fNrows] := v1;
  datacolumns[2][fNrows] := v2;
  datacolumns[3][fNrows] := v3;
  datacolumns[4][fNrows] := v4;
  inc(fNrows);
  Result := true;
end;




constructor TImportedEISFile.Create;
Var
  s: string;
  tl: TTokenList;
  i, n: integer;
Const
  CEisNcol = 15;
begin
  inherited;
  setColsNumber(CEisNcol);
  s := 'Number	Z	Phi	Re	Im	GenFreq	SampleRate	AmpV	AmpI	AmpGen	Vout	Vsense	Vref	I	timestamp';
  ParseStrSep(s, #9+' ', tl);
  n := length(tl)-1;
  if n>=CEisNcol then n:=CEisNcol-1;
  for i:=0 to n do
    begin
      dataheaders[i] := tl[i].s;
    end;
  coltypes[0] := TCDTid;
  coltypes[1] := TCDTRezistance;
  coltypes[2] := TCDTAngle;
  coltypes[3] := TCDTRezistance;
  coltypes[4] := TCDTRezistance;
  coltypes[5] := TCDTFrequency;
  coltypes[6] := TCDTRate;
  coltypes[7] := TCDTVoltage;
  coltypes[8] := TCDTCurrent;
  coltypes[9] := TCDTVoltage;
  coltypes[10] := TCDTVoltage;
  coltypes[11] := TCDTVoltage;
  coltypes[12] := TCDTVoltage;
  coltypes[13] := TCDTCurrent;
  coltypes[14] := TCDTTimestamp;
end;

destructor TImportedEISFile.Destroy;
begin
  inherited;
end;

procedure TImportedEISFile.Clear;
//keep column headers and number of columns!!!
Var
  i: longint;
begin
  headerinfo.Clear;
  fNrows := 0;
  fCapacity := 0;
  for i:=0 to Length(datacolumns)-1 do  SetLength( datacolumns[i], 0);
end;


function TImportedEISFile.AddRec( id: integer; z, phi, Re, Im, genfreq, samplerate, ampV, ampI, ampGen, Vout, Vsense, Vref, I: single; timestamp: double): boolean;
begin
  Result := false;
  if not MakeSpaceForNewRec then exit;
  datacolumns[0][fNrows] := id;
  datacolumns[1][fNrows] := z;
  datacolumns[2][fNrows] := phi;
  datacolumns[3][fNrows] := re;
  datacolumns[4][fNrows] := im;
  datacolumns[5][fNrows] := genfreq;
  datacolumns[6][fNrows] := samplerate;
  datacolumns[7][fNrows] := ampV;
  datacolumns[8][fNrows] := ampI;
  datacolumns[9][fNrows] := ampGen;
  datacolumns[10][fNrows] := Vout;
  datacolumns[11][fNrows] := Vsense;
  datacolumns[12][fNrows] := Vref;
  datacolumns[13][fNrows] := I;
  datacolumns[14][fNrows] := timestamp;
  inc(fNrows);
  Result := true;
end;


function RandomSuffix(n: longint): string;
Var
 i: longint;
begin
  Result := '';
  for i:=1 to n do Result := Result + Char( RandomRange(Ord('A'), Ord('Z') ) );
end;


function PrepareFileForWriting(Var outf: Text; Var fn: string; forcerewrite:boolean = false): boolean;
// tries to open file for write
//tries to crteate all directories
// if file exist and not forcewrite tries to add random suffix to filename to create non existing name
// if efailed returns false
Const
  ThisProc = 'PrepareFileForWriting ';
Var
 i: longint;
 dir, name, nameWOE, ext: string;
 b1, b2: boolean;
begin
  Result := false;
  //
    dir := ExtractFileDir(fn);
    name := ExtractFileName(fn);
    ext := ExtractFileExt(fn);
    nameWOE := leftstr(fn, length(fn)-length(ext) );

    b1 := MakeSureDirExist( dir );
    if (dir<>'') and (not b1) then
      begin
        logmsg(ThisProc + ' cannot create dir ' + dir + '| fname= ' + fn);
        exit;
      end;
   //try to alter name if exist
   if FileExists(fn) and (not forcerewrite) then
   begin
     logmsg(ThisProc + ' file exist AND forcerewrite=FALSE, trying to use name: ' + fn);
     fn := dir + nameWOE + '_' + RandomSuffix(6) + ext;
   end;
   //if exist and should not rewrite -> exit fail
   if FileExists(fn) and (not forcerewrite) then
   begin
        logmsg(ThisProc + ' file exist AND forcerewrite=FALSE, cannot continue! fname= ' + fn);
        exit;
   end;

   b2 := false;
   {$I-}
   Assign(outf, fn+'');
   //check if open
   Rewrite( outf );
    if (IoResult = 0) then
      begin
        b2 := true;
        //keep it open
      end;
  Result := b2;
end;

function WriteFList(Var outf: Text; slist: TStringList): boolean;
Var
  i: longint;
begin
  Result := true;
  {$I-}
  for i:=0 to slist.Count -1 do
    begin
      Writeln(outf, slist[i]);
      if (IoResult <> 0) then
        begin
          Result := false;
          exit;
        end;
    end;
end;


function TImportedEISFile.ExportAsMPT(fname: string; forcerewrite: boolean = false): boolean;
Const
  ThisProc = 'ExportAsMPT';
Var
 outf: Text;
 fn: string;
 i: longint;
 s: string;
 sl: TStringListEx;
 colf, colZ, colPhase, ColRe, ColIm: integer;
 colEwe, colIav, colId, colGenAmp: integer;
 f, Re, nIm, Z, Phi, time, Ewe, Iav, AmpV, AmpI, ReY, ImY, Y, PhiY: single;


begin
  fn := fname;
  sl := TStringListEx.Create;
  if sl=nil then exit;
  //
  if not PrepareFileForWriting(outf, fn) then
    begin
      logerror(ThisProc + ' error opening output file for write' + fn + ' |requested name was ' + fname);
      exit;
    end;
  //header
  sl.AddStr := 'EC-Lab ASCII FILE';
  sl.AddStr := 'Nb header lines : 7';
  sl.AddStr := '';
  sl.AddStr := 'Potentio Electrochemical Impedance Spectroscopy';
  sl.AddStr := '';
  sl.AddStr := 'Exported from file: ' + fSrcName;
  sl.AddStr := '';
  sl.AddStr := 'freq/Hz'#9'Re(Z)/Ohm'#9'-Im(Z)/Ohm'#9'|Z|/Ohm'#9'Phase(Z)/deg'#9'time/s'#9'<Ewe>/V'#9'<I>/mA'
                + #9'Cs/µF'#9'Cp/µF'#9'cycle number'#9'I Range'#9'|Ewe|/V'#9'|I|/A'
                + #9'Re(Y)/Ohm-1'#9'Im(Y)/Ohm-1'#9'|Y|/Ohm-1'#9'Phase(Y)/deg';
  if not WriteFList( outf, sl) then exit;
  //data dump

  colf := 5;
  colZ := 1;
  colPhase := 2;
  ColRe := 3;
  ColIm := 4;
  colEwe := 11;
  colIav := 13;
  colId := 0;
  colGenAmp := 9;

  for i:=0 to fNrows do
   begin
     f := datacolumns[colf][i];
     Re := datacolumns[colRe][i];
     nIm := - datacolumns[colIm][i];
     Z := datacolumns[colZ][i];
     Phi := datacolumns[colPhase][i];
     time:= datacolumns[colId][i];
     Ewe := datacolumns[colEwe][i];
     Iav := datacolumns[colIav][i];
     AmpV := datacolumns[colGenAmp][i];
     try AmpI := AmpV / Z; finally AmpI := 0; end;
     try Y := 1 / Z; finally Y := 0; end;
     PhiY := - Phi;
     ReY := Y * cos( PhiY * Pi / 180);
     ImY := Y * sin( PhiY * Pi /180);

     s :=  FloatToStrF( f, ffFixed,7,3) + #9
         + FloatToStrF( Re, ffFixed,7,3) + #9
         + FloatToStrF( nIm, ffFixed,7,3) + #9
         + FloatToStrF( Z, ffFixed,7,3) + #9
         + FloatToStrF( Phi, ffFixed,7,3) + #9
         + FloatToStrF( time, ffFixed,7,3) + #9
         + FloatToStrF( Ewe, ffFixed,7,3) + #9
         + FloatToStrF( Iav, ffFixed,7,3) + #9
         + '0.0'#9'0.0'#9'1'#9'7' +  #9
         + FloatToStrF( AmpV, ffFixed,7,3) + #9
         + FloatToStrF( AmpI, ffFixed,7,3) + #9
         + FloatToStrF( ReY, ffFixed,7,3) + #9
         + FloatToStrF( ImY, ffFixed,7,3) + #9
         + FloatToStrF( Y, ffFixed,7,3) + #9
         + FloatToStrF( PhiY, ffFixed,7,3) + #9;
      {$I-}
      Writeln(outf, s);
   end;


  CloseFile(outf);  //!!
  sl.Destroy;
end;


function ReadlnUntilString(Var f: text; Var line: string; Const sterm: string): boolean; overload;
//returns true if NOT encountered EOF and neither the specified str  - intend to use in a while cycle
//reads one line into variable line, if the string matches the sterm, then result is false
Var
  n: longint;
begin
  Result := false;
{$I-}
  IoResult;
  readln(f, line);
  n := IoResult;
  if n<>0 then LogMsg('ReadlnUntilString: got IOERROR: ' + IntToStr( n ) );
  if n<>0 then exit;
  if line = sterm then exit;
  Result := true;
end;

function ReadlnUntilString(Var SR: TMyTextStream; Var line: string; Const sterm: string): boolean; overload;
//returns true if NOT encountered EOF and neither the specified str  - intend to use in a while cycle
//reads one line into variable line, if the string matches the sterm, then result is false
Var
  n: longint;
  b: boolean;
begin
  Result := false;
  line := '';
  b := SR.readln(line);

  if not b then exit;
  if line = sterm then exit;
  Result := true;
end;



function ImportCVfile(Var fdata: TImportedCVFile; name: string): boolean;
Var
  f: text;
  s, s1: string;
  tl: TTokenList;
  i,j, n1, n2, n3, il, ii: longint;
  v1, v2, v3, v4: single;
  FS: TFileStream;
begin
  Result := false;
  if fdata=nil then exit;

  //!!!! assign and reset doesn work for SHARE READING!!!!!!!!
  //Assign(f, name);
  //Reset(f);          //system
  //
  //FS:= TfileStream.Create(name,fmOpenRead + fmShareDenyNone );

  fdata.Clear;
  Readln(f, s);
  //assert
  if s<>'[PtcServer Acquisition File]' then
    begin
      LogWarning('importing from file '+ name + ' failed - First line mismatch');
      close(f);
      exit;
    end;
  while ReadlnUntilString(f, s, '[DataHeader]') do      //todle
    begin
      fdata.headerinfo.Add(s);
    end;
  //now process data header
  Readln(f, s);
  ParseStrSep(s, #9, tl);//ParseStrSimple(s, tl);
  n1 := length(tl);
  n2 := 0;
  il := fdata.headerinfo.IndexOfName('ChannelCount');
  if il>-1 then n2 := 1 + StrToIntDef( fdata.headerinfo.Values['ChannelCount'], 0);
  //verify number of columns
  if n1<>n2 then LogWarning('import:  n1 '+ IntToStr( n1) + ' <> n2 '  + IntToStr( n2) );
  //
  fdata.setColsNumber( n1 );
  for i:=0 to n1-1 do fdata.dataheaders[i] := tl[i].s + '';
  while ReadlnUntilString(f, s, '[Data]') do begin end;
  //read data
  while ReadlnUntilString(f, s, '[ACQ END]') do
    begin
      ParseStrSep(s, #9, tl);
      n1 := length(tl);
      ii := 0;
      v1 := NAN;
      v2 := NAN;
      v3 := NAN;
      v4 := NAN;
      if n1>=0 then ii := StrToIntDef( tl[0].s, 0);
      if n1>=1 then v1 := MyStrToFloat( tl[1].s ); // StrToFloatDef( tl[1].s, 0);
      if n1>=2 then v2 := MyStrToFloat( tl[2].s );//StrToFloatDef( tl[2].s, 0);
      if n1>=3 then v3 := MyStrToFloat( tl[3].s );//StrToFloatDef( tl[3].s, 0);
      if n1>=4 then v4 := MyStrToFloat( tl[4].s ); //StrToFloatDef( tl[4].s, 0);
      fdata.AddRec(ii, v1, v2, v3, v4);
    end;
  FS.Destroy;
  Result := true;
end;


function ImportEISfile(Var fdata: TImportedEISFile; name: string): boolean;
Var
  //f: text;
  s, s1: string;
  tl: TTokenList;
  i, n1, n2, il: longint;
  d: tdatetime;
  fs: tFormatSettings;
  fstream: TFileStream;
  SR: TMyTextStream;
begin
  Result := false;
  GetLocaleFormatSettings(0, fs);
  fs.DateSeparator := '-';
  fs.TimeSeparator := ':';
  fs.ShortDateFormat := 'yyyy-mm-dd';
  //
  if fdata=nil then exit;
  if name='' then exit;
  try
    fstream := TfileStream.Create(name, fmOpenRead + fmShareDenyNone );       //ttextreader
    SR := TMyTextStream.Create(fstream);
  except
    on E: exception do begin exit; end;
  end;
  //Reset(f);          //system
  fdata.Clear;
  SR.Readln(s); //Readln(f, s);
  //assert
  if s<>'[PtcServer Acquisition File]' then
    begin
      LogWarning('importing from file '+ name + ' failed - First line mismatch');
      //close(f);
      fstream.Destroy;
      SR.Destroy;
      exit;
    end;
  while ReadlnUntilString(SR, s, '[DataHeader]') do      //todle
    begin
      fdata.headerinfo.Add(s);
    end;
  //now process data header
  SR.Readln(s);//Readln(f, s);
  ParseStrSep(s, #9, tl);//ParseStrSimple(s, tl);
  n1 := length(tl);
  n2 := 0;
  il := fdata.headerinfo.IndexOfName('ChannelCount');
  if il>-1 then n2 := 1 + StrToIntDef( fdata.headerinfo.Values['ChannelCount'], 0);
  //verify number of columns
  if n1<>n2 then LogWarning('import:  n1 '+ IntToStr( n1) + ' <> n2 '  + IntToStr( n2) );
  //
  if n1< fdata.fNcols then
    begin
      LogWarning('importing from file '+ name + ' failed - not enough columns');
      //close(f);
      fstream.Destroy;
      SR.Destroy;
      exit;
    end;
  while ReadlnUntilString(SR, s, '[Data]') do begin end;
  //read data
   while ReadlnUntilString(SR, s, '[ACQ END]') do
    begin
      ParseStrSep(s, #9, tl);
      n1 := length(tl);
      if n1<15 then continue;
      if not TryStrToDateTime(tl[14].s, d, fs) then d := Now; //d := strtodatetime( tl[14].s, fs);
      //
      fdata.AddRec(StrToIntDef( tl[0].s, 0), MyStrToFloatDef( tl[1].s, 0),
                   MyStrToFloatDef( tl[2].s, 0), MyStrToFloatDef( tl[3].s, 0),
                   MyStrToFloatDef( tl[4].s, 0), MyStrToFloatDef( tl[5].s, 0),
                   MyStrToFloatDef( tl[6].s, 0), MyStrToFloatDef( tl[7].s, 0),
                   MyStrToFloatDef( tl[8].s, 0), MyStrToFloatDef( tl[9].s, 0),
                   MyStrToFloatDef( tl[10].s, 0), MyStrToFloatDef( tl[11].s, 0),
                   MyStrToFloatDef( tl[12].s, 0), MyStrToFloatDef( tl[13].s, 0),
                   d
                   );                                  //strtodate
    end;
  //close(f);
  fstream.Destroy;
  SR.Destroy;
  Result := true;
end;



end.

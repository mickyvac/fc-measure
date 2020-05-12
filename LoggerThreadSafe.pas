unit LoggerThreadSafe;

interface

uses Sysutils, Classes, MyUtils;

Const
   CLogautodumpsize = 200;


type

  TMyLoggerThreadSafe = class  //main app log
  public
    constructor Create(fileprefix, filesuffix: string; path: string = ''; autodump: boolean=true);  //auto create file with datetime
    destructor Destroy; override;
    //if path='' app dir is used;  path must end with '\'
    { Public declarations }
    procedure LogMsg(a:String);
    procedure ForceDumpToFile;
  private
    { Private declarations }
    flogfile: TextFile;
    fsynchro: TMultiReadExclusiveWriteSynchronizer;  //!!! important when logging from multiple threads
    fstrlist: TStringList;  //if the list reaches predefined size, it is dumped into file
    ffilename: string;
    fAutodump: boolean;
    fFormatSettings: TFormatSettings;
    fAutoCommit: boolean;
    fAutoCommitTimeMS: longint;
    fNextAutoCommintTimeTICK: longword;
  private
    function LoggerNowString: string;  //returns actual datetime up to miliseconds to be put at begginning of line
    procedure dump;
    procedure MakeEmpty;
    procedure CheckDumpCondition;        
  public
    property Filename: string read ffilename;
    property Autodump: boolean read fAutodump write fAutodump;
    property AutoCommit: boolean read fAutoCommit write fAutoCommit;
    property AutoCommitTimeMS: longint read fAutoCommitTimeMS write fAutoCommitTimeMS;

  end;





implementation

Uses Forms;


constructor TMyLoggerThreadSafe.Create(fileprefix, filesuffix: string; path: string = ''; autodump: boolean=true);  //auto create file with datetime
Var
  tstr: string;
begin
  fAutoDump := autodump;
  fAutoCommit := autodump;
  fAutoCommitTimeMS := 300000;  //5min
  fNextAutoCommintTimeTICK := TimeDeltaTICKgetT0 + fAutoCommitTimeMS;
  GetLocaleFOrmatSettings(0, fFormatSettings);
  DateTimeToString(tstr, '_yyyy-mm-dd-hh-nn-ss', Now(), fFormatSettings);
  if path='' then path := ExtractFilePath( Application.Exename );
  ffilename := path + fileprefix + tstr + '_' + filesuffix + '.txt';
  MakeSureDirExist( path );
  {$I-}
  AssignFile(flogfile, ffilename );
  Append(flogfile);
  if IOResult<>0 then Rewrite(flogfile);
  {$I+}
  fsynchro := TMultiReadExclusiveWriteSynchronizer.Create;
  fstrlist := TStringList.Create;
  LogMsg('===log created ===');
  dump;
end;


destructor TMyLoggerThreadSafe.Destroy;
begin
  LogMsg('===log destroy===');
  if fAutoDump then dump;
  {$I-}
    closefile( flogfile );
  {$I+}
  fsynchro.Destroy;
  fstrlist.Destroy;
end;

procedure TMyLoggerThreadSafe.CheckDumpCondition;
begin
  if (fstrlist.count >= CLogautodumpsize) or (TimeDeltaTICKgetT0 > fNextAutoCommintTimeTICK) then MakeEmpty;
end;

procedure TMyLoggerThreadSafe.LogMsg(a:String);
begin
  fsynchro.beginwrite;
     CheckDumpCondition;
     fstrlist.Add( LoggerNowString + a );
  fsynchro.endwrite;
end;



procedure TMyLoggerThreadSafe.ForceDumpToFile;
begin
  fsynchro.beginwrite;
    dump;
  fsynchro.endwrite;
end;




procedure TMyLoggerThreadSafe.MakeEmpty;  //internal proc - no locking
begin
  if fAutoDump then dump
  else
    begin  //throw away
      fstrlist.Clear();
    end;
  fNextAutoCommintTimeTICK := TimeDeltaTICKgetT0 + fAutoCommitTimeMS;
end;




procedure TMyLoggerThreadSafe.Dump;  //internal proc - no locking
Var
  s: string;
  i: longint;
  berr: boolean;
  errcnt: longint;
begin
  if fstrlist.Count = 0  then exit;
  s := '';
  try
    {$I-}
    berr := false;
    errcnt := 0;
    //
    Append(flogfile);
    if IOResult<>0 then berr := true;
    if not berr then
      begin
       for i:=0 to fstrlist.Count-1 do
          begin
            Writeln(flogfile, fstrlist.strings[i]);  //no IOerror checking
            if IOResult<>0 then Inc( errcnt);
          end;
        closeFile(flogfile);
        if IOResult<>0 then berr := true;
      end;
    {$I+}
  except
    on E: exception do s := E.message;
  end;
  fstrlist.Clear;
  if s<>'' then logmsg(s);
  if berr then logmsg('ERR: TMyLoggerThreadSafe.Dump: There was IO Error during Append or Closefile');
  if errcnt>0 then logmsg('ERR: TMyLoggerThreadSafe.Dump: There was ' + IntToStr( errcnt) + ' errors during "writeln" into logfile');
end;


function TMyLoggerThreadSafe.LoggerNowString: string;  //returns actual datetime up to miliseconds to be put at begginning of linebegin
begin
  DateTimeToString(Result, '[yyyy-mm-dd_hh:nn:ss.zzz] ', Now(), fFormatsettings);
end;


end.

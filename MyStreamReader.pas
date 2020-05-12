unit MyStreamReader;

interface

uses classes,  strutils, sysutils,
     myutils;
     //sysutils for fmFileMode constants...

const
  CMaxBuf = 1024;

type
TMyTextStream = class(TObject)
      private
        FHost: TStream;
        FdestroyHost: boolean;
        Freadonly: boolean;
        FOffset,FBufSize: longint;
        fInBuf: longint;
        fBuffer: array[0..CMaxBuf-1] of Char;
        fstrbuffer: string;
        FEOF: Boolean;
        fEOLNstr: string;        
        function FillBuffer: Boolean;
        function AddFromBuffer(Var Data: string; MaxN: longint = -1): longint;
      public
        constructor Create(AHost: TStream; readonly: boolean = true); overload;
        constructor Create(fname: string; readonly: boolean = true); overload;
        destructor Destroy; override;
        function ReadLn: string; overload;
        function ReadLn(out Data: string): Boolean; overload;
        function ReadLnLimit(out Data: string; maxn: longint = -1): Boolean; overload;
        procedure ResetStreamPos;  //sets pos to 0
      private
        function getStreamPos(): Int64;
        procedure setStreamPos( p: Int64);

      public
        property EOF: Boolean read FEOF;
        property HostStream: TStream read FHost;
        property Offset: Integer read FOffset write FOffset;
        property EOLNstr: string read fEOLNstr write fEOLNstr;
        property StreamPos: Int64 read getStreamPos write setStreamPos;
      end;


implementation




{ TTextStream }

constructor TMyTextStream.Create(AHost: TStream; readonly: boolean = true);
begin
  inherited Create;
  FHost := AHost;
  FInBuf := 0;
  FOffset := 0;
  FEOF := false;
  fstrbuffer := '';
  fEOLNstr := #13#10;
  FdestroyHost := false;
  Freadonly := readonly;
end;

constructor TMyTextStream.Create(fname: string; readonly: boolean = true);
begin
  inherited Create;
  FHost :=  TfileStream.Create(fname, fmOpenRead + fmShareDenyNone );
  FInBuf := 0;
  FOffset := 0;
  FEOF := false;
  fstrbuffer := '';
  fEOLNstr := #13#10;
  FdestroyHost := false;
  Freadonly := readonly;
end;



destructor TMyTextStream.Destroy;
begin
  if FdestroyHost then MyDeStroyAndNil( FHost );  //.Free;  no do not dfestroy it was not created here!!!
  inherited Destroy;
end;

    function TMyTextStream.FillBuffer: Boolean;
    Var
      fsize: longint;
    begin
      Result := false;
      if Fhost = nil then exit;
      FillChar(FBuffer,SizeOf(FBuffer),0);
      FSize := FHost.Read(FBuffer,SizeOf(FBuffer));
      Result := FSize > 0;
      if Result then
        begin
          fstrbuffer := fstrbuffer + string(pchar(@FBuffer[0]));
          Inc( FOffset, FSize);
        end;
      if FSize=0 then FEOF := true;
    end;

function TMyTextStream.AddFromBuffer(Var Data: string; MaxN: longint = -1): longint;
    Var
      len, cpn, jr: longint;
    begin
      Result := 0;
      len := length( fstrbuffer );
      if MaxN<0 then cpn := len
      else if len>maxn then cpn := maxn
      else cpn := len;
      if cpn=0 then exit;
      Assert(cpn>0);
      data := data + leftstr(fstrbuffer, cpn );
      //shorten buffer
      jr := len - cpn;
      fstrbuffer := rightstr(fstrbuffer, jr);
      Result := cpn;
    end;


    function TMyTextStream.ReadLnLimit(out Data: string; maxn: longint = -1): Boolean;
    var
      Len, Start, i, jl, jr: Integer;
      EOLChar: Char;
      bend : boolean;
      xs : string;
      ndata, n, nx: longint;
      limitn: boolean;
    begin
      Data:='';
      Result := False;
      if Fhost = nil then exit;
      if FEOF then exit;
      if maxn=0 then exit;
      limitn := maxn>0;
      bend := false;
      ndata := 0;
      if length(fstrbuffer)=0 then bend := FillBuffer;
      i := posex(fEOLNstr, fstrbuffer, 1);
      while (i<1) and (not bend) do
        begin
          if (limitn) then
            begin
              n := AddFromBuffer( Data, maxn);
              maxn := maxn - n;
            end
          else AddFromBuffer( Data, -1);
          if (limitn) and (maxn<=0) then exit; //limit reached
          //l := Data + fstrbuffer;
         // n := length( fstrbuffer );
          //fstrbuffer := '';
          bend := FillBuffer;
          i := posex(fEOLNstr, fstrbuffer, 1);
          if bend then break;
        end;
      //if (limitn) and (maxn<=0) then exit;  //limit reached

      //jl := i - 1;
      //if (maxn>=0) and (i>0)
      if i>0 then //copy rest
        begin
          jl := i - 1;
          if (limitn) and (jl>maxn) then
            begin
              n := AddFromBuffer( Data, maxn);
              maxn := maxn - n;
              exit; //limit reached before reaching eoln
            end;
          //jl characters can be added to data within limit
          //
          if jl>0 then data := data + leftstr(fstrbuffer, jl ); //+ length(fEOLNstr)
          jr := length(fstrbuffer) - i + 1 - length(fEOLNstr);
          // remove eoln ... keep rest of data in buffer
          xs := '';
          if jr>1 then xs := midstr( fstrbuffer, jl + length(fEOLNstr) + 1, jr );
          fstrbuffer := xs;
        end;
      if bend then FEOF := length(fstrbuffer)=0;
      Result := i>0;
    end;

    function TMyTextStream.ReadLn(out Data: string): Boolean;
    begin
      Result := ReadLnLimit(Data);
    end;

    function TMyTextStream.ReadLn: string;
    begin
      ReadLn(Result);
    end;



function TMyTextStream.getStreamPos(): Int64;
begin
  Result := FHost.Position;
end;

procedure TMyTextStream.setStreamPos( p: Int64);
begin
  FHost.Position := p;
end;


procedure TMyTextStream.ResetStreamPos;  //sets pos to 0
begin
  setStreamPos( 0 );
end;


end.
 
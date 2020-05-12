{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
unit plotgraph;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ExtCtrls, DateUtils, Math, MyUtils;

Const
  CDBmaxsets =1000;
  CDBinset = 1000;
  CGMaxGrRows= 10;
  CGMaxLayers = 2;
  CGMaxPixelsTick = 100;
  CGMinPixelsTick = 50;
  CMaxMemoryUsage = 800; //in Megabytes - will limit allocation of new data storage

type
   TDataPoint = record
		  x: double;   //x is mandatory item - used as key   - for minimum and maximum
		  y: double;   //y is mandatory item - used as value - for minimum and maximum
      fff: double;
      id: longint;
      a: array[1..100] of double;
      end;
   PDataPoint = ^TDataPoint;

   TDataSet =  array [0..CDBinset-1] of TDataPoint;
   PDataSet = ^TDataSet;

   TDataBunch = class
     private
       NP: longint;     //number of points ... 0= no points
       Nsets: word;
       MinV: real;
       MaxV: real;
       MinK: real;
       MaxK: real;
     private
       list: array[0..CDBmaxsets-1] of PDataSet;
       ninlist: array[0..CDBmaxsets-1] of word;
     public
       constructor Create;
       destructor Destroy; override;
       function AddPoint( x,y: real):longint; //after succes returns id of record(>=0) or -1 on error
       function GetPoint( n: longint): PDataPoint; //n is ordinal number (not the id) of record, starts from 0 to NPoints-1
       function NPoints(): longint;
       function MinVal():real;
       function MaxVal():real;
       function MinKey():real;
       function MaxKey():real;
       procedure RemoveAllData;
   end;
   PDataBunch = ^TDataBunch;

   PCanvas = ^TCanvas;

   TLayer = record
     //status
     changed: boolean;
     inirng: boolean;
     rnglimitenabled: boolean;
     //ranges final
     Lx: real;
     Hx: real;
     Ly: real;
     Hy: real;
     //range lomits
     minLrx: real;
     minHrx: real;
     minLrY: real;
     minHrY: real;
     maxLrx: real;
     maxHrx: real;
     maxLrY: real;
     maxHrY: real;
     //coefficients
     xcoef: real;
     ycoef: real;
     //ticks
     XnMajTicks: word;   
     YnMajTicks: word;
     X1stMajTick: real;
     Y1stMajTick: real;
     XMajTickDelta: real;
     YMajTickDelta: real;
     MinTicksBetween: word;
     FirstMinTick: real;
     MinTickDelta: real;
     nMinTickBefore: word;
     nMinTickAfter: word;
     //layout config
     showaxisx: boolean;
     showaxisy: boolean;
     axisXvalY: real;
     axisYvalX: real;
     showlabelsx: boolean;
     showlabelsy: boolean;
     showgridx: boolean;
     showgridy: boolean;
     //scalex: TScale;
     //scaley: TScale;
     end;

   TGrLineStyle = ( GrLineNone, GrLineSolid );
   TGrMarkStyle = ( GrMarkNone, GrMarkSquare );
   TGVertAxisPos = (GAxisLeft, GAxisRight );

   TGraphRow = record
     data: TDataBunch;
     linest: TGrLineStyle;
     markst: TGrMarkStyle;
     xname: string;
     yname: string;
     end;


   TMyGraph = class
   private
     //canvas
     BM: TBitmap;
     Pcanv: PCanvas;
     fromx: longint;
     fromy: longint;
     tox: longint;
     toy: longint;
     sizex: longint;
     sizey: longint;
     layx1: longint;
     layx2: longint;
     layy1: longint;
     layy2: longint;
     Initialised: boolean;
     //layers
     layers: array[1..CGMaxLayers] of TLayer;
     layerdata: array[1..CGMaxLAyers] of array[1..CGMaxGrRows] of word;
     layerNdata: array[1..CGMaxLayers] of word;
     nlayers: byte;
     //data
     datarows: array[1..CGMaxGrRows] of TGraphRow;
     activedata: array[1..CGMaxGrRows] of boolean;
     datalayer: array[1..CGMaxGrRows] of byte;
   public
     procedure IniGraph(pc: PCanvas; fx, fy, tx, ty: longint);
     function AddNewRow(layer: byte; LS: TGrLineStyle; MS: TGrMarkStyle; nmx, nmy: string): integer;
       //returns id - use when deleting, PDataBunch must stay valid until the data row is removed !!!
       //returns -1 when fault
       //use PDataBuch for adding data to row
     function AddData(id: integer;  x,y: real): boolean;
     procedure RemoveDataRow( id: integer ); //treat the pointer received from adddatarow as invalid

     procedure ConfMinRanges(layer: byte; lrx, hrx, lrY, hrY: real);
     procedure ConfMaxRanges(layer: byte; lrx, hrx, lrY, hrY: real);
     //ShowLayer(l: byte);
     //HideLayer(l: byte);
     procedure Plot;
   private
     procedure PrepareRanges(lay: byte);
     procedure PrepareAxes(lay: byte);
     procedure ClearCanvas;
     procedure PlotHorizAxis(lay: byte);
     procedure PlotVertAxis(lay: byte; pos: TGVertAxisPos; ofs: byte);
     procedure PlotGrid(lay: byte);
     procedure PlotDataRow(id: integer);
     procedure PlotPoint(x,y:integer; ms: TGrMarkStyle);
     procedure PlotLine(x1,y1,x2,y2:integer; ls:  TGrLineStyle);
     procedure OutTextXy(x,y:integer; size: integer; txt: ansistring);
     function FindFreeRow: integer;
     procedure SetDefaultRanges(layer: byte);
     procedure OptimalTicks(lr, hr: real; size: longint; Var FirstMaj, MajDelta: real; Var NMaj: word);
   end;



implementation


//-------------TMyGraph ------

procedure TMyGraph.IniGraph(pc: PCanvas; fx, fy, tx, ty: longint);
begin
  pcanv := pc;
  fromx := fx;
  fromy := fy;
  tox := tx;
  toy := ty;
  sizex := tox - fromx;
  sizey := toy - fromy;
  layx1 := fromx;
  layx2 := tox;
  layy1 := fromy;
  layy2 := toy;
  if (sizex<1) or (sizey<1) then pc := nil;
end;

function TMyGraph.AddNewRow(layer: byte; LS: TGrLineStyle; MS: TGrMarkStyle; nmx, nmy: string): integer;
  //returns id - use for adding data or deleting.
  //returns -1 when fault
Var
  pos: word;
  ndata: word;
begin
  Result := -1;
  if (layer<1) or (layer>2) then exit;
  pos := FindFreeRow;
  if (pos<1) then exit;
  with datarows[pos] do
    begin
    linest := LS;
    markst := MS;
    xname := nmx;
    yname := nmy;
    end;
  activedata[ pos ] := true;
  datalayer[ pos ] := layer;
  inc( LayerNdata[ layer ] );
  ndata := LayerNdata[ layer ];
  layerdata[ layer][ndata] := pos;
  layers[ layer ].changed := true;
  Result := pos;
end;

function TMyGraph.AddData(id: integer;  x,y: real): boolean;
begin
  Result := false;
  if (id<1) or (id>CGMaxGrRows) then exit;
  if (not activedata[id]) then exit;
  Result := datarows[id].data.AddPoint(x,y) >=0 ;
end;

procedure TMyGraph.RemoveDataRow( id: integer );
Var
  l: byte;
begin
  if (id<1) or (id>CGMaxGrRows) then exit;
  if (not activedata[id]) then exit;
  l := datalayer[ id ];
  activedata[id] := false;

end;


procedure TMyGraph.ConfMinRanges(layer: byte; lrx, hrx, lrY, hrY: real);
begin
  if (layer<1) or (layer>2) then exit;
  with layers[layer] do
    begin
    minLrx := lrx;
    minHrx := hrx;
    minLrY := lry;
    minHrY := hry;
    changed := true;
    inirng := true;
    end;
end;

procedure TMyGraph.ConfMaxRanges(layer: byte; lrx, hrx, lrY, hrY: real);
begin
  if (layer<1) or (layer>2) then exit;
  with layers[layer] do
    begin
    maxLrx := lrx;
    maxHrx := hrx;
    maxLrY := lry;
    maxHrY := hry;
    changed := true;
    inirng := true;
    end;
end;


procedure TMyGraph.Plot;
Var i,j:word;
    id: word;
begin
  ClearCanvas; //TCanvas
  for i:= 1 to nlayers do
    begin
    PrepareRanges(i);
    PrepareAxes(i);
    PlotHorizAxis(i);
    PlotVertAxis(i, GAxisLeft, i);
    if (i=1) then PlotGrid(i);
    for j:= 1 to layerndata[i] do
      begin
      id := layerdata[i,j];
      PlotDataRow(id);
      end;
    end;
    PCanv.CopyMode := cmSrcCopy;
    PCanv.Draw(fromx, fromy, BM);
  //Copy bitmap to canvas
  //PCanv^.
end;


procedure TMyGraph.PrepareRanges(lay: byte);
Var
  PL: ^Tlayer;
  pd: PDataBunch;
  i,j, id: longint;
  xc, yc, d: real;
  lrx, hrx, lry, hry: real;
begin
  if (lay<1) or (lay>CGMaxLayers) then exit;
  if not layers[lay].inirng then SetDefaultRanges(lay);
  PL := @layers[lay];
  if (PL^.rnglimitenabled) or (layerNdata[lay]<1) then
  begin
    lrx := PL^.minLrx;
    hrx := PL^.minHrx;
    lry := PL^.minLry;
    hry := PL^.minHry;
  end
  else
  begin
    id := layerdata[lay][1];
    pd := @datarows[id].data;
    lrx := pd^.MinK;
    hrx := pd^.MaxK;
    lry := pd^.MinV;
    hry := pd^.MaxV;
  end;
  //go through max data ranges - and find overall max
  for i:=1 to layerNdata[lay] do
  begin
    id := layerdata[lay][i];
    //if (id<1) or (id>CGMaxRows) then exit;
    //if not activedata[i] then exit;
    pd := @datarows[id].data;
    lrx := Min(pd^.MinK, lrx);
    hrx := Max(pd^.MaxK, hrx);
    lry := Min(pd^.MinV, lry);
    hry := Max(pd^.MaxV, hry);
  end;
  //compare to layer defined maximum and minimum ranges
  if (PL^.rnglimitenabled) then
  begin
    lrx := Min(lrx, layers[lay].minLrx);
    lrx := Max(lrx, layers[lay].maxLrx);
    hrx := Max(hrx, layers[lay].minHrx);
    hrx := Min(hrx, layers[lay].maxHrx);
    lry := Min(lry, layers[lay].minLry);
    lry := Max(lry, layers[lay].maxLry);
    hry := Max(hry, layers[lay].minHry);
    hry := Min(hry, layers[lay].maxHry);
  end;
  //final checks
  if (hrx<=lrx) then  hrx := lrx+1;
  if (hry<=lry) then  hry := lry+1;
  //set final values of rng
  PL^.Lx := lrx;
  PL^.Hx := hrx;
  PL^.Ly := lry;
  PL^.Hy := hry;   
  //-----
  //calculate coefs...
  d := hrx-lrx;
  if (d<>0) then xc := sizex / d else xc := 0;
  d := hry-lry;
  if (d<>0) then yc := sizey / d else yc := 0;
  //store coeffd
  PL^.xcoef := xc;
  PL^.ycoef := yc;
end;

procedure TMyGraph.PrepareAxes(lay: byte);
Var
  PL: ^Tlayer;
  pd: PDataBunch;
  i,j, id: longint;
  xc, yc: real;
  d, lr, hr, optr: real;
  size: longint;
  min, optn, max: word;
  r, t, s, ss,sss,f, stepr: real;
  stepi: word;
begin
  if (lay<1) or (lay>CGMaxLayers) then exit;
  PL := @layers[lay];
  //X axis
  lr := PL^.Lx;
  hr := PL^.Hx;
  size := sizex;
  OptimalTicks(lr, hr, size, PL^.X1stMajTick, PL^.XMajTickDelta, PL^.XnMajTicks);
  lr := PL^.Ly;
  hr := PL^.Hy;
  size := sizey;
  OptimalTicks(lr, hr, size, PL^.Y1stMajTick, PL^.YMajTickDelta, PL^.YnMajTicks);
end;

procedure TMyGraph.ClearCanvas;
begin
  BM.Canvas.Brush.Style := bsSolid;
  BM.Canvas.Brush.Color := clWhite;
  BM.Canvas.Pen.Color := clWhite;
  BM.Canvas.Rectangle(-1,-1,sizex+1,sizey+1);
end;

procedure TMyGraph.PlotVertAxis(lay: byte; pos: TGVertAxisPos; ofs: byte);
Var i,j: integer;
    y1: integer;
    PL: ^TLayer;
    y, ycoef, delta: real;
    lr, hr: real;
    TickDelta,FirstTick, s, ss: real;
    nTickBefore: byte;
begin
  if (lay<1) or (lay>CGMaxLayers) then exit;
  PL := @layers[lay];
  PlotLine (Fromx, fromy, fromx, toy, GrLineSolid);
  //major ticks and labels
  y:= PL^.Y1stMajTick;
  ycoef := PL^.ycoef;
  delta := PL^.YMajTickDelta;
  For i:=1 to PL^.YnMajTicks do
    begin
    y1 := Round(y * ycoef);
    PlotLine (fromx, y1, fromx - 5, y1, GrLineSolid);
    OutTextXy(fromx - 15, y1, 6, FloatToStrF(y, FFFixed, 4,4) );
    y := y + delta;
    end;
  //minor ticks
  TickDelta := delta / (PL^.MinTicksBetween + 1);
  lr := PL^.Ly;
  hr := PL^.Hy;
  s := (PL^.Y1stMajTick - lr) / TickDelta;
  ss := floor( s );
  nTickBefore := round( s );
  FirstTick :=  PL^.Y1stMajTick - nTickBefore * TickDelta;
  s := (PL^.Y1stMajTick - lr) / TickDelta;
  ss := ceil( s );
  y := FirstTick;
  while ( y<hr) do
    begin
    y1 := Round(y * ycoef);
    PlotLine (fromx, y1, fromx - 2, y1, GrLineSolid);
    y := y + TickDelta;
    end;
end;

procedure TMyGraph.PlotHorizAxis(lay: byte);
Var i: integer;
    x1: integer;
    PL: ^TLayer;
    x, xkoef, delta: real;
    lr, hr: real;
    TickDelta,FirstTick, s, ss: real; 
    nTickBefore: byte;
begin
  if (lay<1) or (lay>CGMaxLayers) then exit;
  PL := @layers[lay];
  PlotLine (Fromx, toy, tox, toy, GrLineSolid);
  //major ticks and labels
  x:= PL^.X1stMajTick;
  xkoef := PL^.xcoef;
  delta := PL^.XMajTickDelta;
  For i:=1 to PL^.XnMajTicks do
    begin 
    x1 := Round(x * xkoef);
    PlotLine (x1, toy, x1, toy+5, GrLineSolid);
    OutTextXy(x1, toy+10, 8, FloatToStrF(x, FFFixed, 4,4) );
    x := x + delta;
    end;
  //minor ticks
  TickDelta := delta / (PL^.MinTicksBetween + 1);
  lr := PL^.Lx;
  hr := PL^.Hx;
  s := (PL^.X1stMajTick - lr) / TickDelta;
  ss := floor( s );
  nTickBefore := round( s );
  FirstTick :=  PL^.X1stMajTick - nTickBefore * TickDelta;
  s := (PL^.X1stMajTick - lr) / TickDelta;
  ss := ceil( s );
  x := FirstTick;
  while ( x<hr) do
    begin
    x1 := Round(x * xkoef);
    PlotLine (x1, toy, x1, toy+2, GrLineSolid);
    x := x + TickDelta;
    end;
end;
 
procedure TMyGraph.PlotGrid(lay: byte);
Var i: integer;
    x1: integer;
    PL: ^TLayer;
begin
  if (lay<1) or (lay>CGMaxLayers) then exit;
  PL := @layers[lay];
  if not PL^.showgridx or not PL^.showgridy then exit;
  //!!!!!!!!!!!!!!!!!!
end;

 
procedure TMyGraph.PlotDataRow(id: integer);
Var
  xkoef, ykoef: real;
  x, y: integer;
  vx, vy: real;
  //midllex, middley, sx, sy: integer;  
  lrx, hrx, lry, hry, d: real;
  lay: byte;
  pd: PDataBunch;
  pp: PDataPoint;
  ls: TGrLineStyle;
  ms: TGrMarkStyle;
  i: longint;
  first: boolean;
  PL: ^Tlayer;
begin
  if (id<1) or (id>CGMaxGrRows) then exit;
  if not activedata[id] then exit;
  lay := datalayer[id];
  if not layers[lay].inirng then SetDefaultRanges(lay);
  pd := @datarows[id].data;
  ls := datarows[id].linest;
  ms := datarows[id].markst;
  PL := @(layers[lay]);
  //calculate actual range
  lrx := Max(pd^.MinK, layers[lay].maxLrx);
  lrx := Min(lrx, layers[lay].minLrx);
  hrx := Min(pd^.MaxK, layers[lay].maxHrx);
  hrx := Max(hrx, layers[lay].minHrx);
  lry := Max(pd^.MinV, layers[lay].maxLry);
  lry := Min(lry, layers[lay].minLry);
  hry := Min(pd^.MaxV, layers[lay].maxHry);
  hry := Max(hry, layers[lay].minHry);
  PL^.Lx := lrx;
  PL^.Hx := hrx;
  PL^.Ly := lry;
  PL^.Hy := hry;   
  //calculate middle pos, coefs...  
  if (hrx<=lrx) then hrx := lrx+1;
  if (hry<=lry) then hry := lry+1;
  d := hrx-lrx;
  if (d)<>0 then xkoef := sizex / d
  else xkoef := 0;
  d := hry-lry;
  if (d)<>0 then ykoef := sizey / d
  else ykoef := 0;
  //plot
  first := true;
  for i:=1 to pd^.NPoints do
  begin
    pp := pd^.GetPoint(i);
    if (pp=nil) then break;
    vx := pp^.x;
    vy := pp^.y;
    if InRange(vx, lrx, hrx) and InRange( vy, lry, hry ) then
      begin
      x := Round( (vx - lrx) * xkoef );
      y := Round( (vy - lry) * ykoef );
      PlotPoint(x,y, ms);
      if not first then  //line
        begin
        
        end; 
      if (first) then first := false; 
      end
    else //data point is outside of range, maybe plot just some line
      begin
      first := true;
      end;
    
  end;


end;


procedure TMyGraph.PlotPoint(x,y:integer; ms: TGRMarkStyle);
begin
  BM.Canvas.Pen.Color := clBlack;
  BM.Canvas.Brush.Color := clBlack;
  BM.Canvas.Brush.Style := bsSolid;
  BM.Canvas.Rectangle(x-2,y+2,x+2,y-2);
end;

procedure TMyGraph.PlotLine(x1,y1,x2,y2:integer; ls:  TGrLineStyle);
begin
  BM.Canvas.Pen.Color := clBlack;
  BM.Canvas.Brush.Style := bsSolid;
  BM.Canvas.MoveTo(x1,y1);
  BM.Canvas.LineTo(x2,y2);
end;

procedure TMyGraph.OutTextXy(x,y:integer; size: integer; txt: ansistring);
begin

end;

function TMyGraph.FindFreeRow(): integer;
Var i:word;
begin
  Result := -1;
  for i:= 1 to CGMaxGrRows do
    if not activedata[i] then
    begin
      Result := i;
      exit;
    end;
end;

procedure TMyGraph.SetDefaultRanges(layer: byte);
begin
  ConfMaxRanges(layer, -10, 10, -10, 10);
  ConfMinRanges(layer, -1, 1, -1, 1);
end;


procedure TMyGraph.OptimalTicks(lr, hr: real; size: longint; Var FirstMaj, MajDelta: real; Var NMaj: word);
Var
  xc, yc: real;
  d, optr: real;
  min, optn, max: word;
  r, t, s, ss,sss,f, stepr: real;
begin
  d := hr - lr;
  size := sizex;
  //safe values
  NMaj := 1;
  FirstMaj := d / 2;
  MajDelta := 0;
  if not (Initialised) then exit;
  //only works for sane values
  if (d<=0) then exit;
  //target is to have 10 Major ticks, but at most 1 tick per 50 pixels and minimun 1 tick per 100 pixels
  //optimum is to have integer step in as significant digit as possible
    min := size div CGMaxPixelsTick; //min # of ticks
    max := size div CGMinPixelsTick; //max # of ticks    
    //calculate optimum step from range
    r := log10(d) - 1;
    t := Power(10, floor( r ) ); //optimal step - value in axis units
    optn := floor( d / t );  //calculated # of pieces (ticks)
    optr := t;
    if (optn>max) then
    begin      
      if (max<>0)  then s:=optn/max  else s:=1;
      ss := round(s);
      optn := optn * round(ss); //integer factor
      optr := optr * ss;
    end;
    if (optn < min) then
    begin      
      if (optn<>0)  then s:=min/optn else s:=1;
      if (s>0)  then ss:= floor( log10(s) ) else ss:=0;
      sss := power(10,ss);
      //lets use only factors 2 or 5 or 10
      f := 1;
      ss := optn * sss * 2;
      if (xc >= min) then f := ss;
      ss := optn * sss * 5;
      if (xc >= min) then f := ss;
      ss := optn * sss * 10;
      if (xc >= min) then f := ss;
      //it should already be enough or no change at all
      optr := optr / f;
    end;
  //some post calc
  if (optr>1) then t:=log10(optr) else t:=log10(d);
  r := lr / power(10, floor(t));
  s := round ( r ); //value of first major tick  
  //now calculate variables used to plot axes
  NMaj := floor( d / optr);
  FirstMaj := s;
  MajDelta := optr;
end;



//---------TDataBunch -----------

constructor TDataBunch.Create;
begin
  NP := 0;
  NSets := 0;
  list[0] := nil;
end;

destructor TDataBunch.Destroy;
Var i:word;
begin
  for i:=0 to CDBmaxsets-1 do
  begin
    if list[i]<>nil then dispose( list[i] );
  end;
  inherited;
end;


function TDataBunch.AddPoint( x,y: real):longint; //after succes returns Position of record(that is >=0) or -1 on error
Var r,c:word;
    ps: PDataSet;
    newn:longint;
    mem : longint;
begin
  Result := -1;
  newn := NP;
  r := newn div CDBinset;
  c := newn mod CDBinset;
  if (r>=CDBMaxsets) then exit;
  ps := list[r];
  if (ps=nil) or (r>=Nsets) then   //need to allocate new array
  begin
    //check if there is enough memory allowed
    mem := (NSets + 1) * SizeOf( TDataSet ) div 1000000;  //in Mega bytes
    if mem > CMaxMemoryUsage then //will not allocate more - return as if error
    begin
      ps := nil;
      exit;
    end;
    try
      New(ps);
      if ps<>nil then  //OK
        begin
          list[r] := ps;
          Inc( Nsets );
          ninlist[r] := 0;
        end;
    except
      //EOutOfMemory ?
    end;
  end;
  if (ps=nil) then exit; //not enough memory or error
  //add item - update variables
  Inc( ninlist[r] );
  Inc( NP );
  //create new record
  ps^[c].x := x;
  ps^[c].y := y;
  ps^[c].id := newn;
  //check the minimum, amximum
  if not isNAN(x) then
    begin
    if isNan(minK) then minK := x;
    if isNan(maxK) then maxK := x;
    if (x<MinK) then MinK := x;
    if (x>MaxK) then MaxK := x;
    end;
  if not isNAN(y) then
    begin
    if isNan(minV) then minV := y;
    if isNan(maxV) then maxV := y;
    if (y<MinV) then MinV := y;
    if (y>MaxV) then MaxV := y;
    end;
  Result := newn;
end;

function TDataBunch.GetPoint( n: longint): PDataPoint; //n is ordinal number (not the id) of record, starts from 0 to NPoints-1
Var r,p:word;
    ps: PDataSet;
begin
  Result := nil;
  if (n<0) or (n>=NP) then exit;
  r := n div CDBinset;
  p := n mod CDBinset;
  if (r >= NSets) then exit;  //this should not be necessary
  //if p >= ninlist[r] then exit;    //this should not be necessary
  ps := list[r];
  if (ps=nil) then exit;
  Result := @(ps^[p]);
end;

function TDataBunch.NPoints(): longint;
begin
    Result := NP;
end;

function TDataBunch.MinVal():real;
begin
    Result := MinV;
end;

function TDataBunch.MaxVal():real;
begin
    Result := MaxV;
end;

function TDataBunch.MinKey():real;
begin
  Result := MinK;
end;

function TDataBunch.MaxKey():real;
begin
  Result := MaxK;
end;


procedure TDataBunch.RemoveAllData;
Var i:word;
begin
  if Nsets>0 then
    begin
    for i:=0 to Nsets-1 do
      begin
       if list[i]<>nil then
       begin
         dispose( list[i] );
       end;
       ninlist[i] := 0;
      end;
    end;
  NP :=0;
  Nsets := 0;
  MinV:= Nan;
  MaxV:= Nan;
  MinK:= Nan;
  MaxK:= Nan;
end;









end.

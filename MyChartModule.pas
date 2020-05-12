unit MyChartModule;

interface

Uses
     datastorage, myutils, Logger,
     Math, SysUtils,
     TeEngine, Series, TeeProcs, Chart,
     Classes, ExtCtrls, StdCtrls, Dialogs, Buttons, Controls, Graphics,
     FormGlobalConfig,
     MyThreadUtils;

const
    CMainChartMaxTmpRecs = 4000;
    CSeriesMaxTmpRecs = 4000; //max 1000 * 4 points to plot

Type

                           
  TGraphConf = record
     whatdata: byte;   //identify, which type of chart to display e.g. Voltage vs time or others
     enabled: boolean; //whether to update mainchart or not - debug
     deltat: TDateTime;   //how much time should be displayed   (TDateTime is in days)
     xincrement: TDateTimeStep;  //on graph - what is the convenient tick distance
     userXcenter: double;  //if userpos true then this the center of shown range
     userXmax: double;
     userXmin: double;
     userXinterval: double;
     userLymin: double;
     userLymax: double;
     userLYinterval: double;
     LtoRcoupligFact: double; //try to keep same of position of "0" level -> the maximum displayed value on Right Y is porportional to Left Y
     userRymin: double;
     userRymax: double;
     maximized: boolean;
     xmaximized: boolean;
     ymaximized: boolean;
     userpos: boolean;    //if maximized, then if false it means show latest data
//     tbnotifyupdate: boolean;  //flag that user moved the thumb on trackbar - in maingrrepaint there will be new startrec calculated
//     y1min, y1max: double;   //continously updated min and max (to calculate visible range)
 //    y2min, y2max: double;
     maxpoints: integer;  //how many points should be loaded into chart to limit excessive data processing
                          //good estimate is about 1 point per pixel of display width
  end;


type
  TSeriesType = (CSeriesVoltage, CSeriesCurrent, CSeriesRefVoltage, CSeriesPower,
                 CSeriesTempCellTop, CSeriesTempCellBot, CSeriesTempbH, CSeriesTempbO,
                 CSeriespBPsp, CSeriespA, CSeriespC, CSeriespPiston,
                 CSeriesFlowA, CSeriesFlowC, CSeriesFLowN,
                 CSeriesOutputOn, CSeriesFuseHardOn, CSeriesFuseSWOn);
  TSeriesAxis = (CSeriesAxLeft, CSeriesAxRight);

  TSeriesConf = record
    stype: TSeriesType;
    sunit: string;
    saxis: TSeriesAxis;
  end;

  TSeriesSelection = record              //uses dynamic aray for list of series description
    nseries: byte;
    serconf: array of TSeriesConf;
  end;

//idea: Only a PANEL on which the chart should be draws is ASSIGNED at the begining,
//then everyhting else (create chart objkects and control buttons will be taken care of by the module
//Only thing which will have to be controlled is the content = assigning data to be plotted and configuring
//default visible area etc...
//DATA: the module accepts TMemDataStorageBase object from "datastorage unit" - the one which is used for storing all aquired data into cache
//
//todo:  load, save - from TFileStorage
//


  TMainChartTmpData = array[0..CMAinChartMaxTmpRecs] of TMonitorRec;    //will not use dynamic array now - to avoid memory reallocation

  TSeriesData = record
    ndata: longint;
    x: array[0..CSeriesMaxTmpRecs] of double;
    y: array[0..CSeriesMaxTmpRecs] of double;
  end;
  PSeriesData = ^TSeriesData;

  TChartDataPack = record            //uses dynamic array for storing of seriesdata according to the number of series to display
    nseries: byte;
    serdata: array of TSeriesData;
  end;



  TControlList = array of TControl;

  TSeriesObjectType = (CSOTFastLine);

  TSeriesRec = record
    ser: TChartSeries;
    axlabelx: string;
    axlabely: string;
  end;

  TSeriesObject = class
     public
       constructor Create(pc: TChart; leftax: boolean; rightax: boolean);
       destructor Destroy; override;
     private
       fparentchart: TCHart;
       fseries: array of TSeriesRec;
       fleftaxis: boolean;
       frightaxis: boolean;
       function CreateSeries(t: TSeriesObjectType): TSeriesRec;
     public
       procedure RemoveAllSeries;
       function SetSeriesNumber(n: byte; t: TSeriesObjectType): boolean;
       function AddSeries(t: TSeriesObjectType): boolean;
       function GetSeries(n:byte): TChartSeries;
       function Count: integer;
       procedure ConfSeries(n:byte; legendtitle: string; xaxislabel: string; yaxislabel: string);
       function GetXAxisLabel: string;
       function GetYAxisLabel: string;
     end;




  TMyChartPanelObject = class (TObject)
     public
       constructor Create(p: TPanel);
       destructor Destroy; override;
     public
       procedure Init;
       procedure Repaint;
       procedure AfterResize;
       procedure BeginUpdate;
       procedure EndUpdate;  //refresh labels, data and so on
       procedure ShowLegend;
       procedure HideLegend;
     private
       fReady: boolean;
       fWidth: integer;
       fHeight: integer;
       procedure DrawControls;
       function AddControl(c: TControl; Var ctrllist: TControlList): TControl;
       procedure LoadBitmaps;
       function GetBMPbyName(s: string): TBitmap;
       procedure ClearBitmaps;
       procedure ConfigureSpeedBtn(Const b: TSpeedButton; resbmpname: string; altname: string);
       procedure PlaceControlToTheRight(ctrl: TControl; nexttoleft: boolean; height, width: integer; leftspace, bottomspace: integer; top: integer; maxright: integer);
     public
       procedure PlaceExternalControlToTheRight(ctrl: TControl; leftspace: integer);
     private
       fBitmaps: array of TBitmap;
       fBmpNames: TStringList;
     private
       fTargetPanel: TPanel;  //assigned!!!
       //objects created at runtime
       fChart: TChart;
       FConf: TGraphConf;
       FLockConf: TMyLockableObject;
       fLeftSeries: TSeriesObject;
       fRightSeries: TSeriesObject;
       //
       //fToolbar: TToolbar;              //ttoolbutton   style
       fBuSavePNG: TSpeedButton;
       fBuCopyBMP: TSpeedButton;
       fBuCopyWMF: TSpeedButton;
       fBuCopyTXT: TSpeedButton;
       fBuReset: TSpeedButton;
       fBuLeft: TSpeedButton;
       fBuRight: TSpeedButton;
       fBuPlus: TSpeedButton;
       fBuMinus: TSpeedButton;
       //fLaStatus: TLabel;
       fLaCoords: TLabel;
       //fCBoxTimeScale: TComboBox;
       fbuttons: TControlList;
       fotherctrl: TControlList;
       ftoolbarctrls: TControlList;
     public
       property Chart:  TChart read fChart;
       property LeftSeriesObj: TSeriesObject read fLeftSeries;
       property RightSeriesObj: TSeriesObject read fRightSeries;
     private
       procedure ActionZoomReset(Sender: TObject);
       procedure ActionZoomPlus(Sender: TObject);
       procedure ActionZoomMinust(Sender: TObject);
       procedure ActionSavePNG(Sender: TObject);
       procedure ActionCopyBMP(Sender: TObject);
       procedure ActionCopyWMF(Sender: TObject);
       procedure ActionCopyTXT(Sender: TObject);
       procedure ActionMoveRight(Sender: TObject);
       procedure ActionMoveLeft(Sender: TObject);
       procedure ActionMoveUp(Sender: TObject);
       procedure ActionMoveDown(Sender: TObject);
     private

  end;



procedure ExtractData( Var seriessel: TSeriesSelection; Var chdata: TChartDataPack; Var mon: TMonitorMemDataStorage; monfrom, monto, nred: longint );


implementation

uses HWAbstractdevicesV3;


const

CFloppypng25 = 'FloppyPNG25';




constructor TSeriesObject.Create(pc: TChart; leftax: boolean; rightax: boolean);
begin
  fparentchart := pc;
  setlength( fseries, 0);
  fleftaxis := leftax;
  frightaxis := rightax;
end;

destructor TSeriesObject.Destroy;
begin
  RemoveAllSeries;
end;


procedure TSeriesObject.RemoveAllSeries;
Var
  i: integer;
begin
      for i:= 0 to Length(fSeries)-1 do
        begin
          if fseries[i].ser=nil then continue;
          fseries[i].ser.ParentChart := nil;
          fseries[i].ser.Destroy;
        end;
  setlength( fseries, 0 );
end;


function TSeriesObject.CreateSeries(t: TSeriesObjectType): TSeriesRec;
Var
  se: TCHartSeries;
begin
  Result.ser := nil;
  Result.axlabelx := '';
  Result.axlabely := '';
  try
    se := nil;
    case t of
        CSOTFastLine:  se := TFastLineSeries.Create( nil );
    end;
    if se<>nil then
      begin
        se.ParentChart := fparentchart;
        se.HorizAxis := aBottomAxis;
        if fleftaxis then se.VertAxis := aLeftAxis;
        if frightaxis then se.VertAxis := aRightAxis;
        if frightaxis and fleftaxis then se.VertAxis := aBothVertAxis;
      end;
  except
    on E: exception do begin se := nil; LogMsg('EXCEPTION CreateSeries' + E.Message); end;
  end;
  Result.ser := se;
end;


function TSeriesObject.SetSeriesNumber(n: byte; t: TSeriesObjectType): boolean;
Var
  i: integer;
  e: boolean;
  //fls: TFastLineSeries;
  //se: TChartSeries;
begin
  e := false;
  RemoveAllSeries;
  try
    setlength(fseries, n);
    for i:= 0 to n-1 do fseries[i] := CreateSeries( t );
  except
    on Ex: exception do begin e := true; LogMsg('EXCEPTION SetSeriesNumber' + Ex.Message); end;
  end;
  Result := not e;
end;


function TSeriesObject.AddSeries(t: TSeriesObjectType): boolean;
Var
  i: integer;
  e: boolean;
begin
  e := false;
  try
    i := length(fseries);
    setlength(fseries, i+1);
    fseries[i] := CreateSeries( t );
  except
    on Ex: exception do begin e := true; LogMsg('EXCEPTION AddSeries ' + Ex.Message); end;
  end;
  Result := not e;
end;



function TSeriesObject.GetSeries(n:byte): TChartSeries; //n is 0 .. nseries-1
begin
  Result := nil;
  if n< Length( fseries ) then Result := fseries[n].ser;
end;

function TSeriesObject.Count: integer;
begin
  Result := Length( fseries );
end;

procedure  TSeriesObject.ConfSeries(n:byte; legendtitle: string; xaxislabel: string; yaxislabel: string);
begin
  if n< Length( fseries ) then
    begin
      fseries[n].ser.Title := legendtitle;
      fseries[n].axlabelx := xaxislabel;
      fseries[n].axlabely := yaxislabel;
    end;
end;

function  TSeriesObject.GetXAxisLabel: string;  //takes from first series
begin
  Result := '';
  if Length(fseries)>0 then Result := fseries[0].axlabelx;
end;

function  TSeriesObject.GetYAxisLabel: string;
Var
  i, n: integer;
begin
  Result := '';
  n := Length(fseries);
  for i:= 0 to n-1 do
    begin
      Result := Result + fseries[i].axlabely;
      if i<n-1 then Result := Result + ', ';
    end;
end;

constructor TMyChartPanelObject.Create(p: TPanel);
Var
  i: integer;
begin
  fTargetPanel := p;
  fReady := false;
  //create runtime objects controls
  //!!!!! do not forget to set PARENT property to make them visible
       fChart := TChart.Create(p);
       fBuSavePNG := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuCopyBMP := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuCopyWMF := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuCopyTXT := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuReset := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuLeft := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuRight := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuPlus := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fBuMinus := TSpeedButton( AddControl( TControl(TSpeedButton.Create(p)), fbuttons) );
       fLaCoords := TLabel( AddControl( TControl(TLabel.Create(p) ), fotherctrl) );
  //
  for i:=0 to length( fbuttons )-1 do fbuttons[i].Parent := p;
  for i:=0 to length( fotherctrl )-1 do fotherctrl[i].Parent := p;
  //
  FLockConf := TMyLockableObject.Create;
  //
  fBmpNames := TStringlist.Create;
  setlength( fBitmaps, 0 );
  fLeftSeries := TSeriesObject.Create( fCHart, true, false );
  fRightSeries := TSeriesObject.Create( fCHart, false, true );
end;


destructor TMyChartPanelObject.Destroy;
begin
  //do not need to destroy buttons and, as Owner was assigned
  ClearBitmaps;
  fBmpNames.Destroy;
  fLeftSeries.Destroy;
  fRightSeries.Destroy;
  //
  MyDestroyAndNil( FLockConf);
end;


procedure TMyChartPanelObject.ClearBitmaps;
Var
 i: integer;
begin
  for i:=0 to Length(fBitmaps) - 1 do if fBItmaps[i]<>nil then fBItmaps[i].Destroy;
  SetLength(fBitmaps, 0);
end;




function  TMyChartPanelObject.AddControl(c: TControl; Var ctrllist: TControlList): TControl;
var
  i, j: integer;
begin
  Result := c; //!!! copy out the same ref
  i := length(ctrllist);
  setlength( ctrllist, i+1);
  ctrllist[i] := c;
end;


procedure TMyChartPanelObject.Init;
begin
  if fTargetPanel=nil then exit;
  fTargetPanel.Caption := '';
  fWidth := fTargetPanel.Width;
  fHeight := fTargetPanel.Height;
  LoadBitmaps;

    //button icons
    ConfigureSpeedBtn(fBuSavePNG, CFloppypng25, 'PNG');
    ConfigureSpeedBtn(fBuCopyBMP, '', 'BMP');
    ConfigureSpeedBtn(fBuCopyWMF, '', 'WMF');
    ConfigureSpeedBtn(fBuCopyTXT, '', 'TXT');
    ConfigureSpeedBtn(fBuPlus, '', '+');
    ConfigureSpeedBtn(fBuMinus, '', '-');
    ConfigureSpeedBtn(fBuLeft, '', '<');
    ConfigureSpeedBtn(fBuRight, '', '>');
    ConfigureSpeedBtn(fBuReset, '', 'RESET');
    // onclick handlers
    fBuReset.Onclick := ActionZoomReset;          //TNotifyEvent
    fBuSavePNG.Onclick := ActionSavePNG;
    fBuCopyBMP.Onclick := ActionCopyBMP;
    fBuCopyWMF.Onclick := ActionCopyWMF;
    fBuCopyTXT.Onclick := ActionCopyTXT;
    fBuPlus.Onclick := ActionZoomPlus;
    fBuMinus.Onclick := ActionZoomMinust;
    fBuLeft.Onclick := ActionMoveLeft;
    fBuRight.Onclick := ActionMoveRight;
  //
  DrawControls;
  fReady := true;
end;

procedure TMyChartPanelObject.Repaint;
begin
  fChart.Repaint;
end;


procedure TMyChartPanelObject.AfterResize;
begin
   DrawControls;
end;

procedure TMyChartPanelObject.BeginUpdate;
begin
  fChart.AutoRepaint := false;
end;

procedure TMyChartPanelObject.EndUpdate;  //refresh labels, data and so on
Var
  s: string;
begin
  fChart.BottomAxis.Title.Caption := IfThenElse( fLeftSeries.Count>0, fLeftSeries.GetXAxisLabel, fRightSeries.GetXAxisLabel);
  fChart.LeftAxis.Title.Caption := fLeftSeries.GetYAxisLabel;
  fChart.RightAxis.Title.Caption := fRightSeries.GetYAxisLabel;
  fChart.AutoRepaint := true;
  fChart.BottomAxis.Automatic := true;
  fChart.LeftAxis.Automatic := true;
  fChart.RightAxis.Automatic := true;
  fChart.Update;
  fChart.AutoSize := false;
  //fChart.Repaint;
end;

procedure TMyChartPanelObject.ShowLegend;
begin
  fChart.Legend.Visible := true;
end;

procedure TMyChartPanelObject.HideLegend;
begin
  fChart.Legend.Visible := false;
end;

procedure TMyChartPanelObject.LoadBitmaps;
Var
  bmp: TBitmap;
  files: TStringList;
  i: integer;
  fn: string;
begin
  files := TStringList.Create;
  files.Add(CFloppypng25);
  files.Add('IMG_1');

  //
  ClearBitmaps;
  fBmpNames.Clear;
  setlength(fBitmaps, files.Count);
  for i:=0 to files.Count-1 do
    begin
      bmp := TBitmap.Create;
      //fn := GlobalConfig.getAppPath+'icons\'+files[i];
      try
        //bmp.LoadFromFile(fn);
        bmp.LoadFromResourceName(HInstance, files[i] ); //bmp.LoadFromResource
      except
        on E: exception do begin ShowMessage( files[i] + 'failed' ); end;
      end;
      fBitmaps[i] := bmp;
      fBmpNames.Add( files[i]+ '=' +IntToStr(i) )
    end;
  files.Destroy;
end;

function TMyChartPanelObject.GetBMPbyName(s: string): TBitmap;
Var
 i, j: integer;
begin
  Result := nil;
  i := fBmpNames.IndexOfName(s);
  if i<0 then exit;
  j := StrToInt( fBmpNames.ValueFromIndex[ i ] );
  if j<length(fBitmaps) then Result := fBitmaps[j];
end;


procedure TMyChartPanelObject.ConfigureSpeedBtn(Const b: TSpeedButton; resbmpname: string; altname: string);
begin
  b.Flat := true;
  b.Caption := '';
  b.Glyph := GetBMPbyName(resbmpname);
  if (b.Glyph = nil) or (resbmpname = '') then b.Caption := altname;
end;



procedure TMyChartPanelObject.PlaceControlToTheRight(ctrl: TControl; nexttoleft: boolean; height, width: integer; leftspace, bottomspace: integer; top: integer; maxright: integer);
//if it would be too wide, makes new row
//instead of dimension or size use -1 for default
Var
  lpos, tpos: integer;
  left: TControl;
Const
  Cdefleftspace = 5;
  Cdefbottomspace = 2;
  CdefTop = 1;
begin
  if ctrl=nil then exit;
  if height <0  then height := ctrl.Height;
  if width <0  then width := ctrl.width;
  leftspace := ifthenelse( leftspace>=0, leftspace, Cdefleftspace);
  bottomspace := ifthenelse( bottomspace>=0, bottomspace, Cdefbottomspace);
  top := IfThenElse(top>=0, top, Cdeftop);
  //
  ctrl.Height := height;
  ctrl.Width := width;
  //
  lpos := leftspace;
  left := nil;
  if length(ftoolbarctrls)>0 then left := ftoolbarctrls[ length(ftoolbarctrls)-1 ];
  tpos := top;
  if (left<>nil) and nexttoleft then
    begin
      lpos := left.Left + left.Width + leftspace;
      tpos := left.Top;
    end;
  if (maxright>0) and ((lpos + width) > maxright) then //place to second row
    begin
      lpos := leftspace;
      tpos := tpos + height + bottomspace;
    end;
  ctrl.Top := tpos;
  ctrl.Left := lpos;
  AddControl(ctrl, ftoolbarctrls);
end;

procedure TMyChartPanelObject.PlaceExternalControlToTheRight(ctrl: TControl; leftspace: integer);
begin
  //chenge new owner of component!!
  ctrl.Parent := fTargetPanel;
  PlaceControlToTheRight( ctrl, true, -1,-1, leftspace, -1, -1, -1);
end;


procedure TMyChartPanelObject.DrawControls;
Var i, j, ypos, xpos, size, left, top, vspace, hspace, maxright: integer;
Const
  CBSize=20;  //for speed button, make size base + 1 + 3  margins
begin
  left := 5;
  maxright := fTargetPanel.Width;
  vspace := 5;
  hspace := 0;
  top := 5;
  size := CBSize + 4;
  //
  fHeight :=  fTargetPanel.Height;
  fWidth :=  fTargetPanel.Width;
  //line of buttons, make toolbar
  PlaceControlToTheRight(fBuSavePNG, false, size, size, left, vspace, top, maxright );
  PlaceControlToTheRight(fBuCopyBMP, true, size, size, 0, vspace, top, maxright );
  PlaceControlToTheRight(fBuCopyWMF, true, size, size, 0, vspace, top, maxright );
  PlaceControlToTheRight(fBuCopyTXT, true, size, size, 0, vspace, top, maxright );
  //
  fLaCoords.AutoSize := false;
  PlaceControlToTheRight(fLaCoords, true, size, 200, CBSize, vspace, top, maxright );
  //
  PlaceControlToTheRight(fBuPlus, true, size, size, CBSize, vspace, top, maxright );
  PlaceControlToTheRight(fBuMinus, true, size, size, 0, vspace, top, maxright );
  PlaceControlToTheRight(fBuReset, true, size, size, 0, vspace, top, maxright );
  //
  PlaceControlToTheRight(fBuLeft, true, size, size, CBSize, vspace, top, maxright );
  PlaceControlToTheRight(fBuRight, true, size, size, 0, vspace, top, maxright );
  //
  for i:=0 to Length(fbuttons)-1 do
    begin
      fbuttons[i].Visible := true;
      //fbuttons[i].Flat := true;
    end;
   //label
   fLaCoords.Color := clBlack;
   fLaCoords.Font.Color := clLime;
   fLaCoords.Font.Size := 10;
   fLaCoords.Caption := 'x=,y=';
    //
    top := fBuRight.Top + fBuRight.Height + vspace;
    fChart.Parent := fTargetPanel;
    fChart.Top := top;
    fChart.Left := 2;
    fchart.Height := fHeight - fChart.Top - 2;
    fchart.Width :=  fWidth - 4;
    fChart.LeftWall.Size := 0;
    fChart.View3D := false;
    fCHart.LeftAxis.Visible := true;
    fCHart.RightAxis.Visible := true;
    fChart.Legend.Alignment := laTop;
    fChart.Legend.LegendStyle := lsSeries;
    fChart.Legend.ShadowSize := 0;
    fChart.Legend.TopPos := 2;




    //
end;



procedure TMyChartPanelObject.ActionZoomReset(Sender: TObject);
begin
  FLockConf.Lock;
  try
    fConf.maximized := true;
    fConf.userpos := false;
  finally
    FLockConf.UnLock;
  end;
end;

procedure TMyChartPanelObject.ActionZoomPlus(Sender: TObject);
var
  cy, dy: double;
begin
  FLockConf.Lock;
  try
    with FConf do
      begin
        userpos := true;
        maximized := false;
        userXcenter := (userXmax + userXmin) / 2;
        userXinterval := userXmax - userXmin;
        //x *2 zoom
        userXmax := userXcenter + userXinterval/4;
        userXmin := userXcenter - userXinterval/4;
        userXinterval := userXinterval/2;
        //y *2 zoom
        cy := (userLymax + userLymin) / 2;
        dy :=  (userLymax - userLymin);
        userLymax := cy + dy/4;
        userLymin := cy - dy/4;
        cy := (userRymax + userRymin) / 2;
        dy :=  (userRymax - userRymin);
        userRymax := cy + dy/4;
        userRymin := cy - dy/4;
      end;
  finally
    FLockConf.UnLock;
  end;
end;

procedure TMyChartPanelObject.ActionZoomMinust(Sender: TObject);
var
  cy, dy: double;
begin
  FLockConf.Lock;
  try
    with FConf do
      begin
        userpos := true;
        maximized := false;
        userXcenter := (userXmax + userXmin) / 2;
        userXinterval := userXmax - userXmin;
        //x *2 zoom
        userXmax := userXcenter + userXinterval;
        userXmin := userXcenter - userXinterval;
        userXinterval := 2 * userXinterval;
        //y *2 zoom
        cy := (userLymax + userLymin) / 2;
        dy :=  (userLymax - userLymin);
        userLymax := cy + dy;
        userLymin := cy - dy;
        cy := (userRymax + userRymin) / 2;
        dy :=  (userRymax - userRymin);
        userRymax := cy + dy;
        userRymin := cy - dy;
      end;
  finally
    FLockConf.UnLock;
  end;
end;


procedure TMyChartPanelObject.ActionSavePNG(Sender: TObject);
begin
  //fChart.SaveToBitmapFile(); //tpngimage
end;

procedure TMyChartPanelObject.ActionCopyBMP(Sender: TObject);
begin
  ShowMessage('bmp');
end;

procedure TMyChartPanelObject.ActionCopyWMF(Sender: TObject);
begin
  ShowMessage('wmf');
end;

procedure TMyChartPanelObject.ActionCopyTXT(Sender: TObject);
begin
  ShowMessage('txt');
end;


procedure TMyChartPanelObject.ActionMoveRight(Sender: TObject);
begin
  ShowMessage('Reset');
end;


procedure TMyChartPanelObject.ActionMoveLeft(Sender: TObject);
Var
 dx : double;
begin
  FLockConf.Lock;
  try
    with FConf do
      begin
        dx := (userXmax - userXmin) * 0.8;  //shift by 80% of visible x    //last dispalyed range values
        if not isnan(dx) then
          begin
                maximized :=false;
                userpos := true;
                userXcenter := userXcenter - dx;
                userXmax := userXmax - dx;
                userXmin := userXmin - dx;
          end;
      end;
  finally
    FLockConf.UnLock;
  end;

end;


procedure TMyChartPanelObject.ActionMoveUp(Sender: TObject);
begin
  ShowMessage('Reset');
end;

procedure TMyChartPanelObject.ActionMoveDown(Sender: TObject);
begin
  ShowMessage('Reset');
end;





//********************************************************************************

{
     private
       fTargetPanel: TPanel;
       fChart: TChart;
       fBuReset: TButton;
       fBuLeft: TButton;
       fBuRight: TButton;
       fBuPlus: TButton;
       fBuMinus: TButton;
       fLaStatus: TLabel;
       fCBoxTimeScale: TComboBox;
}










procedure getDataFromMonRec( Var x, y: double; Var stype: TSeriesType;  pmonrec: PMonitorRec );
begin
  //EXPECT valid parameters!!!
      case stype of
               CSeriesVoltage: begin x:= pmonrec^.PTCrec.timestamp; y := pmonrec^.U;  end;
               CSeriesCurrent: begin x:= pmonrec^.PTCrec.timestamp; y := pmonrec^.Inorm;  end;
               CSeriesPower: begin x:= pmonrec^.PTCrec.timestamp; y := pmonrec^.Pnorm;  end;
               CSeriesRefVoltage: begin x:= pmonrec^.PTCrec.timestamp; y := pmonrec^.Uref;  end;
               //
                CSeriesTempCellTop: begin x:= pmonrec^.SensorData[CTCellTop].timestamp; y := pmonrec^.SensorData[CTCellTop].val;  end;
                CSeriesTempCellBot: begin x:= pmonrec^.SensorData[CTCellBot].timestamp; y := pmonrec^.SensorData[CTCellBot].val;  end;
                CSeriesTempbH: begin x:= pmonrec^.SensorData[CTbubH2].timestamp; y := pmonrec^.SensorData[CTbubH2].val;  end;
                CSeriesTempbO: begin x:= pmonrec^.SensorData[CTbubO2].timestamp; y := pmonrec^.SensorData[CTbubO2].val;  end;
               //
                 CSeriespBPsp: begin x:= pmonrec^.SensorData[CpBPControl].timestamp; y := pmonrec^.SensorData[CpBPControl].val;  end;
                 CSeriespA: begin x:= pmonrec^.SensorData[CpAnode].timestamp; y := pmonrec^.SensorData[CpBPControl].val;  end;
                 CSeriespC: begin x:= pmonrec^.SensorData[CpCathode].timestamp; y := pmonrec^.SensorData[CpBPControl].val;  end;
                 CSeriespPiston: begin x:= pmonrec^.SensorData[CpPiston].timestamp; y := pmonrec^.SensorData[CpPiston].val;  end;
               //
                 CSeriesFlowA: begin x:= pmonrec^.FlowData[CFlowAnode].timestamp; y := pmonrec^.FlowData[CFlowAnode].massflow; end;
                 CSeriesFlowC: begin x:= pmonrec^.FlowData[CFlowCathode].timestamp; y := pmonrec^.FlowData[CFlowCathode].massflow; end;
                 CSeriesFLowN: begin x:= pmonrec^.FlowData[CFlowN2].timestamp; y := pmonrec^.FlowData[CFlowN2].massflow; end;
               //
                 CSeriesFuseHardOn : begin x:= pmonrec^.PTCrec.timestamp; y := BoolToDouble( FlagIsSet( pmonrec^.PTCStatus.flagSet, CPtcHardFuseActivated ) );  end;
                 CSeriesFuseSWOn : begin x:= pmonrec^.PTCrec.timestamp; y := BoolToDouble( FlagIsSet( pmonrec^.PTCStatus.flagSet, CPtcSoftLimitationActive ) );  end;
                 CSeriesOutputOn: begin x:= pmonrec^.PTCrec.timestamp; y := BoolToDouble( pmonrec^.PTCStatus.isLoadConnected);  end;
            end;

end;




procedure ExtractData( Var seriessel: TSeriesSelection; Var chdata: TChartDataPack; Var mon: TMonitorMemDataStorage; monfrom, monto, nred: longint );
//monfrom, monto are determined elsewhere
//nred: reduction of number of points - for every nred points in monitor data storage, create set of 4 records in chart data (averga, min, max, average)
//       this is to censerve performance - not so many points to display
//this procedure knows which series are going to be plot - seriessel - and so extracts only coresponding data from memory storage
type
  TtmpRec = record
    ymin: double;
    ymax: double;
    ysum: double;
    x: double;     //last valid x
    nvalid: longint;
  end;

Var
 i, j, k: longint;
 monn, nx, nredx: longint;
 pmonrec: PMonitorRec;
 nser: byte;
 tmpwork: array of TTmpRec;
 x, y, avg: double;
 datan, datamax: longint;

begin
  monn := mon.CountTotal;
  //assert
  MakeSureIsInRange(monto, 0, monn-1);
  MakeSureIsInRange(monfrom, 0, monto);
  nx := monto - monfrom + 1;
  if nred<1 then nred := 1;
  if (nred>1) and (nred<4) then nred := 4;  //will be adding set of 4 points for every "point" to display (avg, min, max, avg)
  //ini - set n data to 0
  for k:=0 to chdata.nseries -1 do chdata.serdata[k].ndata := 0;
  //
  nser := seriessel.nseries;
  if nser<1 then
  begin
    logmsg('CHART ExtractData nseries is <1');
    exit;
  end;
  if seriessel.nseries<>chdata.nseries then
  begin
    LogWarning('CHART ExtractData seriessel.nseries<>chdata.nseries EXITING');
    exit;
  end;
  //ini
  setlength( tmpwork, nser ); //!!!
  //do it!
  Assert( monto>=monfrom );
  i:=monfrom;
  while (i <= monto) do  //main cycle traversing monitor data - must increment i inside!!!
  begin
    // intermediate ini tmp work
    for k:=0 to nser-1 do
      begin
      tmpwork[k].nvalid := 0;
      tmpwork[k].ysum := 0;
      tmpwork[k].ymin := NAN;
      tmpwork[k].ymax := NAN;
      tmpwork[k].x := NAN;
      end;
    for j := 1 to nred do  //for each nred ... averaging
      begin
        assert(i<monn);
        pmonrec := mon.GetRec(i);
        Inc(i);  //!!!
        if pmonrec=nil then
           begin
             logmsg('CHART ExtractData: got NIL on pmonrec');
             continue;
           end;
        for k:=0 to nser-1 do   //extract and process data for each series
          begin
            //get data
            x := NAN; y:= NAN;
            //
            getDataFromMonRec( x, y, seriessel.serconf[k].stype, pmonrec );
            //
            if (not isNan(x)) and (not isnan(y)) then
              begin
              inc(tmpwork[k].nvalid);
              tmpwork[k].ymin := mymin( tmpwork[k].ymin, y);
              tmpwork[k].ymax := mymax( tmpwork[k].ymax, y);
              tmpwork[k].ysum := tmpwork[k].ysum + y;
              tmpwork[k].x := x;
              end;
          end;   //for k
        if i>monto then break; //break for j //end of data already
      end; //for j
      //calculate avg and store data;
    for k:=0 to nser-1 do   //for every series, there is record from nvalid points
      begin
      if tmpwork[k].nvalid > 0 then //only add data fro chart, if valid
        begin
          try
            avg := tmpwork[k].ysum / tmpwork[k].nvalid;
          except
            on E: Exception do
              begin
                avg := 0;
                logmsg('CHART ExtractData Exception when avg calc: ' + E.Message);
              end;
          end;
          //add data point (set of 4  if nred>1) for this series
          datamax := CSeriesMaxTmpRecs;
          datan := chdata.serdata[k].ndata;
          if datan<datamax then //first point - x:avg_y
            begin
              chdata.serdata[k].x[datan] := tmpwork[k].x;
              chdata.serdata[k].y[datan] := avg;
              Inc(datan);
              chdata.serdata[k].ndata := datan;
            end;
          if (nred>1) and ((datan+2) < datamax ) then //remaining three records
            begin
              chdata.serdata[k].x[datan] := tmpwork[k].x;
              chdata.serdata[k].y[datan] := tmpwork[k].ymax;
              chdata.serdata[k].x[datan+1] := tmpwork[k].x;
              chdata.serdata[k].y[datan+1] := tmpwork[k].ymin;
              chdata.serdata[k].x[datan+2] := tmpwork[k].x;
              chdata.serdata[k].y[datan+2] := avg;
              datan := datan + 3;
              chdata.serdata[k].ndata := datan;
            end;
        end; //if valid
      end; //for k - adding records
  end; //while i
  //records should be processed now
end;  //proc ExtracData


end.

unit ModuleEISunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, TeEngine, Series, TeeProcs, Chart, StdCtrls, MVConversion,

  HWAbstractDevicesV3, PTCInterface_KolPTC_TCPIP_new,
  MyImportKolData,
  MyParseUtils, MyChartModule, MyPSUtils_winapi,
  Logger, HWInterface, FormGlobalConfig, ToolWin, ComCtrls,
  StreamIO;

type

 TEISModule = class
    public
      constructor Create;
      destructor Destroy; override;
   public
     procedure Updatecmd;
     procedure Run(Var memo: TMemo);  //memo for messages
     procedure Stop;
     procedure AssignKolPTC(Const kolPTC: TKolPTCObject);
     procedure Timer(xo: TObject);
     procedure HandleEvent( s: string );
     procedure ExportDataAsMPT;
   public
     fDCfb: TKolPTCFeedback;
     fDCusePresentSP: boolean;
     fDCsetpoint: double;
     fDCwaitbeforeEIS: longword;
     //
     fEISstartf: double;
     fEISendf: double;
     fEISpointpd: word;
     fEISACamp: double; //in mV
     fEISUrng: byte;
     fEISIrng: byte;
     fEISRepeatPeriods: byte;
     fEISsamples: word;
     //
     fCMDstr: string;
     fInProgress: boolean;
     fActFreq: double;
     fActFilename: string;
     //
     fLastDataImport: TImportedEISFile;
   private
     fTimer: TTimer;
     fMemo: TMemo;
     fkolPTC: TKolPTCObject;
     fPTCServerPath: string;
     //
     fStopRequest: boolean;
   end;




type
  TFormEIS = class(TForm)
    Label8: TLabel;
    BuRun: TButton;
    BuStop: TButton;
    Ecmd: TEdit;
    Memo1: TMemo;
    BuHide: TButton;
    Button2: TButton;
    Timer1: TTimer;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    CBfbsel: TComboBox;
    LaStartSP: TLabel;
    Esetpoint: TEdit;
    Label10: TLabel;
    Ewait: TEdit;
    Panel3: TPanel;
    Label3: TLabel;
    Efstart: TEdit;
    Efend: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Epointspd: TEdit;
    Label6: TLabel;
    Eamplitude: TEdit;
    EVrange: TEdit;
    Label7: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    EIrange: TEdit;
    Erepeatperiods: TEdit;
    ChkUSeActSP: TCheckBox;
    Panel4: TPanel;
    labfname: TLabel;
    Panfname: TPanel;
    Label9: TLabel;
    PanFreq: TPanel;
    Label2: TLabel;
    PanStatus: TPanel;
    ComboBox1: TComboBox;
    CheckBox1: TCheckBox;
    Memo2: TMemo;
    Button1: TButton;
    procedure BuHideClick(Sender: TObject);
    procedure CBfbselChange(Sender: TObject);
    procedure EsetpointChange(Sender: TObject);
    procedure EwaitChange(Sender: TObject);
    procedure EfstartChange(Sender: TObject);
    procedure EfendChange(Sender: TObject);
    procedure EpointspdChange(Sender: TObject);
    procedure EamplitudeChange(Sender: TObject);
    procedure EVrangeChange(Sender: TObject);
    procedure EIrangeChange(Sender: TObject);
    procedure ErepeatperiodsChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BuRunClick(Sender: TObject);
    procedure BuStopClick(Sender: TObject);
    procedure ChkUSeActSPClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    fBuReset: TBUtton;
    fBuX: TBitBtn;
    fnyquist: boolean;
    fbode: boolean;
    //
    fLastFreq: double;
    fLastChartUpdate: longword;
    fUpdateAfterMS: longword;
    //
    procedure UpdateForm;
    procedure UpdateChart;
    function FillChartSeries(data: TImportedEISFile; ChartObj: TMyChartPanelObject): boolean;

  public
    { Public declarations }
    fChartSeries: array of TFastLineSeries;
    fEisModule: TEISModule;
    fPanelChart: TMyChartPanelObject;
    fEISdata: TImportedEISFile;
    fEISdata2 : TImportedEISFile;
  end;






var
  FormEIS: TFormEIS;

implementation

{$R *.dfm}

uses MyUtils, StrUtils, math;


constructor TEISModule.Create;
begin
  fTimer := TTimer.Create(nil);
  fTimer.OnTimer := Timer;
  //ini val
  fDCfb := CPTCFbI;
  fDCsetpoint := 0;
  fDCwaitbeforeEIS := 10;
  fDCusePresentSP := true;
  fEISstartf := 100;
  fEISendf := 100000;
  fEISpointpd := 10;
  fEISACamp := 10;
  fEISUrng := 1;
  fEISIrng := 1;
  fEISRepeatPeriods := 3;
  fEISsamples := 1024;
  //
  fPTCServerPath := '';
end;


destructor TEISModule.Destroy;
begin
  fTimer.Destroy;
end;


procedure TEISModule.Updatecmd;
begin
  fCMDstr := 'StartEIS '+ FloatToStr(fEISstartf) + ' ' + FloatToStr(fEISendf) + ' '
              + IntToStr(fEISpointpd) + ' ' + FloatToStr(fEISACamp) + ' '
              + IntToStr(fEISUrng) + ' ' + IntToStr(fEISIrng) + ' '
              + IntToStr(fEISRepeatPeriods) + ' ' + IntToStr(fEISsamples);
end;


procedure TEISModule.Run(Var memo: TMemo);  //memo for messages
Var
  reply: string;
begin
    if fkolPTC=nil then exit;
    fPTCServerPath := fkolPTC.PTCServerAppPath;
    fMemo := memo;
    fStopRequest := false;
    fTimer.Interval := 20;
    fTimer.Enabled := true;
    Updatecmd;


    fkolPTC.TCPSendUserCMD( fCMDstr, reply, 500 );
end;


procedure TEISModule.Stop;
Var
  reply: string;
begin
  if fkolPTC=nil then exit;
  fStopRequest := true;
  fkolPTC.TCPSendUserCMD( 'StopEis', reply, 500 );
  fkolPTC.TCPSendUserCMD( 'StopAcq', reply, 500 );
end;


procedure TEISModule.Timer(xo: TObject);  //memo for messages
Var
  s: string;
begin
  if fkolPTC = nil then exit;
      while fkolPTC.EventQueuePTCServer.Count()>0 do
        begin
          fkolPTC.EventQueuePTCServer.PopMsg( s );
          HandleEvent( s );
          if fmemo<>nil then fMemo.Lines.Add( 'EVENT ' + s );
        end;
end;


procedure TEISModule.HandleEvent( s: string );
Var
  tl: TTokenList;
  ename, evar: string;
Const
  CScansDir = 'scans';
begin
  ParseStrSimple(s, tl);
  if length(tl)<2 then exit;
  ename := tl[0].s;
  evar := tl[1].s;

  if ename = 'PTC.EisPointReady' then if length(tl)>=3 then fActFreq := MyStrToFloat( tl[2].s );
  if ename = 'PTC.EisStarted' then  fInProgress := true;
  if ename = 'PTC.AcqLog' then fActFilename := fPTCServerPath + CScansDir + CPathSlash + evar;
  if ename = 'PTC.EisIdle' then
    begin
      fMemo.Lines.Add( 'EIS FINISHED');
      fInProgress := false;
    end;
end;


procedure TEISModule.AssignKolPTC(Const kolPTC: TKolPTCObject);
begin
  fkolPTC := kolPTC;
end;

procedure TEISModule.ExportDataAsMPT;
begin
  ShowMessage('xxx');
end;




//


procedure TFormEIS.FormCreate(Sender: TObject);
begin
  fEisModule := TEISModule.Create;
  //
  fLastFreq := -1;
  fLastChartUpdate := 0;
  fUpdateAfterMS := 1000;
  //
    fEISdata := TImportedEISFile.Create;
    fEISdata2 := TImportedEISFile.Create;
  //
  fPanelChart := TMyChartPanelObject.Create( Panel1 );
  fPanelChart.Init;
  fPanelChart.PlaceExternalControlToTheRight( ComboBox1, 5);
end;

procedure TFormEIS.FormDestroy(Sender: TObject);
begin
  fEisModule.Destroy;
  fPanelChart.Destroy;
  fEISdata.Destroy;
  fEISdata2.Destroy;
end;


procedure TFormEIS.BuHideClick(Sender: TObject);
begin
  FormEIS.Hide;
end;

procedure TFormEIS.UpdateForm;
Var
  s, chmask: string;
  b: byte;
  fb: TKolPTCFeedback;
  sweeps, nrep: word;
begin
  fb := CPTCFbV2;
  case CBfbsel.ItemIndex of
    0: fb := CPTCFbV2;
    1: fb := CPTCFbV4;
    2: fb := CPTCFbVref;
    3: fb := CPTCFbI;
  end;
  if fb=CPTCFbI then LaStartSP.Caption := 'DC setpoint (A)' else
    LaStartSP.Caption := 'DC setpoint (V)';
  //
  Esetpoint.Enabled  := not ChkUSeActSP.Checked;
  CBfbsel.Enabled := not ChkUSeActSP.Checked;
  //
  //update internal module state
  fEisModule.fDCfb := fb;
  fEisModule.fDCsetpoint := MyStrToFloat( Esetpoint.Text );
  fEisModule.fDCwaitbeforeEIS := MyXStrToInt( Ewait.Text );
  fEisModule.fDCusePresentSP := ChkUSeActSP.Checked;
  //...
  fEisModule.fEISstartf := MyStrToFloat( Efstart.Text );
  fEisModule.fEISendf := MyStrToFloat( Efend.Text );
  fEisModule.fEISpointpd := MyXStrToInt( Epointspd.Text );
  fEisModule.fEISACamp := MyStrToFloat( Eamplitude.Text );
  fEisModule.fEISUrng := MyXStrToInt( EVrange.Text );
  fEisModule.fEISIrng := MyXStrToInt( EIrange.Text );
  fEisModule.fEISRepeatPeriods := MyXStrToInt( Erepeatperiods.Text );
  //
  fEisModule.Updatecmd;
  Ecmd.Text := fEisModule.fCMDstr;
end;


procedure TFormEIS.CBfbselChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EsetpointChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EwaitChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EfstartChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EfendChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EpointspdChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EamplitudeChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EVrangeChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.EIrangeChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.ErepeatperiodsChange(Sender: TObject);
begin
  UpdateForm;
end;

procedure TFormEIS.Timer1Timer(Sender: TObject);
Var
 s: string;
begin
  PanStatus.Caption := IfThen(fEisModule.fInProgress, 'Running...', 'Idle');
  Panfname.Caption := fEisModule.fActFilename ;
  PanFreq.Caption := FloatToStr( fEisModule.fActFreq );
  //updatechart
  if (fEisModule.fInProgress) and (fLastFreq<>fEisModule.fActFreq) and
        (TimeDeltaTICKNowMS( fLastChartUpdate) > fUpdateAfterMS ) then
    begin
      fLastFreq := fEisModule.fActFreq;
      fLastChartUpdate := TimeDeltaTICKgetT0;
      try
        UpdateChart;
      except
        on E: exception do begin ShowMessage(E.Message); end;
      end;
    end;
end;


procedure TFormEIS.UpdateChart;
Var
  b: boolean;
  fname, sp: string;
begin
  fname := fEisModule.fActFilename;   //inclding full path
  if CheckBox1.Checked then fname := GlobalConfig.getAppPath + 'scans/20170124090533_EIS.dat';
  //
  if fname='' then exit;
  //ShowMessage(fname);
  Memo1.Lines.Add( ' Will import: ' + fname);
  fEISdata.Clear;
  b := ImportEISfile( fEISdata, fname );   //(Var fdata: TImportedCVFile; name: string): boolean;
  Memo1.Lines.Add( ' Import res: ' + BoolToStr( b ) );
  Memo1.Lines.Add( ' Data points: ' + IntToStr( fEISdata.fNrows ) );
  //
  FillChartSeries(fEISdata, fPanelChart);
end;



function TFormEIS.FillChartSeries(data: TImportedEISFile; ChartObj: TMyChartPanelObject): boolean;
Var
  ser1, ser2:  TChartSeries;
  col1, col2, col3: TDataColumn;
  i,j,k, nd: longint;
  dd, logf, logz: double;
begin
  result := false;
  if (data=nil) or (chartobj=nil) then exit;
  ChartObj.Chart.AutoRepaint := false;
  //
  nd := data.fNrows;
  if data.fNcols<15 then exit;
  //
  ChartObj.BeginUpdate;
  if fnyquist then
    begin
      ChartObj.LeftSeriesObj.SetSeriesNumber(1, CSOTFastLine);
      ChartObj.RightSeriesObj.SetSeriesNumber(0, CSOTFastLine);
      ChartObj.LeftSeriesObj.ConfSeries(0, '-Im(Z) vs Re(Z)', 'Re(Z)/Ohm', '-Im(Z)/Ohm');
      ChartObj.HideLegend;
      ser1 := ChartObj.LeftSeriesObj.GetSeries(0);
      Ser1.Clear;
      Ser1.XValues.Order := loNone;
      Ser1.YValues.Order := loNone;
      //Ser1.AddNullXY()
      col1 := data.datacolumns[3]; //x Re
      col2 := data.datacolumns[4]; //y Im
      //Memo2.Lines.Clear;
      //Memo2.Lines.Add( 'X' + #9 + 'Y' );
		  for i:=0 to nd-1 do
		    begin
		      ser1.AddXY( col1[i], -col2[i] );
          //Memo2.Lines.Add( FloatToStr( col1[i] ) + #9 + FloatToStr( -col2[i] ) );
		    end;
    end
  else
    begin
      ChartObj.LeftSeriesObj.SetSeriesNumber(1, CSOTFastLine);
      ChartObj.RightSeriesObj.SetSeriesNumber(1, CSOTFastLine);
      ChartObj.LeftSeriesObj.ConfSeries(0, 'log(Z) vs log(f)', 'log( frequency/Hz )', 'log( Z/Ohm )');
      ChartObj.RightSeriesObj.ConfSeries(0, 'Phase vs log(f)', '', 'Phase/deg');
      ChartObj.ShowLegend;
      ser1 := ChartObj.LeftSeriesObj.GetSeries(0);
      ser2 := ChartObj.RightSeriesObj.GetSeries(0);
      Ser1.Clear;
      Ser2.Clear;
      col1 := data.datacolumns[5]; //x f
      col2 := data.datacolumns[1]; //y Z
      col3 := data.datacolumns[2]; //x phase
	    for i:=0 to nd-1 do
		    begin
          try
            logf := log10(col1[i]);
            logz := log10(col2[i])
          except
             on E: exception do begin logf := 0; logz := 0; end;
          end;
		      ser1.AddXY( logf, logz );
          ser2.AddXY( logf, col3[i] );
		    end;
    end;
  //
  ChartObj.EndUpdate;
  ChartObj.Repaint; //Chart.Repaint;
end;


procedure TFormEIS.BuRunClick(Sender: TObject);
Var
  ptco: TPotentiostatObject;
  reply: string;
begin
  BuRun.Enabled := false;
  ptco := MainHWInterface.PTCControl.ControlObj;
  if ptco is TKolPTCObject then fEisModule.AssignKolPTC( TKolPTCObject( ptco ) );
  fEisModule.Run( Memo1 );
  BuRun.Enabled := true;
end;

procedure TFormEIS.BuStopClick(Sender: TObject);
begin
   fEisModule.Stop;
   BuRun.Enabled := true;
end;

procedure TFormEIS.ChkUSeActSPClick(Sender: TObject);
begin
  UpdateForm;
end;



procedure TFormEIS.FormShow(Sender: TObject);
begin
  UpdateForm;
  ComboBox1Change(nil);
  Timer1.Enabled := true;
end;

procedure TFormEIS.FormHide(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TFormEIS.Button2Click(Sender: TObject);
begin
  UpdateChart;
end;

procedure TFormEIS.Button3Click(Sender: TObject);
begin
  fPanelChart.Init;
end;

procedure TFormEIS.Button4Click(Sender: TObject);
begin
    fPanelChart.Repaint;
end;

procedure TFormEIS.Panel1Resize(Sender: TObject);
begin
  fPanelChart.AfterResize;
end;

procedure TFormEIS.ComboBox1Change(Sender: TObject);
begin
  fnyquist := false;
  fbode := false;
  case ComboBox1.ItemIndex of
    0: fnyquist := true;
    1: fbode := true;
  end;
  UpdateChart;
end;

procedure TFormEIS.Button1Click(Sender: TObject);
begin
  fEisModule.ExportDataAsMPT;
end;

end.

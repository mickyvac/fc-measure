unit ModuleCVunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  FormHWAccessControlUnit, Logger, HWInterface,  myutils, FormGLobalConfig,
  HWAbstractDevicesV3, PTCInterface_KolPTC_TCPIP_new, ExtCtrls, TeEngine,
  Series, TeeProcs, Chart,
  MyParseUtils, MyImportKolData, Buttons;


type
  TFormCV = class(TForm)
    CBfbsel: TComboBox;
    Label1: TLabel;
    EStartV: TEdit;
    LaStartSP: TLabel;
    EScanRate: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EVertex1: TEdit;
    EVertex2: TEdit;
    Label5: TLabel;
    Erepeat: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    EfinishV: TEdit;
    BuRun: TButton;
    BuStop: TButton;
    Ecmd: TEdit;
    Label8: TLabel;
    Memo1: TMemo;
    LaSweepCnt: TLabel;
    BuHide: TButton;
    Timer1: TTimer;
    Button1: TButton;
    Chart1: TChart;
    Series1: TFastLineSeries;
    Label9: TLabel;
    Button2: TButton;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    procedure UpdateCmd;
    procedure EStartVChange(Sender: TObject);
    procedure EScanRateChange(Sender: TObject);
    procedure EVertex1Change(Sender: TObject);
    procedure EVertex2Change(Sender: TObject);
    procedure ErepeatChange(Sender: TObject);
    procedure EfinishVChange(Sender: TObject);
    procedure CBfbselChange(Sender: TObject);
    procedure BuHideClick(Sender: TObject);
    procedure BuRunClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BuStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ChkUSeActSPClick(Sender: TObject);
  private
    kolPTC: TKolPTCObject;
  public
    { Public declarations }
    fCVfilename: string;
    fChartSeries: array of TFastLineSeries;
    procedure HandleEvent( s: string );
    function FillChart(data: TImportedCVFile; Chart: TChart): boolean;
    function SetChartSerNumber(n: byte; removeremaining: boolean = false): boolean;
  end;

var
  FormCV: TFormCV;

implementation

{$R *.dfm}

{
CV:
StartCV <U8 VChannel> <U8 Mask> <float Start> <float Margin1> <float Margin2> <float End> <float Speed> <U16 Sweeps>
- VChannel - napetový kanál pro zpetnou vazbu (stejné císlo jako mask)
- Mask - merící kanály, které se budou zaznamenávat. Proud a VChannel bude vybrán automaticky, i když ho zde nevybereš
- Start-Margin1-Margin2-End  - napetové meze. Zacíná se na Start, pak se jede na Margin1, pak na Margin2 a pak se kmitá mezi nimi a skoncí se na End
- Speed je v mV za sekundu
- Sweeps je pocet tech lineárních cástí mezi napetovými mezemi. Když by byl moc malý, tak se prípadne vynechájí marginy, takže extrém =1 znamená Start->End
Príkaz si sám zapne relé, pokud je treba a pokud bylo vypnuté, tak ho zase vypne po skoncení.
}



procedure TFormCV.UpdateCmd;
Var
  s, chmask: string;
  b: byte;
  sweeps, nrep: word;
begin
  b := 1;
  chmask := '15';
  case CBfbsel.ItemIndex of
    0: b:= 1;
    1: b := 2;
    2: b := 0;
  end;
  nrep := StrToInt( Erepeat.Text);
  if nrep<1 then nrep := 1;
  sweeps := nrep * 2 + 2;
  LaSweepCnt.Caption := IntToStr( sweeps );
//StartCV <U8 VChannel> <U8 Mask> <float Start> <float Margin1> <float Margin2> <float End> <float Speed> <U16 Sweeps>
  s := 'StartCV '+ IntToStr(b) + ' ' + chmask + ' ' + EStartV.Text + ' ' + EVertex1.Text + ' ' +
       EVertex2.Text + ' ' + EfinishV.Text + ' ' +  EScanRate.Text + ' ' + IntToStr( sweeps );
  Ecmd.Text := s;
end;


procedure TFormCV.EStartVChange(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.EScanRateChange(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.EVertex1Change(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.EVertex2Change(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.ErepeatChange(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.EfinishVChange(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.CBfbselChange(Sender: TObject);
begin
  UpdateCmd;
end;

procedure TFormCV.BuHideClick(Sender: TObject);
begin
  FormCV.Hide;
end;

procedure TFormCV.BuRunClick(Sender: TObject);
Var
  ptco: TPotentiostatObject;
  reply: string;
begin
  if kolPTC = nil then
    begin
      ptco := MainHWInterface.PTCControl.ControlObj;
      if ptco is TKolPTCObject then kolPTC := TKolPTCObject( ptco );
    end;
  if kolPTC<>nil then
    begin
      KolPTC.EventQueuePTCServer.Clear;
      Timer1.Enabled := true;
      kolPTC.TCPSendUserCMD( Ecmd.Text, reply, 500 );
      Memo1.Lines.Add( 'Send - reply:  ' + reply);
    end;
end;

procedure TFormCV.Timer1Timer(Sender: TObject);
Var
 s: string;
begin
  if kolPTC=nil then exit;
  while kolPTC.EventQueuePTCServer.Count > 0 do
    begin
      while kolPTC.EventQueuePTCServer.Count()>0 do
        begin
          kolPTC.EventQueuePTCServer.PopMsg( s );
          HandleEvent( s );
          Memo1.Lines.Add( 'EVENT ' + s );
        end;
      //if
    end;
  Label9.Caption := fCVfilename;
end;


procedure TFormCV.HandleEvent( s: string );
Var
  tl: TTokenList;
  ename, evar: string;
begin
  ParseStrSimple(s, tl);
  if length(tl)<2 then exit;
  ename := tl[0].s;
  evar := tl[1].s;
  if ename = 'PTC.AcqLog' then fCVfilename := evar;
  if ename = 'PTC.AcqIdle' then Memo1.Lines.Add( 'PTC GOT IDLE');
end;


procedure TFormCV.FormCreate(Sender: TObject);
begin
  kolPTC := nil;
end;

procedure TFormCV.Button1Click(Sender: TObject);
begin
  if kolPTC=nil then exit;
  KolPTC.EventQueuePTCServer.Clear;
  Memo1.LInes.Add('waiting');
  Timer1.Enabled := true;
end;

procedure TFormCV.BuStopClick(Sender: TObject);
Var
 reply: string;
begin
  Timer1.Enabled := false;
  kolPTC.TCPSendUserCMD( 'stopacq', reply, 500 );
  Memo1.LInes.Add('STOP |' + reply);
end;

procedure TFormCV.FormShow(Sender: TObject);
begin
  UpdateCMD;
end;



function TFormCV.SetChartSerNumber(n: byte; removeremaining: boolean = false): boolean;
var
  i: integer;
  e: boolean;
begin
  e := false;
  if Length(fChartSeries)< n then setlength(fChartSeries, n);
  if removeremaining and (Length(fChartSeries)>n) then
    begin
      for i:= n to Length(fChartSeries)-1 do fChartSeries[i].Destroy;
      setlength(fChartSeries, n);
    end;
  //make sure is created  
  for i:= 0 to Length(fChartSeries)-1 do if fChartSeries[i] = nil then fChartSeries[i] := TFastLineSeries.Create(Chart1);
  Result := not e;
end;


function TFormCV.FillChart(data: TImportedCVFile; Chart: TChart): boolean;
Var
  ser1, ser2:  TChartSeries;
  col1, col2: TDataColumn;
  i,j,k, nd: longint;
begin
  result := false;
  if (data=nil) or (chart=nil) then exit;
  Chart.AutoRepaint := false;
  for i:=0 to Length(fChartSeries)-1 do
    begin
      if fChartSeries[i]<> nil then fCHartSeries[i].ParentChart := nil;
    end;
  if not SetChartSerNumber(1) then exit;
  ser1 :=  fChartSeries[0];
  //ser2 :=  fChartSeries[1];
  Ser1.Clear;
  //Ser2.Clear;
  Ser1.ParentChart := Chart;
  Chart.AddSeries( ser1 );
  //Ser2.ParentChart := Chart;
  Ser1.Title := 'I vs Ewe';
  nd := data.fNrows;
  if data.fNcols<5 then exit;
  col1 := data.datacolumns[2]; //x Vsense
  col2 := data.datacolumns[4]; //y I
  //
  for i:=0 to nd-1 do
    begin
      ser1.AddXY( col1[i], col2[i] );
    end;
  ser1.Active := true;
  Chart.AutoRepaint := true;
end;



procedure TFormCV.Button2Click(Sender: TObject);
Var
 data: TImportedCVFile;
 b: boolean;
 s: string;
begin
  fCVfilename := '20170120132709_CV.dat';
  data := TImportedCVFile.Create;
  s := GlobalConfig.getAppPath + 'scans/'+fCVfilename;
  b := ImportCVfile( data, s );   //(Var fdata: TImportedCVFile; name: string): boolean;
  Memo1.Lines.Add( ' Import test: ' + s + '  res: ' + BoolToStr( b ) );
  Memo1.Lines.Add( ' Data points: ' + IntToStr( data.fNrows ) );

  FillChart(data, Chart1);

  data.destroy;
end;

procedure TFormCV.BitBtn1Click(Sender: TObject);
begin
  //DrawIconEx
end;

procedure TFormCV.ChkUSeActSPClick(Sender: TObject);
begin
  UpdateCMD;
end;

end.

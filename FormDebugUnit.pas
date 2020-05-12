unit FormDebugUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  HWAbstractDevicesV3, DataStorage, myUtils, MVConversion,
  FormPTCHardwareUnit, HWInterface, ExtCtrls, MyChartModule, PTCINterface_KOlPTC_TCPIP_new;

type
  TFormDebug = class(TForm)
    BuDebugMemory: TButton;
    BuInfo: TButton;
    LaMainChartMsg: TLabel;
    Label1: TLabel;
    BuMonSizeOf: TButton;
    BuHide: TButton;
    LaMainChartMsg2: TLabel;
    LaChartTime: TLabel;
    LaMainChartMsg3: TLabel;
    MeChart: TMemo;
    MeChart2: TMemo;
    chkChartDump: TCheckBox;
    cbKolPTcLog: TCheckBox;
    CheckBox2: TCheckBox;
    Label4: TLabel;
    Label3: TLabel;
    ELogInterval: TEdit;
    Button2: TButton;
    Memo1: TMemo;
    BuMonListHist: TButton;
    BuMonClearHist: TButton;
    Button1: TButton;
    Panel1: TPanel;
    ScrollBar1: TScrollBar;
    Edit1: TEdit;
    Label2: TLabel;
    Button3: TButton;
    TestPanel: TPanel;
    BuTestChart: TButton;
    Button4: TButton;
    Edit2: TEdit;
    Button5: TButton;
    ListBox1: TListBox;
    Button6: TButton;
    procedure BuHideClick(Sender: TObject);
    procedure BuDebugMemoryClick(Sender: TObject);
    procedure BuInfoClick(Sender: TObject);
    procedure BuMonSizeOfClick(Sender: TObject);
    procedure cbKolPTcLogClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BuMonListHistClick(Sender: TObject);
    procedure BuMonClearHistClick(Sender: TObject);
    procedure ELogIntervalChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BuTestChartClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    //testchart: TMyChartModule;
  public
    { Public declarations }
    origevent : TMessageEvent;
    procedure myeventlog(var Msg: TMsg; var Handled: Boolean);
  end;

var
  FormDebug: TFormDebug;

implementation

uses debug, main;

{$R *.dfm}

procedure TFormDebug.BuHideClick(Sender: TObject);
begin
  FormDebug.Hide;
end;

procedure TFormDebug.BuDebugMemoryClick(Sender: TObject);
begin
  {$ifdef FastMM4Add}
  ShowFastMMUsageTracker;
  {$else}
  ShowMessage('Do nothing because ''FastMM4.pas'' is not included.');
  {$endif}
end;

procedure TFormDebug.BuInfoClick(Sender: TObject);
begin
  //ShowMessage( 'Compiled on: ' + DateTimeToStr(_builddatetime)  );
  //ShowMessage( 'PTC: ' + MainPTCiface.Info );
  Form3.Show;
end;

procedure TFormDebug.BuMonSizeOfClick(Sender: TObject);
begin
  ShowMessage( IntToStr( sizeof( TMonitorRec )));
end;

procedure TFormDebug.cbKolPTcLogClick(Sender: TObject);
begin
    logfiledebug := cbKolPTcLog.Checked;
end;

procedure TFormDebug.CheckBox2Click(Sender: TObject);
begin
  if ( CheckBox2.Checked ) then
  begin
    //activate event logging
    origevent := Application.OnMessage;
    Application.OnMessage := myeventlog;
  end
  else
  begin //disable event log
    Application.OnMessage := origevent;
  end;
end;

procedure TFormDebug.myeventlog(var Msg: TMsg; var Handled: Boolean);
begin
  Memo1.Lines.Add(TimeToStr(Now) + ' msg '+ IntToStr( msg.message) + ' w ' + IntToStr(msg.wParam) +  ' i ' + IntToStr(msg.lParam));
  if Assigned(origevent) then origevent(msg, handled);
end;


procedure TFormDebug.Button2Click(Sender: TObject);
begin
    if FormMain.maingrconf.enabled then
    begin
      FormMain.MainChart.Enabled := false;
      FormMain.maingrconf.enabled := false;
    end
  else
    begin
      FormMain.MainChart.Enabled := true;
      FormMain.maingrconf.enabled := true;
    end;
end;

procedure TFormDebug.BuMonListHistClick(Sender: TObject);
Var i: integer;
    pd: PMonitorRec;
begin
  Memo1.Lines.Clear;
  for i :=1 to MonitorMemHistory.CountTotal do
    begin
    pd := MonitorMemHistory.GetRec(i-1);
    if pd=nil then Memo1.Lines.Add( IntToStr(i)+ ' nil' )
    else
      Memo1.Lines.Add(IntToStr(i)+ 'time:' + FloatTostr(pd^.PTCrec.timestamp) + ' x: ' + FloatTostr(pd^.Inorm) + ' y: ' +  FloatTostr(pd^.U) );
    end;
end;

procedure TFormDebug.BuMonClearHistClick(Sender: TObject);
begin
  MonitorMemHistory.RemoveAllData;
end;

procedure TFormDebug.ELogIntervalChange(Sender: TObject);
begin
    MainHWInterface.MinLogInterval := StrToIntDef(ELogInterval.Text, 300);
end;

procedure TFormDebug.Button1Click(Sender: TObject);
begin
  Panel1.Color := HSLtoTColor(0, 1, 0.5);
end;

procedure TFormDebug.ScrollBar1Change(Sender: TObject);
Var
  c: TColor;
  l: longint;
begin
  c := GenerateRainbowColor( ScrollBar1.Position, ScrollBar1.Max);
  Panel1.Color := c;
  l := c;
  Edit1.Text := IntToStr( l and $FF ) + ' ' + IntToStr( (l and $FF00) div 256 ) + ' ' + IntToStr( (l and $FF0000) div (256*256) );
end;

procedure TFormDebug.Button3Click(Sender: TObject);
Var
  mh: TMonitorMemDataStorage;
  i: longint;
  rec: TMonitorRec;
  pr: PMonitorRec;
  c, x: longint;
begin
  mh := TMonitorMemDataStorage.Create;
  Memo1.Lines.Clear;
  Memo1.Lines.Add( 'Start: c=' + IntToStr(c));
    for i:=1 to 300 do
      begin
        rec.U := i;
        rec.PTCrec.timestamp := Now;
        x := mh.AddRec(@rec);
        c := mh.CountTotal;
        Memo1.Lines.Add( 'i=' + IntToStr(i) + ' x=' + IntToStr(x) +' c=' + IntToStr(c));
      end;
  Memo1.Lines.Add( '----Dump----');
    for i:=1 to 300 do
      begin
        pr := mh.GetRec(i);
        if pr=nil then Memo1.Lines.Add( 'i=' + IntToStr(i) + ' pr=NIL')
        else
           Memo1.Lines.Add( 'i=' + IntToStr(i) + ' pr.ts=' + FloatToStr( pr^.PTCrec.timestamp) +' pr.U=' + FloatToStr(pr^.U));
      end;
  mh.MakeSpaceProcents(50);
  Memo1.Lines.Add( '----Dump----');
    for i:=1 to 300 do
      begin
        pr := mh.GetRec(i);
        if pr=nil then Memo1.Lines.Add( 'i=' + IntToStr(i) + ' pr=NIL')
        else
           Memo1.Lines.Add( 'i=' + IntToStr(i) + ' pr.ts=' + FloatToStr( pr^.PTCrec.timestamp) +' pr.U=' + FloatToStr(pr^.U));
      end;
    for i:=1 to 300 do
      begin
        rec.U := i;
        rec.PTCrec.timestamp := Now;
        x := mh.AddRec(@rec);
        c := mh.CountTotal;
        Memo1.Lines.Add( 'i=' + IntToStr(i) + ' x=' + IntToStr(x) +' c=' + IntToStr(c));
      end;
  Memo1.Lines.Add( '----Dump----');
    for i:=1 to 300 do
      begin
        pr := mh.GetRec(i);
        if pr=nil then Memo1.Lines.Add( 'i=' + IntToStr(i) + ' pr=NIL')
        else
           Memo1.Lines.Add( 'i=' + IntToStr(i) + ' pr.ts=' + FloatToStr( pr^.PTCrec.timestamp) +' pr.U=' + FloatToStr(pr^.U));
      end;      

  mh.Destroy;
end;

procedure TFormDebug.BuTestChartClick(Sender: TObject);
begin
  //if  testchart=nil then begin ShowMessage('nil - create'); testchart := TMyChartModule.Create; end;
  //testchart.AssignPanel( TestPanel );
  //testchart.Init;
end;

procedure TFormDebug.Button4Click(Sender: TObject);
begin
  ShowMessage( FloatToStr( MyStrToFloatDef( Edit2.Text, -1 ) ) );
end;

procedure TFormDebug.Button5Click(Sender: TObject);
Var
 s: string;
 d: double;
begin
  s := '56.123456';
  Memo1.Lines.Add( s );
  d := MyStrToFloatDef(s, -1);
  Memo1.Lines.Add( FloatToStr( d ) );
  Memo1.Lines.Add( '---' );
  s := '56,123456';
  Memo1.Lines.Add( s );
  d := MyStrToFloatDef(s, -1);
  Memo1.Lines.Add( FloatToStr( d ) );
  Memo1.Lines.Add( '---' );
end;

procedure TFormDebug.Button6Click(Sender: TObject);
begin
  raise Exception.Create('Test');
end;

end.

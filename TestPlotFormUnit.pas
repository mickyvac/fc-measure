unit TestPlotFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, CheckLst, Buttons,
  myutils, MyStreamReader;

type


TMVDataFileType = (CFTNotDetermined, CFTNotValid, CFTLinBatchV1);



TMyFileTreeNode =  class(TTreeNode)
  public
    constructor Create( filename: string);
    destructor Destroy; override;
  public
    function GetFileType(): TMVDataFileType;
    procedure GetHeader(Var sl: TStringList);
    //procedure GetData(Var data: TSmartDataStorage);
  private
    Fname: string;
    Ftype: TMVDataFileType;
    FTxtStream: TMyTextStream;
    FheaderPos: Int64;
    FDataPos: Int64;
    FFooterPos: Int64;
end;



TDataFileTreeManager = class(TObject)
  public
    constructor Create();
    destructor Destroy; override;
  public
    procedure AddDirectory( dname: string);
    procedure CloneToTreeView(Var tt: TTreeView);
  private
    Ftree: TTreeView;
end;


TProjectFileViewer = class(TObject)
   public
    iPanChart: TPanel;
    iTree: TTreeView;
    iFileSelChkList: TCheckListBox;

    iBuOpenProj: TButton;
    iBuOpenFold: TButton;
    iBuOpenFile: TButton;
    iCBChartType: TComboBox;
    iBuUserConf: TButton;

    iComboBox1: TComboBox;
    iButton3: TButton;
    Button4: TButton;
    Panel2: TPanel;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    Button5: TButton;
    Panel3: TPanel;
    CheckListBox2: TCheckListBox;
    Button2: TButton;
    Button6: TButton;
    Button7: TButton;
  private
    FDrawPan: TPanel;
end;



  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    ComboBox1: TComboBox;
    Panel2: TPanel;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    Button5: TButton;
    Panel3: TPanel;
    PageCtrlSelect: TPageControl;
    TabSheet1: TTabSheet;
    PSelection: TTabSheet;
    TabActive: TTabSheet;
    TreeView1: TTreeView;
    CheckListBox2: TCheckListBox;
    Button6: TButton;
    Button2: TButton;
    Button7: TButton;
    Button3: TButton;
    Button4: TButton;
    TreeView2: TTreeView;
    Button8: TButton;
    Button9: TButton;
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button9Click(Sender: TObject);
begin
  Panel1.Visible := False;
end;





constructor TMyFileTreeNode.Create( filename: string);
begin
  inherited Create(nil);
  Fname := filename;
  Ftype := CFTNotDetermined;
  FTxtStream := TMyTextStream.Create( Fname );
  FheaderPos := -1;
  FDataPos := -1;
  FFooterPos := -1;
end;

destructor TMyFileTreeNode.Destroy;
begin
  MyDestroyAndNil( FTxtStream );
  inherited;
end;


function TMyFileTreeNode.GetFileType(): TMVDataFileType;
Var
 s: string;
 b: boolean;
begin
  if Ftype = CFTNotDetermined then
    begin
      FTxtStream.ResetStreamPos;
      b := FTxtStream.ReadLnLimit(s, 200);
      if b then FheaderPos := FTxtStream.StreamPos;
      if s = 'LinearBatch Acquisition File]' then FType := CFTLinBatchV1
      else FType := CFTNotValid;
    end
  else Result := Ftype;
end;


procedure TMyFileTreeNode.GetHeader(Var sl: TStringList);
Var
  //f: text;
  nextl, s, s1: string;
  i, n1, n2, il: longint;
  b: boolean;
Const
  CSdata = '[DataHeader]';
begin
  //sl.Clear;
  if GetFileType() = CFTNotValid then exit;
  if FheaderPos<0 then exit;
  FTxtStream.StreamPos := FheaderPos;
  while true do
    begin
      b := FTxtStream.ReadLn ( nextl );
      if not b then exit; //EOF
      if nextl<>CSdata then
        begin
          sl.Add( nextl);
        end
      else
        begin
          FDataPos := FTxtStream.StreamPos;
          break;
        end;
    end;
end;


//procedure GetData(Var data: TSmartDataStorage);
{



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
}

constructor TDataFileTreeManager.Create();
begin
  inherited Create;
  Ftree := TTreeView.Create(nil);
end;

destructor TDataFileTreeManager.Destroy;
begin
  MyDestroyAndNil( FTree );
  inherited;
end;



procedure TDataFileTreeManager.AddDirectory( dname: string);
begin

end;



procedure TDataFileTreeManager.CloneToTreeView(Var tt: TTreeView);
//private
//  Ftree: TTreeView;
begin
end;


















end.

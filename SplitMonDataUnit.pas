unit SplitMonDataUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  myUtils, MyParseUtils;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Edit3: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    begin
      Edit1.Text := OpenDialog1.FileName;
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    if SaveDialog1.Execute then
    begin
      Edit2.Text := SaveDialog1.FileName;
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
Var
 fin: TextFile;
 fout: TextFile;
 line, sout, seps: string;
 slist: TStringList;
 n, i, cc: longint;
 res:boolean;
 tl: ttokenlist;
begin

  slist := TStringList.Create;

  AssignFile(fin, Edit1.Text);
  reset(fin);

  if FileExists( Edit2.Text )  then
   begin
     ShowMessage('File Exist, Are you sure?');
     //if not ShowModal('File Exist, Are you sure?') then exit;
   end;
  AssignFile(fout, Edit2.Text);
  rewrite(fout);

  seps := Edit3.Text;



  n:=0;
  while True do
  begin
    Readln(fin, line);
    res := ParseStrSep(line, seps ,tl);
    if res then
      begin
        sout := '';
        for i:=0 to Length(tl)-1 do
          begin
            sout := sout + tl[i].s;
            if i<(Length(tl)-1) then  sout := sout + #9;
          end;
        Writeln(fout, sout);
      end
    else
      begin
        Writeln(fout, line);
      end;

    //Memo1.Lines.AddStrings( slist );
    if (n mod 10000) = 0 then
      begin
        Memo1.Lines.Add( 'progress: '  + INtToStr(n) );
        Application.ProcessMessages;
      end;
    Inc(n);
    if (CheckBox1.Checked) and (n>=10) then break;
    if Eof(fin) then break;
  end;
  Memo1.Lines.Add( 'Rows Processed ' + IntToStr(n) );

  slist.Destroy;
  closefile(fin);
  closefile(fout);
end;

end.

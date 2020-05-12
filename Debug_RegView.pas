unit Debug_RegView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FormGlobalConfig,
  MyEditInterfaceHelper, ComCtrls, HWAbstractDevicesV3;

type
  TFormRegView = class(TForm)
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Button1: TButton;
    Edit2: TEdit;
    Edit3: TEdit;
    Button2: TButton;
    Button3: TButton;
    Edit4: TEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    HW: TTabSheet;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Refresh;
  end;

var
  FormRegView: TFormRegView;

implementation

{$R *.dfm}

procedure TFormRegView.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  Refresh;
  Timer1.Enabled := CheckBox1.Checked;
end;

procedure TFormRegView.CheckBox1Click(Sender: TObject);
begin
  Timer1.Enabled := CheckBox1.Checked;
end;

procedure TFormRegView.Refresh;
Var sl: TStringList;
begin
   sl := TStringList.Create;
   RegistryHW.DumpIntoStringList( sl );
   Memo1.Lines.Clear;
   Memo1.Lines.AddStrings( sl );
   sl.Clear;
   CommonDataRegistry.DumpAsStrignList( sl );
   Memo2.Lines.Clear;
   Memo2.Lines.AddStrings( sl );
   sl.Destroy;
end;

procedure TFormRegView.FormHide(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TFormRegView.FormShow(Sender: TObject);
begin
  Timer1.Enabled := CheckBox1.Checked;
end;

procedure TFormRegView.Button1Click(Sender: TObject);
begin
  InterfaceHelper.AssignControl( Edit1, RegistryHW.GetOrCreateSection('test'), Edit2.Text, 'default', 'THis is a hint!' );
end;

procedure TFormRegView.Button2Click(Sender: TObject);
begin
  RegistryHW.GetOrCreateSection('test').valStr[ Edit2.Text ] := Edit3.Text;
end;

end.

unit debug;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls{, HWInterfaceMeasure};

type
  TForm3 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    Button5: TButton;
    Label21: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button3: TButton;
    Button4: TButton;
    Memo2: TMemo;
    Button7: TButton;
    Label5: TLabel;
    Button1: TButton;
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

//uses pcibase;

{$R *.dfm}

procedure TForm3.Button5Click(Sender: TObject);
begin
  //vypise co nejvice o karte BMC PCI-Base1000
  Memo1.Lines.Clear;
  Memo1.Lines.Add( 'Intermediate layer: karta usbbase ted neni!!!!!!!!!!!!');
  
{  Memo1.Lines.Add( 'Intermediate layer: ' + Form2.PCIBaseEnv.Info );
  Memo1.Lines.Add( '--------' );
  Memo1.Lines.Add( 'Installed Cards: ' + IntToStr( Form2.PCIBaseEnv.InstalledCards ) );
  Memo1.Lines.Add( 'Module Count: ' + IntToStr( Form2.PCIBaseEnv.ModuleCount ) );
  Memo1.Lines.Add( '# of AD channels: ' + IntToStr( Form2.PCIBaseEnv.AnalogInCount ) );
  Memo1.Lines.Add( '# of DA channel: ' + IntToStr( Form2.PCIBaseEnv.AnalogOutCount ) );
  Memo1.Lines.Add( '# of DIGITAL ports: ' + IntToStr( Form2.PCIBaseEnv.PortCount ) );
  Memo1.Lines.Add( 'Base ID: ' + IntToStr( Form2.PCIBaseEnv.Baseid ) );
  Memo1.Lines.Add( 'Card ID: ' + IntToStr( Form2.PCIBaseEnv.CardId ) );}
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  Form3.Hide;
end;

procedure TForm3.Button7Click(Sender: TObject);
begin
  Memo2.Lines.Clear;
end;

end.

unit SetData_Help;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSetData_Help = class(TForm)
    Label1: TLabel;
    Memo1: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    Memo2: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetData_Hlp: TSetData_Help;

implementation

uses SetData;

{$R *.dfm}

procedure TSetData_Help.FormCreate(Sender: TObject);
begin
  SetData_Hlp.Visible := False;
  SetData_Hlp.Caption := ProgName + ' - Abaut';
end;

end.
 
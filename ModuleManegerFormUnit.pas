unit ModuleManegerFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TModuleManagerForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    procedure getLockState;
    procedure requestlock;
    { Public declarations }
  end;

var
  ModuleManagerForm: TModuleManagerForm;

implementation

{$R *.dfm}


procedure TModuleManagerForm.getLockState;
begin
 //TODO:
end;

procedure TModuleManagerForm.requestlock;
begin
 //TODO:
end;

end.

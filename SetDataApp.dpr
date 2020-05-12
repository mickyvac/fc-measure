program SetDataApp;

uses
  Forms,
  SetData in 'SetData.pas' {Form1},
  SetData_Help in 'SetData_Help.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSetDataForm, SetDataForm);
  Application.CreateForm(TSetData_Help, SetData_Hlp);
  Application.Run;
end.

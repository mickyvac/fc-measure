program M9711tester;

uses
  Forms,
  M9711test_main in 'M9711test_main.pas' {Form1},
  CPort in 'cport\CPort.pas',
  CPortAbout in 'cport\CPortAbout.pas' {AboutBox},
  CPortCtl in 'cport\CPortCtl.pas',
  CPortEsc in 'cport\CPortEsc.pas',
  CPortTrmSet in 'cport\CPortTrmSet.pas' {ComTrmSetForm},
  CPortSetup in 'cport\CPortSetup.pas',
  M97XX_interface in 'M97XX_interface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

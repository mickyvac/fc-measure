unit calibration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, measure, StdCtrls, Grids;

type
  TForm5 = class(TForm)
    StringGrid1: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Label5: TLabel;
    Button4: TButton;
    Button5: TButton;
    Edit5: TEdit;
    Edit6: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Edit11: TEdit;
    Button6: TButton;
    Label10: TLabel;
    Label11: TLabel;
    Edit12: TEdit;
    Memo1: TMemo;
    Edit13: TEdit;
    Label12: TLabel;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Edit14: TEdit;
    Button7: TButton;
    Label13: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
    changedV: Array [TVoltageRange] of boolean;
    changedC: Array [TCurrentRange] of boolean;
    avr: TVoltageRange;
    acr: TCurrentRange;
    finished : boolean;
    newinf: real;
    newinoffs: real;
    newspf: real;
    newspoffs: real;
    confvoltage: boolean;
    confcurrent: boolean;
    confvr: TVoltageRange;
    confcr: TCurrentRange;
    step : byte;
    userV1: real;
    userC1: real;
    {userV2: real;
    userC2: real;
    userV3: real;
    userC3: real;}
  public
    { Public declarations }
    procedure Refresh;
    procedure Reset;
    procedure VoltSt2;
    procedure CurrSt2;
    procedure Save;
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.Button1Click(Sender: TObject);
begin
  Refresh;
end;


procedure TForm5.Reset;
begin   //TStringGrid    Cells[col][row]
  changedV[Vr10V] := false;
  changedV[Vr2V] := false;
  changedV[Vr1V] := false;
  changedC[Cr2A] := false;
  changedC[Cr200mA] := false;
  changedC[Cr20mA] := false;
  changedC[Cr2mA] := false;
  finished := false;
  newinf := 0;
  newinoffs := 0;
  newspf := 0;
  newspoffs :=0;
  Memo1.Clear;
  Label7.Caption := '';
  Button6.Enabled := false;
  //userV1 := 0;
  //userC1 := 0;
end;

procedure TForm5.Refresh;
Var
  cr: TCurrentRange;
  vr: TVoltageRange;
  r: byte;
  inf, inoffs, spf, spoffs: real;
  b: boolean;
  a: AnsiString;
begin   //TStringGrid    Cells[col][row]
  finished := false;
  with StringGrid1 do
  begin
    Cells[1,0] := 'Range';
    Cells[1,0] := 'Input Factor';
    Cells[2,0] := 'Input Offset';
    Cells[3,0] := 'Output Factor';
    Cells[4,0] := 'Output Offset';
    Cells[5,0] := 'Changed';

    Cells[0,1] := 'Voltage 10V';
    Cells[0,2] := 'Voltage 2V';
    Cells[0,3] := 'Voltage 1V';
    Cells[0,4] := 'Current 2000mA';
    Cells[0,5] := 'Current 200mA';
    Cells[0,6] := 'Current 20mA';
    Cells[0,7] := 'Current 2mA';
    for r:=1 to 7 do
    begin
      inf := -9999;
      inoffs := -9999;
      spf := -9999;
      spoffs := -9999;
      case r of
        1: vr := Vr10V;
        2: vr := Vr2V;
        3: vr := Vr1V;
      end;
      case r of
        4: cr := Cr2A;
        5: cr := Cr200mA;
        6: cr := Cr20mA;
        7: cr := Cr2mA;
      end;
      if (r in [1..3]) then
      begin
        ReadVoltRange(vr, inf, inoffs, spf, spoffs);
        b := ChangedV[ vr ];
        a := VoltageRangeToStr( vr);
      end;
      if (r in [4..7]) then
      begin
        ReadCurrRange(cr, inf, inoffs, spf, spoffs);
        b := ChangedC[ cr ];
        a := CurrentRangeToStr( cr );
      end;
      Cells[0,r] := a;
      Cells[1,r] := FloatToStr( inf );
      Cells[2,r] := FloatToStr( inoffs );
      Cells[3,r] := FloatToStr( spf );
      Cells[4,r] := FloatToStr( spoffs );
      if b then  Cells[5,r] := 'Yes' else Cells[5,r] := '--'
    end; //for
  end;  //stringgrid
  Aquire;
  Avr := Mon.VoltageRange;
  Acr := Mon.CurrentRange;
  Edit5.Text := VoltageRangeToStr( Avr );
  Edit6.Text := CurrentRangeToStr( Acr );
end;


procedure TForm5.Button3Click(Sender: TObject);
begin
  if not finished then
  begin
    ShowMessage ('Calibration not finished');
    exit;
  end;
  Save;
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
  Visible := false;
end;

procedure TForm5.Button4Click(Sender: TObject);
Var
  a,b,c,d: real;
  vm, vu: real;
begin  //volt conf
   Memo1.Lines.Add('Out of order' );
{  Memo1.Lines.Add('Doing Voltage calibration of range: ' +  VoltageRangeToStr( Avr ) );
  finished := false;
  confvoltage := true;
  confcurrent := false;
  confvr := Avr;
  ReadVoltRange(confvr, a, b, c, d);
  Edit1.Text := FloatToStr( a );
  Edit2.Text := FloatToStr( b );
  Edit3.Text := FloatToStr( c );
  Edit4.Text := FloatToStr( d );
  Edit7.Text := '';
  Edit8.Text := '';
  Edit9.Text := '';
  Edit10.Text := '';
  //begin
  SetRelayStatus( RsNone );
  Label7.Caption := 'Wait for instructions...';
  ShowMessage('Step 0: DISCONNECT any load from output');
  step := 0;
  Edit13.Text := IntToStr( step );
  SetRelayStatus( RsVoltCurr );
  SetFeedbackVoltage(0);
  ShowMessage('Step 1: Connect together "U+", "U-" (and not anywhere else)!!!, then press OK. (will do input offset calib)');
  //offset
  step := 1;
  Edit13.Text := IntToStr( step );
  vm := ReadVoltageRaw;
  vu := 0;
  Edit12.Text := FloatToStr(vm);
  Edit11.Text := FloatToStr(vu);
  Memo1.Lines.Add('Input voltage offset: measured "' +  FloatToStr(vm) + '" should be 0.000 V');
  newinoffs := vm;    //Result := CurrentFactor * (prumer - CurrentOffset);
  Edit8.Text := FloatToStr(newinoffs);
  //prepare for factor
  step := 2;
  Edit13.Text := IntToStr( step );
  ShowMessage('Step 2: Connect "U+" to "I+", "U-" to "I-" and a Voltmetter between "U+" and "U-". (Then use multimetr to measure ACTUAL voltage)');
  Label7.Caption := 'Setting output to cca 80%... The ouput should be stable. Enter value measured by VOLTMETTER in VOLTS into Edit box below, then hit the NEXT button';
  SetFeedbackVoltage(0);
  SetpointSetRaw(8);
  SetRelayStatus( RsVoltCurr );
  Edit11.Text := FloatToStr( userv1 );
  Edit12.Text := '';
  Button6.Enabled := true;}
end;

procedure TForm5.Button5Click(Sender: TObject);
Var
  a,b,c,d: real;
  vm, vu: real;
begin  //current
  Memo1.Lines.Add('calibration is off');
  {Memo1.Lines.Add('Doing Current calibration of range: ' +  CurrentRangeToStr( Acr ) );
  finished := false;
  confvoltage := false;
  confcurrent := true;
  confcr := Acr;
  ReadCurrRange(confcr, a, b, c, d);
  Edit1.Text := FloatToStr( a );
  Edit2.Text := FloatToStr( b );
  Edit3.Text := FloatToStr( c );
  Edit4.Text := FloatToStr( d );
  Edit7.Text := '';
  Edit8.Text := '';
  Edit9.Text := '';
  Edit10.Text := '';
  //begin
  SetRelayStatus( RsNone );
  Label7.Caption := 'Wait for instructions...';
  ShowMessage('Step 0: DISCONNECT any load from output');
  step := 0;
  Edit13.Text := IntToStr( step );
  SetRelayStatus( RsVoltCurr );
  SetFeedbackCurrent(0);
  ShowMessage('Step 1: Leave "I+" and "I-" DISCONNECTED, then press OK. (will do input offset calib)');
  //offset
  step := 1;
  Edit13.Text := IntToStr( step );
  vm := ReadCurrentRaw;
  vu := 0;
  Edit12.Text := FloatToStr(vm);
  Edit11.Text := FloatToStr(vu);
  Memo1.Lines.Add('Input current offset: measured "' +  FloatToStr(vm) + '" should be 0.000 V');
  newinoffs := vm;    //Result := CurrentFactor * (prumer - CurrentOffset);
  Edit8.Text := FloatToStr(newinoffs);
  //prepare for factor
  step := 2;
  Edit13.Text := IntToStr( step );
  ShowMessage('Step 2: Connect an Ampermetter (apropriate range) between "I+" and "TestR" (the resistor is connceted from TestR to I-). Then use the device to measure ACTUAL current');
  Label7.Caption := '(You can alternatively use your own resistor). Setting output to cca 80%... The ouput should be stable. Enter value measured by Ampermetter in AMPERES into Edit box below, then hit the NEXT button';
  SetRelayStatus( RsVoltCurr );
  SetFeedbackCurrent(0);
  SetpointSetRaw(6);
  Edit11.Text := FloatToStr( userc1 );
  Edit12.Text := '';
  Button6.Enabled := true;}
end;

procedure TForm5.Button6Click(Sender: TObject);
Var
  e: boolean;
begin
  e := false;
  if confvoltage then
  begin
    if (step=2) then VoltSt2
    else e:=true;
  end
  else if confcurrent then
  begin
    if (step=2) then CurrSt2
    else e:=true;
  end
  else e:= true;
  if e then ShowMessage ('There was some Error');
end;

procedure TForm5.VoltSt2;
Var
  vm, vu, x: real;
begin  //volt conf
  userv1 := StrToFloatDef( Edit11.Text, 0);
  vm := ReadVoltageRaw - newinoffs;  //offset correcetd
  Edit12.Text := FloatToStr(vm);
  Memo1.Lines.Add('Input voltage factor: measured "' +  FloatToStr(vm) + '" , should be "' + FloatToStr( userV1 ) + '"');
  if (vm=0) then begin vm := 1; ShowMessage('Error'); end;
  newinf := UserV1 / vm;    //Result := CurrentFactor * (prumer - CurrentOffset);
  Edit7.Text := FloatToStr(newinf);
  //now do setpoint offset
  Label7.Caption := 'Wait for instructions...';
  step := 3;
  Edit13.Text := IntToStr( step );
  SetpointSetRaw(0);
  ShowMessage('Will do setpoint offset now - setting 0V output. Keep the wires connected. Press OK');
  vm := (ReadVoltageRaw - newinoffs);  //partially corrected !!!!!!  vm := newinf * (ReadVoltageRaw - newinoffs);
  vu := 0;
  Edit12.Text := FloatToStr(vm);
  Edit11.Text := FloatToStr(vu);
  Memo1.Lines.Add('Setpoint offset: measured "' +  FloatToStr(vm) + '" should be 0.000 V');
  newspoffs := - vm ;    //newval :=  val * SetPointFactor + SetPointOffset;
  Edit10.Text := FloatToStr(newspoffs);
  //prepare for factor
  step := 4;
  Edit13.Text := IntToStr( step );
  x := 8;
  SetpointSetRaw( x + newspoffs );  //newval :=  val * SetPointFactor + SetPointOffset;
  ShowMessage('Will do setpoint factor now - setting 80% output. Keep the wires connected. Press OK');
  vm := x;
  vu := newinf * (ReadVoltageRaw - newinoffs);  //completelz correcetd
  Edit12.Text := FloatToStr(vm);
  Edit11.Text := FloatToStr(vu);
  Memo1.Lines.Add('Setpoint factor: vaalue set "' +  FloatToStr(vm) + '" , should be "' + FloatToStr( vu ) + '"');
  if (vu=0) then ShowMessage('Error');
  if (vu<>0) then newspf := vm / vu    //newval :=  val * SetPointFactor + SetPointOffset;
  else newspf := 0;
  Edit9.Text := FloatToStr(newspf);
  //now do finish
  Button6.Enabled := false;
  finished := true;
  SetRelayStatus( RsVolt );
  SetFeedbackCurrent(0);
  Label7.Caption := 'You may now disconect the wires. You can now change range and do the calibration for it. Do not forget to save the values first. It would be wise to check if the NEW settings are working correctly.';
  ShowMessage('Finished. Now accept and save the new values using the button');
end;

procedure TForm5.CurrSt2;
Var
  vm, vu, x: real;
begin  //volt conf
  userc1 := StrToFloatDef( Edit11.Text, 0);
  vm := ReadCurrentRaw - newinoffs;  //offset correcetd
  Edit12.Text := FloatToStr(vm);
  Memo1.Lines.Add('Input current factor: measured "' +  FloatToStr(vm) + '" , should be "' + FloatToStr( userC1 ) + '"');
  if (vm=0) then begin vm := 1; ShowMessage('Error'); end;
  newinf := UserC1 / vm;    //Result := CurrentFactor * (prumer - CurrentOffset);
  Edit7.Text := FloatToStr(newinf);
  //now do setpoint offset
  Label7.Caption := 'Wait for instructions...';
  step := 3;
  Edit13.Text := IntToStr( step );
  SetpointSetRaw(0);
  ShowMessage('Will do setpoint offset now - setting 0 mA output. Keep the wires connected. Press OK');
  vm := ReadCurrentRaw - newinoffs;  //partially corrected !!!!!! corrected only for offset
  vu := 0;
  Edit12.Text := FloatToStr(vm);
  Edit11.Text := FloatToStr(vu);
  Memo1.Lines.Add('Setpoint offset: measured "' +  FloatToStr(vm) + '" should be 0.000 V');
  newspoffs := - vm;    //newval :=  val * SetPointFactor + SetPointOffset;
  Edit10.Text := FloatToStr(newspoffs);
  //prepare for factor
  step := 4;
  Edit13.Text := IntToStr( step );
  x := 8;
  SetpointSetRaw( x + newspoffs );  //newval :=  val * SetPointFactor + SetPointOffset;
  ShowMessage('Will do setpoint factor now - setting 80% output. Keep the wires connected. Press OK');
  vm := x;
  vu := newinf * (ReadCurrentRaw - newinoffs);  //completelz correcetd
  Edit12.Text := FloatToStr(vm);
  Edit11.Text := FloatToStr(vu);
  Memo1.Lines.Add('Setpoint factor: vaalue set "' +  FloatToStr(vm) + '" , should be "' + FloatToStr( vu ) + '"');
  if (vu=0) then ShowMessage('Error');
  if (vu<>0) then newspf := vm / vu    //newval :=  val * SetPointFactor + SetPointOffset;
  else newspf := 0;
  Edit9.Text := FloatToStr(newspf);
  //now do finish
  Button6.Enabled := false;
  finished := true;
  SetRelayStatus( RsVolt );
  SetFeedbackCurrent(0);
  Label7.Caption := 'You may now disconect the wires. You can now change range and do the calibration for it. Do not forget to save the values first. It would be wise to check if the NEW settings are working correctly.';
  ShowMessage('Finished. Now accept and save the new values using the button');
end;

procedure TForm5.Save;
begin
  if (confvoltage) then
  begin
    ConfigVoltRange( confvr, newinf, newinoffs, newspf, newspoffs);
    changedV[ confvr ] := true;
  end;
  if (confcurrent) then
  begin
    ConfigCurrRange( confcr, newinf, newinoffs, newspf, newspoffs);
    changedC[ confcr ] := true;
  end;
  confvoltage := false;
  confcurrent := false;
  SaveCoefficients;
  Refresh;
end;


procedure TForm5.Button8Click(Sender: TObject);
Var lastv, lastc: boolean;
begin
  lastv :=  confvoltage;
  lastc := confcurrent;
  newinf := StrToFloatDef( Edit7.Text, 0);
  newinoffs := StrToFloatDef( Edit8.Text, 0);
  newspf := StrToFloatDef( Edit9.Text, 0);
  newspoffs := StrToFloatDef( Edit10.Text, 0);
  Save;
  if (lastv)  then Button10Click(Sender);
  if (lastc)  then Button9Click(Sender);
end;

procedure TForm5.Button10Click(Sender: TObject);
Var
  a,b,c,d: real;
begin
  Memo1.Lines.Add('Prepare USER Voltage calibration of range: ' +  VoltageRangeToStr( Avr ) );
  finished := false;
  confvoltage := true;
  confcurrent := false;
  confvr := Avr;
  ReadVoltRange(confvr, a, b, c, d);
  Edit1.Text := FloatToStr( a );
  Edit2.Text := FloatToStr( b );
  Edit3.Text := FloatToStr( c );
  Edit4.Text := FloatToStr( d );
  Edit7.Text := FloatToStr( a );
  Edit8.Text := FloatToStr( b );
  Edit9.Text := FloatToStr( c );
  Edit10.Text := FloatToStr( d );
  Label7.Caption := 'Edit the values and hit the the USER save button...';
end;

procedure TForm5.Button9Click(Sender: TObject);
Var
  a,b,c,d: real;
begin
  Memo1.Lines.Add('Prepare USER Current calibration of range: ' +  CurrentRangeToStr( Acr ) );
  finished := false;
  confvoltage := false;
  confcurrent := true;
  confcr := Acr;
  ReadCurrRange(confcr, a, b, c, d);
  Edit1.Text := FloatToStr( a );
  Edit2.Text := FloatToStr( b );
  Edit3.Text := FloatToStr( c );
  Edit4.Text := FloatToStr( d );
  Edit7.Text := FloatToStr( a );
  Edit8.Text := FloatToStr( b );
  Edit9.Text := FloatToStr( c );
  Edit10.Text := FloatToStr( d );
  Label7.Caption := 'Edit the values and hit the the USER save button...';
end;

procedure TForm5.Button7Click(Sender: TObject);
Var v: real;
begin
  v := StrToFloatDef( Edit14.Text, 0);
  if (confvoltage) then SetFeedbackVoltage(v);
  if (confcurrent) then SetFeedbackCurrent(v);
  SetRelayStatus( RsVoltCurr );
end;

end.

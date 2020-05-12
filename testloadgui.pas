unit testloadgui;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    //Reader   : TReader;
    debugsl : TStringlist;
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}


procedure SetComponentStyles(AForm:TForm);
var
  AComponent : TComponent;
  i          : Integer;
  B1, B2     : Boolean;

begin
//  for i := 0 to AForm.ComponentCount-1 do begin
//    AComponent := AForm.Components[i];
//    if AComponent is TTimer then begin
//      // TTIMER:
//      B1 := csDesigning in AComponent.ComponentState;
//
//      // Does not work: an attempt to make the TTimer visible like it is in Delphi IDE's form designer.
//      TCrackedTComponent(AComponent).UpdateState_Designing;
//
//      B2 := csDesigning in AComponent.ComponentState;
//      ReportBoolean('Before setting it: ', B1);
//      ReportBoolean('After  setting it: ', B2);
//    end;
//  end;
end;


procedure RegisterNecessaryClasses;
begin
  RegisterClass(TPanel);
  RegisterClass(TMemo);
  RegisterClass(TTimer);
  RegisterClass(TListBox);
  RegisterClass(TSplitter);
  RegisterClass(TEdit);
  RegisterClass(TCheckBox);
  RegisterClass(TButton);
  RegisterClass(TLabel);
  RegisterClass(TRadioGroup);
end;


procedure TForm4.Button1Click(Sender: TObject);
Var
  S1       : TFileStream;
  S1m      : TMemoryStream;
  S2       : TMemoryStream;
  S        : String;
  k1, k2   : Integer;
  Reader   : TReader;
  SLHelper: TStringlist;
  OK       : Boolean;
  Filename: string;

  MissingClassName, FormName, FormTypeName : String;
  Component: TComponent;
  twc: TControl;


begin
// https://stackoverflow.com/questions/19989389/can-we-load-a-dfm-file-for-a-form-at-runtime


Filename := 'testdfm.txt';
S1 := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
  try
    S1m := TMemoryStream.Create;
    try
      SLHelper := TStringlist.Create;
      try
        SLHelper.LoadFromStream(S1);
//
//        S := SLHelper[0];
//
//        k1 := pos(' ', S);
//        k2 := pos(': ', S);
//        if (k1 <> 0) AND (k2 > k1) then begin
//          // match:
//          SetLength(S, k2+1);
//          S := 'object ' + FormName + ': ' + FormTypeName;
//          SLHelper[0] := S;
//        end;

        //RemoveEventHandlers(SLHelper);
        SLHelper.SaveToStream(S1m);
      finally
        SLHelper.Free;
      end;

      S1m.Position := 0;
      S2 := TMemoryStream.Create;
      try
              RegisterNecessaryClasses;

        while S1m.Position < S1m.Size do
         begin
              S2.Clear;
              ObjectTextToBinary(S1m, S2);
              S2.Position := 0;


              //Reader := TReader.Create(S2, 4096);
              try
                try
                  //FormDyna := Form4;
                  //Reader.ReadRootComponent(Form4);
                  //Reader.ReadComponent(component);


                      component := nil;
                      component := S2.ReadComponent(nil);
                      //Form4.InsertComponent(component);
                      //component.owner := Form4;
                      //InsertComponent
                      //component.

                      twc := nil;
                      if component is TControl then twc := TControl(component);
                      if twc<>nil then twc.Parent := Form4;

                      //Tlabel

                  OK       := True;
                  //SetComponentStyles(FormDyna);
                except
                  on E:Exception do begin
                    S := E.ClassName + '    ' + E.Message;
                    if Assigned(DebugSL) then begin
                      DebugSL.add(S);
                      if (E.ClassName = 'EClassNotFound') then begin
                        // the class is missing - we need one more "RegisterClass" line in the RegisterNecessaryClasses procedure.
                        MissingClassName := E.Message + ' not found';
                        S := '    RegisterClass(' + MissingClassName + ');';
                        DebugSL.Add(S);
                      end;
                    end;
                  end;
                end;
              finally
                //Reader.Free;
              end;
         end; //while
      finally
        S2.Free;
      end;

    finally
      S1m.Free;
    end;
  finally
    S1.Free;
  end;

  //Application.InsertComponent
end;

procedure TForm4.Button2Click(Sender: TObject);
Var
  S1       : TFileStream;
  S1m      : TMemoryStream;
  S2       : TMemoryStream;
  S        : String;
  k1, k2   : Integer;
  Reader   : TReader;
  SLHelper: TStringlist;
  OK       : Boolean;
  Filename: string;

  MissingClassName, FormName, FormTypeName : String;
  Component: TComponent;
  twc: TControl;


begin
  // https://stackoverflow.com/questions/19989389/can-we-load-a-dfm-file-for-a-form-at-runtime
  Filename := 'testdfm.txt';
  RegisterNecessaryClasses;
  S1 := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
  S1m := TMemoryStream.Create;
  try
      SLHelper := TStringlist.Create;
      try
        SLHelper.LoadFromStream(S1);
//
//        S := SLHelper[0];
//
//        k1 := pos(' ', S);
//        k2 := pos(': ', S);
//        if (k1 <> 0) AND (k2 > k1) then begin
//          // match:
//          SetLength(S, k2+1);
//          S := 'object ' + FormName + ': ' + FormTypeName;
//          SLHelper[0] := S;
//        end;
        //RemoveEventHandlers(SLHelper);
        SLHelper.SaveToStream(S1m);
      finally
        SLHelper.Free;
      end;
      // now process
      S1m.Position := 0;
      S2 := TMemoryStream.Create;
      try
        while S1m.Position < S1m.Size do
            begin
              S2.Clear;
              ObjectTextToBinary(S1m, S2);
              S2.Position := 0;
              try
                try
                      component := S2.ReadComponent(nil);
                      twc := nil;
                      if component is TControl then twc := TControl(component);
                      if twc<>nil then twc.Parent := Form4;
                      OK := True;
                except
                  on E:Exception do begin
                    S := E.ClassName + '    ' + E.Message;
                    if Assigned(DebugSL) then begin
                      DebugSL.add(S);
                      if (E.ClassName = 'EClassNotFound') then begin
                        // the class is missing - we need one more "RegisterClass" line in the RegisterNecessaryClasses procedure.
                        MissingClassName := E.Message + ' not found';
                        S := '    RegisterClass(' + MissingClassName + ');';
                        DebugSL.Add(S);
                      end;
                    end;
                  end;
                end;
              finally
                //Reader.Free;
              end;
         end; //while
      finally
        S2.Free;
      end;
  finally
    S1.Free;
    S1m.Free;
  end;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  //Reader:= TReader.Create;
  debugsl := TStringlist.Create;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  //Reader.Free;
  debugsl.Free;
end;

end.

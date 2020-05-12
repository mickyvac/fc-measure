unit TestRegistryMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  ConfigManager, MVConversion, MVvariant_DataObjects, myutils;

type

TXThread = class (TThread)
    public
      constructor Create(n:string);
      destructor Destroy; override;
      procedure Execute; override;  //EExecute is defined here-> !!! Descendat must use EXECUTEINNERLOOP
    public
      procedure SetUserSuspend;
      procedure ResetUserSuspend;
    private
      fn: string;
      fUserSuspendReq: boolean;  //user supension is check in side the CheckAndProcessRequests;
end;









  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    Timer1: TTimer;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    Registry: TMyRegistryRootObject;
    fThread: TXThread;
    fT2: TXThread;
    fT3: TXThread;
    fT4: TXThread;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
   Timer1.Enabled := CheckBox1.Checked;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Registry := TMyRegistryRootObject.Create();
  fThread := TXThread.Create('T1');
  fT2 := TXThread.Create('T2');
  fT3 := TXThread.Create('T3');
  fT4 := TXThread.Create('T4');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fThread.Destroy;
  fT2.Destroy;
  fT3.Destroy;
  fT4.Destroy;
  Registry.Destroy;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
Var
 sl: TStringlist;
begin
  sl := TStringlist.Create;
  Registry.DumpIntoStringList( sl );
  Memo1.Lines.BeginUpdate;
    Memo1.Lines.Clear;
    Memo1.Lines.AddStrings( sl );
  Memo1.Lines.EndUpdate;
  sl.Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  fThread.ResetUserSuspend;
end;
procedure TForm1.Button2Click(Sender: TObject);
begin
  fThread.SetUserSuspend;
end;



constructor TXThread.Create(n:string);
begin
  inherited Create(true); //createsuspended=true
  fn := n + '';
  FreeOnTerminate := false;
  fUserSuspendReq := false;
end;

destructor TXThread.Destroy;    //tthread
begin
  //damn !!! this is run from context of main thread - must wait here for thred to terminate - I observed, that the execute was still running
  //even after log was destroyed apparently!!!
  Terminate;
  if not suspended then WaitFor;
  if FatalException<>nil then ShowMessage('THREad - Fatal exception ' + FatalException.ClassName );
  inherited;
end;


procedure TXThread.Execute;
Const
  CS= 'Section1';
Var
  t0, dtMS: longword;
  i, j, k: longint;
  s, ni, ns, nf: string;
  rn: TMyRegistryNodeObject;
  cnt, ncyc: longint;
  ii: longint;
begin
  rn := Form1.Registry.GetOrCreateSection( CS );
  cnt := 0;
  ncyc := 0;
  while not Terminated do
    begin
	    //
      while fUserSuspendReq and (not Terminated) do begin sleep(100) end;
      if cnt = 0 then t0 := TimeDeltaTICKgetT0;
      for i:= 1 to 9 do
        begin
          ni := 'int' + IntToStr(i);
          ns := 'str' + IntToStr(i);
          nf := 'flt' + IntToStr(i);

          rn.valInt[ni] := rn.valInt[ni] + 1;
          rn.valStr[ns] := IntToStr( rn.valInt[ni] );
          ii := MyXStrToInt(rn.valStr[ns]);
          rn.valDouble[nf] := rn.valInt[ni] * 2.33 * ii;

        end;
       cnt := cnt + 1;
       Inc(ncyc);
       if cnt >=100 then
         begin
           dtMS := TimeDeltaTICKNowMS( t0 );
           rn.valInt['thread_cycle_time_ms'] := dtMS;
           rn.valStr['my_name'] := fn;
           rn.valInt[fn + 'time_ms'] := dtMS;
           rn.valInt[fn + 'ncyc'] := ncyc;
           cnt := 0;
           sleep(20);
         end;
      //sleep(20);
    end;
end;




procedure TXThread.SetUserSuspend;
begin
  fUserSuspendReq := true;
end;

procedure TXThread.ResetUserSuspend;
begin
  fUserSuspendReq := false;
  Resume;  //just in case
end;






procedure TForm1.Button3Click(Sender: TObject);
begin
  fT2.ResetUserSuspend;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  fT3.ResetUserSuspend;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  fThread.Terminate;
  fT2.Terminate;
  fT3.Terminate;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  fT4.ResetUserSuspend;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  fThread.SetUserSuspend;
  fT2.SetUserSuspend;
  fT3.SetUserSuspend;
  fT4.SetUserSuspend;
end;

end.

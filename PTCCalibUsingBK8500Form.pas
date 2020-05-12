unit PTCCalibUsingBK8500Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, math, StrUtils,
  PTCInterface_BK8500, HWAbstractDevicesV3, MyComPort, HWInterface,
  Myparseutils,
  FormHWAccessControlUnit, FormPTCHardwareUnit, Logger, myutils, MVConversion, ExtCtrls;

type
  TArrayDouble = array of double;


  TPTCCalibForm = class(TForm)
    buBKConfPort: TButton;
    buBKopenPort: TButton;
    buBKcloseport: TButton;
    LaBKstatus: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Button3: TButton;
    Label4: TLabel;
    Memo3: TMemo;
    LErrors: TLabel;
    Timer1: TTimer;
    LaBKU: TLabel;
    LaBKI: TLabel;
    LaPTCU: TLabel;
    LaPTCI: TLabel;
    BKO: TCheckBox;
    PTCO: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    CheckBox1: TCheckBox;
    Label5: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Button6: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit5: TEdit;
    Button7: TButton;
    chkWaitSP: TCheckBox;
    CheckBox2: TCheckBox;
    Label6: TLabel;
    Label7: TLabel;
    Button8: TButton;
    Button9: TButton;
    Edit6: TEdit;
    Edit7: TEdit;
    Button10: TButton;
    Button11: TButton;
    Edit8: TEdit;
    Button12: TButton;
    Edit9: TEdit;
    Button13: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure buBKConfPortClick(Sender: TObject);
    procedure buBKopenPortClick(Sender: TObject);
    procedure buBKcloseportClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
  private
    BK8500: TBK8500Potentio;
    { Private declarations }
    fBKrec: TPotentioRec;
    fBKst: TPotentioStatus;
    fPTCrec: TPotentioRec;
    fPTCst: TPotentioStatus;
    lock: boolean;
    fTok: THWAccessToken;
    fCancel: boolean;
  public
    { Public declarations }
    function GenerateList(src: string; Var a: TArrayDouble; Var errlist: TStringList): boolean;
    function RunPTCCheckSweep(delay: integer; naver: integer): boolean;
  end;

var
  PTCCalibForm: TPTCCalibForm;

implementation

uses datastorage;

{$R *.dfm}

procedure TPTCCalibForm.FormShow(Sender: TObject);
begin
  if BK8500=nil then
    begin
     //BK8500 :=  TBK8500Potentio.Create;
     //BK8500.LoadConfig;
     //BK8500.setPortName('COM3');
     //BK8500.setBaudRate('38400');
    end;
end;

procedure TPTCCalibForm.FormCreate(Sender: TObject);
begin
  BK8500 := nil;
  lock := false;
  fTok :=  THWAccessToken.Create;
  fTok.tokenname := 'PTCTest-with-BK8500';
end;

procedure TPTCCalibForm.FormDestroy(Sender: TObject);
begin
  if BK8500<>nil then BK8500.Destroy;
  fTok.Destroy;
end;

procedure TPTCCalibForm.buBKConfPortClick(Sender: TObject);
begin
  if BK8500<>nil then BK8500.SetupComPort;
end;

procedure TPTCCalibForm.buBKopenPortClick(Sender: TObject);
begin
  if BK8500<>nil then BK8500.OpenComPort;
end;

procedure TPTCCalibForm.buBKcloseportClick(Sender: TObject);
begin
  if BK8500<>nil then BK8500.CloseComPort;
end;

procedure TPTCCalibForm.Button4Click(Sender: TObject);
begin
  if BK8500<>nil then BK8500.Initialize;
end;

procedure TPTCCalibForm.Button5Click(Sender: TObject);
begin
  if BK8500<>nil then BK8500.Finalize;
end;


procedure TPTCCalibForm.Button3Click(Sender: TObject);
Var
   ad: TArrayDouble;
   i: longint;
   el: TStringList;

begin
  el := TStringList.Create;
  GenerateList( Edit1.Text, ad, el);
  Memo2.Lines.Clear;
  for i:=0 to Length(ad)-1 do Memo2.Lines.Add( FloatTostr( ad[i] ) );
  Memo3.Clear;
  for i:=0 to el.Count-1 do Memo3.Lines.Add( el.Strings[i] );
  el.Destroy;
end;

procedure TPTCCalibForm.Button1Click(Sender: TObject);
begin
  RunPTCCheckSweep( StrToIntDef( Edit2.Text, 1000), StrToIntDef( Edit3.Text, 1) );
end;



procedure ArrayDAdd(Var a: TArrayDouble; d: double);
Var
  i: longint;
begin
  i := Length(a);
  Setlength(a, i+1);
  a[i] := d;
end;

function extractargument(s: string; pos: longint ): string;
//expect pos pointing at first (
//returns string up to corresponding finish )  without the "(", ")"!!!!
Var
  from, toi: longint;
begin
  from := pos + 1;
  toi :=  PosEx( ')', s, pos );   //AnsiPos
  Result := StrCopyFromTo1base(s, from, toi-1);
end;

function TPTCCalibForm.GenerateList(src: string; Var a: TArrayDouble; Var errlist: TStringList): boolean;
Var
  tl, tla: TTokenList;
  i, j, ka, kb, p: longint;
  b: boolean;
  s, sa, sfrom, sto, sstep: string;
  d, dfrom, dto, dstep: double;
begin
  Result := false;
  SetLength(a, 0);
  errlist.Clear;
  if not ParseStrSep(src, ',', tl) then exit;
  ka := Length(tl);
  for i:=0 to ka-1 do
    begin
      s := tl[i].s;
      p := AnsiPos('list', s);
      if p=0 then  //handle value
        begin
          d := MyStrToFloat(s);
          ArrayDAdd(a, d);
        end;
      if p=1 then  //handle list generator
        begin
          sa := extractargument(s, 5);
          b := ParseStrSep(sa, ';', tla);
          if (not b) or (length(tla)<>3) then
            begin
              errlist.Add('Error parsing list at token ' + IntToStr(i));
              continue;
            end;
          sfrom := tla[0].s;
          sto := tla[1].s;
          sstep := tla[2].s;

          errlist.Add(' token ' + IntToStr(i) + ' values ' + sfrom + ' ' + sto + ' ' + sstep);

          dfrom := MyStrToFloatDef(sfrom, 0.0);
          dto := MyStrToFloatDef(sto, 1.0);
          dstep := MyStrToFloatDef(sstep, 0.1);

          errlist.Add(' token ' + IntToStr(i) + ' values ' + FloatToStr( dfrom ) + ' ' + FloatToStr( dto) + ' ' + FloatToStr( dstep));
          if Isnan(dfrom) or Isnan(dto) or IsNan(dstep) then
          begin
              errlist.Add('  got NAN at token ' + IntToStr(i));
              continue;
          end;

          ArrayDAdd(a, dfrom);
          if dto>dfrom then dstep := abs(dstep);
          if dto<dfrom then dstep := - abs(dstep);
          while true do
            begin
              dfrom := dfrom + dstep;
              if (dstep>0) and (dfrom>dto) then break;
              if (dstep<0) and (dfrom<dto) then break;
              ArrayDAdd(a, dfrom);
            end;
        end;
      if p>1 then
        begin
          errlist.Add('Error at token ' + IntToStr(i));
        end;
    end;

end;


procedure WaitWithAppProcMsgs( delay: longint );
var
  t0: longword;
begin
  t0 := TimeDeltaTICKgetT0;
  while TimeDeltaTICKNowMS( t0 )<delay do Application.ProcessMessages;
end;



function TPTCCalibForm.RunPTCCheckSweep(delay: integer; naver: integer): boolean;
Var
   ad: TArrayDouble;
   i, j, n: longint;
   el: TStringList;
   sp, avu, avi, ptcavu, ptcavi, BKspU: double;
   ss, sx: string;
   wait: boolean;
begin
  if BK8500=nil then exit;
  if not ftok.getLock then begin ShowMessage('not able to HW lock!'); exit; end;
  if lock then begin ShowMessage('internal locked!'); ftok.unlock; exit; end;
  if not BK8500.IsReady then
    begin
       ShowMessage('BK8500 not ready!');
       //ftok.unlock;
       //exit;
    end;

  lock := true;
  fCancel := false;
  wait := chkWaitSP.Checked;

  //
  el := TStringList.Create;
  if naver<1 then naver := 1;

  sx := 'error';
  if RadioButton1.Checked then
    begin
     sx := ' at zero voltage ';
     BK8500.SetCC(30);  //max
     BK8500.TurnLoadON;
    end;
  if RadioButton2.Checked then
    begin
     bkspu := MyStrToFloatDef( Edit5.Text, 1);
     sx := ' at user voltage=' + FloatToStr( bkspu);
     BK8500.SetCV( bkspu );  //max
     BK8500.TurnLoadON;
    end;
  //
  Button3.Click();
  //
  GenerateList( Edit1.Text, ad, el);
  //
  //Memo1.Clear;
  Memo1.Lines.Add('-----------------------'+ DateTimeToStr( Now )  +'-----------------------');
  Memo1.Lines.Add('---------'+ sx  +'-------------------------------------');
  if CheckBox2.checked then  Memo1.Lines.Add('--------------------------  negative currents regime --------------------');
  Memo1.Lines.Add('step'+#9+'SP(A)'+ #9 +'PTCU(V)'+#9+'PTCI(A)'+ #9 + 'BK8500U(V)'+#9+'BK8500I(A)'+ #9 + 'DeltaU(V)'+#9+'DeltaI(A)' );
  n := length( ad );

  if n>0 then
   begin
     MainHWInterface.PTCSetCC( ad[0], fTok );
     MainHWInterface.PTCTurnON(fTok);
   end;

  for i:=0 to n-1 do
    begin
      if fCancel then break;
      sp := ad[i];
      MainHWInterface.PTCSetCC( sp, fTok );
      j := 20;  //seconds to wait max ...
      while true do
        begin
          if fCancel then break;
          MainHWInterface.AquireAll( fTok );
          if CompareEpsilonAequalB( MainHWINterface.DataRec.Inorm, sp, abs(sp)/10 ) then break;
          Dec(j);
          if j<=0 then break;
          WaitWithAppProcMsgs( 1000 );
        end;
      if j=0 then Memo3.Lines.Add('Wait for SP failed for step ' +  IntToStr( i+1 ) );
      //MainHWInterface.PTCTurnON(fTok);
      //
      ss := 'Step ' + IntToStr( i+1 ) + '/'+IntTOStr(n) + ' sp=' + FloatToStrF( sp, ffFixed,7,3);
      Edit4.Text := ss;
      fTok.statusmsg := ss;
      WaitWithAppProcMsgs( delay );
      avu := 0;
      avi := 0;
      ptcavu := 0;
      ptcavi := 0;
      //
      j:=1;
      while (j<=naver) do
        begin
          if fCancel then break;
          BK8500.AquireDataStatus( fBKrec, fBKst );
          MainHWInterface.AquireAll( fTok );
          avu := avu + fBKrec.U;
          avi := avi + fBKrec.I;
          ptcavu := ptcavu + MainHWInterface.DataRec.Uraw;
          ptcavi := ptcavi + MainHWInterface.DataRec.Iraw;
          //check for NAN
          if Isnan(avu) or isNan(avi) or Isnan(ptcavu) or isNan(ptcavi) then
            begin
              //reaquire
              Memo3.Lines.Add('Got NAN in step ' +  IntToStr( i+1 ) );
              j := 1;
              avu := 0;
              avi := 0;
              ptcavu := 0;
              ptcavi := 0;
              continue;
            end;
          Inc(j);
        end;
      avu := avu / naver;
      avi := avi / naver;
      ptcavu := ptcavu / naver;
      ptcavi := ptcavi / naver;
      if CheckBox2.checked then ptcavi := abs(ptcavi);
      //
      Memo1.Lines.Add( IntToStr(i+1)+#9+ FloatToStrF(sp, ffFixed,7,3)+ #9 +
                       FloatToStrF(ptcavu, ffFixed,7,3)+#9+ FloatToStrF(ptcavi, ffFixed,7,3)+ #9 +
                       FloatToStrF(avu, ffFixed,7,3)+#9+ FloatToStrF(avi, ffFixed,7,3)+ #9 +
                       FloatToStrF( abs(ptcavu)-abs(avu), ffFixed,7,3)+#9+ FloatToStrF(abs(ptcavi)-abs(avi), ffFixed,7,3) );
    end;

  MainHWInterface.PTCTurnOFF(fTok);
  BK8500.TurnLoadOFF;
  fTok.unlock;
  el.Destroy;
  lock := false;
end;


procedure TPTCCalibForm.Timer1Timer(Sender: TObject);
Var
  ptcrec: TPotentioRec;
  ptcst: TPotentioStatus;
  b: boolean;
  //datarec: TMonitorRec;
  strv, strI: string;
begin
  if not PTCCalibForm.Visible then exit;
  CheckBox1.Checked := lock;
  if BK8500<>nil then
    begin
      LaBKStatus.Caption := BK8500.getPortName + ' open='+ BoolToStr( BK8500.isPortOpen() );
      if BK8500.IsReady then
        begin
         b := true;
         if not lock then b := BK8500.AquireDataStatus(fBKrec, fBKst);
         LaBKU.Caption := FloatToStrF( fBKrec.U, ffFixed,7,3 ) + ' V';;
         LaBKI.Caption := FloatToStrF( fBKrec.I, ffFixed,7,4 ) + ' A';
         BKO.Enabled := true;
         BKO.Checked := fBKst.isLoadConnected;
         if not b then
               begin
                LaBKU.Caption := ' failed aquire';
                LaBKI.Caption := '';
               end;
        end
      else
        begin
         LaBKU.Caption := 'not ready';
         LaBKI.Caption := 'not ready';
         BKO.Enabled := false;
         BKO.Checked := false;
        end
    end
  else
    begin
      LaBKStatus.Caption := 'NIL';
      LaBKU.Caption := 'NIL';
      LaBKI.Caption := 'NIL';
      BKO.Enabled := false;
      BKO.Checked := false;
    end;
   //main ptc
   strV := FloatToStrF( MainHWInterface.DataRec.U ,ffFixed,7,3) + ' V';
   strI := FloatToStrF( MainHWInterface.DataRec.I ,ffFixed,8,4) + ' A';
   LaPTCU.Caption := strV;
   LaPTCI.Caption := strI;
   PTCO.Checked :=  MainHWInterface.DataRec.PTCStatus.isLoadConnected;
end;



procedure TPTCCalibForm.Button6Click(Sender: TObject);
begin
  fCancel := true;
end;

procedure TPTCCalibForm.Button2Click(Sender: TObject);
begin
  Memo1.SelectAll;
  Memo1.CopyToClipboard;
end;

procedure TPTCCalibForm.Button7Click(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TPTCCalibForm.Button8Click(Sender: TObject);
begin
  if BK8500<>nil then BK8500.TurnLoadOFF;
end;

procedure TPTCCalibForm.Button9Click(Sender: TObject);
begin
  if BK8500<>nil then BK8500.TurnLoadON;
end;

procedure TPTCCalibForm.Button11Click(Sender: TObject);
begin
  if BK8500<>nil then BK8500.SetCV( MyStrToFloatDef(Edit7.Text, 1 ) );
end;

procedure TPTCCalibForm.Button10Click(Sender: TObject);
begin
  if BK8500<>nil then BK8500.SetCC( MyStrToFloatDef(Edit6.Text, 0 ) );
end;

procedure TPTCCalibForm.Button12Click(Sender: TObject);
begin
  MainHWInterface.PTCSetCC( MyStrToFloatDef(Edit8.Text, 0 ), fTok );
end;

procedure TPTCCalibForm.Button13Click(Sender: TObject);
begin
    MainHWInterface.PTCSetCV( MyStrToFloatDef(Edit9.Text, 0 ), fTok );
end;

end.

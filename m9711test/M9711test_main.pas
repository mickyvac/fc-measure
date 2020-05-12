unit M9711test_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, strutils,
  myutils, MyComPort, Logger, mvconversion,
  M97XX_interface, ExtCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Label2: TLabel;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    Button5: TButton;
    Label3: TLabel;
    Edit10: TEdit;
    Button9: TButton;
    Label9: TLabel;
    Edit11: TEdit;
    Edit15: TEdit;
    Button11: TButton;
    Edit16: TEdit;
    Label12: TLabel;
    Panel1: TPanel;
    Button6: TButton;
    Edit6: TEdit;
    Label5: TLabel;
    Button7: TButton;
    Edit7: TEdit;
    Edit8: TEdit;
    Label7: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Button8: TButton;
    Edit5: TEdit;
    Edit9: TEdit;
    Label8: TLabel;
    Label10: TLabel;
    Button10: TButton;
    Edit12: TEdit;
    Edit13: TEdit;
    Label11: TLabel;
    Edit14: TEdit;
    Panel2: TPanel;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Memo2: TMemo;
    Timer1: TTimer;
    GetStatus: TButton;
    GetSTatusExt: TButton;
    Button12: TButton;
    CheckBox1: TCheckBox;
    Button16: TButton;
    Edit17: TEdit;
    Button17: TButton;
    Edit18: TEdit;
    Button18: TButton;
    Edit19: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure GetStatusClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      //function BKsendcmd( Var cmd: Tbk8500message ): boolean;
      //function BKReceiveMsg(Var msg: TBK8500message; timeout: longint): boolean; //returns true on success , fills internal bkrxbuf!!!
      //function BKgetResult( Var res: Tbk8500message; Var rescode: integer ): boolean;
      //function BKIsEndOfMessage(Const recvbuf: string): boolean;
      //function BKSendReceive(Const cmd: string; Var reply:string; Timeout: longword; CLearInBuf: boolean = true): boolean;  //needs isendofmessage fucntion
      procedure logmsg(s: string);

      function BKReceiveMsg(Var res: string; timeout: longint): boolean;
{      function ReadCoilStatus(Var res: TBytes; Var rescode:byte; addr: byte; startaddr: word; Nbytes: word): boolean; //returns true on success , fills internal bkrxbuf!!!
      function SetCoil(Var rescode:byte; devaddr: byte; memaddr: word; state: boolean): boolean;
      function ReadRegisters(VAr data: TBytes; Var rescode:byte; devaddr: byte; memaddr: word; nwords: word): boolean;
      function WriteRegisters(Var rescode: byte; devaddr: byte; memaddr: word; nwords: word; data:TBytes ): boolean;
}


    private
      fM97Iface: TM97XXlowlevelIface;
      fComPort: TComPortThreadSafe;
      fTimeout: longword;
      fLog: TLoggerThreadSafeNew;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
Var pc: TComPortConf;
begin
  fLog := TLoggerThreadSafeNew.Create;
  fLog.StartLogFileName('!log.txt');

  fComPort := TComPortThreadSafe.Create;
  fTimeout := 500;
  fComPort.getComPortConf( pc);
  pc.Name := 'COM3';
  pc.BR := '57600';
  fComPort.setComPortConf( pc);

  fM97Iface := TM97XXlowlevelIface.Create;
  fM97Iface.AssignComPort( fComPort);
  fM97Iface.AssignLogObject( fLog );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fM97Iface.Destroy;
  fComPort.Destroy;
  fLog.Destroy;
end;


procedure TForm1.Button1Click(Sender: TObject);
Var
 s: string;
 convs: string;
 i, len: integer;
 b: TBytes;
 w: word;
begin
  s := Edit1.text;
  len := length(s) div 2;
  setlength(convs, len);
  hextoBin(PChar(s), Pchar(convs), len);
  setlength(b, len);
  for i:=0 to len-1 do b[i] := CharToByte( convs[i+1] );
  s := CRC16ModbusStrBE( b );
  w := CRC16ModbusA(b);
  //Edit2.Text := IntToHex(w, 2);
  Edit2.Text :=  BinStrToPrintStrHexa( s );
end;



procedure TForm1.Button3Click(Sender: TObject);
begin
  fComPort.ShowSetupDialog;
end;

procedure TForm1.Button2Click(Sender: TObject);
Var
   b: boolean;
begin
  b := fComPort.OpenPort;
  logmsg('open port  res='+ BoolToStr( b) );
end;

procedure TForm1.logmsg(s: string);
begin
  Memo1.Lines.Add( DateTimeToStr(Now) + ' ' + s);
end;

procedure TForm1.Button4Click(Sender: TObject);
Var
   b: boolean;
begin
  fComPort.ClosePort;
  logmsg('close port');
end;



Function EncodeHexaCmdToStr(hs: string): string;
Var
 s: string;
 convs: string;
 i, len: integer;
 b: TBytes;
 w: word;
begin
  Result := '';
  convs := MyHexStrToBin(hs);
  len := length(convs);
  setlength(b, len);
  for i:=0 to len-1 do b[i] := CharToByte( convs[i+1] );
  s := CRC16ModbusStrBE( b );
  w := CRC16ModbusA(b);
  //Edit2.Text := IntToHex(w, 2);
  Result := convs + s;
end;




procedure TForm1.Button5Click(Sender: TObject);
Var
  s, msg, res: string;
  b: boolean;
begin
  s := Edit3.Text;
  msg := EncodeHexaCmdToStr( s );
  b := fComPort.SendStringRaw( msg );
  logmsg( 'sending |'+ BinStrToPrintStrHexa( msg ) + '| len=' + IntToStr( length(msg)) + ' res='+ BoolToStr( b) );
  res := '';
  b := BKReceiveMsg(res, 500); //fComPort.ReadStringRaw( res );
  logmsg( 'res='+ BoolToStr(b) + ' received |'+ BinStrToPrintStrHexa( res ) + '| len=' + IntToStr( length(res)) )
end;



function TForm1.BKReceiveMsg(Var res: string; timeout: longint): boolean; //returns true on success , fills internal bkrxbuf!!!
//returns true on success , reads from  internal bkrxbuf!!!
Var i: integer;
    strt: TDateTime;
    t1: Cardinal;
    b: boolean;
    rstr: string;
  bs, br: boolean;
  //dtout: TDateTime;
  t0: longword;
  tout: boolean;
  s, reply: string;
begin
  Result := false;
  //
  //bkrxbuf.len := 0;
  if not fComPort.IsPortOpen then
    begin
    logmsg('TBK8500Potentio.BKReceiveMsg: BKConnected false' );
    exit;
    end;

     strt := Now;
     t1 := GetTickCount;

     //receive tiomeout
     //before sending prepare for receiving
     reply := '';
     tout := true;
     fcomport.RecvEnabled := true;
     t0 := TimeDeltaTICKgetT0;
     //receive
     while TimeDeltaTICKNowMS(t0)< timeout do
       begin
         br := fcomPort.ReadStringRaw(s);
         //if not br then continue;
         reply := reply + s;
         if false then //if BKIsEndOfMessage( reply ) then
           begin
             tout := false;
             break;
           end;
       end;
     fcomPort.RecvEnabled := false;   //do not expect any other incoming data

     Result := not tout;
   //convert to BK buf

  res := reply;
  //clear rx buffer
end;






procedure TForm1.Button6Click(Sender: TObject);
Var
 n, addr: word;
 tb: tBytes;
 rc: byte;
 b: boolean;
 t0, dt: longword;
begin
  //n := StrToIntDef( Edit5.Text, 1);
  n := 8;
  addr := HexStrToLongwordLE ( Edit6.Text );
  t0 := TimeDeltaTICKgetT0;
  b := fM97Iface.M97ReadCoilStatus(tb, rc, 1, addr, n);
  dt := TimeDeltaTICKNowMS(t0);
  logmsg('READ COILS result: res=' + BoolToStr(b) + 'rescode=' + IntToStr(rc) + 'len= '
       + IntToStr( length(tb) ) + ' data=' + BinaryArrayToHexStr(tb, length(tb)) + ' elapsedms=' + IntToStr( dt ) ) ;
end;

procedure TForm1.Button7Click(Sender: TObject);
Var
 ns: boolean;
 addr: word;
 rc: byte;
 b: boolean;
 t0, dt: longword;
begin
  //set coil
  ns := StrToIntDef( Edit7.Text, 0) <> 0;
  addr := HexStrToLongwordLE ( Edit8.Text );
  t0 := TimeDeltaTICKgetT0;
  b := fM97Iface.M97SetCoil(rc, 1, addr, ns);
  dt := TimeDeltaTICKNowMS(t0);
  logmsg('SET COIL result: ' + 'newstate=' + BoolToStr(ns) + 'res=' + BoolToStr(b)
      + 'rescode=' + IntToStr(rc) +  ' elapsedms=' + IntToStr( dt ) ) ;
end;

procedure TForm1.Button9Click(Sender: TObject);
Var
 s: string;
 lw: longword;
 f: double;
 sngl: single;
begin
  lw := HexStrToLongwordBE ( Edit10.Text );
  sngl := FourBytesToSingle(lw shr 24, lw shr 16, lw shr 8, lw and $FF);
  Edit11.Text := FloatToStr( sngl );
end;

procedure TForm1.Button8Click(Sender: TObject);
Var
 n: byte;
 addr: word;
 rc: byte;
 b: boolean;
  tb: tBytes;
 t0, dt: longword;
begin
  n := StrToIntDef( Edit5.Text, 1);
  addr := HexStrToLongwordLE ( Edit9.Text );
  t0 := TimeDeltaTICKgetT0;
  b := fM97Iface.M97ReadRegisters(tb, rc, 1, addr, n);
  dt := TimeDeltaTICKNowMS(t0);
  logmsg('READ MEM result: ' + 'res=' + BoolToStr(b)
               + 'rescode=' + IntToStr(rc) +  ' data=' + BinaryArrayToHexStr(tb, length(tb)) + ' elapsedms=' + IntToStr( dt ) ) ;
end;

procedure TForm1.Button10Click(Sender: TObject);
Var
 n: byte;
 addr: word;
 databin: string;
 rc: byte;
 b: boolean;
  tb: tBytes;
 t0, dt: longword;
begin
  n := StrToIntDef( Edit12.Text, 1);
  addr := HexStrToLongwordLE ( Edit13.Text );
  databin := MyHexStrToBin( Edit14.Text );
  BinStrToBinArray(databin, tb);
  t0 := TimeDeltaTICKgetT0;
  b := fM97Iface.M97WriteRegisters(rc, 1, addr, n, tb);
  dt := TimeDeltaTICKNowMS(t0);
  logmsg('WRITE MEM result: ' + 'res=' + BoolToStr(b)
               + 'rescode=' + IntToStr(rc) +  ' data=' + BinaryArrayToHexStr(tb, length(tb)) + ' elapsedms=' + IntToStr( dt ) ) ;
end;

procedure TForm1.Button11Click(Sender: TObject);
Var
 s: string;
 lw: longword;
 f: double;
 sngl: single;
 b1, b2, b3, b4: byte;
begin
  sngl := StrToFloatDef( Edit15.Text, 0.0);
  SingleTo4Bytes(sngl, b4, b3, b2, b1);
  Edit16.Text := ByteToHexStr(b1) + ' ' + ByteToHexStr(b2) + ' ' + ByteToHexStr(b3) + ' ' + ByteToHexStr(b4);
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  fM97Iface.SetInputON;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  fM97Iface.SetInputOFF;
end;





procedure TForm1.Button14Click(Sender: TObject);
begin
  fM97Iface.SetModeCV;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  fM97Iface.SetModeCCwithCVprotection;
end;

procedure TForm1.GetStatusClick(Sender: TObject);
  procedure AddItem( id: string );
    Var
      d: double;
    begin
      d :=  fM97Iface.Data.valDouble[ Id ];
      Memo2.Lines.Add( id + ': ' + FloatToStrF( d , ffFixed, 6, 3) );
    end;
begin
  Memo2.Lines.Clear;
  fM97Iface.AcquireStatus;
  Memo2.LInes.Add( 'acquired run ' + DateTimeToStr(Now));
  AddItem( IdM97U );
  AddItem( IdM97I );
  AddItem( IdM97UFIX );
  AddItem( IdM97IFIX );
  AddItem( IdM97PFIX );
  AddItem( IdM97UMAX );
  AddItem( IdM97IMAX );
  AddItem( IdM97PMAX );
  AddItem( IdM97UCCCV );
  AddItem( IdM97MODEL );
  AddItem( IdM97EDITION );
  AddItem( IdM97PC1 );
  AddItem( IdM97PC2 );
  AddItem( IdM97REMOTE );
  AddItem( IdM97ISTATE );
  AddItem( IdM97REVERSE );
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  Timer1.Enabled := CheckBox1.Checked;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  GetStatusClick(Sender);
end;

procedure TForm1.Button16Click(Sender: TObject);
Var val: single;
begin
  val :=  MyStrToFloatDef( Edit17.Text, 1);
  fM97Iface.SetUfix( val );
end;

procedure TForm1.Button17Click(Sender: TObject);
Var val: single;
begin
  val := MyStrToFloatDef( Edit18.Text, 0);
  fM97Iface.SetIfix( val );
end;

procedure TForm1.Button18Click(Sender: TObject);
Var val: single;
begin
  val :=  MyStrToFloatDef( Edit19.Text, 1);
  fM97Iface.SetUCCCV( val );
end;

end.

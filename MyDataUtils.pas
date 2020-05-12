unit MyDataUtils;

interface

Const
  CDataSmootherMaxData = 10000;

type

{
  TCyclicArrayBase = class  //firstin first out queue manager  - manages virtual indexes - in descendadnt the actuall array is placed
  public
    constructor Create( maxn: longint);  //up to 1000?? points stored for math processing
    destructor Destroy;
  protected
    procedure Push;
    procedure Pop;
    procedure Clear;
  private
    fN: longint;
    fStrt: longint;
    fPos: longint; //pos of last added number in fData
    fmaxn: longint;
  public                                                      //any result MAY contain NAN !!!!!
    property N: longint read fN;
    property StrtI: longint read fN;
    property LastI: longint read fN;
  end;
}


  TDataSmoother = class
  public
    constructor Create( maxn: longint);  //up to 1000?? points stored for math processing
    destructor Destroy; override;
  public
    procedure AddVal(d: double);
    procedure Clear;
  private
    fData: array of double;
    fN: longint;
    fStrt: longint;
    fPos: longint; //pos of last added number in fData
    fmaxn: longint;
    fMax: double;
    fMin: double;
    fAver: double;
    fSavGolaySm: double;
    fAverN: longint;
  public                                                      //any result MAY contain NAN !!!!!
    property Max: double read fMax;
    property Min: double read fMin;
    property Aver: double read fAver;
    property N: longint read fN;
    property NtoAverage: longint read faverN write faverN;   //will calculate average form N last values
  end;



implementation


    constructor TDataSmoother.Create( maxn: longint);  //up to 1000?? points stored for math processing
    begin
      if maxn<1 then maxn := 1;
      if maxn>CDataSmootherMaxData then maxn := CDataSmootherMaxData;
      fmaxn := maxn;
      setlength(fData, fmaxn);
      fPos := 0;
      fStrt := 0;
      fN := 0;
    end;

    destructor TDataSmoother.Destroy;
    begin
      setlength(fData, 0);
      fN := 0;
    end;

    procedure TDataSmoother.AddVal(d: double);
    Var                                                     //tqueue
      newpos: longint;
    begin
      newpos := fPos + 1;
      if newpos = fMaxn then newpos := 0;
      if newpos = fStrt then Inc(fStrt);
      fData[newpos] := d;
      fPos := newpos;
    end;


    procedure TDataSmoother.Clear;
    begin
    end;
end.

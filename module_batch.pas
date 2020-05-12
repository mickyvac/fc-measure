unit module_batch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;


type

TCommandType = ( CCmdUndef,
                 CCmdCTRLForLoop, CCmdCTRLUntilLoop, 
                 CCmdPTCTurnOff, CCmdPTCTurnCON, CCmdPTCSetCC, CCmdPTCSetCV,
                 CCmdFlowSetFlow,
                 CCmdProjSetFlowTracking, CCmdProjSetInvVoltage, CCmdProjSetInvCurrent,
                 CCmdModuleVACHAR, CCmdModuleBatchRoman );

{
TCommandNodeBase  = class  //common command ancestor
  public
    constructor Create;
    destructor Destroy; override;
  public   //implemented as double linked list/ tree
    fRootNode: TCommandNodeBase;
    fNextNode: TCommandNodeBase;
    fPrevNode: TCommandNodeBase;
    fParentNode: TCommandNodeBase;
    //
    fCmdType: TCommandType;   //Each cmd type should have its own derived class object with specific parameters and execute method
    function Execute(): boolean;  virtual; abstract;
  end;

TCommandSequence = class
  public
    constructor Create;
    destructor Destroy; override;
  public
    fRootTtem: TCommandNodeBase;

  end;



}


type
  TFormBatch = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Button2: TButton;
    Memo3: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormBatch: TFormBatch;

implementation

{$R *.dfm}

end.

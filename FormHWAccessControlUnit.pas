unit FormHWAccessControlUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls{, ExtCtrls},
  Logger, ExtCtrls;

type
  TStatusFunction = function: string;

type
   THWAccessToken = class
   //idea is that a module or fucntion has to have its own token to be granted control of aquire -
   // aquire methods could check if passed token is the one that has granted control ...
   //also the signal or request to stop is signaled through this token by the HWAccessControl
   public
     constructor create;   //will obtain unique ID
     function getLock: boolean;  //result true = lock succesfull
     procedure unlock;
     function isAccessAllowed: boolean;  //true if lock still valid
     function isRequestToStop: boolean;  //true if main app signaled stop of aquire
     function getID: longint;
   public
     tokenname: string;    //to identify what module this token belongs to
                      //(plan is in batch module, the token will be borrowed to each task in sequence, e.g. VA char
     statusmsg: string;     //main app will display this string as status of present progress of this task
     statusmsg2: string;
     onProjectUpdateProc: TMethod;  //if assigned the ProjectControl will have called this method, when project related info is changed
                                   //and requires change of configuration e.g. there is new directory to store files
     root: boolean;     //flag if it is root then verification goes agains list of root tokens
   private
     tokenid: longint;
   end;

   PHWAccessToken = ^THWAccessToken;



type
  TFormHWAccessControl = class(TForm)
    Label1: TLabel;
    PanProjDescript: TPanel;
    Label2: TLabel;
    Panel1: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    listofroottokens: array of longint;
    idgeneratorlast: longint;
    idlocker: longint;
    lockstatus: boolean;  //true= lock active
    varstopreq: boolean;
    activetoken: THWAccessToken;
  public
    fSWInterlok: boolean;
  public
    ///on create should ini id gen
    { Public declarations }
    function genID: longint;  //generate new unique id for idenfying lock

    function dolock(token: THWAccessToken): boolean;
      //token caintains: 'id' = is id assigned by genID, 'name' is infromation to identify the module which made lock,
    procedure unlock(token: THWAccessToken);
    function islocked: boolean;  //true =hw access is locked
    function TokenLockIsActive(token: THWAccessToken): boolean;  //query if token is still owning the lock
    function TokenCanAccessHW(token: THWAccessToken): boolean;  //query if token can access - includes check for ROOT token will unlimited access
    procedure RegisterRootToken(token: THWAccessToken);
    function IsTokenInRoot(token: THWAccessToken): boolean;
    function stoprequested: boolean;
    function gettaskname: string;
    function gettaskstatus: string;
    function gettaskstatus2: string;
  end;



var
  FormHWAccessControl: TFormHWAccessControl;

implementation

{$R *.dfm}

constructor THWAccessToken.create;   //will obtain unique ID
begin
  inherited;
  tokenid := -1;
  if FormHWAccessControl<>nil then tokenid :=  FormHWAccessControl.genID
  else logmsg(' THWAccessToken.create FormHWAccessControl=nil' );
  logmsg(' THWAccessToken.create tokeinid=' + IntToStr( tokenid ) );
  tokenname := 'noname';
  statusmsg := 'N/A';
end;


function THWAccessToken.getLock: boolean;  //result true = lock succesfull
begin
  Result := FormHWAccessControl.dolock( self );
end;


procedure THWAccessToken.unlock;
begin
  FormHWAccessControl.unlock( self );
end;


function THWAccessToken.isAccessAllowed: boolean;  //true if lock still valid
begin
  Result := FormHWAccessControl.TokenLockIsActive( self );
end;


function THWAccessToken.isRequestToStop: boolean;  //true if main app signaled stop of aquire
begin
  Result := FormHWAccessControl.stoprequested;
end;


function THWAccessToken.getID: longint;
begin
  Result := tokenid;
end;



// -------

procedure TFormHWAccessControl.FormCreate(Sender: TObject);
begin
  idgeneratorlast :=  1000; //starting number
  lockstatus := false;  //true= lock active
  activetoken := nil;
  fSWInterlok := false;
  logmsg('TFormHWAccessControl.FormCreate done.');
end;


function TFormHWAccessControl.genID: longint;  //generate new unique id for idenfying lock
begin
  Inc(idgeneratorlast);
  Result := idgeneratorlast;
end;

function TFormHWAccessControl.dolock(token: THWAccessToken): boolean;
      //token caintains: 'id' = id assigned by genID, 'name' is infromation to identify the module which made lock,
begin
  Result := false;
  if token=nil then exit;
  if fSWInterlok then exit;  //when general sw interlock, no token can get acccess
  if lockstatus and (activetoken=token) then  //this token already has lock
    begin
      Result := true;
      exit;
    end;
  if lockstatus then exit;   //lock is active already - by another token
  lockstatus := true;
  activetoken := token;
  idlocker := token.getID;
  Result := true;
end;

procedure TFormHWAccessControl.unlock(token: THWAccessToken);
begin
  if not lockstatus then exit;
  if token=nil then exit;
  if token.getID <> idlocker then exit;  //lock not owned
  idlocker := 0;
  activetoken := nil;
  lockstatus := false;
end;

function TFormHWAccessControl.islocked: boolean;  //true =hw access is locked
begin
  Result := lockstatus;
end;

function TFormHWAccessControl.TokenLockIsActive(token: THWAccessToken): boolean;
//query whether token is still owning the lock
begin
  Result := false;
  if token=nil then exit;
  Result := lockstatus and (token.getID = idlocker);
end;

function TFormHWAccessControl.TokenCanAccessHW(token: THWAccessToken): boolean;
//query if token can access - includes check for ROOT token will unlimited access
begin
  Result := TokenLockIsActive(token);
  if (not Result) and (token.root) then Result := IsTokenInRoot( token );
end;

procedure TFormHWAccessControl.RegisterRootToken(token: THWAccessToken);
Var
 n: longint;
begin
  if token=nil then exit;
  token.root := true;
  if IsTokenInRoot(token) then exit;
  n := length( listofroottokens );
  setlength( listofroottokens, n+1 );
  listofroottokens[n] := token.getid;
end;

function TFormHWAccessControl.IsTokenInRoot(token: THWAccessToken): boolean;
Var
 n, i, id: longint;
begin
  Result := false;
  if token=nil then exit;
  n := length( listofroottokens );
  if n=0 then exit;
  id := token.getID;
  for i:= 0 to n-1 do
    begin
      if listofroottokens[i] = id then
        begin
          Result := true;
          exit;
        end;
    end;
end;


function TFormHWAccessControl.stoprequested: boolean;
begin
  Result := varstopreq;
end;


function TFormHWAccessControl.gettaskname: string;
begin
  Result := 'Undefined';
  if not lockstatus then
    begin
    Result := 'Idle';
    exit;
    end;
  if activetoken=nil then exit;
  Result := activetoken.tokenname;
end;


function TFormHWAccessControl.gettaskstatus: string;
begin
  Result := 'Undefined';
  if not lockstatus then
    begin
    Result := '---';
    exit;
    end;
  if activetoken=nil then exit;
  Result := activetoken.statusmsg;
end;

function TFormHWAccessControl.gettaskstatus2: string;
begin
  Result := 'Undefined';
  if not lockstatus then
    begin
    Result := '---';
    exit;
    end;
  if activetoken=nil then exit;
  Result := activetoken.statusmsg2;
end;


end.

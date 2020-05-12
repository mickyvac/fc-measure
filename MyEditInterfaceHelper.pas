unit MyEditInterfaceHelper;

interface

uses Classes, Controls, StdCtrls, ExtCtrls, Graphics, Contnrs, Forms, strutils, SysUtils, math,
     Logger, myutils, MyThreadUtils, MVConversion,
     ConfigManager, MyParseUtils;

Const
  CSuffixDdefaultVal = '_defaultvalue';
  CSuffixConfigStr = '_configstr';
  CSuffixHistoryStr = '_historystr';
  CSuffixHintStr = '_hintstr';

Type
  TCTrlObjAncestor = class (TMyLockableObject)
    public
      constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
      destructor Destroy; override;
    public
      procedure Refresh; virtual; abstract; //updates GUI properties
    public
      procedure SetDefaultValue; //not virtual!
      procedure SyncFromRegistry; //not virtual!
      procedure StoreConf; //not virtual!
      procedure RestoreConf; //not virtual!
    public //virtual, but default action is defined
      procedure BeginChanges;  virtual;   //default: nothing
      procedure CommitChanges; virtual;   //default: strore value to reg
      procedure CancelChanges; virtual;   //default: replace value from data in reg
    public
      procedure fOnClick(Sender: TObject); virtual;   //default: nothing //TNotifyEvent;
      procedure fOnChange(Sender: TObject); virtual;   //default: nothing //TNotifyEvent;
      procedure fOnKeyPress(Sender: TObject; var Key: Char); virtual;   //default: nothing//TKeyPressEvent;
    public
      fCtrl: TControl;
      fRegObj: TMyRegistryNodeObject;
      fVarName: string;
    protected
      function fGetParentFrm: TCustomForm; //not virtual!
      function fGetDefValueReg: string;   //not virtual!
      procedure fSetDefValueReg(s: string);   //not virtual!
      function fGetHintStrReg: string;   //not virtual!
      function fGetValueReg: string;      //not virtual!
      procedure fSetValueReg(s: string);  //not virtual!
      function fGetHistoryStrReg: string;      //not virtual!
      procedure fSetHistoryStrReg(s: string);  //not virtual!
      function fGetConfigStrReg: string;      //not virtual!
      procedure fSetConfigStrReg(s: string);  //not virtual!
    private
      function fGetValueObj: string;  virtual; abstract;
      procedure fSetValueObj(s: string); virtual; abstract;
      function fPackObjConfToStr: string;  virtual; abstract;
      procedure fUnpackObjConfFromStr(s: string); virtual; abstract;
      procedure fSetObjHint(s: string); virtual; abstract;
    public
      property TextValReg: string read fGetValueReg write fSetValueReg;
      property TextValDef: string read fGetDefValueReg;
      property TextValObj: string read fGetValueObj write fSetValueObj;
      property ParentForm: TCustomForm read fGetParentFrm;
  end;


  TCTrlObjLABEL = class (TCTrlObjAncestor)
    public
      constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
      destructor Destroy; override;
    public
      procedure Refresh; override;
    public
      fLabelObj: TLabel;
    private
      function fGetValueObj: string; override;
      procedure fSetValueObj(s: string); override;
      function fPackObjConfToStr: string; override;
      procedure fUnpackObjConfFromStr(s: string); override;
      procedure fSetObjHint(s: string); override;
  end;


  TCTrlObjRecEDIT = class (TCTrlObjAncestor)
    public
      constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
      destructor Destroy; override;
    public
      procedure Refresh; override;
    public
      fEditObj: TEdit;
      EditInProgress: boolean;
    public
      procedure fOnClick(Sender: TObject); override;   //EditInProgress
      //procedure fOnChange(Sender: TObject); override;   //default: nothing //TNotifyEvent;
      procedure fOnKeyPress(Sender: TObject; var Key: Char); override;   //default: nothing//TKeyPressEvent;
      //
      procedure BeginChanges;  override;   //default: nothing
      procedure CommitChanges; override;   //default: strore value to reg
      procedure CancelChanges; override;   //default: replace value from data in reg
    private
      function fGetValueObj: string; override;
      procedure fSetValueObj(s: string); override;
      function fPackObjConfToStr: string; override;
      procedure fUnpackObjConfFromStr(s: string); override;
      procedure fSetObjHint(s: string); override;
  end;


  TCTrlObjCheckbox = class (TCTrlObjAncestor)
    public
      constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
      destructor Destroy; override;
    public
      procedure Refresh; override;
    public
      fChkObj: TCheckBox;
    public
      procedure fOnClick(Sender: TObject); override;   //EditInProgress
      procedure fOnKeyPress(Sender: TObject; var Key: Char); override;   //default: nothing //TNotifyEvent;
    private
      function fGetValueObj: string; override;
      procedure fSetValueObj(s: string); override;
      procedure fSetObjHint(s: string); override;
  end;



  TCtrlObjGroup = class (TObject)
    public
      constructor Create;
      destructor Destroy; override;
    public
      procedure AddCtrlObj( ctrlo: TCTrlObjAncestor );
      procedure CommitChanges;
      procedure CancelChanges;
      procedure SetDefault;
    private
      fList: TObjectList;
  end;


  TInterfaceHelper = class (TObject)
    public
      constructor Create;
      destructor Destroy; override;
    public
      procedure RefreshControls;
      procedure AssignControl( ctrlobj: TControl; regobj: TMyRegistryNodeObject; varname: string); overload;
      procedure AssignControl( eobj: TEdit; regobj: TMyRegistryNodeObject; varname: string; defval:string; hint: string); overload;
      procedure AssignControl( eobj: TCheckBox; regobj: TMyRegistryNodeObject; varname: string; defval:string; hint: string); overload;
      function FindControlByObjectPTR( ptr: TObject): TCTrlObjAncestor;
      procedure RestoreOrCreateSmartEditBox;
    public
      procedure fOnClick(Sender: TObject); //TNotifyEvent;
      procedure fOnChange(Sender: TObject); //TNotifyEvent;
      procedure fOnKeyPress(Sender: TObject; var Key: Char); //TKeyPressEvent;
      procedure RunAfterUserAction( ctrlo: TCTrlObjAncestor );  //e.g. check if display SmartEditBox for TEdits
    private
      ctrllist: TStringList;  //need the feature of stringlist: store pair of data name(string - will be Control pointer) and correcponding object!!!
      fTimer: TTimer;
      fRefreshLock: TMyLockableObject;
      flastchangeDT: TDateTime;
    private
      procedure AttachToEdit( editobj: TEdit; regobj: TMyRegistryNodeObject; varname: string);
      procedure AttachToLabel( labelo: TLabel; regobj: TMyRegistryNodeObject; varname: string);
      procedure AttachToCheckBox( chko: TCheckBox; regobj: TMyRegistryNodeObject; varname: string);
    private
      function fGetEnable: boolean;
      procedure fSetEnable(b: boolean);
      procedure fOnTimer(Sender: TObject);
    public
      property RefreshEnabled: boolean read fGetEnable write fSetEnable;
   end;




Var
  InterfaceHelper: TInterfaceHelper;
  IfaceControlRegistry: TMyRegistryNodeObject;



implementation




constructor TCTrlObjAncestor.Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
begin
  inherited Create;
  fCtrl := xctrlobj;
  fRegobj := xregobj;
  fVarname := xvarname;
  //history := TStringList.Create;
end;

destructor TCTrlObjAncestor.Destroy;
begin
  //  MyDestroyAndNil( history );
  inherited;
end;



procedure TCTrlObjAncestor.SetDefaultValue;
begin
  fSetValueReg( fGetDefValueReg );
  SyncFromRegistry;
end;


procedure TCTrlObjAncestor.SyncFromRegistry;
begin
  //todo lock
  fSetValueObj( fGetValueReg );
  fSetObjHint( fGetHintStrReg );
end;


procedure TCTrlObjAncestor.StoreConf; //not virtual!
Var
  s: string;
begin
  s := fPackObjConfToStr;
  fSetConfigStrReg(s);
end;


procedure TCTrlObjAncestor.RestoreConf; //not virtual!
begin
  //todo lock
  fUnpackObjConfFromStr( fGetConfigStrReg );
end;


procedure TCTrlObjAncestor.BeginChanges;
begin
end;

procedure TCTrlObjAncestor.CommitChanges;
begin
  fSetValueReg( fGetValueObj );
end;

procedure TCTrlObjAncestor.CancelChanges;
begin
  SyncFromRegistry;
end;

procedure TCTrlObjAncestor.fOnClick(Sender: TObject);  //default: nothing //TNotifyEvent;
begin
end;

procedure TCTrlObjAncestor.fOnChange(Sender: TObject);   //default: nothing //TNotifyEvent;
begin
end;

procedure TCTrlObjAncestor.fOnKeyPress(Sender: TObject; var Key: Char);   //default: nothing//TKeyPressEvent;
begin
end;



function TCTrlObjAncestor.fGetParentFrm: TCustomForm;
begin
  Result := nil;
  if fCtrl=nil then exit;
  Result := GetParentForm (  fCtrl );
end;


function TCTrlObjAncestor.fGetDefValueReg: string;
begin
  Result := 'NULL';
  if fRegobj=nil then exit;
  Result := fRegObj.valStr[ fVarName + CSuffixDdefaultVal ];
end;

procedure TCTrlObjAncestor.fSetDefValueReg(s: string);   //not virtual!
begin
  if fRegobj=nil then exit;
  fRegObj.valStr[ fVarName + CSuffixDdefaultVal ] := s ;
end;

function TCTrlObjAncestor.fGetHintStrReg: string;   //not virtual!
begin
  Result := 'NULL';
  if fRegobj=nil then exit;
  Result := fRegObj.valStr[ fVarName + CSuffixHintStr ];
end;


function TCTrlObjAncestor.fGetValueReg: string;
begin
  Result := 'NULL';
  if fRegobj=nil then exit;
  Result := fRegObj.valStr[ fVarName ];
end;

procedure TCTrlObjAncestor.fSetValueReg(s: string);
begin
  if fRegobj=nil then exit;
  fRegObj.valStr[ fVarName ] := s;
end;


function TCTrlObjAncestor.fGetHistoryStrReg: string;      //not virtual!
begin
  Result := '';
  if fRegobj=nil then exit;
  Result := fRegObj.valStr[ fVarName + CSuffixHistoryStr ];
end;

procedure TCTrlObjAncestor.fSetHistoryStrReg(s: string);  //not virtual!
begin
  if fRegobj=nil then exit;
  fRegObj.valStr[ fVarName + CSuffixHistoryStr ] := s;
end;


function TCTrlObjAncestor.fGetConfigStrReg: string;      //not virtual!
begin
  Result := '';
  if fRegobj=nil then exit;
  Result := fRegObj.valStr[ fVarName + CSuffixConfigStr ];
end;


procedure TCTrlObjAncestor.fSetConfigStrReg(s: string);  //not virtual!
begin
  if fRegobj=nil then exit;
  fRegObj.valStr[ fVarName + CSuffixConfigStr ] := s;
end;







//----------EDIT



constructor TCTrlObjRecEDIT.Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
begin
  inherited Create(xctrlobj, xregobj, xvarname);           //constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
  if xctrlobj is TEdit then
    begin
     fCtrl := xctrlobj;
     fEditObj := TEdit( fCtrl );
    end
  else fCtrl := nil;
end;



destructor TCTrlObjRecEDIT.Destroy;
begin
  inherited;
end;


procedure TCTrlObjRecEDIT.Refresh;
begin
  lock;
  try
    if fEditObj=nil then exit;
    if EditInProgress then
      begin
       fEditObj.Color := clYellow;
       //do not change value
      end
    else
      begin
        fEditObj.Color := clWhite;
        SyncFromRegistry;
      end;
  finally
    unlock;
  end;
end;



function TCTrlObjRecEDIT.fGetValueObj: string;
begin
  Result := 'NULL';
  if fCtrl=nil then exit;
  Result := TEdit(fCtrl).Text;
end;


procedure TCTrlObjRecEDIT.fSetValueObj(s: string);
begin
  if fCtrl=nil then exit;
  TEdit(fCtrl).Text := s;
end;



function TCTrlObjRecEDIT.fPackObjConfToStr: string;
begin
  Result := '';  //TODO
end;

procedure TCTrlObjRecEDIT.fUnpackObjConfFromStr(s: string);
begin
  //TODO
end;


procedure TCTrlObjRecEDIT.fSetObjHint(s: string);
begin
  if fEditObj=nil then exit;
  fEditObj.Hint := s;
end;



procedure TCTrlObjRecEDIT.fOnClick(Sender: TObject);  //EditInProgress
begin
  BeginChanges;
end;


//procedure fOnChange(Sender: TObject); override;   //default: nothing //TNotifyEvent;

procedure TCTrlObjRecEDIT.fOnKeyPress(Sender: TObject; var Key: Char);   //default: nothing//TKeyPressEvent;
begin
  if (Sender<>nil) then
    begin
      BeginChanges;
      case Key of
         #13: CommitChanges;
         #27: CancelChanges;
      end;
    end;
end;




procedure TCTrlObjRecEDIT.BeginChanges;   //default: nothing
begin
  lock;
  try
    EditInProgress := true;
  finally
    unlock;
  end;
end;


procedure TCTrlObjRecEDIT.CommitChanges;                //EditInProgress
begin
  lock;
  try
    fSetValueReg( fgetValueObj);
    EditInProgress := false;
  finally
    unlock;
  end;
end;

procedure TCTrlObjRecEDIT.CancelChanges;  //default: replace value from data in reg
begin
  lock;
  try
    SyncFromRegistry;
    EditInProgress := false;
  finally
    unlock;
  end;
end;




// ----- CHEKCBOX



constructor TCTrlObjCheckbox.Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
begin
  inherited Create(xctrlobj, xregobj, xvarname);           //constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
  if xctrlobj is TCheckBox then
    begin
     fCtrl := xctrlobj;
     fChkObj := TCheckBox( xctrlobj );
    end
  else fCtrl := nil;
end;

destructor TCTrlObjCheckbox.Destroy;
begin
  inherited;
end;

procedure TCTrlObjCheckbox.Refresh;
begin
  lock;
  try
    begin
      if fChkObj=nil then exit;
      SyncFromRegistry;
    end;
  finally
    unlock;
  end;
end;



procedure TCTrlObjCheckbox.fOnClick(Sender: TObject);  //EditInProgress
begin
  lock;
  try
    fSetValueReg( fgetValueObj);
  finally
    unlock;
  end;
end;


procedure TCTrlObjCheckbox.fOnKeyPress(Sender: TObject; var Key: Char);   //default: nothing //TNotifyEvent;
begin
  lock;
  try
    fSetValueReg( fgetValueObj);
  finally
    unlock;
  end;
end;

function TCTrlObjCheckbox.fGetValueObj: string;
begin
  if fCtrl=nil then exit;
  Result := MVBoolToStr( TCheckBox(fCtrl).Checked );
end;

procedure TCTrlObjCheckbox.fSetValueObj(s: string);
begin
  if fCtrl=nil then exit;
  TCheckBox(fCtrl).Checked := MVStrToBool(s);
end;

procedure TCTrlObjCheckbox.fSetObjHint(s: string);
begin
  if fCtrl=nil then exit;
  TCheckBox(fCtrl).Hint := s;
end;








//----- LABEL


constructor TCTrlObjLABEL.Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
begin
  inherited Create(xctrlobj, xregobj, xvarname);           //constructor Create( xctrlobj: TControl; xregobj: TMyRegistryNodeObject; xvarname: string);
  if xctrlobj is TLabel then
    begin
     fCtrl := xctrlobj;
     fLabelObj := TLabel( fCtrl );
    end
  else fCtrl := nil;
end;

destructor TCTrlObjLABEL.Destroy;
begin
  inherited;
end;



procedure TCTrlObjLABEL.Refresh;
begin
  lock;
  try
    if fLabelObj=nil then exit;
    SyncFromRegistry;
  finally
    unlock;
  end;
end;

function TCTrlObjLABEL.fGetValueObj: string;
begin
  Result := 'NULL';
  if fCtrl=nil then exit;
  Result := TEdit(fCtrl).Text;
end;


procedure TCTrlObjLABEL.fSetValueObj(s: string);
begin
  if fCtrl=nil then exit;
  TEdit(fCtrl).Text := s;
end;


function TCTrlObjLABEL.fPackObjConfToStr: string;
begin
  Result := '';  //TODO
end;

procedure TCTrlObjLABEL.fUnpackObjConfFromStr(s: string);
begin
  //TODO
end;


procedure TCTrlObjLABEL.fSetObjHint(s: string);
begin
  if fLabelObj=nil then exit;
  fLabelObj.Hint := s;
end;





//----------------------



constructor TInterfaceHelper.Create;
begin
  inherited;
  fRefreshLock := TMyLockableObject.Create;
  ctrllist := TStringList.Create;
  fTimer := TTimer.Create(nil);
  fTimer.Interval := 500;
  fTimer.Enabled := false;
  fTimer.OnTimer := fOnTimer;
end;


destructor TInterfaceHelper.Destroy;
Var
 i: integer;
 o: TObject;
begin
  inherited;
  //empty ctrllist objects !!!!
  //EmptyCtrllist;
  if ctrllist<>nil then
    begin
     for i:=0 to ctrllist.Count-1 do
       begin
         o := ctrllist.objects[i];
         if o<>nil then o.Destroy;
         ctrllist.Objects[i] := nil;
       end;
    end;
  MyDestroyAndNil( fTimer );
  MyDestroyAndNil( ctrllist );
  MyDestroyAndNil( fRefreshLock );
end;


procedure TInterfaceHelper.RefreshControls;
Var
  i, n: integer;
  o: TCTrlObjRecEDIT;
  lastt: boolean;
begin
  if (fRefreshLock=nil)  then  exit;
  try
    fRefreshLock.Lock;
    if (ctrllist=nil) or (fTimer=nil) then exit;
    lastt := fTimer.Enabled;
    fTimer.Enabled := false;
    //
    n := ctrllist.Count;
    for i:= 0 to n-1 do
      begin
        o := TCTrlObjRecEDIT( ctrllist.Objects[i] );
        if o<>nil then o.Refresh;
      end;
    fTimer.Enabled := lastt;
  finally
    fRefreshLock.Unlock;
  end;
end;


function TInterfaceHelper.FindControlByObjectPTR( ptr: TObject): TCTrlObjAncestor;
Var
 s: string;
 i: integer;
begin
  Result := nil;
  if ctrllist=nil then exit;
  fRefreshLock.Lock;
  try
    s := PointerToStr( ptr );
    i := ctrllist.IndexOf(s);
    if i>=0 then Result := TCTrlObjAncestor( ctrllist.objects[i] );
  finally
    fRefreshLock.Unlock;
  end;
end;



procedure TInterfaceHelper.RestoreOrCreateSmartEditBox;
Var
 s: string;
 i: integer;
begin
  if ctrllist=nil then exit;
  fRefreshLock.Lock;
  try
    //s := PointerToStr( ptr );
    //i := ctrllist.IndexOf(s);
    // i>=0 then Result := TCTrlObjRecEDIT( ctrllist.objects[i] );
  finally
    fRefreshLock.Unlock;
  end;
end;




procedure TInterfaceHelper.AssignControl( ctrlobj: TControl; regobj: TMyRegistryNodeObject; varname: string);
begin
  if ctrlobj is TEdit then
      AttachToEdit( TEdit(ctrlobj), regobj, varname);
  if ctrlobj is TLabel then
      AttachToLabel( TLabel(ctrlobj), regobj, varname);
  if ctrlobj is TCheckBox then
     AttachToCheckBox( TCheckBox(ctrlobj), regobj, varname);
end;

procedure TInterfaceHelper.AssignControl( eobj: TEdit; regobj: TMyRegistryNodeObject; varname: string; defval:string; hint: string);
Var
  oe: TCTrlObjRecEDIT;
begin
  AttachToEdit( eobj, regobj, varname);
  oe := TCTrlObjRecEDIT( FindControlByObjectPTR( eobj ) );
  if oe=nil then exit;
  //oe.fSetDefValueReg( defval );
  oe.fSetObjHint( hint );
end;

procedure TInterfaceHelper.AssignControl( eobj: TCheckBox; regobj: TMyRegistryNodeObject; varname: string; defval:string; hint: string);
Var
  oe: TCTrlObjCheckbox;
begin
  AttachToCheckBox( eobj, regobj, varname);
  oe := TCTrlObjCheckbox( FindControlByObjectPTR( eobj ) );
  if oe=nil then exit;
  //oe.fSetDefValueReg( defval );
  //oe.fSetObjHint( hint );
end;



procedure TInterfaceHelper.AttachToEdit( editobj: TEdit; regobj: TMyRegistryNodeObject; varname: string);
Var
  oe: TCTrlObjRecEDIT;
  strptr: string;
begin
  //!!! fisrt should look if not already hooked
  oe := TCTrlObjRecEDIT.Create( editobj, regobj, varname );
  if oe=nil then exit;
  strptr := PointerToStr( editobj );
  ctrllist.AddObject( strptr, oe );            //TObjectList
  editobj.OnClick := fOnClick;
  editobj.OnChange := fOnChange;
  editobj.OnKeyPress := fOnKeyPress;   //check hitting enter
  //oe.SetDefaultValue;
  oe.SyncFromRegistry;
  oe.Refresh;
end;



procedure TInterfaceHelper.AttachToCheckBox( chko: TCheckBox; regobj: TMyRegistryNodeObject; varname: string);
Var
  oe: TCTrlObjCheckbox;
  strptr: string;
begin
  oe := TCTrlObjCheckbox.Create( chko, regobj, varname );
  if oe=nil then exit;
  strptr := PointerToStr( chko );
  ctrllist.AddObject( strptr, oe );            //TObjectList
  //
  chko.OnClick := fOnClick;
  chko.OnKeyPress := fOnKeyPress;
  //
  //oe.SetDefaultValue;
  oe.SyncFromRegistry;
  oe.Refresh;
end;


procedure TInterfaceHelper.AttachToLabel( labelo: TLabel; regobj: TMyRegistryNodeObject; varname: string);
Var
  oe: TCTrlObjLABEL;
  strptr: string;
begin
  oe := TCTrlObjLABEL.Create( labelo, regobj, varname );
  if oe=nil then exit;
  strptr := PointerToStr( labelo );
  ctrllist.AddObject( strptr, oe );            //TObjectList
  oe.SetDefaultValue;
  oe.SyncFromRegistry;
  oe.Refresh;
end;




procedure TInterfaceHelper.fOnClick(Sender: TObject); //TNotifyEvent;
Var
  o: TCTrlObjAncestor;
begin
  o := FindControlByObjectPTR(Sender);
  if o=nil then exit;
  o.fOnClick( Sender );
  RunAfterUserAction( o );
end;


procedure TInterfaceHelper.fOnChange(Sender: TObject); //TNotifyEvent;
Var
  o: TCTrlObjAncestor;
begin
  o := FindControlByObjectPTR(Sender);
  if o=nil then exit;
  o.fOnChange( Sender );
  flastchangeDT := Now;
end;


procedure TInterfaceHelper.fOnKeyPress(Sender: TObject; var Key: Char); //TNotifyEvent;
Var
  o: TCTrlObjAncestor;
begin
  o := FindControlByObjectPTR(Sender);
  if o=nil then exit;
  o.fOnKeyPress( Sender, Key );
  //
  //if (Key = #13) and (o<>nil) then o.CommitChange;
end;


procedure TInterfaceHelper.RunAfterUserAction( ctrlo: TCTrlObjAncestor );  //e.g. check if display SmartEditBox for TEdits
Var
  o: TCTrlObjAncestor;
begin
  if ctrlo=nil then exit;
  if ctrlo is TCTrlObjRecEDIT then
    begin
      RestoreOrCreateSmartEditBox(); //TODO  ctrlo
    end;
end;




function TInterfaceHelper.fGetEnable: boolean;
begin
  Result := false;
  if fTimer=nil then exit;
  Result := fTimer.Enabled;
end;


procedure TInterfaceHelper.fSetEnable(b: boolean);
begin
  if fTimer=nil then exit;
  fTimer.Enabled := true;
end;


procedure TInterfaceHelper.fOnTimer(Sender: TObject);
begin
  RefreshControls;
end;





//  TCtrlObjGroup. = class (TObject)
constructor TCtrlObjGroup.Create;
begin
  inherited;
  fList := TObjectList.Create;
end;

destructor TCtrlObjGroup.Destroy;
Var
 i: integer;
 o: TObject;
begin
  inherited;
  //empty ctrllist objects !!!!
  //EmptyCtrllist;
  if fList<>nil then
    begin
     for i:=0 to fList.Count-1 do
       begin
         o := fList[i];
         if o<>nil then o.Destroy;
         fList[i] := nil;
       end;
    end;
  MyDestroyAndNil( fList );
end;


procedure TCtrlObjGroup.AddCtrlObj( ctrlo: TCTrlObjAncestor );
begin
  if fList=nil then exit;
  fList.Add( ctrlo );
end;


procedure TCtrlObjGroup.CommitChanges;
Var
 i: integer;
 o: TCTrlObjAncestor;
begin
  if fList=nil then exit;
  for i:=0 to fList.Count-1 do
    begin
         o := TCTrlObjAncestor( fList[i] );
         if o<>nil then o.CommitChanges;
    end;
end;


procedure TCtrlObjGroup.CancelChanges;
Var
 i: integer;
 o: TCTrlObjAncestor;
begin
  if fList=nil then exit;
  for i:=0 to fList.Count-1 do
    begin
         o := TCTrlObjAncestor( fList[i] );
         if o<>nil then o.CancelChanges;
    end;
end;


procedure TCtrlObjGroup.SetDefault;
Var
 i: integer;
 o: TCTrlObjAncestor;
begin
  if fList=nil then exit;
  for i:=0 to fList.Count-1 do
    begin
         o := TCTrlObjAncestor( fList[i] );
         if o<>nil then o.SetDefaultValue;
    end;
end;
















initialization

  InterfaceHelper :=  TInterfaceHelper.Create;
  InterfaceHelper.RefreshEnabled := true;

  IfaceControlRegistry := TMyRegistryNodeObject.Create('InterfaceHleper');

finalization

  MyDestroyAndNil( InterfaceHelper );
  MyDestroyAndNil( IfaceControlRegistry );

end.

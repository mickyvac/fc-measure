unit MyLockableObject;

interface

Uses Sysutils;

type

  TLogProcedureThreadSafe = procedure(s: string) of object;
  TLogProcedureThreadSafeLevel = procedure(s: string; lvl: byte) of object;

  TMyLockableObject = class     //should be thread safe
    //the TMultiReadExclusiveWriteSynchroniser reaaaly f**cks me, I hate the program freezes with it and also that
     //i cannot check the state of the lock !!!!!
     //and so here I provide lockwith timeout - so if not possible to otain lock, at least fail!!!! and RETURN
  public
    constructor Create( timeoutMS: longint);     //timeout - if cannot obtain lock for long time, assume it is OK and continue as if lock obtained
    destructor Destroy; override;
    function LockTimeout(toutMS: longint): boolean; overload;
    function LockTimeout(Var didlock: boolean; toutMS: longint): boolean; overload;  //if lock was set to true, set didlock variable - then use it simply in the unlock
    procedure Lock;
    procedure Unlock; overload;
    procedure Unlock(didlock: boolean); overload;  //if didlock = false, will not cleare the lock, because someone else locked it
    procedure BeginWrite; //remap
    procedure EndWrite;
    procedure BeginRead;
    procedure EndRead;
  private
    fLock: boolean;
    fDefTimeoutMS: longint;
    fExlusLock: TMultiReadExclusiveWriteSynchronizer;
  public
    property IsLocked: boolean read fLock;
  end;


implementation

uses myutils;

constructor TMyLockableObject.Create( timeoutMS: longint);
begin
  fExlusLock := TMultiReadExclusiveWriteSynchronizer.Create;
  fDefTimeoutMS := timeoutMS;
  fLock := false;
end;

destructor TMyLockableObject.Destroy;
begin
  fExlusLock.Destroy;
  inherited;
end;


function TMyLockableObject.LockTimeout(Var didlock: boolean; toutMS: longint): boolean;  //if lock was set to true, set didlock variable - then use it simply in the unlock
Var
  t0: longword;
begin
  Result := false;
  didlock := false;
  t0 := TimeDeltaTICKgetT0;
  while fLock and (TimeDeltaTICKNowMS(t0)< toutMS) do
    begin
      //MyProcessMessages; //TODO!!!!!!!!  IS IT NECESSARY!!!!!!!??????
    end;
  if fLock then exit;
  fExlusLock.BeginWrite;
    if not flock then
      begin
        fLock := true;
        didlock := true;
        Result := true;
      end;
  fExlusLock.EndWrite;
end;

function TMyLockableObject.LockTimeout(toutMS: longint): boolean;
Var
  b: boolean;
begin
  Result := LockTimeout(b, toutMS);
end;


procedure TMyLockableObject.Lock;
begin
  LockTimeout(fDefTimeoutMS);
end;


procedure TMyLockableObject.Unlock;

begin
  fLock := false;
end;


procedure TMyLockableObject.Unlock(didlock: boolean);
//if didlock = false, will not cleare the lock, because someone else locked it
begin
  if not didlock then exit;
  fExlusLock.BeginWrite;
    fLock := false;
  fExlusLock.EndWrite;
end;


procedure TMyLockableObject.BeginWrite; //remap
begin
  Lock;
end;

procedure TMyLockableObject.EndWrite;
begin
  UnLock;
end;

procedure TMyLockableObject.BeginRead;
begin
  Lock;
end;

procedure TMyLockableObject.EndRead;
begin
  UnLock;
end;

end.

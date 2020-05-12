unit MyAquireThread_TCPIPKolServer;

{$IFDEF FPC}  //for compatibility between delphi  and lazarus
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs, ExtCtrls, Graphics,
  myutils, MyParseUtils, Logger, LoggerThreadSafe, ConfigManager, MVConversion, FormGLobalConfig,
  HWAbstractDevicesNew2, MyAquireThreadNEW_TCPIP, MyTCPClientForKolServer,
  MyTCPClient_indy, MVvariant_DataObjects, MyThreadUtils; //MyAquireThreadPrototype,

Type

  //flow commands

  TSynchroMethod = procedure of object;

  {
  TCmdObj = class (TObject)
  public
    constructor Create;
    destructor Destroy; override;
  public
      fUserCmdReplyS: string;           //user command
      fUserCmdReplyTime: TDateTime;
      fUserCmdReplyIsNew: boolean;
      fLastCycleInsideMS: longint;
  end;
  }

  TAquireThread_KolServer_TCPIP = class (TObject)
    //this obejct tskes care of aquiring data from defined objects ID form a Kolibrik Server
    //(XCT communication protocol)
    //there is also a "command queue" in the form of  stringlist of text commands
    public
      constructor Create( log: TMyLoggerThreadSafe);
      destructor Destroy; override;
    public
      procedure RunAcquire;
      procedure StopAcquire;
    public
      procedure AddAcquireObject(name: string);
      procedure AddAcquireObjectList(sl: TStringList);
      procedure ClearAcquireObjects;
    public
      procedure AddCommand(cmd: string);
      procedure ClearCommandsQueue;
    private
      fDataRegistry: TMyRegistryNodeObject;   //stores data and status - access methods are THREADSAFE!!!
      function getDataByName(n: string): TRegistryItem;
    private
      fReady: TMVVariantThreadSafe;
      function getReady: boolean;
      function getRunning: boolean;
    public
      property Data[id: string]: TRegistryItem read getDataByName;
      property IsReady: boolean read GetReady;
      property IsRunning: boolean read GetRunning;

    public
      procedure setTCPconf( server: string; port: string; ProtocolVer: integer);    //called from main thread, must not block
      procedure getTCPconf( Var server: string; Var port: string; Var ProtocolVer: integer ); //called from main thread, must not block
      procedure ResetConnection;
      function isThreadRunning(): boolean;
      function getThreadStatus: string;
      procedure ForceClientClose; //this is called from main thread - emergency close - will not check criticial section
      function isClientConnected(): boolean;
    protected
      fLog:  TMyLoggerThreadSafe;
      procedure fLogMsg(a: string);   //in order to do it THREAD SAFE. must call logmsg using Synchronize!!!!!!
    protected
      //aquire thread and objects
      fAcquireObjects: TMVStringListThreadSafe;
      fCommandQueue: TMVStringListThreadSafe;
      procedure ManualAquire;
      procedure ManualProcessCmd;
    private
      fDebug: boolean;
      procedure setDebug(b: boolean);
    public
      property Debug: boolean read fDebug write setDebug;

    private
      //helper
      fAcquireNamesList: TStringList;
      fAcquireNamesListTS: TDateTime;
      fReplylist: TStringList;
      fCmdstrlist: TStringList;
    private
      fDoingInit: TMVVariantThreadSafe;
      fLastAquireTS: TRegistryItem;  //just ref - do not create, do not destroy
      fLastElapsedMS: TRegistryItem;  //just ref - do not create, do not destroy
    private
      //thread control
      fAquireThread: TAquireThreadV2_TCPIP; //TAquireThreadBaseV2;
      fTargetCycleTimeMS: longword;
      procedure fMyExecute; //TMyExecuteMethod
      procedure fMyOnClientStatusChange;  //runs by thread after e.g. connection open
      procedure ThreadStart;
      procedure ThreadStop;
      procedure genAcquireList;
    protected
      //commucation and status display
      fTCPclient: TMyTCPClientForKolServer;
    private
      procedure AfterClientStatusChange(nstate: TMyClientState; statusstr: string); //updates reported status - connecting/disconnected etc. - will use datasynchro
  end;



Var
  IDdoingInit: string = '_DoingInit';
  IdLastAquireTS: string = '_LastAquireTimeStamp';
  IdLastElapsedMS: string = '_LastAquireElapsedMS';
  IdAnswerLowLevel: string = '_AnswerLowLevel';       //for use with user cmd - answer to last USER cmd - in raw as received
  IdCLientState: string = '_CLientState';
  IdCLientStatusStr: string =  '_CLientStatusStr';
  IdInterfaceReady: string = '_InterfaceReady';


//---------------------------------------
//helper, conversion functions


Implementation

uses Math, Windows, Forms, MyAquireThreadPrototype, MyAquireThreadNEW,
  Controls;



constructor TAquireThread_KolServer_TCPIP.Create( log: TMyLoggerThreadSafe);
begin
  inherited Create;
  fLog := log;
  //
  fAcquireObjects := TMVStringListThreadSafe.Create;
  fCommandQueue := TMVStringListThreadSafe.Create;
  fAcquireNamesList := TStringlist.Create;
  fReplylist := TStringlist.Create;
  fCmdstrlist := TStringlist.Create;
  fAcquireNamesListTS := 0;
  //
  fDataRegistry := TMyRegistryNodeObject.Create('DataAndStatus');
  fLastAquireTS := fDataRegistry.GetOrCreateItem( IdLastAquireTS );
  fLastElapsedMS := fDataRegistry.GetOrCreateItem( IdLastElapsedMS );
  fDataRegistry.GetOrCreateItem( IdCLientState );
  fDataRegistry.GetOrCreateItem( IdCLientStatusStr );
  fDataRegistry.GetOrCreateItem( IdInterfaceReady );

  //tcp client
  fTCPclient :=  TMyTCPClientForKolServer.Create;
  if fTCPclient<>nil then
    begin
      fTCPClient.AssignLogProc( fLogMsg );
      fTCPClient.AssignOnStatusChange( AfterClientStatusChange );
    end;
  //thread
  fAquireThread := TAquireThreadV2_TCPIP.Create( fMyExecute, TMyTCPClientThreadSafe(fTCPclient), fMyOnClientStatusChange );
  if fAquireThread<>nil then
    begin
      fAquireThread.SetUserSuspend;
      fAquireThread.Resume;
    end;
  //
  //
  fReady := TMVVariantThreadSafe.Create(false);
  fDoingInit := TMVVariantThreadSafe.Create( 0 );  //number of retries
  //
  fTargetCycleTimeMS := 300;
  //
  logmsg('TFlowControlFCS_TCPIP.Create: done.');
  fLogMsg('TFlowControlFCS_TCPIP.Create: done.');
end;


destructor TAquireThread_KolServer_TCPIP.Destroy;

begin
  if fAquireThread<> nil then
    begin
      fAquireThread.TerminateAndWaitForExecuteFinish;
      fAquireThread.Free;
    end;
  if fTCPclient<>nil then fTCPclient.Close;
  fTCPclient.Destroy;
  //
  fAcquireObjects.Destroy;
  fCommandQueue.Destroy;
  fAcquireNamesList.Destroy;
  fReplylist.Destroy;
  fCmdstrlist.Destroy;
  fDataRegistry.Destroy;
  //
  fDoingInit.Destroy;
  fReady.Destroy;
  //
  inherited;
end;



procedure TAquireThread_KolServer_TCPIP.AddAcquireObject(name: string);
begin
  if fAcquireObjects = nil then exit;
  fAcquireObjects.Add(name);
end;


procedure TAquireThread_KolServer_TCPIP.AddAcquireObjectList(sl: TStringList);
begin
  if fAcquireObjects = nil then exit;
  fAcquireObjects.AddStrings(sl);
end;

procedure TAquireThread_KolServer_TCPIP.ClearAcquireObjects;
begin
  if fAcquireObjects = nil then exit;
  fAcquireObjects.Clear;
end;




procedure TAquireThread_KolServer_TCPIP.AddCommand(cmd: string);
begin
  if fCommandQueue=nil then exit;
  if fDebug then logmsg('TAquireThread_KolServer_TCPIP.AddCommand: ' + BinaryStrTostring(cmd) );
  fCommandQueue.Add( cmd );
end;



procedure TAquireThread_KolServer_TCPIP.ClearCommandsQueue;
begin
  if fCommandQueue=nil then exit;
  fCommandQueue.Clear;
end;



function TAquireThread_KolServer_TCPIP.getDataByName(n: string): TRegistryItem;
Var
 ri: TRegistryItem;
begin
  Result := _NullRegistryItem;
  if fDataRegistry = nil then exit;
  ri := fDataRegistry.ItemExists(n);
  if ri<>nil then Result := ri;
end;

function TAquireThread_KolServer_TCPIP.getReady: boolean;
begin
  Result := false;
  if fReady = nil then exit;
  Result := fReady.valBool;
end;

function TAquireThread_KolServer_TCPIP.getRunning: boolean;
begin
  Result := false;
  if fAquireThread = nil then exit;
  Result := fAquireThread.IsThreadRunning;
end;



//**************
//basic control functions
//---------------------

procedure TAquireThread_KolServer_TCPIP.RunAcquire;
begin
  if fReady = nil then exit;
  if fAquireThread = nil then exit;
  if  fTCPclient = nil then exit;
  //
  if not fTCPclient.IsConfigured then exit;
  fReady.valBool := false;
  fAquireThread.OpenTCP;
  fDoingInit.valInt := 3;  //number of retrie to connect
  ThreadStart;
  //fready IS NOT SET HERE - at is set in the aquire thread after succesfull connection !!!!;
  fLogMsg('TAquireThread_KolServer_TCPIP.RunAcquire: done');
end;


procedure TAquireThread_KolServer_TCPIP.StopAcquire;
begin
  fLogMsg('TAquireThread_KolServer_TCPIP.StopAcquire: start');
  fAquireThread.CloseTCP;
  ThreadStop;
  fReady.valBool := false;
  fDoingInit.valInt := 0;
  ForceClientClose;  //will force close even during openingn in progress (calls fTCPclient.Close)
end;




procedure TAquireThread_KolServer_TCPIP.ResetConnection;
//close port, open port - this should help it seems
begin
  logmsg('TAquireThread_KolServer_TCPIP.ResetConnection: Closing and opening PORT!!!' );
  fAquireThread.ResetConnection;
end;




procedure TAquireThread_KolServer_TCPIP.genAcquireList;
Var
  i, n: longint;
  needupdate: boolean;
begin
  if fAcquireObjects=nil then exit;
  needupdate := fAcquireNamesListTS < fAcquireObjects.LastModified;
  if needupdate then
        begin
          fAcquireNamesList.Clear;
          fAcquireObjects.GetCopyStrList( fAcquireNamesList );
          fAcquireNamesListTS := Now;
        end;
end;


procedure TAquireThread_KolServer_TCPIP.fMyExecute; //TMyExecuteMethod
Var
  b, conOK: boolean;
  t0, t, dt: longword;
begin
  if (fDoingInit=nil) or (fReady=nil) then
      begin
        fLogMsg('Some of "synchro" objects is NIL - sleep 10sec and retry');
        exit;
      end;
    //check if iface became ready after init was called
  if fDoingInit.valBool and (not fready.valBool) then
    begin
      conOK := false;
      if fTCPclient.IsReady then conOK := fTCPclient.VerifyConnectionToServer;
      fready.valBool := conOK;
      fDoingInit.valInt := fDoingInit.valInt - 1;
    end
  else if fReady.valBool then
    begin
      if not fTCPclient.IsReady then fReady.valBool := false;
    end;

    if not fready.valBool then exit;
    //
   t0 := TimeDeltaTICKgetT0;
   //
   ManualAquire;
   t := TimeDeltaTICKgetT0;
   ManualProcessCmd;
    //
    //
    dt := TimeDeltaTICKNowMS( t0 );
    if fLastElapsedMS<>nil then fLastElapsedMS.valInt := dt;
    if fDebug then fLogMsg('  finished in ms: ' + IntToStr(dt) + ' ... target cycle is ' + IntToStr(fTargetCycleTimeMS) );
    //
    if dt<(fTargetCycleTimeMS-20) then sleep(fTargetCycleTimeMS-dt);
end;

procedure TAquireThread_KolServer_TCPIP.ManualAquire;

Var
  n, m: byte;
  w: word;
  i, k, fdid: longint;
  b: boolean;
  //replylist: Tstringlist;
  //frec: TFlowRec;
  name, val: string;
  ri: TRegistryItem;
begin
    if (fAcquireNamesList=nil) or (fDataRegistry=nil) or (fReady=nil) or (fTCPclient=nil) then
      begin
        fLogMsg('Some of "synchro" objects is NIL - exit');
        exit;
      end;
   if not fready.valBool then exit;
   //replylist := TStringList.Create;
   fReplylist.Clear;
   genAcquireList;    //verify and update faquireNameslist
    //
    n := fAcquireNamesList.Count;
    if n>0 then
      begin
         b := fTCPclient.QueryGetVariables(fAcquireNamesList, fReplylist);
         if b then
           begin
             for i:=0 to n-1 do
               begin
                 //store reply into dataregistry
                 //assuming replylist has format of name=value
                 name := freplylist.Names[i]; //name := fAquireNameList.Strings[i];
                 val := freplylist.ValueFromIndex[i];
                 //xval.valDouble := val;
                 ri := fDataRegistry.GetOrCreateItem(name); //xval
                 if ri<>nil then ri.SetData( val );
               end;
             if fLastAquireTS<>nil then  fLastAquireTS.valDouble := Now();
           end;
      end;
    //
    //replylist.Destroy;
    if fLastAquireTS<>nil then  fLastAquireTS.valDouble := Now();
end;




procedure TAquireThread_KolServer_TCPIP.ManualProcessCmd;

Var
  n: byte;
  w: word;
  i, k: longint;
  b: boolean;
  t0, t, dt: longword;
  //cmdstrlist, replylist: Tstringlist;
begin
    if (fCommandQueue=nil) or (fDataRegistry=nil) or (fReady=nil) then
      begin
        fLogMsg('Some of "synchro" objects is NIL - exit');
        exit;
      end;
   if not fready.valBool then exit;
   //replylist := TStringList.Create;
   //cmdstrlist := TStringList.Create;
   fReplylist.Clear;
   fCmdstrlist.Clear;
    //
   fCommandQueue.GetCopyStrList(fcmdstrlist);
   fCommandQueue.Clear;

   if fcmdstrlist.Count>0 then b := fTCPclient.QueryDoCommands(fCmdstrlist, fReplylist);
   //
   //cmdstrlist.Destroy;
   //replylist.Destroy;
end;



procedure TAquireThread_KolServer_TCPIP.setDebug(b: boolean);
begin
  fDebug := b;
end;






procedure TAquireThread_KolServer_TCPIP.fMyOnClientStatusChange;
//runs by thread after e.g. connection open
//verifies conenction to server and if OK sets the READY! flag
Var
  conOK: boolean;
begin
  //check if client connected during init - then verify connection and if all ok , sets READY FLAG
 //fDataRegistry.valBool[ IdInterfaceReady ] := fready.valBool;
end;

procedure TAquireThread_KolServer_TCPIP.AfterClientStatusChange(nstate: TMyClientState; statusstr: string);
begin
  if fDataRegistry = nil then exit;
  //in this proc only update status - checking to switch interface ready is done
  //in the other function after signal from worker thread...
  fDataRegistry.valstr[ IdCLientState ] := ClientStateToStr( fTCPclient.ClientState );
  fDataRegistry.valstr[ IdCLientStatusStr ] := fTCPclient.ClientStateDescription;
end;




procedure TAquireThread_KolServer_TCPIP.setTCPconf( server: string; port: string; ProtocolVer: integer);    //called from main thread, must not block
begin
  if fAquireThread=nil then exit;
  fAquireThread.ConfigureTCP(server, port);
  fTCPclient.ProtocolVer := ProtocolVer;
end;

procedure TAquireThread_KolServer_TCPIP.getTCPConf( Var server: string; Var port: string; Var ProtocolVer: integer); //called from main thread, must not block
begin
  if fTCPclient=nil then exit;
  server := fTCPclient.ConfHost;
  port := fTCPclient.ConfPort;
  ProtocolVer := fTCPclient.ProtocolVer;
end;

procedure TAquireThread_KolServer_TCPIP.ForceClientClose; //this is called from main thread - emergency close - will not check criticial section
begin
  if fTCPclient=nil then exit;
  fTCPclient.CLose;
end;

function TAquireThread_KolServer_TCPIP.isClientConnected(): boolean;
begin
  Result := false;
  if fTCPclient=nil then exit;
  Result := fTCPClient.IsConnected;
end;


procedure TAquireThread_KolServer_TCPIP.ThreadStart;
begin
  if fAquireThread = nil then exit;
  logmsg('TAquireThread_KolServer_TCPIP.ThreadStart: calling RESUME');
  fAquireThread.ResetUserSuspend;
  fAquireThread.Resume;     //TThread  //in case it was suspended
end;


procedure TAquireThread_KolServer_TCPIP.ThreadStop;
begin
  if fAquireThread = nil then exit;
  logmsg('TAquireThread_KolServer_TCPIP.ThreadStart: calling SUSPEND');
  fAquireThread.SetUserSuspend;
end;


function TAquireThread_KolServer_TCPIP.IsThreadRunning(): boolean;
begin
  Result := false;
  if fAquireThread = nil then exit;
  Result := fAquireThread.IsThreadRunning;
end;

function TAquireThread_KolServer_TCPIP.getThreadStatus: string;
begin
  Result := 'NIL';
  if fAquireThread = nil then exit;
  Result := fAquireThread.getThreadStatusStr;
end;




procedure TAquireThread_KolServer_TCPIP.fLogMsg(a: string);
begin
  if flog=nil then exit;
  fLog.LogMsg(a);
end;

//****************************************************



end.

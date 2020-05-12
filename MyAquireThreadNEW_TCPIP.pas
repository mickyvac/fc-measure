unit MyAquireThreadNEW_TCPIP;

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, Logger, ConfigManager, MyThreadUtils,
  MyTCPClient_indy,  sockets, loggerThreadsafe,    //MyLockableObject
  MyAquireThreadNEW;


type

  TMyExecuteMethod = procedure of object;

  TAquireThreadV2_TCPIP = class (TAquireThreadBaseV2)       //TMultiReadExclusiveWriteSynchronizer
  //!!!!!NOTE!!!!
  //redefine override execute - now does also PROCESS CONFIGURATION REQUEST ON TCPCLIENT,
  //especially handles OPEN connection, which may BLOCK!!!!!
  //code that wants to use some TCPIP client should remap all opening to this thred object
  //create takes reference to TCPIP client base class (only does open, close, updatehost...)!!!!!!
    public
      constructor Create( UserExecute: TMyExecuteMethod; client: TMyTCPClientThreadSafe; OnCLiStatChange: TMyExecuteMethod);
      destructor Destroy; override;
      procedure ProcessConfigurationRequests; override;//helper - here - handles tasks with tcpclient from within the thread (although tcpclient is creatred externaly)
                                    //OVERRIDES PREVIOS version!!!! - need to add check for process cofiguration
    public
      //notably inherited
      //procedure SetUserSuspend;
      //procedure ResetUserSuspend;
      // procedure TerminateAndWaitForExecuteFinish;
      //function IsThreadRunning(): boolean;
      //function getThreadStatusStr: string;
    public
      //property LastCycleMS: longword read fLastCycleMS;
      //property ExecuteFinished: boolean read fExecuteFinished;
      //property UserSuspendActive: boolean read fFlagSuspend;
    //
    //NEWLY ADDED FUNCITONALITY:
    public
      procedure OpenTCP;      //called from main thread, must not block
      procedure CloseTCP;               //called from main thread, must not block
      procedure ResetConnection;     //called from main thread, must not block
      procedure ConfigureTCP( server: string; port: string);    //called from main thread, must not block
    private
      //cached tcp client status - main thread should not collide with lock on comsynchro
      fclient: TMyTCPClientThreadSafe;
      //fTCPsynchro: TTCPIPConfSynchro;
      fCloseRequested: TMVVariantThreadSafe;
      fOpenRequested: TMVVariantThreadSafe;
      fUpdateConfRequested: TMVVariantThreadSafe;   //signal that parameters of port should change -
      fServer: TMVVariantThreadSafe;
      fPort: TMVVariantThreadSafe;
      fCliChangeFlag: TMVVariantThreadSafe;
      //
      fOnCliStatusChange: TMyExecuteMethod;
  end;





//*********************************

implementation

Uses Windows;



constructor TAquireThreadV2_TCPIP.Create( UserExecute: TMyExecuteMethod; client: TMyTCPClientThreadSafe; OnCLiStatChange: TMyExecuteMethod);
begin
  inherited Create( UserExecute );
  fOnCliStatusChange := OnCLiStatChange;
  fClient := client;
  //fTCPsynchro := TTCPIPConfSynchro.Create;
  fCloseRequested := TMVVariantThreadSafe.Create(false);
  fOpenRequested := TMVVariantThreadSafe.Create(false);
  fUpdateConfRequested := TMVVariantThreadSafe.Create(false);   //signal that parameters of port should change -
  fServer := TMVVariantThreadSafe.Create('localhost');
  fPort := TMVVariantThreadSafe.Create('20005');
  fCliChangeFlag := TMVVariantThreadSafe.Create(false);
  SetUserSuspend;
  Resume; //!! there was issue, when object was never initialised and thus service thread not ever started - then during destroy  - wait for finish execute could never become fulfilled
end;


destructor TAquireThreadV2_TCPIP.Destroy;
begin
  //fTCPsynchro.Destroy;
  fCloseRequested.Destroy;
  fOpenRequested.Destroy;
  fUpdateConfRequested.Destroy;   //signal that parameters of port should change -
  fServer.Destroy;
  fPort.Destroy;
  fCliChangeFlag.Destroy;
  inherited;
end;


procedure TAquireThreadV2_TCPIP.ProcessConfigurationRequests;
  Procedure RunOnCliStatChange;
  begin
    if Assigned( fOnCliStatusChange  ) then
      begin
        try
          fOnCliStatusChange;
        except
          on E: Exception do begin end;
        end;
      end;
  end;
begin
  if fclient=nil then exit;
  //1)
  if fCloseRequested.valBool then
    begin
      if fclient.IsReady then fclient.Close;
      fCloseRequested.valBool := false;
      RunOnCliStatChange;
    end;
  //2)
  if fUpdateConfRequested.valBool then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient UpdateConf...');
      if fclient.IsConnected then fclient.Close;
      fclient.ConfigureTCP( fServer.valStr, fPort.valStr );
      fUpdateConfRequested.valBool := false;
      RunOnCliStatChange;
    end;
  //3)
  if fOpenRequested.valBool then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient OPEN port...');
      if not fclient.IsConnected then
         fclient.Open;  //may block for some time!!!!
      fOpenRequested.valBool := false;
      fCloseRequested.valBool := false;
      RunOnCliStatChange;
      //LeaveLogMsg('  NEW port state is: ' + BoolToStr(fTCPConnected));
    end;
  if fCliChangeFlag.valBool then
    begin
      RunOnCliStatChange;
    end;
end;


procedure TAquireThreadV2_TCPIP.OpenTCP;      //called from main thread, must not block
begin
  fOpenRequested.valBool := true;
end;


procedure TAquireThreadV2_TCPIP.CloseTCP;               //called from main thread, must not block
begin
  fCloseRequested.valBool := true;
end;


procedure TAquireThreadV2_TCPIP.ResetConnection;
begin
  fCloseRequested.valBool := true; //that will make reset with usening current configuration
  fUpdateConfRequested.valBool := true;  
  fOpenRequested.valBool := true;    //after update this will connect
end;

procedure TAquireThreadV2_TCPIP.ConfigureTCP( server: string; port: string);
//called from main thread,  must not block
begin
  fUpdateConfRequested.valBool := true;
  fServer.valStr := server;  //force COPY
  fPort.valStr :=  port;      //force COPY
end;




end.

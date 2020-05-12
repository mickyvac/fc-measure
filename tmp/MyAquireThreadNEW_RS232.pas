unit MyAquireThreadNEW_RS232;

{
   MyAquireThreadNEW_RS232.pas
   Copyright 2017 Michal Vaclavu <michal.vaclavu@gmail.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
}

interface

uses
  Classes, SysUtils, StdCtrls, Dialogs, DateUtils, SyncObjs,
  myutils, MyParseUtils, Logger, ConfigManager, MyThreadUtils,
  MyAquireThreadNEW, MyComPort;


type

  TMyExecuteMethod = procedure of object;

  TAquireThreadV2_RS232 = class (TAquireThreadBaseV2)       //TMultiReadExclusiveWriteSynchronizer
  //!!!!!NOTE!!!!
  //redefine override execute - now does also PROCESS CONFIGURATION REQUEST ON TCPCLIENT,
  //especially handles OPEN connection, which may BLOCK!!!!!
  //code that wants to use some TCPIP client should remap all opening to this thred object
  //create takes reference to TCPIP client base class (only does open, close, updatehost...)!!!!!!
    public
      constructor Create( UserExecute: TMyExecuteMethod; client: TComPortThreadSafe; log: TLoggerThreadSafeNew; OnCLiStatChange: TMyExecuteMethod);
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
      procedure OpenClient;      //called from main thread, must not block
      procedure CloseClient;               //called from main thread, must not block
      procedure ResetConnection;     //called from main thread, must not block
      procedure ConfigureClient( portconf: TComPortConf);    //called from main thread, must not block
    private
      //cached tcp client status - main thread should not collide with lock on comsynchro
      fclient: TComPortThreadSafe;
      fLog: TLoggerThreadSafeNew;
      //fTCPsynchro: TTCPIPConfSynchro;
      fCloseRequested: TMVVariantThreadSafe;
      fOpenRequested: TMVVariantThreadSafe;
      fUpdateConfRequested: TMVVariantThreadSafe;   //signal that parameters of port should change -
      fPortConf: TComPortConf;
      fPortConfLock: TMyLockableObject;
      fCliChangeFlag: TMVVariantThreadSafe;
      //
      fOnCliStatusChange: TMyExecuteMethod;
  end;





//*********************************

implementation

Uses Windows;



constructor TAquireThreadV2_RS232.Create( UserExecute: TMyExecuteMethod; client: TComPortThreadSafe; log: TLoggerThreadSafeNew; OnCLiStatChange: TMyExecuteMethod);
begin
  inherited Create( UserExecute );
  fOnCliStatusChange := OnCLiStatChange;
  fClient := client;
  fLog := log;
  //fTCPsynchro := TTCPIPConfSynchro.Create;
  fCloseRequested := TMVVariantThreadSafe.Create(false);
  fOpenRequested := TMVVariantThreadSafe.Create(false);
  fUpdateConfRequested := TMVVariantThreadSafe.Create(false);   //signal that parameters of port should change -
  fPortConfLock := TMyLockableObject.Create;
  fCliChangeFlag := TMVVariantThreadSafe.Create(false);
end;


destructor TAquireThreadV2_RS232.Destroy;
begin
  //fTCPsynchro.Destroy;
  fCloseRequested.Destroy;
  fOpenRequested.Destroy;
  fUpdateConfRequested.Destroy;   //signal that parameters of port should change -
  fCliChangeFlag.Destroy;
  fPortConfLock.Destroy;
  inherited;
end;


procedure TAquireThreadV2_RS232.ProcessConfigurationRequests;
  Procedure RunOnCliStatChange;
  begin
    if Assigned( fOnCliStatusChange  ) then
      begin
        try
          fOnCliStatusChange;
        except
          on E: Exception do begin flog.LogMsg('EXCEPTION ' + 'ProcessConfigurationRequests ' + E.Message); end;
        end;
      end;
  end;
begin
  if fclient=nil then exit;
  //1)
  if fCloseRequested.valBool then
    begin
      if fclient.IsPortOpen then fclient.ClosePort;
      fCloseRequested.valBool := false;
      RunOnCliStatChange;
    end;
  //2)
  if fUpdateConfRequested.valBool then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient UpdateConf...');
      if fclient.IsPortOpen then fclient.ClosePort;
      fPortConfLock.Lock;
      fclient.setComPortConf( fPortConf );
      fPortConfLock.UnLock;
      fUpdateConfRequested.valBool := false;
      RunOnCliStatChange;
    end;
  //3)
  if fOpenRequested.valBool then
    begin
      //LeaveLogMsg('CheckAndProcessRequestsTCPClient OPEN port...');
      if not fclient.IsPortOpen then
         fclient.OpenPort;  //may block for some time!!!!
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


procedure TAquireThreadV2_RS232.OpenClient;      //called from main thread, must not block
begin
  fOpenRequested.valBool := true;
end;


procedure TAquireThreadV2_RS232.CloseClient;               //called from main thread, must not block
begin
  fCloseRequested.valBool := true;
end;


procedure TAquireThreadV2_RS232.ResetConnection;
begin
  fCloseRequested.valBool := true; //that will make reset with usening current configuration
  fUpdateConfRequested.valBool := true;  
  fOpenRequested.valBool := true;    //after update this will connect
end;

procedure TAquireThreadV2_RS232.ConfigureClient( portconf: TComPortConf);
//called from main thread,  must not block
begin
  fUpdateConfRequested.valBool := true;
  fPortConfLock.Lock;
  fPortConf := portconf;  //force COPY
  fPortConfLock.Unlock;
end;




end.

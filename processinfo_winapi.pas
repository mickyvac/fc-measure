unit processinfo_winapi;

interface

uses windows, SysUtils;

type
  TQueryFullProcessImageNameW = function(AProcess: THANDLE; AFlags: DWORD;
    AFileName: PWideChar; var ASize: DWORD): BOOL; stdcall;
  TGetModuleFileNameExW = function(AProcess: THANDLE; AModule: HMODULE;
    AFilename: PWideChar; ASize: DWORD): DWORD; stdcall;



implementation
{
  b := CheckWin32Version(AMajor,AMin);
  ShowMessage(BoolToStr( CheckWin32Version(5) ));
  ShowMessage(BoolToStr( CheckWin32Version(6) ));
  ShowMessage(BoolToStr( CheckWin32Version(7) ));
}

function IsWindows200OrLater: Boolean;
begin
  Result := Win32MajorVersion >= 5;
end;

function IsWindowsVistaOrLater: Boolean;
begin
  Result := Win32MajorVersion >= 6;
end;

var
  PsapiLib: HMODULE;
  GetModuleFileNameExW: TGetModuleFileNameExW;

procedure DonePsapiLib;
begin
  if PsapiLib = 0 then Exit;
  FreeLibrary(PsapiLib);
  PsapiLib := 0;
  @GetModuleFileNameExW := nil;
end;

procedure InitPsapiLib;
begin
  if PsapiLib <> 0 then Exit;
  PsapiLib := LoadLibrary('psapi.dll');
  if PsapiLib = 0 then RaiseLastOSError;
  @GetModuleFileNameExW := GetProcAddress(PsapiLib, 'GetModuleFileNameExW');
  if not Assigned(GetModuleFileNameExW) then
    try
      RaiseLastOSError;
    except
      DonePsapiLib;
      raise;
    end;
end;

function GetFileNameByProcessID(AProcessID: DWORD): WideString;
const
  PROCESS_QUERY_LIMITED_INFORMATION = $00001000; //Vista and above
var
  HProcess: THandle;
  Lib: HMODULE;
  QueryFullProcessImageNameW: TQueryFullProcessImageNameW;
  S: DWORD;
begin
  if IsWindowsVistaOrLater then
    begin
      Lib := GetModuleHandle('kernel32.dll');
      if Lib = 0 then RaiseLastOSError;
      @QueryFullProcessImageNameW := GetProcAddress(Lib, 'QueryFullProcessImageNameW');
      if not Assigned(QueryFullProcessImageNameW) then RaiseLastOSError;
      HProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessID);
      if HProcess = 0 then RaiseLastOSError;
      try
        S := MAX_PATH;
        SetLength(Result, S + 1);
        while not QueryFullProcessImageNameW(HProcess, 0, PWideChar(Result), S) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) do
          begin
            S := S * 2;
            SetLength(Result, S + 1);
          end;
        SetLength(Result, S);
        Inc(S);
        if not QueryFullProcessImageNameW(HProcess, 0, PWideChar(Result), S) then
          RaiseLastOSError;
      finally
        CloseHandle(HProcess);
      end;
    end
  else
    if IsWindows200OrLater then
      begin
        InitPsapiLib;
        HProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, AProcessID);
        if HProcess = 0 then RaiseLastOSError;
        try
          S := MAX_PATH;
          SetLength(Result, S + 1);
          if GetModuleFileNameExW(HProcess, 0, PWideChar(Result), S) = 0 then
            RaiseLastOSError;
          Result := PWideChar(Result);
        finally
          CloseHandle(HProcess);
        end;
      end;
end;


initialization
  PsapiLib := 0;

finalization
  DonePsapiLib;




end.


//example

procedure EnumProcesses(AStrings: TStrings);
var Snapshot: THandle;
    Entry: TProcessEntry32;
    Found: Boolean;
    Count: Integer;
begin
    Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (Snapshot = INVALID_HANDLE_VALUE) or (Snapshot = 0) then Exit;
    try
      ZeroMemory(@Entry, SizeOf(Entry));
      Entry.dwSize := SizeOf(Entry);
      if Process32First(Snapshot, Entry) then
        repeat
          try
            AStrings.Add(GetFileNameByProcessID(Entry.th32ProcessID));
          except
            AStrings.Add('System process #' + IntToStr(Entry.th32ProcessID));
          end;
          ZeroMemory(@Entry, SizeOf(Entry));
          Entry.dwSize := SizeOf(Entry);
        until not Process32Next(Snapshot, Entry);
    finally
      CloseHandle(Snapshot)
    end;
end;

procedure TForm11.FormCreate(Sender: TObject);
begin
  EnumProcesses(ListBox1.Items);
end;
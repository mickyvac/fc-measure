unit MyPSUtils_winapi;

interface

uses windows, SysUtils, PSAPI, TLHelp32;

type
  TQueryFullProcessImageName = function(AProcess: THANDLE; AFlags: DWORD;
    AFileName: PWideChar; var ASize: DWORD): BOOL; stdcall;
  TGetModuleFileNameEx = function(AProcess: THANDLE; AModule: HMODULE;
    AFilename: PChar; ASize: DWORD): DWORD; stdcall;


function IsWindows200OrLater: Boolean;
function IsWindowsVistaOrLater: Boolean;

function myGetProcessPID(psname: string): longword;
function TerminateProcessByID(ProcessID: Cardinal): Boolean;

function MyGetFileNameByProcessID(AProcessID: DWORD; Var psname: string): longword;


implementation





function IsWindows200OrLater: Boolean;
begin
  Result := Win32MajorVersion >= 5;
end;

function IsWindowsVistaOrLater: Boolean;
begin
  Result := Win32MajorVersion >= 6;
end;


function MyGetFileNameByProcessID(AProcessID: DWORD; Var psname: string): longword;
const
  PROCESS_QUERY_LIMITED_INFORMATION = $00001000; //Vista and above
var
  HProcess: THandle;
  Lib: HMODULE;
  QueryFullProcessImageName: TQueryFullProcessImageName;
  buffer: array of Char;
  bufferw: array of WideChar;
  s: DWORD;
begin
  Result := 1;
  psname := '';
  setlength( buffer, MAX_PATH+1 );
  S := length(buffer);
  if IsWindowsVistaOrLater or true then
    begin
      Lib := GetModuleHandle('kernel32.dll');
      if Lib = 0 then begin Result:= GetLastError; exit; end;
      QueryFullProcessImageName := GetProcAddress(Lib, 'QueryFullProcessImageNameW');
      if not Assigned(QueryFullProcessImageName) then begin Result:= GetLastError; exit; end;
      HProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessID);
      if HProcess = 0 then begin Result:= GetLastError; exit; end;
      try
        if not QueryFullProcessImageName(HProcess, 0, pwidechar(buffer), s ) then
           begin Result:= GetLastError; exit; end;
        psname := string(pwidechar(buffer));
      finally
        CloseHandle(HProcess);
      end;
    end
  else
    if IsWindows200OrLater then
      begin
        HProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, AProcessID);
        if HProcess = 0 then
          begin Result:= GetLastError; exit; end;
        try
          if GetModuleFileNameEx(HProcess, 0, pchar(buffer), s) = 0 then
              begin Result:= GetLastError; exit; end;
          psname := pchar(buffer);
        finally
          CloseHandle(HProcess);
        end;
      end;
end;



function myGetProcessPID(psname: string): longword;
//From http://stackoverflow.com/questions/12637203/why-does-createprocess-give-error-193-1-is-not-a-valid-win32-app
//returns PID<>0 if ptc is runnning
//0 if cannot find process
var
  ptcsrvwindname: string;
  ptcHWND: THandle;
  snapshot: THandle;
  ProcEntry: TProcessEntry32;
  s: String;
begin
   Result := 0;
   snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   //
   if (snapshot <> INVALID_HANDLE_VALUE) then begin
     ProcEntry.dwSize := SizeOf(ProcessEntry32);
     if (Process32First(snapshot, ProcEntry)) then begin
       s := ProcEntry.szExeFile;
       // s contains image name of the first process // Can throw away, never an actual app
       while Process32Next(snapshot, ProcEntry) do begin
         s := ProcEntry.szExeFile;
         if AnsiCompareText(s,psname)=0 then begin Result := ProcEntry.th32ProcessID; break; end;  //non-case-sensitive comapre!!!
         // s contains image name of the current process
       end;
     end;
   end;
   CloseHandle(snapshot);
end;

function TerminateProcessByID(ProcessID: Cardinal): Boolean;
//  http://stackoverflow.com/questions/2550927/i-have-the-process-id-and-need-to-close-the-associate-process-programatically-wi
var
  hProcess : THandle;
begin
  Result := False;
  try
    hProcess := OpenProcess(PROCESS_TERMINATE,False,ProcessID);
  except
    on E: exception do begin end;
  end;
  if hProcess > 0 then
  try
    //Result := Win32Check(Windows.TerminateProcess(hProcess,0));
    CloseHandle(hProcess);
  finally
    CloseHandle(hProcess);
  end;
end;


end.

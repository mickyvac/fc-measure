unit MyFileUtils;

interface

//sysutils: function ForceDirectories(Dir: string): Boolean;
//function MakeSureDirExist( path: string ): boolean;
function Backslash: string;


implementation

Uses SysUtils, StrUtils, Math, Windows;



function Backslash: string;
begin
  Result := '\';
end;

function MakeSureDirExist( path: string ): boolean;
begin  //MkDir
  Result := false;
  {$I-}
  if not DirectoryExists(path) then
    begin
      //create directory
      if not CreateDir(path) then exit;
    end;
  if (IoResult <> 0) then  exit;
  {$I+}
  Result := true;
end;



end.

unit Ptc_defines;

interface

type
    TPtcInfo = record
      fw:array[0..63] of AnsiChar;
      fwVersion:array[0..63] of AnsiChar;
      fwVendor:array[0..63] of AnsiChar;
      ainCount:integer;
      aoutCount:integer;
    end;
    PPtcInfo = ^TPtcInfo;

implementation

end.

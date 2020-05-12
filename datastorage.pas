unit datastorage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ExtCtrls, DateUtils, Math,
  HWAbstractdevicesV3, {HWInterface,} FormGLobalConfig, FormProjectControl,
  MyUtils, Logger, MyParseUtils;

Const
  CDSMaxArrays = 50000;
  CDSRecsInArray = 1000;          //size of one "block" of stored data
  CDSDefMaxMemoryUsageMB = 800; //in Megabytes - will limit allocation of new data storage

//for debugging purpose
//  CDSMaxArrays =10;
//  CDSRecsInArray = 3;          //size of one "block" of stored data


  CMonitorFileSuperPrefix = '!mon_';
  CMonitorFileSuffix = '_log.txt';

  CDataTooOldLimitMS = 10000;


type
   TMonitorRec = record
      //PTC values
      Uraw: double;
      Iraw: double;
      Praw: double;
      Uref: double;
      //ptc procesed data - invert voltage/current
      I: double;
      U: double;
      P: double;
      //ptc data normlaized to area
      Inorm: double;
      Unorm: double;
      Pnorm: double;
      //ptc rec
      PTCrec: TPotentioRec;       //contains timestamp
      PTCStatus: TPotentioStatus;
      //flow
      FlowData: TFlowData;        //contains timestamp
      FlowFlags: TFlowControllerFlagSet;
      //other devices data - valve temp pressure
      ValveData: TValveData;
      SensorData: TSensorData;
      RegData: TRegData;
      VTPFlags: TVTPControllerFlagSet;
      //other
      //a: array[1..100] of double; //dummy to test memory consumpion
      end;

   PMonitorRec = ^TMonitorRec;

   TMonitorRecArray =  array [0..CDSRecsInArray-1] of TMonitorRec;
   PMonitorRecArray = ^TMonitorRecArray;



   TMemDataStorageBase = class (TObject)
     // !!!this is only abstract class with code for storage handling, but for
     //    each type of record to be stored there should be special class derived with overridden methods for accesing individual records
     //    there are two private methods to be overriden (these are neccesary) because they have to know with which
     //     type of record they are working (becasue of size in memory)
     //idea: fast storage of data - e.g. history or for graph
     //-> main properties:  only storing;  NO DELETING of single items
     //      minimalize allocation - use blocks - array of datapoints at each allocation
     //memory usage management - user sets limit - after that limit no more allocation
     //possible strategy in case of full data - possibly delete some e.g. 20% of data - but delete
     //   only whole blocks - let say first 20% of TDataArays from beginning and reaarange pointers = minimum work and memory requirements
     //   >>when removing some blocks - DO NOT DEALLCOATE memory, but instead Rearrange blocks IN PLACE
     private
       //main internal variables!!!
       fCountInLastBlock: longword;     //number of points... 0= no points  takes into account unfilled records in "blocks" (in the last block)
       fLastBlockIndex: longword;     //this is the index of active block, where the the data are beeing added = last unfilled block of data
       fCountAllocatedBlocks: longword;     //number af active (allocated) arrays with records; in defined state - always from the beginning up the count are allocated, rest are nil
       fMaxBlocksLimitCount: longword;    ///maximum allocated blocks - combination of max allowed records & max memory usage
       fBlockArray: array[0..CDSMaxArrays-1] of Pointer;   //this array stores Pointers to "block of records", max size of array should be limited to "CDSMaxArrays" Items
       fMemLimitMB: longint;  //number in megabytes - if sizeof storage would be larger becasuse of new allcoation, no more is created
       //fRetryNewFilecnt: longint;

     private
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments this is done in the core methods
       procedure WriteRecord(TargetBlock: Pointer; pos: longword; Prec: Pointer); virtual; abstract;   //copy record data into array on position of new record
                              //pos: 0.. CDSMaxInArray
                              //if do not want to copy data, only allocate then  use Proc=nil
       function ReadRecord(TargetBlock: Pointer; pos: longword): Pointer; virtual; abstract;
       function SizeOfArrayBlock: longword; virtual; abstract;
       procedure AllocateNewArrayBlock(Var pa: Pointer); virtual; abstract;    //override with allocation of actual type e.g. TMonitorRecArray
       procedure DisposeArrayBlock(Var pa: Pointer); virtual; abstract;
       //
     public
       //core methods
       constructor Create;
       destructor Destroy; override;
       function AddRecUni( PRec: Pointer ): longint;  //after succes sets id(present position) of record(>=0) otherwise returns -1
       function GetRecUni( n: longint): Pointer;  //n is ordinal number of record, starts from 0 to CountTotal-1
       function CountTotal(): longint;   //returns actual number of records
       function MemUsageMB: longint;  //returns number of raw size of data in megabytes
       function MemUsageProcent: byte; //returns how many procent of set memory limit is used (rounded)   0..100
       procedure setMemLimitMB(m: longint);
     public
       property MemLimitMB: longint read fMemLimitMB write setMemLimitMB;  //in megabytes limit the size
       property CountLastBlock: longword read fCountInLastBlock;  //returns actual number of records in last block (that is the only one which may not be full)
       property CountAllocatedBlocks: longword read fCountAllocatedBlocks;
     public
       procedure MakeSpaceProcents(procents: byte=20);  //tries to delete first=oldest 'procents' procent of records stored
       procedure RemoveAllData;
       procedure DeallocateUnusedBlocks;
   end;




  TMonitorMemDataStorage = class(TMemDataStorageBase)
     public
       constructor Create;
       destructor Destroy; override;
     private
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments
       procedure WriteRecord(TargetBlock: Pointer; pos: longword; Prec: Pointer); override;   //copy record data into array on position of new record
                              //pos: 0.. CDSMaxInArray  //if do not want to copy data, only allocate then  use Proc=nil
       function ReadRecord(TargetBlock: Pointer; pos: longword): Pointer; override;
       function SizeOfArrayBlock: longword; override;
       procedure AllocateNewArrayBlock(Var pa: Pointer); override;
       procedure DisposeArrayBlock(Var pa: Pointer); override;
     public
       //wrapper with retyping of pointers to and from PmonitorRec for convenience
       function AddRec( PRec:  PMonitorRec):longint;  //after succes returns id of record(>=0) or -1 on error
       function GetRec( n: longint):  PMonitorRec;  //n is ordinal number (not the id) of record, starts from 0 to NPoints-1
       function FindRecByTime(tmatch: TDateTime): longint; //tries to find closest record with time tm if not possible returns -1
   end;





  TMonitorFileStorage = class (TObject)
  public
    constructor Create;
    destructor Destroy; override;
    { Public declarations }
    procedure LogRecord( Var monrec: TMonitorRec);
    function TsValid(dt: TDateTime): boolean;
    procedure Reset;  //if file not exist call start new file else just reopen, continue appending
    function StartNewFile: boolean;   //file name is based on project sttings - prefix and driectory!
    function SetFile(path: string): boolean;
    procedure RegisterForProjectUpdate;
    procedure OnProjectUpdate;
  private
    { Private declarations }
    procedure WriteHeader;  //writes header info (called with new file)
    function FlowRecToStr(r: TFlowRec): string;
    function MonPressureToStr(d: TOneDoubleRec): string;
    //
    function MakeHeaderStrV3: string;
    function MakeMonRecStrV3( Var monrec: TMonitorRec): string;
    function MakeHeaderStrV4: string;
    function MakeMonRecStrV4( Var monrec: TMonitorRec): string;
  private
    logset: boolean;
    logPath: string;
    flogfile: TextFile;
    starttime: TDateTime;
    fFormatS: TFormatSettings;
    fRetryNewFilecnt: longint;
    fUpdateLogFile: boolean;    //project update broadcasted
    fRegisteredUpdate :boolean;
    fDataTooOldLimitMS: longint;
  end;



procedure DataStorageInittt;       //call after app start

//monitor record handling routines


procedure MonitorRecFillNaN(Var res: TMonitorRec);
procedure MonitorRecTakeMin(Var res: TMonitorRec; in1, in2: PMonitorRec);
procedure MonitorRecTakeMax(Var res: TMonitorRec; in1, in2: PMonitorRec);
procedure MonitorRecAdd(Var res: TMonitorRec; in1: PMonitorRec);
procedure MonitorRecMultiplyByNumber(Var res: TMonitorRec; d: double);


Var
  MonitorFileMain: TMonitorFileStorage;  //storing monitor data - electrical and other values, placed in project directory
  MonitorMemHistory: TMonitorMemDataStorage;    //MONITOR data - stored in memory for plotting

  logfiledebug: boolean;


implementation



procedure DataStorageInittt;       //call after app start
begin
   logfiledebug := false;
end;





//---------TDataStorage for MonitorRecord

constructor TMonitorMemDataStorage.Create;
begin
 inherited;
end;

destructor TMonitorMemDataStorage.Destroy;
begin
 inherited;
end;


procedure TMonitorMemDataStorage.WriteRecord(TargetBlock: Pointer; pos: longword; Prec: Pointer);
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments
//copy record data into array on position of new record
//pos: 0.. CDSMaxInArray
//if do not want to copy data, only allocate then  use Proc=nil
//array type is:   TMonitorRecArray   and record is TMonitorRec
Var
 pa: PMonitorRecArray;
 pr: PMonitorRec;
begin
  pa := PMonitorRecArray(TargetBlock);
  pr := PMonitorRec(Prec);
  pa^[pos] := pr^;  //rec copy
end;


function TMonitorMemDataStorage.ReadRecord(TargetBlock: Pointer; pos: longword): Pointer;
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments
Var
 pa: PMonitorRecArray;
 pr: PMonitorRec;
begin
  pa := PMonitorRecArray(TargetBlock);
  pr := @( pa^[pos] );
  Result := pr;
end;

function TMonitorMemDataStorage.SizeOfArrayBlock: longword;
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments
begin
  Result := SizeOf( TMonitorRecArray );
end;


procedure TMonitorMemDataStorage.AllocateNewArrayBlock(Var pa: Pointer);
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments
Var
 p: PMonitorRecArray;
begin
  p := nil;
  try
    New(p);
  except
    //logmsg('TMonitorMemDataStorage.AllocateNewArrayBlock: E OUT OF MEMORY');
    //Dispose(p);      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    p := nil;
  end;
  pa := p;
end;


procedure TMonitorMemDataStorage.DisposeArrayBlock(Var pa: Pointer);
       //these simple internal methods have to be rewriten for each specific object type
       //they are used only internally as wrapper - no need to check correctness of arguments
Var
 p: PMonitorRecArray;
begin
  p := PMonitorRecArray(pa);
  Dispose(p);
  pa := nil;
end;


function TMonitorMemDataStorage.AddRec( PRec:  PMonitorRec): longint;
//wrapper
//after succes returns id of record(>=0) or -1 on error
Var
  b: boolean;
  id: longword;
begin
  Result := AddRecUni( prec );
end;


function TMonitorMemDataStorage.GetRec( n: longint):  PMonitorRec;
//wrapper
 //n is ordinal number (not the id) of record, starts from 0 to NPoints-1
begin
  Result := GetRecUni( n );
end;



function TMonitorMemDataStorage.FindRecByTime(tmatch: TDateTime): longint; //tries to find closest record with time tm if not possible returns -1
Var
  iL, iH, imid, i: longint;
  t: TDateTime;
  prec : PMonitorRec;
begin
  //use method of searching record by halving the space to search (assuming records are sorted ASCENDINDLY by time
  //-  which should be true in this case, where records are continuosly added !!!!
  Result := -1;
  //!!!! CHECK FOR NAN
  if isnan(Tmatch) then exit;
  iL := 0;
  iH := CountTotal-1;
  if iH<0 then exit;
 // if iH=0 then  //if only one record - consider it the closest  match
 //   begin
 //     Result:=0;
 //     exit;
 //   end;
  iMid := 0;
  // code must guarantee the interval is reduced at each iteration
  while not (iL>iH) do
    begin
      //middle point
      imid := iL + ((iH-iL) div 2);    //if IH is iL+1 one from iL imid will remain to be iL !!!
      //spcecial condition iL=iH - must treat as special condition,
      //get time val
      Prec := GetRec( iMid );
      t := NaN;
      if pRec <> nil then t := Prec^.PTCrec.timestamp else begin  break; end;
      // here the plus 1 is important !!! in the calculation of iMid can stay at iL if iH=iL+1
      // -1/+1 in every iteration makes sure, that the loop will finish!!!
      //in rare case, when t=tmatch, the result index will be  shifted by one - which is usually no problem
      //
      //think about NAN in that case do not uses interval dividing
      if IsNan(t) then
        begin
          for i:=iL to iH do //find first non-NAN
            begin
              Prec := GetRec( i );
              if pRec <> nil then t := Prec^.PTCrec.timestamp;
              iMid := i;
              if not IsNAN(t) then break;
            end;
        end;
      if IsNan(t) then exit;  //no way how to solve this situation - all data was NaN
      try
        if t>tmatch then iH := iMid - 1
        else iL := iMid + 1;
      except
        iL:=iH+1;
        IMid := -1;
      end;
    end;
  Result := IMid;
end;


//---------TDataStorage Common Ancestor -----------



constructor TMemDataStorageBase.Create;
Var i:longword;
begin
  inherited;
  fLastBlockIndex := 0;
  fCountInLastBlock := 0;
  fCountAllocatedBlocks := 0;
  setMemLimitMB( CDSDefMaxMemoryUsageMB ); //initializes also fMaxBlocksLimit
  //fill nil
  for i :=0 to CDSMaxArrays-1 do begin fBlockArray[i] := nil; end;
end;


destructor TMemDataStorageBase.Destroy;
Var i:longint;
begin
  for i:=0 to fCountAllocatedBlocks-1 do
  begin
    if fBlockArray[i]<>nil then DisposeArrayBlock( fBlockArray[i] );
  end;
  inherited;
end;



function TMemDataStorageBase.AddRecUni( PRec: Pointer):longint;
//after succes returns id of record(>=0) or -1 on error
//uses call to specific function WriteRecord which will handle concrete Single record type
Var r,c:longint;
    pa: Pointer;
    newblockpos, newbi: longword;
    memafter : longint;
    valid, neednewarray: boolean;
begin
  Result := -1;
  if Prec=nil then exit;
  //
  neednewarray:= false;
  if fCountAllocatedBlocks = 0 then  neednewarray := true; //special case first array allocation
  if fCountInLastBlock >= CDSRecsInArray then
    if (fLastBlockIndex + 1) >= fCountAllocatedBlocks then neednewarray := true;
  //
  if neednewarray then //new array allcoation
    begin
      if fCountAllocatedBlocks = 0 then Assert( fLastBlockIndex = 0 );
      if fCountAllocatedBlocks > 0 then Assert( (fLastBlockIndex +1) = fCountAllocatedBlocks );
      newbi := fCountAllocatedBlocks;
      if (newbi>=fMaxBlocksLimitCount) and (fCountAllocatedBlocks>0) then
        //check if is limit of count then exit, but allow at least one array
        begin
          exit;
        end;
      AllocateNewArrayBlock( pa );
      if pa=nil then exit;
      fBlockArray[newbi] := pa;
      Inc(fCountAllocatedBlocks);
    end;
  //adding record - find new position
  valid := false;
  if fCountInLastBlock < CDSRecsInArray then //can safely add without any trouble
    begin
      newblockpos := fCountInLastBlock;
      valid := true;
    end
  else  //need to use next block, if available
    begin
      Assert( (fLastBlockIndex +1) <= fCountAllocatedBlocks );
      Inc( fLastBlockIndex );
      newblockpos := 0;
      valid := true;
    end;
  //write record
  if valid then
    begin
      pa := fBlockArray[ fLastBlockIndex ];
      WriteRecord( pa, newblockpos, PRec);
      fCountInLastBlock := newblockpos + 1;
    end;
  //done
  Result := CountTotal;
end;


function TMemDataStorageBase.GetRecUni( n: longint): Pointer;  //n is ordinal number of record, starts from 0 to NPoints-1       function NPoints(): longint;   //returns actual number of records
//call to specific function ReadRecord which will handle concrete Single record type
Var row,pos:word;
    pa: Pointer;
begin
  Result := nil;
  if (n<0) then exit;
  row := n div CDSRecsInArray;
  pos := n mod CDSRecsInArray;
  if (row > fLastBlockIndex) then exit;
  if (row = fLastBlockIndex) and (pos >= fCountInLastBlock) then exit;
  pa := fBlockArray[row];
  if (pa=nil) then exit;
  Result := ReadRecord(pa, pos);
end;

function TMemDataStorageBase.CountTotal(): longint;
begin
  Result := CDSRecsInArray * (fLastBlockIndex) + fCountInLastBlock;
end;

function TMemDataStorageBase.MemUsageMB: longint;  //returns number of megabytes
begin
    Result := (fCountAllocatedBlocks * SizeOfArrayBlock) div (1024*1024);
end;

function TMemDataStorageBase.MemUsageProcent: byte; //returns how many procent of set memory limit is used
begin
    Result := (100 * (fLastBlockIndex+1) ) div fMaxBlocksLimitCount;
end;

procedure TMemDataStorageBase.setMemLimitMB(m: longint);
begin
  if (m<0) then m := CDSDefMaxMemoryUsageMB;
  fMemLimitMB := m;
  fMaxBlocksLimitCount := (fMemLimitMB * 1024 * 1024) div (SizeOfArrayBlock);
  if fMaxBlocksLimitCount > CDSMaxArrays then fMaxBlocksLimitCount := CDSMaxArrays;
end;

procedure TMemDataStorageBase.MakeSpaceProcents(procents: byte=20);
//tries to delete first=oldest 'procents' procent of records stored
Var
  na, i: longword;
  tmpar: array of Pointer;
begin
    //calc how many arrays are procentage of max memory usage
    na := (fMaxBlocksLimitCount * procents) div 100;
    // will keep at least one last array block
    if na>fLastBlockIndex then na := fLastBlockIndex;
    if na<1 then exit; //nothing to do;
    //do not deaallocate any arrays, just move in place" the pointers to blocks and "forget" about data that
    //were in the first na blocks (now shjould be at end
    //ShowMessage(' in make space na=' + IntToStr(na) + ' nsets ' + IntToStr(nsets) );
    //to do it simply - I will use helper array for the pointers - (size for all the "na"pointers, that are to be moved to the end
    setlength(tmpar, na);
    for i:= 0 to na-1 do tmpar[i] := fBlockArray[i];
    //shift all remaining pointers by ""na""
    Assert( na <= fCountAllocatedBlocks-1);
    for i:= na to fCountAllocatedBlocks-1 do fBlockArray[i-na] := fBlockArray[i];
    //return pointers put aside to the end
    for i:=0 to na-1 do fBlockArray[fCountAllocatedBlocks + i - na] := tmpar[i];
    //update last used index
    fLastBlockIndex := fLastBlockIndex - na;
    //done
    setlength(tmpar, 0);
end;

procedure TMemDataStorageBase.RemoveAllData;
//block arrays will stay allocated
begin
  fCountInLastBlock := 0;
  fLastBlockIndex := 0;
end;

procedure TMemDataStorageBase.DeallocateUnusedBlocks;
Var i, i0: longword;
begin
  i0 := fLastBlockIndex + 1;
  if fCountAllocatedBlocks=0 then exit;  //completely empty, special case
  if fCountAllocatedBlocks=i0 then exit; //no work to do
  Assert(fCountAllocatedBlocks>i0);
  for i:=i0 to fCountAllocatedBlocks-1 do
    begin
      DisposeArrayBlock( fBlockArray[i] );
    end;
  fCountAllocatedBlocks:=i0;
end;






//
// **************************************************************
// FILE STORAGE
//

constructor TMonitorFileStorage.Create;
begin
  inherited;
  logset := false;
  GetLocaleFormatSettings(0, fFormatS);
  //set format settings to use "."
  fFormatS.DecimalSeparator := '.';
  fRetryNewFilecnt := 0;
  fUpdateLogFile := false;
  fRegisteredUpdate := false;
  fDataTooOldLimitMS := CDataTooOldLimitMS;
end;


destructor TMonitorFileStorage.Destroy;
begin
  inherited;
end;

procedure TMonitorFileStorage.RegisterForProjectUpdate;
begin
  if (fRegisteredUpdate=false) and (ProjectControl<>nil) then
    begin
      ProjectControl.RegOnProjectUpdateMethod( OnProjectUpdate );
      fRegisteredUpdate := true;
    end
  else
    begin
      logerror('TMonitorFileStorage.RegisterForProjectUpdate ProjectControl=nil');
    end;
end;

procedure TMonitorFileStorage.OnProjectUpdate;
begin
  fUpdateLogFile := true;
end;



function TMonitorFileStorage.MonPressureToStr(d: TOneDoubleRec): string;
  begin
    Result := IfThenElse( TsValid(d.timestamp),  FloatToStrF( d.val ,  ffGeneral,3,2, fFormatS), 'NAN' )
  end;




function TMonitorFileStorage.MakeHeaderStrV3: string;
begin
  Result := 'Time_from_start[ms]' + #9 + 'Temp[degC]' + #9 + 'Current[A.cm-2]'
            + #9 + 'VoltagePerCell[V]' + #9 + 'PowerPerCell[W.cm-2]' + #9 + 'FullTime' + #9 + 'Uref[V]' + #9 + 'RawCurrent[A]' + #9+ 'RawVoltage[V]' + #9 + 'debugmsg' + #9 + 'FlowData(sccm,bar)';
end;

function TMonitorFileStorage.MakeMonRecStrV3( Var monrec: TMonitorRec): string;
Var
  dtstr, tstr, monstr, monstrFlow, monstrVTP: String;
  deltat : int64;
begin
  deltat := MilliSecondsBetween(Now , starttime);
  dtstr := IntToStr( deltat );
  //GetLocaleFormatSettings(0, tfs);
  DateTimeToString(tstr, '(yyyy/mm/dd_hh:nn:ss)', Now);
  // 'Time_from_start[ms]' + #9 + 'Temp[degC]' + #9 + 'Current[A.cm-2]' + #9 + 'Voltage[V]' + #9 + 'Power[W.cm-2]' + #9 + 'FullTime' + #9 + 'Uref[V]');
  monstr := dtstr + #9 + FloatToStrF( NAN, ffGeneral,4,2, fFormatS)
                  + #9 + FloatToStrF( monrec.Inorm,  ffGeneral,7,2, fFormatS) +
                    #9 + FloatToStrF(monrec.Unorm, ffGeneral,7,2, fFormatS) +
                    #9 + FloatToStrF(monrec.Pnorm, ffGeneral,7,2, fFormatS) +
                    #9 + tstr +
                    #9 + FloatToStrF(monrec.Uref, ffGeneral,7,2, fFormatS) +
                    #9 + FloatToStrF(monrec.Iraw, ffGeneral,7,2, fFormatS) +
                    #9 + FloatToStrF(monrec.Uraw, ffGeneral,7,2, fFormatS);
  //
  monstrFlow := 'MFA=(' + FlowRecToStr(monrec.FlowData[CFlowAnode]) + ')' +
                'MFN=(' + FlowRecToStr(monrec.FlowData[CFlowN2]) + ')' +
                'MFC=(' + FlowRecToStr(monrec.FlowData[CFlowCathode]) + ')' +
                'MFR=(' + FlowRecToStr(monrec.FlowData[CFlowRes]) + ')';
  //

  monstrVTP := 'pA='+  MonPressureToStr( monrec.SensorData[CpAnode] ) + ';' +
               'pC='+  MonPressureToStr( monrec.SensorData[CpCathode] ) + ';' +
               'pP='+  MonPressureToStr( monrec.SensorData[CpPiston] ) + ';' +
               'TbH='+  MonPressureToStr( monrec.SensorData[CTBubH2] ) + ';' +
               'TbO='+  MonPressureToStr( monrec.SensorData[CTBubO2] ) + ';' +
               'TcT='+  MonPressureToStr( monrec.SensorData[CTCellTop] ) + ';' +
               'TcB='+  MonPressureToStr( monrec.SensorData[CTCellBot] ) + ';' ;


  Result := monstr +  #9 + monrec.PTCStatus.debuglogmsg + #9 + monstrFlow + #9 + monstrVTP;
end;


function MakeValveDumpHdr(): string;
Var
  vd: TValveDevices;
begin
  Result := '';
  for vd:= Low(TValveDevices) to High(TValveDevices) do
    begin
      Result := Result + VTPDeviceToStr( vd );
      if vd<> High(TValveDevices) then Result := Result + #9;
    end;
end;


function ValveDataStr( Var monrec: TMonitorRec ): string;
Var
  vd: TValveDevices;
begin
  Result := '';
  for vd := Low(TValveDevices) to High(TValveDevices) do
    begin
      Result := Result + ValveStateToStr( monrec.Valvedata[vd].state );
      if vd<> High(TValveDevices) then Result := Result + #9;
    end;
end;


function TMonitorFileStorage.MakeHeaderStrV4: string;
begin
  Result := 'RelTime[s]' + #9 + 'Current[A.cm-2]'
            + #9 + 'VoltagePerCell[V]' + #9 + 'PowerPerCell[W.cm-2]' + #9 + 'FullTime'
            + #9 + 'Uref[V]'
            + #9 + 'RawCurrent[A]' + #9 + 'RawVoltage[V]'
            + #9 + 'PTCsetpoint[A/V]'
            + #9 + 'TempCellBot[°C]' + #9 + 'TempCellTop[°C]'
            + #9 + 'p_Ain[bar]' + #9 + 'p_Cin[bar]' + #9 + 'p_piston[bar]'
            + #9 + 'flow_A[sccm]' + #9 + 'flow_C[sccm]' + #9 + 'flow_N2[sccm]' + #9 + 'flow_mix[sccm]'
            + #9 + 'TBubA[°C]' + #9 + 'TBubN[°C]' + #9 + 'TBubC[°C]' + #9 + 'TOven1[°C]' + #9 + 'TOven2[°C]'
            + #9 + 'p_MFCA[bar]' + #9 + 'p_MFCN[bar]' + #9 + 'p_MFCC[bar]' + #9 + 'p_MFCMix[bar]'
            + #9 + 'set_MFCA[sccm]' + #9 + 'set_MFCN[sccm]' + #9 + 'set_MFCC[sccm]' + #9 + 'set_MFCMix[sccm]'
            + #9 + 'BPRreg[bar]' + #9 + 'set_BPRreg[bar]'
            + #9 + 'PTCdebugmsg'
            + #9 + '|'
            + #9 + MakeValveDumpHdr()
            + #9 + '|'
            + #9 + 'H1set[°C]' + #9 + 'H2set[°C]'+ #9 + 'H3set[°C]'+ #9 + 'H4set[°C]'+ #9 + 'H5set[°C]'+ #9 + 'H6set[°C]'
            ;
end;


function TMonitorFileStorage.MakeMonRecStrV4( Var monrec: TMonitorRec): string;
Var
  dtstr, tstr, monstr, monstrFlow, monstrVTP: String;
  deltat : int64;
begin
  deltat := MilliSecondsBetween(Now , starttime);
  dtstr := FloatToStrF( deltat/1000, ffGeneral,7,3, fFormatS );
  DateTimeToString(tstr, '(yyyy/mm/dd_hh:nn:ss.zzz)', Now);
  //
  monstr := dtstr
            + #9 + FloatToStrF( monrec.Inorm,  ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.Unorm, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.Pnorm, ffGeneral,7,2, fFormatS)
            + #9 + tstr
            + #9 + FloatToStrF(monrec.Uref, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.Iraw, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.Uraw, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.PTCStatus.setpoint, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTCellBot].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTCellTop].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CpAnode].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CpCathode].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CpPiston].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowAnode].massflow, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowCathode].massflow, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowN2].massflow, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowRes].massflow, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTBubH2].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTBubN2].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTBubO2].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTOven1].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTOven2].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowAnode].pressure, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowCathode].pressure, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowN2].pressure, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowRes].pressure, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowAnode].setpoint, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowCathode].setpoint, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowN2].setpoint, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.FlowData[CFlowRes].setpoint, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CpBPControl].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.RegData[CpRegBackpress].val, ffGeneral,7,2, fFormatS)
            + #9 + monrec.PTCStatus.debuglogmsg
            + #9 + '|'
            + #9 + ValveDataStr( monrec )
            + #9 + '|'
            + #9 + FloatToStrF(monrec.SensorData[CTH1set].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTH2set].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTH3set].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTH4set].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTH5set].val, ffGeneral,7,2, fFormatS)
            + #9 + FloatToStrF(monrec.SensorData[CTH6set].val, ffGeneral,7,2, fFormatS)
            ;
  Result := monstr;
end;








procedure TMonitorFileStorage.LogRecord( Var monrec: TMonitorRec);




Var
  dtstr, tstr, monstr, monstrFlow, monstrVTP: String;
  deltat : int64;
  //tfs : TFormatSettings;
begin
  if not fRegisteredUpdate then RegisterForProjectUpdate;
  if not logset then
   begin
     logmsg('TMonitorFileStorage.LogRecord : logset = false -> Reset!');
     Reset;
   end;
  if fUpdateLogFile then      //project update broadcasted
    begin
      logmsg('TMonitorFileStorage.LogRecord : fUpdateLogFile found -> Reset!');
      Reset;
      fUpdateLogFile := false;
    end;
  if not logset then
    begin
    if ProjectCOntrol<>nil then ProjectControl.logmonitornotworking := true;
    logmsg('TMonitorFileStorage.LogRecord : file not working!');
    end;
  //
  //prepare data line
  //
  //monstr := MakeMonRecStrV3( monrec );
  monstr := MakeMonRecStrV4( monrec );
  //
  //append into file
  //{$I-}
  {$I+}
  try
    Append(flogfile);
  except
    on E: exception do
      begin
       logset := false;
       logmsg('TMonitorFileStorage.LogRecord : Append failed! ('+ E.Message + ') data=>>>>>' + monstr);
       if ProjectControl<>nil then ProjectControl.logmonitornotworking := true;
       exit;
    end;
  end;
  try
    Writeln(flogfile, monstr);
  except
    on E: exception do
      begin
       logset := false;
       logmsg('TMonitorFileStorage.LogRecord : writeln failed! ('+ E.Message + ') data=>>>>>' + monstr);
       if ProjectControl<>nil then ProjectControl.logmonitornotworking := true;
       exit;
      end;
  end;
  //reset flag
  if ProjectControl<>nil then ProjectControl.logmonitornotworking := false;
  {$I+}
  try
    closeFile(flogfile);
  except
     on E: exception do logmsg('TMonitorFileStorage.LogRecord : closefile failed! ('+ E.Message + ')');
  end;
end;



//  =============   moniotr rec from str(file) to monitorrec


function MyStrToFloatDef(const s: string; def: double): double;
begin
  try
    Result := StrToFloat(s, GlobalConfig.FormatSettings)
  except
    on EConvertError do Result := def;
  end;
end;


function MonitorStrToMonRecV2(line: string; Var monrec: TMonitorRec; t0: TDateTime): boolean;

Var
  linetr, dtstr, tstr, monstr, monstrFlow, monstrVTP: String;
  deltat : int64;
  fs : TFormatSettings;
  toklist1, toklist2: TTokenlist;
  b1, b2: boolean;
  i1, i2: longint;
  d1, d2, d3, d4, d5: double;
begin
  Result := false;
  linetr := Trim( line );
  if length(line)<1 then exit;
  if line[1]='#' then exit;
  b1 := ParseStrSep( linetr, #9, toklist1 );
  if length(toklist1)<5 then exit;
  fs := GlobalConfig.FormatSettings;
  //
  i1 := StrToIntDef(toklist1[0].s, 0);   //time ms
  d2 := StrToFloatDef(toklist1[1].s, 0, fs);  //temp
  d3 := StrToFloatDef(toklist1[2].s, 0, fs);  //curr A.cm-2
  d4 := StrToFloatDef(toklist1[3].s, 0, fs);  //Voltage V
  d5 := StrToFloatDef(toklist1[4].s, 0, fs);  //Power W.cm-2
  //
  d1 := i1/1000/3600/24;
  monrec.PTCrec.timestamp := t0 + d1;
  monrec.Inorm := d2;
  monrec.U := d3;
  monrec.Pnorm := d4;

  if length(toklist1)>=7 then
    begin
      //pos6 = datetime-str
      d1 := StrToFloatDef(toklist1[6].s, 0, fs);  //Uref
      monrec.Uref := d1;
    end;

  Result := true;

  {// 'Time_from_start[ms]' + #9 + 'Temp[degC]' + #9 + 'Current[A.cm-2]' + #9 + 'Voltage[V]' + #9 + 'Power[W.cm-2]' + #9 + 'FullTime' + #9 + 'Uref[V]');
  monstr := dtstr + #9 + FloatToStrF( NAN, ffGeneral,4,2, fFormatS)
                  + #9 + FloatToStrF( monrec.Inorm,  ffGeneral,7,2, fFormatS) +
                    #9 + FloatToStrF(monrec.U, ffGeneral,7,2, fFormatS) +
                    #9 + FloatToStrF(monrec.Pnorm, ffGeneral,7,2, fFormatS) +
                    #9 + tstr +
                    #9 + FloatToStrF(monrec.Uref, ffGeneral,7,2, fFormatS);
  //
  monstrFlow := 'MFA=(' + FlowRecToStr(monrec.FlowData[CFlowAnode]) + ')' +
                'MFN=(' + FlowRecToStr(monrec.FlowData[CFlowN2]) + ')' +
                'MFC=(' + FlowRecToStr(monrec.FlowData[CFlowCathode]) + ')' +
                'MFR=(' + FlowRecToStr(monrec.FlowData[CFlowRes]) + ')';
  //

  monstrVTP := 'pA='+  MonPressureToStr( monrec.SensorData[CpAnode] ) + ';' +
               'pC='+  MonPressureToStr( monrec.SensorData[CpCathode] ) + ';' +
               'pP='+  MonPressureToStr( monrec.SensorData[CpPiston] ) + ';' +
               'TbH='+  MonPressureToStr( monrec.SensorData[CTBubH2] ) + ';' +
               'TbO='+  MonPressureToStr( monrec.SensorData[CTBubO2] ) + ';' +
               'TcT='+  MonPressureToStr( monrec.SensorData[CTCellTop] ) + ';' +
               'TcB='+  MonPressureToStr( monrec.SensorData[CTCellBot] ) + ';' ;
   }

end;


//=========













function TMonitorFileStorage.TsValid(dt: TDateTime): boolean;
begin
  Result := TimeDeltaNowMS( dt) <= fDataTooOldLimitMS;
end;

function TMonitorFileStorage.FlowRecToStr(r: TFlowRec): string;
begin
   Result:= 'F='+ FloatToStrF( r.massflow, ffGeneral,4,1, fFormatS) +
            '_SP=' + FloatToStrF( r.setpoint, ffGeneral,4,1, fFormatS) +
            '_p=' + FloatToStrF( r.pressure, ffGeneral,4,1, fFormatS) +
            '_T=' + FloatToStrF( r.temp, ffGeneral,3,0, fFormatS) +
            '_Gas='+FlowGasTypeToStr(r.gastype);
end;

procedure TMonitorFileStorage.WriteHeader;  //writes header info (called with new file)
begin
  if not logset then
    begin
      logmsg(' TMonitorFileStorage.WriteHeader: log not set ');
      exit;
    end;
  {$I-}
  Append(flogfile);
  if (IoResult <> 0) then
    begin
    logset := false;
    exit;
    end;
  {$I+}
  Writeln(flogfile, '#monitorfile V4');
  Writeln(flogfile, '#start timestamp: ' + FloatToStr( starttime ) + ' date: ' + DateToStr( starttime ));
  Writeln(flogfile, '#' + ProjectControl.ProjParametersToStr );  
  Writeln(flogfile, MakeHeaderStrV4);
  closeFile(flogfile);
  if (IoResult <> 0) then
    begin
      logmsg(' TMonitorFileStorage.WriteHeader: got error on writing ');
    end;
end;

procedure TMonitorFileStorage.Reset;  //if file not exist call start new file else just reopen, continue appending
Var
  newfile: boolean;
begin
  logset := false;
  newfile := false;
  //check if file exist or if there should be new file created
  if not fileexists(logpath) then newfile := true;
  if ProjectControl<>nil then if ProjectControl.getMonitorUpdateFlag then newfile := true;
  if newfile then //creating new file
  begin
    logmsg('TMonitorFileStorage.Reset: Startimg new file');
    StartNewFile;
  end;
  //{$I-}
  {$I+}
  //append test
  try
    AssignFile(flogfile, logpath );
    Append( flogfile );
    Closefile(flogfile);
    logset := true;
  except
    on E: exception do logmsg('TMonitorFileStorage.Reset: Assign+Append failed! ('+ E.Message + ')');
  end;
  if not logset then
    begin
      logerror('TMonitorFileStorage.Reset: reset (append test) FAILED');
      //
      //!!!!!MUST DO SOMETHING ABOUT IT - TRY Assign new file?
      Inc(fRetryNewFilecnt);
      if (fRetryNewFilecnt=9) then logmsg('TMonitorFileStorage.Reset: this is the last try for new file (9)');
      if (fRetryNewFilecnt< 10) then StartNewFile
      else
        begin
          if ProjectCOntrol<>nil then ProjectControl.logmonitornotworking := true;
        end;

      exit;
    end;
  {$I+}
    //Writeln(logfile);
    //Writeln(logfile, '=================== Reset  =====================');
    //Writeln(logfile);
  if not newfile then WriteHeader;
  logmsg('TMonitorFileStorage.Reset: done');
  logset := true;
  //reset flag indicator
  fRetryNewFilecnt := 0;
  if ProjectControl<>nil then ProjectControl.logmonitornotworking := false;
end;




function TMonitorFileStorage.StartNewFile: boolean;   //file name is based on project sttings - prefix and driectory!
Var
  newfile, b: boolean;
  pathdir: string;
begin
  Result := false;
  logset := false;
  //generate new name
  if ProjectControl<>nil then pathdir:= ProjectControl.ProjDir
  else
      pathdir:= GlobalConfig.globDataDir;
  //
  logpath := pathdir + CPathSlash + CMonitorFileSuperPrefix + GlobalConfig.getNewFilePrefixAndIncCnt + CMonitorFileSuffix;
  logmsg('TMonitorFileStorage.StartNewFile: new log file is: ' + logpath);
  //rewrite file
  b := MakeSureDirExist( pathdir );
  if not b  then  logmsg('TMonitorFileStorage.StartNewFilet: Create dir: failed');
  //check file exist and if yes - that shoulb be error
  if not fileexists(logpath) then
    begin
    //rewrite
    //{$I-}
    {$I+}
    try
      AssignFile(flogfile, logpath );
      Rewrite( flogfile );
      Closefile(flogfile);
      logset := true;
    except
      on E: exception do logmsg('TMonitorFileStorage.StartNewFile: Rewrite FAILED +(' + E.message);
    end;
    if logset then logmsg('TMonitorFileStorage.StartNewFile: Rewrite done');
    end
  else
    begin
      logerror('TMonitorFileStorage.StartNewFile: File EXISTs NO REWRITE done');
      AssignFile(flogfile, logpath );
      logset := true;
    end;
  if not logset then  exit;
  //update strattime and write header
  starttime := Now;
  WriteHeader;
  Result := true;
end;

function TMonitorFileStorage.SetFile(path: string): boolean;
begin
  logset := false;
  logpath := path;
  Reset;
  Result := logset;
end;




// ***************************

procedure MonitorRecFillNaN(Var res: TMonitorRec);
begin
  res.U := NaN;
  res.I := NaN;
  res.P := NaN;
  res.Inorm := NaN;
  res.Pnorm := NaN;
	res.Uraw := NaN;
  res.Iraw := NaN;
	res.Praw := NaN;
  res.Uref := NaN;
  InitPtcRecWithNAN(res.PTCrec, res.PTCstatus);
  InitWithNAN(res.FlowData);
  InitWithNAN( res.ValveData );
  InitWithNAN(res.SensorData );
  InitWithNAN(res.RegData );
end;


procedure MonitorRecTakeMin(Var res: TMonitorRec; in1, in2: PMonitorRec);
var
 x: double;
begin
  if (in1=nil) or (in2=nil) then exit;
  res.U := MyMin(in1^.U, in2^.U);
  res.Inorm := MyMin(in1^.Inorm, in2^.Inorm);
  res.Pnorm := MyMin(in1^.Pnorm, in2.Pnorm);
  res.Uref := MyMin(in1^.Uref, in2^.Uref);
  res.PTCrec.timestamp := MyMin(in1^.PTCrec.timestamp, in2^.PTCrec.timestamp);
end;

procedure MonitorRecTakeMax(Var res: TMonitorRec; in1, in2: PMonitorRec);
var
 x: double;
begin
  if (in1=nil) or (in2=nil) then exit;
  res.U := MyMax(in1.U, in2.U);
  res.Inorm := MyMax(in1^.Inorm, in2^.Inorm);
  res.Pnorm := MyMax(in1^.Pnorm, in2^.Pnorm);
  res.Uref := MyMax(in1^.Uref, in2^.Uref);
  res.PTCrec.timestamp := MyMax(in1^.PTCrec.timestamp, in2^.PTCrec.timestamp);
end;


procedure MonitorRecAdd(Var res: TMonitorRec; in1: PMonitorRec);
var
 x: double;
begin
  if (in1=nil) then exit;
  res.U := res.U + in1^.U;
  res.Inorm := res.Inorm + in1^.Inorm;
  res.Pnorm := res.Pnorm + in1^.Pnorm;
  res.Uref := res.Uref + in1^.Uref;
  res.PTCrec.timestamp := res.PTCrec.timestamp + in1^.PTCrec.timestamp;
end;

procedure MonitorRecMultiplyByNumber(Var res: TMonitorRec; d: double);
begin
  res.U := res.U * d;
  res.Inorm := res.Inorm * d;
  res.Pnorm := res.Pnorm * d;
  res.Uref := res.Uref * d;
  res.PTCrec.timestamp := res.PTCrec.timestamp * d;
end;



initialization

  MonitorFileMain := TMonitorFileStorage.Create;
  MonitorMemHistory := TMonitorMemDataStorage.Create;
  logfiledebug := false;

finalization

   if MonitorFileMain<>nil then begin  MonitorFileMain.Destroy; MonitorFileMain := nil; end;
   if MonitorMemHistory<>nil then begin MonitorMemHistory.Destroy; MonitorMemHistory := nil; end;


end.





//TMonitorFileStorage





end.

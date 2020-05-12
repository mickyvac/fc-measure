Unit MyTCPClientForKolServer;

interface

Uses  MyTCPClient_winsock, myutils, myparseutils,  //no more MyTCPClient
     Classes, SysUtils, StrUtils; {, mydateutils}



{
 NOTE: (MV 2016)
 intended to be run from inside an aquire thread - because it may block for some limited time!!!
 contains function to easily aquire from Kolibrik TCPServer
 ...eg. query by name
 ensures repeated query if failing
}



type

  TKolEventHandlerMethod = procedure(eventstr: string) of object;

  TTCPClientReturnFlags = ( CTCPClientResyncFailed, CTCPCLientNotResponding);

type

TMyTCPClientForKolServer = class (TMyTCPClientThreadSafe)
  public
      constructor Create;
      destructor Destroy; override;
  //note: important inherited functions, procedures:
  //    procedure Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
  //    procedure Close;
  //    function IsOpen: boolean;
  //    procedure ConfigureTCP( server: string; port: string);
  //    function SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
  //    function ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
  //    procedure AssignLogProc(logproc: TLogProcedure);    //logging to independent logger object - must be thread safe
  //    for internal logging use: procedure xLogMsg(s: string);

  //  public
  //    property ConfHost: string read fServer;
  //    property ConfPort: string read fPort;
  //    property Debug: boolean read fDebug write fDebug;
  //    property IsConfigured: boolean read fConfigured;
  public
      function QueryCmdReliable(cmd: string; Var reply: string; tottimeout: longint): boolean;
         //timeout is total time for which function tries to get answer from server, e.g.  10000 ms
         //    if failed or no answer for the timeout, returns false
         //note: for each single send or receive, the  variable  TimeoutSingle should be set and used, default 1000 ms
         //
         //!! this function should handle all states like server disconennected or not responding at all,
         //     can try close+open of the connection when server not responding
         //!! function should mark every request with id and check the answer for the id string to make sure, the answer belongs to the command
         //         see kolServer specification ....   example    
         //                cmd: 'GET setpoint; GET range'   translates into internal cmd: '#123456abc GET setpoint; GET range'   expected int. answer: '#123456abc read Setpoint 0.5; read Range 0'
         //          
         //!!  Kolibrik server uses termination of command by <CR><LF>   and it is not case sensitive
         //this fucntions autamatically adds the terminator string and removes it form reply!!!!!

      function QueryGetVariables(Var ListIN: TStringList; Var ListOUT: TStringList; tottimeout: longint = -2): boolean; 
         //uses internally "QueryCmdReliable"
         //   ListIN constains list of names of variables to query for
         //   ListOUT contains Key-val pairs parsed from reply from Kolibrik-server    example of one string:   'Setpoint=0.04'
      function VerifyConnectionToServer: boolean;
        //tries to send echo to server - if reply OK, returns true and means comm should work
        //use during initialization
      function RegisterEventHandler(f: TKolEventHandlerMethod): boolean;
  private
      fTimeoutSingle: longint;
      fIdcounter: longword;
      fTCPLastTRYConnectDateTime: TDateTime;
      fTerminatingStr: string;
      fProtocolVer: byte;
  public
      property TimeoutSingle: longint read fTimeoutSingle write fTimeoutSingle;
      property ProtocolVer: byte read fProtocolVer write fProtocolVer;
  private
      procedure TCPTryReconnect;
      function TryResync(timeout: longint): boolean;
      procedure MarkCmd(cmd: string; Var markedcmd: string; Var markstr: string);
      function CheckMarkInReply(markedreply: string; markstr: string; Var reply: string): boolean;
      function RemoveLineEnd(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
      function TCPSendReceiveRaw(cmd: string; Var reply: string; timeout: longint): boolean;
      function TCPIsEndOfMessage( reply: string ): boolean;
      function ProcesReplyIntoKeyValList( replydata: string; Var sl: TStringList): boolean;
      function ProcesReplyIntoKeyValListV2(inputlist: TStringList;  replydata: string; Var sl: TStringList): boolean;
      procedure HandleEventMsg(evmsg: string);
      function IsEventMsg(const buf:string): boolean;
      procedure CheckAndRemoveEVENTS(Var buf:string);
      procedure CheckAndRemoveLeadingEVENTS(Var buf:string);
      procedure ClearInternalBuffer;
      function ReceiveReplyMsgEventAware(Var reply: string; clearbuffer: boolean = false): boolean;
      function ExtractFirstMessage( Var buf: string ): string;      
  private
    frecvbuf: string;
    fEventHandlerList: array of TKolEventHandlerMethod;
    fEventHandlerListCount: longint;
end;



implementation


constructor TMyTCPClientForKolServer.Create;
begin
  inherited;
  fTimeoutSingle := 1000;
  fProtocolVer := 1;
  fIdcounter := 0;
  fTCPLastTRYConnectDateTime := 0;
  fTerminatingStr := #13#10;
  SetLength( fEventHandlerList, 100); //intial size
  fEventHandlerListCount := 0;
  frecvbuf := '';
end;


destructor TMyTCPClientForKolServer.Destroy;
begin
  SetLength( fEventHandlerList, 0);
  inherited;
end;

  //note: important inherited functions, procedures:
  //    procedure Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
  //    procedure Close;
  //    function IsOpen: boolean;
  //    procedure ConfigureTCP( server: string; port: string);
  //    function SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
  //    function ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
  //    procedure AssignLogProc(logproc: TLogProcedure);    //logging to independent logger object - must be thread safe
  //    for internal logging use: procedure xLogMsg(s: string);  
          
//procedure TMyTCPClientForKolServer.Open;
//begin
//  inherited;
//  frecvbuf := '';
//end;

  
  
procedure TMyTCPClientForKolServer.TCPTryReconnect;  //reconnects client - but only tries after some time has elapsed - to limit too frequent repetititon
begin
  if TimeDeltaNowMS(fTCPLastTRYConnectDateTime) > 10*fTimeoutSingle then
    begin
      fTCPLastTRYConnectDateTime := Now;
      xLogMsg('TCPTryReconnect - forcing client reconnect');
      Close;
      Open;     
    end;
end;  


procedure TMyTCPClientForKolServer.MarkCmd(cmd: string; Var markedcmd: string; Var markstr: string);
begin
  Inc(fidcounter);
  markstr := '#' + IntToStr( fIdcounter );
  Inc(fIdcounter);
  markedcmd := markstr + ' ' + cmd;
end;


function TMyTCPClientForKolServer.CheckMarkInReply(markedreply: string; markstr: string; Var reply: string): boolean;
Var
  i: longint;
  replyid: string;
begin
  Result := false;
  reply := markedreply;
 //check reply id      pos    leftstr   midstr
  i := posex(' ', markedreply, 1);  //space after idstr  (=first space occurence)
  if i<1 then exit; //no space separator - something is wrong
  reply := RightStr(markedreply, Length(markedreply)-i);
  replyid := leftstr( markedreply, i - 1 );
  if replyid<>markstr then exit;
  Result := true;
end;

  
  
function TMyTCPClientForKolServer.RemoveLineEnd(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
Var
  i: longword;
begin
  Result := '';
  i := Pos(fTerminatingStr, buf);
  if i>0 then
    begin
      Result := Copy(buf, 0 , i-1);
    end
  else Result := buf + '';    //make sure unique str
end;  
  

function TMyTCPClientForKolServer.IsEventMsg(const buf:string): boolean;
begin
  Result :=  posex('EVENT', buf,1) > 0;
end;


procedure TMyTCPClientForKolServer.CheckAndRemoveEVENTS(Var buf:string);
Var
  inin, pn, en, xn, count: longint;
  prestr, estr, reststr: string;
begin
  //procedure HandleEventMsg(evmsg: string);
  inin := length(buf);
  while true do
    begin
      pn := posex('EVENT ', buf,1);
      if pn=0 then break;
      en := posex( fTerminatingStr, buf, pn);
      //extract one EVENT
      xn := en+length(fTerminatingStr);
      count := xn-pn;
      estr := midstr(buf, pn, count );
      prestr := '';
      if pn>1 then prestr := midstr(buf, 1, pn-1);
      reststr := midstr(buf, xn, length(buf)-xn+1 );
      buf := prestr + reststr;
      estr := RemoveLineEnd(estr);
      HandleEventMsg(estr);
      xLogMsg( BinStrToPrintStr( 'EVENT received:' + estr + ' rest:' + buf  ) );
    end;
end;



procedure TMyTCPClientForKolServer.CheckAndRemoveLeadingEVENTS(Var buf:string);
Var
  inin, pn, en, xn, count: longint;
  prestr, estr, reststr: string;
begin
  while true do
    begin
		  pn := posex('EVENT ', buf,1);
		  if pn<>1 then break;  //want it exactly at the beginning!
		  en := posex( fTerminatingStr, buf, pn);
		  //extract one EVENT
		  xn := en+length(fTerminatingStr);
		  count := xn-pn;
		  estr := midstr(buf, pn, count );
		  reststr := midstr(buf, xn, length(buf)-xn+1 );
		  buf := reststr;
		  estr := RemoveLineEnd(estr);
		  HandleEventMsg(estr);
		  xLogMsg( BinStrToPrintStr( 'EVENT received:' + estr + ' rest:' + buf  ) );
    end;
end;


function TMyTCPClientForKolServer.ExtractFirstMessage( Var buf: string ): string;
Var
  en, xn, count: longint;
  reststr: string;
begin
  Result := '';
  en := posex( fTerminatingStr, buf, 1);
  if en<1 then exit;
  count := en - 1 + length(fTerminatingStr);
  Result := midstr( buf, 1, count );
  reststr := midstr( buf, count+1, length(buf) );
  buf := reststr;
end;



procedure TMyTCPClientForKolServer.ClearInternalBuffer;
begin
  frecvbuf := '';
end;

function TMyTCPClientForKolServer.ReceiveReplyMsgEventAware(Var reply: string; clearbuffer: boolean = false): boolean;
//uses fTimeoutSingle
//waits for at least one terminated message or timeouts, all events all filtered out!
Const
  ThisProc = 'ReceiveReplyMsgEventAware ';
Var
  br, ok: boolean;
  tr: longword;
  srep: string;
  len: longint;
begin
  Result := false;
  reply := '';
  if clearbuffer then ClearInternalBuffer;
  //
  tr := TimeDeltaTICKgetT0;
  br := false;
  //read loop
  while true do
     begin
              ok := ReadStringRaw(srep, len, fTimeoutSingle);
              if ok then frecvbuf := frecvbuf + srep;
              //
              CheckAndRemoveLeadingEVENTS( frecvbuf );
              if TCPIsEndOfMessage( frecvbuf ) then
                begin
                  br := true;
                  reply := ExtractFirstMessage( frecvbuf );
                  break;
                end;
              if TimeDeltaTICKNowMS(tr) > fTimeoutSingle then break;
     end;
  if not br then  xLogmsg(ThisProc + 'receive failed(timeout) - buffer content: ' + BinStrToPrintStr( frecvbuf ) );
  Result := br;
end;


function TMyTCPClientForKolServer.TCPSendReceiveRaw(cmd: string; Var reply: string; timeout: longint): boolean;
Const
  ThisProc = 'TCPSendReceiveRaw ';
Var
  bs, br, ok: boolean;
  tr, dts, dtr, tw: longword;
  len: integer;
  sss: string;
begin
  Result := false;
  reply := '';
  if not IsOpen then exit;
  if timeout<1 then timeout := high(longint);
  cmd := cmd + fTerminatingStr;
  bs := SendStringRaw(cmd, timeout, dts);
  if not bs then  xLogmsg(ThisProc + 'send FAILED - ' + BinStrToPrintStr( cmd ));
  //
  br :=  ReceiveReplyMsgEventAware(sss);
  if br then
    begin
       reply := RemoveLineEnd(sss);
       //if Debug then xLogmsg('   ' + ThisProc + '  reply: ' + BinStrToPrintStr( reply ) );
    end;
  Result := bs and br;
end;
  


function TMyTCPClientForKolServer.TCPIsEndOfMessage( reply: string ): boolean;
Var
  i: longint;
begin
  i := posex( fTerminatingStr, reply);
  Result := i>0;
end;  
  

function TMyTCPClientForKolServer.TryResync(timeout: longint): boolean;
Const
  procident = 'TryResync: ';
Var
  b, b1, b2, b3, ok, resyncneeded: boolean;
  idcmdstr, echostr, echorepOKstr, cmd, rep: string;
  i, j, len, k: longint;
  dts, tw: longword;
begin
  Result := false;
  xLogmsg(procident + 'start Resync');
  //send echo and wait low level until reply comes back
  MarkCmd('echo', echostr, idcmdstr);
  echorepOKstr :=  idcmdstr + ' OK echo'; 
  cmd := echostr + fTerminatingStr;
  xLogmsg(procident + ' sending ECHO');
  b := SendStringRaw(cmd, fTimeoutSingle, dts);
  //
  xLogmsg(procident + ' wait for reply, timeout= '+IntToStr(timeout));  
  j := 1;
  i := 0;
  tw := TimeDeltaTICKgetT0;
  while true do
    begin
      //b1 := ReadStringRaw(rep, len, fTimeoutSingle);
      b1 := ReceiveReplyMsgEventAware(rep, true);   //CLEAR BUF!!!
      if b1 then
        begin
           i := posex( echorepOKstr, rep, 1); //i := posex( echostr, rep, 1);
           if i>0 then break; //OK
        end;
      if TimeDeltaTICKNowMS(tw)>timeout then break; 
      Inc(j);
    end;
  //
  if i>0 then
    begin
      xLogmsg(procident + ' OK echo received back OK on iter:'+ IntToStr(j) );
      Result := true;
    end
  else
    begin
      xLogmsg(procident + ' wait for ECHO failed!!! SOMETHING IS WRONG -> should RESTART connection');
      Result := false;
      //because wait for echo failed -> recommended is reopening of the connection!!! 
    end;
  xLogmsg(procident + 'end (Result=' + BoolToStr(Result) + ')');
end;



function TMyTCPClientForKolServer.VerifyConnectionToServer: boolean;
Const
  procident = 'VerifyConnectionToServer';
Var
  b: boolean;
  echostr, idcmdstr, reply: string;
  i1, i2: longint;
begin
  Result := false;
  MarkCmd('echo', echostr, idcmdstr);
  b := TCPSendReceiveRaw(echostr, reply, fTimeoutSingle);
  if b then
    begin
      i2 := posex( idcmdstr, reply, 1);
      if fProtocolVer=1 then i1 := posex( 'echo', reply, 1);
      if fProtocolVer=2 then i1 := posex( 'OK', reply, 1);
      if (i1>0) and (i2>0) then Result := true
      else
        xLogmsg(procident + ' verify reply res i1, i2:'+ IntToStr( i1 ) + ', '+ IntToStr( i2 ) );
    end;
  xLogmsg(procident + ' result:'+ BoolToStr( Result ) );
end;


function TMyTCPClientForKolServer.RegisterEventHandler(f: TKolEventHandlerMethod): boolean;
begin
  Result := false;
  if fEventHandlerListCount >= length( fEventHandlerList ) then
    begin
      setlength( fEventHandlerList, length( fEventHandlerList ) + 100 );
    end;
  //if resize failed
  if fEventHandlerListCount >= length( fEventHandlerList ) then
    begin
      xLogmsg('EE: RegisterEventHandler: no more space');
      exit;
    end;
  fEventHandlerList[ fEventHandlerListCount ] := f;
  inc( fEventHandlerListCount );
  xLogmsg(' RegisterEventHandler: new method registered ' + PointerToStr(@f) + ' now count:' + IntToStr(fEventHandlerListCount) );
  Result := true;
end;


procedure  TMyTCPClientForKolServer.HandleEventMsg(evmsg: string);
var i: longint;
begin
  if Debug then xLogMsg('HandleEVENT: ' + evmsg);
  if fEventHandlerListCount<1 then exit;
  for i:=0 to fEventHandlerListCount-1 do if assigned( fEventHandlerList[i] ) then
    begin
      try
        fEventHandlerList[i](evmsg);
      except
        on E: Exception do xLogmsg('  EE: HandleEventMsg: got error during method '+ PointerToStr(@fEventHandlerList[i]) + ' event: ' + evmsg + ' EXC-msg: ' + E.message);
      end;
    end;
end;


function TMyTCPClientForKolServer.QueryCmdReliable(cmd: string; Var reply: string; tottimeout: longint): boolean;
  //QueryCmdReliable(cmd: string; Var reply: string; Var retflags: TTCPClientReturnFlags; timeout: longint): boolean;
         //timeout is total time for which function tries to get answer from server, e.g.  10000 ms
         //    if failed or no answer for the timeout, returns false
         //note: for each single send or receive, the  variable  fSingleTimeout should be set and used, default 1000 ms
         //
         //!! this function should handle all states like server disconennected or not responding at all,
         //     can try close+open of the connection when server not responding
         //!! function should mark every request with id and check the answer for the id string to make sure, the answer belongs to the command
         //         see kolServer specification ....   example    
         //                cmd: 'GET setpoint; GET range'   intcmd: '#123456abc GET setpoint; GET range'   expected intanswer: '#123456abc read Setpoint 0.5; read Range 0'
         //
         //!!  Kolibrik server uses termination of command by <CR><LF>   and it is not case sensitive
         //this fucntions autamatically adds the terminator string and removes it form reply!!!!!
Const
  ThisProc = 'QueryCmdReliable';
Var
  tw: longword;
  markedcmd, markedreply, markedrawreply,  idcmdstr: string;
  b, bmark, bresync: boolean;
  lenout: integer;
begin
  Result := false;
  reply := '';
  //retflags := [];

  if not IsOpen then
    begin
      xLogMsg(ThisProc + ' port not open, try reconnect');
      TCPTryReconnect;
      if not IsOpen then
        begin
          xLogMsg(ThisProc + ' EEE: connection could not be opened!');
          //Include(retflags, CTCPCannotOpen);
          exit;
        end;
    end;

  tw := TimeDeltaTICKgetT0;
  //add ID tag
  MarkCmd(cmd, markedcmd, idcmdstr);
  while true  do//large main send repeat cycle
    begin
        //mark, send
        b := TCPSendReceiveRaw(markedcmd, markedreply, fTimeoutSingle);
        //markedreply := markedrawreply; //RemoveLineEnd( markedrawreply );
        bmark := b and CheckMarkInReply(markedreply,  idcmdstr, reply);
        //
        if bmark then break;
        if not bmark then   //no reply or wrong lablelled reply
          begin
            if not b then xLogMsg(ThisProc + ' TCPSendReceiveRaw FAILED, tryresync and resend' );
            if b then xLogMsg(ThisProc + ' CheckMarkInReply FAILED, tryresync and resend');
            if not b then
              begin
                bresync := TryResync(fTimeoutSingle*3);
                if not bresync then
                  begin
                    xLogMsg(ThisProc + ' Resync failed, try close, open manually and one LAST RESEND');
                    TCPTryReconnect;
                  end;
              end;
            //try repeat send single time
          end;
        //
        if TimeDeltaTICKNowMS(tw)>tottimeout then break;
    end;
   Result := bmark;
end;




function TMyTCPClientForKolServer.QueryGetVariables(Var ListIN: TStringList; Var ListOUT: TStringList; tottimeout: longint = -2): boolean;
         //uses internally "QueryCmdReliable"
         //   ListIN constains list of names of variables to query for
         //   ListOUT contains Key-val pairs parsed from reply from Kolibrik-server    example of one string:   'Setpoint=0.04'
Var
  cmdstr, replystr: string;
  i, ie: longint;
  bq, bp: boolean;
begin
  Result := false;
  ListOUT.Clear;
  //create cmd from list
  cmdstr := '';
  ie := ListIN.Count;
  for i:=0 to ie-1 do
    begin
      cmdstr := cmdstr + 'GET ' + ListIN.Strings[i];
      if i<ie-1 then cmdstr := cmdstr + ';';
    end;
  //send query
  if tottimeout = -2 then tottimeout := fTimeoutSingle;
  bq := QueryCmdReliable( cmdstr, replystr, tottimeout );
  if not bq then exit;
  // parse reply
  bp := false;
  if fProtocolVer=1 then  bp := ProcesReplyIntoKeyValList( replystr, listOUT);      //walk toklist, fill tstringlist with key-val pairs
  if fProtocolVer=2 then  bp := ProcesReplyIntoKeyValListV2( ListIN, replystr, listOUT);
  Result := bp and bq;
  end;




//==============================  utils ============


function DivideReplyIntoParts( readreply: string; Var namestr, valstr: string): boolean;
Var
  toklist: TTokenList;
  b: boolean;
begin
  Result := false;
  namestr := '';
  valstr := '';
  b := ParseStrSep( readreply, ' ', toklist );
  if (not b) or (length(toklist)<3) then exit;
  if toklist[0].s <> 'read' then exit;
  namestr := toklist[1].s;
  valstr := toklist[2].s;
  Result := true;
end;


function TMyTCPClientForKolServer.ProcesReplyIntoKeyValList( replydata: string; Var sl: TStringList): boolean;
Var
  toklist: TTokenList;
  b1, b, bx : boolean;
  i: integer;
  ns, vs:  string;
begin
  Result := false;
  if sl=nil then exit;
  b1 := ParseStrSep( replydata, ';', toklist );
  if not b1 then exit;
  sl.Clear;
  if length( toklist)<1 then
    begin
      Result := true;
      exit;
    end;
  b := true;
  try
    for i:=0 to length( toklist)-1 do
      begin
        if fProtocolVer=1 then bx := DivideReplyIntoParts( toklist[i].s, ns, vs);
        if fProtocolVer=2 then bx := false;
        b := b and bx;
        sl.Add(ns + '='+ vs);
      end;
  except
    Result := false;
    sl.Clear;
    exit;
  end;
  Result := b;
end;

function TMyTCPClientForKolServer.ProcesReplyIntoKeyValListV2(inputlist: TStringList;  replydata: string; Var sl: TStringList): boolean;
Var
  toklist, minitokl: TTokenList;
  b1, b, bx, bxx : boolean;
  i: integer;
  ns, vs:  string;
begin
  Result := false;
  if sl=nil then exit;
  b1 := ParseStrSep( replydata, ';', toklist );
  if not b1 then exit;
  sl.Clear;
  if length( toklist)<1 then
    begin
      Result := true;
      exit;
    end;
  //assert
  if inputlist.Count > length(toklist) then exit;
  //
  b := true;
  try
    for i:=0 to inputlist.Count-1 do
      begin
         bx := ParseStrSep( toklist[i].s, ' ', minitokl );
         bxx := false;
         if length(minitokl)>1 then if minitokl[0].s = 'OK' then bxx := true;
         ns := inputlist.Strings[i];
         vs := '';
         if bxx then vs := minitokl[1].s;
         b := b and bx and bxx;
         sl.Add(ns + '='+ vs);
      end;
  except
    Result := false;
    sl.Clear;
    exit;
  end;
  Result := b;
end;


end.

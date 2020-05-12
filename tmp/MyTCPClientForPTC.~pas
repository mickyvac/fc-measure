Unit MyTCPClientForPTC;

interface

Uses MyTCPClientForKolServer, myutils, myparseutils,
     Classes, SysUtils, StrUtils;


{
 NOTE: (MV 2016)
 intended to be run from inside an aquire thread - because it may block for some limited time!!!

 contains HIGH LEVEL access to PTC via PTC server (using TCPIP)

 provides functions to cummunicate directly with ptc - PTCQUERY
 makes sure, the connectino with PTC is working (by sending occasionally echo packet - pingPTC),
 - if communication lost, tries to reconnected. Uses inherited KolServer access functions, which takes care
 of reliable connection with the PTC Server.
 - ensures repeated query if failing
}



type

  TTCPClientForPTCResultFlags = ( CPTCServerNotResponding, CPTCNotResponding);

type

  TMyTCPInterfaceForKolPTC = class
  public
      constructor Create;
      destructor Destroy; override;
      //inherited form TMyTCPClientForKolServer:
        //function QueryCmdReliable(cmd: string; Var reply: string; tottimeout: longint): boolean;

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

        //function QueryGetVariables(Var ListIN: TStringList; Var ListOUT: TStringList; tottimeout: longint = -2): boolean;

         //uses internally "QueryCmdReliable"
         //   ListIN constains list of names of variables to query for
         //   ListOUT contains Key-val pairs parsed from reply from Kolibrik-server    example of one string:   'Setpoint=0.04'



  //note: important inherited functions, procedures from MyTcpClient:
  //    procedure Open;    //if server not responding - will block - to interrupt, call Close from MAIN thread (will call close  internally)
  //    procedure Close;
  //    function IsOpen: boolean;
  //    procedure ConfigureTCP( server: string; port: string);
  //    function SendStringRaw(s: string; timeoutMS: longint; var elapsedMS:longword): boolean;
  //    function ReadStringRaw(Var s: string; Var lenout: longint; timeout: longint): boolean;
  //    procedure AssignLogProc(logproc: TLogProcedure);    //logging to independent logger object - must be thread safe
  //    for internal logging use: procedure xLogMsg(s: string);

  public
      fTCPClient: TMyTCPClientForKolServer;
  private
      fTimeoutSingle: longint;
      fIdcounter: longword;
      fTCPLastTRYConnectDateTime: TDateTime;
      fTerminatingStr: string;
  property
      TimeoutSingle: longint read fTimeoutSingle write fTimeoutSingle;
      TCPClient: TMyTCPClientForKolServer read fTCPClient;
  public
      function PTCPing: boolean;
      function PTCQuery (cmd: string; Var reply: string; tottimeout: longint): boolean;
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
  private
      procedure TCPTryReconnect;
      function TryResync(timeout: longint): boolean;
      procedure MarkCmd(cmd: string; Var markedcmd: string; Var markstr: string);
      function CheckMarkInReply(markedreply: string; markstr: string; Var reply: string): boolean;
      function ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
      function TCPSendReceiveRaw(cmd: string; Var reply: string; timeout: longint): boolean;
      function TCPIsEndOfMessage( reply: string ): boolean;
end;



function ProcesReplyIntoKeyValList( replydata: string; Var sl: TStringList): boolean;



implementation


constructor TMyTCPClientForKolServer.Create;
begin
  inherited;
  fTimeoutSingle := 200;
  fIdcounter := 0;
  fTCPLastTRYConnectDateTime := 0;
  fTerminatingStr := #13#10;
end;


destructor TMyTCPClientForKolServer.Destroy;
begin
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
          

  
  
procedure TMyTCPClientForKolServer.TCPTryReconnect;  //reconnects client - but only tries after some time has elapsed - to limit too frequent repetititon
begin
  if TimeDeltaNowMS(fTCPLastTRYConnectDateTime) > fTimeoutSingle then
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

  
  
function TMyTCPClientForKolServer.ExtractReply(Var buf:string): string;  //returns part of the string up to the pakcet end identifier (<CR> in this case)
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
  

function TMyTCPClientForKolServer.TCPSendReceiveRaw(cmd: string; Var reply: string; timeout: longint): boolean;
Const
  ThisProc = 'TCPSendReceiveRaw ';
Var
  bs, br, ok: boolean;
  tr, dts, dtr, tw: longword;
  len: integer;
  srep, sss: string;
begin
  Result := false;
  reply := '';
  if not IsOpen then exit;
  if timeout<1 then timeout := high(longint);
  cmd := cmd + fTerminatingStr;

  if Debug then xLogmsg('   ' + ThisProc + '  sending cmd: ' + BinStrToPrintStr( cmd ) );
  bs := SendStringRaw(cmd, timeout, dts);
  if not bs then  xLogmsg(ThisProc + 'send FAILED - ' + BinStrToPrintStr( cmd ));
  br := false;
  tr := TimeDeltaTICKgetT0;
  if bs then
    begin
         br := false;
         sss := '';
         tw := TimeDeltaTICKgetT0;
         while true do
            begin
              ok := ReadStringRaw(srep, len, timeout);
              if ok then sss := sss + srep;
              if TCPIsEndOfMessage( sss ) then
                begin
                  br := true;
                  break;
                end;
              if TimeDeltaTICKNowMS(tw)>timeout then break;
            end;
         if not br then  xLogmsg(ThisProc + 'receive failed - reply got so far: ' + BinStrToPrintStr( sss ) );
    end;
  dtr := TimeDeltaTICKNowMS( tr );
  if br then
    begin
      reply := ExtractReply( sss );
       if Debug then xLogmsg('   ' + ThisProc + '  reply: ' + BinStrToPrintStr( reply ) );
    end;
  Result := bs and br;
end;
  


function TMyTCPClientForKolServer.TCPIsEndOfMessage( reply: string ): boolean;
Var
  i: longint;
begin
  i := posex( fTerminatingStr, reply);  //space after idstr
  Result := i>0;
end;  
  

function TMyTCPClientForKolServer.TryResync(timeout: longint): boolean;
Const
  procident = 'TryResync: ';
Var
  b, b1, b2, b3, ok, resyncneeded: boolean;
  idcmdstr, echostr, cmd, rep: string;
  i, j, len, k: longint;
  dts, tw: longword;
begin
  Result := false;
  xLogmsg(procident + 'start Resync');
  //send echo and wait low level until reply comes back
  MarkCmd('echo', echostr, idcmdstr);
  cmd := echostr + fTerminatingStr;
  xLogmsg(procident + ' sending ECHO');
  b := SendStringRaw(cmd, fTimeoutSingle, dts);
  //
  xLogmsg(procident + ' wait for reply');  
  j := 1;
  i := 0;
  tw := TimeDeltaTICKgetT0;
  while true do
    begin
      b1 := ReadStringRaw(rep, len, fTimeoutSingle);
      if b1 then
        begin
           i := posex( echostr, rep, 1);
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
  markedcmd, markedreply,  idcmdstr: string; 
  b, bmark, bresync: boolean;
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
  while true  do//large main repeat cycle
    begin
        //mark, send
        MarkCmd(cmd, markedcmd, idcmdstr);
        b := TCPSendReceiveRaw(markedcmd, markedreply, fTimeoutSingle);
        bmark := b and CheckMarkInReply(markedreply,  idcmdstr, reply);
        //
        if bmark then break;
        if not bmark then   //no reply or wrong lablelled reply
          begin
            if not b then xLogMsg(ThisProc + ' TCPSendReceiveRaw FAILED, tryresync and resend' );
            if b then xLogMsg(ThisProc + ' CheckMarkInReply FAILED, tryresync and resend');
            bresync := TryResync(fTimeoutSingle*3);
            if not bresync then
              begin
                xLogMsg(ThisProc + ' Resync failed, try close, open manually and one LAST RESEND');
                TCPTryReconnect
              end;
            //try repeat send single time
            b := TCPSendReceiveRaw(markedcmd, markedreply, fTimeoutSingle);
            bmark := b and CheckMarkInReply(markedreply,  idcmdstr, reply);
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
      cmdstr := cmdstr + ' GET ' + ListIN.Strings[i];
      if i<ie-1 then cmdstr := cmdstr + ';';
    end;
  //send query
  if tottimeout = -2 then tottimeout := fTimeoutSingle;
  bq := QueryCmdReliable( cmdstr, replystr, tottimeout );
  if not bq then exit;
  // parse reply
  bp := ProcesReplyIntoKeyValList( replystr, listOUT);      //walk toklist, fill tstringlist with key-val pairs
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


function ProcesReplyIntoKeyValList( replydata: string; Var sl: TStringList): boolean;
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
        bx := DivideReplyIntoParts( toklist[i].s, ns, vs);
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




end.

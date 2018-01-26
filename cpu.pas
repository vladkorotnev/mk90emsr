unit cpu;

interface

  procedure CpuReset;
  function CpuRun : integer;


implementation

  uses Def, Decoder, Srcdst;

  type Proc1 = procedure;


  procedure CpuReset;
  begin
    procptr := nil;
    RTT_flag := false;
    WAIT_flag := false;
    STEP_flag := false;
    RESET_flag := true;
    HALT_i := false;
    EVNT_i := false;
    VIRQ_i := false;
    cpc := cpc and $FFFE;
{ reset vector }
    ptrw(@reg[R7])^ := $F600;
    psw := $00E0;
  end {CpuReset};


{ execute a single instruction, returns the number of clock cycles }
  function CpuRun : integer;
  var
    vector: word;
  begin
    CpuRun := 1;

{ complete an optional I/O device write }
    if procptr <> nil then
    begin
      Proc1(procptr);
      procptr := nil;
    end {if};

{ pending hardware interrupt? }
    if HALT_i or EVNT_i or VIRQ_i then WAIT_flag := false;
    if STEP_flag or ((psw and H_bit) <> 0) then HALT_i := false;
    STEP_flag := false;
    if WAIT_flag then exit;

{ handle the interrupts }
    if EVNT_i and ((psw and I_bit) = 0) then
    begin
      vector := $0040;
      EVNT_i := false;
    end
    else if VIRQ_i and ((psw and I_bit) = 0) then
    begin
      vector := $00C8;
      VIRQ_i := false;
    end
    else

    begin

{ handle the HALT interrupt }
      if HALT_i then
      begin
        code := $0000;			{ instruction HALT }
        HALT_i := false;
      end
      else
      begin
        opt := WORDSIZE;
        GetLoc ($17);
        code := ptrw(SrcPtr)^;		{ instruction pointed to by the PC }
      end {if};

{ execute the instruction }
      vector := Make_DC0;
      ptrw(@reg[R7])^ := ptrw(@reg[R7])^ and $FFFE;
{ trace mode? }
      if ((psw and T_bit) <> 0) and (vector = 0) and not RTT_flag then
	vector := $000C;
    end {if};

{ execute an optional trap }
    if vector <> 0 then
    begin
      opt := WORDSIZE;
      GetLoc ($26);				{ SP <- SP-2 }
      loc := loc and $FFFE;
      ptrw(DstPtr)^ := psw;			{ (SP) <- PSW }
      GetLoc ($26);				{ SP <- SP-2 }
      ptrw(DstPtr)^ := ptrw(@reg[R7])^;		{ (SP) <- PC }
      loc := vector and $FFFE;
      if (psw and H_bit) <> 0 then Inc (loc, SEL and $FF00);
      ptrw(@reg[R7])^ := ptrw(SrcPtr)^ and $FFFE; { PC <- (vector) }
      Inc (loc, 2);
      psw := ptrw(SrcPtr)^;			{ PSW <- (vector+2) }
    end {if};

    RTT_flag := false;
  end {CpuRun};

end.

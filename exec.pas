{ PDP-11 command execution,
  based on the PDP-11/03 emulator written by Ovsienko V.A. }

unit Exec;


interface

  function Make_TRAP10 : word;		{ XXXXXXX ----    TRAP10   ------ }
  function Make_BR : word;		{ 0004XXX ----    BR      ------ }
  function Make_BNE : word;		{ 0010XXX ----    BNE     ------ }
  function Make_BEQ : word;		{ 0014XXX ----    BEQ     ------ }
  function Make_BVC : word;		{ 1020XXX ----    BVC     ------ }
  function Make_BVS : word;		{ 1024XXX ----    BVS     ------ }
  function Make_BCC : word;		{ 1030XXX ----    BCC     ------ }
  function Make_BCS : word;		{ 1034XXX ----    BCS     ------ }
  function Make_BGE : word;		{ 0020XXX ----    BGE     ------ }
  function Make_BLT : word;		{ 0024XXX ----    BLT     ------ }
  function Make_BGT : word;		{ 0030XXX ----    BGT     ------ }
  function Make_BLE : word;		{ 0034XXX ----    BLE     ------ }
  function Make_BPL : word;		{ 1000XXX ----    BPL     ------ }
  function Make_BMI : word;		{ 1004XXX ----    BMI     ------ }
  function Make_BHI : word;		{ 1010XXX ----    BHI     ------ }
  function Make_BLOS : word;		{ 1014XXX ----    BLOS    ------ }
  function Make_JSR : word;		{ 004RDD  ----    JSR     ------ }
  function Make_MOV : word;		{ 01SSDD  ++0-    MOV     ------ }
  function Make_CMP : word;		{ 02SSDD  ++++    CMP     ------ }
  function Make_BIT : word;		{ 03SSDD  ++0-    BIT     ------ }
  function Make_BIC : word;		{ 04SSDD  ++0-    BIC     ------ }
  function Make_BIS : word;		{ 05SSDD  ++0-    BIS     ------ }
  function Make_ADD : word;		{ 06SSDD  ++++    ADD     ------ }
  function Make_MUL : word;		{ 070RSS  ++0+    MUL     ------ }
  function Make_DIV : word;		{ 071RSS  ++++    DIV     ------ }
  function Make_ASH : word;		{ 072RSS  ++++    ASH     ------ }
  function Make_ASHC : word;		{ 073RSS  ++++    ASHC    ------ }
  function Make_XOR : word;		{ 074RDD  ++0-    XOR     ------ }
  function Make_FIS : word;		{ 0750XXX ----    FIS     ------ }
  function Make_SOB : word;		{ 077RNN  ----    SOB     ------ }
  function Make_EMT : word;		{ 1040XXX ++++    EMT     ------ }
  function Make_TRAP : word;		{ 1044XXX ++++    TRAP    ------ }
  function Make_MOVB : word;		{ 11SSDD  ++0-    MOVB    ------ }
  function Make_CMPB : word;		{ 12SSDD  ++++    CMPB    ------ }
  function Make_BITB : word;		{ 13SSDD  ++0-    BITB    ------ }
  function Make_BICB : word;		{ 14SSDD  ++0-    BICB    ------ }
  function Make_BISB : word;		{ 15SSDD  ++0-    BISB    ------ }
  function Make_SUB : word;		{ 16SSDD  ++++    SUB     ------ }
  function Make_HALT : word;		{ 000000  ----    HALT    ------ }
  function Make_WAIT : word;		{ 000001  ----    WAIT    ------ }
  function Make_RTI : word;		{ 000002  ++++    RTI     ------ }
  function Make_BPT : word;		{ 000003  ++++    BPT     ------ }
  function Make_IOT : word;		{ 000004  ++++    IOT     ------ }
  function Make_RESET : word;		{ 000005  0000    RESET   ------ }
  function Make_RTT : word;		{ 000006  ++++    RTT     ------ }
  function Make_GO : word;		{ 000012  ++++    GO      ------ }
  function Make_STEP : word;		{ 000016  ++++    STEP    ------ }
  function Make_RSEL : word;		{ 000020  ----    RSEL    ------ }
  function Make_MFUS : word;		{ 000021  ----    MFUS    ------ }
  function Make_RCPC : word;		{ 000022  ----    RCPC    ------ }
  function Make_RCPS : word;		{ 000024  ----    RCPS    ------ }
  function Make_MTUS : word;		{ 000031  ----    MTUS    ------ }
  function Make_WCPC : word;		{ 000032  ----    WCPC    ------ }
  function Make_WCPS : word;		{ 000034  ----    WCPS    ------ }
  function Make_JMP : word;		{ 0001SS  ----    JMP     ------ }
  function Make_RTS : word;		{ 00020R  ----    RTS     ------ }
  function Make_CLC : word;		{ 00024C  ++++    CLC     ------ }
  function Make_SEC : word;		{ 00026C  ++++    SEC     ------ }
  function Make_SWAB : word;		{ 0003DD  ++00    SWAB    ------ }
  function Make_CLR : word;		{ 0050DD  0100    CLR     ------ }
  function Make_COM : word;		{ 0051DD  ++01    COM     ------ }
  function Make_INC : word;		{ 0052DD  +++-    INC     ------ }
  function Make_DEC : word;		{ 0053DD  +++-    DEC     ------ }
  function Make_NEG : word;		{ 0054DD  ++++    NEG     ------ }
  function Make_ADC : word;		{ 0055DD  ++++    ADC     ------ }
  function Make_SBC : word;		{ 0056DD  ++++    SBC     ------ }
  function Make_TST : word;		{ 0057DD  ++00    TST     ------ }
  function Make_ROR : word;		{ 0060DD  ++++    ROR     ------ }
  function Make_ROL : word;		{ 0061DD  ++++    ROL     ------ }
  function Make_ASR : word;		{ 0062DD  ++++    ASR     ------ }
  function Make_ASL : word;		{ 0063DD  ++++    ASL     ------ }
  function Make_MARK : word;		{ 0064NN  ----    MARK    ------ }
  function Make_SXT : word;		{ 0067DD  -+0-    SXT     ------ }
  function Make_CLRB : word;		{ 1050DD  0100    CLRB    ------ }
  function Make_COMB : word;		{ 1051DD  ++01    COMB    ------ }
  function Make_INCB : word;		{ 1052DD  +++-    INCB    ------ }
  function Make_DECB : word;		{ 1053DD  +++-    DECB    ------ }
  function Make_NEGB : word;		{ 1054DD  ++++    NEGB    ------ }
  function Make_ADCB : word;		{ 1055DD  ++++    ADCB    ------ }
  function Make_SBCB : word;		{ 1056DD  ++++    SBCB    ------ }
  function Make_TSTB : word;		{ 1057DD  ++00    TSTB    ------ }
  function Make_RORB : word;		{ 1060DD  ++++    RORB    ------ }
  function Make_ROLB : word;		{ 1061DD  ++++    ROLB    ------ }
  function Make_ASRB : word;		{ 1062DD  ++++    ASRB    ------ }
  function Make_ASLB : word;		{ 1063DD  ++++    ASLB    ------ }
  function Make_MTPS : word;		{ 1064SS  ++++    MTPS    ------ }
  function Make_MFPS : word;		{ 1067DD  ----    MFPS    ------ }


implementation

  uses Def, Srcdst;


{ calculate the N and Z bits for value A }
  procedure Check_bit_NZ (A: integer);
  begin
    if A<0 then psw := psw or N_bit
    else if A = 0 then psw := psw or Z_bit;
  end {Check_bit_NZ};


{ calculate the V bit for shifts/rotations, V = N xor C }
  procedure NCtoV;
  begin
    psw := psw or (((psw shr 2) xor (psw shl 1)) and V_bit);
  end;


{ all command execution functions return 0 when no errors occured,
  otherwise an address of a trap vector }

  function Make_TRAP10 : word;		{ XXXXXXX ----    TRAP10   ------ }
  begin
    Make_TRAP10 := $0008;
  end {Make_TRAP10};


  function Make_BR : word;		{ 0004XXX ----    BR      ------ }
  var
    offset: word;
  begin
    offset := Lo(code);
    if (offset and $80) <> 0 then offset := offset or $FF00;
    ptrw(@reg[R7])^ := ptrw(@reg[R7])^ + (offset shl 1);
    Make_BR := 0;
  end {Make_BR};


  function Make_BNE : word;		{ 0010XXX ----    BNE     ------ }
  begin
    if (psw and Z_bit) = 0 then Make_BNE := Make_BR else Make_BNE := 0;
  end {Make_BNE};


  function Make_BEQ : word;		{ 0014XXX ----    BEQ     ------ }
  begin
    if (psw and Z_bit) <> 0 then Make_BEQ := Make_BR else Make_BEQ := 0;
  end {Make_BEQ};


  function Make_BVC : word;		{ 1020XXX ----    BVC     ------ }
  begin
    if (psw and V_bit) = 0 then Make_BVC := Make_BR else Make_BVC := 0;
  end {Make_BVC};


  function Make_BVS : word;		{ 1024XXX ----    BVS     ------ }
  begin
    if (psw and V_bit) <> 0 then Make_BVS := Make_BR else Make_BVS := 0;
  end {Make_BVS};


  function Make_BCC : word;		{ 1030XXX ----    BCC     ------ }
  begin
    if (psw and C_bit) = 0 then Make_BCC := Make_BR else Make_BCC := 0;
  end {Make_BCC};


  function Make_BCS : word;		{ 1034XXX ----    BCS     ------ }
  begin
    if (psw and C_bit) <> 0 then Make_BCS := Make_BR else Make_BCS := 0;
  end {Make_BCS};


  function Make_BGE : word;		{ 0020XXX ----    BGE     ------ }
  begin
    if (((psw shr 2) xor psw) and V_bit) = 0 then Make_BGE := Make_BR
    else Make_BGE := 0;
  end {Make_BGE};


  function Make_BLT : word;		{ 0024XXX ----    BLT     ------ }
  begin
    if (((psw shr 2) xor psw) and V_bit) <> 0 then Make_BLT := Make_BR
    else Make_BLT := 0;
  end {Make_BLT};


  function Make_BGT : word;		{ 0030XXX ----    BGT     ------ }
  begin
    if (psw and Z_bit) = 0 then Make_BGT := Make_BGE else Make_BGT := 0;
  end {Make_BGT};


  function Make_BLE : word;		{ 0034XXX ----    BLE     ------ }
  begin
    if (psw and Z_bit) <> 0 then Make_BLE := Make_BR
    else Make_BLE := Make_BLT;
  end {Make_BLE};


  function Make_BPL : word;		{ 1000XXX ----    BPL     ------ }
  begin
    if (psw and N_bit) = 0 then Make_BPL := Make_BR else Make_BPL := 0;
  end {Make_BPL};


  function Make_BMI : word;		{ 1004XXX ----    BMI     ------ }
  begin
    if (psw and N_bit) <> 0 then Make_BMI := Make_BR else Make_BMI := 0;
  end {Make_BMI};


  function Make_BHI : word;		{ 1010XXX ----    BHI     ------ }
  begin
    if (psw and Z_bit) = 0 then Make_BHI := Make_BCC else Make_BHI := 0;
  end {Make_BHI};


  function Make_BLOS : word;		{ 1014XXX ----    BLOS    ------ }
  begin
    if (psw and Z_bit) <> 0 then Make_BLOS := Make_BR
    else Make_BLOS := Make_BCS;
  end {Make_BLOS};


  function Make_JSR : word;		{ 004RDD  ----    JSR     ------ }
  var
    R, temp: word;
  begin
{ The destination of jsr must not be a register, i.e. the address mode must
  not equal zero. }
    if (code and $38) = 0 then Make_JSR := $0004 else
    begin
      opt := WORDSIZE;
      R := (code shr 5) and $E;			{ index of the R register }
      GetLoc (code and $3F);
      temp := loc and $FFFE;			{ temp <- EA }
      GetLoc ($26);				{ SP <- SP-2, stack <- SP }
      ptrw(DstPtr)^ := ptrw(@reg[R])^;		{ (SP) <- R }
      ptrw(@reg[R])^ := ptrw(@reg[R7])^;	{ R <- PC }
      ptrw(@reg[R7])^ := temp;			{ PC <- temp }
      Make_JSR := 0;
    end;
  end {Make_JSR};


  function Make_MOV : word;		{ 01SSDD  ++0-    MOV     ------ }
  var
    x: word;
  begin
    opt := WORDSIZE;
    x := ptrw(GetSrc((code shr 6) and $3F))^;
    ptrw(GetDst(code and $3F))^ := x;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_MOV := 0;
  end {Make_MOV};


  function Make_CMP : word;		{ 02SSDD  ++++    CMP     ------ }
  var
    s, d, x, y: word;
  begin
    opt := WORDSIZE;
{ different order from SUB! }
    d := ptrw(GetSrc((code shr 6) and $3F))^;
    s := ptrw(GetSrc(code and $3F))^;
    x := d - s;
    y := (x and s) or ((not d) and (x or s));
    psw := psw and not NZVC_bit;
    if y and $8000 <> 0 then psw := psw or C_bit;
    y := y and $C000;
    if (y = $8000) or (y = $4000) then psw := psw or V_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_CMP := 0;
  end {Make_CMP};


  function Make_BIT : word;		{ 03SSDD  ++0-    BIT     ------ }
  var
    s, d: word;
  begin
    opt := WORDSIZE;
    s := ptrw(GetSrc((code shr 6) and $3F))^;
    d := ptrw(GetSrc(code and $3F))^;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(smallint(s and d)));
    Make_BIT := 0;
  end {Make_BIT};


  function Make_BIC : word;		{ 04SSDD  ++0-    BIC     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    x := ptrw(GetSrc((code shr 6) and $3F))^;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^ and not x;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_BIC := 0;
  end {Make_BIC};


  function Make_BIS : word;		{ 05SSDD  ++0-    BIS     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    x := ptrw(GetSrc((code shr 6) and $3F))^;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^ or x;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_BIS := 0;
  end {Make_BIS};


  function Make_ADD : word;		{ 06SSDD  ++++    ADD     ------ }
  var
    DST: ptrw;
    s, x, y: word;
  begin
    opt := WORDSIZE;
    s := ptrw(GetSrc((code shr 6) and $3F))^;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^ + s;
    y := (DST^ and s) or ((not x) and (DST^ or s));
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := psw and not NZVC_bit;
    if y and $8000 <> 0 then psw := psw or C_bit;
    y := y and $C000;
    if (y = $8000) or (y = $4000) then psw := psw or V_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_ADD := 0;
  end {Make_ADD};


  function Make_MUL : word;		{ 070RSS  ++0+    MUL     ------ }
  var
    R: word;
    x, y: integer;		{ must be signed 32-bit }
  begin
    opt := WORDSIZE;
    R := (code shr 5) and $E;
    y := integer(smallint(ptrw(GetSrc(code and $3F))^));
    x := integer(smallint(ptrw(@reg[R])^));
    x := x * y;
    psw := psw and not NZVC_bit;
    Check_Bit_NZ(x);
{ C set if low word overflows }
    if (x>32767) or (x<-32768) then psw := psw or C_bit;
    ptrw(@reg[R])^ := ptrw(PChar(@x)+2)^;	{ most significant word }
    ptrw(@reg[R or 2])^ := word(x);		{ least significant word }
    Make_MUL := 0;
  end {Make_MUL};


  function Make_DIV : word;		{ 071RSS  ++++    DIV     ------ }
  var
    R: word;
    x, y: integer;		{ must be signed 32-bit }
  begin
    opt := WORDSIZE;
    R := (code shr 5) and $E;
    y := integer(smallint(ptrw(GetSrc(code and $3F))^));
    psw := psw and not NZVC_bit;
    if y = 0 then psw := psw or V_bit or C_bit
    else
    begin
      ptrw(PChar(@x)+2)^ := ptrw(@reg[R])^;	{ most significant word }
      ptrw(@x)^ := ptrw(@reg[R or 2])^;		{ least significant word }
      ptrw(@reg[R or 2])^ := word(x mod y);	{ remainder }
      x := x div y;
      ptrw(@reg[R])^ := word(x);		{ quotient }
      Check_Bit_NZ(x);
      if (x>32767) or (x<-32768) then psw := psw or V_bit;
    end;
    Make_DIV := 0;
  end {Make_DIV};


  function Make_ASH : word;		{ 072RSS  ++++    ASH     ------ }
  var
    x, y, m, d: integer;
    R: word;
  begin
    opt := WORDSIZE;
    R := (code shr 5) and $E;
    x := integer(smallint(ptrw(@reg[R])^));
    d := integer(ptrw(GetSrc(code and $3F))^ and $3F);
    psw := psw and not NZVC_bit;
    if d >= $20 then
{ shift right }
    begin
      d := $40 - d;
      if d > 16 then d := 16;
      m := 1 shl (d-1);
      if (x and m) <> 0 then psw := psw or C_bit;
      x := x shr d;
    end
    else if d >= $10 then
{ all bits shifted out left }
    begin
      if x <> 0 then psw := psw or V_bit;
      if (d = 16) and ((x and 1) <> 0) then psw := psw or C_bit;
      x := 0;
    end
    else if d > 0 then
{ shift left up to 15 times }
    begin
      m := 1 shl (16-d);
      if (x and m) <> 0 then psw := psw or C_bit;
      m := (-1) shl (15-d);
      y := x and m;
      if (y <> m) and (y <> 0) then psw := psw or V_bit;
      x := x shl d;
    end {if};
    ptrw(@reg[R])^ := word(x);
    Check_Bit_NZ(integer(smallint(x)));
    Make_ASH := 0;
  end {Make_ASH};


  function Make_ASHC : word;		{ 073RSS  ++++    ASHC    ------ }
  var
    x, y, m, d: integer;
    R: word;
  begin
    opt := WORDSIZE;
    R := (code shr 5) and $E;
    ptrw(PChar(@x)+2)^ := ptrw(@reg[R])^;	{ most significant word }
    ptrw(@x)^ := ptrw(@reg[R or 2])^;		{ least significant word }
    d := integer(ptrw(GetSrc(code and $3F))^ and $3F);
    psw := psw and not NZVC_bit;
    if d >= $20 then
{ shift right }
    begin
      d := $40 - d;
      m := 1 shl (d-1);
      if (x and m) <> 0 then psw := psw or C_bit;
      if x < 0 then m := (-1) shl (32-d) else m := 0;
      x := (x shr d) or m;
    end
    else if d > 0 then
{ shift left }
    begin
      m := 1 shl (32-d);
      if (x and m) <> 0 then psw := psw or C_bit;
      m := (-1) shl (31-d);
      y := x and m;
      if (y <> m) and (y <> 0) then psw := psw or V_bit;
      x := x shl d;
    end {if};
    ptrw(@reg[R])^ := ptrw(PChar(@x)+2)^;	{ most significant word }
    ptrw(@reg[R or 2])^ := word(x);		{ least significant word }
    Check_Bit_NZ(x);
    Make_ASHC := 0;
  end {Make_ASHC};


  function Make_XOR : word;		{ 074RDD  ++0-    XOR     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    x := (code shr 5) and $E;		{ index of the R register }
    DST := ptrw(GetSrc(code and $3F));
    x := DST^ xor ptrw(@reg[x])^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_XOR := 0;
  end {Make_XOR};


{ floating point instructions: FADD, FMUL, FSUB, FDIV }
  function Make_FIS : word;		{ 0750XXX ----    FIS     ------ }
  begin
    if ((code and $E0) = 0) and ((SEL and $0080) = 0) then
	psw := psw or H_bit;
    Make_FIS := $0008;
  end {Make_FIS};


  function Make_SOB : word;		{ 077RNN  ----    SOB     ------ }
  var
    DST: ptrw;
  begin
    DST := ptrw(@reg[(code shr 5) and $E]);
    Dec(DST^);
    if DST^ <> 0 then
	ptrw(@reg[R7])^ := ptrw(@reg[R7])^ - ((code shl 1) and $7E);
    Make_SOB := 0;
  end {Make_SOB};


  function Make_EMT : word;		{ 1040XXX ++++    EMT     ------ }
  begin
    Make_EMT := $0018;
  end {Make_EMT};


  function Make_TRAP : word;		{ 1044XXX ++++    TRAP    ------ }
  begin
    Make_TRAP := $001C;
  end {Make_TRAP};


  function Make_MOVB : word;		{ 11SSDD  ++0-    MOVB    ------ }
  var
    x: byte;
  begin
    opt := BYTESIZE;
    x := ptrb(GetSrc((code shr 6) and $3F))^;
    if (code and $38) <> 0 then
    begin
      GetLoc (code and $3F);
      ptrb(DstPtr)^ := x;
    end
{ if DST is a register, is sign-extended }
    else ptrsmall(@reg[(code shl 1) and $0E])^ := smallint(shortint(x));
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_MOVB := 0;
  end {Make_MOVB};


  function Make_CMPB : word;		{ 12SSDD  ++++    CMPB    ------ }
  var
    s, d, x, y: byte;
  begin
{ different order from SUB! }
    opt := BYTESIZE;
    d := ptrb(GetSrc((code shr 6) and $3F))^;
    s := ptrb(GetSrc(code and $3F))^;
    x := d - s;
    y := (x and s) or ((not d) and (x or s));
    psw := psw and not NZVC_bit;
    if y and $80 <> 0 then psw := psw or C_bit;
    y := y and $C0;
    if (y = $80) or (y = $40) then psw := psw or V_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_CMPB := 0;
  end {Make_CMPB};


  function Make_BITB : word;		{ 13SSDD  ++0-    BITB    ------ }
  var
    s, d: byte;
  begin
    opt := BYTESIZE;
    s := ptrb(GetSrc((code shr 6) and $3F))^;
    d := ptrb(GetSrc(code and $3F))^;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(shortint(s and d)));
    Make_BITB := 0;
  end {Make_BITB};


  function Make_BICB : word;		{ 14SSDD  ++0-    BICB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    x := ptrb(GetSrc((code shr 6) and $3F))^;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^ and not x;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_BICB := 0;
  end {Make_BICB};


  function Make_BISB : word;		{ 15SSDD  ++0-    BISB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    x := ptrb(GetSrc((code shr 6) and $3F))^;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^ or x;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_BISB := 0;
  end {Make_BISB};


  function Make_SUB : word;		{ 16SSDD  ++++    SUB     ------ }
  var
    DST: ptrw;
    s, d, x, y: word;
  begin
    opt := WORDSIZE;
    s := ptrw(GetSrc((code shr 6) and $3F))^;
    DST := ptrw(GetSrc(code and $3F));
    d := DST^;
    x := d - s;
    y := (x and s) or ((not d) and (x or s));
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := psw and not NZVC_bit;
    if y and $8000 <> 0 then psw := psw or C_bit;
    y := y and $C000;
    if (y = $8000) or (y = $4000) then psw := psw or V_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_SUB := 0;
  end {Make_SUB};


  function Make_HALT : word;		{ 000000  ----    HALT    ------ }
  begin
    cpc := ptrw(@reg[R7])^;
    cps := psw;
    loc := $0078;
    if (psw and H_bit) <> 0 then Inc (loc, SEL and $FF00);
    ptrw(@reg[R7])^ := ptrw(SrcPtr)^ and $FFFE;
    Inc (loc, 2);
    psw := ptrw(SrcPtr)^ or H_bit;
    Make_HALT := 0;
  end {Make_HALT};


  function Make_WAIT : word;		{ 000001  ----    WAIT    ------ }
  begin
    WAIT_flag := True;
    Make_WAIT := 0;
  end {Make_WAIT};


  function Make_RTI : word;		{ 000002  ++++    RTI     ------ }
  begin
    opt := WORDSIZE;
{ stack <- SP, SP <- SP+2, PC <- (stack) }
    ptrw(@reg[R7])^ := ptrw(GetSrc($16))^ and $FFFE;
{ stack <- SP, SP <- SP+2, PSW <- (stack) }
    psw := ptrw(GetSrc($16))^;
    if ptrw(@reg[R7])^ >= $E000 then psw := psw or H_bit;
    Make_RTI := 0;
  end {Make_RTI};


  function Make_BPT : word;		{ 000003  ++++    BPT     ------ }
  begin
    Make_BPT := $000C;
  end {Make_BPT};


  function Make_IOT : word;		{ 000004  ++++    IOT     ------ }
  begin
    Make_IOT := $0010;
  end {Make_IOT};


  function Make_RESET : word;		{ 000005  0000    RESET   ------ }
  begin
    RESET_flag := true;
    Make_RESET := 0;
  end {Make_RESET};


  function Make_RTT : word;		{ 000006  ++++    RTT     ------ }
  begin
    RTT_flag := True;
    Make_RTT := Make_RTI;
  end {Make_RTT};


  function Make_GO : word;		{ 000012  ++++    GO      ------ }
  begin
    if (psw and H_bit) = 0 then Make_GO := $0008 else
    begin
      ptrw(@reg[R7])^ := cpc;
      psw := cps and not H_bit;
      Make_GO := 0;
    end;
  end {Make_GO};


  function Make_STEP : word;		{ 000016  ++++    STEP    ------ }
  begin
    if (psw and H_bit) = 0 then Make_STEP := $0008 else
    begin
      STEP_flag := True;
      ptrw(@reg[R7])^ := cpc;
      psw := cps and not H_bit;
      Make_STEP := 0;
    end;
  end {Make_STEP};


  function Make_RSEL : word;		{ 000020  ----    RSEL    ------ }
  begin
    if (psw and H_bit) = 0 then Make_RSEL := $0008 else
    begin
      ptrw(@reg[R0])^ := SEL;
      Make_RSEL := 0;
    end;
  end {Make_RSEL};


  function Make_MFUS : word;		{ 000021  ----    MFUS    ------ }
  begin
    if (psw and H_bit) = 0 then Make_MFUS := $0008 else
    begin
      opt := WORDSIZE;
      ptrw(@reg[R0])^ := ptrw(GetSrc($15))^;
      Make_MFUS := 0;
    end;
  end {Make_MFUS};


  function Make_RCPC : word;		{ 000022  ----    RCPC    ------ }
  begin
    if (psw and H_bit) = 0 then Make_RCPC := $0008 else
    begin
      ptrw(@reg[R0])^ := cpc;
      Make_RCPC := 0;
    end;
  end {Make_RCPC};


  function Make_RCPS : word;		{ 000024  ----    RCPS    ------ }
  begin
    if (psw and H_bit) = 0 then Make_RCPS := $0008 else
    begin
      ptrw(@reg[R0])^ := cps;
      Make_RCPS := 0;
    end;
  end {Make_RCPS};


  function Make_MTUS : word;		{ 000031  ----    MTUS    ------ }
  begin
    if (psw and H_bit) = 0 then Make_MTUS := $0008 else
    begin
      opt := WORDSIZE;
      GetLoc ($25);				{ R5 <- R5-2 }
      loc := loc and $FFFE;
      ptrw(DstPtr)^ := ptrw(@reg[R0])^;		{ (R5) <- R0 }
      Make_MTUS := 0;
    end;
  end {Make_MTUS};


  function Make_WCPC : word;		{ 000032  ----    WCPC    ------ }
  begin
    if (psw and H_bit) = 0 then Make_WCPC := $0008 else
    begin
      cpc := ptrw(@reg[R0])^;
      Make_WCPC := 0;
    end;
  end {Make_WCPC};


  function Make_WCPS : word;		{ 000034  ----    WCPS    ------ }
  begin
    if (psw and H_bit) = 0 then Make_WCPS := $0008 else
    begin
      cps := ptrw(@reg[R0])^;
      Make_WCPS := 0;
    end;
  end {Make_WCPS};


  function Make_JMP : word;		{ 0001SS  ----    JMP     ------ }
{ The destination of JMP must not be a register, i.e. the address mode must
  not equal zero. }
  begin
    if (code and $38) = 0 then Make_JMP := $0004 else
    begin
      opt := WORDSIZE;
      GetLoc (code and $3F);
      ptrw(@reg[R7])^ := loc;		{ always even }
      Make_JMP := 0;
    end;
  end {Make_JMP};


  function Make_RTS : word;		{ 00020R  ----    RTS     ------ }
  var
    R: word;
  begin
    opt := WORDSIZE;
    R := (code shl 1) and $E;		{ index of the R register }
{ PC <- R }
    ptrw(@reg[R7])^ := ptrw(@reg[R])^ and $FFFE;
{ stack <- SP, SP <- SP+2, R <- (stack) }
    ptrw(@reg[R])^ := ptrw(GetSrc($16))^;
    Make_RTS := 0;
  end {Make_RTS};


  function Make_CLC : word;		{ 00024C  ++++    CLC     ------ }
  begin
    psw := psw and not (code and $F);
    Make_CLC := 0;
  end {Make_CLC};


  function Make_SEC : word;		{ 00026C  ++++    SEC     ------ }
  begin
    psw := psw or (code and $F);
    Make_SEC := 0;
  end {Make_SEC};


  function Make_SWAB : word;		{ 0003DD  ++00    SWAB    ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := Swap(DST^);
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := psw and not NZVC_bit;
    Check_Bit_NZ(integer(shortint(Lo(x))));	{ N,Z according to low byte of the result }
    Make_SWAB := 0;
  end {Make_SWAB};


  function Make_CLR : word;		{ 0050DD  0100    CLR     ------ }
  begin
    opt := WORDSIZE;
    ptrw(GetDst(code and $3F))^ := 0;
    psw := (psw and not NZVC_bit) or Z_bit;
    Make_CLR := 0;
  end {Make_CLR};


  function Make_COM : word;		{ 0051DD  ++01    COM     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := not DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    DST^ := x;
    psw := (psw and not NZV_bit) or C_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_COM := 0;
  end {Make_COM};


  function Make_INC : word;		{ 0052DD  +++-    INC     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^ + 1;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    psw := psw and not NZV_bit;
    if x = $8000 then psw := psw or V_bit;
    DST^ := x;
    Check_Bit_NZ(integer(smallint(x)));
    Make_INC := 0;
  end {Make_INC};


  function Make_DEC : word;		{ 0053DD  +++-    DEC     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^ - 1;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    psw := psw and not NZV_bit;
    if x = $7FFF then psw := psw or V_bit;
    DST^ := x;
    Check_Bit_NZ(integer(smallint(x)));
    Make_DEC := 0;
  end {Make_DEC};


  function Make_NEG : word;		{ 0054DD  ++++    NEG     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    psw := psw and not NZVC_bit;
    if x = $8000 then psw := psw or V_bit;
    x := -x;
    DST^ := x;
    if x <> 0 then psw := psw or C_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_NEG := 0;
  end {Make_NEG};


  function Make_ADC : word;		{ 0055DD  ++++    ADC     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    psw := psw and not NZV_bit;
    if (psw and C_bit) <> 0 then
    begin
      if x = $7FFF then psw := psw or V_bit;
      if x <> $FFFF then psw := psw and not C_bit;
      Inc(x);
    end;
    DST^ := x;
    Check_Bit_NZ(integer(smallint(x)));
    Make_ADC := 0;
  end {Make_ADC};


  function Make_SBC : word;		{ 0056DD  ++++    SBC     ------ }
  var
    DST: ptrw;
    x: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    psw := psw and not NZV_bit;
    if (psw and C_bit) <> 0 then
    begin
      if x = $8000 then psw := psw or V_bit;
      if x <> 0 then psw := psw and not C_bit;
      Dec(x);
    end;
    DST^ := x;
    Check_Bit_NZ(integer(smallint(x)));
    Make_SBC := 0;
  end {Make_SBC};


  function Make_TST : word;		{ 0057DD  ++00    TST     ------ }
  var
    x: word;
  begin
    opt := WORDSIZE;
    x := ptrw(GetSrc(code and $3F))^;
    psw := psw and not NZVC_bit;
    Check_Bit_NZ(integer(smallint(x)));
    Make_TST := 0;
  end {Make_TST};


  function Make_ROR : word;		{ 0060DD  ++++    ROR     ------ }
  var
    DST: ptrw;
    x, C1: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    C1 := x and 1;
    x := x shr 1;
    if (psw and C_bit) <> 0 then x := x or $8000;
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(smallint(x)));
    NCtoV;
    Make_ROR := 0;
  end {Make_ROR};


  function Make_ROL : word;		{ 0061DD  ++++    ROL     ------ }
  var
    DST: ptrw;
    x, C1: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    if (x and $8000) = 0 then C1 := 0 else C1 := 1;
    x := x shl 1;
    if (psw and C_bit) <> 0 then x := x or 1;
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(smallint(x)));
    NCtoV;
    Make_ROL := 0;
  end {Make_ROL};


  function Make_ASR : word;		{ 0062DD  ++++    ASR     ------ }
  var
    DST: ptrw;
    x, C1: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    C1 := x and 1;
    x := (x and $8000) or (x shr 1);
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(smallint(x)));
    NCtoV;
    Make_ASR := 0;
  end {Make_ASR};


  function Make_ASL : word;		{ 0063DD  ++++    ASL     ------ }
  var
    DST: ptrw;
    x, C1: word;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrw(DstPtr);
    if (x and $8000) = 0 then C1 := 0 else C1 := C_bit;
    x := x shl 1;
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(smallint(x)));
    NCtoV;
    Make_ASL := 0;
  end {Make_ASL};


  function Make_MARK : word;		{ 0064NN  ----    MARK    ------ }
  begin
    opt := WORDSIZE;
{ SP <- PC + 2*N }
    ptrw(@reg[R6])^ := ptrw(@reg[R7])^ + ((code shl 1) and $7E);
{ PC <- FP }
    ptrw(@reg[R7])^ := ptrw(@reg[R5])^ and $FFFE;
{ stack <- SP, SP <- SP+2, FP <- (stack) }
    ptrw(@reg[R5])^ := ptrw(GetSrc($16))^;
    Make_MARK := 0;
  end {Make_MARK};


  function Make_SXT : word;		{ 0067DD  -+0-    SXT     ------ }
  var
    DST: ptrw;
  begin
    opt := WORDSIZE;
    DST := ptrw(GetDst(code and $3F));
    if (psw and N_bit) = 0 then
    begin
      DST^ := 0;
      psw := psw or Z_bit;
    end
    else
    begin
      DST^ := $FFFF;
      psw := psw and not Z_bit;
    end;
    psw := psw and not V_bit;
    Make_SXT := 0;
  end {Make_SXT};


  function Make_CLRB : word;		{ 1050DD  0100    CLRB    ------ }
  begin
    opt := BYTESIZE;
    ptrb(GetDst(code and $3F))^ := 0;
    psw := (psw and not NZVC_bit) or Z_bit;
    Make_CLRB := 0;
  end {Make_CLRB};


  function Make_COMB : word;		{ 1051DD  ++01    COMB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := not DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    DST^ := x;
    psw := (psw and not NZV_bit) or C_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_COMB := 0;
  end {Make_COMB};


  function Make_INCB : word;		{ 1052DD  +++-    INCB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^ + 1;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    if x = $80 then psw := psw or V_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_INCB := 0;
  end {Make_INCB};


  function Make_DECB : word;		{ 1053DD  +++-    DECB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^ - 1;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    DST^ := x;
    psw := psw and not NZV_bit;
    if x = $7F then psw := psw or V_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_DECB := 0;
  end {Make_DECB};


  function Make_NEGB : word;		{ 1054DD  ++++    NEGB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    psw := psw and not NZVC_bit;
    if x = $80 then psw := psw or V_bit;
    x := -x;
    DST^ := x;
    if x <> 0 then psw := psw or C_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_NEGB := 0;
  end {Make_NEGB};


  function Make_ADCB : word;		{ 1055DD  ++++    ADCB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    psw := psw and not NZV_bit;
    if (psw and C_bit) <> 0 then
    begin
      if x = $7F then psw := psw or V_bit;
      if x <> $FF then psw := psw and not C_bit;
      Inc(x);
    end;
    DST^ := x;
    Check_Bit_NZ(integer(shortint(x)));
    Make_ADCB := 0;
  end {Make_ADCB};


  function Make_SBCB : word;		{ 1056DD  ++++    SBCB    ------ }
  var
    DST: ptrb;
    x: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    psw := psw and not NZV_bit;
    if (psw and C_bit) <> 0 then
    begin
      if x = $80 then psw := psw or V_bit;
      if x <> 0 then psw := psw and not C_bit;
      Dec(x);
    end;
    DST^ := x;
    Check_Bit_NZ(integer(shortint(x)));
    Make_SBCB := 0;
  end {Make_SBCB};


  function Make_TSTB : word;		{ 1057DD  ++00    TSTB    ------ }
  var
    x: byte;
  begin
    opt := BYTESIZE;
    x := ptrb(GetSrc(code and $3F))^;
    psw := psw and not NZVC_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_TSTB := 0;
  end {Make_TSTB};


  function Make_RORB : word;		{ 1060DD  ++++    RORB    ------ }
  var
    DST: ptrb;
    x, C1: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    C1 := x and 1;
    x := x shr 1;
    if (psw and C_bit) <> 0 then x := x or $80;
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(shortint(x)));
    NCtoV;
    Make_RORB := 0;
  end {Make_RORB};


  function Make_ROLB : word;		{ 1061DD  ++++    ROLB    ------ }
  var
    DST: ptrb;
    x, C1: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    if (x and $80) = 0 then C1 := 0 else C1 := C_bit;
    x := x shl 1;
    if (psw and C_bit) <> 0 then x := x or 1;
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(shortint(x)));
    NCtoV;
    Make_ROLB := 0;
  end {Make_ROLB};


  function Make_ASRB : word;		{ 1062DD  ++++    ASRB    ------ }
  var
    DST: ptrb;
    x, C1: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    C1 := x and 1;
    x := (x and $80) or (x shr 1);
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(shortint(x)));
    NCtoV;
    Make_ASRB := 0;
  end {Make_ASRB};


  function Make_ASLB : word;		{ 1063DD  ++++    ASLB    ------ }
  var
    DST: ptrb;
    x, C1: byte;
  begin
    opt := BYTESIZE;
    DST := ptrb(GetSrc(code and $3F));
    x := DST^;
    if (code and $38) <> 0 then DST := ptrb(DstPtr);
    if (x and $80) = 0 then C1 := 0 else C1 := C_bit;
    x := x shl 1;
    DST^ := x;
    psw := (psw and not NZVC_bit) or C1;
    Check_Bit_NZ(integer(shortint(x)));
    NCtoV;
    Make_ASLB := 0;
  end {Make_ASLB};


  function Make_MTPS : word;		{ 1064SS  ++++    MTPS    ------ }
  var
    x: byte;
  begin
    opt := BYTESIZE;
    x := ptrb(GetSrc(code and $3F))^;
    psw := (psw and $FF10) or (x and $00EF);	{ T bit left unchanged }
    Make_MTPS := 0;
  end {Make_MTPS};


  function Make_MFPS : word;		{ 1067DD  ++0-    MFPS    ------ }
  var
    x: byte;
  begin
    x := byte(psw);
    opt := BYTESIZE;
    if (code and $38) <> 0 then
    begin
      GetLoc (code and $3F);
      ptrb(DstPtr)^ := x;
    end
{ if DST is a register, is sign-extended }
    else ptrsmall(@reg[(code shl 1) and $0E])^ := smallint(shortint(psw));
    psw := psw and not NZV_bit;
    Check_Bit_NZ(integer(shortint(x)));
    Make_MFPS := 0;
  end {Make_MFPS};


end.

{ PDP-11 assembler and disassembler,
  the disassembler part is based on program pinst.c written by Martin Minow }

unit Pdp11dis;

interface

  var
{ assembler input }
    InBuf: string[64];
    InIndex: integer;
{ assembler output }
    OutBuf: array[0..2] of word;
    OutIndex: integer;

  function FetchWord : word;
  procedure StoreWord (x: word);
  function ScanMnemTab (x: integer) : integer;
  function Mnemonic (i: integer; size: char) : string;
  function Arguments (i: integer; x: word) : string;
  procedure Assemble;
  

implementation

  uses SysUtils, Def, Numbers;



{ COMMON DATA FOR BOTH THE ASSEMBLER AND DISASSEMBLER }

type

  kinds = (
    ILLOP,	{ illop }
    NONE,	{ halt }
    RTS,	{ rts reg }
    DOUBLE,	{ mov src,dst }
    ADD,	{ add src,dst }
    SWBYTE,	{ sop[b] dst }
    SINGLE,	{ sop dst }
    JSR,	{ jsr reg,dst }
    MUL,	{ mul src,reg }
    BR,		{ br addr }
    SOB,	{ sob reg,addr }
    SPL,	{ spl n }
    MARK,	{ mark n }
    TRAP,	{ trap n }
    CODE	{ se[cvnz] }
  );

  tab = record
    mask: word;
    op: word;
    str: string[5];
    kind: kinds;
  end;


const

  NTAB = 86; {index of the last item in the 'mnem' array}

  mnem: array[0..NTAB] of tab = (
    (	mask:$FFFF;	op:$0000;	str:'halt';	kind:NONE	),
    (	mask:$FFFF;	op:$0001;	str:'wait';	kind:NONE	),
    (	mask:$FFFF;	op:$0002;	str:'rti';	kind:NONE	),
    (	mask:$FFFF;	op:$0003;	str:'bpt';	kind:NONE	),
    (	mask:$FFFF;	op:$0004;	str:'iot';	kind:NONE	),
    (	mask:$FFFF;	op:$0005;	str:'reset';	kind:NONE	),
    (	mask:$FFFF;	op:$0006;	str:'rtt';	kind:NONE	),
    (	mask:$FFFF;	op:$000A;	str:'go';	kind:NONE	),
    (	mask:$FFFC;	op:$0008;	str:'go';	kind:NONE	),
    (	mask:$FFFF;	op:$000E;	str:'step';	kind:NONE	),
    (	mask:$FFFC;	op:$000C;	str:'step';	kind:NONE	),
    (	mask:$FFF7;	op:$0010;	str:'rsel';	kind:NONE	),
    (	mask:$FFFF;	op:$0011;	str:'mfus';	kind:NONE	),
    (	mask:$FFFE;	op:$0012;	str:'rcpc';	kind:NONE	),
    (	mask:$FFFC;	op:$0014;	str:'rcps';	kind:NONE	),
    (	mask:$FFFF;	op:$0019;	str:'mtus';	kind:NONE	),
    (	mask:$FFFE;	op:$001A;	str:'wcpc';	kind:NONE	),
    (	mask:$FFFC;	op:$001C;	str:'wcps';	kind:NONE	),
    (	mask:$FFE0;	op:$0000;	str:'illop';	kind:ILLOP	),
    (	mask:$FFC0;	op:$0040;	str:'jmp';	kind:SINGLE	),
    (	mask:$FFF8;	op:$0080;	str:'rts';	kind:RTS	),
    (	mask:$FFF0;	op:$0088;	str:'illop';	kind:ILLOP	),
    (	mask:$FFF8;	op:$0098;	str:'spl';	kind:SPL	),
    (	mask:$FFFF;	op:$00A0;	str:'nop';	kind:NONE	),
    (	mask:$FFFF;	op:$00A1;	str:'clc';	kind:NONE	),
    (	mask:$FFF0;	op:$00A0;	str:'clear';	kind:CODE	),
    (	mask:$FFFF;	op:$00B1;	str:'sec';	kind:NONE	),
    (	mask:$FFF0;	op:$00B0;	str:'set';	kind:CODE	),
    (	mask:$FFC0;	op:$00C0;	str:'swab';	kind:SINGLE	),
    (	mask:$FF00;	op:$0100;	str:'br';	kind:BR		),
    (	mask:$FF00;	op:$0200;	str:'bne';	kind:BR		),
    (	mask:$FF00;	op:$0300;	str:'beq';	kind:BR		),
    (	mask:$FF00;	op:$0400;	str:'bge';	kind:BR		),
    (	mask:$FF00;	op:$0500;	str:'blt';	kind:BR		),
    (	mask:$FF00;	op:$0600;	str:'bgt';	kind:BR		),
    (	mask:$FF00;	op:$0700;	str:'ble';	kind:BR		),
    (	mask:$FE00;	op:$0800;	str:'jsr';	kind:JSR	),
    (	mask:$7FC0;	op:$0A00;	str:'clr';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0A40;	str:'com';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0A80;	str:'inc';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0AC0;	str:'dec';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0B00;	str:'neg';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0B40;	str:'adc';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0B80;	str:'sbc';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0BC0;	str:'tst';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0C00;	str:'ror';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0C40;	str:'rol';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0C80;	str:'asr';	kind:SWBYTE	),
    (	mask:$7FC0;	op:$0CC0;	str:'asl';	kind:SWBYTE	),
    (	mask:$FFC0;	op:$0D00;	str:'mark';	kind:MARK	),
    (	mask:$FFC0;	op:$0D40;	str:'mfpi';	kind:SINGLE	),
    (	mask:$FFC0;	op:$0D80;	str:'mtpi';	kind:SINGLE	),
    (	mask:$FFC0;	op:$0DC0;	str:'sxt';	kind:SINGLE	),
    (	mask:$FE00;	op:$0E00;	str:'illop';	kind:ILLOP	),
    (	mask:$7000;	op:$1000;	str:'mov';	kind:DOUBLE	),
    (	mask:$7000;	op:$2000;	str:'cmp';	kind:DOUBLE	),
    (	mask:$7000;	op:$3000;	str:'bit';	kind:DOUBLE	),
    (	mask:$7000;	op:$4000;	str:'bic';	kind:DOUBLE	),
    (	mask:$7000;	op:$5000;	str:'bis';	kind:DOUBLE	),
    (	mask:$F000;	op:$6000;	str:'add';	kind:ADD	),
    (	mask:$F000;	op:$E000;	str:'sub';	kind:ADD	),
    (	mask:$FE00;	op:$7000;	str:'mul';	kind:MUL	),
    (	mask:$FE00;	op:$7200;	str:'div';	kind:MUL	),
    (	mask:$FE00;	op:$7600;	str:'ashc';	kind:MUL	),
    (	mask:$FE00;	op:$7400;	str:'ash';	kind:MUL	),
    (	mask:$FE00;	op:$7800;	str:'xor';	kind:JSR	),
    (	mask:$FFF8;	op:$7A00;	str:'fadd';	kind:RTS	),
    (	mask:$FFF8;	op:$7A08;	str:'fsub';	kind:RTS	),
    (	mask:$FFF8;	op:$7A10;	str:'fmul';	kind:RTS	),
    (	mask:$FFF8;	op:$7A18;	str:'fdiv';	kind:RTS	),
    (	mask:$FE00;	op:$7E00;	str:'sob';	kind:SOB	),
    (	mask:$F800;	op:$7800;	str:'illop';	kind:ILLOP	),
    (	mask:$FF00;	op:$8000;	str:'bpl';	kind:BR		),
    (	mask:$FF00;	op:$8100;	str:'bmi';	kind:BR		),
    (	mask:$FF00;	op:$8600;	str:'bhis';	kind:BR		),
    (	mask:$FF00;	op:$8200;	str:'bhi';	kind:BR		),
    (	mask:$FF00;	op:$8300;	str:'blos';	kind:BR		),
    (	mask:$FF00;	op:$8400;	str:'bvc';	kind:BR		),
    (	mask:$FF00;	op:$8500;	str:'bvs';	kind:BR		),
    (	mask:$FF00;	op:$8700;	str:'blo';	kind:BR		),
    (	mask:$FF00;	op:$8800;	str:'emt';	kind:TRAP	),
    (	mask:$FF00;	op:$8900;	str:'trap';	kind:TRAP	),
    (	mask:$FFC0;	op:$8D00;	str:'mtps';	kind:SINGLE	),
    (	mask:$FFC0;	op:$8D40;	str:'mfpd';	kind:SINGLE	),
    (	mask:$FFC0;	op:$8D80;	str:'mtpd';	kind:SINGLE	),
    (	mask:$FFC0;	op:$8DC0;	str:'mfps';	kind:SINGLE	),
    (	mask:$0000;	op:$0000;	str:'illop';	kind:ILLOP	)
  );


  NREG = 9; {index of the last item in the 'reg' array}

  treg: array[0..NREG] of tab = (
    (	mask:$FFFF;	op:$0000;	str:'r0';	kind:NONE	),
    (	mask:$FFFF;	op:$0001;	str:'r1';	kind:NONE	),
    (	mask:$FFFF;	op:$0002;	str:'r2';	kind:NONE	),
    (	mask:$FFFF;	op:$0003;	str:'r3';	kind:NONE	),
    (	mask:$FFFF;	op:$0004;	str:'r4';	kind:NONE	),
    (	mask:$FFFF;	op:$0005;	str:'r5';	kind:NONE	),
    (	mask:$FFFF;	op:$0006;	str:'sp';	kind:NONE	),
    (	mask:$FFFF;	op:$0007;	str:'pc';	kind:NONE	),
    (	mask:$FFFF;	op:$0006;	str:'r6';	kind:NONE	),
    (	mask:$FFFF;	op:$0007;	str:'r7';	kind:NONE	)
  );


{ fetch a word from the memory, advance the location counter }
function FetchWord : word;
begin
  FetchWord := ptrw(SrcPtr)^;
  Inc (loc, 2);
end {FetchWord};


procedure StoreWord (x: word);
begin
  if IsInRom (loc) or IsInRam (loc) then ptrw(SrcPtr)^ := x;
  Inc (loc, 2);
end {StoreWord};



{ DISASSEMBLER FUNCTIONS }

{ returns the name of the register r }
function preg (r: word) : string;
begin
  preg := treg[r and 7].str;
end {preg};


{ returns the addressing mode }
function paddr (m: word) : string;
var
  r,t: word;
  s: string[1];
begin
  r := m and $07;
  if (m and $08) = 0 then s := '' else s := '@';

  case m and $38 of

    $00:
      paddr := preg(r);

    $08:
      paddr := '(' + preg(r) + ')';

    $10, $18:
      if r = $07 then
        paddr := s + '#' + WordToStr(FetchWord, ' ')
      else
        paddr := s + '(' + preg(r) + ')+';

    $20, $28:
      paddr := s + '-(' + preg(r) + ')';

    $30, $38:
      if r = $07 then
        begin
          t := FetchWord; { fetch word first to have correct loc }
          paddr := s + WordToStr(loc + t, '0')
        end
      else
        paddr := s + WordToStr(FetchWord, '0') + '(' + preg(r) + ')';

  end {case};
end {paddr};


{ returns the names of the CCR register bits }
function ccr (x: word) : string;
var
  s: string[4];
begin
  s := '';
  if (x and 1) <> 0 then s := s + 'c';
  if (x and 2) <> 0 then s := s + 'v';
  if (x and 4) <> 0 then s := s + 'z';
  if (x and 8) <> 0 then s := s + 'n';
  ccr := s;
end {ccr};


{ returns the index to the 'mnem' table for op-code x }
function ScanMnemTab (x: integer) : integer;
begin
  for result := 0 to NTAB do
  begin
    if (x and mnem[result].mask) = mnem[result].op then Exit;
  end {for};
  result := NTAB;
end {ScanMnemTab};


{ returns the mnemonic }
function Mnemonic (
	i: integer;	{ index to the 'mnem' table }
	size: char)	{ 'b' for byte-size, otherwise ' ' }
	: string;
begin
  Result := mnem[i].str;
  if (mnem[i].kind = SWBYTE) or (mnem[i].kind = DOUBLE) then
    Result := Result + size;
end {Mnemonic};


{ returns the arguments }
function Arguments (
	i: integer;	{ index to the 'mnem' table }
	x: word)	{ op-code }
	: string;
begin
  case mnem[i].kind of

    SPL:
      Arguments := digits[(x and $07) + 1];

    RTS:
      Arguments := preg(x);

    SINGLE, SWBYTE:
      Arguments := paddr(x);

    DOUBLE, ADD:
      Arguments := paddr(x div 64) + ',' + paddr(x);

    JSR:
      Arguments := preg (x div 64) + ',' + paddr(x);

    MUL:
      Arguments := paddr(x) + ',' + preg(x div 64);

    BR:
      begin
        x := x and $FF;
        if (x and $80) <> 0 then x := x or $FF00;
        Arguments := WordToStr(loc + 2*x, '0');
      end;

    SOB:
      Arguments := preg(x div 64) + ',' + WordToStr(loc - 2*(x and $3F), '0');

    MARK:
      Arguments := WordToStr(x and $3F, ' ');

    TRAP:
      Arguments := WordToStr(x and $FF, ' ');

    CODE:
      Arguments := ccr(x);

    else
      Arguments := '';

  end {case};
end {Arguments};



{ ASSEMBLER FUNCTIONS }

{ compare the string 's' with the 'InBuf' at location 'InIndex' without
  the case sensitivity,
  update the 'InIndex' and return True if both string match }
function ParseString (s: string): boolean;
var
  n: integer;
begin
  ParseString := False;
  if InIndex + Length(s) - 1 > Length(InBuf) then exit;
  n := 0;
  while n < Length(s) do
  begin
    if s[n+1] <> LowerCase(InBuf[InIndex + n]) then exit;
    Inc (n);
  end {while};
  Inc (InIndex, n);
  ParseString := True;
end {ParseString};


{ returns index to the table of type 'tab' or -1 if mnemonic not found }
function ParseTable (t: array of tab; last: integer) : integer;
begin
  for result := 0 to last do
  begin
    if ParseString (t[result].str) then exit;
  end {for};
  result := -1;
end {ParseTable};


{ function expects a number in base 'radix',
  returns count of processed characters,
  updates the InIndex,
  places the value of the number in OutBuf[OutIndex] }
function ParseNumber : integer;
var
  x, y: word;
begin
  x := 0;
  result := 0;
  while InIndex <= Length(InBuf) do
  begin
    y := word(GetDigit(InBuf[InIndex]));
    if y >= radix then break;
    x := x*radix + y;
    InIndex := InIndex + 1;
    Inc (result);
  end;
  OutBuf[OutIndex] := x;
end {ParseNumber};


{ move the 'InIndex' to the first character different from space,
  returns True if at least single space processed }
function ParseBlanks : boolean;
begin
  ParseBlanks := False;
  while InIndex <= Length(InBuf) do
  begin
    if InBuf[InIndex] <> ' ' then break;
    ParseBlanks := True;
    Inc (InIndex);
  end;
end {ParseBlanks};


{ a specified character expected }
function ParseChar (c: char) : boolean;
begin
  result := (InIndex <= Length(InBuf)) and (InBuf[InIndex] = c);
  if result then Inc (InIndex);
end {ParseChar};


{ comma expected }
function ParseComma : boolean;
begin
  ParseBlanks;
  ParseComma := ParseChar (',');
  ParseBlanks;
end {ParseComma};


{ returns address mode or value > $3F if error }
function ParseAddr : word;
var
  i: integer;
begin
  result := $8000;
  if ParseChar ('@') then result := result or $0008;

{ Ri }
  i := ParseTable (treg, NREG);
  if i >= 0 then result := result or treg[i].op

{ #n }
  else if ParseChar ('#') then
  begin
    result := result or $0017;
    if ParseNumber = 0 then exit;		{ failure, a number expected }
    Inc (OutIndex);
  end

{ -(Ri) }
  else if ParseChar ('-') then
  begin
    if not ParseChar ('(') then exit;	{ failure, opening bracket expected }
    i := ParseTable (treg, NREG);
    if i < 0 then exit;			{ failure, register name expected }
    if not ParseChar (')') then exit;	{ failure, closing bracket expected }
    result := result or $0020 or treg[i].op;
  end

{ (Ri) or (Ri)+ }
  else if ParseChar ('(') then
  begin
    i := ParseTable (treg, NREG);
    if i < 0 then exit;			{ failure, register name expected }
    if not ParseChar (')') then exit;	{ failure, closing bracket expected }
    result := result or treg[i].op;
    if ParseChar ('+') then		{ (Ri)+ }
      result := result or $0010
    else
    begin
      if (result and $0008) = 0 then
        result := result or $0008	{ (Ri) = @Ri }
      else
      begin
        result := result or $0030;	{ @(Ri) = @0000(Ri) }
        OutBuf[OutIndex] := 0;
        Inc (OutIndex);
      end {if};
    end {if};
  end

{ n or n(Ri) }
  else if ParseNumber > 0 then
  begin
    if ParseChar ('(') then
    begin
      i := ParseTable (treg, NREG);
      if i < 0 then exit;		{ failure, register name expected }
      if not ParseChar (')') then exit;	{ failure, closing bracket expected }
      result := result or $0030 or treg[i].op;
    end
    else
    begin
      OutBuf[OutIndex] := OutBuf[OutIndex] - loc - 2*OutIndex - 2;
      result := result or $0037;
    end {if};
    Inc (OutIndex);
  end {if};

  result := result and $3F;		{ success }
end {ParseAddr};


{ assemble the instruction in the 'InBuf' and place the result in the OutBuf,
  expects the address in 'loc', but doesn't update it,
  on exit 'InIndex' contains the position of an error (warning: it can
  point past the end of the 'InBuf'!), otherwise 0 }
procedure Assemble;
var
  i: integer;		{ index to the 'mnem' table }
  x: word;
begin
  InIndex := 1;
  OutIndex := 0;

{ skip leading blanks }
  ParseBlanks;
  if InIndex > Length(InBuf) then	{ empty InBuf? }
  begin
    InIndex := 0;
    exit;				{ success }
  end {if};

{ parse the mnemonic }
  i := ParseTable (mnem, NTAB);
  if i < 0 then exit;			{ failure, mnemonic not recognised }
  if mnem[i].kind = ILLOP then exit;	{ failure, invalid mnemonic 'illop' }
  OutBuf[0] := mnem[i].op;
  OutIndex := 1;
  if (InIndex <= Length(InBuf)) and (LowerCase(InBuf[InIndex]) = 'b')
	and ((mnem[i].kind = SWBYTE) or (mnem[i].kind = DOUBLE)) then
  begin
    Inc (InIndex);
    OutBuf[0] := OutBuf[0] or $8000;
  end {if};

{ space after mnemonic required, unless an instruction without operands }
  if not ParseBlanks and (mnem[i].kind <> NONE) then exit;

{ parse the arguments }
  case mnem[i].kind of

    SPL: begin
        if ParseNumber = 0 then exit;	{ failure, a number expected }
        if OutBuf[1] > 7 then exit;	{ failure, value out of range }
        OutBuf[0] := OutBuf[0] or OutBuf[1];
      end;

    RTS: begin
        i := ParseTable (treg, NREG);
        if i < 0 then exit;		{ failure, register name expected }
        OutBuf[0] := OutBuf[0] or treg[i].op;
      end;

    SINGLE, SWBYTE: begin
        x := ParseAddr;
        if x > $3F then exit;		{ failure }
        OutBuf[0] := OutBuf[0] or x;
      end;

    DOUBLE, ADD: begin
        x := ParseAddr;
        if x > $3F then exit;		{ failure }
        OutBuf[0] := OutBuf[0] or (x shl 6);
        if not ParseComma then exit;	{ failure, comma expected }
        x := ParseAddr;
        if x > $3F then exit;		{ failure }
        OutBuf[0] := OutBuf[0] or x;
      end;

    JSR: begin
        i := ParseTable (treg, NREG);
        if i < 0 then exit;		{ failure, register name expected }
        OutBuf[0] := OutBuf[0] or (treg[i].op shl 6);
        if not ParseComma then exit;	{ failure, comma expected }
        x := ParseAddr;
        if x > $3F then exit;		{ failure }
        OutBuf[0] := OutBuf[0] or x;
      end;

    MUL: begin
        x := ParseAddr;
        if x > $3F then exit;		{ failure }
        OutBuf[0] := OutBuf[0] or x;
        if not ParseComma then exit;	{ failure, comma expected }
        i := ParseTable (treg, NREG);
        if i < 0 then exit;		{ failure, register name expected }
        OutBuf[0] := OutBuf[0] or (treg[i].op shl 6);
      end;

    BR: begin
        if ParseNumber = 0 then exit;	{ failure, a number expected }
        x := (OutBuf[1] - loc - 2) shr 1;
        if ((x and $7F80) <> 0) and ((x and $7F80) <> $7F80) then
          exit;				{ failure, branch out of range }
        OutBuf[0] := OutBuf[0] or (x and $FF);
      end;

    SOB: begin
        i := ParseTable (treg, NREG);
        if i < 0 then exit;		{ failure, register name expected }
        OutBuf[0] := OutBuf[0] or (treg[i].op shl 6);
        if not ParseComma then exit;	{ failure, comma expected }
        if ParseNumber = 0 then exit;	{ failure, a number expected }
        x := (loc + 2 - OutBuf[1]) shr 1;
        if (x and $7FC0) <> 0 then exit; { failure, branch out of range }
        OutBuf[0] := OutBuf[0] or (x and $3F);
      end;

    MARK: begin
        if ParseNumber = 0 then exit;	{ failure, a number expected }
        if OutBuf[1] > $3F then exit;	{ failure, value out of range }
        OutBuf[0] := OutBuf[0] or OutBuf[1];
      end;

    TRAP: begin
        if ParseNumber = 0 then exit;	{ failure, a number expected }
        if OutBuf[1] > $FF then exit;	{ failure, value out of range }
        OutBuf[0] := OutBuf[0] or OutBuf[1];
      end;

    CODE: begin
        if ParseChar ('c') then OutBuf[0] := OutBuf[0] or 1;
        if ParseChar ('v') then OutBuf[0] := OutBuf[0] or 2;
        if ParseChar ('z') then OutBuf[0] := OutBuf[0] or 4;
        if ParseChar ('n') then OutBuf[0] := OutBuf[0] or 8;
      end;

  end {case};

{ the rest of the InBuf is allowed to be padded with spaces only }
  ParseBlanks;
  if InIndex > Length(InBuf) then InIndex := 0;	{ success }
{ otherwise failure, extra characters encountered }

end {Assemble};


end.

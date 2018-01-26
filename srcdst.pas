{ PDP-11 addressing modes,
  based on the PDP-11/03 emulator written by Ovsienko V.A. }

unit Srcdst;


interface

  const
    BYTESIZE = $FFFF;
    WORDSIZE = $FFFE;

  var opt: word;	{ BYTESIZE or WORDSIZE }

  procedure GetLoc (mode: word);
  function GetSrc (mode: word) : pointer;
  function GetDst (mode: word) : pointer;


implementation

  uses Def;

  type Proc1 = procedure;



{ should never get called! }
  procedure AddrMode_00x;		{ R0..R7 }
  begin
    loc := 0;
  end {AddrMode_00x};



  procedure AddrMode_010;		{ @R0 }
  begin
    loc := ptrw(@reg[R0])^ and opt;
  end {AddrMode_010};

  procedure AddrMode_011;		{ @R1 }
  begin
    loc := ptrw(@reg[R1])^ and opt;
  end {AddrMode_011};

  procedure AddrMode_012;		{ @R2 }
  begin
    loc := ptrw(@reg[R2])^ and opt;
  end {AddrMode_012};

  procedure AddrMode_013;		{ @R3 }
  begin
    loc := ptrw(@reg[R3])^ and opt;
  end {AddrMode_013};

  procedure AddrMode_014;		{ @R4 }
  begin
    loc := ptrw(@reg[R4])^ and opt;
  end {AddrMode_014};

  procedure AddrMode_015;		{ @R5 }
  begin
    loc := ptrw(@reg[R5])^ and opt;
  end {AddrMode_015};

  procedure AddrMode_016;		{ @R6 }
  begin
    loc := ptrw(@reg[R6])^;		{ always even }
  end {AddrMode_016};

  procedure AddrMode_017;		{ @R7 }
  begin
    loc := ptrw(@reg[R7])^;		{ always even }
  end {AddrMode_017};



  procedure AddrMode_020;		{ (R0)+ }
  begin
    loc := ptrw(@reg[R0])^ and opt;
    Dec (ptrw(@reg[R0])^, opt);
  end {AddrMode_020};

  procedure AddrMode_021;		{ (R1)+ }
  begin
    loc := ptrw(@reg[R1])^ and opt;
    Dec (ptrw(@reg[R1])^, opt);
  end {AddrMode_021};

  procedure AddrMode_022;		{ (R2)+ }
  begin
    loc := ptrw(@reg[R2])^ and opt;
    Dec (ptrw(@reg[R2])^, opt);
  end {AddrMode_022};

  procedure AddrMode_023;		{ (R3)+ }
  begin
    loc := ptrw(@reg[R3])^ and opt;
    Dec (ptrw(@reg[R3])^, opt);
  end {AddrMode_023};

  procedure AddrMode_024;		{ (R4)+ }
  begin
    loc := ptrw(@reg[R4])^ and opt;
    Dec (ptrw(@reg[R4])^, opt);
  end {AddrMode_024};

  procedure AddrMode_025;		{ (R5)+ }
  begin
    loc := ptrw(@reg[R5])^ and opt;
    Dec (ptrw(@reg[R5])^, opt);
  end {AddrMode_025};

  procedure AddrMode_026;		{ (R6)+ = (SP)+ }
  begin
    loc := ptrw(@reg[R6])^;		{ always even }
    Inc (ptrw(@reg[R6])^, 2);
  end {AddrMode_026};

  procedure AddrMode_027;		{ (R7)+ = #n }
  begin
    loc := ptrw(@reg[R7])^;		{ always even }
    Inc (ptrw(@reg[R7])^, 2);
  end {AddrMode_027};



  procedure AddrMode_030;		{ @(R0)+ }
  begin
    loc := ptrw(@reg[R0])^ and $FFFE;
    Inc (ptrw(@reg[R0])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_030};

  procedure AddrMode_031;		{ @(R1)+ }
  begin
    loc := ptrw(@reg[R1])^ and $FFFE;
    Inc (ptrw(@reg[R1])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_031};

  procedure AddrMode_032;		{ @(R2)+ }
  begin
    loc := ptrw(@reg[R2])^ and $FFFE;
    Inc (ptrw(@reg[R2])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_032};

  procedure AddrMode_033;		{ @(R3)+ }
  begin
    loc := ptrw(@reg[R3])^ and $FFFE;
    Inc (ptrw(@reg[R3])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_033};

  procedure AddrMode_034;		{ @(R4)+ }
  begin
    loc := ptrw(@reg[R4])^ and $FFFE;
    Inc (ptrw(@reg[R4])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_034};

  procedure AddrMode_035;		{ @(R5)+ }
  begin
    loc := ptrw(@reg[R5])^ and $FFFE;
    Inc (ptrw(@reg[R5])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_035};

  procedure AddrMode_036;		{ @(R6)+ = @(SP)+ }
  begin
    loc := ptrw(@reg[R6])^;		{ always even }
    Inc (ptrw(@reg[R6])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_036};

  procedure AddrMode_037;		{ @(R7)+ = @#n when source type }
  begin
    loc := ptrw(@reg[R7])^;		{ always even }
    Inc (ptrw(@reg[R7])^, 2);
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_037};



  procedure AddrMode_040;		{ -(R0) }
  begin
    Inc (ptrw(@reg[R0])^, opt);
    loc := ptrw(@reg[R0])^ and opt;
  end {AddrMode_040};

  procedure AddrMode_041;		{ -(R1) }
  begin
    Inc (ptrw(@reg[R1])^, opt);
    loc := ptrw(@reg[R1])^ and opt;
  end {AddrMode_041};

  procedure AddrMode_042;		{ -(R2) }
  begin
    Inc (ptrw(@reg[R2])^, opt);
    loc := ptrw(@reg[R2])^ and opt;
  end {AddrMode_042};

  procedure AddrMode_043;		{ -(R3) }
  begin
    Inc (ptrw(@reg[R3])^, opt);
    loc := ptrw(@reg[R3])^ and opt;
  end {AddrMode_043};

  procedure AddrMode_044;		{ -(R4) }
  begin
    Inc (ptrw(@reg[R4])^, opt);
    loc := ptrw(@reg[R4])^ and opt;
  end {AddrMode_044};

  procedure AddrMode_045;		{ -(R5) }
  begin
    Inc (ptrw(@reg[R5])^, opt);
    loc := ptrw(@reg[R5])^ and opt;
  end {AddrMode_045};

  procedure AddrMode_046;		{ -(R6) = -(SP) }
  begin
    Dec (ptrw(@reg[R6])^, 2);
    loc := ptrw(@reg[R6])^;		{ always even }
  end {AddrMode_046};

  procedure AddrMode_047;		{ -(R7) = kind of pointless }
  begin
    Dec (ptrw(@reg[R7])^, 2);
    loc := ptrw(@reg[R7])^;		{ always even }
  end {AddrMode_047};



  procedure AddrMode_050;		{ @-(R0) }
  begin
    Dec (ptrw(@reg[R0])^, 2);
    loc := ptrw(@reg[R0])^ and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_050};

  procedure AddrMode_051;		{ @-(R1) }
  begin
    Dec (ptrw(@reg[R1])^, 2);
    loc := ptrw(@reg[R1])^ and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_051};

  procedure AddrMode_052;		{ @-(R2) }
  begin
    Dec (ptrw(@reg[R2])^, 2);
    loc := ptrw(@reg[R2])^ and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_052};

  procedure AddrMode_053;		{ @-(R3) }
  begin
    Dec (ptrw(@reg[R3])^, 2);
    loc := ptrw(@reg[R3])^ and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_053};

  procedure AddrMode_054;		{ @-(R4) }
  begin
    Dec (ptrw(@reg[R4])^, 2);
    loc := ptrw(@reg[R4])^ and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_054};

  procedure AddrMode_055;		{ @-(R5) }
  begin
    Dec (ptrw(@reg[R5])^, 2);
    loc := ptrw(@reg[R5])^ and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_055};

  procedure AddrMode_056;		{ @-(R6) = @-(SP) }
  begin
    Dec (ptrw(@reg[R6])^, 2);
    loc := ptrw(@reg[R6])^;		{ always even }
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_056};

  procedure AddrMode_057;		{ @-(R7) = kind of pointless }
  begin
    Dec (ptrw(@reg[R7])^, 2);
    loc := ptrw(@reg[R7])^;		{ always even }
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_057};



  procedure AddrMode_060;		{ n(R0) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R0])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_060};

  procedure AddrMode_061;		{ n(R1) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R1])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_061};

  procedure AddrMode_062;		{ n(R2) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R2])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_062};

  procedure AddrMode_063;		{ n(R3) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R3])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_063};

  procedure AddrMode_064;		{ n(R4) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R4])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_064};

  procedure AddrMode_065;		{ n(R5) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R5])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_065};

  procedure AddrMode_066;		{ n(R6) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R6])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_066};

  procedure AddrMode_067;		{ n(R7) = n , relative direct }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R7])^ + ptrw(SrcPtr)^) and opt;
  end {AddrMode_067};



  procedure AddrMode_070;		{ @n(R0) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R0])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_070};

  procedure AddrMode_071;		{ @n(R1) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R1])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_071};

  procedure AddrMode_072;		{ @n(R2) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R2])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_072};

  procedure AddrMode_073;		{ @n(R3) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R3])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_073};

  procedure AddrMode_074;		{ @n(R4) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R4])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_074};

  procedure AddrMode_075;		{ @n(R5) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R5])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_075};

  procedure AddrMode_076;		{ @n(R6) }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R6])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_076};

  procedure AddrMode_077;		{ @n(R7) = @n , relative indirect }
  begin
    loc := ptrw(@reg[R7])^;
    Inc (ptrw(@reg[R7])^, 2);
    loc := (ptrw(@reg[R7])^ + ptrw(SrcPtr)^) and $FFFE;
    loc := ptrw(SrcPtr)^ and opt;
  end {AddrMode_077};



  const Tabl_AddrMode: array[0..63] of pointer = (
	@AddrMode_00x,	@AddrMode_00x,	@AddrMode_00x,	@AddrMode_00x,
	@AddrMode_00x,	@AddrMode_00x,	@AddrMode_00x,	@AddrMode_00x,
	@AddrMode_010,	@AddrMode_011,	@AddrMode_012,	@AddrMode_013,
	@AddrMode_014,	@AddrMode_015,	@AddrMode_016,	@AddrMode_017,
	@AddrMode_020,	@AddrMode_021,	@AddrMode_022,	@AddrMode_023,
	@AddrMode_024,	@AddrMode_025,	@AddrMode_026,	@AddrMode_027,
	@AddrMode_030,	@AddrMode_031,	@AddrMode_032,	@AddrMode_033,
	@AddrMode_034,	@AddrMode_035,	@AddrMode_036,	@AddrMode_037,
	@AddrMode_040,	@AddrMode_041,	@AddrMode_042,	@AddrMode_043,
	@AddrMode_044,	@AddrMode_045,	@AddrMode_046,	@AddrMode_047,
	@AddrMode_050,	@AddrMode_051,	@AddrMode_052,	@AddrMode_053,
	@AddrMode_054,	@AddrMode_055,	@AddrMode_056,	@AddrMode_057,
	@AddrMode_060,	@AddrMode_061,	@AddrMode_062,	@AddrMode_063,
	@AddrMode_064,	@AddrMode_065,	@AddrMode_066,	@AddrMode_067,
	@AddrMode_070,	@AddrMode_071,	@AddrMode_072,	@AddrMode_073,
	@AddrMode_074,	@AddrMode_075,	@AddrMode_076,	@AddrMode_077
	);


{ returns the effective address in the variable loc, address modes R0 to R7
  should be treated separately }
  procedure GetLoc (mode: word);
  begin
    Proc1(Tabl_AddrMode[mode]);
  end {GetLoc};


{ function returns the pointer to the 'read' type resource for all address
  modes, inclusive R0 to R7 }
  function GetSrc (mode: word) : pointer;
  begin
    if mode < 8 then GetSrc := @reg[mode shl 1]
    else
    begin
      Proc1(Tabl_AddrMode[mode]);
      GetSrc := SrcPtr;
    end {if};
  end {GetSrc};


{ function returns the pointer to the 'write' type resource for all address
  modes, inclusive R0 to R7 }
  function GetDst (mode: word) : pointer;
  begin
    if mode < 8 then GetDst := @reg[mode shl 1]
    else
    begin
      Proc1(Tabl_AddrMode[mode]);
      GetDst := DstPtr;
    end {if};
  end {GetDst};

end.

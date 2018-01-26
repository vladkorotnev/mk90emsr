{ global scope definitions, memory, constants, variables, common procedures }

unit Def;

interface

  type
    ptrb = ^byte;		{ unsigned 8-bit }
    ptrw = ^word;		{ unsigned 16-bit }
    ptrshort = ^shortint;	{ signed 8-bit }
    ptrsmall = ^smallint;	{ unsigned 16-bit }


  const
    IniName: string = 'mk90.ini';

{ indexes to the 'reg' table }
    R0		= 0*2;
    R1		= 1*2;
    R2		= 2*2;
    R3		= 3*2;
    R4		= 4*2;
    R5		= 5*2;
    R6		= 6*2;
    R7		= 7*2;

{ status bits }
    H_bit	= $100;	{ HALT/USER mode }
    I_bit	= $80;	{ interrupt priority }
    T_bit	= $10;
    N_bit	= $08;
    Z_bit	= $04;
    V_bit	= $02;
    C_bit	= $01;
    NZ_bit	= $0C;	{ N+Z }
    VC_bit	= $03;	{ V+C }
    NZV_bit	= $0E;	{ N+Z+V }
    NZVC_bit	= $0F;	{ N+Z+V+C }

{ ROM address space }
    ROMSTART	= $4000;
    ROMSIZE	= $BF00;
    ROMEND	= ROMSTART + ROMSIZE - 1;
{ RAM address space }
    RAMSTART	= $0000;
    MINRAMSIZE	= $4000;
    MAXRAMSIZE	= $8000;

{ HALT mode register }
    SEL		= $0000;

    dummysrc: array[0..2] of byte	{ free adress space }
	= ($FF, $FF, $FF);

  var
    dummydst: array[0..2] of byte;	{ free address space }
    rom: array[0..ROMSIZE-1] of byte;
    ram: array[0..MAXRAMSIZE-1] of byte;
    RamSize: word;
    RamEnd: word;			{ = RAMSTART + RamSize }
    reg: array[0..15] of byte;
    psw: word;
    code: word;
    cpc: word;				{ HALT-mode register storing the PC }
    cps: word;				{ HALT-mode register storing the PSW }
    RTT_flag: boolean;			{ true when RTT instruction executed }
    WAIT_flag: boolean;			{ true when WAIT instruction executed }
    STEP_flag: boolean;			{ true when STEP instruction executed }
    RESET_flag: boolean;		{ true when RESET instruction executed }
    HALT_i, EVNT_i, VIRQ_i: boolean;	{ hardware interrupt request flags }
    procptr: pointer;			{ pointer to a procedure that should
					  be executed before a machine code
					  instruction, usually to complete an
					  I/O register write cycle }

    KeyCode1: integer;		{ from the mouse }
    KeyCode2: integer;		{ from the keyboard }
    CpuStop: boolean;		{ True stops the CPU }
    CpuDelay: integer;		{ delay after hiding the Debug Window,
				  prevents the program from crashing when the
				  Debug Window was made visible too early }
    CpuSteps: integer;		{ ignored when < 0 }
    BreakPoint: integer;	{ ignored when < 0 }
    loc: word; 			{ address of the resource }


  function IsInRom (address: word) : boolean;
  function IsInRam (address: word) : boolean;
  function SrcPtr : pointer;
  function DstPtr : pointer;


implementation

uses Rtc, IoSystem, Lcd;


{ test if the given address is within the ROM address space }
function IsInRom (address: word) : boolean;
begin
  IsInRom := address >= ROMSTART;
end {IsInRom};


{ test if the given address is within the RAM address space }
function IsInRam (address: word) : boolean;
begin
  IsInRam := address <= RamEnd;
end {IsInRam};


{ function returns the pointer to the 'read' type resource at address 'loc' }
function SrcPtr : pointer;
begin
  if IsInRam (loc) then SrcPtr := @ram[loc-RAMSTART]
  else if (loc and $FFFC) = $E800 then SrcPtr := LcdRdPtr (loc-$E800)
  else if (loc and $FFF0) = $E810 then SrcPtr := IoRdPtr (loc-$E810)
  else if (loc and $FF80) = $EA00 then SrcPtr := RtcRdPtr (loc-$EA00)
  else if IsInRom (loc) then SrcPtr := @rom[loc-ROMSTART]
  else SrcPtr := @dummysrc;
end {SrcPtr};


{ function returns the pointer to the 'write' type resource at address 'loc' }
function DstPtr : pointer;
begin
  if IsInRam (loc) then DstPtr := @ram[loc-RAMSTART]
  else if (loc and $FFFC) = $E800 then DstPtr := LcdWrPtr (loc-$E800)
  else if (loc and $FFF0) = $E810 then DstPtr := IoWrPtr (loc-$E810)
  else if (loc and $FF80) = $EA00 then DstPtr := RtcWrPtr (loc-$EA00)
  else DstPtr := @dummydst;
end {DstPtr};


end.


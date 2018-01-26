{ Serial bus interface KA1835VG4, keyboard interface KA1835VG1, SMP modules }

unit IoSystem;

interface

  procedure IoInit;
  procedure IoClose;
  function IoWrPtr (index: word) : pointer;
  function IoRdPtr (index: word) : pointer;
  procedure KeyIrq;

implementation

uses Def, Keyboard, Smp;

var
  iodata: array [0..3] of word;
  ioword: word;		{ data to exchange with the host }
  ioindex: word;	{ index of the iodata location that should be written
			  at next CPU cycle, otherwise $FFFF }
  shiftreg: word;	{ serial bus shift register }
  select: boolean;	{ serial bus SELECT signal }


{ write pending data to the ioindex memory location }
procedure IoWrite;
begin
  if ioindex > 3 then exit;
  iodata[ioindex] := ioword;
  case ioindex of
    0: begin				{data register}
         shiftreg := ioword;
         if select then
         begin
           case iodata[2] and $0F of
             $00: shiftreg := SmpData (0, 0);
             $01: shiftreg := SmpData (1, 0);
             $02: shiftreg := KeyScanCode;
             $08: SmpData (0, shiftreg);
             $09: SmpData (1, shiftreg);
           end {case};
         end {if};
       end;
    2: begin				{control register}
         if select then
         begin
           case iodata[2] and $0F of
             $00: shiftreg := SmpData (0, 0);
             $01: shiftreg := SmpData (1, 0);
             $02: shiftreg := KeyScanCode;
           end {case};
         end {if};
       end;
    3: begin				{command register}
         select := true;
         shiftreg := ioword;
         case iodata[2] and $0F of
           $00: shiftreg := SmpCmd (0, 0);
           $01: shiftreg := SmpCmd (1, 0);
           $02: shiftreg := KeyScanCode;
           $08: SmpCmd (0, shiftreg);
           $09: SmpCmd (1, shiftreg);
         end {case};
       end;
  end {case};
  ioindex := $FFFF;
end {IoWrite};


procedure IoInit;
begin
  ioindex := $FFFF;
  shiftreg := $FFFF;
  select := false;
  SmpOpen (0);
  SmpOpen (1);
end {IoInit};


procedure IoClose;
begin
  SmpClose (0);
  SmpClose (1);
end {IoClose};


function IoWrPtr (index: word) : pointer;
begin
  ioindex := (index shr 1) and $03;
  IoWrPtr := @ioword;
  procptr := @IoWrite;
end {IoWrPtr};


function IoRdPtr (index: word) : pointer;
begin
  index := (index shr 1) and $03;
  case index of
    0: begin				{data register}
         ioword := shiftreg;
         shiftreg := $FFFF;		{default value}
         if select then
         begin
           case iodata[2] and $0F of
             $00: shiftreg := SmpData (0, 0);
             $01: shiftreg := SmpData (1, 0);
             $02: shiftreg := KeyScanCode;
           end {case};
         end {if};
       end;
    1: ioword := iodata[1];		{transfer rate}
    2: ioword := $FFFF;			{status register, always ready}
    3: begin				{command register}
         ioword := shiftreg;
         select := false;
       end;
  end {case};
  IoRdPtr := @ioword;
end {IoRdPtr};


{ keyboard interrupt, should be possible to disable somehow because it could
  otherwise hang the calculator in case of uninitialised interrupt vector }
procedure KeyIrq;
begin
  if not CpuStop then	{if the system isn't in the debug mode}
    VIRQ_i := true;
end {KeyIrq};


end.

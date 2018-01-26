{ Real Time Clock and RAM with battery backup KA512VI1,
  limited emulation }

unit Rtc;

interface

  procedure RtcInit;
  procedure RtcClose;
  procedure RtcUpdate;
  procedure RtcIrq;
  function RtcWrPtr (index: word) : pointer;
  function RtcRdPtr (index: word) : pointer;

implementation

uses SysUtils, Def;

const
  RtcFile: string = 'rtc.bin';

var
  rtcdata: array [0..63] of byte;
  rtcword: word;		{ to exchange data with the host }
  rtcindex: word;		{ if in range 0..63 then rtcword should be
				  written to the rtcdata memory location at
				  next access of the RTC system }

{ write pending data to the rtcdata memory }
procedure RtcWrite;
begin
  if rtcindex > 63 then Exit;
  if (rtcindex <> $0C) and (rtcindex <> $0D) then
  begin
    rtcdata[rtcindex] := rtcword shr 1;
  end {if};
  rtcindex := $FFFF;
end {RtcWrite};


procedure RtcInit;
var
//  f: file;
  t: TDateTime;
  x1,x2,x3,x4: word;
begin
{ File loading disabled in the public release, because a corrupted RtcFile can
  hang the emulated calculator (just as corrupted non-volatile RAM contents
  can hang the real one). In such case the user would have to delete the file
  (equivalent to removing the batteries in a real MK-90). I'm afraid that this
  would be asking too much and decided to avoid the hassle... }
//  if FileExists (RtcFile) then
//  begin
//    AssignFile (f, RtcFile);
//    Reset (f, 1);
//    BlockRead (f, rtcdata, 64);
//    CloseFile (f);
//  end; {if}

  rtcindex := $FFFF;
  rtcdata[$0D] := 0;	{clear the VRT bit}
{ The MK-90 firmware relies on the remaining RTC registers being cleared upon
 power-up. }
  rtcdata[$0C] := 0;
  rtcdata[$0B] := 0;
  rtcdata[$0A] := 0;

{ copy current date and time to rtcdata }
  t := Now;
  DecodeDate(t, x1, x2, x3);
  rtcdata[9] := byte(x1 mod 100);
  rtcdata[8] := byte(x2);
  rtcdata[7] := byte(x3);
  x3 := DayOfWeek(t) - 1;
  if x3 <= 0 then x3 := 7;
  rtcdata[6] := byte(x3);
  DecodeTime(t, x1, x2, x3, x4);
  rtcdata[4] := byte(x1);
  rtcdata[2] := byte(x2);
  rtcdata[0] := byte(x3);
end {RtcInit};


procedure RtcClose;
var
  f: file;
begin
  RtcWrite;
  AssignFile (f, RtcFile);
  Rewrite (f, 1);
  BlockWrite (f, rtcdata, 64);
  CloseFile (f);
end {RtcClose};


{ should be called every second }
procedure RtcUpdate;
const
  days: array[0..11] of integer = (31,28,31,30,31,30,31,31,30,31,30,31);
begin
  RtcWrite;
  rtcdata[$0C] := rtcdata[$0C] or $10;	{update-ended interrupt flag}
{ set the IRQF interrupt flag if the update-ended interrupt enabled }
  if (rtcdata[$0B] and $10) <> 0 then rtcdata[$0C] := rtcdata[$0C] or $80;
  Inc (rtcdata[0]);			{seconds}
  if rtcdata[0] < 60 then Exit;
  rtcdata[0] := 0;
  Inc (rtcdata[2]);			{minutes}
  if rtcdata[2] < 60 then Exit;
  rtcdata[2] := 0;
  Inc (rtcdata[4]);			{hours}
  if rtcdata[4] < 24 then Exit;
  rtcdata[4] := 0;
  rtcdata[6] := rtcdata[6] mod 7 + 1;	{day of the week};
  Inc (rtcdata[7]);			{day of the month};
  if rtcdata[7] <= days[(rtcdata[8] - 1) mod 12] then Exit;
  rtcdata[7] := 1;
  Inc (rtcdata[8]);			{month};
  if rtcdata[8] <= 12 then Exit;
  rtcdata[8] := 1;
  Inc (rtcdata[9]);			{year};
  if rtcdata[8] <= 99 then Exit;
  rtcdata[8] := 0;
end {RtcUpdate};


{ should be called every 32ms }
procedure RtcIrq;
begin
  if (not CpuStop) and			{the system isn't in the debug mode}
  ((rtcdata[$0B] and $08) <> 0) then	{bit SQWE in the register B is set}
    EVNT_i := true;
  rtcdata[$0C] := rtcdata[$0C] or $40;	{periodic interrupt flag}
{ set the IRQF interrupt flag if the periodic interrupt enabled }
  if (rtcdata[$0B] and $40) <> 0 then rtcdata[$0C] := rtcdata[$0C] or $80;
end {RtcIrq};


function RtcWrPtr (index: word) : pointer;
begin
  RtcWrite;
  rtcindex := (index shr 1) and $3F;
  RtcWrPtr := @rtcword;
end {RtcWrPtr};


function RtcRdPtr (index: word) : pointer;
begin
  RtcWrite;
  index := (index shr 1) and $3F;
  rtcword := word(rtcdata[index]) shl 1;
  if index = $0D then rtcdata[$0D] := $80	{set the VRT bit}
  else if index = $0C then rtcdata[$0C] := 0;	{clear all interrupt flags}
  RtcRdPtr := @rtcword;
end {RtcRdPtr};


end.

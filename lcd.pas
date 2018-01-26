{ LCD controller KA1835VG3, only display address register implemented }

unit Lcd;

interface

  procedure LcdInit;
  procedure LcdClose;
  function LcdWrPtr (index: word) : pointer;
  function LcdRdPtr (index: word) : pointer;
  function LcdMemAddr : word;

implementation

uses Def;

var
  lcddata: array [0..1] of word;
  lcdword: word;	{ data to exchange with the host }
  lcdindex: word;	{ index of the lcddata location that should be written
			  at next CPU cycle, otherwise $FFFF }


{ write pending data to the lcdindex memory location }
procedure LcdWrite;
begin
  if lcdindex > 1 then exit;
  lcddata[lcdindex] := lcdword;
  lcdindex := $FFFF;
end {LcdWrite};


procedure LcdInit;
begin
  lcdindex := $FFFF;
end {LcdInit};


procedure LcdClose;
begin
  Exit;
end {LcdClose};


function LcdWrPtr (index: word) : pointer;
begin
  lcdindex := (index shr 1) and $01;
  LcdWrPtr := @lcdword;
  procptr := @LcdWrite;
end {LcdWrPtr};


function LcdRdPtr (index: word) : pointer;
begin
  lcdword := lcddata[(index shr 1) and $01];
  LcdRdPtr := @lcdword;
end {LcdRdPtr};


{ returns address of the display memory }
function LcdMemAddr : word;
begin
  LcdMemAddr := lcddata[0];
end {LcdMemAddr};


end.

unit Numbers;

interface

  const
    digits: string[22] = '0123456789ABCDEFabcdef';

  var
    radix: integer = 16;
    bytewidth: integer = 2;	{ number of digits in a byte }
    wordwidth: integer = 4;	{ number of digits in a word }

  function CardToStr (x: cardinal; base: cardinal; c: char) : string;
  function WordToStr (x: word; c: char) : string;
  function ByteToStr (x: word; c: char) : string;
  function GetDigit (c: char) : integer;
  function GetValue (s: string; base: integer) : integer;


implementation

uses SysUtils;

const
  WIDTH32 = 11;	{ string size required to hold an octal 32-bit number }


{ conversion of a number to a string,
  leading zeroes are replaced with the character c }
function CardToStr (x: cardinal; base: cardinal; c: char) : string;
var
  s: string[WIDTH32];
  i: integer;
begin
  s := StringOfChar(c, WIDTH32);
  for i := WIDTH32 downto 1 do
  begin
    s[i] := digits[x mod base + 1];
    x := x div base;
    if x = 0 then Break;
  end {for};
  CardToStr := s;
end {CardToStr};


{ conversion of a word to a string }
function WordToStr (x: word; c: char) : string;
begin
  WordToStr := TrimLeft(Copy(CardToStr(cardinal(x), cardinal(radix), c), WIDTH32+1-wordwidth, wordwidth));
end {WordToStr};


{ conversion of a byte to a string }
function ByteToStr (x: word; c: char) : string;
begin
  ByteToStr := TrimLeft(Copy(CardToStr(cardinal(x), cardinal(radix), c), WIDTH32+1-bytewidth, bytewidth));
end {ByteToStr};


{ value of a digit }
function GetDigit (c: char) : integer;
var
  i: integer;
begin
  i := 1;
  while (i<=22) and (c <> digits[i]) do Inc (i);
  if i>16 then GetDigit := i-7 else GetDigit := i-1;
end {GetDigit};


{ value of a string }
function GetValue (s: string; base: integer) : integer;
var
  x, y, i: integer;
begin
  x := 0;
  i := 1;
{ skip leading spaces }
  while i <= Length(s) do
  begin
    if s[i] <> ' ' then break;
    Inc (i);
  end {while};
  while i <= Length(s) do
  begin
    y := GetDigit(s[i]);
    if y >= base then break;
    x := x*base + y;
    Inc (i);
  end;
  GetValue := x;
end {GetValue};


end.

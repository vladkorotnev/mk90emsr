unit Keyboard;

interface

type

  keyblock = record
    L: integer;		{ left }
    T: integer;		{ top }
    W: integer;		{ width of the key }
    H: integer;		{ height of the key }
    SX: integer;	{ horizontal spacing }
    SY: integer;	{ vertical spacing }
    col: integer;	{ number of columns }
    cnt: integer;	{ number of keys in a block }
    OX: integer;	{ left in the Keys.bmp }
    OY: integer;	{ top in the Keys.bmp }
  end;

  function KeyScanCode: word;


const

  KEYPADS = 5;		{index of the last item in the 'keypad' array}
  LASTKEYCODE = 63;

  keypad: array[0..KEYPADS] of keyblock = (
{ power and reset keys, code: 1..2 }
    (	L:491;	T:37;	W:27;	H:18;	SX:35;	SY:33;	col:1;	cnt:2;	OX:54;	OY:18	),
{ numeric keys, code: 3..16 }
    (	L:526;	T:35;	W:27;	H:22;	SX:35;	SY:33;	col:7;	cnt:14;	OX:0;	OY:18	),
{ letter keys and a row of grey keys, code: 17..56 }
    (	L:491;	T:103;	W:27;	H:18;	SX:35;	SY:31;	col:8;	cnt:40;	OX:54;	OY:18	),
{ three keys left from the space bar, code: 57..59 }
    (	L:491;	T:258;	W:27;	H:18;	SX:35;	SY:31;	col:3;	cnt:3;	OX:54;	OY:18	),
{ space bar, code: 60 }
    (	L:596;	T:258;	W:62;	H:18;	SX:70;	SY:31;	col:1;	cnt:1;	OX:0;	OY:0	),
{ three keys right from the space bar, code: 61..63 }
    (	L:666;	T:258;	W:27;	H:18;	SX:35;	SY:31;	col:3;	cnt:3;	OX:54;	OY:18	)
  );


implementation

uses Def;

{ tables convert KeyCode1 and KeyCode2 to the keyboard scan code }
const

KeyTab: array[0..LASTKEYCODE] of word = (
$0000,							{ no key pressed }
$0000, $0000,						{ power, reset }
       $0023, $0043, $0063, $0083, $00A3, $00C3, $00E3,	{   1 2 3 4 5 : ; }
       $0027, $0047, $0067, $0087, $00A7, $00C7, $00E7,	{   6 7 8 9 0 / - }
$000B, $002B, $004B, $006B, $008B, $00AB, $00CB, $00EB,	{ A B W G D E V Z }
$000F, $002F, $004F, $006F, $008F, $00AF, $00CF, $00EF,	{ I J K L M N O P }
$0013, $0033, $0053, $0073, $0093, $00B3, $00D3, $00F3,	{ R S T U F H C ^ }
$0017, $0037, $0057, $0077, $0097, $00B7, $00D7, $00F7,	{ [ ] X Y _ \ @ Q }
$001B, $003B, $005B, $007B, $009B, $00BB, $00DB, $00FB,	{ first row of grey keys }
$001F, $003F, $005F,					{ keys left from the space }
                     $007F,				{ space }
                                   $00BF, $00DF, $00FF	{ keys right from the space }
);


function KeyScanCode: word;
begin
  if KeyCode1 > 2 then
    KeyScanCode := KeyTab[KeyCode1]
  else
    KeyScanCode := KeyTab[KeyCode2];
end {KeyScanCode};


end.

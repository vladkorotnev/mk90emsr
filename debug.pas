unit Debug;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles;

type
  TDebugForm = class(TForm)
    ListGroupBox: TGroupBox;
    ListPaintBox: TPaintBox;
    ListScrollBar: TScrollBar;
    ListEdit: TEdit;

    RegGroupBox: TGroupBox;
    RegPaintBox: TPaintBox;
    RegScrollBar: TScrollBar;
    RegEdit: TEdit;

    BinGroupBox: TGroupBox;
    BinPaintBox: TPaintBox;
    BinScrollBar: TScrollBar;
    RadioButtonByte: TRadioButton;
    RadioButtonWord: TRadioButton;
    BinEdit: TEdit;

    StepGroupBox: TGroupBox;
    StepButton: TButton;

    TraceGroupBox: TGroupBox;
    TraceEdit: TEdit;
    TraceButton: TButton;

    BpGroupBox: TGroupBox;
    BpEdit: TEdit;
    BpButton: TButton;

{ DISASSEMBLY BOX EVENTS }
    procedure ListGroupBoxClick(Sender: TObject);
    procedure ListBoxScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ListPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListEditChange(Sender: TObject);
    procedure ListPaintBoxPaint(Sender: TObject);

{ REGISTER BOX EVENTS }
    procedure RegGroupBoxClick(Sender: TObject);
    procedure RegBoxScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure RegPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RegEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RegEditChange(Sender: TObject);
    procedure RegPaintBoxPaint(Sender: TObject);

{ BINARY EDITOR BOX EVENTS }
    procedure BinGroupBoxClick(Sender: TObject);
    procedure BinBoxScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure BinPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BinEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BinEditChange(Sender: TObject);
    procedure BinPaintBoxPaint(Sender: TObject);
    procedure BinRadioButtonClick(Sender: TObject);

{ MACHINE CODE EXECUTION CONTROL EVENTS }
    procedure StepGroupBoxClick(Sender: TObject);
    procedure StepButtonClick(Sender: TObject);
    procedure TraceGroupBoxClick(Sender: TObject);
    procedure TraceButtonClick(Sender: TObject);
    procedure TraceEditChange(Sender: TObject);
    procedure BpGroupBoxClick(Sender: TObject);
    procedure BpButtonClick(Sender: TObject);
    procedure BpEditChange(Sender: TObject);

{ GENERAL FORM EVENTS }
    procedure DebugCreate(Sender: TObject);
    procedure DebugShow(Sender: TObject);
    procedure DebugHide(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  DebugForm: TDebugForm;
  RomChanged: boolean = False;

implementation

{$R *.dfm}

uses Def, Numbers, Pdp11dis, Cpu;

const
  SELECTED = clBlue;

var
  BinAddr: word;
  ListAddr: word;
  ListStartAddr: word;
  ListEndAddr: word;
  RegAddr: word;

  EditState: (NoEditSt, ListAddrEditSt, ListInstrEditSt, RegEditSt, PSWEditSt,
	BinAddrEditSt, BinDataEditSt, BinCharEditSt);
  EditAddr: word;	{address of the edited object - memory location, register}

  BinDataSize: integer = 1;

{ set the font color of all TGrupBox controls to default }
procedure Unselect;
begin
  with DebugForm do
  begin
    ListGroupBox.Font.Color := clWindowText;
    RegGroupBox.Font.Color := clWindowText;
    BinGroupBox.Font.Color := clWindowText;
    StepGroupBox.Font.Color := clWindowText;
    TraceGroupBox.Font.Color := clWindowText;
    BpGroupBox.Font.Color := clWindowText;
  end {with};
end {Unselect};


procedure BoxEdit (box: TPaintBox; ed: TEdit; Col, Row, W: integer);
var
  cx, cy, L, T: integer;
begin
  with box do
  begin
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    L := Left;
    T := Top;
  end {with};
  with ed do
  begin
    Left := L + Col * cx;
    Top := T + Row * cy;
    Width := cx * W;
    Height := cy;
    MaxLength := W;
    Text := '';
  end {with};
end {BoxEdit};


{ remove digits out of specified range from the edited string }
procedure CheckEdit (ed: TEdit; limit: integer);
var
  i, x, y: integer;
  s: string;
begin
  with ed do
  begin
    if Modified then
    begin
      s := Text;
      x := SelStart;
      y := SelLength;
      i := 1;
      while i <= Length(s) do
      begin
        if GetDigit(s[i]) >= limit then
        begin
          Delete (s, i, 1);
          if x >= i then Dec(x) else if x+y >= i then Dec(y);
        end
        else
        begin
          Inc (i);
        end {if};
      end {while};
      Text := s;
      SelStart := x;
      SelLength := y;
    end {if};
  end {with};
end {CheckEdit};


procedure CloseEdit;
begin
  EditState := NoEditSt;
  with DebugForm do
  begin
    with ListEdit do
    begin
      Text := '';
      Width := 0;
      Left := 0;
      Top := 0;
    end {with};
    with RegEdit do
    begin
      Text := '';
      Width := 0;
      Left := 0;
      Top := 0;
    end {with};
    with BinEdit do
    begin
      Text := '';
      Width := 0;
      Left := 0;
      Top := 0;
    end {with};
    ListPaintBox.Invalidate;
    RegPaintBox.Invalidate;
    BinPaintBox.Invalidate;
  end {with};
end {CloseEdit};


{ expects the new disassembly address,
  sets new values of ListAddr, ListStartAddr, ListEndAddr }
procedure SetListBoundaries (addr: word);
begin
  ListAddr := addr and $FFFE;
  if IsInRom (ListAddr) then
  begin
    ListStartAddr := ROMSTART;
    ListEndAddr := ROMEND;
  end
  else if IsInRam (ListAddr) then
  begin
    ListStartAddr := RAMSTART;
    ListEndAddr := RamEnd;
  end
  else {out of allowed address space}
  begin
    ListAddr := ROMSTART;
    ListStartAddr := ROMSTART;
    ListEndAddr := ROMEND;
  end {if};
end {SetListBoundaries};


{ scrolling with the arrow keys,
  returns new value for Position or -1 when Position hasn't changed }
function ArrowKeys (Key: word; sb: TScrollBar) : integer;
begin
  with sb do
  begin
    Result := Position;
    case Key of
      VK_HOME:	Result := Min;
      VK_PRIOR:	Dec (Result, LargeChange);
      VK_UP:	Dec (Result, SmallChange);
      VK_DOWN:	Inc (Result, SmallChange);
      VK_NEXT:	Inc (Result, LargeChange);
      VK_END:	Result := Max;
    end {case};
    if Result < Min then Result := Min
    else if Result > Max then Result := Max;
    if Result = Position then Result := -1;
  end {with};
end;


{ DISASSEMBLY BOX EVENTS }

procedure TDebugForm.ListGroupBoxClick(Sender: TObject);
begin
  ListEdit.SetFocus;
  Unselect;
  ListGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.ListBoxScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if IsInRam (ListAddr) then
    ListAddr := 2*word(ScrollPos) + RAMSTART
  else
    ListAddr := 2*word(ScrollPos) + ROMSTART;
  ListEdit.SetFocus;
  Unselect;
  ListGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.ListPaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row, cols, rows, i, w: integer;
  opcode: word;
  cx, cy: integer;	{ font size in pixels }
begin
  ListEdit.SetFocus;
  Unselect;
  ListGroupBox.Font.Color := SELECTED;
  CloseEdit;
  with ListPaintBox do
  begin
    cx := Canvas.TextWidth ('0');
    cy := Canvas.TextHeight ('0');
    cols := Width div cx;
    rows := Height div cy;
    Col := X div cx;
    Row := Y div cy;
  end {with};
  if Row >= rows then Exit;
  if (Col < wordwidth) and (Row = 0) then
  begin
    EditState := ListAddrEditSt;
    EditAddr := ListAddr;
    Col := 0;
    w := wordwidth;
    ListEdit.CharCase := ecUpperCase;
  end

  else if (Col >= wordwidth+2) and (Col < cols) then
  begin
    loc := ListAddr;
    i := 0;
    while i < Row do
    begin
{ move the 'loc' to the next instruction, i.e. disassemble a single
  instruction without generating any output }
      opcode := FetchWord;
      Arguments (ScanMnemTab (opcode), opcode);
      if (loc > ListEndAddr) or
	((not loc and ListAddr) >= $8000) {wrapped?} then Exit;
      Inc (i);
    end {while};
    EditAddr := loc;
    EditState := ListInstrEditSt;
    Col := wordwidth+2;
    w := cols - wordwidth - 2;
    ListEdit.CharCase := ecNormal;
  end
  else
  begin
    Exit;
  end {if};
  BoxEdit (ListPaintBox, ListEdit, Col, Row, w);
end;


procedure TDebugForm.ListEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
begin
  i := ArrowKeys (Key, ListScrollBar);
  if (i >= 0) and (EditState = NoEditSt) then
  begin
    if IsInRam (ListAddr) then
      ListAddr := 2*word(i) + RAMSTART
    else
      ListAddr := 2*word(i) + ROMSTART;
    ListPaintBox.Invalidate;
  end

  else if Key = VK_RETURN then
  begin
    if EditState = ListAddrEditSt then
    begin
      SetListBoundaries (GetValue (ListEdit.Text, radix));
      CloseEdit;
    end
    else if EditState = ListInstrEditSt then
    begin
      loc := EditAddr;
      InBuf := ListEdit.Text;
      Assemble;
      if InIndex = 0 then
      begin
        i := 0;
        while i < OutIndex do
        begin
          StoreWord (OutBuf[i]);
          Inc (i);
        end {while};
        RomChanged := True;
        CloseEdit;
      end
      else
      begin
{ position the cursor just before the first offending character }
        ListEdit.SelStart := InIndex-1;
      end {if};
    end {if};
  end

  else if key = VK_ESCAPE then CloseEdit;
end;


procedure TDebugForm.ListEditChange(Sender: TObject);
begin
  if EditState = ListAddrEditSt then CheckEdit (ListEdit, radix);
end;


procedure TDebugForm.ListPaintBoxPaint(Sender: TObject);
var
  i, rows, index: integer;
  opcode: word;
  c: char;
  cx, cy: integer;	{ font size in pixels }
begin
  loc := ListAddr;
  with ListPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Color;
    cx := Canvas.TextWidth ('0');
    cy := Canvas.TextHeight ('0');
    rows := Height div cy;
  end {with};
  with ListPaintBox.Canvas do
  begin
    for i := 0 to rows-1 do
    begin
      if (loc > ListEndAddr) or
	((not loc and ListAddr) >= $8000) {wrapped?} then break;
      TextOut (0, i*cy, WordToStr(loc, '0') + ':');
      opcode := FetchWord;
      index := ScanMnemTab (opcode);
      if (opcode and $8000) = 0 then c := ' ' else c := 'b';
      TextOut ((wordwidth+2)*cx, i*cy, Mnemonic (index, c));
      TextOut ((wordwidth+8)*cx, i*cy, Arguments (index, opcode));
    end {for};
  end {with};
{ set the scroll bar }
  with ListScrollBar do
  begin
    SetParams ((ListAddr-ListStartAddr) div 2, 0,
	(ListEndAddr-ListStartAddr) div 2);
    if loc < ListEndAddr then
	LargeChange := (loc-ListAddr) div 2;
  end {with};
end;



{ REGISTER BOX EVENTS }

const
  REGROWS = 9;
  regname: array[0..REGROWS-1] of string[4] =
    ('R0:', 'R1:', 'R2:', 'R3:', 'R4:', 'R5:', 'SP:', 'PC:', 'PSW:');
  flagname: array[0..4] of char =
    ('T', 'N', 'Z', 'V', 'C');
  flagmask: array[0..4] of word =
    (T_bit, N_bit, Z_bit, V_bit, C_bit);


procedure TDebugForm.RegGroupBoxClick(Sender: TObject);
begin
  RegEdit.SetFocus;
  Unselect;
  RegGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.RegBoxScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  RegAddr := word(ScrollPos);
  RegEdit.SetFocus;
  Unselect;
  RegGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.RegPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row, rows: integer;
  cx, cy: integer;	{ font size in pixels }
begin
  RegEdit.SetFocus;
  Unselect;
  RegGroupBox.Font.Color := SELECTED;
  CloseEdit;
  with RegPaintBox do
  begin
    cx := Canvas.TextWidth ('0');
    cy := Canvas.TextHeight ('0');
    rows := Height div cy;
    Col := X div cx;
    Row := Y div cy;
  end {with};
  if rows > REGROWS+1 then rows := REGROWS+1;
  if (Col >= 4) and (Col < 4+wordwidth) and (Row < rows-1) then
  begin
    EditState := RegEditSt;
    EditAddr := word(Row) + RegAddr;
    BoxEdit (RegPaintBox, RegEdit, 4, Row, wordwidth);
  end {if};
end;


procedure TDebugForm.RegEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
  x: word;
begin
  i := ArrowKeys (Key, RegScrollBar);
  if (i >= 0) and (EditState = NoEditSt) then
  begin
    RegAddr := word(i);
    RegPaintBox.Invalidate;
  end

  else if Key = VK_RETURN then
  begin
    if EditState = RegEditSt then
    begin
      x := GetValue (RegEdit.Text, radix);
      if EditAddr < 6 then ptrw(@reg[2*EditAddr])^ := x
      else if EditAddr < 8 then ptrw(@reg[2*EditAddr])^ := x and $FFFE
      else psw := x;
      CloseEdit;
    end {if};
  end

  else if Key = VK_ESCAPE then CloseEdit;
end;


procedure TDebugForm.RegEditChange(Sender: TObject);
begin
  CheckEdit (RegEdit, radix);
end;


procedure TDebugForm.RegPaintBoxPaint(Sender: TObject);
var
  i, rows: integer;
  c: char;
  x: word;
  cx, cy: integer;	{ font size in pixels }
begin
  with RegPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Color;
    cx := Canvas.TextWidth ('0');
    cy := Canvas.TextHeight ('0');
    rows := Height div cy;
  end {with};
  if rows > REGROWS+1 then rows := REGROWS+1;
  with RegPaintBox.Canvas do
  begin
{ unscrollable Flags register bits }
    for i := 0 to 4 do
    begin
      if (psw and flagmask[i]) = 0 then c := '-' else c := flagname[i];
      TextOut (i*cx, (rows-1)*cy, c);
    end {for};
{ other registers, scrollable }
    for i := 0 to rows-2 do
    begin
      TextOut (0, i*cy, regname[i+RegAddr]);
      if i+RegAddr = 8 then x := psw else x := ptrw(@reg[(i+RegAddr)*2])^;
      TextOut (4*cx, i*cy, WordToStr(x, '0'));
    end {for};
  end {with};
{ set the scroll bar }
  with RegScrollBar do
  begin
    SetParams (RegAddr, 0, REGROWS+1-rows);
    LargeChange := rows-1;
  end {with};
end;



{ BINARY EDITOR BOX EVENTS }

procedure TDebugForm.BinGroupBoxClick(Sender: TObject);
begin
  BinEdit.SetFocus;
  Unselect;
  BinGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.BinBoxScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  BinAddr := 16*word(ScrollPos) + RAMSTART;
  BinEdit.SetFocus;
  Unselect;
  BinGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.BinPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row, rows, j, w, z: integer;
  cx, cy: integer;	{ font size in pixels }
begin
  BinEdit.SetFocus;
  Unselect;
  BinGroupBox.Font.Color := SELECTED;
  CloseEdit;
  with BinPaintBox do
  begin
    cx := Canvas.TextWidth ('0');
    cy := Canvas.TextHeight ('0');
    rows := Height div cy;
    Col := X div cx;
    Row := Y div cy;
  end {with};
  j := wordwidth + 16 * bytewidth + 18;		{ column of characters }
  if BinDataSize = 2 then w := wordwidth else w := bytewidth;
  z := BinDataSize * (bytewidth+1);		{ raster of binary data }
  if Row >= rows then Exit;
  if (Row = 0) and (Col < wordwidth) then
  begin				{select BinAddr edition}
    EditState := BinAddrEditSt;
    EditAddr := 0;
    Col := 0;
    w := wordwidth;
    BinEdit.CharCase := ecUpperCase;
  end
  else if (Col >= wordwidth+2) and (Col < j) and
	(((Col-wordwidth-2) mod z) < w) then
  begin				{select binary data edition in the BinBox}
    Col := (Col-wordwidth-2) div z;
    EditAddr := BinAddr + word(16*Row + BinDataSize*Col);
    if not IsInRam (EditAddr) then Exit;
    Col := Col * z + wordwidth + 2;
    EditState := BinDataEditSt;
    BinEdit.CharCase := ecUpperCase;
  end
  else if (Col >= j) and (Col < j+16) then
  begin				{select character edition in the BinBox}
    EditAddr := BinAddr + word(16*Row + Col - j);
    if not IsInRam (EditAddr) then Exit;
    EditState := BinCharEditSt;
    w := 1;
    BinEdit.CharCase := ecNormal;
  end
  else
  begin
    Exit;
  end {if};
  BoxEdit (BinPaintBox, BinEdit, Col, Row, w);
end;


procedure TDebugForm.BinEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
  x, rows: word;
begin
  with BinPaintBox do
  begin
    rows := word(Height div Canvas.TextHeight ('0'));
  end {with};

  i := ArrowKeys (Key, BinScrollBar);
  if (i >= 0) and (EditState = NoEditSt) then
  begin
    BinAddr := 16*word(i) + RAMSTART;
    BinPaintBox.Invalidate;
  end

  else if Key = VK_RETURN then
  begin
    if EditState = BinAddrEditSt then
    begin
      x := GetValue (BinEdit.Text, radix) and $FFF0;
      if IsInRam (x) and IsInRam (x + 16*rows) then BinAddr := x;
      CloseEdit;
    end
    else if EditState = BinDataEditSt then
    begin
      if BinDataSize = 2 then
        ptrw(@ram[EditAddr-RAMSTART])^ := word(GetValue(BinEdit.Text, radix))
      else
        ram[EditAddr-RAMSTART] := byte(GetValue(BinEdit.Text, radix));
      CloseEdit;
    end
    else if EditState = BinCharEditSt then
    begin
      ram[EditAddr-RAMSTART] := byte(Ord(BinEdit.Text[1]));
      CloseEdit;
    end {if};
  end

  else if Key = VK_ESCAPE then CloseEdit;
end;


procedure TDebugForm.BinEditChange(Sender: TObject);
begin
  if (EditState = BinAddrEditSt) or (EditState = BinDataEditSt) then
    CheckEdit (BinEdit, radix);
end;


procedure TDebugForm.BinPaintBoxPaint(Sender: TObject);
var
  i, j, rows, cc: integer;
  a: word;
  x: byte;
  cx, cy: integer;	{ font size in pixels }
begin
  a := BinAddr;
  cc := wordwidth + 16 * bytewidth + 18;	{ column of characters }
  with BinPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Color;
    cx := Canvas.TextWidth ('0');
    cy := Canvas.TextHeight ('0');
    rows := Height div cy;
  end {with};
  with BinPaintBox.Canvas do
  begin
    for i := 0 to rows-1 do
    begin
      if not IsInRam (a) then break;
{ address }
      TextOut (0, i*cy, WordToStr(a, '0') + ':');
{ bytes }
      j := 0;
      while j < 16 do
      begin
        if BinDataSize = 2 then
        begin
          TextOut ( (wordwidth+2+(bytewidth+1)*j)*cx, i*cy,
		WordToStr(ptrw(@ram[a+word(j)-RAMSTART])^, '0') );
        end
        else
        begin
          TextOut ( (wordwidth+2+(bytewidth+1)*j)*cx, i*cy,
		ByteToStr(ram[a+word(j)-RAMSTART], '0') );
        end {if};
        Inc (j, BinDataSize);
      end {while};
{ characters }
      for j := 0 to 15 do
      begin
        x := ram[a+word(j)-RAMSTART];
        if (x < $20) or (x > $7E) then x := byte(Ord('.'));
        TextOut ((cc+j)*cx, i*cy, Chr(x));
      end {for};
      Inc (a, 16);
    end {for};
  end {with};
{ set the scroll bar }
  with BinScrollBar do
  begin
    SetParams ((BinAddr-RAMSTART) div 16, 0, RamSize div 16 - rows);
    LargeChange := rows;
  end {with};
end;


procedure TDebugForm.BinRadioButtonClick(Sender: TObject);
begin
  BinDataSize := TRadioButton(Sender).Tag;
  BinEdit.SetFocus;
  Unselect;
  BinGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;



{ MACHINE CODE EXECUTION CONTROL }

procedure TDebugForm.StepGroupBoxClick(Sender: TObject);
begin
  StepGroupBox.SetFocus;
  Unselect;
  StepGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.StepButtonClick(Sender: TObject);
begin
  CpuRun;
  SetListBoundaries (ptrw(@reg[R7])^);
  StepGroupBox.SetFocus;
  Unselect;
  StepGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.TraceGroupBoxClick(Sender: TObject);
begin
  TraceEdit.SetFocus;
  Unselect;
  TraceGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.TraceButtonClick(Sender: TObject);
var
  i: integer;
begin
  with TraceEdit do
  begin
    i := GetValue (Text, 10);
    SetFocus;
  end {with};
  Unselect;
  TraceGroupBox.Font.Color := SELECTED;
  CloseEdit;
  if i > 0 then
  begin
    BreakPoint := -1;
    CpuSteps := i;
    Hide;
  end {if};
end;


{ remove digits out of specified range from the edited string }
procedure TDebugForm.TraceEditChange(Sender: TObject);
begin
  CheckEdit (TraceEdit, 10);
end;


procedure TDebugForm.BpGroupBoxClick(Sender: TObject);
begin
  BpEdit.SetFocus;
  Unselect;
  BpGroupBox.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.BpButtonClick(Sender: TObject);
var
  i: integer;
begin
  with BpEdit do
  begin
    i := GetValue (Text, radix);
    SetFocus;
  end {with};
  Unselect;
  BpGroupBox.Font.Color := SELECTED;
  CloseEdit;
  BreakPoint := i;
  CpuSteps := -1;
  Hide;
end;


procedure TDebugForm.BpEditChange(Sender: TObject);
begin
  CheckEdit (BpEdit, radix);
end;



{ GENERAL FORM EVENTS }

procedure TDebugForm.DebugCreate(Sender: TObject);
var
  IniMK: TIniFile;
begin
  CloseEdit;
  RegAddr := 0;
  BinAddr := RAMSTART;
  SetListBoundaries (ROMSTART);
  IniMK := TIniFile.Create (ExpandFileName(IniName));
  with IniMK do
  begin
    radix := ReadInteger ('Debugger', 'Radix', 16);
  end {with};
  if (radix < 8) or (radix > 16) then radix := 16;
  IniMK.Free;
  bytewidth := Length(TrimLeft(CardToStr($FF, cardinal(radix), ' ')));
  wordwidth := Length(TrimLeft(CardToStr($FFFF, cardinal(radix), ' ')));
  BpEdit.MaxLength := wordwidth;
  Width := (wordwidth + 16*bytewidth + 34) * 8 + 65;
{ The constant 8 in the above expression represents the character width.
  Replacing it with BinPaintBox.Canvas.TextWidth('0') would be more elegant,
  but wouldn't work, because the font is not known at this moment. }
  BinGroupBox.Width := Width - 24;
end;


procedure TDebugForm.DebugShow(Sender: TObject);
begin
  CpuStop := True;
  CpuSteps := -1;
  BreakPoint := -1;
  SetListBoundaries (ptrw(@reg[R7])^);
  ListEdit.SetFocus;
  Unselect;
  ListGroupBox.Font.Color := SELECTED;
end;


procedure TDebugForm.DebugHide(Sender: TObject);
begin
  CloseEdit;
  Hide;
  CpuDelay := 30;
  CpuStop := False;
end;


end.

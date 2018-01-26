unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IniFiles, ThdTimer;

type
    TMainForm = class(TForm)
    RefreshTimer: TTimer;
    RunTimer: TThreadedTimer;
    RtcTimer: TThreadedTimer;
    SecTimer: TTimer;
    RomSaveDialog: TSaveDialog;
    procedure OnRefreshTimer(Sender: TObject);
    procedure OnRunTimer(Sender: TObject);
    procedure OnRtcTimer(Sender: TObject);
    procedure OnSecTimer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationDeactivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
    MainForm: TMainForm;

implementation

{$R *.dfm}

uses
    Def, Cpu, Debug, Keyboard, Rtc, IoSystem, Lcd;

const
    FaceName: string = 'face.bmp';
    KeysName: string = 'keys.bmp';
    OverlayName: string = 'overlay.bmp';
    RomName: string = 'rom.bin';
    RomtName: string = 'romt.bin';
    LoadMsg: string = 'Failed to load the file ';
    SaveMsg: string = 'Failed to save the file ';

var
    BitMap, Face, LcdBmp, KeyBmp, OverlayBmp: TBitMap;
    RedrawReq: boolean;		{ true if the LcdBmp image has changed and
				  needs to be redrawn }
    SaveRom: integer;

{ LCD }
    ScrMem: array[0..959] of byte;	{ LCD shadow memory }

{ CPU }
    CpuSpeed: integer;		{ how many instructions executes the emulated
				  CPU at each RunTimer call }


{ draws the image of a key from the KeyBmp }
procedure DrawKey (index, x, y: integer; pressed: boolean);
var
  offset: word;
begin
  with keypad[index] do
  begin
    BitMap.Width := W;
    BitMap.Height := H;
    if (pressed) then offset := 0 else offset := W;
    BitMap.Canvas.Draw (-OX - offset, -OY, KeyBmp);
  end {with};
  BitMap.TransparentColor := $0000FF00;
  BitMap.Transparent := True;
  Face.Canvas.Draw (x, y, BitMap);
  BitMap.Transparent := False;
  BitMap.Canvas.Draw (-x, -y, Face);
  MainForm.Canvas.Draw (x, y, BitMap);
end {DrawKey};


{ draw the LCD contents }
procedure View;
var
  Page, Row, Col, Pixel, X, Y: Integer;
  B: byte;
  Index, A: word;
begin
  A := LcdMemAddr;
  with LcdBmp.Canvas do
  begin
    Brush.Style := bsSolid;

{ draw the pixels }
    Index := 0;
    X := 0;
    Y := 0;
    for Page := 0 to 1 do
    begin
      for Row := 0 to 31 do
      begin
        for Col := 0 to 14 do
        begin
{ the display memory is assumed to be in the RAM area }
          if IsInRam(A+Index) then B := ram[A+Index] else B := $FF;
          if ScrMem[Index] = B then Inc (X, 24) else
          begin
            RedrawReq := True;
            ScrMem[Index] := B;
            for Pixel := 0 to 7 do
            begin
              if (B and $80) = 0 then Brush.Color := clWhite
                                 else Brush.Color := clBlack;
              B := B shl 1;
              FillRect (Rect(X, Y, X+3, Y+3));
              Inc (X, 3);
            end {for Pixel};
          end {if};
          Inc (Index, 2);
        end {for Col};
        Dec (X, 360);
        Inc (Y, 3)
      end {for Row};
      Dec (Index, 959);
    end {for Page};
  end {with};
end; {proc View}


{ In order to avoid display flickers all drawing is done off-screen
  on LcdBmp.Canvas, then periodically transferred to MainForm.Canvas }
procedure TMainForm.OnRefreshTimer(Sender: TObject);
begin
  View;
  if RedrawReq = True then Canvas.Draw (62, 55, LcdBmp);
  RedrawReq := False;
end;


{ release a pressed key if it's placed outside the coordinates X,Y }
procedure ReleaseKey1 (X, Y: Integer);
var
  i, r, c, k: integer;
begin
  if KeyCode1 = 0 then Exit;

{ locate the "keyblock" the key "KeyCode1" belongs to }
  i := 0;	{ "keyblock" index }
  k := 1;	{ first key code in the "keyblock" }
  while (KeyCode1 >= k + keypad[i].cnt) and (i < KEYPADS) do
  begin
    Inc (k, keypad[i].cnt);
    Inc (i);
  end {while};

  with keypad[i] do
  begin
    k := KeyCode1 - k;		{ offset of the key in the "keyblock" }
    c := L + SX*(k mod col);	{ X coordinate of the key image }
    r := T + SY*(k div col);	{ Y coordinate of the key image }
    if (X < c) or (X >= c + W) or (Y < r) or (Y >= r + H) then
    begin
{ shift the key label up-left to get an impression of a released key }
      BitMap.Width := W-8;
      BitMap.Height := H-8;
      BitMap.Transparent := False;
      BitMap.Canvas.Draw (-c-5, -r-5, Face);
      Face.Canvas.Draw (c+4, r+4, BitMap);
      DrawKey (i, c, r, False);
      KeyCode1 := 0;
    end {if};
  end {with};
end {ReleaseKey1};


{ called when mouse button pressed }
procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, r, c, k: Integer;
begin
{ proceed only when left mouse button pressed }
  if Button <> mbLeft then Exit;

  ReleaseKey1 (-1, -1);
  KeyCode1 := 1;
  for i := 0 to KEYPADS do
  begin
    with keypad[i] do
    begin
      if (X >= L) and (X < L+SX*col) and (((X-L) mod SX) < W) and
	(Y >= T) and (((Y-T) mod SY) < H) then
      begin
        c := (X-L) div SX;
        r := (Y-T) div SY;
        k := col*r + c;
        if k < cnt then
        begin
          Inc (KeyCode1, k);
          c := L+c*SX;
          r := T+r*SY;
{ shift the key label down-right to get an impression of a pressed key }
          BitMap.Width := W-8;
          BitMap.Height := H-8;
          BitMap.Transparent := False;
          BitMap.Canvas.Draw (-c-4, -r-4, Face);
          Face.Canvas.Draw (c+5, r+5, BitMap);
          DrawKey (i, c, r, True);
          break;
        end {if};
      end {if};
      Inc (KeyCode1, cnt);
    end {with};
  end {for};

  if KeyCode1 > LASTKEYCODE then	{ no valid key pressed }
  begin
    KeyCode1 := 0;
{ dragging a captionless form by clicking anywhere on the client area outside
  the controls }
    if BorderStyle = bsNone then
    begin
      ReleaseCapture;
      SendMessage (Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
    end {if};
  end {if};

  if KeyCode1 > 2 then KeyIrq;
end {proc};


{ called when mouse button released }
procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  K: integer;
begin
{ proceed only when left mouse button was pressed }
  if Button <> mbLeft then Exit;

  K := KeyCode1;
{ release a pressed key }
  ReleaseKey1 (-1, -1);

{ what to do if the mouse button was released over a pressed ... }
  if K = 1 then Close				{ ...power key }
  else if K = 2 then CpuReset;			{ ...Reset key }
end;


{ called when moving the mouse while the button pressed }
procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
{ release a pressed key if mouse was moved from it }
  ReleaseKey1 (X, Y);
end;


procedure TMainForm.FormShow(Sender: TObject);
var
  X: Integer;
begin
  KeyCode1 := 0;
  KeyCode2 := 0;
  CpuStop := False;
  CpuDelay := 0;
  CpuSteps := -1;
  BreakPoint := -1;
{ load the Keys.bmp image }
  if FileExists (KeysName) then
    KeyBmp.LoadFromFile (KeysName)
  else
    MessageDlg (LoadMsg + KeysName, mtWarning, [mbOk], 0);
  KeyBmp.Transparent := False;
{ load the Overlay.bmp image }
  if FileExists (OverlayName) then
    OverlayBmp.LoadFromFile (OverlayName)
  else
    MessageDlg (LoadMsg + OverlayName, mtWarning, [mbOk], 0);
  OverlayBmp.Transparent := False;
{ draw the background image on the Face.Canvas }
  if FileExists (FaceName) then
  begin
    BitMap.LoadFromFile (FaceName);
    BitMap.Transparent := False;
    Face.Canvas.Draw (0, 0, BitMap);
    MainForm.Canvas.Draw (0, 0, BitMap);
  end
  else
    MessageDlg (LoadMsg + FaceName, mtWarning, [mbOk], 0);
  Face.Transparent := False;
{ clear the display memory }
  for X := 0 to 959 do ScrMem[X] := ram[X+$200] xor $FF;
  CpuReset;
  RtcTimer.Enabled := True;
  SecTimer.Enabled := True;
  RunTimer.Enabled := True;
  RefreshTimer.Enabled := True;
  RedrawReq := True;
end;


{ load the ROM image }
procedure MemLoad;
var
  f: file;
begin
{ initialise the ROM area }
  FillChar (rom, ROMSIZE, $FF);
{ load the optional test ROM image }
  if FileExists (RomtName) then
  begin
    AssignFile (f, RomtName);
    Reset (f, 1);
    BlockRead (f, rom, $4000);
    CloseFile (f);
  end {if};
{ load the main ROM image }
  if FileExists (RomName) then
  begin
    AssignFile (f, RomName);
    Reset (f, 1);
    BlockRead (f, rom[$4000], ROMSIZE-$4000);
    CloseFile (f);
  end
  else MessageDlg (LoadMsg + RomName, mtWarning, [mbOk], 0);
end {MemLoad};


{ save the ROM image }
procedure MemSave;
var
  f: file;
begin
  if (SaveRom = 0) or not RomChanged then Exit;
  with MainForm.RomSaveDialog do
  begin
    InitialDir := GetCurrentDir;
    FileName := RomName;
    Filter := 'Binary files (*.bin)|*.BIN';
    if Execute then
    begin
      {$I-}
      AssignFile (f, FileName);
      Rewrite (f, 1);
      BlockWrite (f, rom[$4000], ROMSIZE-$4000);
      CloseFile (f);
      {$I+}
      if IOResult <> 0 then MessageDlg (SaveMsg, mtWarning, [mbOk], 0);
    end {if};
  end {with};
end {MemSave};


procedure IniLoad;
var
  IniMK: TIniFile;
begin
  IniMK := TIniFile.Create (ExpandFileName(IniName));
  with IniMK do
  begin
    CpuSpeed := ReadInteger ('Settings', 'CpuSpeed', 400);
    RamSize := ReadInteger ('Settings', 'RamSize', MINRAMSIZE);
    SaveRom := ReadInteger ('Debugger', 'SaveRom', 0);
  end {with};
  IniMK.Free;
end {IniLoad};


{ initialise the application }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  BitMap := TBitMap.Create;
  Face := TBitMap.Create;
  Face.Width := 790;
  Face.Height := 312;
  LcdBmp := TBitMap.Create;
  LcdBmp.Width := 360;
  LcdBmp.Height := 192;
  KeyBmp := TBitMap.Create;
  KeyBmp.Width := 124;
  KeyBmp.Height := 40;
  OverlayBmp := TBitMap.Create;
  OverlayBmp.Width := 282;
  OverlayBmp.Height := 72;
  IniLoad;
  if RamSize < MINRAMSIZE then RamSize := MINRAMSIZE;
  if RamSize > MAXRAMSIZE then RamSize := MAXRAMSIZE;
  RamSize := (RamSize + 15) and $FFF0;
  RamEnd := RAMSTART + RamSize - 1;
  MemLoad;
  LcdInit;
  IoInit;
  RtcInit;
end;


{ terminate the application }
procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CpuStop := True;
  RtcTimer.Enabled := False;
  SecTimer.Enabled := False;
  RunTimer.Enabled := False;
  RefreshTimer.Enabled := False;
  LcdClose;
  IoClose;
  RtcClose;
  BitMap.Free;
  Face.Free;
  LcdBmp.Free;
  KeyBmp.Free;
  OverlayBmp.Free;
  MemSave;
end;


{ show/hide the keyboard overlay }
procedure OverlayFlip;
const
  row: array[0..7] of integer = ( 25, 58, 93, 124, 155, 186, 217, 248 );
var
  Temp: TBitMap;
  i, y: integer;
begin
  Temp := TBitMap.Create;
  Temp.Width := 282;
  Temp.Height := 9;
  Temp.Transparent := False;
  BitMap.Width := 282;
  BitMap.Height := 9;
  BitMap.Transparent := False;
  y := 0;
  for i := 0 to 7 do
  begin
    Temp.Canvas.Draw (-486, -row[i], Face);
    BitMap.Canvas.Draw (0, -y, OverlayBmp);
    OverlayBmp.Canvas.Draw (0, y, Temp);
    Face.Canvas.Draw (486, row[i], BitMap);
    MainForm.Canvas.Draw (486, row[i], BitMap);
    Inc (y, 9);
  end {for};
  Temp.Free;
end {OverlayFlip};


procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
const
{ key codes 3 to 53 }
  Letters: string[51] = '12345:;67890/-ABWGDEVZIJKLMNOPRSTUFHC^[]XY_\@Qaaa,.';
var
  i: integer;
begin
  i := 1;
  Key := UpCase(Key);
  while (i <= 51) and (Key <> Letters[i]) do Inc (i);
  if i <= 51 then
  begin
    KeyCode2 := i+2;
    KeyIrq;
  end {if};
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  x: integer;
begin
  x := 0;
  case Key of
    VK_UP:	x := 50;
    VK_LEFT:	x := 51;	{ <- }
    VK_RIGHT:	x := 54;	{ -> }
    VK_BACK:	x := 55;	{ ZV }
    VK_RETURN:  x := 56;	{ VK }
    VK_DOWN:	x := 58;
    VK_NEXT:	x := 59;
    VK_SPACE:	x := 60;
    VK_PRIOR:	x := 61;
    VK_F2:	OverlayFlip;
    VK_F3:	DebugForm.Show;
    VK_F6:	x := 49;	{ su }
    VK_F7:	x := 57;	{ rus/lat }
    VK_F8:	x := 62;	{ FK }
    VK_F9:	x := 63;	{ v/n }
  end {case};
  if x <> 0 then
  begin
    KeyCode2 := x;
    KeyIrq;
  end {if};
end;


procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  KeyCode2 := 0;
end;


procedure TMainForm.FormPaint(Sender: TObject);
begin
  Face.Canvas.Draw (62, 55, LcdBmp);
  Canvas.Draw (0, 0, Face);
  RedrawReq := False;
end;


{ execute a bunch of machine code instructions }
procedure TMainForm.OnRunTimer(Sender: TObject);
var
  i: integer;
begin
  if CpuDelay > 0 then
  begin
    Dec (CpuDelay);
    Exit;
  end {if};
  i := 0;
  while i < CpuSpeed do
  begin
    if CpuStop then exit;
    Inc (i, CpuRun);
    if CpuSteps > 0 then
    begin
      Dec (CpuSteps);
      if CpuSteps = 0 then
      begin
        DebugForm.Show;
        break;
      end {if};
    end {if};
    if (BreakPoint >= 0) and (BreakPoint = ptrw(@reg[R7])^) then
    begin
      DebugForm.Show;
      break;
    end {if};
  end {while};
end;


procedure TMainForm.OnRtcTimer(Sender: TObject);
begin
  RtcIrq;
end;


procedure TMainForm.OnSecTimer(Sender: TObject);
begin
  RtcUpdate;
end;


procedure TMainForm.FormDeactivate(Sender: TObject);
begin
  ReleaseKey1 (-1, -1);
  KeyCode2 := 0;
end;


procedure TMainForm.ApplicationDeactivate(Sender: TObject);
begin
  ReleaseKey1 (-1, -1);
  KeyCode2 := 0;
end;

end.

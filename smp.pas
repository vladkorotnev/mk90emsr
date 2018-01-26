{ SMP memory modules with the chips KA1835VG2, KA1835VG7 }

unit Smp;

interface

  procedure SmpOpen (device: word);
  procedure SmpClose (device: word);
  function SmpCmd (device: word; x: byte) : byte;
  function SmpData (device: word; x: byte) : byte;

implementation

  uses SysUtils, Def;

  const DEVICES = 2;

  smpname: array [0..DEVICES-1] of string = ('smp0.bin', 'smp1.bin');

  type
    Tparam = record
      handle: file of byte;
      exists: boolean;
      size: cardinal;		{ file size > 64K means a ROM module }
      position: cardinal;
      mask: cardinal;
      cmd: byte;
      str: string;
      strpos: cardinal;
      emufname: string;
    end;

  var
    param: array[0..DEVICES-1] of Tparam;


procedure SmpOpen (device: word);
var
  filename: string;
  SRec: TSearchRec;
                 Res: Integer;
begin
  if device >= DEVICES then exit;
  filename := smpname[device];
  with param[device] do
  begin
    exists := FileExists (filename);
    if not exists then exit;
    AssignFile (handle, filename);
    Reset (handle);
    position := 0;
    size := cardinal(FileSize (handle));
    if size < $10000 then mask := $FFFF else mask := $FFFFFF;
    cmd := $00;
    Res := FindFirst('sdcard\*.bin', faAnyfile, SRec);
              str := '';
              If Res = 0 then
              try
                while Res = 0 do
                begin
                  if (SRec.Attr and faDirectory <> faDirectory) then
                    str := str + SRec.Name + chr(13);
                  Res := FindNext(SRec);
                end;
              finally
                FindClose(SRec);
              end;
              str := str + chr(0);
              strpos := length(str); {donno why but otherwise 1 char is missed}
  end {with};
end {SmpOpen};


procedure SmpClose (device: word);
begin
  if device >= DEVICES then exit;
  with param[device] do
  begin
    if exists then CloseFile (handle);
  end {with};
end {SmpClose};


{ reads or writes the first byte from/to the SMP after the SELECT signal
  has become active, interpreted as command }
function SmpCmd (device: word; x: byte) : byte;
begin
  if device < DEVICES then param[device].cmd := x;
  SmpCmd := 0;
end {SmpCmd};


{ reads or writes a data byte from/to the SMP, depending on the cmd }
function SmpData (device: word; x: byte) : byte;
begin
  SmpData := $FF;
  if device >= DEVICES then exit;
  with param[device] do
  begin
    if not exists then exit;
    case cmd and $FF of
      $00: begin		{Read Something}
             SmpData := $00;
           end;
      $A0: begin		{Write Address}
             position := ((position shl 8) or x) and mask;
           end;
      $10, $D0: begin		{Read Data}
             if position < size then
             begin
                Seek (handle, longint(position));
                Read (handle, result);
             end {if};
             if (cmd and $80) = 0 then Dec (position) else Inc (position);
             position := position and mask;
           end;
      $20, $C0, $E0: begin	{Write Data}
             if position < size then
             begin
               Seek (handle, longint(position));
               if size < $10000 then Write (handle, x);
             end {if};
             if (cmd and $20) = 0 then Inc (position) else Dec (position);
             position := position and mask;
           end;
     { Start protocol for SMPEmu flash cart }
      $F0: begin { List files in card }
             if strpos < length(str) then begin
                 result := ord(str[strpos]);
                 strpos := strpos + 1;
             end
             else begin
                 strpos := 0;
                 result := 0;
             end;
             emufname := '';
           end;
      $F1: begin { Set emulation file name }
             if(x > 0) then emufname := emufname + chr(x)
             else begin
                      if exists then CloseFile(handle);
                      exists := FileExists ('sdcard\'+emufname);
                      if not exists then exit;
                      AssignFile (handle, 'sdcard\'+emufname);
                       Reset (handle);
                      position := 0;
                      size := cardinal(FileSize (handle));
                    if size < $10000 then mask := $FFFF else mask := $FFFFFF;
                      cmd := $00;
                  end;
           end;

     { End protocol for SMPEmu flash cart }
    end {case};
  end {with};
end {SmpData};


end.

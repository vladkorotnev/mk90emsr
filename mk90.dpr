program MK90;

uses
  Forms,
  Windows,
  Main in 'main.pas' {MainForm},
  Def in 'def.pas',
  Cpu in 'cpu.pas',
  Decoder in 'decoder.pas',
  Exec in 'exec.pas',
  Srcdst in 'srcdst.pas',
  Numbers in 'numbers.pas',
  Debug in 'debug.pas' {DebugForm},
  Pdp11dis in 'pdp11dis.pas',
  Keyboard in 'keyboard.pas',
  IoSystem in 'iosystem.pas',
  Smp in 'smp.pas',
  Rtc in 'rtc.pas',
  Lcd in 'lcd.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'MK90 emulator';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.Run;
end.


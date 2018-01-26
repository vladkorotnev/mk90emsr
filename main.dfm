object MainForm: TMainForm
  Left = 80
  Top = 116
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsNone
  Caption = 'MK90'
  ClientHeight = 312
  ClientWidth = 790
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object RunTimer: TThreadedTimer
    Interval = 10
    OnTimer = OnRunTimer
    Left = 40
    Top = 8
  end
  object RtcTimer: TThreadedTimer
    Interval = 32
    OnTimer = OnRtcTimer
    Left = 40
    Top = 72
  end
  object RefreshTimer: TTimer
    Enabled = False
    Interval = 32
    OnTimer = OnRefreshTimer
    Left = 40
    Top = 144
  end
  object SecTimer: TTimer
    Enabled = False
    OnTimer = OnSecTimer
    Left = 40
    Top = 216
  end
  object RomSaveDialog: TSaveDialog
    Title = 'Save the modified ROM image'
    Left = 144
    Top = 8
  end
end

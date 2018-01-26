object DebugForm: TDebugForm
  Left = 376
  Top = 206
  Width = 625
  Height = 373
  Caption = 'Debug Window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpFixed
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = DebugCreate
  OnHide = DebugHide
  OnShow = DebugShow
  PixelsPerInch = 96
  TextHeight = 13
  object BinGroupBox: TGroupBox
    Left = 8
    Top = 176
    Width = 601
    Height = 161
    Anchors = [akLeft, akTop, akBottom]
    Caption = ' Binary Editor '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = BinGroupBoxClick
    object BinPaintBox: TPaintBox
      Left = 8
      Top = 16
      Width = 561
      Height = 137
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      OnMouseDown = BinPaintBoxMouseDown
      OnPaint = BinPaintBoxPaint
    end
    object BinScrollBar: TScrollBar
      Left = 577
      Top = 16
      Width = 16
      Height = 137
      Anchors = [akTop, akRight, akBottom]
      Kind = sbVertical
      PageSize = 0
      TabOrder = 1
      TabStop = False
      OnScroll = BinBoxScroll
    end
    object RadioButtonByte: TRadioButton
      Tag = 1
      Left = 104
      Top = -1
      Width = 49
      Height = 17
      Caption = 'byte'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = BinRadioButtonClick
    end
    object RadioButtonWord: TRadioButton
      Tag = 2
      Left = 160
      Top = -1
      Width = 49
      Height = 17
      Caption = 'word'
      TabOrder = 3
      OnClick = BinRadioButtonClick
    end
    object BinEdit: TEdit
      Left = 32
      Top = 32
      Width = 40
      Height = 21
      TabStop = False
      BorderStyle = bsNone
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 4
      ParentFont = False
      TabOrder = 0
      OnChange = BinEditChange
      OnKeyDown = BinEditKeyDown
    end
  end
  object ListGroupBox: TGroupBox
    Left = 8
    Top = 8
    Width = 313
    Height = 161
    Caption = ' Disassembly '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = ListGroupBoxClick
    object ListPaintBox: TPaintBox
      Left = 8
      Top = 16
      Width = 273
      Height = 137
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      OnMouseDown = ListPaintBoxMouseDown
      OnPaint = ListPaintBoxPaint
    end
    object ListScrollBar: TScrollBar
      Left = 288
      Top = 16
      Width = 16
      Height = 137
      Anchors = [akTop, akRight, akBottom]
      Kind = sbVertical
      PageSize = 0
      TabOrder = 1
      TabStop = False
      OnScroll = ListBoxScroll
    end
    object ListEdit: TEdit
      Left = 32
      Top = 32
      Width = 40
      Height = 21
      TabStop = False
      BorderStyle = bsNone
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 4
      ParentFont = False
      TabOrder = 0
      OnChange = ListEditChange
      OnKeyDown = ListEditKeyDown
    end
  end
  object RegGroupBox: TGroupBox
    Left = 328
    Top = 8
    Width = 121
    Height = 161
    Caption = ' Registers '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = RegGroupBoxClick
    object RegPaintBox: TPaintBox
      Left = 8
      Top = 16
      Width = 81
      Height = 137
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      OnMouseDown = RegPaintBoxMouseDown
      OnPaint = RegPaintBoxPaint
    end
    object RegScrollBar: TScrollBar
      Left = 97
      Top = 16
      Width = 16
      Height = 137
      Anchors = [akTop, akRight, akBottom]
      Kind = sbVertical
      Max = 0
      PageSize = 0
      TabOrder = 1
      TabStop = False
      OnScroll = RegBoxScroll
    end
    object RegEdit: TEdit
      Left = 32
      Top = 32
      Width = 40
      Height = 21
      TabStop = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 4
      ParentFont = False
      TabOrder = 0
      OnChange = RegEditChange
      OnKeyDown = RegEditKeyDown
    end
  end
  object StepGroupBox: TGroupBox
    Left = 456
    Top = 8
    Width = 153
    Height = 49
    Caption = ' Single step '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = StepGroupBoxClick
    object StepButton: TButton
      Left = 88
      Top = 16
      Width = 49
      Height = 25
      Caption = 'Run'
      TabOrder = 0
      TabStop = False
      OnClick = StepButtonClick
    end
  end
  object TraceGroupBox: TGroupBox
    Left = 456
    Top = 64
    Width = 153
    Height = 49
    Caption = ' Number of steps (decimal) '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = TraceGroupBoxClick
    object TraceEdit: TEdit
      Left = 16
      Top = 16
      Width = 57
      Height = 21
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 6
      ParentFont = False
      TabOrder = 1
      OnChange = TraceEditChange
      OnClick = TraceGroupBoxClick
    end
    object TraceButton: TButton
      Left = 88
      Top = 16
      Width = 49
      Height = 25
      Caption = 'Run'
      TabOrder = 0
      TabStop = False
      OnClick = TraceButtonClick
    end
  end
  object BpGroupBox: TGroupBox
    Left = 456
    Top = 120
    Width = 153
    Height = 49
    Caption = ' Breakpoint address '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = BpGroupBoxClick
    object BpEdit: TEdit
      Left = 16
      Top = 16
      Width = 57
      Height = 21
      TabStop = False
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = BpEditChange
      OnClick = BpGroupBoxClick
    end
    object BpButton: TButton
      Left = 88
      Top = 16
      Width = 49
      Height = 25
      Caption = 'Run'
      TabOrder = 0
      TabStop = False
      OnClick = BpButtonClick
    end
  end
end

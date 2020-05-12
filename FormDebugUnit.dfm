object FormDebug: TFormDebug
  Left = 402
  Top = 162
  Caption = 'FormDebug'
  ClientHeight = 750
  ClientWidth = 1226
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LaMainChartMsg: TLabel
    Left = 0
    Top = 174
    Width = 753
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = '---'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label1: TLabel
    Left = 0
    Top = 152
    Width = 76
    Height = 13
    Caption = 'Main Chart msg:'
  end
  object LaMainChartMsg2: TLabel
    Left = 0
    Top = 206
    Width = 753
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = '---'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object LaChartTime: TLabel
    Left = 0
    Top = 240
    Width = 60
    Height = 13
    Caption = 'LaChartTime'
  end
  object LaMainChartMsg3: TLabel
    Left = 0
    Top = 254
    Width = 753
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = '---'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label4: TLabel
    Left = 224
    Top = 72
    Width = 34
    Height = 13
    Caption = 'interval'
  end
  object Label3: TLabel
    Left = 200
    Top = 48
    Width = 66
    Height = 13
    Caption = 'KolPTCdebug'
  end
  object Label2: TLabel
    Left = 16
    Top = 126
    Width = 753
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = '---'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object BuDebugMemory: TButton
    Left = 6
    Top = 8
    Width = 76
    Height = 25
    Caption = 'Show Memory'
    TabOrder = 0
    OnClick = BuDebugMemoryClick
  end
  object BuInfo: TButton
    Left = 96
    Top = 8
    Width = 121
    Height = 25
    Caption = 'Info'
    TabOrder = 1
    OnClick = BuInfoClick
  end
  object BuMonSizeOf: TButton
    Left = 351
    Top = 10
    Width = 90
    Height = 17
    Caption = 'BuMonSizeOf'
    TabOrder = 2
    OnClick = BuMonSizeOfClick
  end
  object BuHide: TButton
    Left = 728
    Top = 0
    Width = 113
    Height = 41
    Caption = 'Hide'
    TabOrder = 3
    OnClick = BuHideClick
  end
  object MeChart: TMemo
    Left = 8
    Top = 288
    Width = 305
    Height = 273
    Lines.Strings = (
      'MeChart')
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object MeChart2: TMemo
    Left = 344
    Top = 304
    Width = 305
    Height = 273
    Lines.Strings = (
      'MeChart')
    ScrollBars = ssBoth
    TabOrder = 5
  end
  object chkChartDump: TCheckBox
    Left = 344
    Top = 288
    Width = 81
    Height = 17
    Caption = 'chkChartDump'
    TabOrder = 6
  end
  object cbKolPTcLog: TCheckBox
    Left = 24
    Top = 48
    Width = 129
    Height = 25
    Caption = 'KolPTCLogEnabled'
    TabOrder = 7
    OnClick = cbKolPTcLogClick
  end
  object CheckBox2: TCheckBox
    Left = 24
    Top = 80
    Width = 89
    Height = 17
    Caption = 'log smgs'
    TabOrder = 8
    OnClick = CheckBox2Click
  end
  object ELogInterval: TEdit
    Left = 280
    Top = 64
    Width = 113
    Height = 21
    TabOrder = 9
    Text = '300'
    OnChange = ELogIntervalChange
  end
  object Button2: TButton
    Left = 440
    Top = 40
    Width = 97
    Height = 17
    Caption = 'EnableDisableGr'
    TabOrder = 10
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 661
    Top = 297
    Width = 240
    Height = 305
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 11
  end
  object BuMonListHist: TButton
    Left = 791
    Top = 247
    Width = 65
    Height = 25
    Caption = 'List Hist'
    TabOrder = 12
    OnClick = BuMonListHistClick
  end
  object BuMonClearHist: TButton
    Left = 765
    Top = 180
    Width = 163
    Height = 20
    Caption = 'Clear history'
    TabOrder = 13
    OnClick = BuMonClearHistClick
  end
  object Button1: TButton
    Left = 872
    Top = 48
    Width = 65
    Height = 33
    Caption = 'Button1'
    TabOrder = 14
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 872
    Top = 8
    Width = 65
    Height = 33
    Caption = 'Panel1'
    TabOrder = 15
  end
  object ScrollBar1: TScrollBar
    Left = 680
    Top = 112
    Width = 329
    Height = 25
    PageSize = 0
    TabOrder = 16
    OnChange = ScrollBar1Change
  end
  object Edit1: TEdit
    Left = 784
    Top = 56
    Width = 73
    Height = 21
    TabOrder = 17
    Text = 'Edit1'
  end
  object Button3: TButton
    Left = 400
    Top = 616
    Width = 249
    Height = 49
    Caption = 'Test Hist'
    TabOrder = 18
    OnClick = Button3Click
  end
  object TestPanel: TPanel
    Left = 920
    Top = 368
    Width = 289
    Height = 369
    Caption = 'TestPanel'
    TabOrder = 19
  end
  object BuTestChart: TButton
    Left = 976
    Top = 40
    Width = 73
    Height = 25
    Caption = 'BuTestChart'
    TabOrder = 20
    OnClick = BuTestChartClick
  end
  object Button4: TButton
    Left = 40
    Top = 632
    Width = 153
    Height = 41
    Caption = 'Test MyFloatToStr'
    TabOrder = 21
    OnClick = Button4Click
  end
  object Edit2: TEdit
    Left = 56
    Top = 608
    Width = 121
    Height = 21
    TabOrder = 22
    Text = 'Edit2'
  end
  object Button5: TButton
    Left = 1072
    Top = 40
    Width = 121
    Height = 49
    Caption = 'Test Conversion'
    TabOrder = 23
    OnClick = Button5Click
  end
  object ListBox1: TListBox
    Left = 944
    Top = 152
    Width = 257
    Height = 321
    ItemHeight = 13
    ScrollWidth = 500
    TabOrder = 24
  end
  object Button6: TButton
    Left = 576
    Top = 48
    Width = 113
    Height = 25
    Caption = 'Test Exception'
    TabOrder = 25
    OnClick = Button6Click
  end
end

object FormSimpleModule: TFormSimpleModule
  Left = 624
  Top = 377
  Caption = 'Simple PTC control module'
  ClientHeight = 222
  ClientWidth = 553
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label35: TLabel
    Left = 286
    Top = 61
    Width = 20
    Height = 16
    Caption = 'mV'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label36: TLabel
    Left = 286
    Top = 20
    Width = 52
    Height = 16
    Caption = 'mA.cm-2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object LaMsg: TLabel
    Left = 16
    Top = 102
    Width = 505
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
  object BuStop: TButton
    Left = 464
    Top = 18
    Width = 81
    Height = 63
    Caption = 'Stop'
    TabOrder = 0
    OnClick = BuStopClick
  end
  object BuSetCurrent: TButton
    Left = 345
    Top = 17
    Width = 113
    Height = 25
    Caption = 'Force CURRENT'
    TabOrder = 1
    OnClick = BuSetCurrentClick
  end
  object BuSetVoltage: TButton
    Left = 345
    Top = 59
    Width = 113
    Height = 24
    Caption = 'Force VOLTAGE'
    TabOrder = 2
    OnClick = BuSetVoltageClick
  end
  object EVoltageSp: TEdit
    Left = 190
    Top = 61
    Width = 88
    Height = 21
    TabOrder = 3
    Text = '650'
    OnKeyPress = EVoltageSpKeyPress
  end
  object ECurrentsp: TEdit
    Left = 190
    Top = 20
    Width = 88
    Height = 21
    TabOrder = 4
    Text = '1'
    OnKeyPress = ECurrentspKeyPress
  end
  object BuConLoad: TButton
    Left = 18
    Top = 57
    Width = 160
    Height = 33
    Caption = 'Connect LOAD to PTC'
    TabOrder = 5
    OnClick = BuConLoadClick
  end
  object buDisconLoad: TButton
    Left = 17
    Top = 18
    Width = 161
    Height = 33
    Caption = 'Disconnect LOAD from PTC'
    TabOrder = 6
    OnClick = buDisconLoadClick
  end
  object BuHide: TButton
    Left = 19
    Top = 139
    Width = 126
    Height = 38
    Caption = 'Hide'
    TabOrder = 7
    OnClick = BuHideClick
  end
  object Button1: TButton
    Left = 216
    Top = 144
    Width = 49
    Height = 25
    Caption = 'Lock'
    TabOrder = 8
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 296
    Top = 144
    Width = 41
    Height = 25
    Caption = 'Unlock'
    TabOrder = 9
    OnClick = Button2Click
  end
end

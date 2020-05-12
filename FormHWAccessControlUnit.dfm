object FormHWAccessControl: TFormHWAccessControl
  Left = 609
  Top = 385
  Width = 706
  Height = 341
  Caption = 'FormHWAccessControl'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 117
    Height = 13
    Caption = 'HW Access Lock Status'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 115
    Height = 13
    Caption = 'HW Access Lock Name'
  end
  object Label3: TLabel
    Left = 16
    Top = 56
    Width = 98
    Height = 13
    Caption = 'HW Access Lock ID'
  end
  object Label4: TLabel
    Left = 16
    Top = 80
    Width = 105
    Height = 13
    Caption = 'HW Access Lock Info'
  end
  object PanProjDescript: TPanel
    Left = 148
    Top = 5
    Width = 295
    Height = 20
    BorderStyle = bsSingle
    Caption = 'Pan'
    ParentColor = True
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 132
    Top = 29
    Width = 295
    Height = 20
    BorderStyle = bsSingle
    Caption = 'Pan'
    ParentColor = True
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 132
    Top = 53
    Width = 295
    Height = 20
    BorderStyle = bsSingle
    Caption = 'Pan'
    ParentColor = True
    TabOrder = 2
  end
  object Panel3: TPanel
    Left = 140
    Top = 77
    Width = 295
    Height = 20
    BorderStyle = bsSingle
    Caption = 'Pan'
    ParentColor = True
    TabOrder = 3
  end
  object Button1: TButton
    Left = 336
    Top = 128
    Width = 113
    Height = 41
    Caption = 'Hide'
    TabOrder = 4
  end
  object Button2: TButton
    Left = 32
    Top = 112
    Width = 113
    Height = 41
    Caption = 'Force release lock'
    TabOrder = 5
  end
end

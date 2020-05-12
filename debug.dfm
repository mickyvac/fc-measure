object Form3: TForm3
  Left = 942
  Top = 345
  Width = 480
  Height = 587
  Caption = 'Debug and Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 237
    Height = 13
    Caption = 'Program for measiuring Volt-Ampere Characteristic '
  end
  object Label2: TLabel
    Left = 16
    Top = 32
    Width = 209
    Height = 13
    Caption = 'using BMC Messsysteme PCIBase1000 card'
  end
  object Label3: TLabel
    Left = 16
    Top = 48
    Width = 379
    Height = 13
    Caption = 
      '(c) 2008 Michal Vaclavu michal.vaclavu@gmail.com, Roman Fiala rf' +
      '@gmail.com'
  end
  object Label4: TLabel
    Left = 16
    Top = 72
    Width = 38
    Height = 13
    Caption = 'Version:'
  end
  object Label21: TLabel
    Left = 21
    Top = 424
    Width = 77
    Height = 13
    Caption = 'Set DA Outputs:'
  end
  object Label5: TLabel
    Left = 64
    Top = 72
    Width = 32
    Height = 13
    Caption = 'Label5'
  end
  object Memo1: TMemo
    Left = 16
    Top = 152
    Width = 209
    Height = 241
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button5: TButton
    Left = 16
    Top = 112
    Width = 209
    Height = 33
    Caption = 'PCIBase Card information'
    TabOrder = 1
    OnClick = Button5Click
  end
  object Edit1: TEdit
    Left = 17
    Top = 456
    Width = 112
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object Edit2: TEdit
    Left = 17
    Top = 496
    Width = 112
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object Button3: TButton
    Left = 137
    Top = 448
    Width = 96
    Height = 33
    Caption = 'DA1 Set Out'
    TabOrder = 4
  end
  object Button4: TButton
    Left = 137
    Top = 496
    Width = 96
    Height = 33
    Caption = 'DA2 Set Out'
    TabOrder = 5
  end
  object Memo2: TMemo
    Left = 249
    Top = 152
    Width = 208
    Height = 281
    Lines.Strings = (
      'Memo2')
    TabOrder = 6
  end
  object Button7: TButton
    Left = 249
    Top = 112
    Width = 209
    Height = 33
    Caption = 'Read ADs'
    TabOrder = 7
    OnClick = Button7Click
  end
  object Button1: TButton
    Left = 376
    Top = 448
    Width = 81
    Height = 81
    Caption = 'Hide'
    TabOrder = 8
    OnClick = Button1Click
  end
end

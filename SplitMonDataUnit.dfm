object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 120
    Width = 53
    Height = 13
    Caption = 'Separators'
  end
  object Edit1: TEdit
    Left = 16
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 200
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit2'
  end
  object Memo1: TMemo
    Left = 16
    Top = 152
    Width = 409
    Height = 105
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Button1: TButton
    Left = 72
    Top = 24
    Width = 57
    Height = 25
    Caption = 'Sel IN'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 312
    Top = 24
    Width = 49
    Height = 17
    Caption = 'Sel OUT'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 432
    Top = 32
    Width = 57
    Height = 25
    Caption = 'Process'
    TabOrder = 5
    OnClick = Button3Click
  end
  object CheckBox1: TCheckBox
    Left = 416
    Top = 80
    Width = 97
    Height = 17
    Caption = 'Test Only'
    TabOrder = 6
  end
  object Edit3: TEdit
    Left = 96
    Top = 120
    Width = 121
    Height = 21
    TabOrder = 7
    Text = ';='
  end
  object OpenDialog1: TOpenDialog
    Left = 8
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Left = 248
    Top = 8
  end
end

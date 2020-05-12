object Form1: TForm1
  Left = 469
  Top = 187
  Width = 722
  Height = 760
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 24
    Top = 64
    Width = 377
    Height = 617
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 480
    Top = 16
    Width = 89
    Height = 33
    Caption = 'Run Thread1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 24
    Top = 24
    Width = 169
    Height = 17
    Caption = 'Refresh - Read TEST'
    TabOrder = 2
    OnClick = CheckBox1Click
  end
  object Button2: TButton
    Left = 576
    Top = 16
    Width = 89
    Height = 33
    Caption = 'Pause Thread1'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 488
    Top = 80
    Width = 81
    Height = 41
    Caption = 'Run Thread2'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 488
    Top = 136
    Width = 89
    Height = 33
    Caption = 'Run T3'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 496
    Top = 288
    Width = 89
    Height = 57
    Caption = 'TeminateThreads'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 488
    Top = 192
    Width = 57
    Height = 25
    Caption = 'T4'
    TabOrder = 7
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 568
    Top = 224
    Width = 89
    Height = 25
    Caption = 'Pause ALL'
    TabOrder = 8
    OnClick = Button7Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 240
    Top = 16
  end
end

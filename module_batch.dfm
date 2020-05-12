object FormBatch: TFormBatch
  Left = 336
  Top = 159
  Width = 585
  Height = 763
  Caption = 'Batch module'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 13
    Top = 7
    Width = 176
    Height = 39
    Caption = 'Hide'
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 16
    Top = 72
    Width = 537
    Height = 249
    Lines.Strings = (
      'Example of command (IVchar):'
      ''
      'IVchar(type=return, timepstep=500, timehfr=50, '
      'filename="test", setpoints=[0,1,2,3,sequence(from=10, '
      'to=2000, step=200), 2500, 3000], '
      'undervoltageprotection=1, usegloballimits=0, '
      'votlimlow=0.350)'
      ''
      '#def MySeq=[0,10,20,sequence(0, 3000, 20)]')
    TabOrder = 1
    Visible = False
  end
  object Memo2: TMemo
    Left = 16
    Top = 328
    Width = 537
    Height = 225
    TabOrder = 2
  end
  object Button2: TButton
    Left = 240
    Top = 40
    Width = 105
    Height = 25
    Caption = 'Run'
    TabOrder = 3
  end
  object Memo3: TMemo
    Left = 8
    Top = 64
    Width = 537
    Height = 249
    TabOrder = 4
  end
end

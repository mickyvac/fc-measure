object Form5: TForm5
  Left = 275
  Top = 163
  Width = 906
  Height = 672
  Caption = 'Calibration'
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
    Left = 32
    Top = 328
    Width = 60
    Height = 13
    Caption = 'NEW values'
  end
  object Label2: TLabel
    Left = 696
    Top = 120
    Width = 99
    Height = 13
    Caption = 'Actual Voltage range'
  end
  object Label3: TLabel
    Left = 120
    Top = 272
    Width = 57
    Height = 13
    Caption = 'Input Factor'
  end
  object Label4: TLabel
    Left = 248
    Top = 272
    Width = 55
    Height = 13
    Caption = 'Input Offset'
  end
  object Label5: TLabel
    Left = 688
    Top = 208
    Width = 97
    Height = 13
    Caption = 'Actual Current range'
  end
  object Label8: TLabel
    Left = 376
    Top = 272
    Width = 72
    Height = 13
    Caption = 'Setpoint Factor'
  end
  object Label9: TLabel
    Left = 504
    Top = 272
    Width = 70
    Height = 13
    Caption = 'Setpoint Offset'
  end
  object Label6: TLabel
    Left = 32
    Top = 304
    Width = 50
    Height = 13
    Caption = 'Old values'
  end
  object Label7: TLabel
    Left = 32
    Top = 352
    Width = 593
    Height = 65
    AutoSize = False
    Caption = 'Label7'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object Label10: TLabel
    Left = 80
    Top = 448
    Width = 100
    Height = 13
    Caption = 'User measured value'
  end
  object Label11: TLabel
    Left = 64
    Top = 424
    Width = 117
    Height = 13
    Caption = 'Program measured value'
  end
  object Label12: TLabel
    Left = 16
    Top = 424
    Width = 22
    Height = 13
    Caption = 'Step'
  end
  object Label13: TLabel
    Left = 808
    Top = 472
    Width = 25
    Height = 13
    Caption = 'A / V'
  end
  object StringGrid1: TStringGrid
    Left = 16
    Top = 16
    Width = 641
    Height = 225
    ColCount = 6
    DefaultColWidth = 100
    RowCount = 8
    TabOrder = 0
  end
  object Button1: TButton
    Left = 688
    Top = 72
    Width = 153
    Height = 33
    Caption = 'Refresh'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 688
    Top = 24
    Width = 153
    Height = 33
    Caption = 'Exit'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 120
    Top = 296
    Width = 120
    Height = 21
    TabOrder = 3
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 248
    Top = 296
    Width = 120
    Height = 21
    TabOrder = 4
    Text = 'Edit2'
  end
  object Button3: TButton
    Left = 472
    Top = 424
    Width = 169
    Height = 49
    Caption = 'Save this new set of coefficients'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Edit3: TEdit
    Left = 376
    Top = 296
    Width = 120
    Height = 21
    TabOrder = 6
    Text = 'Edit3'
  end
  object Edit4: TEdit
    Left = 504
    Top = 296
    Width = 120
    Height = 21
    TabOrder = 7
    Text = 'Edit4'
  end
  object Button4: TButton
    Left = 680
    Top = 168
    Width = 169
    Height = 25
    Caption = 'Do Voltage calibration'
    TabOrder = 8
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 680
    Top = 264
    Width = 169
    Height = 25
    Caption = 'Do Current calibration'
    TabOrder = 9
    OnClick = Button5Click
  end
  object Edit5: TEdit
    Left = 696
    Top = 144
    Width = 129
    Height = 21
    Enabled = False
    TabOrder = 10
    Text = 'Edit5'
  end
  object Edit6: TEdit
    Left = 680
    Top = 232
    Width = 129
    Height = 21
    Enabled = False
    TabOrder = 11
    Text = 'Edit6'
  end
  object Edit7: TEdit
    Left = 120
    Top = 320
    Width = 120
    Height = 21
    TabOrder = 12
    Text = 'Edit7'
  end
  object Edit8: TEdit
    Left = 248
    Top = 320
    Width = 120
    Height = 21
    TabOrder = 13
    Text = 'Edit8'
  end
  object Edit9: TEdit
    Left = 376
    Top = 320
    Width = 120
    Height = 21
    TabOrder = 14
    Text = 'Edit9'
  end
  object Edit10: TEdit
    Left = 504
    Top = 320
    Width = 120
    Height = 21
    TabOrder = 15
    Text = 'Edit10'
  end
  object Edit11: TEdit
    Left = 184
    Top = 448
    Width = 121
    Height = 21
    TabOrder = 16
    Text = 'Edit11'
  end
  object Button6: TButton
    Left = 312
    Top = 440
    Width = 153
    Height = 33
    Caption = 'Confirm and do Next Step'
    Enabled = False
    TabOrder = 17
    OnClick = Button6Click
  end
  object Edit12: TEdit
    Left = 184
    Top = 424
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 18
    Text = 'Edit12'
  end
  object Memo1: TMemo
    Left = 32
    Top = 480
    Width = 625
    Height = 113
    Lines.Strings = (
      'Memo1')
    TabOrder = 19
  end
  object Edit13: TEdit
    Left = 8
    Top = 440
    Width = 57
    Height = 21
    TabOrder = 20
    Text = 'Edit13'
  end
  object Button8: TButton
    Left = 688
    Top = 400
    Width = 185
    Height = 41
    Caption = 'Use USER entered values and SAVE'
    TabOrder = 21
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 696
    Top = 368
    Width = 169
    Height = 25
    Caption = 'Select USER Current Calib'
    TabOrder = 22
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 696
    Top = 336
    Width = 169
    Height = 25
    Caption = 'Select USER Voltage Calib'
    TabOrder = 23
    OnClick = Button10Click
  end
  object Edit14: TEdit
    Left = 712
    Top = 472
    Width = 89
    Height = 21
    TabOrder = 24
    Text = '0'
  end
  object Button7: TButton
    Left = 712
    Top = 496
    Width = 113
    Height = 25
    Caption = 'Setpoint test'
    TabOrder = 25
    OnClick = Button7Click
  end
end

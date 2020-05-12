object Form1: TForm1
  Left = 407
  Top = 189
  Width = 1142
  Height = 656
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
  object Label1: TLabel
    Left = 56
    Top = 24
    Width = 69
    Height = 13
    Caption = 'hexcoded msg'
  end
  object Label2: TLabel
    Left = 408
    Top = 72
    Width = 30
    Height = 13
    Caption = 'Status'
  end
  object Label3: TLabel
    Left = 56
    Top = 152
    Width = 44
    Height = 13
    Caption = 'Hexamsg'
  end
  object Label9: TLabel
    Left = 648
    Top = 24
    Width = 87
    Height = 13
    Caption = 'Hexamsg (4 bytes)'
  end
  object Label12: TLabel
    Left = 952
    Top = 80
    Width = 87
    Height = 13
    Caption = 'Hexamsg (4 bytes)'
  end
  object Edit1: TEdit
    Left = 56
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '010105100001'
  end
  object Edit2: TEdit
    Left = 296
    Top = 40
    Width = 113
    Height = 21
    TabOrder = 1
    Text = 'Edit2'
  end
  object Button1: TButton
    Left = 200
    Top = 32
    Width = 65
    Height = 33
    Caption = 'crctest'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 56
    Top = 80
    Width = 81
    Height = 33
    Caption = 'Connect'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Edit3: TEdit
    Left = 56
    Top = 168
    Width = 209
    Height = 21
    TabOrder = 4
    Text = '01030b000002'
  end
  object Edit4: TEdit
    Left = 400
    Top = 88
    Width = 161
    Height = 21
    TabOrder = 5
    Text = 'Edit4'
  end
  object Button3: TButton
    Left = 312
    Top = 88
    Width = 65
    Height = 25
    Caption = 'Config'
    TabOrder = 6
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 160
    Top = 80
    Width = 81
    Height = 33
    Caption = 'DisConnect'
    TabOrder = 7
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 296
    Top = 432
    Width = 801
    Height = 169
    Lines.Strings = (
      'Memo1')
    TabOrder = 8
  end
  object Button5: TButton
    Left = 296
    Top = 168
    Width = 57
    Height = 25
    Caption = 'send'
    TabOrder = 9
    OnClick = Button5Click
  end
  object Edit10: TEdit
    Left = 648
    Top = 40
    Width = 145
    Height = 21
    TabOrder = 10
    Text = 'Edit10'
  end
  object Button9: TButton
    Left = 808
    Top = 40
    Width = 105
    Height = 25
    Caption = 'Back Convert to float'
    TabOrder = 11
    OnClick = Button9Click
  end
  object Edit11: TEdit
    Left = 944
    Top = 40
    Width = 153
    Height = 21
    TabOrder = 12
    Text = 'Edit11'
  end
  object Edit15: TEdit
    Left = 648
    Top = 96
    Width = 145
    Height = 21
    TabOrder = 13
    Text = 'Edit10'
  end
  object Button11: TButton
    Left = 808
    Top = 96
    Width = 113
    Height = 25
    Caption = 'Forward Convert to float'
    TabOrder = 14
    OnClick = Button11Click
  end
  object Edit16: TEdit
    Left = 944
    Top = 96
    Width = 153
    Height = 21
    TabOrder = 15
    Text = 'Edit11'
  end
  object Panel1: TPanel
    Left = 792
    Top = 136
    Width = 305
    Height = 233
    Caption = 'Panel1'
    TabOrder = 16
    object Label5: TLabel
      Left = 8
      Top = 56
      Width = 51
      Height = 13
      Caption = 'Addr(hexa)'
    end
    object Label7: TLabel
      Left = 8
      Top = 8
      Width = 51
      Height = 13
      Caption = 'Addr(hexa)'
    end
    object Label4: TLabel
      Left = 80
      Top = 56
      Width = 53
      Height = 13
      Caption = 'Value (0/1)'
    end
    object Label6: TLabel
      Left = 8
      Top = 104
      Width = 51
      Height = 13
      Caption = 'Addr(hexa)'
    end
    object Label8: TLabel
      Left = 80
      Top = 104
      Width = 54
      Height = 13
      Caption = 'N of Words'
    end
    object Label10: TLabel
      Left = 8
      Top = 152
      Width = 51
      Height = 13
      Caption = 'Addr(hexa)'
    end
    object Label11: TLabel
      Left = 80
      Top = 152
      Width = 54
      Height = 13
      Caption = 'N of Words'
    end
    object Button6: TButton
      Left = 72
      Top = 16
      Width = 97
      Height = 25
      Caption = 'ReadCoilStatus'
      TabOrder = 0
      OnClick = Button6Click
    end
    object Edit6: TEdit
      Left = 8
      Top = 24
      Width = 49
      Height = 21
      TabOrder = 1
      Text = '0510'
    end
    object Button7: TButton
      Left = 152
      Top = 72
      Width = 97
      Height = 25
      Caption = 'SetCoil'
      TabOrder = 2
      OnClick = Button7Click
    end
    object Edit7: TEdit
      Left = 80
      Top = 72
      Width = 49
      Height = 21
      TabOrder = 3
      Text = '1'
    end
    object Edit8: TEdit
      Left = 8
      Top = 72
      Width = 49
      Height = 21
      TabOrder = 4
      Text = '0500'
    end
    object Button8: TButton
      Left = 152
      Top = 120
      Width = 97
      Height = 25
      Caption = 'ReadRegisters'
      TabOrder = 5
      OnClick = Button8Click
    end
    object Edit5: TEdit
      Left = 80
      Top = 120
      Width = 49
      Height = 21
      TabOrder = 6
      Text = '2'
    end
    object Edit9: TEdit
      Left = 8
      Top = 120
      Width = 49
      Height = 21
      TabOrder = 7
      Text = '0B00'
    end
    object Button10: TButton
      Left = 192
      Top = 192
      Width = 97
      Height = 25
      Caption = 'WriteRegisters'
      TabOrder = 8
      OnClick = Button10Click
    end
    object Edit12: TEdit
      Left = 80
      Top = 168
      Width = 49
      Height = 21
      TabOrder = 9
      Text = '2'
    end
    object Edit13: TEdit
      Left = 8
      Top = 168
      Width = 49
      Height = 21
      TabOrder = 10
      Text = '0A01'
    end
    object Edit14: TEdit
      Left = 8
      Top = 200
      Width = 169
      Height = 21
      TabOrder = 11
      Text = '40133333'
    end
  end
  object Panel2: TPanel
    Left = 368
    Top = 160
    Width = 385
    Height = 257
    Caption = 'Panel2'
    TabOrder = 17
    object Button13: TButton
      Left = 96
      Top = 8
      Width = 73
      Height = 25
      Caption = 'Turn OFF'
      TabOrder = 0
      OnClick = Button13Click
    end
    object Button14: TButton
      Left = 8
      Top = 48
      Width = 73
      Height = 25
      Caption = 'Set CV'
      TabOrder = 1
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 96
      Top = 48
      Width = 73
      Height = 25
      Caption = 'Set CCCV'
      TabOrder = 2
      OnClick = Button15Click
    end
    object GetStatus: TButton
      Left = 248
      Top = 24
      Width = 81
      Height = 25
      Caption = 'GetStatus'
      TabOrder = 3
      OnClick = GetStatusClick
    end
    object GetSTatusExt: TButton
      Left = 248
      Top = 56
      Width = 81
      Height = 25
      Caption = 'GetSTatusExt'
      TabOrder = 4
    end
    object Button12: TButton
      Left = 14
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Turn ON'
      TabOrder = 5
      OnClick = Button12Click
    end
    object CheckBox1: TCheckBox
      Left = 256
      Top = 8
      Width = 97
      Height = 17
      Caption = 'Autorefresh'
      TabOrder = 6
      OnClick = CheckBox1Click
    end
    object Button16: TButton
      Left = 120
      Top = 104
      Width = 57
      Height = 25
      Caption = 'set Ufix'
      TabOrder = 7
      OnClick = Button16Click
    end
    object Edit17: TEdit
      Left = 16
      Top = 104
      Width = 97
      Height = 21
      TabOrder = 8
      Text = 'Edit17'
    end
    object Button17: TButton
      Left = 120
      Top = 136
      Width = 49
      Height = 25
      Caption = 'set Ifix'
      TabOrder = 9
      OnClick = Button17Click
    end
    object Edit18: TEdit
      Left = 16
      Top = 136
      Width = 97
      Height = 21
      TabOrder = 10
      Text = 'Edit17'
    end
    object Button18: TButton
      Left = 120
      Top = 168
      Width = 65
      Height = 25
      Caption = 'set Ucccv'
      TabOrder = 11
      OnClick = Button18Click
    end
    object Edit19: TEdit
      Left = 16
      Top = 168
      Width = 97
      Height = 21
      TabOrder = 12
      Text = 'Edit17'
    end
  end
  object Memo2: TMemo
    Left = 32
    Top = 216
    Width = 249
    Height = 385
    Lines.Strings = (
      'Memo2')
    TabOrder = 18
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 424
    Top = 24
  end
end

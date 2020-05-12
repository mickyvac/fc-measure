object FormModuleBatchRoman: TFormModuleBatchRoman
  Left = 475
  Top = 195
  Caption = 'Linear batch'
  ClientHeight = 772
  ClientWidth = 1135
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 32
    Top = 440
    Width = 105
    Height = 13
    Caption = 'Time delay btwn steps'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label11: TLabel
    Left = 32
    Top = 240
    Width = 47
    Height = 13
    Caption = 'FileName:'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label13: TLabel
    Left = 216
    Top = 240
    Width = 15
    Height = 16
    Caption = '.txt'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label14: TLabel
    Left = 216
    Top = 440
    Width = 13
    Height = 13
    Caption = 'ms'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label17: TLabel
    Left = 32
    Top = 304
    Width = 51
    Height = 13
    Caption = 'Start value'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label18: TLabel
    Left = 32
    Top = 272
    Width = 73
    Height = 13
    Caption = 'Control variable'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label21: TLabel
    Left = 32
    Top = 336
    Width = 113
    Height = 17
    AutoSize = False
    Caption = 'Step'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label41: TLabel
    Left = 32
    Top = 368
    Width = 113
    Height = 17
    AutoSize = False
    Caption = 'End value'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label34: TLabel
    Left = 32
    Top = 504
    Width = 89
    Height = 17
    AutoSize = False
    Caption = 'Current limit low'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label42: TLabel
    Left = 32
    Top = 528
    Width = 89
    Height = 17
    AutoSize = False
    Caption = 'Current limit high'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label43: TLabel
    Left = 32
    Top = 552
    Width = 89
    Height = 17
    AutoSize = False
    Caption = 'Voltage limit low'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label45: TLabel
    Left = 32
    Top = 576
    Width = 89
    Height = 17
    AutoSize = False
    Caption = 'Voltage limit high'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label46: TLabel
    Left = 32
    Top = 184
    Width = 33
    Height = 13
    Caption = 'Preset:'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label58: TLabel
    Left = 208
    Top = 304
    Width = 20
    Height = 16
    Caption = 'mA'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label67: TLabel
    Left = 232
    Top = 504
    Width = 20
    Height = 16
    Caption = 'mA'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label68: TLabel
    Left = 232
    Top = 528
    Width = 20
    Height = 16
    Caption = 'mA'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label69: TLabel
    Left = 232
    Top = 552
    Width = 20
    Height = 16
    Caption = 'mV'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label71: TLabel
    Left = 232
    Top = 576
    Width = 20
    Height = 16
    Caption = 'mV'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label72: TLabel
    Left = 216
    Top = 456
    Width = 20
    Height = 16
    Caption = 'mV'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label75: TLabel
    Left = 208
    Top = 336
    Width = 20
    Height = 16
    Caption = 'mA'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label76: TLabel
    Left = 208
    Top = 368
    Width = 20
    Height = 16
    Caption = 'mA'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label19: TLabel
    Left = 32
    Top = 408
    Width = 85
    Height = 13
    Caption = 'Turn Voltage [mV]'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label20: TLabel
    Left = 224
    Top = 408
    Width = 20
    Height = 16
    Caption = 'mV'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label32: TLabel
    Left = 13
    Top = 151
    Width = 60
    Height = 18
    AutoSize = False
    Caption = 'Status:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object Label73: TLabel
    Left = 16
    Top = 38
    Width = 625
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
    Left = 400
    Top = 176
    Width = 32
    Height = 13
    Caption = 'Osa X:'
  end
  object Label5: TLabel
    Left = 616
    Top = 176
    Width = 32
    Height = 13
    Caption = 'Osa Y:'
  end
  object Label6: TLabel
    Left = 448
    Top = 120
    Width = 46
    Height = 13
    Caption = 'Rozsah X'
  end
  object Label7: TLabel
    Left = 600
    Top = 120
    Width = 46
    Height = 13
    Caption = 'Rozsah Y'
  end
  object Label8: TLabel
    Left = 512
    Top = 120
    Width = 19
    Height = 13
    Caption = 'Unit'
  end
  object Label9: TLabel
    Left = 664
    Top = 120
    Width = 19
    Height = 13
    Caption = 'Unit'
  end
  object Label23: TLabel
    Left = 8
    Top = 8
    Width = 125
    Height = 16
    Caption = 'Project Directory: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 280
    Top = 208
    Width = 833
    Height = 537
    Caption = 'Panel1'
    TabOrder = 0
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 831
      Height = 535
      Align = alClient
    end
  end
  object Button1: TButton
    Left = 16
    Top = 107
    Width = 73
    Height = 25
    Caption = 'Run'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 104
    Top = 107
    Width = 73
    Height = 25
    Caption = 'Stop'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object Edit3: TEdit
    Left = 144
    Top = 432
    Width = 65
    Height = 21
    TabOrder = 3
    Text = '50'
  end
  object Edit6: TEdit
    Left = 96
    Top = 240
    Width = 97
    Height = 21
    TabOrder = 4
    Text = 'VA'
  end
  object Edit10: TEdit
    Left = 192
    Top = 240
    Width = 25
    Height = 21
    TabOrder = 5
    Text = 'Edit10'
  end
  object Edit2: TEdit
    Left = 88
    Top = 304
    Width = 113
    Height = 21
    TabOrder = 6
    Text = 'Edit2'
  end
  object Edit9: TEdit
    Left = 88
    Top = 336
    Width = 113
    Height = 21
    TabOrder = 7
    Text = 'Edit9'
  end
  object Edit14: TEdit
    Left = 88
    Top = 368
    Width = 113
    Height = 21
    TabOrder = 8
    Text = 'Edit14'
  end
  object Edit18: TEdit
    Left = 120
    Top = 504
    Width = 105
    Height = 21
    TabOrder = 9
    Text = 'Edit18'
  end
  object Edit22: TEdit
    Left = 120
    Top = 528
    Width = 105
    Height = 21
    TabOrder = 10
    Text = 'Edit22'
  end
  object Edit23: TEdit
    Left = 120
    Top = 552
    Width = 105
    Height = 21
    TabOrder = 11
    Text = 'Edit23'
  end
  object Edit24: TEdit
    Left = 120
    Top = 576
    Width = 105
    Height = 21
    TabOrder = 12
    Text = 'Edit24'
  end
  object ComboBox6: TComboBox
    Left = 32
    Top = 200
    Width = 153
    Height = 24
    Color = clMoneyGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    Text = 'ComboBox6'
  end
  object CheckBox6: TCheckBox
    Left = 32
    Top = 456
    Width = 113
    Height = 17
    Caption = 'Wait for stability'
    Color = clSkyBlue
    Enabled = False
    ParentColor = False
    TabOrder = 14
  end
  object Edit25: TEdit
    Left = 144
    Top = 456
    Width = 65
    Height = 21
    TabOrder = 15
    Text = '50'
  end
  object ComboBox16: TComboBox
    Left = 112
    Top = 272
    Width = 121
    Height = 21
    Style = csDropDownList
    TabOrder = 16
    OnChange = ComboBox16Change
    Items.Strings = (
      'Current'
      'Voltage')
  end
  object BFileName: TEdit
    Left = 104
    Top = 72
    Width = 769
    Height = 21
    Color = clInactiveBorder
    TabOrder = 17
    OnChange = BFileNameChange
  end
  object BatchOpenButt: TButton
    Left = 264
    Top = 96
    Width = 161
    Height = 21
    Caption = 'Batch Editor'
    TabOrder = 18
    OnClick = BatchOpenButtClick
  end
  object Edit8: TEdit
    Left = 120
    Top = 400
    Width = 97
    Height = 21
    TabOrder = 19
    Text = 'Edit8'
  end
  object PanStatus: TPanel
    Left = 88
    Top = 144
    Width = 281
    Height = 33
    BorderStyle = bsSingle
    Caption = 'Status'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = True
    ParentFont = False
    TabOrder = 20
  end
  object Edit12: TEdit
    Left = 136
    Top = 8
    Width = 617
    Height = 21
    TabOrder = 21
    Text = 'Edit12'
  end
  object ComboBox1: TComboBox
    Left = 440
    Top = 168
    Width = 145
    Height = 21
    TabOrder = 22
    Text = 'ComboBox1'
  end
  object ComboBox2: TComboBox
    Left = 656
    Top = 168
    Width = 145
    Height = 21
    TabOrder = 23
    Text = 'ComboBox1'
  end
  object Edit4: TEdit
    Left = 448
    Top = 136
    Width = 49
    Height = 21
    TabOrder = 24
    Text = '1'
  end
  object Edit5: TEdit
    Left = 600
    Top = 136
    Width = 49
    Height = 21
    TabOrder = 25
    Text = '1'
  end
  object ComboBox3: TComboBox
    Left = 512
    Top = 136
    Width = 57
    Height = 21
    ItemIndex = 3
    TabOrder = 26
    Text = 'A'
    Items.Strings = (
      'kV'
      'V'
      'mV'
      'A'
      'mA')
  end
  object ComboBox4: TComboBox
    Left = 664
    Top = 136
    Width = 57
    Height = 21
    ItemIndex = 1
    TabOrder = 27
    Text = 'V'
    Items.Strings = (
      'kV'
      'V'
      'mV'
      'A'
      'mA')
  end
  object CheckBox2: TCheckBox
    Left = 736
    Top = 136
    Width = 97
    Height = 17
    Caption = 'Graf nemaz'
    TabOrder = 28
  end
  object BuUnlockHW: TButton
    Left = 32
    Top = 704
    Width = 113
    Height = 25
    Caption = 'Manual HW unlock'
    TabOrder = 29
    OnClick = BuUnlockHWClick
  end
  object Memo1: TMemo
    Left = 896
    Top = 40
    Width = 225
    Height = 161
    Lines.Strings = (
      'Memo1')
    TabOrder = 30
  end
  object cbDebug: TCheckBox
    Left = 824
    Top = 40
    Width = 73
    Height = 17
    Caption = 'Debug Log'
    TabOrder = 31
  end
  object BuGenNewDir: TButton
    Left = 760
    Top = 8
    Width = 129
    Height = 25
    Caption = 'Generate New Dir Name'
    TabOrder = 32
    OnClick = BuGenNewDirClick
  end
  object BuOpenBatch: TButton
    Left = 8
    Top = 72
    Width = 89
    Height = 25
    Caption = 'Open File'
    TabOrder = 33
    OnClick = BuOpenBatchClick
  end
  object BuHide: TButton
    Left = 896
    Top = 1
    Width = 225
    Height = 33
    Caption = 'Hide Window'
    TabOrder = 34
    OnClick = BuHideClick
  end
  object Button3: TButton
    Left = 768
    Top = 40
    Width = 41
    Height = 17
    Caption = 'Clear'
    TabOrder = 35
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 832
    Top = 128
    Width = 57
    Height = 17
    Caption = 'list batch'
    TabOrder = 36
    OnClick = Button4Click
  end
  object Edit1: TEdit
    Left = 840
    Top = 104
    Width = 33
    Height = 21
    TabOrder = 37
    Text = 'Edit1'
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 624
    Width = 289
    Height = 17
    Caption = 'Turn PTC off when I_SP=0 for real OCV'
    Color = clFuchsia
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 38
    OnClick = CheckBox1Click
  end
  object CheckBox3: TCheckBox
    Left = 8
    Top = 648
    Width = 289
    Height = 17
    Caption = 'Make Sure Load is Connected during batch'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 39
    OnClick = CheckBox3Click
  end
  object OpenDialogBatch: TOpenDialog
    Filter = 'cmb|*.cmb|text|*.cmb;*.txt|all files|*.*'
    Left = 136
    Top = 64
  end
end

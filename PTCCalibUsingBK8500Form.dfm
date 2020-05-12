object PTCCalibForm: TPTCCalibForm
  Left = 446
  Top = 178
  Caption = 'PTC Calib'
  ClientHeight = 697
  ClientWidth = 1126
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LaBKstatus: TLabel
    Left = 8
    Top = 56
    Width = 161
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'LaBKstatus'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 272
    Width = 61
    Height = 13
    Caption = 'List setpoints'
  end
  object Label2: TLabel
    Left = 8
    Top = 136
    Width = 76
    Height = 13
    Caption = 'Define setpoints'
  end
  object Label3: TLabel
    Left = 488
    Top = 8
    Width = 70
    Height = 13
    Caption = 'Stabil time (ms)'
  end
  object Label4: TLabel
    Left = 656
    Top = 8
    Width = 30
    Height = 13
    Caption = 'Result'
  end
  object LErrors: TLabel
    Left = 272
    Top = 272
    Width = 27
    Height = 13
    Caption = 'Errors'
  end
  object LaBKU: TLabel
    Left = 176
    Top = 24
    Width = 137
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'LaBKstatus'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object LaBKI: TLabel
    Left = 176
    Top = 56
    Width = 137
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'LaBKstatus'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object LaPTCU: TLabel
    Left = 328
    Top = 24
    Width = 137
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'LaBKstatus'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object LaPTCI: TLabel
    Left = 328
    Top = 56
    Width = 137
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'LaBKstatus'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label5: TLabel
    Left = 488
    Top = 32
    Width = 48
    Height = 13
    Caption = 'Averaging'
  end
  object Label6: TLabel
    Left = 376
    Top = 8
    Width = 21
    Height = 13
    Caption = 'PTC'
  end
  object Label7: TLabel
    Left = 216
    Top = 8
    Width = 38
    Height = 13
    Caption = 'BK8500'
  end
  object buBKConfPort: TButton
    Left = 8
    Top = 8
    Width = 161
    Height = 20
    Caption = 'ComPortConf'
    TabOrder = 0
    OnClick = buBKConfPortClick
  end
  object buBKopenPort: TButton
    Left = 8
    Top = 32
    Width = 81
    Height = 20
    Caption = 'Open Port'
    TabOrder = 1
    OnClick = buBKopenPortClick
  end
  object buBKcloseport: TButton
    Left = 88
    Top = 32
    Width = 81
    Height = 20
    Caption = 'ClosePort'
    TabOrder = 2
    OnClick = buBKcloseportClick
  end
  object Memo1: TMemo
    Left = 656
    Top = 32
    Width = 473
    Height = 529
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object Button1: TButton
    Left = 488
    Top = 64
    Width = 153
    Height = 33
    Caption = 'Run Sweep'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Memo2: TMemo
    Left = 8
    Top = 296
    Width = 201
    Height = 361
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object Button2: TButton
    Left = 840
    Top = 576
    Width = 153
    Height = 33
    Caption = 'Copy all to clipboard'
    TabOrder = 6
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 232
    Width = 633
    Height = 21
    TabOrder = 7
    Text = 
      'list(0.001;0.05;0.001),list(0.05;0.2;0.005),list(0.2;0.5;0.02),l' +
      'ist(0.5;2;0.05),list(2;3.1;0.2)'
  end
  object Edit2: TEdit
    Left = 560
    Top = 8
    Width = 81
    Height = 21
    TabOrder = 8
    Text = '1000'
  end
  object Button3: TButton
    Left = 88
    Top = 264
    Width = 57
    Height = 25
    Caption = 'Check'
    TabOrder = 9
    OnClick = Button3Click
  end
  object Memo3: TMemo
    Left = 272
    Top = 296
    Width = 185
    Height = 361
    Lines.Strings = (
      'Memo3')
    ScrollBars = ssBoth
    TabOrder = 10
  end
  object BKO: TCheckBox
    Left = 192
    Top = 88
    Width = 97
    Height = 17
    Caption = 'Output ON'
    TabOrder = 11
  end
  object PTCO: TCheckBox
    Left = 344
    Top = 88
    Width = 97
    Height = 17
    Caption = 'Output ON'
    TabOrder = 12
  end
  object Button4: TButton
    Left = 16
    Top = 88
    Width = 73
    Height = 25
    Caption = 'Connect'
    TabOrder = 13
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 96
    Top = 88
    Width = 73
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 14
    OnClick = Button5Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 120
    Width = 73
    Height = 17
    Caption = 'Lock'
    TabOrder = 15
  end
  object Edit3: TEdit
    Left = 560
    Top = 32
    Width = 81
    Height = 21
    TabOrder = 16
    Text = '3'
  end
  object Edit4: TEdit
    Left = 488
    Top = 104
    Width = 145
    Height = 21
    TabOrder = 17
    Text = 'Edit4'
  end
  object Button6: TButton
    Left = 520
    Top = 304
    Width = 89
    Height = 145
    Caption = 'Cancel'
    TabOrder = 18
    OnClick = Button6Click
  end
  object RadioButton1: TRadioButton
    Left = 176
    Top = 184
    Width = 113
    Height = 17
    Caption = 'At zero voltage'
    Checked = True
    TabOrder = 19
    TabStop = True
  end
  object RadioButton2: TRadioButton
    Left = 176
    Top = 208
    Width = 113
    Height = 17
    Caption = 'At voltage: '
    TabOrder = 20
  end
  object Edit5: TEdit
    Left = 296
    Top = 200
    Width = 81
    Height = 21
    TabOrder = 21
    Text = '1'
  end
  object Button7: TButton
    Left = 632
    Top = 584
    Width = 57
    Height = 17
    Caption = 'Clear'
    TabOrder = 22
    OnClick = Button7Click
  end
  object chkWaitSP: TCheckBox
    Left = 312
    Top = 104
    Width = 153
    Height = 17
    Caption = 'Wait for SP reached (10%)'
    Checked = True
    State = cbChecked
    TabOrder = 23
  end
  object CheckBox2: TCheckBox
    Left = 432
    Top = 184
    Width = 201
    Height = 17
    Caption = 'Negative currents mark'
    TabOrder = 24
  end
  object Button8: TButton
    Left = 176
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Out OFF'
    TabOrder = 25
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 240
    Top = 104
    Width = 49
    Height = 25
    Caption = 'Out ON'
    TabOrder = 26
    OnClick = Button9Click
  end
  object Edit6: TEdit
    Left = 176
    Top = 136
    Width = 49
    Height = 21
    TabOrder = 27
    Text = '30'
  end
  object Edit7: TEdit
    Left = 176
    Top = 160
    Width = 49
    Height = 21
    TabOrder = 28
    Text = '1'
  end
  object Button10: TButton
    Left = 232
    Top = 136
    Width = 57
    Height = 17
    Caption = 'Set CC'
    TabOrder = 29
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 232
    Top = 160
    Width = 57
    Height = 17
    Caption = 'Set CV'
    TabOrder = 30
    OnClick = Button11Click
  end
  object Edit8: TEdit
    Left = 328
    Top = 128
    Width = 49
    Height = 21
    TabOrder = 31
    Text = '3'
  end
  object Button12: TButton
    Left = 384
    Top = 128
    Width = 57
    Height = 17
    Caption = 'Set CC'
    TabOrder = 32
    OnClick = Button12Click
  end
  object Edit9: TEdit
    Left = 328
    Top = 152
    Width = 49
    Height = 21
    TabOrder = 33
    Text = '1'
  end
  object Button13: TButton
    Left = 384
    Top = 152
    Width = 57
    Height = 17
    Caption = 'Set CV'
    TabOrder = 34
    OnClick = Button13Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 712
  end
end

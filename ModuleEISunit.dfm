object FormEIS: TFormEIS
  Left = 401
  Top = 127
  Caption = 'Module EIS'
  ClientHeight = 709
  ClientWidth = 1050
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    1050
    709)
  PixelsPerInch = 96
  TextHeight = 13
  object Label8: TLabel
    Left = 16
    Top = 272
    Width = 74
    Height = 13
    Caption = 'PtcServer CMD'
  end
  object BuRun: TButton
    Left = 16
    Top = 352
    Width = 81
    Height = 33
    Caption = 'Run'
    TabOrder = 0
    OnClick = BuRunClick
  end
  object BuStop: TButton
    Left = 16
    Top = 392
    Width = 81
    Height = 33
    Caption = 'Stop'
    TabOrder = 1
    OnClick = BuStopClick
  end
  object Ecmd: TEdit
    Left = 8
    Top = 328
    Width = 337
    Height = 21
    TabOrder = 2
    Text = 'Ecmd'
  end
  object Memo1: TMemo
    Left = 8
    Top = 464
    Width = 433
    Height = 145
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object BuHide: TButton
    Left = 352
    Top = 8
    Width = 465
    Height = 33
    Caption = 'Hide'
    TabOrder = 4
    OnClick = BuHideClick
  end
  object Button2: TButton
    Left = 40
    Top = 616
    Width = 113
    Height = 25
    Caption = 'tst import'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Panel1: TPanel
    Left = 352
    Top = 48
    Width = 650
    Height = 409
    Anchors = [akLeft, akTop, akRight]
    Caption = 'CHART'
    TabOrder = 6
    OnResize = Panel1Resize
  end
  object Panel2: TPanel
    Left = 8
    Top = 8
    Width = 337
    Height = 105
    Color = clWhite
    TabOrder = 7
    object Label1: TLabel
      Left = 16
      Top = 8
      Width = 78
      Height = 13
      Caption = 'Select feedback'
    end
    object LaStartSP: TLabel
      Left = 16
      Top = 32
      Width = 71
      Height = 13
      Caption = 'DC setpoint (V)'
    end
    object Label10: TLabel
      Left = 16
      Top = 56
      Width = 105
      Height = 13
      Caption = 'Before EIS wait for (s) '
    end
    object CBfbsel: TComboBox
      Left = 128
      Top = 8
      Width = 145
      Height = 21
      TabOrder = 0
      Text = 'Vsense'
      OnChange = CBfbselChange
      Items.Strings = (
        'Vout'
        'Vsense'
        'Vref'
        'I')
    end
    object Esetpoint: TEdit
      Left = 128
      Top = 32
      Width = 113
      Height = 21
      TabOrder = 1
      Text = '0.05'
      OnChange = EsetpointChange
    end
    object Ewait: TEdit
      Left = 128
      Top = 56
      Width = 113
      Height = 21
      TabOrder = 2
      Text = '30'
      OnChange = EwaitChange
    end
    object ChkUSeActSP: TCheckBox
      Left = 16
      Top = 80
      Width = 209
      Height = 17
      Caption = 'Use Actuall Setpoint Instead'
      TabOrder = 3
      OnClick = ChkUSeActSPClick
    end
  end
  object Panel3: TPanel
    Left = 8
    Top = 120
    Width = 337
    Height = 201
    Color = clWhite
    TabOrder = 8
    object Label3: TLabel
      Left = 8
      Top = 16
      Width = 91
      Height = 13
      Caption = 'Scan freq start (Hz)'
    end
    object Label4: TLabel
      Left = 8
      Top = 40
      Width = 89
      Height = 13
      Caption = 'Scan freq end (Hz)'
    end
    object Label5: TLabel
      Left = 8
      Top = 64
      Width = 86
      Height = 13
      Caption = 'Points per decade'
    end
    object Label6: TLabel
      Left = 8
      Top = 88
      Width = 131
      Height = 13
      Caption = 'Sinus Signal Amplitude (mV)'
    end
    object Label7: TLabel
      Left = 8
      Top = 112
      Width = 113
      Height = 13
      Caption = 'EIS Input Voltage range'
    end
    object Label11: TLabel
      Left = 8
      Top = 160
      Width = 136
      Height = 13
      Caption = 'Periods repeat for each point'
    end
    object Label12: TLabel
      Left = 8
      Top = 136
      Width = 111
      Height = 13
      Caption = 'EIS Input Current range'
    end
    object Efstart: TEdit
      Left = 136
      Top = 8
      Width = 113
      Height = 21
      TabOrder = 0
      Text = '2'
      OnChange = EfstartChange
    end
    object Efend: TEdit
      Left = 136
      Top = 32
      Width = 113
      Height = 21
      TabOrder = 1
      Text = '1000000'
      OnChange = EfendChange
    end
    object Epointspd: TEdit
      Left = 160
      Top = 56
      Width = 89
      Height = 21
      TabOrder = 2
      Text = '15'
      OnChange = EpointspdChange
    end
    object Eamplitude: TEdit
      Left = 184
      Top = 80
      Width = 65
      Height = 21
      TabOrder = 3
      Text = '5'
      OnChange = EamplitudeChange
    end
    object EVrange: TEdit
      Left = 160
      Top = 104
      Width = 49
      Height = 21
      TabOrder = 4
      Text = '1'
      OnChange = EVrangeChange
    end
    object EIrange: TEdit
      Left = 160
      Top = 136
      Width = 49
      Height = 21
      TabOrder = 5
      Text = '1'
      OnChange = EIrangeChange
    end
    object Erepeatperiods: TEdit
      Left = 184
      Top = 160
      Width = 65
      Height = 21
      TabOrder = 6
      Text = '2'
      OnChange = ErepeatperiodsChange
    end
  end
  object Panel4: TPanel
    Left = 112
    Top = 352
    Width = 233
    Height = 105
    Color = clWhite
    TabOrder = 9
    object labfname: TLabel
      Left = 6
      Top = 44
      Width = 43
      Height = 13
      Caption = 'labfname'
    end
    object Label9: TLabel
      Left = 8
      Top = 76
      Width = 83
      Height = 13
      Caption = 'Actual frequency '
    end
    object Label2: TLabel
      Left = 14
      Top = 12
      Width = 30
      Height = 13
      Caption = 'Status'
    end
    object Panfname: TPanel
      Left = 104
      Top = 40
      Width = 121
      Height = 25
      Caption = '(Idle)'
      TabOrder = 0
    end
    object PanFreq: TPanel
      Left = 104
      Top = 72
      Width = 121
      Height = 25
      Caption = '(Idle)'
      TabOrder = 1
    end
    object PanStatus: TPanel
      Left = 104
      Top = 8
      Width = 121
      Height = 25
      Caption = '(Idle)'
      TabOrder = 2
    end
  end
  object ComboBox1: TComboBox
    Left = 832
    Top = 16
    Width = 57
    Height = 21
    ItemIndex = 0
    TabOrder = 10
    Text = 'Nyquist'
    OnChange = ComboBox1Change
    Items.Strings = (
      'Nyquist'
      'Bode')
  end
  object CheckBox1: TCheckBox
    Left = 40
    Top = 656
    Width = 81
    Height = 25
    Caption = 'debug'
    TabOrder = 11
  end
  object Memo2: TMemo
    Left = 544
    Top = 480
    Width = 329
    Height = 185
    Lines.Strings = (
      'Memo2')
    TabOrder = 12
  end
  object Button1: TButton
    Left = 176
    Top = 616
    Width = 129
    Height = 25
    Caption = 'Export as MPT'
    TabOrder = 13
    OnClick = Button1Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 50
    OnTimer = Timer1Timer
    Left = 304
    Top = 24
  end
end

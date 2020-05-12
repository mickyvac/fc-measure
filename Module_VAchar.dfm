object FormVAchar: TFormVAchar
  Left = 320
  Top = 18
  Caption = 'VA characteristic module'
  ClientHeight = 955
  ClientWidth = 1220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    1220
    955)
  PixelsPerInch = 96
  TextHeight = 13
  object Label11: TLabel
    Left = 16
    Top = 239
    Width = 76
    Height = 13
    Caption = 'FileName Suffix:'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label46: TLabel
    Left = 88
    Top = 151
    Width = 33
    Height = 13
    Caption = 'Preset:'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label19: TLabel
    Left = 248
    Top = 639
    Width = 85
    Height = 13
    Caption = 'Turn Voltage [mV]'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label20: TLabel
    Left = 440
    Top = 639
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
  object Label6: TLabel
    Left = 48
    Top = 63
    Width = 676
    Height = 13
    Caption = 
      'Postup v jednom kroku: Ceka se stabilisation time, pak se zmeri ' +
      'HFR, pak se meri a ceka po averaging time (ulozi se prumer za ce' +
      'lou tuto dobu)'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label9: TLabel
    Left = 256
    Top = 767
    Width = 75
    Height = 13
    Caption = 'HFR frequency '
    Color = clSkyBlue
    ParentColor = False
  end
  object Label16: TLabel
    Left = 680
    Top = 15
    Width = 116
    Height = 13
    Caption = 'Estimated remaining time'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label22: TLabel
    Left = 912
    Top = 15
    Width = 13
    Height = 13
    Caption = 'ms'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label23: TLabel
    Left = 40
    Top = 727
    Width = 92
    Height = 13
    Caption = 'Aquire Refresh time'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label24: TLabel
    Left = 232
    Top = 727
    Width = 13
    Height = 13
    Caption = 'ms'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label27: TLabel
    Left = 80
    Top = 48
    Width = 160
    Height = 13
    Caption = 'TODO: VA CHAR preset manager'
  end
  object Label3: TLabel
    Left = 48
    Top = 103
    Width = 457
    Height = 13
    Caption = 
      'Two way: kdyz klesna napeti pod hranici, nastavi se priznak - al' +
      'e dokonci se jeste soucasny step'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label14: TLabel
    Left = 48
    Top = 87
    Width = 618
    Height = 13
    Caption = 
      'Two way turn condition: nastavi se take kdyz je aktivovano SW un' +
      'dervoltage protection, nebo kdyz je dosazen nejaky globalni limi' +
      't'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label13: TLabel
    Left = 16
    Top = 263
    Width = 86
    Height = 13
    Caption = 'Next file full name:'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label28: TLabel
    Left = 48
    Top = 119
    Width = 492
    Height = 13
    Caption = 
      'Aquire refresh time: aquire interval - have affect on the SW und' +
      'ervoltage protection - how fast is updated'
    Color = clSkyBlue
    ParentColor = False
  end
  object Label29: TLabel
    Left = 240
    Top = 239
    Width = 122
    Height = 13
    Caption = 'Current values in mA/cm2'
    Color = clSkyBlue
    ParentColor = False
  end
  object Button1: TButton
    Left = 7
    Top = 7
    Width = 176
    Height = 26
    Caption = 'Hide'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 80
    Top = 186
    Width = 249
    Height = 25
    Caption = 'Run'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 344
    Top = 186
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
  end
  object Edit6: TEdit
    Left = 112
    Top = 231
    Width = 97
    Height = 21
    TabOrder = 3
    Text = 'VA'
  end
  object CheckBox5: TCheckBox
    Left = 32
    Top = 623
    Width = 201
    Height = 34
    Caption = 'Two way IV char'
    Color = clSkyBlue
    ParentColor = False
    TabOrder = 4
  end
  object ComboBox6: TComboBox
    Left = 160
    Top = 143
    Width = 153
    Height = 24
    Color = clMoneyGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    Text = 'ComboBox6'
  end
  object Button12: TButton
    Left = 344
    Top = 143
    Width = 49
    Height = 25
    Caption = 'Save'
    TabOrder = 6
  end
  object Button19: TButton
    Left = 424
    Top = 143
    Width = 49
    Height = 25
    Caption = 'Delete'
    TabOrder = 7
  end
  object Edit8: TEdit
    Left = 336
    Top = 631
    Width = 97
    Height = 21
    TabOrder = 8
    Text = 'Edit8'
  end
  object CheckBox1: TCheckBox
    Left = 32
    Top = 663
    Width = 201
    Height = 50
    Caption = 'SW UnderVoltage PROTECTION'
    Color = clSkyBlue
    ParentColor = False
    TabOrder = 9
  end
  object CheckBox2: TCheckBox
    Left = 32
    Top = 751
    Width = 201
    Height = 42
    Caption = 'Measure HFR during current steps'
    Color = clSkyBlue
    ParentColor = False
    TabOrder = 10
  end
  object Edit7: TEdit
    Left = 344
    Top = 759
    Width = 65
    Height = 21
    TabOrder = 11
    Text = '50'
  end
  object Button4: TButton
    Left = 192
    Top = 8
    Width = 225
    Height = 25
    Caption = 'Stop'
    TabOrder = 12
  end
  object PanFlowStatus: TPanel
    Left = 430
    Top = 8
    Width = 243
    Height = 25
    Color = clGreen
    TabOrder = 13
    object LaFlowStatus: TLabel
      Left = 8
      Top = 8
      Width = 30
      Height = 13
      Caption = 'Status'
    end
  end
  object Edit13: TEdit
    Left = 808
    Top = 15
    Width = 65
    Height = 21
    TabOrder = 14
    Text = '50'
  end
  object Edit15: TEdit
    Left = 160
    Top = 719
    Width = 65
    Height = 21
    TabOrder = 15
    Text = '50'
  end
  object PanPlot: TPanel
    Left = 616
    Top = 416
    Width = 535
    Height = 465
    Anchors = [akLeft, akTop, akRight]
    Caption = 'PanPlot'
    TabOrder = 16
    object Label33: TLabel
      Left = 17
      Top = 8
      Width = 54
      Height = 13
      Caption = 'Plot Control'
    end
    object Chart1: TChart
      Left = 1
      Top = 75
      Width = 533
      Height = 389
      BackWall.Brush.Color = clWhite
      BackWall.Brush.Style = bsClear
      Legend.Visible = False
      Title.AdjustFrame = False
      Title.Text.Strings = (
        'TChart')
      Title.Visible = False
      View3D = False
      View3DWalls = False
      Align = alBottom
      TabOrder = 0
      object Series1: TFastLineSeries
        Marks.Arrow.Visible = True
        Marks.Callout.Brush.Color = clBlack
        Marks.Callout.Arrow.Visible = True
        Marks.Visible = False
        LinePen.Color = clRed
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
    object ComboBox18: TComboBox
      Left = 76
      Top = 4
      Width = 365
      Height = 21
      ItemIndex = 0
      TabOrder = 1
      Text = 'Monitor U, I: last 10min'
      Items.Strings = (
        'Monitor U, I: last 10min'
        'Monitor U, I: last 1h'
        'Monitor U, I: last 24h'
        'Monitor U, I: all'
        '----files----'
        '')
    end
    object Button15: TButton
      Left = 616
      Top = 8
      Width = 153
      Height = 25
      Caption = 'Plot Multiview'
      TabOrder = 2
    end
  end
  object Panel1: TPanel
    Left = 600
    Top = 168
    Width = 713
    Height = 220
    Caption = 'Panel1'
    TabOrder = 17
    DesignSize = (
      713
      220)
    object LaMonPow: TLabel
      Left = 21
      Top = 80
      Width = 297
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Caption = 'LaMonPow'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clFuchsia
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LaMonVref: TLabel
      Left = 360
      Top = 80
      Width = 280
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Caption = 'LaMonVref'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -21
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LaMonVolt: TLabel
      Left = 5
      Top = 45
      Width = 382
      Height = 35
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LaMonVolt'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LaMonCurr: TLabel
      Left = 21
      Top = 6
      Width = 382
      Height = 35
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LaMonCurr'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label25: TLabel
      Left = 16
      Top = 110
      Width = 425
      Height = 37
      Alignment = taCenter
      AutoSize = False
      Caption = 'Label25 FLOW'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object CheckBox3: TCheckBox
      Left = 48
      Top = 162
      Width = 201
      Height = 34
      Caption = 'Turn condition detected'
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 16
    Top = 296
    Width = 545
    Height = 164
    Caption = 'Panel2'
    TabOrder = 18
    object Label17: TLabel
      Left = 288
      Top = 7
      Width = 51
      Height = 13
      Caption = 'Start value'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label58: TLabel
      Left = 464
      Top = 7
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
    object Label75: TLabel
      Left = 464
      Top = 31
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
    object Label21: TLabel
      Left = 288
      Top = 23
      Width = 113
      Height = 17
      AutoSize = False
      Caption = 'Step'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label41: TLabel
      Left = 288
      Top = 47
      Width = 113
      Height = 17
      AutoSize = False
      Caption = 'End value'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label76: TLabel
      Left = 464
      Top = 55
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
    object Label26: TLabel
      Left = 472
      Top = 87
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
    object Label18: TLabel
      Left = 0
      Top = 15
      Width = 73
      Height = 13
      Caption = 'Control variable'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label15: TLabel
      Left = 24
      Top = -1
      Width = 187
      Height = 13
      Caption = 'Sequence control - step setpoint values'
    end
    object RBSeqIteration: TRadioButton
      Left = 8
      Top = 48
      Width = 257
      Height = 25
      Caption = 'Iteration'
      TabOrder = 0
    end
    object RBSeqUser: TRadioButton
      Left = 8
      Top = 112
      Width = 257
      Height = 25
      Caption = 'User sequence'
      TabOrder = 1
    end
    object ESeqUser: TEdit
      Left = 112
      Top = 120
      Width = 353
      Height = 21
      TabOrder = 2
      Text = 'User sequence of steps'
    end
    object EValStart: TEdit
      Left = 344
      Top = 7
      Width = 113
      Height = 21
      TabOrder = 3
      Text = 'EValStart'
      OnChange = EValStartChange
    end
    object EStep: TEdit
      Left = 344
      Top = 31
      Width = 113
      Height = 21
      TabOrder = 4
      Text = 'EStep'
      OnChange = EStepChange
    end
    object EValEnd: TEdit
      Left = 344
      Top = 55
      Width = 113
      Height = 21
      TabOrder = 5
      Text = 'EValEnd'
      OnChange = EValEndChange
    end
    object CBControlVar: TComboBox
      Left = 88
      Top = 15
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 6
      Text = 'Current'
      Items.Strings = (
        'Current'
        'Voltage')
    end
  end
  object Panel3: TPanel
    Left = 16
    Top = 800
    Width = 457
    Height = 140
    Caption = 'Panel3'
    TabOrder = 19
    object Label34: TLabel
      Left = 40
      Top = 80
      Width = 89
      Height = 17
      AutoSize = False
      Caption = 'Current limit low'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label67: TLabel
      Left = 248
      Top = 33
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
      Left = 248
      Top = 57
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
      Left = 248
      Top = 81
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
      Left = 256
      Top = 105
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
    object Label43: TLabel
      Left = 40
      Top = 56
      Width = 89
      Height = 17
      AutoSize = False
      Caption = 'Voltage limit low'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label45: TLabel
      Left = 40
      Top = 32
      Width = 89
      Height = 17
      AutoSize = False
      Caption = 'Voltage limit high'
      Color = clSkyBlue
      ParentColor = False
    end
    object RadioButton3: TRadioButton
      Left = 8
      Top = 8
      Width = 257
      Height = 25
      Caption = 'Use global limits'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object Edit18: TEdit
      Left = 136
      Top = 28
      Width = 105
      Height = 21
      TabOrder = 1
      Text = 'Edit18'
    end
    object Edit24: TEdit
      Left = 136
      Top = 76
      Width = 105
      Height = 21
      TabOrder = 2
      Text = 'Edit24'
    end
    object Edit23: TEdit
      Left = 136
      Top = 52
      Width = 105
      Height = 21
      TabOrder = 3
      Text = 'Edit23'
    end
    object Edit22: TEdit
      Left = 136
      Top = 100
      Width = 105
      Height = 21
      TabOrder = 4
      Text = 'Edit22'
    end
  end
  object PanFullPath: TPanel
    Left = 109
    Top = 264
    Width = 388
    Height = 22
    BorderStyle = bsSingle
    Caption = 'Pan'
    Color = clWhite
    TabOrder = 20
  end
  object Panel4: TPanel
    Left = 16
    Top = 475
    Width = 417
    Height = 137
    Caption = 'Panel4'
    TabOrder = 21
    object Label1: TLabel
      Left = 24
      Top = 20
      Width = 78
      Height = 13
      Caption = 'Stabilization time'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label2: TLabel
      Left = 184
      Top = 20
      Width = 13
      Height = 13
      Caption = 'ms'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label4: TLabel
      Left = 24
      Top = 68
      Width = 70
      Height = 13
      Caption = 'Averaging time'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label5: TLabel
      Left = 184
      Top = 76
      Width = 13
      Height = 13
      Caption = 'ms'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label7: TLabel
      Left = 24
      Top = 44
      Width = 44
      Height = 13
      Caption = 'HFR time'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label8: TLabel
      Left = 184
      Top = 44
      Width = 13
      Height = 13
      Caption = 'ms'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label10: TLabel
      Left = 16
      Top = 100
      Width = 87
      Height = 13
      Caption = 'Total time per step'
      Color = clSkyBlue
      ParentColor = False
    end
    object Label12: TLabel
      Left = 200
      Top = 100
      Width = 13
      Height = 13
      Caption = 'ms'
      Color = clSkyBlue
      ParentColor = False
    end
    object Edit1: TEdit
      Left = 112
      Top = 20
      Width = 65
      Height = 21
      TabOrder = 0
      Text = '50'
    end
    object Edit4: TEdit
      Left = 112
      Top = 68
      Width = 65
      Height = 21
      TabOrder = 1
      Text = '50'
    end
    object Edit5: TEdit
      Left = 112
      Top = 44
      Width = 65
      Height = 21
      TabOrder = 2
      Text = '50'
    end
    object Edit11: TEdit
      Left = 128
      Top = 100
      Width = 65
      Height = 21
      TabOrder = 3
      Text = '50'
    end
  end
  object FormRefreshTimer: TTimer
    Left = 1104
    Top = 8
  end
end

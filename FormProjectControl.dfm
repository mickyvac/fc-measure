object ProjectControl: TProjectControl
  Left = 525
  Top = 143
  Caption = 'Project Edit Form'
  ClientHeight = 782
  ClientWidth = 780
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label23: TLabel
    Left = 8
    Top = 38
    Width = 170
    Height = 16
    Caption = 'Project Home Directory: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 6
    Width = 99
    Height = 16
    Caption = 'Project Name:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 70
    Width = 141
    Height = 16
    Caption = 'Project Description: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label13: TLabel
    Left = 8
    Top = 102
    Width = 162
    Height = 16
    Caption = 'Full path to project file: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LaProjPath: TLabel
    Left = 176
    Top = 102
    Width = 134
    Height = 16
    Caption = 'Full path to project file: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label14: TLabel
    Left = 8
    Top = 126
    Width = 141
    Height = 16
    Caption = 'Project create date: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LaProjDate: TLabel
    Left = 176
    Top = 126
    Width = 34
    Height = 16
    Caption = 'Date'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label15: TLabel
    Left = 512
    Top = 16
    Width = 172
    Height = 13
    Caption = 'To change dir rename it  and reopen'
  end
  object EProjName: TEdit
    Left = 120
    Top = 6
    Width = 393
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    Text = 'EProjName'
    OnChange = EProjNameChange
  end
  object BuSave: TButton
    Left = 400
    Top = 672
    Width = 209
    Height = 41
    Caption = 'Save and Hide'
    TabOrder = 1
    OnClick = BuSaveClick
  end
  object BuCancel: TButton
    Left = 80
    Top = 672
    Width = 161
    Height = 41
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = BuCancelClick
  end
  object EProjDir: TEdit
    Left = 184
    Top = 40
    Width = 489
    Height = 21
    Enabled = False
    TabOrder = 3
    Text = 'EProjDir'
  end
  object EProjDesc: TEdit
    Left = 152
    Top = 70
    Width = 521
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    Text = 'Edit12'
    OnChange = EProjDescChange
  end
  object Panel2: TPanel
    Left = 10
    Top = 152
    Width = 700
    Height = 41
    Color = clCream
    TabOrder = 5
    object Label32: TLabel
      Left = 7
      Top = 5
      Width = 74
      Height = 13
      Caption = 'Cell Area (cm-2)'
    end
    object Label2: TLabel
      Left = 503
      Top = 5
      Width = 44
      Height = 13
      Caption = 'Cell Type'
    end
    object Label5: TLabel
      Left = 207
      Top = 5
      Width = 113
      Height = 13
      Caption = 'Number of cells in stack'
    end
    object CBCellType: TComboBox
      Left = 552
      Top = 5
      Width = 145
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Text = 'Greenlight graphite electrodes'
      OnChange = CBCellTypeChange
      Items.Strings = (
        'Greenlight graphite electrodes')
    end
    object CBCellArea: TComboBox
      Left = 96
      Top = 5
      Width = 105
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Text = '4,62'
      OnChange = CBCellAreaChange
      Items.Strings = (
        '1'
        '4'
        '4,62'
        '4,84'
        '5'
        '49'
        '50')
    end
    object cBNumberOfCellsStack: TComboBox
      Left = 328
      Top = 5
      Width = 105
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 2
      Text = '1'
      OnChange = cBNumberOfCellsStackChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '10'
        '20'
        '24'
        '48')
    end
  end
  object Panel3: TPanel
    Left = 10
    Top = 248
    Width = 700
    Height = 81
    Color = clFuchsia
    TabOrder = 6
    object Label51: TLabel
      Left = 8
      Top = 4
      Width = 73
      Height = 13
      Caption = 'Anode material:'
    end
    object Label6: TLabel
      Left = 448
      Top = 20
      Width = 98
      Height = 13
      Caption = 'Anode stoichiometry:'
    end
    object Label7: TLabel
      Left = 440
      Top = 52
      Width = 133
      Height = 13
      Caption = 'Anode minimum flow: (sccm)'
    end
    object Label56: TLabel
      Left = 8
      Top = 28
      Width = 56
      Height = 13
      Caption = 'Anode GDL'
    end
    object Label11: TLabel
      Left = 8
      Top = 52
      Width = 130
      Height = 13
      Caption = 'Anode loading (mgPt.cm-2):'
    end
    object CBAnodeMat: TComboBox
      Left = 152
      Top = 4
      Width = 241
      Height = 21
      TabOrder = 0
      Text = 'Select snode material'
      OnChange = CBAnodeMatChange
      Items.Strings = (
        'reference'
        'CeO2 Pt Low'
        'CeO2 Pt High'
        'D-CNT + CeO2 Pt Low'
        'D-CNT + CeO2 Pt High'
        'M-CNT + CeO2 Pt Low'
        'M-CNT + CeO2 Pt High'
        'H-CNT + CeO2 Pt Low'
        'H-CNT + CeO2 Pt High')
    end
    object CBAnodeGDL: TComboBox
      Left = 152
      Top = 28
      Width = 241
      Height = 21
      TabOrder = 1
      Text = 'Select GDL material'
      OnChange = CBAnodeGDLChange
      Items.Strings = (
        'Toray Carbon Paper, TGP-H-60'
        'Toray Carbon Paper, Tefloned, TGP-60')
    end
    object CBAnodeLoading: TComboBox
      Left = 152
      Top = 52
      Width = 129
      Height = 21
      Enabled = False
      TabOrder = 2
      Text = 'CBCellType'
      OnChange = CBAnodeLoadingChange
    end
    object CBAnodeStoich: TComboBox
      Left = 584
      Top = 12
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      Text = '1.2'
      OnChange = CBAnodeStoichChange
      Items.Strings = (
        '1.2'
        '2'
        '9')
    end
    object CBAnodeFlowMin: TComboBox
      Left = 584
      Top = 44
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 2
      ParentFont = False
      TabOrder = 4
      Text = '30'
      OnChange = CBAnodeFlowMinChange
      Items.Strings = (
        '5'
        '10'
        '30'
        '40')
    end
  end
  object Panel4: TPanel
    Left = 10
    Top = 432
    Width = 700
    Height = 65
    Color = clSilver
    TabOrder = 7
    object Label53: TLabel
      Left = 8
      Top = 4
      Width = 53
      Height = 13
      Caption = 'Membrane:'
      Color = clSilver
      ParentColor = False
    end
    object Label54: TLabel
      Left = 8
      Top = 28
      Width = 79
      Height = 13
      Caption = 'MEA preparation'
      Color = clSilver
      ParentColor = False
    end
    object CBMembrane: TComboBox
      Left = 125
      Top = 4
      Width = 140
      Height = 21
      TabOrder = 0
      Text = 'Select membrane'
      OnChange = CBMembraneChange
      Items.Strings = (
        'NAFION 0.05'
        'NAFION 0.09'
        'NAFION 0.125'
        'NAFION 0.18')
    end
    object CBMea: TComboBox
      Left = 125
      Top = 28
      Width = 140
      Height = 21
      TabOrder = 1
      Text = 'Select MEA preparation'
      OnChange = CBMeaChange
      Items.Strings = (
        'NOT Hot-press'
        'Hot-press'
        'Hot-press & NAFION')
    end
  end
  object Panel5: TPanel
    Left = 10
    Top = 336
    Width = 700
    Height = 89
    Color = clAqua
    TabOrder = 8
    object Label9: TLabel
      Left = 432
      Top = 20
      Width = 107
      Height = 13
      Caption = 'Cathode stoichiometry:'
    end
    object Label10: TLabel
      Left = 432
      Top = 52
      Width = 142
      Height = 13
      Caption = 'Cathode minimum flow: (sccm)'
    end
    object Label52: TLabel
      Left = 8
      Top = 4
      Width = 79
      Height = 13
      Caption = 'Cathode material'
    end
    object Label8: TLabel
      Left = 8
      Top = 28
      Width = 65
      Height = 13
      Caption = 'Cathode GDL'
    end
    object Label12: TLabel
      Left = 8
      Top = 52
      Width = 139
      Height = 13
      Caption = 'Cathode loading (mgPt.cm-2):'
    end
    object CBCathodeMat: TComboBox
      Left = 152
      Top = 4
      Width = 249
      Height = 21
      TabOrder = 0
      Text = 'Select cathode material'
      OnChange = CBCathodeMatChange
      Items.Strings = (
        'reference')
    end
    object CBCathodeGDL: TComboBox
      Left = 152
      Top = 28
      Width = 249
      Height = 21
      TabOrder = 1
      Text = 'Select GDL material'
      OnChange = CBCathodeGDLChange
      Items.Strings = (
        'Toray Carbon Paper, TGP-H-60'
        'Toray Carbon Paper, Tefloned, TGP-60')
    end
    object CBCathodeLoading: TComboBox
      Left = 152
      Top = 52
      Width = 121
      Height = 21
      Enabled = False
      TabOrder = 2
      Text = 'CBCellType'
      OnChange = CBCathodeLoadingChange
    end
    object CBCathodeStoich: TComboBox
      Left = 584
      Top = 12
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      Text = '2'
      OnChange = CBCathodeStochChange
      Items.Strings = (
        '1.5'
        '2'
        '9')
    end
    object CBCathodeFlowMin: TComboBox
      Left = 584
      Top = 44
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 2
      ParentFont = False
      TabOrder = 4
      Text = '40'
      OnChange = CBCathodeFlowMinChange
      Items.Strings = (
        '5'
        '10'
        '40'
        '50'
        '100'
        '500')
    end
  end
  object Button1: TButton
    Left = 280
    Top = 672
    Width = 81
    Height = 41
    Caption = 'Make default'
    TabOrder = 9
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 10
    Top = 200
    Width = 700
    Height = 41
    Color = clMoneyGreen
    TabOrder = 10
    object CBFlowTracking: TCheckBox
      Left = 472
      Top = 8
      Width = 201
      Height = 25
      Caption = 'FlowTracking'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = CBFlowTrackingClick
    end
    object chkNormLotageByNoOfCells: TCheckBox
      Left = 15
      Top = 8
      Width = 321
      Height = 15
      Caption = 'Normalize Voltage by number of cells'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
    end
  end
  object Panel6: TPanel
    Left = 10
    Top = 504
    Width = 700
    Height = 161
    TabOrder = 11
    object Label16: TLabel
      Left = 15
      Top = 78
      Width = 162
      Height = 25
      AutoSize = False
      Caption = 'Current limit low (A)'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label17: TLabel
      Left = 15
      Top = 110
      Width = 162
      Height = 25
      AutoSize = False
      Caption = 'Current limit high (A)'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label18: TLabel
      Left = 375
      Top = 78
      Width = 162
      Height = 25
      AutoSize = False
      Caption = 'Voltage limit low (V)'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label19: TLabel
      Left = 375
      Top = 110
      Width = 162
      Height = 25
      AutoSize = False
      Caption = 'Voltage limit high (V)'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label1: TLabel
      Left = 152
      Top = 1
      Width = 246
      Height = 16
      Caption = 'Potenciostat specific configuration: '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label30: TLabel
      Left = 184
      Top = 49
      Width = 235
      Height = 24
      Caption = 'SW Undervoltage protection'
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object CBInvertCurrent: TCheckBox
      Left = 64
      Top = 16
      Width = 150
      Height = 25
      Caption = 'InvertCurrent'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = CBInvertCurrentClick
    end
    object CBInvertVoltage: TCheckBox
      Left = 392
      Top = 16
      Width = 150
      Height = 25
      Caption = 'InvertVoltage'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = CBInvertVoltageClick
    end
    object CBCurrLimLow: TComboBox
      Left = 192
      Top = 78
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 2
      Text = '-15'
      OnChange = CBCurrLimLowChange
      Items.Strings = (
        '-15'
        '-10'
        '-1'
        '0')
    end
    object CBCurrLimHigh: TComboBox
      Left = 192
      Top = 110
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 3
      ParentFont = False
      TabOrder = 3
      Text = '15'
      OnChange = CBCurrLimHighChange
      Items.Strings = (
        '0'
        '1'
        '10'
        '15')
    end
    object CBVoltLimLow: TComboBox
      Left = 544
      Top = 78
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = '0.35'
      OnChange = CBVoltLimLowChange
      Items.Strings = (
        '-0.3'
        '0'
        '0.2'
        '0.3'
        '0.35'
        '0.4'
        '0.5')
    end
    object CBVoltLimHigh: TComboBox
      Left = 544
      Top = 110
      Width = 97
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      Text = '1.5'
      OnChange = CBVoltLimHighChange
      Items.Strings = (
        '1.1'
        '1.2'
        '1.3'
        '1.5'
        '0.3')
    end
  end
  object CHKEditDisabled: TCheckBox
    Left = 576
    Top = 0
    Width = 121
    Height = 17
    Caption = 'Editing is Disabled'
    Enabled = False
    TabOrder = 12
  end
end

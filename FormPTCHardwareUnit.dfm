object FormPTCHardware: TFormPTCHardware
  Left = 488
  Top = 134
  Caption = 'Hardware PTC Form'
  ClientHeight = 778
  ClientWidth = 940
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
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 136
    Top = 8
    Width = 118
    Height = 20
    Caption = 'PTC selection'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 568
    Top = 8
    Width = 13
    Height = 13
    Caption = 'ms'
  end
  object CBSelectPTC: TComboBox
    Left = 264
    Top = 5
    Width = 241
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    Text = 'Kol PTC'
    OnChange = CBSelectPTCChange
    Items.Strings = (
      'Kol PTC'
      'Dummy PTC'
      'BK8500 Load'
      'M97XX Load'
      'ZS1806 Load'
      'PLI series Load')
  end
  object ButtonHide: TButton
    Left = 752
    Top = 5
    Width = 120
    Height = 25
    Caption = 'Hide'
    TabOrder = 1
    OnClick = ButtonHideClick
  end
  object ChkAutoRefresh: TCheckBox
    Left = 528
    Top = 8
    Width = 97
    Height = 17
    Caption = 'AutoRefresh'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = ChkAutoRefreshClick
  end
  object HWFormRefreshIntv: TEdit
    Left = 632
    Top = 8
    Width = 57
    Height = 21
    TabOrder = 3
    Text = '1000'
    OnChange = HWFormRefreshIntvChange
  end
  object BuHWCalib: TButton
    Left = 8
    Top = 670
    Width = 89
    Height = 25
    Caption = 'Calibration'
    TabOrder = 4
  end
  object PageControlPTC: TPageControl
    Left = 8
    Top = 40
    Width = 865
    Height = 705
    ActivePage = TabSheet1
    TabOrder = 5
    object TabSheet1: TTabSheet
      Caption = 'KolPTC'
      object GroupBox2: TGroupBox
        Left = 528
        Top = 200
        Width = 313
        Height = 281
        Caption = 'Register config'
        TabOrder = 0
        object Label33: TLabel
          Left = 8
          Top = 60
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'V4Range'
          Layout = tlCenter
        end
        object Label34: TLabel
          Left = 104
          Top = 36
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Value in use'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
        object Label35: TLabel
          Left = 184
          Top = 36
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'New value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
        object Label36: TLabel
          Left = 8
          Top = 84
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'RelayON '
          Layout = tlCenter
        end
        object Label38: TLabel
          Left = 8
          Top = 108
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Setpoint'
          Layout = tlCenter
        end
        object Label39: TLabel
          Left = 8
          Top = 156
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'ProtectStatus'
          Layout = tlCenter
        end
        object Label40: TLabel
          Left = 8
          Top = 36
          Width = 89
          Height = 21
          AutoSize = False
          Caption = 'Register'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
        end
        object Label41: TLabel
          Left = 8
          Top = 180
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Protect CMD'
          Layout = tlCenter
        end
        object Label62: TLabel
          Left = 8
          Top = 204
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Fw_fuse_Soft'
          Layout = tlCenter
        end
        object Label63: TLabel
          Left = 8
          Top = 228
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Fw_fuse_Hard'
          Layout = tlCenter
        end
        object Label64: TLabel
          Left = 8
          Top = 252
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'ADC value'
          Layout = tlCenter
        end
        object Label65: TLabel
          Left = 8
          Top = 15
          Width = 42
          Height = 13
          Caption = 'FW CRC'
        end
        object Label66: TLabel
          Left = 144
          Top = 15
          Width = 55
          Height = 13
          Caption = 'Config CRC'
        end
        object Label67: TLabel
          Left = 8
          Top = 132
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'SW_feedback'
          Layout = tlCenter
        end
        object PanKolV4R: TPanel
          Left = 108
          Top = 61
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 0
        end
        object BuKolV4R: TButton
          Left = 264
          Top = 61
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 1
          OnClick = BuKolV4RClick
        end
        object EKolV4R: TEdit
          Left = 184
          Top = 60
          Width = 65
          Height = 21
          TabOrder = 2
          Text = 'Edit1'
        end
        object PanKolRelOn: TPanel
          Left = 108
          Top = 85
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 3
        end
        object EKolRelOn: TEdit
          Left = 184
          Top = 84
          Width = 65
          Height = 21
          TabOrder = 4
          Text = 'Edit1'
        end
        object BuKolRelOn: TButton
          Left = 264
          Top = 85
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 5
          OnClick = BuKolRelOnClick
        end
        object PanKolSetp: TPanel
          Left = 108
          Top = 109
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 6
        end
        object EKolSetp: TEdit
          Left = 184
          Top = 108
          Width = 65
          Height = 21
          TabOrder = 7
          Text = 'Edit1'
        end
        object BuKolSetp: TButton
          Left = 264
          Top = 109
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 8
          OnClick = BuKolSetpClick
        end
        object PanKolProtect: TPanel
          Left = 108
          Top = 157
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 9
        end
        object EKolProtect: TEdit
          Left = 184
          Top = 156
          Width = 65
          Height = 21
          TabOrder = 10
          Text = 'Edit1'
        end
        object BuKolProtect: TButton
          Left = 264
          Top = 157
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 11
          OnClick = BuKolProtectClick
        end
        object PanKolPROTcmd: TPanel
          Left = 108
          Top = 181
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 12
        end
        object EKolProtCMD: TEdit
          Left = 184
          Top = 180
          Width = 65
          Height = 21
          TabOrder = 13
          Text = 'Edit1'
        end
        object BuKolProtCMD: TButton
          Left = 264
          Top = 181
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 14
          OnClick = BuKolProtCMDClick
        end
        object PanKolFuseSafe: TPanel
          Left = 108
          Top = 205
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 15
        end
        object EKolFuseSoft: TEdit
          Left = 184
          Top = 204
          Width = 65
          Height = 21
          TabOrder = 16
          Text = 'Edit1'
        end
        object BuKolFuseSoft: TButton
          Left = 264
          Top = 205
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 17
          OnClick = BuKolFuseSoftClick
        end
        object PanKolFuseHard: TPanel
          Left = 108
          Top = 229
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 18
        end
        object EKolFuseHard: TEdit
          Left = 184
          Top = 228
          Width = 65
          Height = 21
          TabOrder = 19
          Text = 'Edit1'
        end
        object BuKolFuseHard: TButton
          Left = 264
          Top = 229
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 20
          OnClick = BuKolFuseHardClick
        end
        object PanKolRegADC: TPanel
          Left = 108
          Top = 253
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 21
        end
        object EKolRegADC: TEdit
          Left = 184
          Top = 252
          Width = 65
          Height = 21
          TabOrder = 22
          Text = 'EKolRegADC'
        end
        object BuKolRegADC: TButton
          Left = 264
          Top = 253
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 23
          OnClick = BuKolRegADCClick
        end
        object PanKolFwId: TPanel
          Left = 56
          Top = 15
          Width = 81
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 24
        end
        object EKolFWVer: TEdit
          Left = 200
          Top = 15
          Width = 57
          Height = 21
          TabOrder = 25
          Text = 'Edit1'
        end
        object Button5: TButton
          Left = 264
          Top = 15
          Width = 41
          Height = 20
          Caption = 'Match'
          TabOrder = 26
          OnClick = Button5Click
        end
        object PanKolRegSWFB: TPanel
          Left = 108
          Top = 133
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 27
        end
        object EKolRegSWFB: TEdit
          Left = 184
          Top = 132
          Width = 65
          Height = 21
          TabOrder = 28
          Text = 'Edit1'
        end
        object BuKolRegSWFB: TButton
          Left = 264
          Top = 133
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 29
          OnClick = BuKolRegSWFBClick
        end
      end
      object GroupBox3: TGroupBox
        Left = 528
        Top = 480
        Width = 313
        Height = 193
        Caption = 'Channel config'
        TabOrder = 1
        object Label8: TLabel
          Left = 8
          Top = 20
          Width = 89
          Height = 21
          AutoSize = False
          Caption = 'Channel'
          Layout = tlCenter
        end
        object Label9: TLabel
          Left = 8
          Top = 44
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'V4'
          Layout = tlCenter
        end
        object Label10: TLabel
          Left = 104
          Top = 20
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Value in use'
          Layout = tlCenter
        end
        object Label13: TLabel
          Left = 184
          Top = 20
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'New value'
          Layout = tlCenter
        end
        object Label14: TLabel
          Left = 8
          Top = 68
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Vref'
          Layout = tlCenter
        end
        object Label17: TLabel
          Left = 8
          Top = 92
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'V2'
          Layout = tlCenter
        end
        object Label18: TLabel
          Left = 8
          Top = 116
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'I'
          Layout = tlCenter
        end
        object Label28: TLabel
          Left = 8
          Top = 140
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'Ix10'
          Layout = tlCenter
        end
        object Label42: TLabel
          Left = 8
          Top = 164
          Width = 97
          Height = 21
          AutoSize = False
          Caption = 'SetPoint (Aout)'
          Layout = tlCenter
        end
        object PanKolChV4: TPanel
          Left = 108
          Top = 45
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 0
        end
        object EKolChV4: TEdit
          Left = 184
          Top = 44
          Width = 65
          Height = 21
          TabOrder = 1
          Text = 'Edit1'
        end
        object BuKolChV4: TButton
          Left = 264
          Top = 45
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 2
          OnClick = BuKolChV4Click
        end
        object PanKolChVref: TPanel
          Left = 108
          Top = 69
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 3
        end
        object EKolChVref: TEdit
          Left = 184
          Top = 68
          Width = 65
          Height = 21
          TabOrder = 4
          Text = 'Edit1'
        end
        object BuKolChVref: TButton
          Left = 264
          Top = 69
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 5
          OnClick = BuKolChVrefClick
        end
        object PanKolChV2: TPanel
          Left = 108
          Top = 93
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 6
        end
        object EKolChV2: TEdit
          Left = 184
          Top = 92
          Width = 65
          Height = 21
          TabOrder = 7
          Text = 'Edit1'
        end
        object BuKolChV2: TButton
          Left = 264
          Top = 93
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 8
          OnClick = BuKolChV2Click
        end
        object PanKolChI: TPanel
          Left = 108
          Top = 117
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 9
        end
        object EKolChI: TEdit
          Left = 184
          Top = 116
          Width = 65
          Height = 21
          TabOrder = 10
          Text = 'Edit1'
        end
        object BuKolChI: TButton
          Left = 264
          Top = 117
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 11
          OnClick = BuKolChIClick
        end
        object PanKolChI10: TPanel
          Left = 108
          Top = 141
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 12
        end
        object EKolChI10: TEdit
          Left = 184
          Top = 140
          Width = 65
          Height = 21
          TabOrder = 13
          Text = 'Edit1'
        end
        object BuKolChI10: TButton
          Left = 264
          Top = 141
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 14
          OnClick = BuKolChI10Click
        end
        object PanKolChSP: TPanel
          Left = 108
          Top = 165
          Width = 61
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 15
        end
        object EKolChSP: TEdit
          Left = 184
          Top = 164
          Width = 65
          Height = 21
          TabOrder = 16
          Text = 'Edit1'
        end
        object BuKolChSP: TButton
          Left = 264
          Top = 165
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 17
          OnClick = BuKolChSPClick
        end
      end
      object GroupBox5: TGroupBox
        Left = 528
        Top = 8
        Width = 313
        Height = 193
        Caption = 'Interface config'
        TabOrder = 2
        object Label32: TLabel
          Left = 9
          Top = 76
          Width = 95
          Height = 20
          AutoSize = False
          Caption = 'Const U feedback'
          Layout = tlCenter
        end
        object Label3: TLabel
          Left = 9
          Top = 100
          Width = 95
          Height = 20
          AutoSize = False
          Caption = 'Const I feedback'
          Layout = tlCenter
        end
        object Label43: TLabel
          Left = 7
          Top = 128
          Width = 226
          Height = 20
          AutoSize = False
          Caption = 'Number of Communication Retries'
          Layout = tlCenter
        end
        object Label20: TLabel
          Left = 164
          Top = 53
          Width = 141
          Height = 20
          AutoSize = False
          Caption = 'TODO: LIMITS curretnt, etc...'
        end
        object ChkKolPTCBufferedRead: TCheckBox
          Left = 8
          Top = 16
          Width = 217
          Height = 17
          Caption = 'Buffered Read from Library'
          TabOrder = 0
          OnClick = ChkKolPTCBufferedReadClick
        end
        object CheckBox3: TCheckBox
          Left = 8
          Top = 32
          Width = 193
          Height = 17
          Caption = 'Delayed Initialization'
          Enabled = False
          TabOrder = 1
        end
        object ChkBKolPTCAutoRange: TCheckBox
          Left = 8
          Top = 48
          Width = 137
          Height = 17
          Caption = 'AutoSwitch Range'
          Enabled = False
          TabOrder = 2
        end
        object PanKolConstUFB: TPanel
          Left = 112
          Top = 77
          Width = 65
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 3
        end
        object CBKolPTCUFB: TComboBox
          Left = 194
          Top = 73
          Width = 60
          Height = 21
          TabOrder = 4
          Text = 'V4'
          OnChange = CBKolPTCUFBChange
          Items.Strings = (
            'FB0/V2'
            'FB1/V4'
            'FB2/Vref'
            'FB3'
            'FB4')
        end
        object CBKolPTCIFB: TComboBox
          Left = 194
          Top = 100
          Width = 60
          Height = 21
          TabOrder = 5
          Text = 'I'
          OnChange = CBKolPTCIFBChange
          Items.Strings = (
            'FB0'
            'FB1'
            'FB2'
            'FB3'
            'FB4/I'
            'FB5/Ix10')
        end
        object PanKolConstIFB: TPanel
          Left = 112
          Top = 101
          Width = 65
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 6
        end
        object PanKolRetryCnt: TPanel
          Left = 8
          Top = 144
          Width = 81
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 7
        end
        object EKolRetryCnt: TEdit
          Left = 104
          Top = 144
          Width = 81
          Height = 21
          TabOrder = 8
          Text = '0'
          OnChange = EKolRetryCntChange
        end
        object BuKolSetRetry: TButton
          Left = 192
          Top = 144
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 9
          OnClick = BuKolSetRetryClick
        end
        object Button9: TButton
          Left = 200
          Top = 16
          Width = 97
          Height = 33
          Caption = 'Set request restart'
          TabOrder = 10
          OnClick = Button9Click
        end
        object ChkKolUseVrefInsteadOfV4: TCheckBox
          Left = 13
          Top = 167
          Width = 276
          Height = 20
          Caption = 'Use Vref instead of V4 (read+feedback)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 11
          OnClick = ChkKolUseVrefInsteadOfV4Click
        end
        object Button11: TButton
          Left = 256
          Top = 120
          Width = 57
          Height = 25
          Caption = 'ChekPID'
          TabOrder = 12
          OnClick = Button11Click
        end
      end
      object GroupBox6: TGroupBox
        Left = 248
        Top = 464
        Width = 273
        Height = 209
        Caption = 'Interface status 2'
        TabOrder = 3
        object Label11: TLabel
          Left = 7
          Top = 64
          Width = 60
          Height = 20
          AutoSize = False
          Caption = 'I range'
          Layout = tlCenter
        end
        object Label5: TLabel
          Left = 7
          Top = 40
          Width = 60
          Height = 20
          AutoSize = False
          Caption = 'V range'
          Layout = tlCenter
        end
        object Label27: TLabel
          Left = 7
          Top = 16
          Width = 60
          Height = 20
          AutoSize = False
          Caption = 'Last OCV'
          Layout = tlCenter
        end
        object Label4: TLabel
          Left = 5
          Top = 96
          Width = 116
          Height = 20
          AutoSize = False
          Caption = 'Aquire time metric (ms):'
          Layout = tlCenter
        end
        object Label44: TLabel
          Left = 5
          Top = 144
          Width = 116
          Height = 20
          AutoSize = False
          Caption = 'Comm Errors incl. fixed'
          Layout = tlCenter
        end
        object Label46: TLabel
          Left = 5
          Top = 168
          Width = 116
          Height = 20
          AutoSize = False
          Caption = 'Comm Erros NOT fixed'
          Layout = tlCenter
        end
        object Label47: TLabel
          Left = 5
          Top = 120
          Width = 116
          Height = 20
          AutoSize = False
          Caption = 'Communication counter'
          Layout = tlCenter
        end
        object PanKolIRange: TPanel
          Left = 72
          Top = 64
          Width = 137
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 0
        end
        object PanKolVRange: TPanel
          Left = 72
          Top = 40
          Width = 137
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 1
        end
        object PanKolLastOCV: TPanel
          Left = 92
          Top = 16
          Width = 117
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 2
        end
        object PanKolAquireTime: TPanel
          Left = 128
          Top = 96
          Width = 105
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 3
        end
        object PanKolCommErr: TPanel
          Left = 128
          Top = 144
          Width = 105
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 4
        end
        object PanKolCommErrNotFixed: TPanel
          Left = 128
          Top = 168
          Width = 105
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 5
        end
        object PanKolCommCnt: TPanel
          Left = 128
          Top = 120
          Width = 105
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          ParentColor = True
          TabOrder = 6
        end
        object Button6: TButton
          Left = 200
          Top = 8
          Width = 81
          Height = 25
          Caption = 'STart PTCSrv'
          TabOrder = 7
          OnClick = Button6Click
        end
        object Button7: TButton
          Left = 192
          Top = 40
          Width = 89
          Height = 17
          Caption = 'STop PTCSrv'
          TabOrder = 8
          OnClick = Button7Click
        end
        object Button8: TButton
          Left = 200
          Top = 72
          Width = 73
          Height = 17
          Caption = 'Get PID PTc srv'
          TabOrder = 9
          OnClick = Button8Click
        end
        object Button10: TButton
          Left = 200
          Top = 112
          Width = 73
          Height = 17
          Caption = 'Get Handle'
          TabOrder = 10
          OnClick = Button10Click
        end
      end
      object GroupBox7: TGroupBox
        Left = 5
        Top = 140
        Width = 524
        Height = 309
        Caption = 'Hardware control'
        Color = clSkyBlue
        ParentColor = False
        TabOrder = 4
        object Label37: TLabel
          Left = 287
          Top = 124
          Width = 57
          Height = 20
          AutoSize = False
          Caption = 'Set Range'
          Layout = tlCenter
        end
        object Label45: TLabel
          Left = 241
          Top = 156
          Width = 120
          Height = 20
          AutoSize = False
          Caption = 'Directly Select FeedBack'
          Layout = tlCenter
        end
        object Label30: TLabel
          Left = 264
          Top = 245
          Width = 193
          Height = 20
          AutoSize = False
          Caption = 'New V4 Protection Range: Min, Max (V)'
          Layout = tlCenter
        end
        object Label6: TLabel
          Left = 263
          Top = 216
          Width = 62
          Height = 20
          AutoSize = False
          Caption = 'New setpoint'
          Layout = tlCenter
        end
        object Label19: TLabel
          Left = 5
          Top = 216
          Width = 100
          Height = 20
          AutoSize = False
          Caption = 'Device Setpoint Now'
          Layout = tlCenter
        end
        object Label29: TLabel
          Left = 5
          Top = 264
          Width = 84
          Height = 20
          AutoSize = False
          Caption = 'V4Range In Use'
          Layout = tlCenter
        end
        object Label31: TLabel
          Left = 369
          Top = 172
          Width = 32
          Height = 20
          AutoSize = False
          Caption = 'OR'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
        end
        object Label48: TLabel
          Left = 9
          Top = 12
          Width = 224
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Caption = 'Actuall Device Status'
          Color = clYellow
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Layout = tlCenter
        end
        object Label49: TLabel
          Left = 265
          Top = 12
          Width = 240
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Caption = 'User Control'
          Color = clYellow
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Layout = tlCenter
        end
        object Label50: TLabel
          Left = 11
          Top = 285
          Width = 494
          Height = 20
          AutoSize = False
          Caption = 
            'Note: Device V4Range and setpoint: Value Measured INTERNALLY by ' +
            'PTC - Mind the Correct Polarity!'
          Layout = tlCenter
        end
        object BuKolPTCTurnON: TButton
          Left = 272
          Top = 80
          Width = 105
          Height = 25
          Caption = 'Turn Output ON'
          TabOrder = 0
          OnClick = BuKolPTCTurnONClick
        end
        object BuKolPTCTurnOFF: TButton
          Left = 384
          Top = 80
          Width = 105
          Height = 25
          Caption = 'Turn Output OFF'
          TabOrder = 1
          OnClick = BuKolPTCTurnOFFClick
        end
        object CBKolPTCRng: TComboBox
          Left = 352
          Top = 124
          Width = 137
          Height = 21
          TabOrder = 2
          Text = '10mOhm: MAX 15A'
          OnChange = CBKolPTCRngChange
          Items.Strings = (
            '10mOhm: MAX 15A'
            '1Ohm: MAX 150mA')
        end
        object CBKolSelectFB: TComboBox
          Left = 256
          Top = 172
          Width = 81
          Height = 21
          TabOrder = 3
          Text = 'V4'
          OnChange = CBKolSelectFBChange
          Items.Strings = (
            'V2'
            'V4'
            'Vref'
            'I'
            'Ix10')
        end
        object EKolPTCV4RngMin: TEdit
          Left = 296
          Top = 264
          Width = 73
          Height = 21
          TabOrder = 4
          Text = 'Edit1'
          OnChange = EKolPTCV4RngMinChange
        end
        object EKolPTCV4RngMax: TEdit
          Left = 376
          Top = 264
          Width = 73
          Height = 21
          TabOrder = 5
          Text = 'Edit1'
          OnChange = EKolPTCV4RngMaxChange
        end
        object BuKolPTCSetV4Rng: TButton
          Left = 456
          Top = 264
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 6
          OnClick = BuKolPTCSetV4RngClick
        end
        object EKolNewSetp: TEdit
          Left = 328
          Top = 216
          Width = 97
          Height = 21
          TabOrder = 7
          Text = '0'
          OnChange = EKolNewSetpChange
        end
        object BuKolPTCSetSP: TButton
          Left = 440
          Top = 216
          Width = 41
          Height = 20
          Caption = 'Set'
          TabOrder = 8
          OnClick = BuKolPTCSetSPClick
        end
        object BuKolPTCResFuse: TButton
          Left = 272
          Top = 40
          Width = 217
          Height = 33
          Caption = 'Reset Fuses'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 9
          OnClick = BuKolPTCResFuseClick
        end
        object BuKolSetConstU: TButton
          Left = 408
          Top = 160
          Width = 105
          Height = 25
          Caption = 'Set Const U mode'
          TabOrder = 10
          OnClick = BuKolSetConstUClick
        end
        object BuKolSetConstI: TButton
          Left = 408
          Top = 184
          Width = 105
          Height = 25
          Caption = 'Set Const I mode'
          TabOrder = 11
          OnClick = BuKolSetConstIClick
        end
        object ChkKolFuse: TCheckBox
          Left = 13
          Top = 40
          Width = 169
          Height = 20
          Caption = 'FuseActivated'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 12
        end
        object ChkKolRelayOn: TCheckBox
          Left = 13
          Top = 79
          Width = 113
          Height = 20
          Caption = 'Output Connected'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clTeal
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 13
        end
        object GBoxKolPTCShowRange: TGroupBox
          Left = 5
          Top = 112
          Width = 137
          Height = 35
          Caption = 'Range'
          TabOrder = 14
          object RBKolPTCr2: TRadioButton
            Left = 64
            Top = 16
            Width = 65
            Height = 17
            Caption = '500 mA'
            Enabled = False
            TabOrder = 0
          end
          object RBKolPTCr1: TRadioButton
            Left = 8
            Top = 16
            Width = 49
            Height = 17
            Caption = '15 A'
            Enabled = False
            TabOrder = 1
          end
        end
        object GBox5: TGroupBox
          Left = 5
          Top = 160
          Width = 209
          Height = 35
          Caption = 'Feedback'
          TabOrder = 15
          object RBKolPTCV2: TRadioButton
            Left = 8
            Top = 16
            Width = 41
            Height = 17
            Caption = 'V2'
            Enabled = False
            TabOrder = 0
          end
          object RBKolPTCV4: TRadioButton
            Left = 48
            Top = 16
            Width = 41
            Height = 17
            Caption = 'V4'
            Enabled = False
            TabOrder = 1
          end
          object RBKolPTCVRef: TRadioButton
            Left = 88
            Top = 16
            Width = 41
            Height = 17
            Caption = 'Vref'
            Enabled = False
            TabOrder = 2
          end
          object RBKolPTCI: TRadioButton
            Left = 128
            Top = 16
            Width = 41
            Height = 17
            Caption = 'I'
            Enabled = False
            TabOrder = 3
          end
          object RBKolPTCIx10: TRadioButton
            Left = 160
            Top = 16
            Width = 41
            Height = 17
            Caption = 'Ix10'
            Enabled = False
            TabOrder = 4
          end
        end
        object PanKolSetpoint: TPanel
          Left = 112
          Top = 216
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 16
        end
        object PanKolProtV4Rng: TPanel
          Left = 92
          Top = 264
          Width = 157
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 17
        end
        object PanKolProtStat: TPanel
          Left = 56
          Top = 56
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 18
        end
      end
      object GroupBox8: TGroupBox
        Left = 5
        Top = 8
        Width = 516
        Height = 129
        Caption = 'Interface status and control'
        TabOrder = 5
        object LKolptcHWstr: TLabel
          Left = 8
          Top = 35
          Width = 66
          Height = 13
          Caption = 'LKolptcHWstr'
        end
        object LaKolIfaceInfo: TLabel
          Left = 8
          Top = 16
          Width = 66
          Height = 13
          Caption = 'LKolptcHWstr'
        end
        object ChkKolAvailable: TCheckBox
          Left = 13
          Top = 56
          Width = 113
          Height = 17
          Caption = 'Available'
          Enabled = False
          TabOrder = 0
        end
        object ChkKolReady: TCheckBox
          Left = 13
          Top = 72
          Width = 105
          Height = 17
          Caption = 'Ready'
          Enabled = False
          TabOrder = 1
        end
        object ChkKolConfigured: TCheckBox
          Left = 13
          Top = 88
          Width = 105
          Height = 17
          Caption = 'Configured'
          Enabled = False
          TabOrder = 2
        end
        object ChkKolDllloaded: TCheckBox
          Left = 13
          Top = 104
          Width = 129
          Height = 17
          Caption = 'Dll Functions Loaded'
          Enabled = False
          TabOrder = 3
        end
        object ButKolInit: TButton
          Left = 336
          Top = 98
          Width = 80
          Height = 25
          Caption = 'Initialize PTC'
          TabOrder = 4
          OnClick = ButKolInitClick
        end
        object ButKolFinal: TButton
          Left = 424
          Top = 98
          Width = 80
          Height = 25
          Caption = 'Finalize PTC'
          TabOrder = 5
          OnClick = ButKolFinalClick
        end
        object BuKolLoadDLL: TButton
          Left = 376
          Top = 74
          Width = 129
          Height = 25
          Caption = 'Connect (load DLL)'
          TabOrder = 6
          OnClick = BuKolLoadDLLClick
        end
        object ChkKolOverrange: TCheckBox
          Left = 152
          Top = 104
          Width = 137
          Height = 17
          Caption = 'OverRange detected'
          Enabled = False
          TabOrder = 7
        end
        object ChkKolDebug: TCheckBox
          Left = 360
          Top = 16
          Width = 121
          Height = 17
          Caption = 'Debug Enabled'
          TabOrder = 8
          OnClick = ChkKolDebugClick
        end
        object PanKolShowFuseHard: TPanel
          Left = 88
          Top = 45
          Width = 313
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 9
        end
        object PanKolShowFuseSafe: TPanel
          Left = 88
          Top = 69
          Width = 281
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 10
        end
      end
      object GroupBox1: TGroupBox
        Left = 5
        Top = 452
        Width = 230
        Height = 221
        Caption = 'Hardware Status'
        TabOrder = 6
        object MeKolChannels: TMemo
          Left = 5
          Top = 16
          Width = 212
          Height = 201
          Lines.Strings = (
            'Memo1')
          TabOrder = 0
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'DummyPTC'
      ImageIndex = 1
      object Label21: TLabel
        Left = 280
        Top = 48
        Width = 3
        Height = 13
      end
      object GroupBox9: TGroupBox
        Left = 0
        Top = 112
        Width = 801
        Height = 345
        Caption = 'Simul Params '
        TabOrder = 0
        object Label51: TLabel
          Left = 10
          Top = 55
          Width = 180
          Height = 20
          AutoSize = False
          Caption = 'Internal Rezistance (Ohm)'
          Layout = tlCenter
        end
        object Label52: TLabel
          Left = 10
          Top = 204
          Width = 164
          Height = 20
          AutoSize = False
          Caption = 'Random Noise Amp (1)'
          Layout = tlCenter
        end
        object Label53: TLabel
          Left = 10
          Top = 30
          Width = 108
          Height = 20
          AutoSize = False
          Caption = 'Open Voltage (V)'
          Layout = tlCenter
        end
        object Label54: TLabel
          Left = 10
          Top = 80
          Width = 108
          Height = 20
          AutoSize = False
          Caption = 'CrossOver Current (A)'
          Layout = tlCenter
        end
        object Label55: TLabel
          Left = 10
          Top = 229
          Width = 164
          Height = 20
          AutoSize = False
          Caption = 'Die Out Ratio (1)'
          Layout = tlCenter
        end
        object Label56: TLabel
          Left = 10
          Top = 179
          Width = 164
          Height = 20
          AutoSize = False
          Caption = 'Sinusoidal Distortion Amp (1)'
          Layout = tlCenter
        end
        object Label57: TLabel
          Left = 10
          Top = 105
          Width = 108
          Height = 20
          AutoSize = False
          Caption = 'Tafel Slope (V.dec-1)'
          Layout = tlCenter
        end
        object Label58: TLabel
          Left = 10
          Top = 130
          Width = 212
          Height = 20
          AutoSize = False
          Caption = '(Mass) Activity Non-normalized @ 900mV (A)'
          Layout = tlCenter
        end
        object Label59: TLabel
          Left = 250
          Top = 10
          Width = 108
          Height = 20
          AutoSize = False
          Caption = 'Value in USE'
          Layout = tlCenter
        end
        object Label60: TLabel
          Left = 380
          Top = 10
          Width = 108
          Height = 20
          AutoSize = False
          Caption = 'New value'
          Layout = tlCenter
        end
        object Label61: TLabel
          Left = 10
          Top = 154
          Width = 212
          Height = 20
          AutoSize = False
          Caption = 'Exchange Current Density (A)'
          Layout = tlCenter
        end
        object ChkDummyDieOut: TCheckBox
          Left = 10
          Top = 272
          Width = 250
          Height = 17
          Caption = 'Enable Die out simulation'
          TabOrder = 0
          OnClick = ChkDummyDieOutClick
        end
        object ChkDummyNoise: TCheckBox
          Left = 10
          Top = 256
          Width = 250
          Height = 17
          Caption = 'Enable Noise'
          TabOrder = 1
          OnClick = ChkDummyNoiseClick
        end
        object PanDumOCV: TPanel
          Left = 250
          Top = 30
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 2
        end
        object EDumOCV: TEdit
          Left = 380
          Top = 30
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 3
        end
        object BuDumOCV: TButton
          Left = 480
          Top = 30
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 4
          OnClick = BuKolSetRetryClick
        end
        object ChkDummyCommError: TCheckBox
          Left = 10
          Top = 304
          Width = 250
          Height = 17
          Caption = 'Enable Comm Error Simul Insert'
          TabOrder = 5
          OnClick = ChkDummyNoiseClick
        end
        object ChkDumFuse: TCheckBox
          Left = 10
          Top = 320
          Width = 250
          Height = 17
          Caption = 'Enable PTC FUSE random insert'
          TabOrder = 6
          OnClick = ChkDummyNoiseClick
        end
        object PanDumiR: TPanel
          Left = 250
          Top = 55
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 7
        end
        object EDumiR: TEdit
          Left = 380
          Top = 55
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 8
        end
        object BuDumiR: TButton
          Left = 480
          Top = 55
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 9
          OnClick = BuKolSetRetryClick
        end
        object PanDumXOver: TPanel
          Left = 250
          Top = 80
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 10
        end
        object EDumXOver: TEdit
          Left = 380
          Top = 80
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 11
        end
        object BuDumXOver: TButton
          Left = 480
          Top = 80
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 12
          OnClick = BuKolSetRetryClick
        end
        object PanDumTafel: TPanel
          Left = 250
          Top = 105
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 13
        end
        object EDumTafel: TEdit
          Left = 380
          Top = 105
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 14
        end
        object BuDumTafel: TButton
          Left = 480
          Top = 105
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 15
          OnClick = BuKolSetRetryClick
        end
        object PanDumMA: TPanel
          Left = 250
          Top = 130
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 16
        end
        object EDumMA: TEdit
          Left = 380
          Top = 130
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 17
        end
        object BuDumMA: TButton
          Left = 480
          Top = 130
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 18
          OnClick = BuKolSetRetryClick
        end
        object PanDumSinDistAmp: TPanel
          Left = 250
          Top = 179
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 19
        end
        object ESinDistAmp: TEdit
          Left = 380
          Top = 179
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 20
        end
        object BuSinDistAmp: TButton
          Left = 480
          Top = 179
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 21
          OnClick = BuKolSetRetryClick
        end
        object PanDumRndNoiseAmp: TPanel
          Left = 250
          Top = 204
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 22
        end
        object ERndNoiseAmp: TEdit
          Left = 380
          Top = 204
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 23
        end
        object BuRndNoiseAmp: TButton
          Left = 480
          Top = 204
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 24
          OnClick = BuKolSetRetryClick
        end
        object PanDumDieOutRatio: TPanel
          Left = 250
          Top = 229
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 25
        end
        object EDumDieOutRatio: TEdit
          Left = 380
          Top = 229
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 26
        end
        object BuDumDieOutRatio: TButton
          Left = 480
          Top = 229
          Width = 57
          Height = 20
          Caption = 'Set'
          TabOrder = 27
          OnClick = BuKolSetRetryClick
        end
        object PanDumExC: TPanel
          Left = 250
          Top = 154
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Exchange Current Density (A)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = True
          ParentFont = False
          TabOrder = 28
        end
        object chkDumEnSwLIM: TCheckBox
          Left = 338
          Top = 272
          Width = 250
          Height = 17
          Caption = 'Enable V4 limmiting'
          TabOrder = 29
          OnClick = chkDumEnSwLIMClick
        end
        object chkDumEnFuse: TCheckBox
          Left = 338
          Top = 288
          Width = 250
          Height = 17
          Caption = 'Enable HW FUSE indicator'
          TabOrder = 30
          OnClick = chkDumEnFuseClick
        end
      end
      object GroupBox10: TGroupBox
        Left = 0
        Top = 0
        Width = 801
        Height = 105
        Caption = 'Device Status'
        TabOrder = 1
        object LDummyV: TLabel
          Left = 256
          Top = 12
          Width = 49
          Height = 21
          AutoSize = False
          Caption = 'Voltage'
          Layout = tlCenter
        end
        object LDumyI: TLabel
          Left = 424
          Top = 12
          Width = 41
          Height = 21
          AutoSize = False
          Caption = 'Current'
          Layout = tlCenter
        end
        object ChkDumAvail: TCheckBox
          Left = 5
          Top = 32
          Width = 113
          Height = 17
          Caption = 'Available'
          Enabled = False
          TabOrder = 0
        end
        object ChkDumConf: TCheckBox
          Left = 5
          Top = 16
          Width = 105
          Height = 17
          Caption = 'Created'
          Enabled = False
          TabOrder = 1
        end
        object ChkDumReady: TCheckBox
          Left = 5
          Top = 48
          Width = 105
          Height = 17
          Caption = 'Ready'
          Enabled = False
          TabOrder = 2
        end
        object GroupBox4: TGroupBox
          Left = 144
          Top = 16
          Width = 89
          Height = 38
          Caption = 'Feedback'
          TabOrder = 3
          object RBDummyFBV: TRadioButton
            Left = 8
            Top = 16
            Width = 41
            Height = 17
            Caption = 'V'
            Enabled = False
            TabOrder = 0
          end
          object RBDummyFBI: TRadioButton
            Left = 48
            Top = 16
            Width = 33
            Height = 17
            Caption = 'I'
            Enabled = False
            TabOrder = 1
          end
        end
        object ChkDummyOuput: TCheckBox
          Left = 261
          Top = 56
          Width = 188
          Height = 17
          Caption = 'Output Connected'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
        end
        object PanDumVolt: TPanel
          Left = 256
          Top = 29
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 5
        end
        object PanDumCurr: TPanel
          Left = 424
          Top = 29
          Width = 121
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Caption'
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clLime
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 6
        end
        object BuDummyCon: TButton
          Left = 560
          Top = 24
          Width = 81
          Height = 25
          Caption = 'Connect'
          TabOrder = 7
          OnClick = BuDummyConClick
        end
        object BuDummyDiscon: TButton
          Left = 640
          Top = 24
          Width = 81
          Height = 25
          Caption = 'Disconnect'
          TabOrder = 8
          OnClick = BuDummyDisconClick
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'BK8500'
      ImageIndex = 2
      object LaBKstatus: TLabel
        Left = 200
        Top = 96
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
      object Label26: TLabel
        Left = 407
        Top = 112
        Width = 60
        Height = 20
        AutoSize = False
        Caption = 'Last I'
        Layout = tlCenter
      end
      object Label25: TLabel
        Left = 407
        Top = 88
        Width = 60
        Height = 20
        AutoSize = False
        Caption = 'Last U'
        Layout = tlCenter
      end
      object Label24: TLabel
        Left = 200
        Top = 48
        Width = 38
        Height = 13
        Caption = 'Timeout'
      end
      object Label23: TLabel
        Left = 407
        Top = 64
        Width = 60
        Height = 20
        AutoSize = False
        Caption = 'Last mode'
        Layout = tlCenter
      end
      object Label22: TLabel
        Left = 624
        Top = 92
        Width = 45
        Height = 13
        Caption = 'OK count'
      end
      object Label2: TLabel
        Left = 616
        Top = 68
        Width = 52
        Height = 13
        Caption = 'Error count'
      end
      object Label16: TLabel
        Left = 8
        Top = 44
        Width = 46
        Height = 13
        Caption = 'Baud rate'
      end
      object Label15: TLabel
        Left = 407
        Top = 40
        Width = 60
        Height = 20
        AutoSize = False
        Caption = 'Last setpoint'
        Layout = tlCenter
      end
      object Label12: TLabel
        Left = 8
        Top = 20
        Width = 22
        Height = 13
        Caption = 'Port:'
      end
      object CheckBox1: TCheckBox
        Left = 16
        Top = 176
        Width = 169
        Height = 17
        Caption = 'Error detected:'
        Enabled = False
        TabOrder = 0
      end
      object Edit1: TEdit
        Left = 120
        Top = 176
        Width = 505
        Height = 21
        TabOrder = 1
        Text = 'EBKPing'
      end
      object EBKTimeout: TEdit
        Left = 256
        Top = 48
        Width = 105
        Height = 21
        TabOrder = 2
        Text = 'EBKTimeout'
        OnChange = EBKTimeoutChange
      end
      object EBKPort: TEdit
        Left = 72
        Top = 20
        Width = 81
        Height = 21
        Enabled = False
        TabOrder = 3
        Text = 'COM1'
      end
      object EBKPing: TEdit
        Left = 200
        Top = 136
        Width = 257
        Height = 21
        Enabled = False
        TabOrder = 4
        Text = 'EBKPing'
      end
      object EBKOKCnt: TEdit
        Left = 672
        Top = 84
        Width = 65
        Height = 21
        Enabled = False
        TabOrder = 5
        Text = 'Edit2'
      end
      object EBKLastU: TEdit
        Left = 480
        Top = 88
        Width = 113
        Height = 21
        Enabled = False
        TabOrder = 6
        Text = '0'
      end
      object EBKLastSetp: TEdit
        Left = 480
        Top = 40
        Width = 113
        Height = 21
        Enabled = False
        TabOrder = 7
        Text = '0'
      end
      object EBKLastMode: TEdit
        Left = 480
        Top = 64
        Width = 113
        Height = 21
        Enabled = False
        TabOrder = 8
        Text = '0'
      end
      object EBKLastI: TEdit
        Left = 480
        Top = 112
        Width = 113
        Height = 21
        Enabled = False
        TabOrder = 9
        Text = '0'
      end
      object EBKErrCnt: TEdit
        Left = 672
        Top = 60
        Width = 65
        Height = 21
        Enabled = False
        TabOrder = 10
        Text = 'EBKErrCnt'
      end
      object EBKBaudrate: TEdit
        Left = 72
        Top = 44
        Width = 81
        Height = 21
        Enabled = False
        TabOrder = 11
        Text = 'COM1'
      end
      object cbBKremotesense: TCheckBox
        Left = 200
        Top = 16
        Width = 177
        Height = 25
        Caption = 'BK8500 Remote Sensing'
        TabOrder = 12
        OnClick = cbBKremotesenseClick
      end
      object CbBKPortOpened: TCheckBox
        Left = 32
        Top = 63
        Width = 97
        Height = 20
        Caption = 'Port Opened'
        Enabled = False
        TabOrder = 13
        OnClick = cbBKdebugClick
      end
      object cbBKOutputOn: TCheckBox
        Left = 416
        Top = 16
        Width = 169
        Height = 17
        Caption = 'Output Connected'
        Enabled = False
        TabOrder = 14
      end
      object cbBKdebug: TCheckBox
        Left = 632
        Top = 120
        Width = 113
        Height = 25
        Caption = 'Bk8500 debug ON'
        TabOrder = 15
        OnClick = cbBKdebugClick
      end
      object Button1: TButton
        Left = 8
        Top = 144
        Width = 113
        Height = 17
        Caption = 'Display Com Timeouts'
        TabOrder = 16
        OnClick = Button1Click
      end
      object buBKResetCnt: TButton
        Left = 624
        Top = 16
        Width = 129
        Height = 33
        Caption = 'Reset Err cnt'
        TabOrder = 17
        OnClick = buBKResetCntClick
      end
      object BuBKping: TButton
        Left = 128
        Top = 136
        Width = 65
        Height = 25
        Caption = 'Ping'
        TabOrder = 18
        OnClick = BuBKpingClick
      end
      object buBKopenPort: TButton
        Left = 8
        Top = 112
        Width = 81
        Height = 20
        Caption = 'Open Port'
        TabOrder = 19
        OnClick = buBKopenPortClick
      end
      object buBKConfPort: TButton
        Left = 8
        Top = 88
        Width = 161
        Height = 20
        Caption = 'ComPortConf'
        TabOrder = 20
        OnClick = buBKConfPortClick
      end
      object buBKcloseport: TButton
        Left = 88
        Top = 112
        Width = 81
        Height = 20
        Caption = 'ClosePort'
        TabOrder = 21
        OnClick = buBKcloseportClick
      end
    end
    object M97XX: TTabSheet
      Caption = 'M97XX'
      ImageIndex = 4
      object PanM97XX: TPanel
        Left = 8
        Top = 0
        Width = 817
        Height = 657
        TabOrder = 0
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'ZS1806'
      ImageIndex = 5
      object PanZS1806: TPanel
        Left = 3
        Top = 0
        Width = 817
        Height = 657
        TabOrder = 0
      end
    end
    object PLIseries: TTabSheet
      Caption = 'PLIseries'
      ImageIndex = 5
      object PanPLIseries: TPanel
        Left = 0
        Top = 0
        Width = 857
        Height = 677
        Align = alClient
        Caption = 'PanPLIseries'
        TabOrder = 0
      end
    end
  end
  object Button2: TButton
    Left = 8
    Top = 5
    Width = 120
    Height = 25
    Caption = 'Hide'
    TabOrder = 6
    OnClick = ButtonHideClick
  end
  object Button3: TButton
    Left = 8
    Top = 749
    Width = 120
    Height = 25
    Caption = 'Hide'
    TabOrder = 7
    OnClick = ButtonHideClick
  end
  object Button4: TButton
    Left = 752
    Top = 749
    Width = 120
    Height = 25
    Caption = 'Hide'
    TabOrder = 8
    OnClick = ButtonHideClick
  end
  object HWFormTimer: TTimer
    Enabled = False
    OnTimer = HWFormTimerTimer
    Left = 568
    Top = 8
  end
end

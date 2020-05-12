object FormFlowHardware: TFormFlowHardware
  Left = 371
  Top = 149
  Caption = 'FlowController Hardware Form'
  ClientHeight = 722
  ClientWidth = 869
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 80
    Top = 8
    Width = 269
    Height = 20
    Caption = 'FlowController module selection'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 704
    Top = 8
    Width = 13
    Height = 13
    Caption = 'ms'
  end
  object Label3: TLabel
    Left = 728
    Top = 720
    Width = 32
    Height = 13
    Caption = 'Label3'
  end
  object CBSelectFlow: TComboBox
    Left = 361
    Top = 6
    Width = 177
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemIndex = 2
    ParentFont = False
    TabOrder = 0
    Text = 'Flow-FCS-TCPIP'
    OnChange = CBSelectFlowChange
    Items.Strings = (
      'Alicat RS232'
      'Dummy Flow'
      'Flow-FCS-TCPIP')
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 40
    Width = 793
    Height = 225
    Caption = 'Simple status and control of selected module'
    TabOrder = 1
    object Label5: TLabel
      Left = 520
      Top = 66
      Width = 97
      Height = 20
      AutoSize = False
      Caption = 'New Setpoint'
      Layout = tlCenter
    end
    object Label6: TLabel
      Left = 688
      Top = 66
      Width = 97
      Height = 20
      AutoSize = False
      Caption = 'Select gas'
      Layout = tlCenter
    end
    object Label9: TLabel
      Left = 458
      Top = 66
      Width = 41
      Height = 20
      AutoSize = False
      Caption = 'Device'
      Layout = tlCenter
    end
    object Label20: TLabel
      Left = 8
      Top = 18
      Width = 41
      Height = 25
      AutoSize = False
      Caption = 'Name:'
      Layout = tlCenter
    end
    object ChkFlowReady: TCheckBox
      Left = 400
      Top = 18
      Width = 129
      Height = 20
      Caption = 'FlowControl Ready'
      Enabled = False
      TabOrder = 0
    end
    object BuFlowCon: TButton
      Left = 616
      Top = 18
      Width = 81
      Height = 25
      Caption = 'Connect'
      TabOrder = 1
      OnClick = BuFlowConClick
    end
    object BuFlowDiscon: TButton
      Left = 704
      Top = 18
      Width = 81
      Height = 25
      Caption = 'Disconnect'
      TabOrder = 2
      OnClick = BuFlowDisconClick
    end
    object BuFlowSPA: TButton
      Left = 584
      Top = 90
      Width = 41
      Height = 20
      Caption = 'Set SP'
      TabOrder = 3
      OnClick = BuFlowSPAClick
    end
    object EFlowSPA: TEdit
      Left = 520
      Top = 90
      Width = 57
      Height = 21
      TabOrder = 4
      Text = '0'
    end
    object BuFlowCloseA: TButton
      Left = 632
      Top = 90
      Width = 41
      Height = 20
      Caption = 'Close'
      TabOrder = 5
      OnClick = BuFlowCloseAClick
    end
    object CBFlowGasA: TComboBox
      Left = 688
      Top = 90
      Width = 89
      Height = 21
      TabOrder = 6
      Text = 'CB'
      OnChange = CBFlowGasAChange
      Items.Strings = (
        'H2'
        'N2')
    end
    object SGDummy: TStringGrid
      Left = 8
      Top = 72
      Width = 433
      Height = 129
      Color = clYellow
      DefaultColWidth = 70
      DefaultRowHeight = 20
      Enabled = False
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
      TabOrder = 7
    end
    object EFlowSPN: TEdit
      Left = 520
      Top = 115
      Width = 57
      Height = 21
      TabOrder = 8
      Text = '0'
    end
    object BuFlowSPN: TButton
      Left = 584
      Top = 115
      Width = 41
      Height = 20
      Caption = 'Set SP'
      TabOrder = 9
      OnClick = BuFlowSPNClick
    end
    object BuFlowCloseN: TButton
      Left = 632
      Top = 115
      Width = 41
      Height = 20
      Caption = 'Close'
      TabOrder = 10
      OnClick = BuFlowCloseNClick
    end
    object CBFlowGasN: TComboBox
      Left = 688
      Top = 115
      Width = 89
      Height = 21
      TabOrder = 11
      Text = 'CB'
      OnChange = CBFlowGasNChange
      Items.Strings = (
        'N2')
    end
    object EFlowSPC: TEdit
      Left = 520
      Top = 140
      Width = 57
      Height = 21
      TabOrder = 12
      Text = '0'
    end
    object BuFlowSPC: TButton
      Left = 584
      Top = 140
      Width = 41
      Height = 20
      Caption = 'Set SP'
      TabOrder = 13
      OnClick = BuFlowSPCClick
    end
    object BuFlowCloseC: TButton
      Left = 632
      Top = 140
      Width = 41
      Height = 20
      Caption = 'Close'
      TabOrder = 14
      OnClick = BuFlowCloseCClick
    end
    object CBFlowGasC: TComboBox
      Left = 688
      Top = 140
      Width = 89
      Height = 21
      TabOrder = 15
      Text = 'CB'
      OnChange = CBFlowGasCChange
      Items.Strings = (
        'O2'
        'N2'
        'Air')
    end
    object EFlowSPR: TEdit
      Left = 520
      Top = 165
      Width = 57
      Height = 21
      TabOrder = 16
      Text = '0'
    end
    object BuFlowSPR: TButton
      Left = 584
      Top = 165
      Width = 41
      Height = 20
      Caption = 'Set SP'
      TabOrder = 17
      OnClick = BuFlowSPRClick
    end
    object BuFlowCloseD: TButton
      Left = 632
      Top = 165
      Width = 41
      Height = 20
      Caption = 'Close'
      TabOrder = 18
      OnClick = BuFlowCloseDClick
    end
    object CBFlowGasR: TComboBox
      Left = 688
      Top = 165
      Width = 89
      Height = 21
      TabOrder = 19
      Text = 'CB'
      OnChange = CBFlowGasRChange
      Items.Strings = (
        'H2'
        'H2+CO')
    end
    object ChkFLowIsDummy: TCheckBox
      Left = 400
      Top = 34
      Width = 129
      Height = 20
      Caption = 'FlowControl is DUMMY'
      Enabled = False
      TabOrder = 20
    end
    object PanFlowName: TPanel
      Left = 42
      Top = 18
      Width = 351
      Height = 25
      BorderStyle = bsSingle
      Caption = 'Panel'
      ParentColor = True
      TabOrder = 21
    end
    object Panel5: TPanel
      Left = 458
      Top = 165
      Width = 60
      Height = 20
      BorderStyle = bsSingle
      Caption = 'Reserve'
      ParentColor = True
      TabOrder = 22
    end
    object Panel6: TPanel
      Left = 458
      Top = 140
      Width = 60
      Height = 20
      BorderStyle = bsSingle
      Caption = 'Cathode'
      ParentColor = True
      TabOrder = 23
    end
    object Panel7: TPanel
      Left = 458
      Top = 115
      Width = 60
      Height = 20
      BorderStyle = bsSingle
      Caption = 'N2'
      ParentColor = True
      TabOrder = 24
    end
    object Panel8: TPanel
      Left = 458
      Top = 90
      Width = 60
      Height = 20
      BorderStyle = bsSingle
      Caption = 'Anode'
      ParentColor = True
      TabOrder = 25
    end
    object BuAliCloseAll: TButton
      Left = 616
      Top = 192
      Width = 81
      Height = 25
      Caption = 'Close ALL'
      TabOrder = 26
      OnClick = BuAliCloseAllClick
    end
    object chkDebug: TCheckBox
      Left = 400
      Top = 49
      Width = 97
      Height = 17
      Caption = 'debug'
      TabOrder = 27
      OnClick = chkDebugClick
    end
  end
  object ButtonHide: TButton
    Left = 728
    Top = 8
    Width = 65
    Height = 25
    Caption = 'Hide'
    TabOrder = 2
    OnClick = ButtonHideClick
  end
  object ChkAutoRefresh: TCheckBox
    Left = 544
    Top = 8
    Width = 97
    Height = 17
    Caption = 'AutoRefresh'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = ChkAutoRefreshClick
  end
  object HWFormRefreshIntv: TEdit
    Left = 640
    Top = 8
    Width = 57
    Height = 21
    TabOrder = 4
    Text = '1000'
    OnChange = HWFormRefreshIntvChange
  end
  object Button2: TButton
    Left = 8
    Top = 680
    Width = 97
    Height = 33
    Caption = 'Hide'
    TabOrder = 5
    OnClick = ButtonHideClick
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 280
    Width = 793
    Height = 385
    ActivePage = TabSheet1
    TabOrder = 6
    object TabSheet1: TTabSheet
      Caption = 'Alicat RS232'
      object Label12: TLabel
        Left = 8
        Top = 44
        Width = 22
        Height = 20
        AutoSize = False
        Caption = 'Port:'
      end
      object Label16: TLabel
        Left = 8
        Top = 68
        Width = 46
        Height = 20
        AutoSize = False
        Caption = 'Baud rate'
      end
      object LaAlistatus: TLabel
        Left = 8
        Top = 8
        Width = 241
        Height = 25
        Alignment = taCenter
        AutoSize = False
        Caption = 'LaAlistatus'
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clLime
        Font.Height = -21
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object Label22: TLabel
        Left = 664
        Top = 25
        Width = 45
        Height = 20
        AutoSize = False
        Caption = 'OK count'
      end
      object Label2: TLabel
        Left = 656
        Top = 5
        Width = 52
        Height = 20
        AutoSize = False
        Caption = 'Error count'
      end
      object Label15: TLabel
        Left = 272
        Top = 72
        Width = 49
        Height = 13
        Caption = 'User CMD'
      end
      object Label17: TLabel
        Left = 272
        Top = 96
        Width = 48
        Height = 13
        Caption = 'Response'
      end
      object Label21: TLabel
        Left = 584
        Top = 5
        Width = 73
        Height = 20
        AutoSize = False
        Caption = 'Comm statistic'
      end
      object LaAliUserCmdTime: TLabel
        Left = 617
        Top = 72
        Width = 152
        Height = 20
        AutoSize = False
        Caption = 'User CMD'
      end
      object ChkAliPortOpened: TCheckBox
        Left = 168
        Top = 48
        Width = 97
        Height = 20
        Caption = 'Port Opened'
        Enabled = False
        TabOrder = 0
        OnClick = chkAlidebugClick
      end
      object buAliConfPort: TButton
        Left = 8
        Top = 96
        Width = 145
        Height = 20
        Caption = 'ComPortConf'
        TabOrder = 1
        OnClick = buAliConfPortClick
      end
      object buAliCloseport: TButton
        Left = 168
        Top = 96
        Width = 81
        Height = 20
        Caption = 'ClosePort'
        TabOrder = 2
        OnClick = buAliCloseportClick
      end
      object buAliOpenPort: TButton
        Left = 168
        Top = 72
        Width = 81
        Height = 20
        Caption = 'Open Port'
        TabOrder = 3
        OnClick = buAliOpenPortClick
      end
      object BuAliping: TButton
        Left = 544
        Top = 72
        Width = 65
        Height = 20
        Caption = 'Send'
        TabOrder = 4
        OnClick = BuAlipingClick
      end
      object EAliUserCmdReply: TEdit
        Left = 320
        Top = 96
        Width = 457
        Height = 21
        Enabled = False
        TabOrder = 5
      end
      object EAliUserCmd: TEdit
        Left = 320
        Top = 72
        Width = 217
        Height = 21
        TabOrder = 6
        Text = 'A'
      end
      object chkAlidebug: TCheckBox
        Left = 272
        Top = 48
        Width = 225
        Height = 20
        Caption = 'Alicat Communication debug Enabled'
        TabOrder = 7
        OnClick = chkAlidebugClick
      end
      object buAliResetCnt: TButton
        Left = 712
        Top = 49
        Width = 73
        Height = 20
        Caption = 'Reset Cnts'
        TabOrder = 8
        OnClick = buAliResetCntClick
      end
      object GroupBox4: TGroupBox
        Left = 8
        Top = 208
        Width = 721
        Height = 129
        Caption = 'Configure/Assign Flowcontrollers'
        TabOrder = 9
        object Label14: TLabel
          Left = 410
          Top = 15
          Width = 59
          Height = 15
          AutoSize = False
          Caption = 'Type/range:'
        end
        object Label18: TLabel
          Left = 10
          Top = 15
          Width = 69
          Height = 15
          AutoSize = False
          Caption = 'Virtual Device:'
        end
        object Label19: TLabel
          Left = 350
          Top = 15
          Width = 38
          Height = 15
          AutoSize = False
          Caption = 'Address'
        end
        object Label10: TLabel
          Left = 200
          Top = 15
          Width = 97
          Height = 15
          AutoSize = False
          Caption = 'Used settings'
        end
        object Pan1: TPanel
          Left = 10
          Top = 32
          Width = 101
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Anode MFC'
          ParentColor = True
          TabOrder = 0
        end
        object Panel1: TPanel
          Left = 10
          Top = 54
          Width = 101
          Height = 20
          BorderStyle = bsSingle
          Caption = 'N2 MFC'
          ParentColor = True
          TabOrder = 1
        end
        object Panel2: TPanel
          Left = 10
          Top = 76
          Width = 101
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Cathode MFC'
          ParentColor = True
          TabOrder = 2
        end
        object Panel3: TPanel
          Left = 10
          Top = 98
          Width = 101
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Reserve MFC'
          ParentColor = True
          TabOrder = 3
        end
        object EAliAddrR: TEdit
          Left = 350
          Top = 98
          Width = 49
          Height = 21
          TabOrder = 4
          Text = 'D'
        end
        object EAliAddrC: TEdit
          Left = 350
          Top = 76
          Width = 49
          Height = 21
          TabOrder = 5
          Text = 'C'
        end
        object EAliAddrN: TEdit
          Left = 350
          Top = 54
          Width = 49
          Height = 21
          TabOrder = 6
          Text = 'B'
        end
        object EAliAddrA: TEdit
          Left = 350
          Top = 32
          Width = 49
          Height = 21
          TabOrder = 7
          Text = 'A'
        end
        object ChkAliDisableA: TCheckBox
          Left = 120
          Top = 32
          Width = 81
          Height = 20
          Caption = 'Disabled'
          TabOrder = 8
          OnClick = ChkAliDisableAClick
        end
        object ChkAliDisableN: TCheckBox
          Left = 120
          Top = 54
          Width = 81
          Height = 20
          Caption = 'Disabled'
          TabOrder = 9
          OnClick = ChkAliDisableNClick
        end
        object ChkAliDisableC: TCheckBox
          Left = 120
          Top = 76
          Width = 81
          Height = 20
          Caption = 'Disabled'
          TabOrder = 10
          OnClick = ChkAliDisableCClick
        end
        object ChkAliDisableR: TCheckBox
          Left = 120
          Top = 98
          Width = 81
          Height = 20
          Caption = 'Disabled'
          TabOrder = 11
          OnClick = ChkAliDisableRClick
        end
        object CBAliRngR: TComboBox
          Left = 410
          Top = 98
          Width = 113
          Height = 21
          ItemIndex = 0
          TabOrder = 12
          Text = '100sccm'
          Items.Strings = (
            '100sccm'
            '500sccm'
            '50sccm')
        end
        object CheckBox8: TCheckBox
          Left = 650
          Top = 98
          Width = 49
          Height = 20
          Caption = 'Mark'
          TabOrder = 13
        end
        object CheckBox7: TCheckBox
          Left = 650
          Top = 76
          Width = 49
          Height = 20
          Caption = 'Mark'
          TabOrder = 14
        end
        object CheckBox2: TCheckBox
          Left = 650
          Top = 54
          Width = 49
          Height = 20
          Caption = 'Mark'
          TabOrder = 15
        end
        object CheckBox1: TCheckBox
          Left = 650
          Top = 32
          Width = 49
          Height = 20
          Caption = 'Mark'
          TabOrder = 16
        end
        object CBAliRngA: TComboBox
          Left = 410
          Top = 32
          Width = 113
          Height = 21
          TabOrder = 17
          Text = '100sccm'
          Items.Strings = (
            '100sccm'
            '500sccm'
            '50sccm'
            '1000 sccm'
            '5000 sccm')
        end
        object CBAliRngN: TComboBox
          Left = 410
          Top = 54
          Width = 113
          Height = 21
          ItemIndex = 0
          TabOrder = 18
          Text = '100sccm'
          Items.Strings = (
            '100sccm'
            '500sccm'
            '50sccm')
        end
        object CBAliRngC: TComboBox
          Left = 410
          Top = 76
          Width = 113
          Height = 21
          TabOrder = 19
          Text = '100sccm'
          Items.Strings = (
            '100sccm'
            '500sccm'
            '50sccm'
            '1000 sccm'
            '5000 sccm')
        end
        object BuAliUpdateA: TButton
          Left = 540
          Top = 32
          Width = 89
          Height = 20
          Caption = 'Update settings'
          TabOrder = 20
          OnClick = BuAliUpdateAClick
        end
        object PanAliStatusA: TPanel
          Left = 200
          Top = 32
          Width = 141
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Anode'
          ParentColor = True
          TabOrder = 21
        end
        object PanAliStatusN2: TPanel
          Left = 200
          Top = 54
          Width = 141
          Height = 20
          BorderStyle = bsSingle
          Caption = 'N2'
          ParentColor = True
          TabOrder = 22
        end
        object PanAliStatusC: TPanel
          Left = 200
          Top = 76
          Width = 141
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Cathode'
          ParentColor = True
          TabOrder = 23
        end
        object PanAliStatusR: TPanel
          Left = 200
          Top = 98
          Width = 141
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Reserve'
          ParentColor = True
          TabOrder = 24
        end
        object BuAliUpdateN2: TButton
          Left = 540
          Top = 54
          Width = 89
          Height = 20
          Caption = 'Update settings'
          TabOrder = 25
          OnClick = BuAliUpdateN2Click
        end
        object BuAliUpdateC: TButton
          Left = 540
          Top = 76
          Width = 89
          Height = 20
          Caption = 'Update settings'
          TabOrder = 26
          OnClick = BuAliUpdateCClick
        end
        object BuAliUpdateR: TButton
          Left = 540
          Top = 98
          Width = 89
          Height = 20
          Caption = 'Update settings'
          TabOrder = 27
          OnClick = BuAliUpdateRClick
        end
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 132
        Width = 769
        Height = 65
        Caption = 'Alicat Aquire Thread Status'
        TabOrder = 10
        object Label11: TLabel
          Left = 368
          Top = 24
          Width = 64
          Height = 20
          AutoSize = False
          Caption = 'Last aquired: '
        end
        object Label13: TLabel
          Left = 8
          Top = 24
          Width = 30
          Height = 20
          AutoSize = False
          Caption = 'Status'
        end
        object Label23: TLabel
          Left = 208
          Top = 24
          Width = 73
          Height = 20
          AutoSize = False
          Caption = 'Active Devices'
        end
        object BuAliThreadStart: TButton
          Left = 584
          Top = 16
          Width = 73
          Height = 30
          Caption = 'Thread Start'
          TabOrder = 0
          OnClick = BuAliThreadStartClick
        end
        object BuAliThreadStop: TButton
          Left = 672
          Top = 16
          Width = 89
          Height = 30
          Caption = 'Thread Stop'
          TabOrder = 1
          OnClick = BuAliThreadStopClick
        end
        object PanAliThreadStatus: TPanel
          Left = 42
          Top = 24
          Width = 151
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Anode Flow'
          ParentColor = True
          TabOrder = 2
        end
        object PanAliNDevs: TPanel
          Left = 290
          Top = 24
          Width = 55
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Anode Flow'
          ParentColor = True
          TabOrder = 3
        end
        object Panel4: TPanel
          Left = 432
          Top = 24
          Width = 113
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Anode Flow'
          ParentColor = True
          TabOrder = 4
        end
      end
      object PanAliPort: TPanel
        Left = 58
        Top = 42
        Width = 95
        Height = 20
        BorderStyle = bsSingle
        Caption = 'Panel'
        ParentColor = True
        TabOrder = 11
      end
      object PanAliBaudRate: TPanel
        Left = 58
        Top = 66
        Width = 95
        Height = 20
        BorderStyle = bsSingle
        Caption = 'Panel'
        ParentColor = True
        TabOrder = 12
      end
      object PanAliOKCnt: TPanel
        Left = 712
        Top = 25
        Width = 73
        Height = 20
        BorderStyle = bsSingle
        Caption = 'Panel'
        ParentColor = True
        TabOrder = 13
      end
      object PanAliErrCnt: TPanel
        Left = 712
        Top = 5
        Width = 73
        Height = 20
        BorderStyle = bsSingle
        Caption = 'Panel'
        ParentColor = True
        TabOrder = 14
      end
      object ChkAliSetpCompatibMode: TCheckBox
        Left = 272
        Top = 8
        Width = 249
        Height = 20
        Caption = 'Alicat COMPATIBILTY setpoint mode'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 15
        OnClick = ChkAliSetpCompatibModeClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Dummy Flow'
      ImageIndex = 1
      object chkDumNoise: TCheckBox
        Left = 8
        Top = 8
        Width = 97
        Height = 17
        Caption = 'Enable Noise'
        TabOrder = 0
        OnClick = ChkDumNoiseClick
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Flow via FCS Control'
      ImageIndex = 2
      object PanelSheet3: TPanel
        Left = 0
        Top = 0
        Width = 785
        Height = 357
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object Button4: TButton
    Left = 696
    Top = 672
    Width = 97
    Height = 33
    Caption = 'Hide'
    TabOrder = 7
    OnClick = ButtonHideClick
  end
  object Button5: TButton
    Left = 352
    Top = 672
    Width = 97
    Height = 33
    Caption = 'Hide'
    TabOrder = 8
    OnClick = ButtonHideClick
  end
  object Button6: TButton
    Left = 8
    Top = 8
    Width = 65
    Height = 25
    Caption = 'Hide'
    TabOrder = 9
    OnClick = ButtonHideClick
  end
  object RefreshTimer: TTimer
    OnTimer = RefreshTimerTimer
    Left = 576
    Top = 8
  end
end

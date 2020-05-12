object FormValveControl: TFormValveControl
  Left = 291
  Top = 78
  Caption = 'ValveControl'
  ClientHeight = 722
  ClientWidth = 1018
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
  object Label7: TLabel
    Left = 104
    Top = 8
    Width = 142
    Height = 20
    Caption = 'Module selection'
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
  object CBSelectControl: TComboBox
    Left = 256
    Top = 5
    Width = 209
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemIndex = 0
    ParentFont = False
    TabOrder = 0
    Text = 'TCPIP-FCSControl'
    Items.Strings = (
      'TCPIP-FCSControl'
      'Dummy')
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 40
    Width = 793
    Height = 377
    Caption = 'Simple status and control of selected module'
    TabOrder = 1
    object Label20: TLabel
      Left = 600
      Top = 50
      Width = 177
      Height = 25
      AutoSize = False
      Caption = 'Name of Active Interface:'
      Layout = tlCenter
    end
    object Label11: TLabel
      Left = 608
      Top = 192
      Width = 177
      Height = 20
      AutoSize = False
      Caption = 'Aquire time metric: (ms)'
    end
    object ChkControlReady: TCheckBox
      Left = 616
      Top = 10
      Width = 129
      Height = 20
      Caption = 'Control is Ready'
      Enabled = False
      TabOrder = 0
    end
    object BuMainConnect: TButton
      Left = 608
      Top = 106
      Width = 81
      Height = 25
      Caption = 'Connect'
      TabOrder = 1
      OnClick = BuMainConnectClick
    end
    object BuMainDiscon: TButton
      Left = 704
      Top = 106
      Width = 81
      Height = 25
      Caption = 'Disconnect'
      TabOrder = 2
      OnClick = BuMainDisconClick
    end
    object SGDevices: TStringGrid
      Left = 8
      Top = 16
      Width = 585
      Height = 345
      Color = clMoneyGreen
      DefaultColWidth = 70
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 60
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
      TabOrder = 3
      ColWidths = (
        70
        70
        70
        70
        70)
    end
    object ChkControlDummy: TCheckBox
      Left = 616
      Top = 26
      Width = 113
      Height = 20
      Caption = 'Control is Dummy'
      Enabled = False
      TabOrder = 4
    end
    object PanControlName: TPanel
      Left = 600
      Top = 74
      Width = 185
      Height = 25
      BorderStyle = bsSingle
      Caption = 'Panel'
      ParentColor = True
      TabOrder = 5
    end
    object GroupBox5: TGroupBox
      Left = 600
      Top = 240
      Width = 185
      Height = 105
      Caption = 'Pressure Regulator Control'
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 6
      object Label3: TLabel
        Left = 10
        Top = 18
        Width = 41
        Height = 20
        AutoSize = False
        Caption = 'Device'
        Layout = tlCenter
      end
      object Label4: TLabel
        Left = 72
        Top = 18
        Width = 73
        Height = 20
        AutoSize = False
        Caption = 'New Setpoint'
        Layout = tlCenter
      end
      object Panel1: TPanel
        Left = 10
        Top = 42
        Width = 60
        Height = 20
        BorderStyle = bsSingle
        Caption = 'R1'
        ParentColor = True
        TabOrder = 0
      end
      object EMainR1SetP: TEdit
        Left = 72
        Top = 42
        Width = 57
        Height = 21
        TabOrder = 1
        Text = '0'
      end
      object BuMainR1Setp: TButton
        Left = 136
        Top = 42
        Width = 41
        Height = 20
        Caption = 'Set SP'
        TabOrder = 2
        OnClick = BuMainR1SetpClick
      end
      object BuMainR1SetZero: TButton
        Left = 80
        Top = 66
        Width = 97
        Height = 20
        Caption = 'Set Zero'
        TabOrder = 3
      end
    end
    object Button1: TButton
      Left = 624
      Top = 144
      Width = 105
      Height = 25
      Caption = 'Tmp enable dev'
      TabOrder = 7
      OnClick = Button1Click
    end
    object PanControlTimeAq: TPanel
      Left = 608
      Top = 208
      Width = 169
      Height = 20
      BorderStyle = bsSingle
      Caption = '---'
      ParentColor = True
      TabOrder = 8
    end
    object Button3: TButton
      Left = 624
      Top = 168
      Width = 105
      Height = 25
      Caption = 'Disable all dev'
      TabOrder = 9
      OnClick = Button3Click
    end
    object Button7: TButton
      Left = 744
      Top = 160
      Width = 33
      Height = 33
      Caption = 'En Sx'
      TabOrder = 10
      OnClick = Button7Click
    end
    object chkEnableSendMFC: TCheckBox
      Left = 618
      Top = 351
      Width = 152
      Height = 14
      Caption = 'chkEnableSendMFC'
      TabOrder = 11
      OnClick = chkEnableSendMFCClick
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
  end
  object ERefreshIntv: TEdit
    Left = 640
    Top = 8
    Width = 57
    Height = 21
    TabOrder = 4
    Text = '1000'
  end
  object Button2: TButton
    Left = 8
    Top = 668
    Width = 97
    Height = 33
    Caption = 'Hide'
    TabOrder = 5
    OnClick = Button2Click
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 428
    Width = 793
    Height = 237
    ActivePage = TabSheet1
    TabOrder = 6
    object TabSheet1: TTabSheet
      Caption = 'TCPIP Interface to FCS Control'
      object GroupBox1: TGroupBox
        Left = 5
        Top = 156
        Width = 770
        Height = 53
        Caption = 'Thread Status'
        TabOrder = 0
        object Label13: TLabel
          Left = 8
          Top = 24
          Width = 30
          Height = 20
          AutoSize = False
          Caption = 'Status'
        end
        object Label23: TLabel
          Left = 240
          Top = 24
          Width = 49
          Height = 20
          AutoSize = False
          Caption = 'Devices'
        end
        object Label5: TLabel
          Left = 360
          Top = 24
          Width = 65
          Height = 20
          AutoSize = False
          Caption = 'Last aquired'
        end
        object BuFCSThreadStart: TButton
          Left = 592
          Top = 16
          Width = 73
          Height = 30
          Caption = 'Thread Start'
          TabOrder = 0
          OnClick = BuFCSThreadStartClick
        end
        object BuFCSThreadStop: TButton
          Left = 672
          Top = 16
          Width = 89
          Height = 30
          Caption = 'Thread Stop'
          TabOrder = 1
          OnClick = BuFCSThreadStopClick
        end
        object PanFCSThreadStatus: TPanel
          Left = 42
          Top = 24
          Width = 175
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Anode Flow'
          ParentColor = True
          TabOrder = 2
        end
        object PanFCSNDevs: TPanel
          Left = 290
          Top = 24
          Width = 55
          Height = 20
          BorderStyle = bsSingle
          ParentColor = True
          TabOrder = 3
        end
        object PanFCSLastAq: TPanel
          Left = 432
          Top = 24
          Width = 145
          Height = 20
          BorderStyle = bsSingle
          ParentColor = True
          TabOrder = 4
        end
      end
      object GroupBox3: TGroupBox
        Left = 5
        Top = 0
        Width = 770
        Height = 81
        Caption = 'TCP CLient Configuration'
        TabOrder = 1
        object Label12: TLabel
          Left = 8
          Top = 21
          Width = 49
          Height = 20
          AutoSize = False
          Caption = 'Server:'
        end
        object Label16: TLabel
          Left = 208
          Top = 21
          Width = 46
          Height = 20
          AutoSize = False
          Caption = 'Port'
        end
        object LaFCSstatus: TLabel
          Left = 8
          Top = 48
          Width = 505
          Height = 25
          Alignment = taCenter
          AutoSize = False
          Caption = 'LaFCSstatus'
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clLime
          Font.Height = -21
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Label2: TLabel
          Left = 640
          Top = 29
          Width = 52
          Height = 20
          AutoSize = False
          Caption = 'Error count'
        end
        object Label22: TLabel
          Left = 648
          Top = 13
          Width = 45
          Height = 20
          AutoSize = False
          Caption = 'OK count'
        end
        object EFCSserver: TEdit
          Left = 48
          Top = 21
          Width = 153
          Height = 21
          TabOrder = 0
          Text = '195.113.25.103'
          OnChange = EFCSserverChange
        end
        object EFCSport: TEdit
          Left = 240
          Top = 21
          Width = 65
          Height = 21
          TabOrder = 1
          Text = '20005'
          OnChange = EFCSportChange
        end
        object BuFCSUpdate: TButton
          Left = 312
          Top = 21
          Width = 113
          Height = 20
          Caption = 'Update/Reconnect'
          TabOrder = 2
          OnClick = BuFCSUpdateClick
        end
        object ChkFCSPortOpened: TCheckBox
          Left = 432
          Top = 21
          Width = 97
          Height = 20
          Caption = 'Connected'
          Enabled = False
          TabOrder = 3
        end
        object buFCSOpenPort: TButton
          Left = 544
          Top = 13
          Width = 81
          Height = 20
          Caption = 'Open Port'
          TabOrder = 4
          OnClick = buFCSOpenPortClick
        end
        object buFCSCloseport: TButton
          Left = 544
          Top = 37
          Width = 81
          Height = 20
          Caption = 'ClosePort'
          TabOrder = 5
          OnClick = buFCSCloseportClick
        end
        object PanFCSErrCnt: TPanel
          Left = 691
          Top = 29
          Width = 73
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Panel'
          ParentColor = True
          TabOrder = 6
        end
        object PanFCSOKCnt: TPanel
          Left = 691
          Top = 13
          Width = 73
          Height = 20
          BorderStyle = bsSingle
          Caption = 'Panel'
          ParentColor = True
          TabOrder = 7
        end
        object buFCSResetCnt: TButton
          Left = 691
          Top = 53
          Width = 73
          Height = 20
          Caption = 'Reset Cnts'
          TabOrder = 8
          OnClick = buFCSResetCntClick
        end
      end
      object GroupBox4: TGroupBox
        Left = 5
        Top = 80
        Width = 770
        Height = 73
        Caption = 'User Command'
        TabOrder = 2
        object Label15: TLabel
          Left = 8
          Top = 16
          Width = 49
          Height = 13
          Caption = 'User CMD'
        end
        object LaFCSUserCmdTime: TLabel
          Left = 353
          Top = 16
          Width = 152
          Height = 20
          AutoSize = False
          Caption = 'User CMD'
        end
        object Label17: TLabel
          Left = 8
          Top = 40
          Width = 48
          Height = 13
          Caption = 'Response'
        end
        object EFCSUserCmd: TEdit
          Left = 56
          Top = 16
          Width = 217
          Height = 21
          TabOrder = 0
          Text = 'A'
        end
        object BuFCSSendCMD: TButton
          Left = 280
          Top = 16
          Width = 65
          Height = 20
          Caption = 'Send'
          TabOrder = 1
          OnClick = BuFCSSendCMDClick
        end
        object EFCSUserCmdReply: TEdit
          Left = 56
          Top = 40
          Width = 705
          Height = 21
          Enabled = False
          TabOrder = 2
        end
        object chkFCSdebug: TCheckBox
          Left = 656
          Top = 16
          Width = 105
          Height = 20
          Caption = 'Debug Enabled'
          TabOrder = 3
          OnClick = chkFCSdebugClick
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Dummy Control'
      ImageIndex = 1
      object chkDumNoise: TCheckBox
        Left = 8
        Top = 8
        Width = 97
        Height = 17
        Caption = 'Enable Noise'
        TabOrder = 0
      end
    end
  end
  object Button4: TButton
    Left = 704
    Top = 668
    Width = 97
    Height = 33
    Caption = 'Hide'
    TabOrder = 7
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 360
    Top = 668
    Width = 97
    Height = 33
    Caption = 'Hide'
    TabOrder = 8
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 8
    Top = 8
    Width = 65
    Height = 25
    Caption = 'Hide'
    TabOrder = 9
    OnClick = Button6Click
  end
  object RefreshTimer: TTimer
    OnTimer = RefreshTimerTimer
    Left = 576
    Top = 8
  end
end

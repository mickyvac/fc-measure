object LoggerForm: TLoggerForm
  Left = 396
  Top = 208
  Width = 982
  Height = 696
  Caption = 'LoggerForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    966
    658)
  PixelsPerInch = 96
  TextHeight = 13
  object PCLog: TPageControl
    Left = 1
    Top = 40
    Width = 972
    Height = 582
    ActivePage = TabReport
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    RaggedRight = True
    TabOrder = 0
    object TabProjectLog: TTabSheet
      Caption = 'Project Log'
      DesignSize = (
        964
        547)
      object MeProjLog: TMemo
        Left = 1
        Top = 1
        Width = 959
        Height = 496
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object Button2: TButton
        Left = 112
        Top = 506
        Width = 89
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Test'
        TabOrder = 1
        OnClick = Button2Click
      end
      object BuClearProj: TButton
        Left = 0
        Top = 506
        Width = 105
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Clear'
        TabOrder = 2
        OnClick = BuClearProjClick
      end
    end
    object TabWarningLog: TTabSheet
      Caption = 'Warning Messages'
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 964
        Height = 547
        Align = alClient
        TabOrder = 0
        DesignSize = (
          964
          547)
        object MeWarningLog: TMemo
          Left = 5
          Top = 3
          Width = 954
          Height = 496
          Anchors = [akLeft, akTop, akRight, akBottom]
          ScrollBars = ssBoth
          TabOrder = 0
        end
        object BuClearWarning: TButton
          Left = 8
          Top = 506
          Width = 105
          Height = 33
          Anchors = [akLeft, akBottom]
          Caption = 'Clear'
          TabOrder = 1
          OnClick = BuClearWarningClick
        end
        object BuResetWarning: TButton
          Left = 715
          Top = 508
          Width = 209
          Height = 33
          Anchors = [akRight, akBottom]
          Caption = 'Reset Warning Counter'
          TabOrder = 2
          OnClick = BuResetWarningClick
        end
        object PanWarningCount: TPanel
          Left = 587
          Top = 508
          Width = 81
          Height = 30
          Anchors = [akRight, akBottom]
          Caption = '---'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
        end
        object Button1: TButton
          Left = 120
          Top = 506
          Width = 89
          Height = 33
          Anchors = [akLeft, akBottom]
          Caption = 'Test'
          TabOrder = 4
          OnClick = Button1Click
        end
        object Button4: TButton
          Left = 224
          Top = 508
          Width = 73
          Height = 33
          Anchors = [akLeft, akBottom]
          Caption = 'Button4'
          TabOrder = 5
          OnClick = Button4Click
        end
        object Button9: TButton
          Left = 219
          Top = 506
          Width = 209
          Height = 33
          Anchors = [akRight, akBottom]
          Caption = 'Reset Warning Counter'
          TabOrder = 6
          OnClick = BuResetWarningClick
        end
      end
    end
    object TabErrorLog: TTabSheet
      Caption = 'ERROR Messages'
      ImageIndex = 2
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 964
        Height = 547
        Align = alClient
        Caption = 'Panel1'
        Color = clRed
        TabOrder = 0
        DesignSize = (
          964
          547)
        object MeERRORlog: TMemo
          Left = 5
          Top = 9
          Width = 954
          Height = 491
          Anchors = [akLeft, akTop, akRight, akBottom]
          ScrollBars = ssBoth
          TabOrder = 0
        end
        object BuClearError: TButton
          Left = 8
          Top = 506
          Width = 105
          Height = 33
          Anchors = [akLeft, akBottom]
          Caption = 'Clear'
          TabOrder = 1
          OnClick = BuClearErrorClick
        end
        object PanErrorCount: TPanel
          Left = 451
          Top = 508
          Width = 81
          Height = 30
          Anchors = [akRight, akBottom]
          Caption = '---'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object BuResetError: TButton
          Left = 579
          Top = 508
          Width = 209
          Height = 33
          Anchors = [akRight, akBottom]
          Caption = 'Reset Error Counter'
          TabOrder = 3
          OnClick = BuResetErrorClick
        end
        object Button3: TButton
          Left = 120
          Top = 506
          Width = 89
          Height = 33
          Anchors = [akLeft, akBottom]
          Caption = 'Test'
          TabOrder = 4
          OnClick = Button3Click
        end
        object Button6: TButton
          Left = 139
          Top = 506
          Width = 209
          Height = 33
          Anchors = [akRight, akBottom]
          Caption = 'Reset Error Counter'
          TabOrder = 5
          OnClick = BuResetErrorClick
        end
      end
    end
    object TabReport: TTabSheet
      Caption = 'RESULTS Report'
      ImageIndex = 3
      DesignSize = (
        964
        547)
      object MeReport: TMemo
        Left = 5
        Top = 9
        Width = 954
        Height = 491
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object Button5: TButton
    Left = 5
    Top = 5
    Width = 137
    Height = 30
    Caption = 'Hide'
    TabOrder = 1
    OnClick = BuHideClick
  end
  object BuHide: TButton
    Left = 827
    Top = 5
    Width = 137
    Height = 30
    Anchors = [akTop, akRight]
    Caption = 'Hide'
    TabOrder = 2
    OnClick = BuHideClick
  end
  object Button7: TButton
    Left = 5
    Top = 625
    Width = 137
    Height = 30
    Anchors = [akLeft, akBottom]
    Caption = 'Hide'
    TabOrder = 3
    OnClick = BuHideClick
  end
  object Button8: TButton
    Left = 832
    Top = 625
    Width = 137
    Height = 30
    Anchors = [akRight, akBottom]
    Caption = 'Hide'
    TabOrder = 4
    OnClick = BuHideClick
  end
end

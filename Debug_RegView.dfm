object FormRegView: TFormRegView
  Left = 470
  Top = 244
  Caption = 'RegView'
  ClientHeight = 618
  ClientWidth = 1126
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CheckBox1: TCheckBox
    Left = 856
    Top = 72
    Width = 121
    Height = 17
    Caption = 'Refresh Enable'
    TabOrder = 0
    OnClick = CheckBox1Click
  end
  object Edit1: TEdit
    Left = 896
    Top = 224
    Width = 121
    Height = 21
    Color = clMenuHighlight
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 944
    Top = 304
    Width = 89
    Height = 33
    Caption = 'attach'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit2: TEdit
    Left = 864
    Top = 312
    Width = 73
    Height = 21
    TabOrder = 3
    Text = 'Edit1Value'
  end
  object Edit3: TEdit
    Left = 856
    Top = 392
    Width = 73
    Height = 21
    Color = clScrollBar
    TabOrder = 4
    Text = 'Edit3'
    TextHint = 'GASDJKSGDKJDASGDJKD'
  end
  object Button2: TButton
    Left = 944
    Top = 392
    Width = 57
    Height = 25
    Caption = 'change value'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 1056
    Top = 384
    Width = 33
    Height = 41
    Caption = 'Commit'
    TabOrder = 6
  end
  object Edit4: TEdit
    Left = 864
    Top = 480
    Width = 121
    Height = 21
    TabOrder = 7
    Text = 'Edit4'
  end
  object PageControl1: TPageControl
    Left = 16
    Top = 8
    Width = 762
    Height = 537
    ActivePage = HW
    TabOrder = 8
    object TabSheet1: TTabSheet
      Caption = 'CommonData'
      object Memo2: TMemo
        Left = 16
        Top = 8
        Width = 721
        Height = 489
        Lines.Strings = (
          'Memo2')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object HW: TTabSheet
      Caption = 'HW'
      ImageIndex = 1
      object Memo1: TMemo
        Left = 3
        Top = 9
        Width = 734
        Height = 497
        Lines.Strings = (
          'Memo1')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 856
    Top = 32
  end
end

object NewProjectForm: TNewProjectForm
  Left = 282
  Top = 63
  Width = 940
  Height = 262
  Caption = 'NewProjectForm'
  Color = clCream
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 64
    Top = 48
    Width = 97
    Height = 22
    AutoSize = False
    Caption = 'New directory name:'
  end
  object Label3: TLabel
    Left = 24
    Top = 88
    Width = 43
    Height = 22
    AutoSize = False
    Caption = 'Full path:'
  end
  object Label4: TLabel
    Left = 536
    Top = 136
    Width = 65
    Height = 22
    AutoSize = False
    Caption = 'Label4'
  end
  object Label1: TLabel
    Left = 32
    Top = 8
    Width = 111
    Height = 22
    AutoSize = False
    Caption = 'Type new project name'
  end
  object Label5: TLabel
    Left = 336
    Top = 192
    Width = 334
    Height = 13
    Caption = 
      'Verify all path reference with .\ !!!! and to change to absolu t' +
      'e app path'
  end
  object BuCancel: TButton
    Left = 66
    Top = 140
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = BuCancelClick
  end
  object BuCreateContinue: TButton
    Left = 200
    Top = 120
    Width = 297
    Height = 65
    Caption = 'Create directory and Continue'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = BuCreateContinueClick
  end
  object BuNewPath: TButton
    Left = 546
    Top = 44
    Width = 129
    Height = 25
    Caption = 'Select new path manualy'
    TabOrder = 2
    OnClick = BuNewPathClick
  end
  object EName: TEdit
    Left = 152
    Top = 9
    Width = 593
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    Text = 'Unspecified'
    OnChange = ENameChange
  end
  object PanAutoDirectory: TPanel
    Left = 183
    Top = 49
    Width = 340
    Height = 22
    BorderStyle = bsSingle
    Caption = 'Pan'
    Color = clWhite
    TabOrder = 4
  end
  object PanFullPath: TPanel
    Left = 87
    Top = 89
    Width = 596
    Height = 22
    BorderStyle = bsSingle
    Caption = 'Pan'
    Color = clWhite
    TabOrder = 5
  end
  object Button1: TButton
    Left = -110
    Top = 132
    Width = 89
    Height = 25
    Caption = 'Reset to defaults'
    TabOrder = 6
    OnClick = Button1Click
  end
  object RBAutomatic: TRadioButton
    Left = -118
    Top = 12
    Width = 113
    Height = 17
    Caption = 'Automatic'
    TabOrder = 7
    OnClick = RBAutomaticClick
  end
  object RBManual: TRadioButton
    Left = -118
    Top = 28
    Width = 113
    Height = 17
    Caption = 'Manual selection'
    TabOrder = 8
    OnClick = RBManualClick
  end
  object Button2: TButton
    Left = 770
    Top = 4
    Width = 129
    Height = 25
    Caption = 'Copy to clipboard'
    TabOrder = 9
    OnClick = Button2Click
  end
  object NFSaveDialog: TSaveDialog
    InitialDir = 'ggg'
    Left = 712
    Top = 80
  end
end

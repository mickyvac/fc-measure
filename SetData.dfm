object SetDataForm: TSetDataForm
  Left = 1638
  Top = 120
  Caption = 'Batching'
  ClientHeight = 760
  ClientWidth = 1098
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = SetBlockKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 216
    Width = 54
    Height = 13
    Caption = 'Current unit'
  end
  object Label2: TLabel
    Left = 24
    Top = 240
    Width = 56
    Height = 13
    Caption = 'Voltage unit'
  end
  object Label3: TLabel
    Left = 24
    Top = 264
    Width = 43
    Height = 13
    Caption = 'Time unit'
  end
  object Label4: TLabel
    Left = 8
    Top = 314
    Width = 78
    Height = 13
    Caption = 'Min. voltage limit'
  end
  object Label5: TLabel
    Left = 144
    Top = 314
    Width = 21
    Height = 13
    Caption = '[mV]'
  end
  object Label6: TLabel
    Left = 8
    Top = 288
    Width = 70
    Height = 13
    Caption = 'Num. of cycles'
  end
  object Button1: TButton
    Left = 88
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Add F4'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ScrollBox1: TScrollBox
    Left = 168
    Top = 0
    Width = 804
    Height = 655
    HorzScrollBar.Increment = 180
    VertScrollBar.Visible = False
    TabOrder = 1
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 800
      Height = 330
    end
  end
  object Button2: TButton
    Left = 8
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Delete !'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Insert L F2'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 88
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Insert R F3'
    TabOrder = 4
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 24
    Top = 184
    Width = 97
    Height = 17
    Caption = 'Conected lines'
    Checked = True
    State = cbChecked
    TabOrder = 5
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 24
    Top = 200
    Width = 97
    Height = 17
    Caption = 'Ramp at the end'
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = CheckBox2Click
  end
  object CUnit: TComboBox
    Left = 88
    Top = 216
    Width = 65
    Height = 21
    Style = csDropDownList
    TabOrder = 7
    OnChange = CUnitChange
  end
  object VUnit: TComboBox
    Left = 88
    Top = 240
    Width = 65
    Height = 21
    Style = csDropDownList
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    OnChange = VUnitChange
  end
  object TUnit: TComboBox
    Left = 88
    Top = 264
    Width = 65
    Height = 21
    Style = csDropDownList
    TabOrder = 9
    OnChange = TUnitChange
  end
  object Edit1: TEdit
    Left = 88
    Top = 312
    Width = 57
    Height = 21
    TabOrder = 10
    Text = 'Edit1'
    OnChange = Edit1Change
  end
  object Cycling: TSpinEdit
    Left = 88
    Top = 288
    Width = 65
    Height = 22
    MaxValue = 2
    MinValue = 1
    TabOrder = 11
    Value = 1
    OnChange = CyclingChange
  end
  object OpenButton: TButton
    Left = 0
    Top = 0
    Width = 41
    Height = 25
    Caption = 'Open'
    TabOrder = 12
    OnClick = OpenButtonClick
  end
  object SaveAsButton: TButton
    Left = 120
    Top = 0
    Width = 51
    Height = 25
    Caption = 'Save As'
    TabOrder = 13
    OnClick = SaveAsButtonClick
  end
  object SaveButton: TButton
    Left = 72
    Top = 0
    Width = 49
    Height = 25
    Caption = 'Save'
    TabOrder = 14
    OnClick = SaveButtonClick
  end
  object Button5: TButton
    Left = 0
    Top = 679
    Width = 169
    Height = 17
    Caption = 'Help and about'
    TabOrder = 16
    OnClick = Button5Click
  end
  object ClearButton: TButton
    Left = 40
    Top = 0
    Width = 41
    Height = 25
    Caption = 'Clear'
    TabOrder = 15
    OnClick = ClearButtonClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 216
    Top = 576
  end
  object OpenDialog1: TOpenDialog
    Left = 128
    Top = 640
  end
  object SaveDialog1: TSaveDialog
    Left = 96
    Top = 640
  end
end

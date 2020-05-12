object Form1: TForm1
  Left = 435
  Top = 137
  Caption = 'Form1'
  ClientHeight = 616
  ClientWidth = 948
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 16
    Top = 35
    Width = 793
    Height = 569
    Caption = 'Panel1'
    TabOrder = 0
    object ComboBox1: TComboBox
      Left = 265
      Top = 18
      Width = 145
      Height = 21
      TabOrder = 0
      Text = 'Chart Type'
      Items.Strings = (
        'Time view'
        'Polarization'
        'User selection')
    end
    object Button5: TButton
      Left = 424
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Config plot...'
      TabOrder = 1
    end
    object Panel3: TPanel
      Left = 239
      Top = 45
      Width = 538
      Height = 508
      Caption = 'Panel3'
      TabOrder = 2
    end
    object PageCtrlSelect: TPageControl
      Left = 0
      Top = 16
      Width = 233
      Height = 545
      ActivePage = TabActive
      TabOrder = 3
      object TabActive: TTabSheet
        Caption = 'Active Project'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object TreeView2: TTreeView
          Left = 3
          Top = 37
          Width = 153
          Height = 337
          Indent = 19
          MultiSelect = True
          TabOrder = 0
          Items.NodeData = {
            0303000000220000000000000000000000FFFFFFFFFFFFFFFF00000000000000
            0001000000010241004100220000000100000000000000FFFFFFFFFFFFFFFF00
            0000000000000000000000010261006100220000000000000000000000FFFFFF
            FFFFFFFFFF000000000000000002000000010242004200220000000000000000
            000000FFFFFFFFFFFFFFFF000000000000000001000000010262006200280000
            000000000000000000FFFFFFFFFFFFFFFF000000000000000000000000010562
            006200620062006400240000000000000000000000FFFFFFFFFFFFFFFF000000
            0000000000000000000103620062007600220000000000000000000000FFFFFF
            FFFFFFFFFF000000000000000003000000010243004300260000000000000000
            000000FFFFFFFFFFFFFFFF000000000000000001000000010463006300630063
            00280000000000000000000000FFFFFFFFFFFFFFFF0000000000000000000000
            00010563006300630063006300260000000000000000000000FFFFFFFFFFFFFF
            FF00000000000000000000000001046300630063006400280000000000000000
            000000FFFFFFFFFFFFFFFF000000000000000000000000010563006300630063
            006600}
        end
        object Button8: TButton
          Left = 162
          Top = 37
          Width = 25
          Height = 33
          Caption = 'Add'
          TabOrder = 1
        end
      end
      object TabSheet1: TTabSheet
        Caption = 'Browse files...'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object TreeView1: TTreeView
          Left = 14
          Top = 45
          Width = 153
          Height = 337
          Indent = 19
          MultiSelect = True
          TabOrder = 0
          Items.NodeData = {
            0303000000220000000000000000000000FFFFFFFFFFFFFFFF00000000000000
            0001000000010241004100220000000100000000000000FFFFFFFFFFFFFFFF00
            0000000000000000000000010261006100220000000000000000000000FFFFFF
            FFFFFFFFFF000000000000000002000000010242004200220000000000000000
            000000FFFFFFFFFFFFFFFF000000000000000001000000010262006200280000
            000000000000000000FFFFFFFFFFFFFFFF000000000000000000000000010562
            006200620062006400240000000000000000000000FFFFFFFFFFFFFFFF000000
            0000000000000000000103620062007600220000000000000000000000FFFFFF
            FFFFFFFFFF000000000000000003000000010243004300260000000000000000
            000000FFFFFFFFFFFFFFFF000000000000000001000000010463006300630063
            00280000000000000000000000FFFFFFFFFFFFFFFF0000000000000000000000
            00010563006300630063006300260000000000000000000000FFFFFFFFFFFFFF
            FF00000000000000000000000001046300630063006400280000000000000000
            000000FFFFFFFFFFFFFFFF000000000000000000000000010563006300630063
            006600}
        end
        object Button2: TButton
          Left = 173
          Top = 93
          Width = 25
          Height = 33
          Caption = 'Add'
          TabOrder = 1
        end
        object Button7: TButton
          Left = 14
          Top = 6
          Width = 81
          Height = 25
          Caption = 'Open Project'
          TabOrder = 2
        end
        object Button3: TButton
          Left = 14
          Top = 388
          Width = 75
          Height = 25
          Caption = 'Open Folder'
          TabOrder = 3
        end
        object Button4: TButton
          Left = 94
          Top = 6
          Width = 75
          Height = 25
          Caption = 'Open File'
          TabOrder = 4
        end
      end
      object PSelection: TTabSheet
        Caption = 'Selection'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object CheckListBox2: TCheckListBox
          Left = 3
          Top = 3
          Width = 145
          Height = 313
          ItemHeight = 13
          TabOrder = 0
        end
        object Button6: TButton
          Left = 172
          Top = 37
          Width = 25
          Height = 33
          Caption = 'Rem'
          TabOrder = 1
        end
      end
    end
  end
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 57
    Height = 25
    Caption = 'Create'
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 736
    Top = 8
    Width = 249
    Height = 177
    Caption = 'Panel2'
    TabOrder = 2
    object Label1: TLabel
      Left = 32
      Top = 8
      Width = 59
      Height = 13
      Caption = 'select X axis'
    end
    object Label2: TLabel
      Left = 136
      Top = 8
      Width = 59
      Height = 13
      Caption = 'select Y axis'
    end
    object CheckListBox1: TCheckListBox
      Left = 16
      Top = 32
      Width = 97
      Height = 129
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object Button9: TButton
    Left = 104
    Top = 16
    Width = 49
    Height = 17
    Caption = 'Button9'
    TabOrder = 3
    OnClick = Button9Click
  end
end

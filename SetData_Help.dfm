object SetData_Help: TSetData_Help
  Left = 509
  Top = 190
  Width = 384
  Height = 620
  Caption = 'Batching - Help'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 315
    Height = 13
    Caption = 
      'Program for preparation batch file for meassuring cell character' +
      'istic.'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 40
    Top = 40
    Width = 258
    Height = 13
    Caption = '(c) 2010   Roman Fiala         romandotfiala@gmail.com,'
  end
  object Label3: TLabel
    Left = 88
    Top = 56
    Width = 211
    Height = 13
    Caption = 'Michal Vaclavu   michal.vaclavu@gmail.com'
  end
  object Memo1: TMemo
    Left = 24
    Top = 88
    Width = 321
    Height = 49
    BevelEdges = []
    BevelInner = bvNone
    BevelKind = bkSoft
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      
        'Files are used in program for obtaining Volt-Amper Charakteristi' +
        'c of '
      'Fule Cell.')
    ReadOnly = True
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 24
    Top = 128
    Width = 329
    Height = 457
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuHighlight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'Use  "Add" or F4 for adding next databox at the end.'
      
        'Use "Insert L" or F2 for adding next databox to the left of sele' +
        'cted '
      'databox.'
      'Use "Insert R" or F2 for adding next databox to the right of '
      'selected databox.'
      ''
      
        'In peration above is coppied contens of themplate databox (in th' +
        'e '
      'left) to the new databox. '
      ''
      'Use "Delete" button or press key "Delete" in textline in active '
      'databox for deleting active databox.'
      'Use "OnClick" (single click) for selecting a databox.'
      'Use "OnDblClilck" (double click) for copping contens to the '
      'themplate. The selection is included in double clicking.'
      ''
      'Buttons "Open", "Save" and "SaveAs" are easy used for opening '
      'and saving your batching stack which is represented with '
      'databoxes. They are easy for use.'
      ''
      
        'In individual databox can be chosen type of feedback  (curren or' +
        ' '
      'voltaget) and type of process. In other words, If you want hold '
      
        'same value or run a sweep with use a concrete step in value ot i' +
        'n '
      'time.'
      'It can be chosen sweep ended with "-" and instead of "|". It is '
      'controled by checbox "Ramp at the end".'
      'Checkbox "Connected lines" permits the conecting lines from '
      'naigboring databoxes with dashed lines.'
      ''
      'The plotting cancas arein relative units.'
      
        'In the horizontal direction is time. The time interval is limite' +
        'd '
      'databox width for each one databox.  '
      
        'In the vertical direction is unit of value (current or voltage) ' +
        'which is '
      'use for feedback. Blue means current and red means voltage.')
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
end

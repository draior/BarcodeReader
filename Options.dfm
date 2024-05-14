object fOptions: TfOptions
  Left = 584
  Top = 290
  BorderStyle = bsToolWindow
  Caption = 'Настройки'
  ClientHeight = 173
  ClientWidth = 264
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 119
    Height = 26
    Caption = 'Начален ACSII номер'#13#10'на бар-код поредицата:'
  end
  object Label2: TLabel
    Left = 8
    Top = 42
    Width = 119
    Height = 26
    Caption = 'Краен ASCII  номер'#13#10'на бар-код поредицата:'
  end
  object Label3: TLabel
    Left = 8
    Top = 78
    Width = 121
    Height = 26
    Caption = 'Честота м\у символите'#13#10'в [ms]:'
  end
  object cbRepeatFreq: TComboBox
    Left = 160
    Top = 80
    Width = 97
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object btnSave: TButton
    Left = 160
    Top = 109
    Width = 97
    Height = 25
    Caption = 'Запомни'
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 160
    Top = 139
    Width = 97
    Height = 25
    Caption = 'Откажи'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object cbShowOnLoad: TCheckBox
    Left = 5
    Top = 110
    Width = 151
    Height = 21
    Caption = 'Показвай при зареждане'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    OnClick = cbShowOnLoadClick
  end
  object cbAsciiCode_Start: TComboBox
    Left = 160
    Top = 10
    Width = 97
    Height = 21
    ItemHeight = 13
    TabOrder = 4
  end
  object cbAsciiCode_End: TComboBox
    Left = 160
    Top = 45
    Width = 97
    Height = 21
    ItemHeight = 13
    TabOrder = 5
  end
end

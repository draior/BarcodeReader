object fOptions: TfOptions
  Left = 584
  Top = 290
  BorderStyle = bsToolWindow
  Caption = '���������'
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
    Caption = '������� ACSII �����'#13#10'�� ���-��� ����������:'
  end
  object Label2: TLabel
    Left = 8
    Top = 42
    Width = 119
    Height = 26
    Caption = '����� ASCII  �����'#13#10'�� ���-��� ����������:'
  end
  object Label3: TLabel
    Left = 8
    Top = 78
    Width = 121
    Height = 26
    Caption = '������� �\� ���������'#13#10'� [ms]:'
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
    Caption = '�������'
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 160
    Top = 139
    Width = 97
    Height = 25
    Caption = '������'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object cbShowOnLoad: TCheckBox
    Left = 5
    Top = 110
    Width = 151
    Height = 21
    Caption = '�������� ��� ���������'
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

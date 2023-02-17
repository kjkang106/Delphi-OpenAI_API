object FOpenAITest: TFOpenAITest
  Left = 0
  Top = 0
  Caption = 'FOpenAITest'
  ClientHeight = 618
  ClientWidth = 1044
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ImgOne: TImage
    Left = 8
    Top = 87
    Width = 512
    Height = 512
    Stretch = True
    OnMouseDown = ImgOneMouseDown
  end
  object Label1: TLabel
    Left = 8
    Top = 43
    Width = 49
    Height = 13
    Caption = 'Image File'
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 43
    Height = 13
    Caption = 'Mask File'
  end
  object LbImageFile: TLabel
    Left = 96
    Top = 43
    Width = 49
    Height = 13
    Caption = 'Image File'
  end
  object LbMaskFile: TLabel
    Left = 96
    Top = 64
    Width = 43
    Height = 13
    Caption = 'Mask File'
  end
  object MemoLog: TMemo
    Left = 526
    Top = 255
    Width = 512
    Height = 344
    TabOrder = 12
  end
  object BtCreateImage: TButton
    Left = 194
    Top = 8
    Width = 96
    Height = 25
    Caption = 'CreateImage'
    TabOrder = 3
    OnClick = BtCreateImageClick
  end
  object CbImgList: TComboBox
    Left = 375
    Top = 10
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    OnChange = CbImgListChange
  end
  object BtLoadImage: TButton
    Left = 526
    Top = 8
    Width = 75
    Height = 25
    Caption = 'LoadImage'
    TabOrder = 5
    OnClick = BtLoadImageClick
  end
  object CbImgSize: TComboBox
    Left = 56
    Top = 10
    Width = 73
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = '256'
    Items.Strings = (
      '256'
      '512'
      '1024')
  end
  object EtImgCnt: TSpinEdit
    Left = 8
    Top = 10
    Width = 41
    Height = 22
    MaxValue = 10
    MinValue = 1
    TabOrder = 0
    Value = 1
  end
  object CbImgRetFmt: TComboBox
    Left = 135
    Top = 10
    Width = 50
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = 'URL'
    Items.Strings = (
      'URL'
      'BIN')
  end
  object MemoPrompt: TMemo
    Left = 526
    Top = 87
    Width = 512
    Height = 162
    Lines.Strings = (
      'A cute baby sea otter')
    TabOrder = 11
  end
  object BtImageEdit: TButton
    Left = 679
    Top = 8
    Width = 96
    Height = 25
    Caption = 'ImageEdit'
    TabOrder = 7
    OnClick = BtImageEditClick
  end
  object BtImageVariation: TButton
    Left = 776
    Top = 8
    Width = 96
    Height = 25
    Caption = 'ImageVariation'
    TabOrder = 8
    OnClick = BtImageVariationClick
  end
  object BtMakeMask: TButton
    Left = 601
    Top = 8
    Width = 75
    Height = 25
    Caption = 'MakeMask'
    TabOrder = 6
    OnClick = BtMakeMaskClick
  end
  object BtCompletion: TButton
    Left = 940
    Top = 8
    Width = 96
    Height = 25
    Caption = 'Completion'
    TabOrder = 10
    OnClick = BtCompletionClick
  end
  object EtMaxToken: TSpinEdit
    Left = 878
    Top = 10
    Width = 59
    Height = 22
    MaxValue = 2048
    MinValue = 1
    TabOrder = 9
    Value = 60
  end
  object BtClearImgMask: TButton
    Left = 57
    Top = 62
    Width = 26
    Height = 19
    Caption = 'X'
    TabOrder = 13
    OnClick = BtClearImgMaskClick
  end
end

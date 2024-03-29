object FOpenAITest: TFOpenAITest
  Left = 0
  Top = 0
  ActiveControl = MemoPrompt
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
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ImgOne: TImage
    Left = 8
    Top = 87
    Width = 512
    Height = 512
    Stretch = True
    OnDblClick = ImgOneDblClick
    OnMouseDown = ImgOneMouseDown
    OnMouseMove = ImgOneMouseMove
    OnMouseUp = ImgOneMouseUp
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
    Width = 424
    Height = 13
    AutoSize = False
    Caption = 'Image File'
  end
  object LbMaskFile: TLabel
    Left = 96
    Top = 64
    Width = 424
    Height = 13
    AutoSize = False
    Caption = 'Mask File'
  end
  object Label3: TLabel
    Left = 526
    Top = 39
    Width = 33
    Height = 13
    Caption = 'Models'
  end
  object Label4: TLabel
    Left = 677
    Top = 39
    Width = 52
    Height = 13
    Caption = 'Max Token'
  end
  object Label5: TLabel
    Left = 767
    Top = 39
    Width = 62
    Height = 13
    Caption = 'Temperature'
  end
  object Label6: TLabel
    Left = 858
    Top = 39
    Width = 30
    Height = 13
    Caption = 'Top_p'
  end
  object Label7: TLabel
    Left = 526
    Top = 88
    Width = 21
    Height = 13
    Caption = 'Role'
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
    Top = 136
    Width = 512
    Height = 113
    Lines.Strings = (
      'A cute baby sea otter')
    TabOrder = 11
  end
  object BtImageEdit: TButton
    Left = 845
    Top = 8
    Width = 96
    Height = 25
    Caption = 'ImageEdit'
    TabOrder = 8
    OnClick = BtImageEditClick
  end
  object BtImageVariation: TButton
    Left = 942
    Top = 8
    Width = 96
    Height = 25
    Caption = 'ImageVariation'
    TabOrder = 9
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
    Left = 942
    Top = 56
    Width = 96
    Height = 25
    Caption = 'Completion'
    TabOrder = 19
    OnClick = BtCompletionClick
  end
  object EtMaxToken: TSpinEdit
    Left = 677
    Top = 58
    Width = 59
    Height = 22
    MaxValue = 2048
    MinValue = 1
    TabOrder = 10
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
  object CbModels: TComboBox
    Left = 526
    Top = 58
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 14
    OnChange = CbModelsChange
    Items.Strings = (
      'GPT-4'
      'GPT-3.5-Turbo'
      'Davinci'
      'Curie'
      'Babbage'
      'Ada')
  end
  object EtTemperature: TEdit
    Left = 767
    Top = 59
    Width = 59
    Height = 21
    MaxLength = 3
    TabOrder = 15
    Text = '0'
  end
  object EtTopP: TEdit
    Left = 858
    Top = 59
    Width = 59
    Height = 21
    MaxLength = 3
    TabOrder = 16
    Text = '1.0'
  end
  object EtMaskSize: TSpinEdit
    Left = 681
    Top = 10
    Width = 41
    Height = 22
    MaxValue = 50
    MinValue = 1
    TabOrder = 7
    Value = 5
  end
  object BtListModels: TButton
    Left = 942
    Top = 32
    Width = 96
    Height = 25
    Caption = 'ListModels'
    TabOrder = 18
    OnClick = BtListModelsClick
  end
  object BtChatCompletion: TButton
    Left = 942
    Top = 80
    Width = 96
    Height = 25
    Caption = 'ChatCompletion'
    TabOrder = 20
    OnClick = BtChatCompletionClick
  end
  object EtRole: TEdit
    Left = 553
    Top = 85
    Width = 118
    Height = 21
    MaxLength = 20
    TabOrder = 17
    Text = 'user'
  end
  object BtTranscription: TButton
    Left = 845
    Top = 105
    Width = 96
    Height = 25
    Caption = 'Transcription'
    TabOrder = 21
    OnClick = BtTranscriptionClick
  end
  object BtTranslation: TButton
    Left = 942
    Top = 105
    Width = 96
    Height = 25
    Caption = 'Translation'
    TabOrder = 22
    OnClick = BtTranslationClick
  end
end

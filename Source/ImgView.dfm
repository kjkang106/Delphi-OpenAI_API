object FImgView: TFImgView
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'FImgView'
  ClientHeight = 338
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ImgOne: TImage
    Left = 0
    Top = 0
    Width = 651
    Height = 338
    Align = alClient
    AutoSize = True
    Stretch = True
    OnDblClick = ImgOneDblClick
    OnMouseDown = ImgOneMouseDown
    ExplicitLeft = 112
    ExplicitTop = 80
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
end
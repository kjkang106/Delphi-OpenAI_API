object FProgressDlg: TFProgressDlg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'FProgressDlg'
  ClientHeight = 161
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object LbTxt: TLabel
    Left = 25
    Top = 48
    Width = 350
    Height = 36
    Alignment = taCenter
    AutoSize = False
    Caption = 'LbTxt'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object ProgressBar1: TProgressBar
    Left = 25
    Top = 104
    Width = 350
    Height = 28
    Smooth = True
    Style = pbstMarquee
    TabOrder = 0
  end
end

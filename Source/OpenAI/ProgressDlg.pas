unit ProgressDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFProgressDlg = class(TForm)
    ProgressBar1: TProgressBar;
    LbTxt: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FProgressDlg: TFProgressDlg;

procedure ShowProgDlg(Msg: string);
procedure HideProgDlg;

implementation

uses ToneDown;

{$R *.dfm}

procedure ShowProgDlg(Msg: string);
begin
  HideProgDlg;

  FToneDown:= OpenToneDown(Application.MainForm);

  FProgressDlg:= TFProgressDlg.Create(nil);
  FProgressDlg.LbTxt.Caption:= Msg;
  FProgressDlg.Show;
end;

procedure HideProgDlg;
begin
  if FToneDown <> nil then
  begin
    CloseToneDown(FToneDown);
    FTonedown:= nil;
  end;

  if FProgressDlg <> nil then
  begin
    FProgressDlg.Close;
    FProgressDlg:= nil;
  end;
end;

procedure TFProgressDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TFProgressDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((ssAlt in shift) and (Key = VK_F4)) then
    Key := 0;
end;

end.

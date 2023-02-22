unit ImgView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFImgView = class(TForm)
    ImgOne: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImgOneDblClick(Sender: TObject);
    procedure ImgOneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure StartDrag(hWnd: HWND);
  public
    { Public declarations }
  end;

var
  FImgView: TFImgView;

procedure PopImgView(AOwner: TWinControl; ImgFileName: string);

implementation

{$R *.dfm}

procedure PopImgView(AOwner: TWinControl; ImgFileName: string);
begin
  if FImgView <> nil then
  begin
    FImgView.Free;
    FImgView:= nil;
  end;

  if not FileExists(ImgFileName) then
    Exit;

  FImgView:= TFImgView.Create(AOwner);
  try
    FImgView.ImgOne.Picture.LoadFromFile(ImgFileName);
  except
  end;

  if FImgView.ImgOne.Picture <> nil then
  begin
    FImgView.ClientHeight:= FImgView.ImgOne.Picture.Height;
    FImgView.ClientWidth := FImgView.ImgOne.Picture.Width;
    FImgView.Left:= ((AOwner.Width  - FImgView.Width ) div 2) + AOwner.Left;
    FImgView.Top := ((AOwner.Height - FImgView.Height) div 2) + AOwner.Top;
    FImgView.Show;
  end
  else
  begin
    FImgView.Free;
    FImgView:= nil;
  end;
end;

procedure TFImgView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TFImgView.FormDestroy(Sender: TObject);
begin
  FImgView:= nil;
end;

procedure TFImgView.ImgOneDblClick(Sender: TObject);
begin
  Close;
end;

procedure TFImgView.ImgOneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StartDrag(Self.Handle);
end;

procedure TFImgView.StartDrag(hWnd: HWND);
const
  SC_DRAGMOVE = $F012;
begin
  ReleaseCapture;
  SendMessage(hWnd, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
end;

end.

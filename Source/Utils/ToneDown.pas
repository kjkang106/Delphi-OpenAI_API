unit ToneDown;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TFToneDown = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FToneDown: TFToneDown;

function OpenToneDown(MForm: TForm): TFTonedown;
procedure CloseToneDown(FTonedown: TFTonedown);

implementation

{$R *.dfm}

function OpenToneDown(MForm: TForm): TFTonedown;
begin
  if MForm = nil then
    Exit(nil);

  Result:= TFTonedown.Create(MForm);

  Result.Left  := MForm.Left;
  Result.Top   := MForm.Top;
  Result.Width := MForm.Width;
  Result.Height:= MForm.Height;
  Result.Show;
end;

procedure CloseToneDown(FTonedown: TFTonedown);
begin
  if FTonedown = nil then
    Exit;
  FTonedown.Close;
end;

procedure TFToneDown.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TFToneDown.FormCreate(Sender: TObject);
begin
  AlphaBlend:= True;
  AlphaBlendValue:= 64;
  BorderStyle:= bsNone;
end;

end.

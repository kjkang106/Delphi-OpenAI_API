unit PNGImgUtil;

interface

uses
  Windows, Graphics, ExtCtrls, pngimage;

procedure LoadPngImage(ImgFileName: string; Image: TImage);
function  PngHasAlpha(ImgFileName: string): Boolean;

function  PngAddMaskStart (Image: TImage): Boolean;
procedure PngAddMaskEnd   (Image: TImage);
procedure PngAddMaskRegion(Image: TImage; ARect: TRect);

implementation

procedure LoadPngImage(ImgFileName: string; Image: TImage);
begin
  Image.Picture.LoadFromFile(ImgFileName);
  TPngImage(Image.Picture.Graphic).CreateAlpha;
end;

function PngHasAlpha(ImgFileName: string): Boolean;
var
  PngImage: TPngImage;
begin
  Result:= False;

  PngImage:= TPngImage.Create;
  try
    PngImage.LoadFromFile(ImgFileName);
    Result:= (PngImage.Header.ColorType = COLOR_GRAYSCALEALPHA) or
             (PngImage.Header.ColorType = COLOR_RGBALPHA);
  finally
    PngImage.Free;
  end;
end;

function GetRGBLinePixel(const png: TPngImage; const X, Y: Integer): TColor;
begin
  with pRGBLine(png.Scanline[Y])^[X] do
    Result:= RGB(rgbtRed, rgbtGreen, rgbtBlue);
end;

procedure SetRGBLinePixel(const png: TPngImage; const X, Y: Integer; Value: TColor);
begin
  with pRGBLine(png.Scanline[Y])^[X] do
  begin
    rgbtRed  := GetRValue(Value);
    rgbtGreen:= GetGValue(Value);
    rgbtBlue := GetBValue(Value)
  end;
end;

function PngAddMaskStart(Image: TImage): Boolean;
var
  PngImage: TPngImage;
begin
  try
    PngImage:= TPngImage(Image.Picture.Graphic);
  except
    Exit(False);
  end;

  Result:= True;
  Image.Parent.DoubleBuffered:= True;
end;

procedure PngAddMaskEnd(Image: TImage);
begin
  try
    TPngImage(Image.Picture.Graphic).Modified:= True;
  except
  end;
  Image.Parent.DoubleBuffered:= False;
end;

procedure PngAddMaskRegion(Image: TImage; ARect: TRect);
var
  ZoomRate: Double;
  PngImage: TPngImage;
  pScanline: pRGBLine;
  Y, X: Integer;
begin
  try
    PngImage:= TPngImage(Image.Picture.Graphic);
  except
    Exit;
  end;

  if PngImage.Width <> Image.Width then
  begin
    ZoomRate:= PngImage.Width / Image.Width;
    ARect.Left  := Trunc(ARect.Left   * ZoomRate);
    ARect.Top   := Trunc(ARect.Top    * ZoomRate);
    ARect.Right := Trunc(ARect.Right  * ZoomRate);
    ARect.Bottom:= Trunc(ARect.Bottom * ZoomRate);
  end;

  for Y:= 0 to PngImage.Height - 1 do
  begin
    if (Y >= ARect.Top) and (Y < ARect.Bottom) then
    begin
      for X:= 0 to PngImage.Width - 1 do
      begin
        if (X >= ARect.Left) and (X < ARect.Right) then
        begin
          SetRGBLinePixel(PngImage, X, Y, clWhite);
          pByteArray(PngImage.AlphaScanline[Y])^[X]:= 0;
        end;
      end;
    end;
  end;
  PngImage.Modified:= True;
end;

end.

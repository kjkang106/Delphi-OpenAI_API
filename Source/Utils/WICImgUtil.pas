unit WICImgUtil;

interface

uses
  SysUtils, Classes, Graphics, EncdDecd, ExtCtrls, pngimage;

function StrmToFile(Strm: TStream; ImgDir: string; var ImgFile: string): Boolean;
procedure LoadWicImage(ImgFileName: string; Image: TImage);

function IsValidImageProp(ImgFileName: string; AlphaCheck: Boolean): Boolean;

function BJsonToImg(bStr, ImgDir: string; var ImgFile: string): Boolean;
function ImgToBJSon(ImgDir, ImgFile: string; var bStr: AnsiString): Boolean;

implementation

function StrmToFile(Strm: TStream; ImgDir: string; var ImgFile: string): Boolean;
var
  WICImage: TWICImage;
  ImgExt: string;
begin
  Result:= False;
  ImgDir:= IncludeTrailingPathDelimiter(ImgDir);
  ForceDirectories(ImgDir);
  if FileExists(ImgDir + ImgFile) then
    DeleteFile(ImgDir + ImgFile);

  WICImage:= TWICImage.Create;
  try
    WICImage.LoadFromStream(Strm);
    if not WICImage.Empty then
    begin
      case WICImage.ImageFormat of
        wifBmp    : ImgExt:= '.bmp';
        wifPng    : ImgExt:= '.png';
        wifJpeg   : ImgExt:= '.jpg';
        wifGif    : ImgExt:= '.gif';
        wifTiff   : ImgExt:= '.tiff';
        wifWMPhoto: ImgExt:= '.wdp';
        wifOther  : ImgExt:= '';
      end;
      ImgFile:= ImgFile + ImgExt;
      WICImage.SaveToFile(ImgDir + ImgFile);
      Result:= FileExists(ImgDir + ImgFile);
    end;
  finally
    WICImage.Free;
  end;
end;

procedure LoadWicImage(ImgFileName: string; Image: TImage);
var
  WICImage: TWICImage;
begin
  WICImage:= TWICImage.Create;
  try
    WICImage.LoadFromFile(ImgFileName);
    Image.Picture.Bitmap.Assign(WICImage);
  finally
    WICImage.Free;
  end;
end;

function IsValidImageProp(ImgFileName: string; AlphaCheck: Boolean): Boolean;
var
  WICImage: TWICImage;
  PngImage: TPngImage;
begin
  WICImage:= TWICImage.Create;
  try
    WICImage.LoadFromFile(ImgFileName);
    Result:= (WICImage.ImageFormat = wifPng) and
             (WICImage.Width = WICImage.Height);
    if not Result then
      Exit;
  finally
    WICImage.Free;
  end;

  if AlphaCheck then
  begin
    PngImage:= TPngImage.Create;
    try
      PngImage.LoadFromFile(ImgFileName);
      Result:= (PngImage.Header.ColorType = COLOR_GRAYSCALEALPHA) or
               (PngImage.Header.ColorType = COLOR_RGBALPHA);
    finally
      PngImage.Free;
    end;
  end;
end;

function BJsonToImg(bStr, ImgDir: string; var ImgFile: string): Boolean;
var
  strIn : TStringStream;
  strOut: TMemoryStream;
begin
  Result:= False;

  strIn := TStringStream.Create(bStr);
  strOut:= TMemoryStream.Create;
  try
    DecodeStream(strIn, strOut);
    Result:= StrmToFile(strOut, ImgDir, ImgFile);
  finally
    strOut.Free;
    strIn.Free;
  end;
end;

function ImgToBJSon(ImgDir, ImgFile: string; var bStr: AnsiString): Boolean;
var
  strIn : TFileStream;
  strOut: TStringStream;
begin
  Result:= False;
  bStr:= '';

  ImgDir:= IncludeTrailingPathDelimiter(ImgDir);
  if not FileExists(ImgDir + ImgFile) then
    Exit;

  strIn := TFileStream.Create(ImgDir + ImgFile, fmOpenRead or fmShareDenyWrite);
  strOut:= TStringStream.Create;
  try
    if strIn.Size > 0 then
    begin
      EncodeStream(strIn, strOut);

      bStr:= strOut.DataString;
      Result:= True;
    end;
  finally
    strOut.Free;
    strIn.Free;
  end;
end;

end.

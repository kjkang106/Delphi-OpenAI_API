unit OpenAIHeader;

interface

const
  OPEN_AI_URL       = 'https://api.openai.com';
  IMG_CREATE_URL    = 'v1/images/generations';
  IMG_EDIT_URL      = 'v1/images/edits';
  IMG_VARIATION_URL = 'v1/images/variations';
  MAX_IMG_DESC      = 1000;
  MAX_IMG_SIZE      = 4194304;   //4MB = 4 * 1024 * 1024

type
  TAiImgSize   = (ais256, ais512, ais1024);
  TAiImgResFmt = (airfUrl, airfB64Json);

function AisToStr(AiImgSize: TAiImgSize): string;
function IntToAis(Idx: Integer): TAiImgSize;

function AirfToStr(AiImgResFmt: TAiImgResFmt): string;
function IntToAirf(Idx: Integer): TAiImgResFmt;

implementation

function AisToStr(AiImgSize: TAiImgSize): string;
begin
  case AiImgSize of
    ais256:  Result:= '256x256';
    ais512:  Result:= '512x512';
    ais1024: Result:= '1024x1024';
    else
      Result:= '';
  end;
end;

function IntToAis(Idx: Integer): TAiImgSize;
begin
  if (Idx < 0) or (Idx > Ord(ais1024)) then
    Exit(ais256);

  Result:= TAiImgSize(Idx);
end;

function AirfToStr(AiImgResFmt: TAiImgResFmt): string;
begin
  case AiImgResFmt of
    airfUrl    : Result:= 'url';
    airfB64Json: Result:= 'b64_json';
    else
      Result:= '';
  end;
end;

function IntToAirf(Idx: Integer): TAiImgResFmt;
begin
  if (Idx < 0) or (Idx > Ord(airfB64Json)) then
    Exit(airfUrl);

  Result:= TAiImgResFmt(Idx);
end;

end.

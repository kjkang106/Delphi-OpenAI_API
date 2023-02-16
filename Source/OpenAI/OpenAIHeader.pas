unit OpenAIHeader;

interface

const
  OPEN_AI_URL        = 'https://api.openai.com';
  IMG_CREATE_URL     = 'v1/images/generations';
  IMG_EDIT_URL       = 'v1/images/edits';
  IMG_VARIATION_URL  = 'v1/images/variations';
  COMPLETION_URL     = 'v1/completions';

  MAX_IMG_DESC       = 1000;
  MAX_IMG_SIZE       = 4194304;   //4MB = 4 * 1024 * 1024

  LASTEST_MODEL_Davinci = 'text-davinci-003';       //Complex intent, cause and effect, summarization for audience
  LASTEST_MODEL_Curie   = 'text-curie-001';         //Language translation, complex classification, text sentiment, summarization
  LASTEST_MODEL_Babbage = 'text-babbage-001';       //Moderate classification, semantic search classification
  LASTEST_MODEL_Ada     = 'text-ada-001';           //Parsing text, simple classification, address correction, keywords
  LASTEST_MODEL_GPT3    = LASTEST_MODEL_Davinci;

  LASTEST_MODEL_Codex   = 'code-davinci-002';       //public code from GitHub
  LASTEST_MODEL_Filter  = 'content-filter-alpha';

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

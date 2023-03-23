unit OpenAIHeader;

interface

const
  OPEN_AI_URL        = 'https://api.openai.com';
  IMG_CREATE_URL     = 'v1/images/generations';
  IMG_EDIT_URL       = 'v1/images/edits';
  IMG_VARIATION_URL  = 'v1/images/variations';
  COMPLETION_URL     = 'v1/completions';
  CHAT_COMPLE_URL    = 'v1/chat/completions';
  MODEL_LIST_URL     = 'v1/models';
  STT_TRANSCRIPT_URL = 'v1/audio/transcriptions';
  STT_TRANSLATE_URL  = 'v1/audio/translations';

  MAX_IMG_DESC       = 1000;
  MAX_IMG_SIZE       = 4194304;   //4MB = 4 * 1024 * 1024
  MAX_AUDIO_SIZE     = 26214400;  //25MB

  LASTEST_MODEL_Davinci = 'text-davinci-003';       //Complex intent, cause and effect, summarization for audience
  LASTEST_MODEL_Curie   = 'text-curie-001';         //Language translation, complex classification, text sentiment, summarization
  LASTEST_MODEL_Babbage = 'text-babbage-001';       //Moderate classification, semantic search classification
  LASTEST_MODEL_Ada     = 'text-ada-001';           //Parsing text, simple classification, address correction, keywords
  LASTEST_MODEL_GPT3    = LASTEST_MODEL_Davinci;

  MAIN_MODEL_GPT3_5     = 'gpt-3.5-turbo';
  LASTEST_MODEL_GPT3_5  = MAIN_MODEL_GPT3_5;

  MAIN_MODEL_GPT4       = 'gpt-4';
  LONGER_MODEL_GPT4     = 'gpt-4-32k';
  LASTEST_MODEL_GPT4    = MAIN_MODEL_GPT4;

  LASTEST_MODEL_Codex   = 'code-davinci-002';       //public code from GitHub
  LASTEST_MODEL_Filter  = 'content-filter-alpha';

  LASTEST_MODEL_STT     = 'whisper-1';

type
  TAiImgSize   = (ais256, ais512, ais1024);
  TAiImgResFmt = (airfUrl, airfB64Json);
  TAiModel     = (aimVer40, aimVer35, aimDav, aimCur, aimBab, aimAda);
  TAiSttFile   = (asfMp3, asfMp4, asfMpeg, asfMpga, asfM4a, asfWav, asfWebm);
  TAiSttResFmt = (asrfJson, asrfText, asrfSrt, asrfVJson, asrfVtt);

function AisToStr(AiImgSize: TAiImgSize): string;
function IntToAis(Idx: Integer): TAiImgSize;

function AirfToStr(AiImgResFmt: TAiImgResFmt): string;
function IntToAirf(Idx: Integer): TAiImgResFmt;

function AimToStr(AiModel: TAiModel): string;
function IntToAim(Idx: Integer): TAiModel;

function AsfToFileExt(AiSttFile: TAiSttFile): string;
function AsrfToStr(AiSttResFmt: TAiSttResFmt): string;

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

function AimToStr(AiModel: TAiModel): string;
begin
  case AiModel of
    aimVer40: Result:= LASTEST_MODEL_GPT4;
    aimVer35: Result:= LASTEST_MODEL_GPT3_5;
    aimDav  : Result:= LASTEST_MODEL_Davinci;
    aimCur  : Result:= LASTEST_MODEL_Curie;
    aimBab  : Result:= LASTEST_MODEL_Babbage;
    aimAda  : Result:= LASTEST_MODEL_Ada;
  end;
end;

function IntToAim(Idx: Integer): TAiModel;
begin
  if (Idx < 0) or (Idx > Ord(High(TAiModel))) then
    Exit(aimDav);

  Result:= TAiModel(Idx);
end;

function AsfToFileExt(AiSttFile: TAiSttFile): string;
begin
  case AiSttFile of
    asfMp3:  Result:= '.mp3';
    asfMp4:  Result:= '.mp4';
    asfMpeg: Result:= '.mpeg';
    asfMpga: Result:= '.mpga';
    asfM4a:  Result:= '.m4a';
    asfWav:  Result:= '.wav';
    asfWebm: Result:= '.webm';
    else
      Result:= '';
  end;
end;

function AsrfToStr(AiSttResFmt: TAiSttResFmt): string;
begin
  case AiSttResFmt of
    asrfJson:  Result:= 'json';
    asrfText:  Result:= 'text';
    asrfSrt:   Result:= 'srt';
    asrfVJson: Result:= 'verbose_json';
    asrfVtt:   Result:= 'vtt';
    else
      Result:= '';
  end;
end;

end.

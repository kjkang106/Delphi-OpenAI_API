unit OpenAIStt;

interface

uses
  Classes, SysUtils, OpenAIHeader, OpenAI, DBXJSON, StrUtil, HTTPApp;

type
  TOpenAIStt = class(TOpenAI)
  private
    FPrompt           : string;
    FResFmt           : TAiSttResFmt;
    FTemperature      : TJSONValue;
    FLanguage         : TJSONValue;

    FRltText          : string;

    function MakeSendDocTranscription(AFile, AModel: string;
      var zFormData: TStringArray; out OutStr: string): Boolean;
    procedure ParseTranscription(RecvObj: TJSONObject);

    function MakeSendDocTranslation(AFile, AModel: string;
      var zFormData: TStringArray; out OutStr: string): Boolean;
    procedure ParseTranslation(RecvObj: TJSONObject);

    function GetValidProp(AFile, AModel: string; out OutStr: string): Boolean;
    function IsValidAsfFile(FileExt: string): Boolean;
    function GetLanguage: string;
    function GetTemperature: Double;
    procedure SetLanguage(const Value: string);
    procedure SetTemperature(const Value: Double);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Init_All;
    function CreateTranscription(AFile, AModel: string): string;
    function CreateTranslation(AFile, AModel: string): string;

    property Prompt     : string        read FPrompt              write FPrompt             ;
    property ResFmt     : TAiSttResFmt  read FResFmt              write FResFmt             default asrfJson;
    property Temperature: Double        read GetTemperature       write SetTemperature      ;
    property Language   : string        read GetLanguage          write SetLanguage         ;

    property RltText    : string        read FRltText             write FRltText            ;
  end;

implementation

uses JSonUtil;


{ TOpenAIStt }

constructor TOpenAIStt.Create;
begin
  inherited;

  Init_All;
end;

function TOpenAIStt.CreateTranscription(AFile, AModel: string): string;
var
  AUrl: string;
  OutStr: string;
  zFormData: TStringArray;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  RltText:= '';;
  AUrl:= OPEN_AI_URL + '/' + STT_TRANSCRIPT_URL;

  if not MakeSendDocTranscription(AFile, AModel, zFormData, OutStr) then
  begin
    Result:= OutStr;
    Exit;
  end;
  JsonStr:= SendFormData(AUrl, zFormData);

  if JsonStr <> '' then
  begin
    try
      try
        RecvObj:= TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
        if RecvObj <> nil then
        begin
          if ParseErrMsg(RecvObj, OutStr) then
          begin
            Result:= 'FAIL' + sLineBreak + OutStr;
            Exit;
          end;
          Result:= 'OK';
          ParseTranscription(RecvObj);
        end
        else
          Result:= 'FAIL' + sLineBreak + JsonStr;
      finally
        RecvObj.Free;
        RecvObj:= nil;
      end;
    except
      on E: Exception do
      begin
        Result:= 'FAIL' + sLineBreak + E.Message;
      end;
    end;
  end
  else
    Result:= 'FAIL: Returned Empty';
end;

function TOpenAIStt.CreateTranslation(AFile, AModel: string): string;
var
  AUrl: string;
  OutStr: string;
  zFormData: TStringArray;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  RltText:= '';;
  AUrl:= OPEN_AI_URL + '/' + STT_TRANSLATE_URL;

  if not MakeSendDocTranslation(AFile, AModel, zFormData, OutStr) then
  begin
    Result:= OutStr;
    Exit;
  end;
  JsonStr:= SendFormData(AUrl, zFormData);

  if JsonStr <> '' then
  begin
    try
      try
        RecvObj:= TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
        if RecvObj <> nil then
        begin
          if ParseErrMsg(RecvObj, OutStr) then
          begin
            Result:= 'FAIL' + sLineBreak + OutStr;
            Exit;
          end;
          Result:= 'OK';
          ParseTranslation(RecvObj);
        end
        else
          Result:= 'FAIL' + sLineBreak + JsonStr;
      finally
        RecvObj.Free;
        RecvObj:= nil;
      end;
    except
      on E: Exception do
      begin
        Result:= 'FAIL' + sLineBreak + E.Message;
      end;
    end;
  end
  else
    Result:= 'FAIL: Returned Empty';
end;

destructor TOpenAIStt.Destroy;
begin
  FTemperature.Free;
  FLanguage.Free;

  inherited;
end;

function TOpenAIStt.GetLanguage: string;
begin
  if FLanguage is TJSONNull then
    Result:= ''
  else
    Result:= TJSONString(FLanguage).Value;
end;

function TOpenAIStt.GetTemperature: Double;
begin
  if FTemperature is TJSONNull then
    Result:= 0
  else
    Result:= TJSONNumber(FTemperature).AsDouble;
end;

function TOpenAIStt.GetValidProp(AFile, AModel: string;
  out OutStr: string): Boolean;
var
  F: File;
  nSize: Integer;
begin
  Result:= False;
  if not FileExists(AFile) then
  begin
    OutStr:= 'Invalid file';
    Exit;
  end;
  if not IsValidAsfFile(ExtractFileExt(AFile)) then
  begin
    OutStr:= 'Invalid file extension';
    Exit;
  end;

  AssignFile(F, AFile);
  Reset(F);
  try
    nSize:= FileSize(F);
  finally
    CloseFile(F);
  end;
  if nSize > MAX_AUDIO_SIZE then
  begin
    OutStr:= 'Less than 25MB';
    Exit;
  end;

  if AModel = LASTEST_MODEL_STT then
  else
  begin
    OutStr:= 'Invalid Model';
    Exit;
  end;

  if (Temperature < 0) or (Temperature > 1) then
  begin
    OutStr:= 'Invalid Temperature';
    Exit;
  end;

  Result:= True;
end;

procedure TOpenAIStt.Init_All;
begin
  FPrompt           := '';
  FTemperature      := TJSONNull.Create;
  FLanguage         := TJSONNull.Create;

  FRltText          := '';
end;

function TOpenAIStt.IsValidAsfFile(FileExt: string): Boolean;
var
  AiSttFile: TAiSttFile;
begin
  Result:= False;
  for AiSttFile:= Low(TAiSttFile) to High(TAiSttFile) do
  begin
    if CompareText(FileExt, AsfToFileExt(AiSttFile)) = 0 then
      Exit(True);
  end;
end;

function TOpenAIStt.MakeSendDocTranscription(AFile, AModel: string;
  var zFormData: TStringArray; out OutStr: string): Boolean;
var
  idx: Integer;
  procedure AddFormParam(FieldName, FileValue: string);
  begin
    Inc(idx);
    SetLength(zFormData, idx + 1);
    zFormData[idx]:= FieldName + '=' + FileValue;
  end;
begin
  Result:= False;
  if not GetValidProp(AFile, AModel, OutStr) then
    Exit;

  Result:= True;
  idx:= -1;

  AddFormParam('file'           , '@' + AFile);
  AddFormParam('model'          , AModel);
  AddFormParam('prompt'         , HTTPEncode(SimpleEscapeJsonParamStr(Prompt)));
  AddFormParam('response_format', AsrfToStr(ResFmt));
  if not(FTemperature is TJSONNull) then
    AddFormParam('temperature'    , FloatToStr(Temperature));
  if not(FLanguage is TJSONNull) then
    AddFormParam('language'       , Language);
  if user_IDs <> '' then
    AddFormParam('user'           , user_IDs);
end;

function TOpenAIStt.MakeSendDocTranslation(AFile, AModel: string;
  var zFormData: TStringArray; out OutStr: string): Boolean;
var
  idx: Integer;
  procedure AddFormParam(FieldName, FileValue: string);
  begin
    Inc(idx);
    SetLength(zFormData, idx + 1);
    zFormData[idx]:= FieldName + '=' + FileValue;
  end;
begin
  Result:= False;
  if not GetValidProp(AFile, AModel, OutStr) then
    Exit;

  Result:= True;
  idx:= -1;

  AddFormParam('file'           , '@' + AFile);
  AddFormParam('model'          , AModel);
  AddFormParam('prompt'         , HTTPEncode(SimpleEscapeJsonParamStr(Prompt)));
  AddFormParam('response_format', AsrfToStr(ResFmt));
  if not(FTemperature is TJSONNull) then
    AddFormParam('temperature'    , FloatToStr(Temperature));
  if user_IDs <> '' then
    AddFormParam('user'           , user_IDs);
end;

procedure TOpenAIStt.ParseTranscription(RecvObj: TJSONObject);
begin
  FRltText:= GetJsonStr(RecvObj, 'text');
  try
    FRltText:= HTTPDecode(FRltText);
  except
  end;
end;

procedure TOpenAIStt.ParseTranslation(RecvObj: TJSONObject);
begin
  FRltText:= GetJsonStr(RecvObj, 'text');
  try
    FRltText:= HTTPDecode(FRltText);
  except
  end;
end;

procedure TOpenAIStt.SetLanguage(const Value: string);
begin
  FLanguage.Free;
  FLanguage:= TJSONString.Create(Value);
end;

procedure TOpenAIStt.SetTemperature(const Value: Double);
begin
  FTemperature.Free;
  FTemperature:= TJSONNumber.Create(Value);
end;

end.

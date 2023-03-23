unit OpenAIImg;

interface

uses
  Classes, SysUtils, OpenAIHeader, OpenAI, DBXJSON, StrUtil, HTTPApp;

type
  TOpenAIImgPrc = (aipCreate, aipEdit, aipVari);
  TOpenAIImg = class(TOpenAI)
  private
    FOpenAIImgPrc: TOpenAIImgPrc;

    FImgCount: Integer;
    FImgSize : TAiImgSize;
    FResFmt  : TAiImgResFmt;

    FImgDir  : string;
    FImgMask : string;
    FzImgList: TStringList;

    procedure Init_List;
    function MakeSendDocCreateImages(APrompt: string;
      var SendObj: TJSONObject; out OutStr: string): Boolean;
    function MakeSendDocCreateImageEdit(ImgFileName, APrompt: string;
      var zFormData: TStringArray; out OutStr: string): Boolean;
    function MakeSendDocCreateImageVariation(ImgFileName: string;
      var zFormData: TStringArray; out OutStr: string): Boolean;

    procedure ParseImgList(RecvObj: TJSONObject);

    function  GetValidPromopt(var APrompt: string; out OutStr: string): Boolean;
    function  IsValidImage(const ImgFileName: string; AlphaCheck: Boolean;
      out OutStr: string): Boolean;

    procedure SetImgCount(const Value: Integer);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Init_All;
    function CreateImages(APrompt: string): string;
    function CreateImageEdit(ImgFileName, APrompt: string): string;
    function CreateImageVariation(ImgFileName: string): string;

    property ImgCount: Integer      read FImgCount    write SetImgCount    default 1;
    property ImgSize : TAiImgSize   read FImgSize     write FImgSize       default ais1024;
    property ResFmt  : TAiImgResFmt read FResFmt      write FResFmt        default airfUrl;

    property ImgDir  : string       read FImgDir      write FImgDir;
    property ImgMask : string       read FImgMask     write FImgMask;
    property zImgList: TStringList  read FzImgList    write FzImgList;
  end;

implementation

uses JSonUtil, WICImgUtil;

{ TOpenAIImg }

constructor TOpenAIImg.Create;
begin
  inherited;

  FzImgList:= TStringList.Create;
  Init_All;
end;

function TOpenAIImg.CreateImageEdit(ImgFileName, APrompt: string): string;
var
  AUrl: string;
  OutStr: string;
  zFormData: TStringArray;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  FOpenAIImgPrc:= aipEdit;
  Init_List;
  AUrl:= OPEN_AI_URL + '/' + IMG_EDIT_URL;

  if not MakeSendDocCreateImageEdit(ImgFileName, APrompt, zFormData, OutStr) then
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
          ParseImgList(RecvObj);
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

function TOpenAIImg.CreateImages(APrompt: string): string;
var
  AUrl: string;
  OutStr: string;
  SendObj: TJSONObject;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  FOpenAIImgPrc:= aipCreate;
  Init_List;
  AUrl:= OPEN_AI_URL + '/' + IMG_CREATE_URL;

  SendObj:= TJSONObject.Create;
  try
    if not MakeSendDocCreateImages(APrompt, SendObj, OutStr) then
    begin
      Result:= OutStr;
      Exit;
    end;

    JsonStr:= SendJson(AUrl, SendObj);
  finally
    SendObj.Free;
    SendObj:= nil;
  end;

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
          ParseImgList(RecvObj);
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

function TOpenAIImg.CreateImageVariation(ImgFileName: string): string;
var
  AUrl: string;
  OutStr: string;
  zFormData: TStringArray;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  FOpenAIImgPrc:= aipVari;
  Init_List;
  AUrl:= OPEN_AI_URL + '/' + IMG_VARIATION_URL;

  if not MakeSendDocCreateImageVariation(ImgFileName, zFormData, OutStr) then
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
          ParseImgList(RecvObj);
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

destructor TOpenAIImg.Destroy;
begin
  Init_List;
  FzImgList.Free;
  FzImgList:= nil;

  inherited;
end;

function TOpenAIImg.IsValidImage(const ImgFileName: string; AlphaCheck: Boolean;
  out OutStr: string): Boolean;
var
  F: File;
  nSize: Integer;
begin
  Result:= False;
  if not FileExists(ImgFileName) then
  begin
    OutStr:= ImgFileName + ' File Not Found';
    Exit;
  end;
  if not IsValidImageProp(ImgFileName, AlphaCheck) then
  begin
    if AlphaCheck then
      OutStr:= 'Must be a valid PNG file and square and have transparency'
    else
      OutStr:= 'Must be a valid PNG file and square';
    Exit;
  end;

  AssignFile(F, ImgFileName);
  Reset(F);
  try
    nSize:= FileSize(F);
  finally
    CloseFile(F);
  end;
  if nSize > MAX_IMG_SIZE then
  begin
    OutStr:= 'Less than 4MB';
    Exit;
  end;

  Result:= True;
end;

function TOpenAIImg.MakeSendDocCreateImageEdit(ImgFileName, APrompt: string;
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
  if not GetValidPromopt(APrompt, OutStr) then
    Exit;

  if not IsValidImage(ImgFileName, ImgMask = '', OutStr) then
    Exit;

  if ImgMask <> '' then
  begin
    if not IsValidImage(FImgMask, True, OutStr) then
      Exit;
  end;

  Result:= True;
  idx:= -1;

  AddFormParam('image'          , '@' + ImgFileName);
  if ImgMask <> '' then
    AddFormParam('mask'           , '@' + ImgMask);
  AddFormParam('prompt'         , HTTPEncode(APrompt));
  AddFormParam('n'              , IntToStr(ImgCount));
  AddFormParam('size'           , AisToStr(ImgSize));
  AddFormParam('response_format', AirfToStr(ResFmt));
  if user_IDs <> '' then
    AddFormParam('user'           , user_IDs);
end;

function TOpenAIImg.MakeSendDocCreateImages(APrompt: string;
  var SendObj: TJSONObject; out OutStr: string): Boolean;
begin
  Result:= False;
  if not GetValidPromopt(APrompt, OutStr) then
    Exit;

  Result:= True;
  AddJsonParam(SendObj, 'prompt'         , HTTPEncode(APrompt));
  AddJsonParam(SendObj, 'n'              , ImgCount);
  AddJsonParam(SendObj, 'size'           , AisToStr(ImgSize));
  AddJsonParam(SendObj, 'response_format', AirfToStr(ResFmt));
  if user_IDs <> '' then
    AddJsonParam(SendObj, 'user'           , user_IDs);
end;

function TOpenAIImg.MakeSendDocCreateImageVariation(ImgFileName: string;
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
  if not IsValidImage(ImgFileName, False, OutStr) then
    Exit;

  Result:= True;
  idx:= -1;

  AddFormParam('image'          , '@' + ImgFileName);
  AddFormParam('n'              , IntToStr(ImgCount));
  AddFormParam('size'           , AisToStr(ImgSize));
  AddFormParam('response_format', AirfToStr(ResFmt));
  if user_IDs <> '' then
    AddFormParam('user'           , user_IDs);
end;

function TOpenAIImg.GetValidPromopt(var APrompt: string; out OutStr: string): Boolean;
var
  PromptLen: Integer;
begin
  Result:= False;
  OutStr:='';
  APrompt:= Trim(APrompt);

  if APrompt = '' then
  begin
    OutStr:= 'prompt is required';
    Exit;
  end;

  PromptLen:= Length(APrompt);
  if PromptLen > MAX_IMG_DESC then
  begin
    OutStr:= Format('max prompt length(%d) but your length(%d)', [MAX_IMG_DESC, PromptLen]);
    Exit;
  end;

  APrompt:= SimpleEscapeJsonParamStr(APrompt);
  Result:= True;
end;

procedure TOpenAIImg.Init_All;
begin
  FImgCount:= 1;
  FImgSize := ais1024;
  FResFmt  := airfUrl;

  FImgDir  := '';
  FImgMask := '';

  Init_List;
end;

procedure TOpenAIImg.Init_List;
begin
  FzImgList.Clear;
end;

procedure TOpenAIImg.ParseImgList(RecvObj: TJSONObject);
var
  jArr: TJSONArray;
  ai, aMax: Integer;
  ResStr: string;
  ImgFile: string;
begin
  jArr:= GetJsonArr(RecvObj, 'data');

  if jArr = nil then
    Exit;
  aMax:= jArr.Size;
  if ResFmt = airfUrl then
  begin
    for ai:= 0 to aMax - 1 do
    begin
      ResStr:= GetJsonStr(TJSONObject(jArr.Get(ai)), 'url');
      FzImgList.Append(ResStr);
    end;
  end
  else if ResFmt = airfB64Json then
  begin
    if ImgDir = '' then
      ImgDir:= GetCurrentDir;
    for ai:= 0 to aMax - 1 do
    begin
      ImgFile:= IntToStr(ai + 1);
      ResStr:= GetJsonStr(TJSONObject(jArr.Get(ai)), 'b64_json');
      if BJsonToImg(ResStr, ImgDir, ImgFile) then
        FzImgList.Append(ImgFile);
    end;
  end;
end;

procedure TOpenAIImg.SetImgCount(const Value: Integer);
begin
  if (Value >= 1) and (Value <= 10) then
    FImgCount := Value;
end;

end.

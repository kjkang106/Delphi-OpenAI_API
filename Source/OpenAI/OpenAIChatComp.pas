unit OpenAIChatComp;

interface

uses
  Classes, SysUtils, OpenAIHeader, OpenAI, DBXJSON, StrUtil;

type
  TChatMsg = record
    Role   : string;
    Content: string;
  end;
  TzChatMsg = array of TChatMsg;

  TOpenAIChatComp = class(TOpenAI)
  private
    FzChatMsg         : TzChatMsg;

    FMax_Tokens       : TJSONValue;
    FTemperature      : TJSONValue;
    FTop_p            : TJSONValue;
    FCompCnt          : TJSONValue;
    FStream           : TJSONValue;
    FLogProbs         : TJSONValue;
    FEcho             : TJSONValue;
    FStopStr          : TJSONValue;
    FPresence_penalty : TJSONValue;
    FFrequency_penalty: TJSONValue;

    FID               : string;
    FModel            : string;
    FzChoices         : TzChatMsg;
    procedure Init_List;

    function MakeSendDocChatCompletion(AModel: string;
      var SendObj: TJSONObject; out OutStr: string): Boolean;
    procedure ParseChoices(RecvObj: TJSONObject);

    function GetValidProp(AModel: string; out OutStr: string): Boolean;
    function GetCompCnt: Integer;
    function GetFrequency_penalty: Double;
    function GetMax_Tokens: Integer;
    function GetPresence_penalty: Double;
    function GetStopStr: string;
    function GetTemperature: Double;
    function GetTop_p: Double;
    procedure SetCompCnt(const Value: Integer);
    procedure SetFrequency_penalty(const Value: Double);
    procedure SetMax_Tokens(const Value: Integer);
    procedure SetPresence_penalty(const Value: Double);
    procedure SetStopStr(const Value: string);
    procedure SetTemperature(const Value: Double);
    procedure SetTop_p(const Value: Double);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Init_All;
    procedure AddChatMessage(role, msg: string);
    function CreateChatCompletions(AModel: string): string;

    property Max_tokens: Integer        read GetMax_Tokens        write SetMax_Tokens       ;
    property Temperature: Double        read GetTemperature       write SetTemperature      ;
    property Top_p: Double              read GetTop_p             write SetTop_p            ;
    property CompCnt: Integer           read GetCompCnt           write SetCompCnt          ;
    property Presence_penalty: Double   read GetPresence_penalty  write SetPresence_penalty ;
    property Frequency_penalty: Double  read GetFrequency_penalty write SetFrequency_penalty;
    property StopStr: string            read GetStopStr           write SetStopStr          ;

    property ID: string                 read FID                  write FID                 ;
    property Model: string              read FModel               write FModel              ;
    property zChoices: TzChatMsg        read FzChoices            write FzChoices           ;
  end;

implementation

uses JSonUtil;


{ TOpenAIChatComp }

procedure TOpenAIChatComp.AddChatMessage(role, msg: string);
var
  nCnt: Integer;
begin
  msg:= Trim(msg);
  if msg = '' then
    Exit;
  role:= Trim(role);
  if role = '' then
    role:= 'user';

  nCnt:= Length(FzChatMsg);
  SetLength(FzChatMsg, nCnt + 1);

  FzChatMsg[nCnt].Role   := role;
  FzChatMsg[nCnt].Content:= msg;
end;

constructor TOpenAIChatComp.Create;
begin
  inherited;

  Init_All;
end;

function TOpenAIChatComp.CreateChatCompletions(AModel: string): string;
var
  AUrl: string;
  OutStr: string;
  SendObj: TJSONObject;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  Init_List;
  AUrl:= OPEN_AI_URL + '/' + CHAT_COMPLE_URL;

  SendObj:= TJSONObject.Create;
  try
    if not MakeSendDocChatCompletion(AModel, SendObj, OutStr) then
    begin
      Result:= OutStr;
      Exit;
    end;

    JsonStr:= SendJson(AUrl, SendObj);
  finally
    SendObj.Free;
    SendObj:= nil;
  end;
  Result:= JsonStr;

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
          ParseChoices(RecvObj);
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

destructor TOpenAIChatComp.Destroy;
begin
  FMax_Tokens.Free;
  FTemperature.Free;
  FTop_p.Free;
  FCompCnt.Free;
  FPresence_penalty.Free;
  FFrequency_penalty.Free;
  FStopStr.Free;

  inherited;
end;

function TOpenAIChatComp.GetCompCnt: Integer;
begin
  if FCompCnt is TJSONNull then
    Result:= 11
  else
    Result:= TJSONNumber(FCompCnt).AsInt;
end;

function TOpenAIChatComp.GetFrequency_penalty: Double;
begin
  if FFrequency_penalty is TJSONNull then
    Result:= 0
  else
    Result:= TJSONNumber(FFrequency_penalty).AsDouble;
end;

function TOpenAIChatComp.GetMax_Tokens: Integer;
begin
  if FMax_Tokens is TJSONNull then
    Result:= 16
  else
    Result:= TJSONNumber(FMax_Tokens).AsInt;
end;

function TOpenAIChatComp.GetPresence_penalty: Double;
begin
  if FPresence_penalty is TJSONNull then
    Result:= 0
  else
    Result:= TJSONNumber(FPresence_penalty).AsDouble;
end;

function TOpenAIChatComp.GetStopStr: string;
begin
  if FStopStr is TJSONNull then
    Result:= ''
  else
    Result:= TJSONString(FStopStr).Value;
end;

function TOpenAIChatComp.GetTemperature: Double;
begin
  if FTemperature is TJSONNull then
    Result:= 1
  else
    Result:= TJSONNumber(FTemperature).AsDouble;
end;

function TOpenAIChatComp.GetTop_p: Double;
begin
  if FTop_p is TJSONNull then
    Result:= 1
  else
    Result:= TJSONNumber(FTop_p).AsDouble;
end;

function TOpenAIChatComp.GetValidProp(AModel: string;
  out OutStr: string): Boolean;
var
  IsOK: Boolean;
  mi: TAiModel;
begin
  Result:= False;
  for mi:= Low(TAiModel) to High(TAiModel) do
  begin
    if AimToStr(mi) = AModel then
    begin
      Result:= True;
      Break;
    end;
  end;
  if Result then
    Result:= False
  else
  begin
    OutStr:= 'Invalid Model';
    Exit;
  end;

  if (Temperature < 0) or (Temperature > 2) then
  begin
    OutStr:= 'Invalid Temperature';
    Exit;
  end;
  if (Top_p < 0) or (Top_p > 1) then
  begin
    OutStr:= 'Invalid Top_p';
    Exit;
  end;
  if (Presence_penalty < -2.0) or (Presence_penalty > 2.0) then
  begin
    OutStr:= 'Invalid Presence_penalty';
    Exit;
  end;
  if (Frequency_penalty < -2.0) or (Frequency_penalty > 2.0) then
  begin
    OutStr:= 'Invalid Frequency_penalty';
    Exit;
  end;

  Result:= True;
end;

procedure TOpenAIChatComp.Init_All;
begin
  SetLength(FzChatMsg, 0);
  FMax_Tokens       := TJSONNull.Create;
  FTemperature      := TJSONNull.Create;
  FTop_p            := TJSONNull.Create;
  FCompCnt          := TJSONNull.Create;
  FPresence_penalty := TJSONNull.Create;
  FFrequency_penalty:= TJSONNull.Create;
  FStopStr          := TJSONNull.Create;
//  FStream     := False;
//  FLogProbs

  Init_List;
end;

procedure TOpenAIChatComp.Init_List;
begin
  FID:= '';
  FModel:= '';
  SetLength(FzChoices, 0);
end;

function TOpenAIChatComp.MakeSendDocChatCompletion(AModel: string;
  var SendObj: TJSONObject; out OutStr: string): Boolean;
var
  jArray : TJSONArray;
  jSubDoc: TJSONObject;
  mi, mMax: Integer;
begin
  Result:= False;
  if not GetValidProp(AModel, OutStr) then
    Exit;

  Result:= True;
  AddJsonParam(SendObj, 'model', AModel);

  jArray:= TJSONArray.Create;
  mMax:= Length(FzChatMsg);
  for mi:= 0 to mMax - 1 do
  begin
    jSubDoc:= TJSONObject.Create;
    AddJsonParam(jSubDoc, 'role'   , SimpleEscapeJsonParamStr(FzChatMsg[mi].Role));
    AddJsonParam(jSubDoc, 'content', SimpleEscapeJsonParamStr(FzChatMsg[mi].Content));
    jArray.Add(jSubDoc);
  end;
  AddJsonParam(SendObj, 'messages', jArray);
  if not(FMax_Tokens is TJSONNull) then
    AddJsonParam(SendObj, 'max_tokens'        , Max_tokens);
  if not(FTemperature is TJSONNull) then
    AddJsonParam(SendObj, 'temperature'       , Temperature);
  if not(FTop_p is TJSONNull) then
    AddJsonParam(SendObj, 'top_p'             , Top_p);
  if not(FCompCnt is TJSONNull) then
    AddJsonParam(SendObj, 'n'                 , CompCnt);
  if not(FFrequency_penalty is TJSONNull) then
    AddJsonParam(SendObj, 'frequency_penalty' , Frequency_penalty);
  if not(FPresence_penalty is TJSONNull) then
    AddJsonParam(SendObj, 'presence_penalty'  , Presence_penalty);
  if not(FStopStr is TJSONNull) then
    AddJsonParam(SendObj, 'stop'              , SimpleEscapeJsonParamStr(StopStr));
  if user_IDs <> '' then
    AddJsonParam(SendObj, 'user'              , user_IDs);
end;

procedure TOpenAIChatComp.ParseChoices(RecvObj: TJSONObject);
var
  jArr: TJSONArray;
  ai, aMax: Integer;
  SubDoc: TJSONObject;
begin
  FID   := GetJsonStr(RecvObj, 'id'   );
  FModel:= GetJsonStr(RecvObj, 'model');

  jArr:= GetJsonArr(RecvObj, 'choices');
  if jArr = nil then
    Exit;

  aMax:= jArr.Size;
  SetLength(FzChoices, aMax);
  for ai:= 0 to aMax - 1 do
  begin
    SubDoc:= GetJsonObj(TJSONObject(jArr.Get(ai)), 'message');
    if SubDoc <> nil then
    begin
      FzChoices[ai].Role   := GetJsonStr(SubDoc, 'role');
      FzChoices[ai].Content:= GetJsonStr(SubDoc, 'content');
    end;
  end;
end;

procedure TOpenAIChatComp.SetCompCnt(const Value: Integer);
begin
  FCompCnt.Free;
  FCompCnt:= TJSONNumber.Create(Value);
end;

procedure TOpenAIChatComp.SetFrequency_penalty(const Value: Double);
begin
  FFrequency_penalty.Free;
  FFrequency_penalty:= TJSONNumber.Create(Value);
end;

procedure TOpenAIChatComp.SetMax_Tokens(const Value: Integer);
begin
  FMax_Tokens.Free;
  FMax_Tokens:= TJSONNumber.Create(Value);
end;

procedure TOpenAIChatComp.SetPresence_penalty(const Value: Double);
begin
  FPresence_penalty.Free;
  FPresence_penalty:= TJSONNumber.Create(Value);
end;

procedure TOpenAIChatComp.SetStopStr(const Value: string);
begin
  FStopStr.Free;
  FStopStr:= TJSONString.Create(Value);
end;

procedure TOpenAIChatComp.SetTemperature(const Value: Double);
begin
  FTemperature.Free;
  FTemperature:= TJSONNumber.Create(Value);
end;

procedure TOpenAIChatComp.SetTop_p(const Value: Double);
begin
  FTop_p.Free;
  FTop_p:= TJSONNumber.Create(Value);
end;

end.

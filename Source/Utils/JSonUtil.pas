unit JSonUtil;

interface

uses
  SysUtils, DBXJSON;

procedure AddJsonParam(var doc:TJSONObject; name, value: string); overload;
procedure AddJsonParam(var doc:TJSONObject; name: string; value: Double); overload;
procedure AddJsonParam(var doc:TJSONObject; name: string; value: Integer); overload;
procedure AddJsonParam(var doc:TJSONObject; name: string; value: TJSONArray); overload;

function  GetJsonStr(jDoc: TJSONObject; const name: string; const nLen: Integer = 0): string;
function  GetJsonInt(jDoc: TJSONObject; const name: string): Integer;
function  GetJsonBle(jDoc: TJSONObject; const name: string): Boolean;
function  GetJsonArr(jDoc: TJSONObject; const name: string): TJSONArray;
function  GetJsonObj(jDoc: TJSONObject; const name: string): TJSONObject;

function MakeJsonParamStr(const JsonStr: string): string;
function SimpleEscapeJsonParamStr(const JsonStr: string): string;
function GetJsonDoc(const JsonStr: string; var JObj: TJSONObject): Boolean;

implementation

procedure AddJsonParam(var doc: TJSONObject; name, value: string);
var
  pair: TJSONPair;
begin
  pair := TJSONPair.Create;
  pair.JsonString:= TJSONString.Create(name);
  pair.JsonValue := TJSONString.Create(Trim(value));
  doc.AddPair(pair);
end;

procedure AddJsonParam(var doc: TJSONObject; name: string; value: Double);
var
  pair: TJSONPair;
begin
  pair := TJSONPair.Create;
  pair.JsonString:= TJSONString.Create(name);
  pair.JsonValue := TJSONNumber.Create(value);
  doc.AddPair(pair);
end;

procedure AddJsonParam(var doc: TJSONObject; name: string; value: Integer);
var
  pair: TJSONPair;
begin
  pair := TJSONPair.Create;
  pair.JsonString:= TJSONString.Create(name);
  pair.JsonValue := TJSONNumber.Create(value);
  doc.AddPair(pair);
end;

procedure AddJsonParam(var doc: TJSONObject; name: string; value: TJSONArray);
var
  pair: TJSONPair;
begin
  pair := TJSONPair.Create;
  pair.JsonString:= TJSONString.Create(name);
  pair.JsonValue := value;
  doc.AddPair(pair);
end;

function GetJsonInt(jDoc: TJSONObject; const name: string): Integer;
begin
  if (jDoc = nil) or (jDoc.Get(name) = nil) then
    Result:= 0
  else
    Result:= TJSONNumber(jDoc.Get(name).JsonValue).AsInt;
end;

function  GetJsonBle(jDoc: TJSONObject; const name: string): Boolean;
begin
  if (jDoc = nil) or (jDoc.Get(name) = nil) then
    Result:= False
  else
    Result:= (jDoc.Get(name).JsonValue).ToString = 'true';
end;

function GetJsonStr(jDoc: TJSONObject; const name: string; const nLen: Integer): string;
var
  rltLen: Integer;
begin
  if (jDoc = nil) or (jDoc.Get(name) = nil) then
    Result:= ''
  else
    Result:= jDoc.Get(name).JsonValue.Value;

  if nLen > 0 then
  begin
    rltLen:= Length(Result);
    if nLen < rltLen then
      Result:= Copy(Result, 1, nLen);
  end;
end;

function GetJsonArr(jDoc: TJSONObject; const name: string): TJSONArray;
begin
  if (jDoc = nil) or (jDoc.Get(name) = nil) then
    Result:= nil
  else
    Result:= TJSONArray(jDoc.Get(name).JsonValue);
end;

function GetJsonObj(jDoc: TJSONObject; const name: string): TJSONObject;
begin
  if (jDoc = nil) or (jDoc.Get(name) = nil) then
    Result:= nil
  else
    Result:= TJSONObject(jDoc.Get(name).JsonValue);
end;

//MakeJsonParamStr, SimpleEscapeJsonParamStr 은 같이 쓰면 안됨
function MakeJsonParamStr(const JsonStr: string): string;
var
  JSONString: TJSONString;
  Data: TBytes;
  Len : Integer;
begin
  Result:= '';

  JSONString:= TJSONString.Create(JsonStr);
  try
    SetLength(Data, JsonString.EstimatedByteSize);
    Len:= JsonString.ToBytes(Data, 0);
    if Len > 2 then   // "" 제거
      Result:= TEncoding.ASCII.GetString(Data, 1, Len - 2);
  finally
    JSONString.Free;
    JSONString:= nil;
  end;
end;

//MakeJsonParamStr, SimpleEscapeJsonParamStr 은 같이 쓰면 안됨
function SimpleEscapeJsonParamStr(const JsonStr: string): string;
begin
  Result:= JsonStr;
  Result:= StringReplace(Result, '\', '\\', [rfReplaceAll]);    //첫번째 치환 필수
  Result:= StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result:= StringReplace(Result, #$A, '\n', [rfReplaceAll]);
  Result:= StringReplace(Result, #$D, '\r', [rfReplaceAll]);
  Result:= StringReplace(Result, #$9, '\t', [rfReplaceAll]);
end;

function GetJsonDoc(const JsonStr: string; var JObj: TJSONObject): Boolean;
begin
  JObj:= TJSONObject(TJSONObject.ParseJSONValue(JsonStr));
  Result:= (JObj <> nil);
end;

end.

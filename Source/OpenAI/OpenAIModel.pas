unit OpenAIModel;

interface
uses
  Classes, SysUtils, OpenAIHeader, OpenAI, DBXJSON;

type
  TPermData = record
    PermID    : string;
    PermType  : string;
    AllowView : Boolean;
    IsBlocking: Boolean;
  end;
  TzDataPerm = array of TPermData;
  TModelData = record
    DataID  : string;
    DataType: string;
    DataPerm: TzDataPerm;
  end;
  TzModelData = array of TModelData;

  TOpenAIModel = class(TOpenAI)
  private
    FzModelData: TzModelData;

    procedure Init_List;
    procedure ParseModelList(RecvObj: TJSONObject);
  public
    constructor Create; override;
    destructor Destroy; override;

    function ListModels: string;

    property zModelData: TzModelData     read FzModelData            write FzModelData;
  end;

implementation

uses JSonUtil;

{ TOpenAIModel }

constructor TOpenAIModel.Create;
begin
  inherited;

  Init_List;
end;

destructor TOpenAIModel.Destroy;
begin
  Init_List;

  inherited;
end;

procedure TOpenAIModel.Init_List;
begin
  SetLength(FzModelData, 0);
end;

function TOpenAIModel.ListModels: string;
var
  AUrl: string;
  OutStr: string;
  RecvObj: TJSONObject;
  JsonStr: string;
begin
  Init_List;
  AUrl:= OPEN_AI_URL + '/' + MODEL_LIST_URL;

  JsonStr:= SendHttpGet(AUrl);

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
          ParseModelList(RecvObj);
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

procedure TOpenAIModel.ParseModelList(RecvObj: TJSONObject);
var
  jArr, jArr2: TJSONArray;
  ai, aMax: Integer;
  bi, bMax: Integer;

  ModelData: TModelData;
begin
  jArr:= GetJsonArr(RecvObj, 'data');
  if jArr = nil then
    Exit;

  aMax:= jArr.Size;
  SetLength(FzModelData, aMax);
  for ai:= 0 to aMax - 1 do
  begin
    ModelData:= Default(TModelData);
    ModelData.DataID  := GetJsonStr(TJSONObject(jArr.Get(ai)), 'id');
    ModelData.DataType:= GetJsonStr(TJSONObject(jArr.Get(ai)), 'object');
    SetLength(ModelData.DataPerm, 0);

    jArr2:= GetJsonArr(TJSONObject(jArr.Get(ai)), 'permission');
    if jArr2 <> nil then
    begin
      bMax:= jArr2.Size;
      SetLength(ModelData.DataPerm, bMax);
      for bi:= 0 to bMax - 1 do
      begin
        ModelData.DataPerm[bi]:= Default(TPermData);
        ModelData.DataPerm[bi].PermID    := GetJsonStr(TJSONObject(jArr2.Get(bi)), 'id');
        ModelData.DataPerm[bi].PermType  := GetJsonStr(TJSONObject(jArr2.Get(bi)), 'object');
        ModelData.DataPerm[bi].AllowView := GetJsonBle(TJSONObject(jArr2.Get(bi)), 'allow_view');
        ModelData.DataPerm[bi].IsBlocking:= GetJsonBle(TJSONObject(jArr2.Get(bi)), 'is_blocking');
      end;
    end;
    FzModelData[ai]:= ModelData;
  end;
end;

end.

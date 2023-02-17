unit InitInfo;

interface

uses
  IniFiles;

var
  RootPath, ImgPath: string;

  ApiKey    : string;
  EndUserIDs: string;

procedure LoadInitInfo;
procedure SaveApiKey(ApiKey: string);

implementation

procedure LoadInitInfo;
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    ApiKey    := Ini.ReadString('OpenAI', 'API_KEY', '');
    EndUserIDs:= Ini.ReadString('OpenAI', 'End-user_IDs', '');
  finally
    Ini.Free;
  end;
end;

procedure SaveApiKey(ApiKey: string);
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    Ini.WriteString('OpenAI', 'API_KEY', ApiKey);
  finally
    Ini.Free;
  end;
end;

initialization
  ApiKey    := '';
  EndUserIDs:= '';

finalization

end.

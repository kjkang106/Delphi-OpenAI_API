unit InitInfo;

interface

uses
  SysUtils, IniFiles;

var
  RootPath, ImgPath, AudioPath: string;

  ApiKey      : string;
  Organization: string;
  EndUserIDs  : string;

procedure LoadInitInfo;
procedure SaveApiKey(ApiKey: string);

function  LoadLastInfo(Ident, Default: string): string;           overload;
function  LoadLastInfo(Ident: string; Default: Integer): Integer; overload;
procedure SaveLastInfo(Ident, Value: string);                     overload;
procedure SaveLastInfo(Ident: string; Value: Integer);            overload;

implementation

procedure LoadInitInfo;
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    ApiKey      := Ini.ReadString('OpenAI', 'API_KEY'     , '');
    Organization:= Ini.ReadString('OpenAI', 'Organization', '');
    EndUserIDs  := Ini.ReadString('OpenAI', 'End-user_IDs', '');
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
    Ini.WriteString('OpenAI', 'API_KEY'     , ApiKey);
    Ini.WriteString('OpenAI', 'Organization', Organization);
    Ini.WriteString('OpenAI', 'End-user_IDs', EndUserIDs);
  finally
    Ini.Free;
  end;
end;

function LoadLastInfo(Ident, Default: string): string;
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    Result:= Ini.ReadString('LastInfo', Ident, Default);

    Result:= StringReplace(Result, '\n', #$A, [rfReplaceAll]);
    Result:= StringReplace(Result, '\r', #$D, [rfReplaceAll]);
  finally
    Ini.Free;
  end;
end;

function LoadLastInfo(Ident: string; Default: Integer): Integer;
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    Result:= Ini.ReadInteger('LastInfo', Ident, Default);
  finally
    Ini.Free;
  end;
end;

procedure SaveLastInfo(Ident, Value: string);
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    Value:= StringReplace(Value, #$A, '\n', [rfReplaceAll]);
    Value:= StringReplace(Value, #$D, '\r', [rfReplaceAll]);

    Ini.WriteString('LastInfo', Ident, Value);
  finally
    Ini.Free;
  end;
end;

procedure SaveLastInfo(Ident: string; Value: Integer);
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    Ini.WriteInteger('LastInfo', Ident, Value);
  finally
    Ini.Free;
  end;
end;

initialization
  ApiKey      := '';
  Organization:= '';
  EndUserIDs  := '';

finalization

end.

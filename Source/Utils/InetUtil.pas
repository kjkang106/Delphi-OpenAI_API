unit InetUtil;

interface

uses
  Windows, Classes, SysUtils, WinInet, StrUtils, StrUtil, WinHTTPUtil;

function HttpGet (const AUrl: string): string; overload;
function HttpGet (const AUrl: string; AResponse: TStream): Boolean; overload;
function HttpPost(const AUrl, AParams: string): string; overload;
function HttpPost(const AUrl, AParams: string; CustomHeader: TStringArray): string; overload;

function HttpPostFormData(const AUrl: string; CustomHeader, zFormData: TStringArray): string;
function PostFormData(var hRequest: HINTERNET; Boundary: string; zFormData: TStringArray): Cardinal;

implementation

function IsSecure(const AUrl: string): Boolean;
begin
  Result:= (CompareText('https', Copy(AUrl, 1, 5)) = 0);
end;

function ParseUrl(const AUrl: string; out APort: Word): TStringArray;
var
  Protocol, Host, URI: string;
  nLen, idx: Integer;
begin
  Result:= Split(AUrl, ':');

  nLen:= Length(Result);
  if nLen > 1 then
  begin
    Protocol:= Result[0];
    Host    := Result[1];
    for idx:= 2 to nLen - 1 do
      Host:= Host + ':' + Result[idx];
  end
  else
    Exit;

  if (CompareText('http' , Protocol) = 0) or
     (CompareText('https', Protocol) = 0) then
  begin
    Protocol:= Protocol + '://';
    if StartsStr('//', Host) then
      Delete(Host, 1, 2);
  end
  else
  begin
    Protocol:= 'http://';
    Host    := AUrl;
  end;

  Result:= Split(Host, ':');
  nLen:= Length(Result);
  if nLen > 1 then
  begin
    Host:= Result[0];
    URI := Result[1];
    for idx:= 2 to nLen - 1 do
      URI:= URI + ':' + Result[idx];

    Result:= Split(URI, '/');
    APort:= StrToIntDef(Result[0], INTERNET_INVALID_PORT_NUMBER);

    nLen:= Length(Result);
    if nLen > 1 then
    begin
      URI := Result[1];
      for idx:= 2 to nLen - 1 do
        URI:= URI + '/' + Result[idx];
    end
    else
      URI := '';
    URI  := Host + '/' + URI;
  end
  else
  begin
    APort:= INTERNET_INVALID_PORT_NUMBER;
    URI  := Host;
  end;

  Result:= Split(URI, '/');
//  Result[0]:= Protocol + Result[0];

  nLen:= Length(Result);
  if nLen > 2 then
  begin
    for idx:= 2 to nLen - 1 do
      Result[1]:= Result[1] + '/' + Result[idx];
    SetLength(Result, 2);
  end;

  if APort = INTERNET_INVALID_PORT_NUMBER then
  begin
    if IsSecure(Protocol) then
      APort := INTERNET_DEFAULT_HTTPS_PORT
    else
      APort := INTERNET_DEFAULT_HTTP_PORT;
  end;
end;

function GetCodePageStr(var srBuf: TMemoryStream; CodePage: Word): string;
var
  rbStr: RawByteString;
begin
  rbStr := '';
  srBuf.Position := 0;
  SetLength(rbStr, srBuf.Size);
  srBuf.ReadBuffer(rbStr[1], srBuf.Size);

  SetCodePage(rbstr, CodePage, False);   //Unicode:65001, ecu-kr:949
  Result:= String(rbStr);
end;

function HttpGet(const AUrl: string): string;
var
  AResponse: TMemoryStream;
begin
  AResponse:= TMemoryStream.Create;
  try
    if HttpGet(AUrl, AResponse) then
      Result:= GetCodePageStr(AResponse, 65001);
  finally
    AResponse.Free;
  end;
end;

function HttpGet (const AUrl: string; AResponse: TStream): Boolean;
var
  hSession, hConnect, hRequest: HINTERNET;
  BufStream: TMemoryStream;
  Buffer   : array[0 .. 4096] of Char;
  dwBytesRead: DWORD;
begin
  Result := False;
  hSession := InternetOpen('Delphi', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
  begin
    hConnect := InternetOpenUrl(hSession, PChar(AUrl), nil, 0, INTERNET_FLAG_RELOAD, 0);
    if Assigned(hConnect) then
    begin
      hRequest := InternetOpenUrl(hSession, PChar(AUrl), nil, 0, INTERNET_FLAG_RELOAD, 0);
      if Assigned(hRequest) then
      begin
        BufStream:= TMemoryStream.Create;
        try
          repeat
            InternetReadFile(hRequest, @Buffer, SizeOf(Buffer) - 1, dwBytesRead);
            BufStream.Write(Buffer, dwBytesRead);
          until dwBytesRead = 0;
          //Buffer[0]:= #0;
          //BufStream.Write(Buffer, 1);

          Result:= True;
          BufStream.SaveToStream(AResponse);
        finally
          BufStream.Free;
        end;
        InternetCloseHandle(hRequest);
      end;
      InternetCloseHandle(hConnect);
    end;
    InternetCloseHandle(hSession);
  end;
end;

function HttpPost(const AUrl, AParams: string): string;
var
  CustomHeader: TStringArray;
begin
  SetLength(CustomHeader, 0);
  Result:= HttpPost(AUrl, AParams, CustomHeader);
end;

function HttpPost(const AUrl, AParams: string; CustomHeader: TStringArray): string;
var
  ParsedURL: TStringArray;
  APort    : Word;
  hi, hMax : Integer;

  hSession, hConnect, hRequest: HINTERNET;
  Flags    : DWORD;
  Header   : TStringStream;
  Body     : RawByteString;
  BodyLen  : Integer;
  BufStream: TMemoryStream;
  Buffer   : array[0 .. 4096] of Char;
  dwBytesRead: DWORD;
begin
  ParsedUrl := ParseUrl(AUrl, APort);

  Result := '';
  hSession := InternetOpen('Delphi', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
  begin
    hConnect := InternetConnect(hSession, PChar(ParsedUrl[0]), APort, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if Assigned(hConnect) then
    begin
      if IsSecure(AUrl) then
        Flags:= INTERNET_FLAG_SECURE or INTERNET_FLAG_KEEP_CONNECTION
      else
        Flags:= INTERNET_SERVICE_HTTP;
      hRequest := HttpOpenRequest(hConnect, 'POST', PChar(ParsedUrl[1]), 'HTTP/1.0', nil, nil, Flags, 0);
      if Assigned(hRequest) then
      begin
        BodyLen:= Length(AParams);
        Header := TStringStream.Create('');
        try
          with Header do
          begin
            WriteString('Connection: keep-alive' + sLineBreak);
            WriteString('Content-Length: ' + IntToStr(BodyLen) + sLineBreak);
            WriteString('Host: ' + ParsedUrl[0] + ':' + IntToStr(APort) + sLineBreak);
            WriteString('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' + sLineBreak);
            hMax:= Length(CustomHeader);
            for hi:= 0 to hMax - 1 do
              WriteString(CustomHeader[hi] + sLineBreak);
//            WriteString('Keep-Alive: 300'+ sLineBreak);
//            WriteString('User-Agent: Mozilla/3.0 (compatible; Indy Library)' + sLineBreak);
          end;
          HttpAddRequestHeaders(hRequest, PChar(Header.DataString), Length(Header.DataString), HTTP_ADDREQ_FLAG_ADD);
          Body:= UTF8Encode(AParams);
          if HttpSendRequest(hRequest, nil, 0, @Body[1], BodyLen) then
          begin
            BufStream:= TMemoryStream.Create;
            try
              repeat
                InternetReadFile(hRequest, @Buffer, SizeOf(Buffer) - 1, dwBytesRead);
                BufStream.Write(Buffer, dwBytesRead);
              until dwBytesRead = 0;
              //Buffer[0]:= #0;
              //BufStream.Write(Buffer, 1);

              Result:= GetCodePageStr(BufStream, 65001);
            finally
              BufStream.Free;
            end;
          end
          else
            Result:= WinHttpSysErrorMessage(GetLastError);
        finally
          Header.Free;
        end;
        InternetCloseHandle(hRequest);
      end;
      InternetCloseHandle(hConnect);
    end;
    InternetCloseHandle(hSession);
  end;
end;

function HttpPostFormData(const AUrl: string; CustomHeader, zFormData: TStringArray): string;
var
  ParsedURL: TStringArray;
  APort    : Word;
  hi, hMax : Integer;

  hSession, hConnect, hRequest: HINTERNET;
  Flags    : DWORD;
  Header   : TStringStream;
  Boundary : string;
  PostRlt  : Cardinal;
  BufStream: TMemoryStream;
  Buffer   : array[0 .. 4096] of Char;
  dwBytesRead: DWORD;
begin
  ParsedUrl := ParseUrl(AUrl, APort);

  Result := '';
  hSession := InternetOpen('Delphi', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
  begin
    hConnect := InternetConnect(hSession, PChar(ParsedUrl[0]), APort, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if Assigned(hConnect) then
    begin
      if IsSecure(AUrl) then
        Flags:= INTERNET_FLAG_SECURE or INTERNET_FLAG_KEEP_CONNECTION
      else
        Flags:= INTERNET_SERVICE_HTTP;
      hRequest := HttpOpenRequest(hConnect, 'POST', PChar(ParsedUrl[1]), 'HTTP/1.0', nil, nil, Flags, 0);
      if Assigned(hRequest) then
      begin
        Boundary := '-------------------------' + IntToHex(Random(MaxInt), 8) + IntToHex(Random(MaxInt), 8);
        Header := TStringStream.Create('');
        try
          with Header do
          begin
            WriteString('Content-Type: multipart/form-data; boundary=' + Boundary + sLineBreak);
            hMax:= Length(CustomHeader);
            for hi:= 0 to hMax - 1 do
              WriteString(CustomHeader[hi] + sLineBreak);
          end;
          HttpAddRequestHeaders(hRequest, PChar(Header.DataString), Length(Header.DataString), HTTP_ADDREQ_FLAG_ADD);
          PostRlt:= PostFormData(hRequest, Boundary, zFormData);
          if PostRlt = ERROR_SUCCESS then
          begin
            BufStream:= TMemoryStream.Create;
            try
              repeat
                InternetReadFile(hRequest, @Buffer, SizeOf(Buffer) - 1, dwBytesRead);
                BufStream.Write(Buffer, dwBytesRead);
              until dwBytesRead = 0;
              //Buffer[0]:= #0;
              //BufStream.Write(Buffer, 1);

              Result:= GetCodePageStr(BufStream, 65001);
            finally
              BufStream.Free;
            end;
          end
          else
            Result:= IntToStr(PostRlt) + ' : ' + WinHttpSysErrorMessage(PostRlt);
        finally
          Header.Free;
        end;
        InternetCloseHandle(hRequest);
      end;
      InternetCloseHandle(hConnect);
    end;
    InternetCloseHandle(hSession);
  end;
end;

function ParseFormData(const AFormData: string; out FieldName, FileValue: string): Boolean;
var
  StringArray: TStringArray;
begin
  Result:= False;
  StringArray:= Split(AFormData, '=');
  if Length(StringArray) = 2 then
  begin
    Result:= True;
    FieldName:= StringArray[0];
    FileValue:= StringArray[1];
  end;
end;

function PostFormData(var hRequest: HINTERNET; Boundary: string; zFormData: TStringArray): Cardinal;
var
  si, sMax: Integer;
  FName, FValue: string;

  StrSize: Longint;
  StrText: TStringStream;
  StrFile: TMemoryStream;
  AddSize: Longint;
  StrBody: TMemoryStream;
  procedure AddBody(StrAdd: TMemoryStream);
  begin
    StrAdd.Position:= 0;
    AddSize:= StrAdd.Size;
    if AddSize <> 0 then
    begin
      StrSize:= StrSize + AddSize;
      StrBody.SetSize(StrSize);
      StrBody.WriteBuffer(StrAdd.Memory^, AddSize);
    end;
  end;
begin
  StrBody:= TMemoryStream.Create;
  StrText:= TStringStream.Create('', TEncoding.UTF8);
  StrSize:= 0;
  try
    sMax:= Length(zFormData);
    for si:= 0 to sMax - 1 do
    begin
      if not ParseFormData(zFormData[si], FName, FValue) then
        Continue;
      if FName = '' then
        Continue;
      if StartsText('@', FValue) then
      begin
        Delete(FValue, 1, 1);

        StrText.Clear;
        StrText.WriteString('--' + Boundary + sLineBreak);
        StrText.WriteString('Content-Disposition: form-data; name="' + FName + '"; filename="' + ExtractFileName(FValue) + '"' + sLineBreak);
        StrText.WriteString('Content-Type: application/octet-stream' + sLineBreak);
        StrText.WriteString(sLineBreak);
        AddBody(StrText);

        StrFile:= TMemoryStream.Create;
        try
          StrFile.LoadFromFile(FValue);
          AddBody(StrFile);
        finally
          StrFile.Free;
        end;

        StrText.Clear;
        StrText.WriteString(sLineBreak);
        AddBody(StrText);
      end
      else
      begin
        StrText.Clear;
        StrText.WriteString('--' + Boundary + sLineBreak);
        StrText.WriteString('Content-Disposition: form-data; name="' + FName + '"' + sLineBreak);
        StrText.WriteString(sLineBreak);
        StrText.WriteString(FValue + sLineBreak);
        AddBody(StrText);
      end;
    end;
    StrText.Clear;
    StrText.WriteString('--' + Boundary + '--' + sLineBreak);
    AddBody(StrText);

    HttpSendRequest(hRequest, nil, 0, StrBody.Memory, StrBody.Size);
  finally
    StrText.Free;
    StrBody.Free;
  end;

  Result:= GetLastError;
end;

end.

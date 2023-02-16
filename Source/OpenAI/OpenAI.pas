unit OpenAI;

interface

uses
  Forms, Classes, SysUtils, DBXJSON, StrUtil;

type
  TProgShowEvent = procedure(Msg: string) of object;
  TOpenAIThread = class(TThread)
  private
    FUrl         : string;
    FOutStr      : string;
    FOnResult    : TNotifyEvent;

    procedure NotiResult;
  published
    property AUrl    : string         read FUrl           write FUrl;
    property OutStr  : string         read FOutStr        write FOutStr;
    property OnResult: TNotifyEvent   read FOnResult      write FOnResult;
  end;

  TSendJsonThread = class(TOpenAIThread)
  private
    FParams      : string;
    FCustomHeader: TStringArray;
  public
    procedure Execute; override;

    property AParams     : string        read FParams        write FParams;
    property CustomHeader: TStringArray  read FCustomHeader  write FCustomHeader;
  end;

  TSendFormDataThread = class(TOpenAIThread)
  private
    FCustomHeader: TStringArray;
    FzFormData   : TStringArray;
  public
    procedure Execute; override;

    property CustomHeader: TStringArray  read FCustomHeader  write FCustomHeader;
    property zFormData   : TStringArray  read FzFormData     write FzFormData;
  end;

  TOpenAI = class
  private
    Forganization : string;
    Fapi_key      : string;
    FOnProgShow   : TProgShowEvent;
    FOnProgHide   : TNotifyEvent;
    FOutStr       : string;

    procedure OnResult(Sender: TObject);
    procedure ShowProcessDlg(Msg: string);
    procedure HideProcessDlg;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function SendJson(AUrl: string; SendObj: TJSONObject): string;
    function SendFormData(AUrl: string; zFormData: TStringArray): string;
  published
    property organization: string          read Forganization write Forganization;
    property api_key     : string          read Fapi_key      write Fapi_key;

    property OnProgShow  : TProgShowEvent  read FOnProgShow   write FOnProgShow;
    property OnProgHide  : TNotifyEvent    read FOnProgHide   write FOnProgHide;
  end;

implementation

uses InetUtil, OpenAIHeader, ProgressDlg;

{ TOpenAI }

constructor TOpenAI.Create;
begin
  FOnProgShow   := nil;
  FOnProgHide   := nil;
end;

destructor TOpenAI.Destroy;
begin
  FOnProgShow   := nil;
  FOnProgHide   := nil;

  inherited;
end;

procedure TOpenAI.HideProcessDlg;
begin
  if Assigned(FOnProgHide) then
    FOnProgHide(Self);
  HideProgDlg;
end;

procedure TOpenAI.OnResult(Sender: TObject);
begin
  FOutStr:= TOpenAIThread(Sender).OutStr;
end;

function TOpenAI.SendFormData(AUrl: string; zFormData: TStringArray): string;
var
  CustomHeader: TStringArray;
  SendFormDataThread: TSendFormDataThread;
begin
  SetLength(CustomHeader, 1);
  CustomHeader[0]:= 'Authorization: Bearer ' + api_key;

  FOutStr:= '';
  ShowProcessDlg('Http Post FormData ...');
  try
    SendFormDataThread:= TSendFormDataThread.Create(True);
    SendFormDataThread.AUrl           := AUrl;
    SendFormDataThread.CustomHeader   := CustomHeader;
    SendFormDataThread.zFormData      := zFormData;
    SendFormDataThread.OnResult       := OnResult;
    SendFormDataThread.FreeOnTerminate:= False;
    SendFormDataThread.Start;

    //SendFormDataThread.WaitFor;
    while not SendFormDataThread.Terminated do
      Application.ProcessMessages;
  finally
    SendFormDataThread.Free;
    HideProcessDlg;
  end;

  Result:= FOutStr;
end;

function TOpenAI.SendJson(AUrl: string; SendObj: TJSONObject): string;
var
  AParams: string;
  CustomHeader: TStringArray;
  SendJsonThread: TSendJsonThread;
begin
  AParams:= SendObj.ToString;

  SetLength(CustomHeader, 2);
  CustomHeader[0]:= 'Content-Type: application/json';
  CustomHeader[1]:= 'Authorization: Bearer ' + api_key;

  FOutStr:= '';
  ShowProcessDlg('Http Post ...');
  try
    SendJsonThread:= TSendJsonThread.Create(True);
    SendJsonThread.AUrl           := AUrl;
    SendJsonThread.AParams        := AParams;
    SendJsonThread.CustomHeader   := CustomHeader;
    SendJsonThread.OnResult       := OnResult;
    SendJsonThread.FreeOnTerminate:= False;
    SendJsonThread.Start;

    //SendJsonThread.WaitFor;
    while not SendJsonThread.Terminated do
      Application.ProcessMessages;
  finally
    SendJsonThread.Free;
    HideProcessDlg;
  end;

  Result:= FOutStr;
end;

procedure TOpenAI.ShowProcessDlg(Msg: string);
begin
  if Assigned(FOnProgShow) and
     Assigned(FOnProgHide) then
  begin
    FOnProgShow(Msg);
  end
  else
  begin
    ShowProgDlg(Msg);
  end;
end;

{ TOpenAIThread }

procedure TOpenAIThread.NotiResult;
begin
  if Assigned(FOnResult) then
    FOnResult(Self);
end;

{ TSendJsonThread }

procedure TSendJsonThread.Execute;
var
  i: Integer;
begin
  inherited;

  OutStr:= HttpPost(AUrl, AParams, CustomHeader);
  Synchronize(NotiResult);

  Terminate;
end;

{ TSendFormDataThread }

procedure TSendFormDataThread.Execute;
begin
  inherited;

  OutStr:= HttpPostFormData(AUrl, CustomHeader, zFormData);
  Synchronize(NotiResult);

  Terminate;
end;

end.
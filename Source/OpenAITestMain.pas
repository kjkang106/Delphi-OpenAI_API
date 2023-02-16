unit OpenAITestMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, StrUtils, IniFiles;

type
  TFOpenAITest = class(TForm)
    MemoLog: TMemo;
    BtCreateImage: TButton;
    CbImgList: TComboBox;
    ImgOne: TImage;
    BtLoadImage: TButton;
    CbImgSize: TComboBox;
    EtImgCnt: TSpinEdit;
    CbImgRetFmt: TComboBox;
    MemoPrompt: TMemo;
    BtImageEdit: TButton;
    BtImageVariation: TButton;
    BtLoadMask: TButton;
    ImgMask: TImage;
    TaskDialog1: TTaskDialog;
    BtCompletion: TButton;
    EtMaxToken: TSpinEdit;
    procedure BtCreateImageClick(Sender: TObject);
    procedure CbImgListChange(Sender: TObject);
    procedure BtLoadImageClick(Sender: TObject);
    procedure BtImageEditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtImageVariationClick(Sender: TObject);
    procedure BtLoadMaskClick(Sender: TObject);
    procedure BtCompletionClick(Sender: TObject);
  private
    { Private declarations }
    RootPath, ImgPath: string;
    function  LoadApiKey: string;
    procedure SaveApiKey(ApiKey: string);
    procedure WriteLog(msg: string);
    procedure LoadImage(ImgFileName: string; Image: TImage);
  public
    { Public declarations }
  end;

var
  FOpenAITest: TFOpenAITest;

implementation

uses InetUtil, OpenAI, OpenAIImg, OpenAIHeader, WICImgUtil, ProgressDlg,
  OpenAIComp;

{$R *.dfm}

procedure TFOpenAITest.BtImageEditClick(Sender: TObject);
var
  OpenAIImg: TOpenAIImg;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateImageEdit');
  CbImgList.Items.Clear;

  OpenAIImg:= TOpenAIImg.Create;
  try
    OpenAIImg.api_key := LoadApiKey;
    OpenAIImg.ImgCount:= EtImgCnt.Value;
    OpenAIImg.ImgSize := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt  := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir  := ExtractFilePath(ImgOne.Hint) + FormatDateTime('YYMMDD_HHNNSS', Now);
    OpenAIImg.ImgMask := ImgMask.Hint;
    Response:= OpenAIImg.CreateImageEdit(ImgOne.Hint, MemoPrompt.Text);

    aMax:= OpenAIImg.zImgList.Count;
    for ai:= 0  to aMax - 1 do
      CbImgList.Items.Add(OpenAIImg.zImgList[ai]);
    CbImgList.Tag := Ord(OpenAIImg.ResFmt);
    CbImgList.Hint:= OpenAIImg.ImgDir;
  finally
    OpenAIImg.Free;
    OpenAIImg:= nil;
  end;

  WriteLog(Response);
  if Response = 'OK' then
  begin
    if CbImgList.Items.Count > 0 then
    begin
      CbImgList.ItemIndex:= 0;
      CbImgListChange(CbImgList);
    end;
  end;
end;

procedure TFOpenAITest.BtImageVariationClick(Sender: TObject);
var
  OpenAIImg: TOpenAIImg;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateImageVariation');
  CbImgList.Items.Clear;

  OpenAIImg:= TOpenAIImg.Create;
  try
    OpenAIImg.api_key := LoadApiKey;
    OpenAIImg.ImgCount:= EtImgCnt.Value;
    OpenAIImg.ImgSize := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt  := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir  := ExtractFilePath(ImgOne.Hint) + FormatDateTime('YYMMDD_HHNNSS', Now);
    Response:= OpenAIImg.CreateImageVariation(ImgOne.Hint);

    aMax:= OpenAIImg.zImgList.Count;
    for ai:= 0  to aMax - 1 do
      CbImgList.Items.Add(OpenAIImg.zImgList[ai]);
    CbImgList.Tag := Ord(OpenAIImg.ResFmt);
    CbImgList.Hint:= OpenAIImg.ImgDir;
  finally
    OpenAIImg.Free;
    OpenAIImg:= nil;
  end;

  WriteLog(Response);
  if Response = 'OK' then
  begin
    if CbImgList.Items.Count > 0 then
    begin
      CbImgList.ItemIndex:= 0;
      CbImgListChange(CbImgList);
    end;
  end;
end;

procedure TFOpenAITest.BtLoadImageClick(Sender: TObject);
var
  ImgFileName: string;
begin
  if PromptForFileName(ImgFileName, 'PNG Images|*.png|All Files|*.*',
    '', 'Select Image', ImgPath) then
  begin
    //LoadImage(ImgFileName, ImgOne);
    CbImgList.Tag := Ord(airfB64Json);
    CbImgList.Hint:= ExtractFilePath(ImgFileName);

    CbImgList.Items.Clear;
    CbImgList.Items.Append(ExtractFileName(ImgFileName));
    CbImgList.ItemIndex:= 0;
    CbImgListChange(CbImgList);
  end;
end;

procedure TFOpenAITest.BtLoadMaskClick(Sender: TObject);
var
  ImgFileName: string;
begin
  if PromptForFileName(ImgFileName, 'PNG Images|*.png|All Files|*.*',
    '', 'Select Image', ImgPath) then
  begin
    LoadImage(ImgFileName, ImgMask);
  end;
end;

procedure TFOpenAITest.BtCompletionClick(Sender: TObject);
var
  OpenAIComp: TOpenAIComp;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('Completion');

  OpenAIComp:= TOpenAIComp.Create;
  try
    OpenAIComp.api_key          := LoadApiKey;
    OpenAIComp.Prompt           := MemoPrompt.Text;
    OpenAIComp.Max_tokens       := EtMaxToken.Value;
    OpenAIComp.Temperature      := 0;
    OpenAIComp.Top_p            := 1.0;
    OpenAIComp.Frequency_penalty:= 0.0;
    OpenAIComp.Presence_penalty := 0.0;
    //OpenAIComp.StopStr          := sLineBreak;
    Response:= OpenAIComp.CreateCompletions(LASTEST_MODEL_GPT3);

    aMax:= Length(OpenAIComp.zChoices);
    for ai:= 0  to aMax - 1 do
      WriteLog(OpenAIComp.zChoices[ai]);
  finally
    OpenAIComp.Free;
    OpenAIComp:= nil;
  end;

  WriteLog(Response);
end;

procedure TFOpenAITest.BtCreateImageClick(Sender: TObject);
var
  OpenAIImg: TOpenAIImg;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateImages');
  CbImgList.Items.Clear;

  OpenAIImg:= TOpenAIImg.Create;
  try
    OpenAIImg.api_key := LoadApiKey;
    OpenAIImg.ImgCount:= EtImgCnt.Value;
    OpenAIImg.ImgSize := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt  := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir  := ImgPath + FormatDateTime('YYMMDD_HHNNSS', Now);
    Response:= OpenAIImg.CreateImages(MemoPrompt.Text);

    aMax:= OpenAIImg.zImgList.Count;
    for ai:= 0  to aMax - 1 do
      CbImgList.Items.Add(OpenAIImg.zImgList[ai]);
    CbImgList.Tag := Ord(OpenAIImg.ResFmt);
    CbImgList.Hint:= OpenAIImg.ImgDir;
  finally
    OpenAIImg.Free;
    OpenAIImg:= nil;
  end;

  WriteLog(Response);
  if Response = 'OK' then
  begin
    if CbImgList.Items.Count > 0 then
    begin
      CbImgList.ItemIndex:= 0;
      CbImgListChange(CbImgList);
    end;
  end;
end;

procedure TFOpenAITest.CbImgListChange(Sender: TObject);
var
  Idx: Integer;
  CbImg: TComboBox absolute Sender;
  ImgDir, ImgFile, ImgStr: string;
  strRecv: TMemoryStream;
begin
  Idx:= CbImg.ItemIndex;
  if Idx = -1 then
    Exit;
  ImgStr:= CbImg.Items[Idx];
  if ImgStr = '' then
    Exit;

  ImgDir:= IncludeTrailingPathDelimiter(CbImg.Hint);
  if CbImg.Tag = Ord(airfUrl) then
  begin
    if StartsText('http', ImgStr) then
    begin
      strRecv:= TMemoryStream.Create;
      try
        if HttpGet(ImgStr, strRecv) then
        begin
          ImgFile:= IntToStr(Idx + 1);
          if StrmToFile(strRecv, ImgDir, ImgFile) then
          begin
            CbImg.Items[idx]:= ImgFile;
            CbImg.OnChange:= nil;
            CbImg.ItemIndex:= Idx;
            CbImg.OnChange:= CbImgListChange;

            LoadImage(ImgDir + ImgFile, ImgOne);
          end;
        end;
      finally
        strRecv.Free;
      end;
    end
    else
    begin
      ImgFile:= ImgStr;
      LoadImage(ImgDir + ImgFile, ImgOne);
    end;
  end
  else if CbImg.Tag = Ord(airfB64Json) then
  begin
    ImgFile:= ImgStr;
    LoadImage(ImgDir + ImgFile, ImgOne);
  end;
end;

procedure TFOpenAITest.FormActivate(Sender: TObject);
var
  ApiKey: string;
begin
  OnActivate:= nil;
  if LoadApiKey = '' then
  begin
    ApiKey:= InputBox('API_KEY', 'Input API Key', '');
    if ApiKey = '' then
      PostMessage(Handle, WM_CLOSE, 0, 0)
    else
      SaveApiKey(ApiKey);
  end;
end;

procedure TFOpenAITest.FormCreate(Sender: TObject);
begin
  RootPath:= IncludeTrailingPathDelimiter( GetCurrentDir );
  ImgPath := RootPath + 'Image\';
  ForceDirectories(ImgPath);
end;

function TFOpenAITest.LoadApiKey: string;
var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create(RootPath + 'Init.ini');
  try
    Result:= Ini.ReadString('OpenAI', 'API_KEY', '');
  finally
    Ini.Free;
  end;
end;

procedure TFOpenAITest.LoadImage(ImgFileName: string; Image: TImage);
begin
  if FileExists(ImgFileName) then
  begin
    LoadWicImage(ImgFileName, Image);
    Image.Hint:= ImgFileName;
  end
  else
  begin
    Image.Picture.Assign(nil);
    Image.Hint:= '';
  end;
end;

procedure TFOpenAITest.SaveApiKey(ApiKey: string);
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

procedure TFOpenAITest.WriteLog(msg: string);
begin
  MemoLog.Lines.Append(msg);
end;

end.

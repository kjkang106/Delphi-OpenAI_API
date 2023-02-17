unit OpenAITestMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, StrUtils;

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
    BtMakeMask: TButton;
    BtCompletion: TButton;
    EtMaxToken: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    LbImageFile: TLabel;
    LbMaskFile: TLabel;
    BtClearImgMask: TButton;
    procedure BtCreateImageClick(Sender: TObject);
    procedure CbImgListChange(Sender: TObject);
    procedure BtLoadImageClick(Sender: TObject);
    procedure BtImageEditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtImageVariationClick(Sender: TObject);
    procedure BtMakeMaskClick(Sender: TObject);
    procedure BtCompletionClick(Sender: TObject);
    procedure ImgOneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtClearImgMaskClick(Sender: TObject);
  private
    { Private declarations }
    procedure WriteLog(msg: string);
    procedure LoadImage(ImgFileName: string; Image: TImage);
    procedure SaveAsMaskImage;
  public
    { Public declarations }
  end;

var
  FOpenAITest: TFOpenAITest;

implementation

uses InetUtil, OpenAI, OpenAIImg, OpenAIHeader, WICImgUtil, ProgressDlg,
  OpenAIComp, InitInfo, PNGImgUtil;

{$R *.dfm}

procedure TFOpenAITest.BtImageEditClick(Sender: TObject);
var
  OpenAIImg: TOpenAIImg;
  ImgFileName: string;
  MskFileName: string;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateImageEdit');
  CbImgList.Items.Clear;

  ImgFileName:= LbImageFile.Caption;
  MskFileName:= LbMaskFile.Caption;
  SaveAsMaskImage;

  OpenAIImg:= TOpenAIImg.Create;
  try
    OpenAIImg.api_key := ApiKey;
    OpenAIImg.user_IDs:= EndUserIDs;
    OpenAIImg.ImgCount:= EtImgCnt.Value;
    OpenAIImg.ImgSize := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt  := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir  := ExtractFilePath(ImgFileName) + FormatDateTime('YYMMDD_HHNNSS', Now);
    OpenAIImg.ImgMask := MskFileName;
    Response:= OpenAIImg.CreateImageEdit(ImgFileName, MemoPrompt.Text);

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
  ImgFileName: string;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateImageVariation');
  CbImgList.Items.Clear;

  ImgFileName:= LbImageFile.Caption;

  OpenAIImg:= TOpenAIImg.Create;
  try
    OpenAIImg.api_key := ApiKey;
    OpenAIImg.user_IDs:= EndUserIDs;
    OpenAIImg.ImgCount:= EtImgCnt.Value;
    OpenAIImg.ImgSize := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt  := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir  := ExtractFilePath(ImgFileName) + FormatDateTime('YYMMDD_HHNNSS', Now);
    Response:= OpenAIImg.CreateImageVariation(ImgFileName);

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

procedure TFOpenAITest.BtMakeMaskClick(Sender: TObject);
var
  ImgFileName: string;
  MskFileName: string;
begin
  ImgFileName:= LbImageFile.Caption;
  if ImgFileName = '' then
    Exit;

  MskFileName:= ExtractFilePath(ImgFileName) + 'Mask_' + ExtractFileName(ImgFileName);
  ImgOne.Picture.SaveToFile(MskFileName);

  LbMaskFile.Caption:= MskFileName;
  LoadPngImage(MskFileName, ImgOne);
end;

procedure TFOpenAITest.BtClearImgMaskClick(Sender: TObject);
var
  ImgFileName: string;
begin
  ImgFileName:= LbImageFile.Caption;
  LoadImage(ImgFileName, ImgOne);

  LbMaskFile.Caption:= '';
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
    OpenAIComp.api_key          := ApiKey;
    OpenAIComp.user_IDs         := EndUserIDs;
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
    OpenAIImg.api_key := ApiKey;
    OpenAIImg.user_IDs:= EndUserIDs;
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

  LbImageFile.Caption:= ImgDir + ImgFile;
  LbMaskFile.Caption := '';
end;

procedure TFOpenAITest.FormActivate(Sender: TObject);
begin
  OnActivate:= nil;
  LoadInitInfo;
  if ApiKey = '' then
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

  LbImageFile.Caption:= '';
  LbMaskFile.Caption := '';
end;

procedure TFOpenAITest.ImgOneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  MskFileName: string;
  X1, X2, Y1, Y2: Integer;
  ARect: TRect;
begin
  MskFileName:= LbMaskFile.Caption;
  if MskFileName = '' then
    Exit;

  X1:= X - 10;  X2:= X + 10;
  Y1:= Y - 10;  Y2:= Y + 10;
  if X1 < 0 then X1:= 0;
  if X2 > ImgOne.Width then X2:= ImgOne.Width;
  if Y1 < 0 then Y1:= 0;
  if Y2 > ImgOne.Height then Y2:= ImgOne.Height;
  ARect:= Rect(X1, Y1, X2, Y2);

  PngAddMaskRegion(ImgOne, ARect);
end;

procedure TFOpenAITest.LoadImage(ImgFileName: string; Image: TImage);
begin
  if FileExists(ImgFileName) then
    LoadWicImage(ImgFileName, Image)
  else
    Image.Picture.Assign(nil);
end;

procedure TFOpenAITest.SaveAsMaskImage;
var
  MskFileName: string;
begin
  MskFileName:= LbMaskFile.Caption;
  if MskFileName = '' then
    Exit;
  ImgOne.Picture.SaveToFile(MskFileName);
end;

procedure TFOpenAITest.WriteLog(msg: string);
begin
  MemoLog.Lines.Append(msg);
end;

end.

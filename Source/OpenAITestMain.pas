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
    CbModels: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EtTemperature: TEdit;
    EtTopP: TEdit;
    EtMaskSize: TSpinEdit;
    BtListModels: TButton;
    BtChatCompletion: TButton;
    Label7: TLabel;
    EtRole: TEdit;
    BtTranscription: TButton;
    BtTranslation: TButton;
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
    procedure ImgOneMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImgOneMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgOneDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtListModelsClick(Sender: TObject);
    procedure BtChatCompletionClick(Sender: TObject);
    procedure CbModelsChange(Sender: TObject);
    procedure BtTranscriptionClick(Sender: TObject);
    procedure BtTranslationClick(Sender: TObject);
  private
    { Private declarations }
    lMaskImgDown: Boolean;
    procedure WriteLog(msg: string);
    procedure LoadImage(ImgFileName: string; Image: TImage);
    procedure SaveAsMaskImage;
    procedure LoadLastValues;
    procedure SaveLastValues;
  public
    { Public declarations }
  end;

var
  FOpenAITest: TFOpenAITest;

implementation

uses InetUtil, OpenAI, OpenAIImg, OpenAIHeader, WICImgUtil, ProgressDlg,
  OpenAIComp, InitInfo, PNGImgUtil, ImgView, OpenAIModel, OpenAIChatComp,
  OpenAIStt;

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
    OpenAIImg.api_key     := ApiKey;
    OpenAIImg.organization:= Organization;
    OpenAIImg.user_IDs    := EndUserIDs;
    OpenAIImg.ImgCount    := EtImgCnt.Value;
    OpenAIImg.ImgSize     := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt      := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir      := ExtractFilePath(ImgFileName) + FormatDateTime('YYMMDD_HHNNSS', Now);
    OpenAIImg.ImgMask     := MskFileName;
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
    OpenAIImg.api_key     := ApiKey;
    OpenAIImg.organization:= Organization;
    OpenAIImg.user_IDs    := EndUserIDs;
    OpenAIImg.ImgCount    := EtImgCnt.Value;
    OpenAIImg.ImgSize     := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt      := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir      := ExtractFilePath(ImgFileName) + FormatDateTime('YYMMDD_HHNNSS', Now);
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

procedure TFOpenAITest.BtListModelsClick(Sender: TObject);
var
  OpenAIModel: TOpenAIModel;
  Response: string;
  ai, aMax: Integer;
  bi, bMax: Integer;
  mi: TAiModel;
begin
  WriteLog('ListModel');

  OpenAIModel:= TOpenAIModel.Create;
  try
    OpenAIModel.api_key          := ApiKey;
    OpenAIModel.organization     := Organization;
    OpenAIModel.user_IDs         := EndUserIDs;

    Response:= OpenAIModel.ListModels;

    aMax:= Length(OpenAIModel.zModelData);
    for ai:= 0  to aMax - 1 do
    begin
      for mi:= Low(TAiModel) to High(TAiModel) do
      begin
        if AimToStr(mi) = OpenAIModel.zModelData[ai].DataID then
        begin
          WriteLog(IntToStr(ai + 1) + '. ' + OpenAIModel.zModelData[ai].DataID);
          bMax:= Length(OpenAIModel.zModelData[ai].DataPerm);
          for bi:= 0 to bMax - 1 do
          begin
            WriteLog(' > PermID     = ' + OpenAIModel.zModelData[ai].DataPerm[bi].PermID);
            WriteLog(' > AllowView  = ' + IfThen(OpenAIModel.zModelData[ai].DataPerm[bi].AllowView, 'True', 'False'));
            WriteLog(' > IsBlocking = ' + IfThen(OpenAIModel.zModelData[ai].DataPerm[bi].IsBlocking, 'True', 'False'));
          end;
          Break;
        end;
      end;
    end;
  finally
    OpenAIModel.Free;
    OpenAIModel:= nil;
  end;

  WriteLog(Response);
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

procedure TFOpenAITest.BtTranscriptionClick(Sender: TObject);
var
  OpenAIStt: TOpenAIStt;
  AudioFileName: string;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateTranscription');

  if not PromptForFileName(AudioFileName,
    'Audios|*.mp3;*.mp4;*.mpeg;*.mpga;*.m4a;*.wav;*.webm|All Files|*.*',
    '', 'Select Audio', AudioPath) then
  begin
    Exit;
  end;

  OpenAIStt:= TOpenAIStt.Create;
  try
    OpenAIStt.api_key     := ApiKey;
    OpenAIStt.organization:= Organization;
    OpenAIStt.user_IDs    := EndUserIDs;
    OpenAIStt.Prompt      := MemoPrompt.Text;
    OpenAIStt.ResFmt      := asrfJson;
    Response:= OpenAIStt.CreateTranscription(AudioFileName, LASTEST_MODEL_STT);

    if Response = 'OK' then
      WriteLog(OpenAIStt.RltText);
  finally
    OpenAIStt.Free;
    OpenAIStt:= nil;
  end;

  WriteLog(Response);
end;

procedure TFOpenAITest.BtTranslationClick(Sender: TObject);
var
  OpenAIStt: TOpenAIStt;
  AudioFileName: string;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('CreateTranslation');

  if not PromptForFileName(AudioFileName,
    'Audios|*.mp3;*.mp4;*.mpeg;*.mpga;*.m4a;*.wav;*.webm|All Files|*.*',
    '', 'Select Audio', AudioPath) then
  begin
    Exit;
  end;

  OpenAIStt:= TOpenAIStt.Create;
  try
    OpenAIStt.api_key     := ApiKey;
    OpenAIStt.organization:= Organization;
    OpenAIStt.user_IDs    := EndUserIDs;
    OpenAIStt.Prompt      := MemoPrompt.Text;
    OpenAIStt.ResFmt      := asrfJson;
    Response:= OpenAIStt.CreateTranslation(AudioFileName, LASTEST_MODEL_STT);

    if Response = 'OK' then
      WriteLog(OpenAIStt.RltText);
  finally
    OpenAIStt.Free;
    OpenAIStt:= nil;
  end;

  WriteLog(Response);
end;

procedure TFOpenAITest.BtChatCompletionClick(Sender: TObject);
var
  OpenAIChatComp: TOpenAIChatComp;
  Response: string;
  ai, aMax: Integer;
begin
  WriteLog('ChatCompletion');

  OpenAIChatComp:= TOpenAIChatComp.Create;
  try
    OpenAIChatComp.api_key          := ApiKey;
    OpenAIChatComp.organization     := Organization;
    OpenAIChatComp.user_IDs         := EndUserIDs;
    OpenAIChatComp.AddChatMessage(EtRole.Text, MemoPrompt.Text);
    OpenAIChatComp.Max_tokens       := EtMaxToken.Value;
    OpenAIChatComp.Temperature      := StrToFloatDef(EtTemperature.Text, 0);
    OpenAIChatComp.Top_p            := StrToFloatDef(EtTopP.Text, 0);
    OpenAIChatComp.Frequency_penalty:= 0.0;
    OpenAIChatComp.Presence_penalty := 0.0;
    //OpenAIChatComp.StopStr          := sLineBreak;

    Response:= OpenAIChatComp.CreateChatCompletions( AimToStr(IntToAim(CbModels.ItemIndex)) );

    aMax:= Length(OpenAIChatComp.zChoices);
    for ai:= 0  to aMax - 1 do
      WriteLog(Format('[%s]%s', [OpenAIChatComp.zChoices[ai].Role, OpenAIChatComp.zChoices[ai].Content]));
  finally
    OpenAIChatComp.Free;
    OpenAIChatComp:= nil;
  end;

  WriteLog(Response);
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
    OpenAIComp.organization     := Organization;
    OpenAIComp.user_IDs         := EndUserIDs;
    OpenAIComp.Prompt           := MemoPrompt.Text;
    OpenAIComp.Max_tokens       := EtMaxToken.Value;
    OpenAIComp.Temperature      := StrToFloatDef(EtTemperature.Text, 0);
    OpenAIComp.Top_p            := StrToFloatDef(EtTopP.Text, 0);
    OpenAIComp.Frequency_penalty:= 0.0;
    OpenAIComp.Presence_penalty := 0.0;
    //OpenAIComp.StopStr          := sLineBreak;

    Response:= OpenAIComp.CreateCompletions( AimToStr(IntToAim(CbModels.ItemIndex)) );

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
    OpenAIImg.api_key     := ApiKey;
    OpenAIImg.organization:= Organization;
    OpenAIImg.user_IDs    := EndUserIDs;
    OpenAIImg.ImgCount    := EtImgCnt.Value;
    OpenAIImg.ImgSize     := IntToAis (CbImgSize.ItemIndex);
    OpenAIImg.ResFmt      := IntToAirf(CbImgRetFmt.ItemIndex);
    OpenAIImg.ImgDir      := ImgPath + FormatDateTime('YYMMDD_HHNNSS', Now);
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

procedure TFOpenAITest.CbModelsChange(Sender: TObject);
var
  nIdx: Integer;
  aim: TAiModel;
begin
  nIdx:= TComboBox(Sender).ItemIndex;
  if nIdx < 0 then
    Exit;
  if nIdx > Ord(High(TAiModel)) then
    Exit;
  aim:= TAiModel(nIdx);
  case aim of
    aimVer40,
    aimVer35:
      begin
        BtCompletion.Enabled    := False;
        BtChatCompletion.Enabled:= True;
      end;
    else
      begin
        BtCompletion.Enabled    := True;
        BtChatCompletion.Enabled:= False;
      end;
  end;
end;

procedure TFOpenAITest.FormActivate(Sender: TObject);
begin
  OnActivate:= nil;
  LoadInitInfo;
  if ApiKey = '' then
    ApiKey:= InputBox('API_KEY', 'Input API Key', '');

  if ApiKey = '' then
    PostMessage(Handle, WM_CLOSE, 0, 0)
  else
  begin
    SaveApiKey(ApiKey);
    LoadLastValues;
  end;
end;

procedure TFOpenAITest.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveLastValues;
end;

procedure TFOpenAITest.FormCreate(Sender: TObject);
begin
  RootPath := IncludeTrailingPathDelimiter( GetCurrentDir );
  ImgPath  := RootPath + 'Image\';
  ForceDirectories(ImgPath);
  AudioPath:= RootPath + 'Audio\';
  ForceDirectories(AudioPath);

  LbImageFile.Caption:= '';
  LbMaskFile.Caption := '';
end;

procedure TFOpenAITest.ImgOneDblClick(Sender: TObject);
var
  ImgFileName: string;
begin
  if ImgOne.Picture = nil then
    Exit;
  ImgFileName:= LbMaskFile.Caption;
  if ImgFileName = '' then
    ImgFileName:= LbImageFile.Caption;

  if ImgFileName <> '' then
    PopImgView(Self, ImgFileName);
end;

procedure TFOpenAITest.ImgOneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  MskFileName: string;
begin
  MskFileName:= LbMaskFile.Caption;
  if MskFileName = '' then
    Exit;

  lMaskImgDown:= PngAddMaskStart(ImgOne);
end;

procedure TFOpenAITest.ImgOneMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  X1, X2, Y1, Y2: Integer;
  ARect: TRect;
  MaskSize: Integer;
begin
  if lMaskImgDown then
  begin
    MaskSize:= StrToIntDef(EtMaskSize.Text, 5);
    X1:= X - MaskSize;  X2:= X + MaskSize;
    Y1:= Y - MaskSize;  Y2:= Y + MaskSize;
    if X1 < 0 then X1:= 0;
    if X2 > ImgOne.Width then X2:= ImgOne.Width;
    if Y1 < 0 then Y1:= 0;
    if Y2 > ImgOne.Height then Y2:= ImgOne.Height;
    ARect:= Rect(X1, Y1, X2, Y2);

    PngAddMaskRegion(ImgOne, ARect);
  end;
end;

procedure TFOpenAITest.ImgOneMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if lMaskImgDown then
  begin
    lMaskImgDown:= False;
    PngAddMaskEnd(ImgOne);
  end;
end;

procedure TFOpenAITest.LoadImage(ImgFileName: string; Image: TImage);
begin
  if FileExists(ImgFileName) then
    LoadWicImage(ImgFileName, Image)
  else
    Image.Picture.Assign(nil);
end;

procedure TFOpenAITest.LoadLastValues;
begin
  EtImgCnt.Text        := LoadLastInfo('Image_Count'  , EtImgCnt.Text);
  CbImgSize.ItemIndex  := LoadLastInfo('Image_Size'   , CbImgSize.ItemIndex);
  CbImgRetFmt.ItemIndex:= LoadLastInfo('Image_Format' , CbImgRetFmt.ItemIndex);

  EtMaskSize.Text      := LoadLastInfo('Mask_Size'    , EtMaskSize.Text);
  CbModels.ItemIndex   := LoadLastInfo('Models'       , CbModels.ItemIndex);
  EtMaskSize.Text      := LoadLastInfo('Mask_Size'    , EtMaskSize.Text);
  EtMaxToken.Text      := LoadLastInfo('Mask_Token'   , EtMaxToken.Text);
  EtTemperature.Text   := LoadLastInfo('Temperature'  , EtTemperature.Text);
  EtTopP.Text          := LoadLastInfo('EtTopP'       , EtTopP.Text);
  MemoPrompt.Text      := LoadLastInfo('Prompt'       , MemoPrompt.Text);

  EtRole.Text          := LoadLastInfo('Role'         , EtRole.Text);

  CbModelsChange(CbModels);
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

procedure TFOpenAITest.SaveLastValues;
begin
  if ApiKey = '' then
    Exit;

  SaveLastInfo('Image_Count'  , EtImgCnt.Text);
  SaveLastInfo('Image_Size'   , CbImgSize.ItemIndex);
  SaveLastInfo('Image_Format' , CbImgRetFmt.ItemIndex);

  SaveLastInfo('Mask_Size'    , EtMaskSize.Text);
  SaveLastInfo('Models'       , CbModels.ItemIndex);
  SaveLastInfo('Mask_Size'    , EtMaskSize.Text);
  SaveLastInfo('Mask_Token'   , EtMaxToken.Text);
  SaveLastInfo('Temperature'  , EtTemperature.Text);
  SaveLastInfo('EtTopP'       , EtTopP.Text);
  SaveLastInfo('Prompt'       , MemoPrompt.Text);

  SaveLastInfo('Role'         , EtRole.Text);
end;

procedure TFOpenAITest.WriteLog(msg: string);
begin
  MemoLog.Lines.Append(msg);
end;

end.

program OpenAITest;

uses
  Forms,
  OpenAITestMain in 'OpenAITestMain.pas' {FOpenAITest},
  InetUtil in 'Utils\InetUtil.pas',
  JSonUtil in 'Utils\JSonUtil.pas',
  StrUtil in 'Utils\StrUtil.pas',
  WICImgUtil in 'Utils\WICImgUtil.pas',
  WinHTTPUtil in 'Utils\WinHTTPUtil.pas',
  OpenAI in 'OpenAI\OpenAI.pas',
  OpenAIHeader in 'OpenAI\OpenAIHeader.pas',
  OpenAIImg in 'OpenAI\OpenAIImg.pas',
  ProgressDlg in 'OpenAI\ProgressDlg.pas' {FProgressDlg},
  ToneDown in 'Utils\ToneDown.pas' {FToneDown};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown:= True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFOpenAITest, FOpenAITest);
  Application.Run;
end.
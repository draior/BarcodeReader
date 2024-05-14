program BarcodeHook64;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Options in 'Options.pas' {fOptions},
  uTLBProcs in 'uTLBProcs.pas',
  BarCodeHook64_TLB in 'BarCodeHook64_TLB.pas';

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.ShowMainForm := False;
  Application.CreateForm(TfOptions, fOptions);
  Application.Run;
end.

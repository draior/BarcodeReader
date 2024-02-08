program BarCodeHook;

uses
  ShareMem,
  Forms,
  Main in 'Main.pas' {fMain},
  BarCodeHook_TLB in 'BarCodeHook_TLB.pas',
  uTLBProcs in 'uTLBProcs.pas' {msg: CoClass},
  Options in 'Options.pas' {fOptions};

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.ShowMainForm := False;
  Application.CreateForm(TfOptions, fOptions);
  Application.Run;
end.

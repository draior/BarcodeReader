unit Options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Main, Registry ;

type
  TfOptions = class(TForm)
    cbRepeatFreq: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnSave: TButton;
    btnCancel: TButton;
    cbShowOnLoad: TCheckBox;
    cbAsciiCode_Start: TComboBox;
    cbAsciiCode_End: TComboBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbShowOnLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fOptions: TfOptions;

implementation

{$R *.DFM}

procedure TfOptions.btnCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfOptions.btnSaveClick(Sender: TObject);
var
  Reg: TRegistry;
begin
  Reg:=TRegistry.Create;
  try
    Reg.RootKey:=HKEY_CLASSES_ROOT;
    Reg.OpenKey('\Z5DM\Default01', True);
    Reg.WriteString('smbStart', cbAsciiCode_Start.Text);
    Reg.WriteString('smbStop', cbAsciiCode_End.Text);
    Reg.WriteString('smbMs', cbRepeatFreq.Text);

    smbDelay := StrToInt(cbRepeatFreq.Text);
    smbStartSymbol := StrToInt(cbAsciiCode_Start.Text);
    smbStopSymbol := StrToInt(cbAsciiCode_End.Text);
  finally
    Reg.Free;
  end;

  Self.Close;
end;

procedure TfOptions.FormShow(Sender: TObject);
var
  i: Integer;
begin
  cbRepeatFreq.Clear;
  cbAsciiCode_Start.Clear;
  cbAsciiCode_End.Clear;
  for i := 0 to 90 do
    cbRepeatFreq.Items.Add(IntToStr(i));

  for i := 0 to 255 do begin
    cbAsciiCode_Start.Items.Add(IntToStr(i));
    cbAsciiCode_End.Items.Add(IntToStr(i));
  end;

  cbAsciiCode_Start.Text := IntToStr(smbStartSymbol);
  cbAsciiCode_End.Text := IntToStr(smbStopSymbol);
  cbRepeatFreq.Text := IntToStr(smbDelay);

  cbShowOnLoad.Checked := bIsVisible
end;

procedure TfOptions.cbShowOnLoadClick(Sender: TObject);
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CLASSES_ROOT;
    Reg.OpenKey('\Z5DM\Default01', True);

    if cbShowOnLoad.Checked then
      Reg.WriteString('vis', '1')
    else
      Reg.WriteString('vis', '0');

    bIsVisible := cbShowOnLoad.Checked;
  finally
    Reg.Free;
  end;
end;

end.

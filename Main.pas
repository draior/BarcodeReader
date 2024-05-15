{
        The main Form  ->
        When Created   -> We are hooking ON;
        When Destroyed -> We are hooking OFF;

        The form References the "BarCodeDLL.dll",
        which is the actual Hook and use FileMapping
        to communicate with it.

        Unit2 contains a COM object, used to hold an array of
        handles. The COM object is Single Instanced - multiple
        applications work with only one instance of it. Every Client 
        that is started, passes its handle to the COM object,
        which is stored in the array. 

        When a key is pressed, nothing happens.
        When a bar-code is scanned, (The barcode symbols
        are read in 5-15 ms each), the barcode is send by
        PostMessage to the handles,are specified in the
        array in Unit2.
}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, uTLBProcs,
  StdCtrls, ComCtrls, Menus, StBase, Registry, Vcl.ExtCtrls, Vcl.ImgList;

const
  DLLName = 'DLL_BarCode64.dll';
  CM_MANDA_TECLA = WM_USER + $1000;

type
  THookOnProc = function(ThrdID: THandle): HHook; stdcall;  //HookOn
  THookOffProc = procedure(AHook: HHook); stdcall;  //HookOff
  TSetActiveHookProc = procedure(AHook: HHook); stdcall; //SetActiveHook

  TfMain = class(TForm)
    eBarCodeStr: TEdit;
    Label1: TLabel;
    btnEnter: TButton;
    PopupMenu1: TPopupMenu;
    miOptions: TMenuItem;
    miShow: TMenuItem;
    btnOptions: TButton;
    miExit: TMenuItem;
    TrayIcon: TTrayIcon;
    ImageList: TImageList;
    tStart: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure btnEnterClick(Sender: TObject);
    procedure miShowClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure eBarCodeStrKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnEnterKeyPress(Sender: TObject; var Key: Char);
    procedure miExitClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure tStartTimer(Sender: TObject);
  private
    { Private declarations }
     MyHandle: THandle;
     PReceptor: ^Integer;
     HandleDLL: THandle;
     timMsec: Double;
     barCodeStr: String;
     HookOn: THookOnProc;
     HookOff: THookOffProc;
     SetHook: TSetActiveHookProc;
     
     procedure LlegaDelHook(var message: TMessage); message CM_MANDA_TECLA;
     procedure OnMinimize(Sender: TObject);
  public
    { Public declarations }
    function SetHookOn(ThrdID: THandle): HHook;
    procedure SetHookOff(AHook: HHook);
    procedure SetActiveHook(AHook: HHook; Hnd: THandle);
  end;

var
  fMain: TfMain;

  smbDelay: Integer;
  smbStartSymbol: Integer;
  smbStopSymbol: Integer;
  bIsVisible: Boolean;
  Show_Flag: Boolean = false;
  CurrentActiveHandle: THandle;

implementation

uses Options;

{$R *.DFM}

function TranslateKeyToCharacter(VirtualKey: Byte; ShiftPressed: Boolean): Char;
var
  KeyboardState: TKeyboardState;
  UnicodeBuffer: array[0..1] of WideChar;
  len: Integer;
begin
  // Prepare keyboard state with Shift key status
  FillChar(KeyboardState, SizeOf(KeyboardState), 0);
  if ShiftPressed then
    keyboardState[VK_SHIFT] := $80; // Set the Shift key state in the keyboard state array

  // Translate the virtual key to Unicode characters
  len := ToUnicodeEx(virtualKey, MapVirtualKey(virtualKey, 0), @keyboardState,
    unicodeBuffer, Length(unicodeBuffer), 0, GetKeyboardLayout(0));

  // Check if translation was successful and return the resulting character
  if len > 0 then
    Result := unicodeBuffer[0]
  else
    Result := #0; // No valid character produced
end;

var
  prevIsShift: boolean = false;

procedure TfMain.LlegaDelHook(var message: TMessage);
var
  lcAtom: LongWord;
  barcode: PChar;
  readCh: Integer;
  AbarCodeStr: String;
begin
  {Reads The Pressed Key}
  readCh := Message.WParam;

  if (prevIsShift) then
    readCh := Ord(TranslateKeyToCharacter(readCh, true));

  prevIsShift := readCh = VK_SHIFT;

  if readCh = smbStartSymbol then
    barCodeStr := '';       { Clear the BarCode String; }

  {If the End Of BarCode Arrived}
  if (readCh = smbStopSymbol) and ((GetTickCount - timMsec) < smbDelay) then begin
    {Convert To PChar To Use ATOMs}

    eBarCodeStr.Text := barCodeStr;
    GetMem(barcode, (Length(barCodeStr) + 1));

    StrPCopy(barcode, barCodeStr);

    AbarCodeStr := barCodeStr;
    barCodeStr := '';
    lcAtom := GlobalAddAtom(barcode);

    PostMessage(CurrentActiveHandle, CM_MANDA_TECLA, lcAtom, 0);

    FreeMem(barcode);

    BarCodeStr := '';
  end;

  { If the Incomming String is a Barcode ?
    The Barcode symbols come between 5 and 15 ms each }
  if ((GetTickCount - timMsec) < smbDelay) then begin
    if (readCh <> smbStopSymbol) and (readCh <> smbStartSymbol) then
      barCodeStr := barCodeStr + chr(readCh);
  end;

  timMsec := GetTickCount;
end;

//--------InitialionCRC--------------------------------------------------------
function InitialionReg: Boolean;
var
  Reg: TRegistry;
  bTmp: String;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if (not Reg.OpenKey('\Z5DM\Default01', False)) then begin
      Reg.OpenKey('\Z5DM\Default01', True);
      Reg.WriteString('smbStart', '51');
      Reg.WriteString('smbStop', '13');
      Reg.WriteString('smbMs', '25');

      smbDelay := 25;
      smbStartSymbol := 51;
      smbStopSymbol := 13;
      bIsVisible := True;
    end
    else begin
      smbDelay := StrToInt(Reg.ReadString('smbMs'));
      smbStartSymbol := StrToInt(Reg.ReadString('smbStart'));
      smbStopSymbol := StrToInt(Reg.ReadString('smbStop'));
      bIsVisible := False;
      try
        bTmp := Reg.ReadString('vis');

        if bTmp = '1' then
          bIsVisible := True;
      except
      end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  {Hooking - Creating FileMapping;}
  InitialionReg;

  Self.Top := Screen.Height - Self.Height - 30;
  Self.Left := Screen.Width  - Self.Width;

  timMsec := GetTickCount;
  HandleDLL := LoadLibrary(PChar(DLLName));
  if HandleDLL = 0 then
    raise Exception.Create('DLL not found');

  HookOn := GetProcAddress(HandleDLL, 'HookOn');
  HookOff := GetProcAddress(HandleDLL, 'HookOff');
  SetHook := GetProcAddress(HandleDLL, 'SetActiveHook');

  if not Assigned(HookOn) or not Assigned(HookOff) or not Assigned(SetHook) then
    raise Exception.Create('Can''t find the required DLL functions');

  //org CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(Integer), 'ElReceptor');
  MyHandle := CreateFileMapping(THandle(-1), nil, PAGE_READWRITE, 0, SizeOf(Integer), 'ElReceptor');

  if MyHandle = 0 then
    raise Exception.Create( 'Error while creating file');

  PReceptor := MapViewOfFile(MyHandle, FILE_MAP_WRITE, 0, 0, 0);

  PReceptor^ := Handle;

  Application.OnMinimize := OnMinimize;

  tStart.Enabled := True;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  {Unhooking and Cleaning Up. }
  {if Assigned(HookOff) then
    HookOff;}

  if HandleDLL <> 0 then
    FreeLibrary(HandleDLL);

  if MyHandle <> 0 then begin
    UnmapViewOfFile(PReceptor);
    CloseHandle(MyHandle);
  end;
end;

procedure TfMain.btnOptionsClick(Sender: TObject);
begin
  fOptions.Visible := True;
end;

procedure TfMain.btnEnterClick(Sender: TObject);
var
  lcAtom: LongWord;
  barcode: PChar;
begin
  GetMem(Barcode, (StrLen(PChar(eBarCodeStr.Text)) + 1));
  StrPCopy(Barcode, eBarCodeStr.Text);
  lcAtom := GlobalAddAtom(barcode);

  PostMessage(CurrentActiveHandle, CM_MANDA_TECLA, lcAtom, 0);

  FreeMem(Barcode);
  fMain.eBarCodeStr.Text := '';
  fMain.eBarCodeStr.SetFocus;
  fMain.Hide;
end;

procedure TfMain.miShowClick(Sender: TObject);
begin
  Show_Flag := true;
  fMain.Show;
end;

procedure TfMain.OnMinimize(Sender: TObject);
begin
  Hide; // This is to hide it from taskbar
  TrayIcon.Visible := True;
end;

procedure TfMain.miOptionsClick(Sender: TObject);
begin
  fOptions.Show;
end;

procedure TfMain.eBarCodeStrKeyPress(Sender: TObject; var Key: Char);
begin
  if (Ord(Key)) = 27 then //ESC
    eBarCodeStr.Text := '';
end;

procedure TfMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  eBarCodeStr.Text := '';
end;

procedure TfMain.btnEnterKeyPress(Sender: TObject; var Key: Char);
begin
  if (Ord(key)) = 27 then begin//ESC
    eBarCodeStr.Text := '';
    eBarCodeStr.SetFocus;
  end;
end;

procedure TfMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfMain.FormPaint(Sender: TObject);
begin
  fMain.Visible := Show_Flag;
end;

procedure TfMain.TrayIconDblClick(Sender: TObject);
begin
  TrayIcon.Visible := Visible;
  if Visible then  // Application is visible, so minimize it to TrayIcon
    Application.Minimize // This is to minimize the whole application
  else begin // Application is not visible, so show it
    Show; // This is to show it from taskbar
    Application.Restore; // This is to restore the whole application
    Application.BringToFront;
  end;
end;

procedure TfMain.tStartTimer(Sender: TObject);
begin
  tStart.Enabled := False;
  OnMinimize(Sender);
end;

function TfMain.SetHookOn(ThrdID: THandle): HHook;
begin
  Result := HookOn(ThrdID);
end;

procedure TfMain.SetHookOff(AHook: HHook);
begin
  HookOff(AHook);
end;

procedure TfMain.SetActiveHook(AHook: HHook; Hnd: THandle);
begin
  SetHook(AHook);
  CurrentActiveHandle := Hnd;
end;

end.

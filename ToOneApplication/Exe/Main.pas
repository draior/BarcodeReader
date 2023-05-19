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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uTLBProcs,
  StdCtrls, ComCtrls, Menus, StBase, StShBase, StTrIcon ,Registry ,CommonUtilities,
  XPMenu;


const
  DLLName         = 'DLL_BarCode.dll';
  CM_MANDA_TECLA  = WM_USER + $1000;

type
  THookOnProc = function(ThrdID: THandle): HHook; stdcall;  //HookOn
  THookOffProc = procedure(AHook: HHook); stdcall;  //HookOff
  TSetActiveHookProc = procedure(AHook: HHook); stdcall; //SetActiveHook

type
  TfMain = class(TForm)
    eBarCodeStr: TEdit;
    Label1: TLabel;
    btnEnter: TButton;
    StTrayIcon: TStTrayIcon;
    PopupMenu: TPopupMenu;
    miOptions: TMenuItem;
    miShow: TMenuItem;
    btnOptions: TButton;
    miExit: TMenuItem;
    XPMenu: TXPMenu;
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
    procedure StTrayIconDblClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; var RestoreApp: Boolean);
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
     {$IFOPT O-}
     L: TStringList;
     {$ENDIF}
     
     procedure LlegaDelHook(var message: TMessage); message  CM_MANDA_TECLA;
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
  Show_Flag: Boolean = False;
  CurrentActiveHandle: THandle;

implementation

uses Options;

{$R *.DFM}

procedure TfMain.LlegaDelHook(var Message: TMessage);
var
  lcAtom: LongWord;
  barcode: PChar;
  readCh: Integer;
begin
  {Reads The Pressed Key}
  readCh := Message.WParam;

  //showmessage(Chr(readCh));
  L.Text :=  L.Text+'['+IntToStr(readCh)+'] ';
  if readCh = smbStartSymbol then
    barCodeStr := '';       { Clear the BarCode String; }

  {If the End Of BarCode Arrived}
  if (readCh = smbStopSymbol) and ((GetTickCount - timMsec) < smbDelay) then begin
    {Convert To PChar To Use ATOMs}

    eBarCodeStr.Text := barCodeStr;
    //if readCh = smbStopSymbol then
      //ShowMessage(barCodeStr);
    GetMem(barcode, (Length(barCodeStr) + 1));

    StrPCopy(barcode, barCodeStr);

    barCodeStr := '';
    lcAtom := GlobalAddAtom(barcode);

    {if cnt <> 0 then                // If There Any Handles;
    for i := 0 to cnt-1 do          // Loop All the Handles;
    begin
      PostMessage(THandle(hnd[i]), CM_MANDA_TECLA, lcAtom, 0);
    end;}

    PostMessage(CurrentActiveHandle, CM_MANDA_TECLA, lcAtom, 0);

    FreeMem(barcode);

    BarCodeStr := '';
  end;

  { If the Incomming String is a Barcode ?
    The Barcode symbols come between 5 and 15 ms each }
  if ((GetTickCount - timMsec) < smbDelay) then begin
    if (readCh <> smbStopSymbol) and (readCh <> smbStartSymbol) then begin
      if lo(readCh) = $BD then
       readCh := $2D;
      barCodeStr := barCodeStr + Chr(Lo(readCh));
      //barCodeStr2 := barCodeStr2 + Chr(Lo(readCh));
    end;
    {$IFOPT O-}
    L.Text := Trim(L.Text) + ' [' + IntToStr(readCh) + ']' + Chr(Lo(readCh));
    if readCh = smbStopSymbol then
      L.Text := Trim(L.Text) + #13#10'> ';
    L.SaveToFile('C:\Temp\Barcode.txt');
    {$ENDIF}
  end;
  timMsec := GetTickCount;
end;

//--------InitialionCRC--------------------------------------------------------
function InitialionReg: Boolean;
var
  Reg: TRegistry;
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
      //bIsVisible :=  Reg.ReadBool('vis');
    end;
  finally
    FreeAndNil(Reg);
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  {Hooking - Creating FileMapping;}
  InitialionReg;

  Self.Top := Screen.Height - Self.Height - 30;
  Self.Left:= Screen.Width  - Self.Width;

  timMsec := GetTickCount;
  HandleDLL := LoadLibrary(PChar(ExtractFilePath(Application.Exename) + DLLName));
  if HandleDLL = 0 then
    raise Exception.Create('DLL not found');

  HookOn  := GetProcAddress(HandleDLL, 'HookOn');
  HookOff := GetProcAddress(HandleDLL, 'HookOff');
  SetHook := GetProcAddress(HandleDLL, 'SetActiveHook');

  if not Assigned(HookOn) or not Assigned(HookOff) or not Assigned(SetHook) then
    raise Exception.Create('Can''t find the required DLL functions');

  MyHandle := CreateFileMapping( $FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(Integer), 'ElReceptor');

  if MyHandle = 0 then
    raise Exception.Create( 'Error while creating file');

  PReceptor := MapViewOfFile(MyHandle, FILE_MAP_WRITE, 0, 0, 0);

  PReceptor^ := Handle;

  {$IFOPT O-}
  L := TStringList.Create;
  L.Text := '> ';
  {$ENDIF}
  //HookOn(ThreadID);
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
  {$IFOPT O-}
  L.SaveToFile(ChangeFileExt(Application.ExeName, '.log'));
  FreeAndNil(L);
  {$ENDIF}
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

  {if cnt <> 0 then                // If There Any Handles;
    for i := 0 to cnt - 1 do          // Loop All the Handles;
      PostMessage(THandle(hnd[i]), CM_MANDA_TECLA ,lcAtom,0);}
  PostMessage(CurrentActiveHandle, CM_MANDA_TECLA ,lcAtom,0);    

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

procedure TfMain.StTrayIconDblClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; var RestoreApp: Boolean);
begin
  Show_Flag := True;
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




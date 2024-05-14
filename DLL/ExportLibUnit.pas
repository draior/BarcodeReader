unit ExportLibUnit;

interface

uses
  Windows, Messages, Sysutils, Registry, Classes;

const
  CM_MANDA_TECLA = WM_USER + $1000;

var
  HookDeTeclado: HHook;
  FicheroM: THandle;
  PReceptor: ^Integer;
  TimMsec: Double;
  StartBit: Longint;
  TimDelay: Double;
  BCStarted: Boolean;

procedure SetActiveHook(AHook: HHook); cdecl;
function HookOn(ThrdID: THandle): HHook; cdecl;
procedure HookOff(AHook: HHook); cdecl;

implementation

function CallBackDelHook(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  // Check if the code is less than 0, indicating a message sent to a hook procedure
  if Code < 0 then
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);

  // Check if the key event is a key up event and BCStarted flag is false
  if (((lParam and $80000000) shr 31) = 1) and (not BCStarted) then
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);

   // Check if the key event is a key down event
  if (((lParam and $80000000) shr 31) = 0) then begin
    // If the pressed key matches StartBit, record the tick count
    if (wParam = StartBit) then
      TimMsec := GetTickCount;

    // If the time elapsed since the last key press is less than TimDelay
    // 24.05.01 added code = 0
    if (Code = HC_ACTION) and ((GetTickCount - TimMsec) < TimDelay) then begin
      BCStarted := True;
      // Attempt to open a file mapping named 'ElReceptor'
      FicheroM := OpenFileMapping(FILE_MAP_READ, False, 'ElReceptor');
      if FicheroM <> 0 then begin
        // Map the file into memory and send a custom message (CM_MANDA_TECLA)
        PReceptor := MapViewOfFile(FicheroM, FILE_MAP_READ, 0, 0, 0);

        PostMessage(PReceptor^, CM_MANDA_TECLA, wParam, lParam);

        UnmapViewOfFile(PReceptor);
        CloseHandle(FicheroM);
      end;
    end
    else begin
      Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);
      BCStarted := False;
    end;
  end;

  TimMsec := GetTickCount;
end;

function HookOn(ThrdID: THandle): HHook;
begin
  HookDeTeclado := SetWindowsHookEx(WH_KEYBOARD, @CallBackDelHook, HInstance, ThrdID);
  Result := HookDeTeclado;

  BCStarted := False;
end;

procedure HookOff(AHook: HHook); cdecl;
begin
  //UnhookWindowsHookEx(HookDeTeclado);
  UnhookWindowsHookEx(AHook);
end;

procedure SetActiveHook(AHook: HHook);
begin
  HookDeTeclado := AHook;
end;

procedure LoadValues;
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create;

    Reg.RootKey := HKEY_CLASSES_ROOT;
    if (Reg.OpenKey('\Z5DM\Default01', False)) then begin
      StartBit := StrToInt(Reg.ReadString('smbStart'));
      TimDelay := StrToInt(Reg.ReadString('smbMs'));
    end
    else begin
      StartBit := 122;  //F11
      TimDelay := 25;   //25 ms
    end;
  finally
    Reg.Free;
  end;
end;

initialization
  LoadValues;

end.


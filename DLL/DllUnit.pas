unit DllUnit;

interface

uses
  ShareMem, Windows, Messages, Sysutils, Registry, Classes;

//procedure SetActiveHook(AHook: HHook); cdecl;
//function CallBackDelHook(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;
//function HookOn(ThrdID: THandle): HHook; cdecl;
//procedure HookOff(AHook: HHook); cdecl;
function testOn(a1: Integer): Integer; cdecl;

implementation

const
  CM_MANDA_TECLA = WM_USER + $1000;

{var
  HookDeTeclado: HHook;
  FicheroM: THandle;
  PReceptor: ^Integer;
  TimMsec: Double;
  StartBit: Longint;
  TimDelay: Double;
  BCStarted: Boolean;  }

function testOn(a1: Integer): Integer; cdecl;
begin

end;

function CallBackDelHook(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  {if Code < 0 then
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);

  if (((lParam and $80000000) shr 31) = 1) and (not BCStarted) then
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);

  if (((lParam and $80000000) shr 31) = 0) then begin
    if (wParam = StartBit) then
      TimMsec := GetTickCount;

    if ((GetTickCount - TimMsec) < TimDelay) then begin
      BCStarted := True;
      FicheroM := OpenFileMapping(FILE_MAP_READ, False, 'ElReceptor');
      if FicheroM <> 0 then begin
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

  TimMsec := GetTickCount;  }
end;

function HookOn(ThrdID: THandle): HHook;
begin
  {HookDeTeclado := SetWindowsHookEx(WH_KEYBOARD, @CallBackDelHook, HInstance, ThrdID);
  Result := HookDeTeclado;

  BCStarted := False;}
end;

procedure HookOff(AHook: HHook);
begin
  //UnhookWindowsHookEx(HookDeTeclado);
  UnhookWindowsHookEx(AHook);
end;

procedure SetActiveHook(AHook: HHook);
begin
  //HookDeTeclado := AHook;
end;

procedure LoadValues;
var
  Reg: TRegistry;
begin
  {Reg := nil;
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
  end;   }
end;

end.

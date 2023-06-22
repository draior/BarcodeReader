library DLL_BarCode;

uses
  ShareMem, Windows, Messages, Sysutils, Registry, Classes;

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

function CallBackDelHook(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
//var msg:TMSG;
begin
  Result := -1;
  if Code < 0 then begin
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);
    Exit;
  end;

  if (((lParam and $80000000) shr 31) = 1) and (not BCStarted) then begin
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);
    Exit;
  end;

  if (((lParam and $80000000) shr 31) = 0) then begin
    if (wParam = StartBit) then begin
      TimMsec := GetTickCount;
      //BCStarted := True;
    end;

    if ((GetTickCount - TimMsec) < TimDelay) then begin
      BCStarted := True;
      FicheroM := OpenFileMapping(FILE_MAP_READ, False, 'ElReceptor');
      if FicheroM <> 0 then begin
        PReceptor := MapViewOfFile(FicheroM, FILE_MAP_READ, 0, 0, 0);

        PostMessage(PReceptor^, CM_MANDA_TECLA, wParam, lParam);

        UnmapViewOfFile(PReceptor);
        CloseHandle(FicheroM);
      end;
      Result := -1;
    end
    else begin
      Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);
      BCStarted := False;
    end;
  end;

  TimMsec := GetTickCount;
end;

function HookOn(ThrdID: THandle): HHook; stdcall;
begin
  HookDeTeclado := SetWindowsHookEx(WH_KEYBOARD, @CallBackDelHook, HInstance, ThrdID);
  Result := HookDeTeclado;
  BCStarted := False;
end;

procedure HookOff(AHook: HHook);  stdcall;
begin
  //UnhookWindowsHookEx(HookDeTeclado);
  UnhookWindowsHookEx(AHook);
end;

procedure SetActiveHook(AHook: HHook);  stdcall;
begin
  HookDeTeclado := AHook;
end;

procedure LoadValues;
var Reg : TRegistry;
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

exports
  HookOn, HookOff, SetActiveHook;

begin
  LoadValues;
end.


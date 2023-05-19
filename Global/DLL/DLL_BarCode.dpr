library DLL_BarCode;

uses
  ShareMem, Windows, Messages, Sysutils, Registry, Classes, Dialogs;

const
  CM_MANDA_TECLA = WM_USER + $1000;

var
  HookDeTeclado     : HHook;
  FicheroM          : THandle;
  PReceptor         : ^Integer;

  TimMsec           : Double;

  StartBit          : Longint;
  TimDelay          : Double;
  BCStarted : Boolean;

function CallBackDelHook(Code    : Integer;
                         wParam  : WPARAM;
                         lParam  : LPARAM) : LRESULT; stdcall;
begin
  if Code < 0 then
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);


  if (((lParam and $80000000) shr 31) = 1) and (not BCStarted) then
  begin
    Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);
  end;

  if (((lParam and $80000000) shr 31) = 0) then
  begin
    if (wParam = StartBit) then
    begin
      TimMsec := GetTickCount;
      //BCStarted := True;
    end;

    if ((GetTickCount - TimMsec) < TimDelay) then
    begin
      BCStarted := True;
      FicheroM := OpenFileMapping(FILE_MAP_READ, False, 'ElReceptor');
      if FicheroM <> 0 then
      begin
        PReceptor := MapViewOfFile(FicheroM, FILE_MAP_READ, 0, 0, 0);

        PostMessage(PReceptor^, CM_MANDA_TECLA, wParam, lParam);

        UnmapViewOfFile(PReceptor);
        CloseHandle(FicheroM);
      end;
    end
    else
    begin
      Result := CallNextHookEx(HookDeTeclado, Code, wParam, lParam);
      BCStarted := False;
    end;
  end;
  
  TimMsec := GetTickCount;
end;

procedure HookOn; stdcall;
begin
  HookDeTeclado := SetWindowsHookEx(WH_KEYBOARD, @CallBackDelHook, HInstance, 0);

  BCStarted := False;
end;

procedure HookOff;  stdcall;
begin
  UnhookWindowsHookEx(HookDeTeclado);
end;

procedure LoadValues;
var Reg : TRegistry;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create;

    Reg.RootKey := HKEY_CLASSES_ROOT;
    if (Reg.OpenKey('\Z5DM\Default01', False)) then
    begin
      StartBit := StrToInt(Reg.ReadString('smbStart'));
      TimDelay := StrToInt(Reg.ReadString('smbMs'));
    end else
    begin
      StartBit := 122;  //F11
      TimDelay := 25;   //25 ms
    end;
  finally
    Reg.Free;
  end;
end;

exports
  HookOn, HookOff;

begin
  LoadValues;
end.


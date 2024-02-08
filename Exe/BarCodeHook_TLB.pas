unit BarCodeHook_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 08.02.2024 09:01:32 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\_Repository\BarcodeReader\Exe\BarCodeHook (1)
// LIBID: {3EE76143-CE58-451F-8940-E5230F915227}
// LCID: 0
// Helpfile:
// HelpString: BarCodeHook Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  BarCodeHookMajorVersion = 1;
  BarCodeHookMinorVersion = 0;

  LIBID_BarCodeHook: TGUID = '{3EE76143-CE58-451F-8940-E5230F915227}';

  IID_Imsg: TGUID = '{03C7B924-60DC-4C66-A064-F5E4284CC6A7}';
  DIID_ImsgEvents: TGUID = '{17EDFD47-8C33-4333-A8A4-DCC141E26B3C}';
  CLASS_msg: TGUID = '{BD08F4DB-420D-46FA-8F99-55072092D847}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  Imsg = interface;
  ImsgDisp = dispinterface;
  ImsgEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  msg = Imsg;


// *********************************************************************//
// Interface: Imsg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03C7B924-60DC-4C66-A064-F5E4284CC6A7}
// *********************************************************************//
  Imsg = interface(IDispatch)
    ['{03C7B924-60DC-4C66-A064-F5E4284CC6A7}']
    procedure SetHandle(hHanlde: OLE_HANDLE; ThrdID: OLE_HANDLE); safecall;
    function Get_GetHandle: HResult; safecall;
    procedure Show_Form; safecall;
    procedure SetActiveHandle(Hnd: OLE_HANDLE); safecall;
    procedure RemoveHandle(Hnd: OLE_HANDLE); safecall;
    property GetHandle: HResult read Get_GetHandle;
  end;

// *********************************************************************//
// DispIntf:  ImsgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03C7B924-60DC-4C66-A064-F5E4284CC6A7}
// *********************************************************************//
  ImsgDisp = dispinterface
    ['{03C7B924-60DC-4C66-A064-F5E4284CC6A7}']
    procedure SetHandle(hHanlde: OLE_HANDLE; ThrdID: OLE_HANDLE); dispid 1;
    property GetHandle: HResult readonly dispid 4;
    procedure Show_Form; dispid 5;
    procedure SetActiveHandle(Hnd: OLE_HANDLE); dispid 2;
    procedure RemoveHandle(Hnd: OLE_HANDLE); dispid 3;
  end;

// *********************************************************************//
// DispIntf:  ImsgEvents
// Flags:     (0)
// GUID:      {17EDFD47-8C33-4333-A8A4-DCC141E26B3C}
// *********************************************************************//
  ImsgEvents = dispinterface
    ['{17EDFD47-8C33-4333-A8A4-DCC141E26B3C}']
  end;

// *********************************************************************//
// The Class Comsg provides a Create and CreateRemote method to
// create instances of the default interface Imsg exposed by
// the CoClass msg. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  Comsg = class
    class function Create: Imsg;
    class function CreateRemote(const MachineName: string): Imsg;
  end;

implementation

uses System.Win.ComObj;

class function Comsg.Create: Imsg;
begin
  Result := CreateComObject(CLASS_msg) as Imsg;
end;

class function Comsg.CreateRemote(const MachineName: string): Imsg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_msg) as Imsg;
end;

end.


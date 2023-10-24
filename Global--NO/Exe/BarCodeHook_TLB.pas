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

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 15.3.2002 ã. 15:33:16 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\Valio\BarCode\Exe\BarCodeHook.tlb (1)
// IID\LCID: {3EE76143-CE58-451F-8940-E5230F915227}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

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
    procedure SetHandle(hHanlde: Integer); safecall;
    function  Get_GetHandle: HResult; safecall;
    procedure Show_Form; safecall;
    property GetHandle: HResult read Get_GetHandle;
  end;

// *********************************************************************//
// DispIntf:  ImsgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03C7B924-60DC-4C66-A064-F5E4284CC6A7}
// *********************************************************************//
  ImsgDisp = dispinterface
    ['{03C7B924-60DC-4C66-A064-F5E4284CC6A7}']
    procedure SetHandle(hHanlde: Integer); dispid 1;
    property GetHandle: HResult readonly dispid 4;
    procedure Show_Form; dispid 5;
  end;

// *********************************************************************//
// DispIntf:  ImsgEvents
// Flags:     (4096) Dispatchable
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

uses ComObj;

class function Comsg.Create: Imsg;
begin
  Result := CreateComObject(CLASS_msg) as Imsg;
end;

class function Comsg.CreateRemote(const MachineName: string): Imsg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_msg) as Imsg;
end;

end.



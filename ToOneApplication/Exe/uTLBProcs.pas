unit uTLBProcs;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, BarCodeHook_TLB, StdVcl, Windows;

type
  AHandleItem = record
    Hnd: THandle;
    AHook: HHook;
  end;

type
  Tmsg = class(TAutoObject, IConnectionPointContainer, Imsg)
  private
    { Private declarations }
    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FSinkList: TList;
    FEvents: ImsgEvents;
  public
    procedure Initialize; override;
    procedure SetHandle(hHanlde, ThrdID: OLE_HANDLE); safecall;
    function getsHandle(id:Integer): Integer; safecall;
    function Get_GetHandle: HResult; safecall;
    function getCount: Integer; safecall;
    procedure Show_Form; safecall;
  protected
    { Protected declarations }
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
    implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure RemoveHandle(Hnd: OLE_HANDLE); safecall;
    procedure SetActiveHandle(Hnd: OLE_HANDLE); safecall;
  end;

var
  Handles: TList;

implementation

uses ComServ, Main;

procedure Tmsg.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as ImsgEvents;
  if FConnectionPoint <> nil then
    FSinkList := FConnectionPoint.SinkList;
end;

procedure Tmsg.Initialize;
begin
  inherited Initialize;
  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;
end;

//---By-Gogo--------------------------------------------------
procedure Tmsg.SetHandle(hHanlde, ThrdID: OLE_HANDLE);
var
  P: ^AHandleItem;
begin
  if Handles = nil then
    Handles := TList.Create;

  New(P);
  P^.Hnd := hHanlde; 
  P^.AHook := fMain.SetHookOn(ThrdID);
  Handles.Add(P);

  SetActiveHandle(hHanlde);

  {if High(Hnd) = -1 then //Adding The First Handle
  begin
    SetLength(Hnd, 1);
    Hnd[0] := hHanlde;
    Cnt := 1;
    fMain.SetHookOn(ThrdID);
  end
  else
  begin  //Adding New Handle
    SetLength(Hnd, (High(Hnd) + 2));
    Hnd[High(Hnd)] := hHanlde;
    Inc(Cnt);
    fMain.SetHookOn(ThrdID);
  end;}
end;
//---By-Gogo-------------------------------------------------

function Tmsg.getsHandle(ID:Integer): Integer;
begin
  //Result := Hnd[ID];
end;

function Tmsg.Get_GetHandle: HResult;
begin
  //
end;

function Tmsg.getCount: Integer;
begin
  //Result := Cnt;
end;

procedure Tmsg.Show_Form;
begin
  fMain.eBarCodeStr.Text := '';
  Show_Flag := True;
  fMain.Visible := True;
end;

procedure Tmsg.RemoveHandle(Hnd: OLE_HANDLE);
var i: Integer;
begin
  for i := 0 to Handles.Count - 1 do begin
    if AHandleItem(Handles[i]^).Hnd = Hnd then begin
      fMain.SetHookOff(AHandleItem(Handles[i]^).AHook);
      Handles.Delete(i);
      Break;
    end;
  end;

  if Handles.Count = 0 then begin
    Handles.Free;
    Handles := nil;
  end;
end;

procedure Tmsg.SetActiveHandle(Hnd: OLE_HANDLE);
var i: Integer;
begin
  for i := 0 to Handles.Count - 1 do begin
    if (AHandleItem(Handles[i]^).Hnd = Hnd) then begin
      fMain.SetActiveHook(AHandleItem(Handles[i]^).AHook, Hnd);
      Break;
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, Tmsg, Class_msg,
    ciMultiInstance, tmApartment);
end.

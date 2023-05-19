unit uTLBProcs;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, BarCodeHook_TLB, StdVcl;

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
    procedure SetHandle(hHanlde: Integer); safecall;
        function getsHandle(id:Integer): Integer; safecall;
    function Get_GetHandle: HResult; safecall;
        function getCount       : Integer; safecall;
        procedure Show_Form; safecall;

  protected
        { Protected declarations }
        property ConnectionPoints: TConnectionPoints read FConnectionPoints
        implements IConnectionPointContainer;
        procedure EventSinkChanged(const EventSink: IUnknown); override;
  end;

var
  Hnd: array of Integer;                // Array that holds the passed handles...
  Cnt: Integer;                         // How Many Handles Are There...

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
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;
end;

//---By-Gogo--------------------------------------------------
procedure Tmsg.SetHandle(hHanlde: Integer);
begin
  if High(Hnd) = -1 then
  begin
    { Adding The First Handle; }
    SetLength(Hnd, 1);
    Hnd[0] := hHanlde;
    Cnt := 1;
  end
  else
  begin
    { Adding New Handle; }
    SetLength(Hnd, (High(Hnd) + 2));
    Hnd[High(Hnd)] := hHanlde;
    Inc(Cnt);
  end;

end;
//---By-Gogo-------------------------------------------------

function Tmsg.getsHandle(ID:Integer): Integer;
begin
  Result := Hnd[ID];
end;

function Tmsg.Get_GetHandle: HResult;
begin
  //
end;

function Tmsg.getCount: Integer;
begin
  Result := Cnt;
end;

procedure Tmsg.Show_Form;
begin
  fMain.eBarCodeStr.Text := '';
  Show_Flag := True;
  fMain.Visible := True;
end;

initialization
  TAutoObjectFactory.Create(ComServer, Tmsg, Class_msg,
    ciMultiInstance, tmApartment);
end.

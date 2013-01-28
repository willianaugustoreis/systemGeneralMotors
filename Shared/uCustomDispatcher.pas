unit uCustomDispatcher;

interface

uses
  Classes, RTTI, uCustomClass, uDomains;

type
  TDispatcherType =(
  dptClientes
  );

  TCustomDispatcher= class
  protected
    FRequestStream: TMemoryStream;
    FResponseStream: TMemoryStream;
    FDispatcherType: TDispatcherType;
  public
    {$IFDEF CLIENTE}
    constructor Create(ADispatcherType: TDispatcherType);
    destructor Destroy;
    procedure Dispatch; virtual;//escrever o final do stream
    {$ENDIF}
    {$IFDEF SERVIDOR}
    procedure ProcessMessage(ARequest, AResponse: TMemoryStream);
    {$ENDIF}
  end;
implementation

uses
  SysUtils;

{ TCustomDispatcher }
{$IFDEF CLIENTE}
constructor TCustomDispatcher.Create(ADispatcherType: TDispatcherType);
begin
  FDispatcherType := ADispatcherType;
  FRequestStream := TMemoryStream.Create;
  FResponseStream := TMemoryStream.Create;
end;

destructor TCustomDispatcher.Destroy;
begin
  FreeAndNil(FRequestStream);
  FreeAndNil(FResponseStream);
end;

procedure TCustomDispatcher.Dispatch;
begin

end;
{$ENDIF}
{ TCustomDispatcher }
{$IFDEF SERVIDOR}
procedure TCustomDispatcher.ProcessMessage(ARequest, AResponse: TMemoryStream);
var
  LRttiInfo : TRttiType;
  LParam : TArray<TValue>;
  Result : TValue;
  LRttiContext:TRttiContext;
  LController, LMethod: TString50;
  LRttiMethod: TRttiMethod;
  LCustomClass: TCustomClass;
begin
  ARequest.Position := 0;
  ARequest.Read(LController, SizeOf(LController));
  ARequest.Read(LMethod, SizeOf(LMethod));

  LRttiContext := TRttiContext.Create;

  if MVClist.TryGetValue(LController, LCustomClass) then
  begin
    LRttiInfo := LRttiContext.GetType(LCustomClass.ClassType);
    for LRttiMethod in LRttiInfo.GetMethods do
    begin
      if LRttiMethod.Name <> LMethod then
        Continue;

        LCustomClass.PaserStream(ARequest);
        LRttiMethod.Invoke(LCustomClass, LParam);
    end;
  end;


end;
{$ENDIF}
end.

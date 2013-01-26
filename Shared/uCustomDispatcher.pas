unit uCustomDispatcher;

interface

uses
  Classes, RTTI;

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
  LClass: string;
  LMethod: string;
  Info : TRttiType;
  Meth : TRttiMethod;
  Param : TArray<TValue>;
  Result : TValue;
  AnyClass : TClass;
  LRttiContext:TRttiContext;
begin
  LRttiContext := TRttiContext.Create;
  Info := LRttiContext.GetType(AnyClass);
  Meth := Info.GetMethod('AMethod');
  Setlength(Param, 1);
  Param[0] := TValue.From<Integer>(11);
  Result := Meth.Invoke(AnyClass, Param);
end;
{$ENDIF}
end.

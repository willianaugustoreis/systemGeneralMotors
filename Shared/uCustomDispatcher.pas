unit uCustomDispatcher;

interface

uses
  Classes;

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
    procedure ProcessMessage; virtual;abstract;
    {$ENDIF}
  end;
implementation

uses
  SysUtils;

{ TCustomDispatcher }

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

end.

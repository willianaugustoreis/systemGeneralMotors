unit uRouterDispatcher;

interface
  uses Classes, uDomains, uCustomClass;

type
  TRouterDispatcher = class
    procedure RouterProcessMessage(ARequest, AResponse: TMemoryStream);
  end;
implementation

uses
  uCustomDispatcher;

{ TRouterDispatcher }

procedure TRouterDispatcher.RouterProcessMessage(ARequest,
  AResponse: TMemoryStream);
begin

end;

end.

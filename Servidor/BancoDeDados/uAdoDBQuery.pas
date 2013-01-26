unit uAdoDBQuery;

interface
uses ADODB, uPoolConnection, Windows, uAdoDBConection, uCustomDBConnection, uCustomDBQuery;
type
  TAdoDBQuery = class(TCustomDBQuery)
  strict private
  FAdoQuery: TADOQuery;
  public
    constructor Create;
  end;
implementation

{ TAdoDBQuery }

constructor TAdoDBQuery.Create;
var
  LItem: TItemPoolCon;
begin
  LItem := nil;
  ListaPool.GetDBPoolByThreadId(Windows.GetCurrentThreadId(), LItem);
  if LItem = nil then
    ListaPool.CreateNewConnectionOnThePool(Windows.GetCurrentThreadId(), dbcAdoConnection, LItem);

  FCustomDBConnection := LItem.Connection;
  FAdoQuery := TADOQuery.Create(nil);
  FAdoQuery.Connection := TAdoDBConnection(FCustomDBConnection).Connection;
end;

end.

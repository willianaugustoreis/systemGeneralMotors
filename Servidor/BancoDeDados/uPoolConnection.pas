unit uPoolConnection;

interface

uses
  uCustomDBConnection, Generics.Collections, uAdoDBConection, uConfiguracao, uMySqlDBConnection;

type
  TItemPoolCon = class
  strict private
    FConnection: TCustomDBConnection;
    FThreadId: Int64;
  public
    constructor Create(AThreadId: Int64; AConnection: TCustomDBConnection);
    property Connection: TCustomDBConnection read FConnection;
    property ThreadId: Int64 read FThreadId;
  end;

  TListPoolConection = class
  strict private
  FOwnerList: TObjectList<TItemPoolCon>;
  public
    constructor Create;
    destructor Destroy;
    procedure CreateNewConnectionOnThePool(AThreadId: Int64; ADBConnector: TDBConnetions;out AItemPool: TItemPoolCon);
    procedure GetDBPoolByThreadId(AThreadId: Int64; out AItemPool: TItemPoolCon);
  end;

var
  ListaPool: TListPoolConection;
implementation

{ TItemPoolCon }

constructor TItemPoolCon.Create(AThreadId: Int64;
  AConnection: TCustomDBConnection);
begin
  FConnection := AConnection;
  AThreadId := AThreadId;
end;

constructor TListPoolConection.Create;
begin
  FOwnerList := TObjectList<TItemPoolCon>.Create;
end;

procedure TListPoolConection.CreateNewConnectionOnThePool(AThreadId: Int64; ADBConnector: TDBConnetions;
  out AItemPool: TItemPoolCon);
var
  LCustomConnection: TCustomDBConnection;
  LConfiguracao: TConfiguracaoDataBase;
  LITemList: TItemPoolCon;
begin
  LConfiguracao := TConfiguracaoDataBase.Create(carFileConfig);
  case ADBConnector of
    dbcAdoConnection: LCustomConnection := TAdoDBConnection.Create(LConfiguracao);
    dbcMySQL: LCustomConnection := TMySqlDBConnection.Create(LConfiguracao);
  end;

  AItemPool := TItemPoolCon.Create(AThreadId, LCustomConnection);
  LITemList := TItemPoolCon.Create(AThreadId, LCustomConnection);
  FOwnerList.Add(LITemList);
end;

destructor TListPoolConection.Destroy;
begin
  FOwnerList.Free;
end;

procedure TListPoolConection.GetDBPoolByThreadId(AThreadId: Int64;
  out AItemPool: TItemPoolCon);
var
  i: Integer;
  LItemPool: TItemPoolCon;
begin
  for i := 0 to FOwnerList.Count -1 do
  begin
    LItemPool := FOwnerList.Items[i];
    if LItemPool.ThreadId = AThreadId then
    begin
      AItemPool := LItemPool;
      Exit;
    end;
  end;
end;

end.

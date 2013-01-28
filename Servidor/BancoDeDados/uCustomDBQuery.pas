unit uCustomDBQuery;

interface
uses uCustomDBConnection;

type
  TCustomDBQuery = class;

  TFactoryDBQuery = class
    class function FactoryDBQuery(ADBConnection: TDBConnetions): TCustomDBQuery;
  end;

  TCustomDBQuery = class
  protected
  FCustomDBConnection: TCustomDBConnection;
  public
    procedure BeginTransaction; virtual;abstract;
    procedure EndTransaction; virtual;abstract;

    procedure SetSQL(ASQL: string); virtual;abstract;
    procedure SetParam(AFieldName: string; AValue: Integer); overload; virtual;abstract;
    procedure SetParam(AFieldName: string; AValue: Extended); overload; virtual;abstract;
    procedure SetParam(AFieldName: string; AValue: Int64); overload; virtual;abstract;
    procedure SetParam(AFieldName: string; AValue: string); overload; virtual;abstract;
  end;
implementation
uses uAdoDBQuery;

{ TCustomDBQuery }

{ TFactoryDBQuery }

class function TFactoryDBQuery.FactoryDBQuery(
  ADBConnection: TDBConnetions): TCustomDBQuery;
begin
  case ADBConnection of
    dbcAdoConnection: Result := TadoDBQuery.Create;
    dbcMySQL: Result := nil;
  end;
end;

end.

unit uAdoDBConection;

interface

uses
  uCustomDBConnection, ADODB, uConfiguracao, ActiveX;

type
  TAdoDBConnection = class(TCustomDBConnection)
    strict private
    FConnection: TADOConnection;
    protected
    function GetConnection: TADOConnection;
    procedure ConnectDataBase;override;
    public
      constructor Create(AConfiguracaoDB: TConfiguracaoDataBase);

      property Connection: TADOConnection read GetConnection;
  end;
implementation

{ TAdoDBConnection }

procedure TAdoDBConnection.ConnectDataBase;
begin
  inherited;

  FConnection := TADOConnection.Create(nil);
  FConnection.ConnectionString := FDataBaseName;
  FConnection.Connected := True;
end;

constructor TAdoDBConnection.Create(AConfiguracaoDB: TConfiguracaoDataBase);
begin
  CoInitialize(nil);
  try
    FDataBaseName := AConfiguracaoDB.DataBaseName;
    ConnectDataBase;
  finally
    CoUninitialize;
  end;
end;

function TAdoDBConnection.GetConnection: TADOConnection;
begin
  Result := FConnection;
end;

end.

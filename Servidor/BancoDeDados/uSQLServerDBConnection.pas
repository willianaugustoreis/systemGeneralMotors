unit uSQLServerDBConnection;

interface

uses
  uCustomDBConnection;
type
  TSQLServerDBConnection = class(TCustomDBConnection)
    strict private
    public
      constructor Create(AConfiguracaoDB: string); overload;

  end;
implementation

{ TSQLServerDBConnection }

constructor TSQLServerDBConnection.Create(AConfiguracaoDB: string);
begin
//  FDataBaseName := AConfiguracaoDB.DataBaseName;
//  FUser := AConfiguracaoDB.User;
//  FPassWord := AConfiguracaoDB.PassWord;
end;

end.

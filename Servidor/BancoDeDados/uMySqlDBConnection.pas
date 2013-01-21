unit uMySqlDBConnection;

interface

uses
  SqlExpr, DB, uCustomDBConnection, uConfiguracao, SysUtils, uHelperLogger;
type
  TMySqlDBConnection = class(TCustomDBConnection)
    strict private
    FConnection: TSQLConnection;

    procedure ConnectDataBase;
    public
      constructor Create(AConfiguracaoDB: TConfiguracaoDataBase);

  end;
implementation

{ TSQLServerDBConnection }

procedure TMySqlDBConnection.ConnectDataBase;
begin
  FConnection := TSQLConnection.Create(nil);
  FConnection.ConnectionName := 'MySQLConnection';
  FConnection.DriverName := 'MySQL';
  FConnection.GetDriverFunc := 'getSQLDriverMYSQL';
  FConnection.LibraryName := 'dbxmys.dll';
  FConnection.LoginPrompt := False;
  FConnection.VendorLib := 'LIBMYSQL.dll';
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverName=MySQL');
  FConnection.Params.Add(Format('HostName=%s',[FHostName]));
  FConnection.Params.Add(Format('Database=%s',[FDataBaseName]));
  FConnection.Params.Add(Format('User_Name=%s',[FUser]));
  FConnection.Params.Add(Format('Password=%s',[FPassWord]));
  FConnection.Params.Add('ServerCharSet=');
  FConnection.Params.Add('BlobSize=-1');
  FConnection.Params.Add('ErrorResourceFile=');
  FConnection.Params.Add('LocaleCode=0000');
  FConnection.Params.Add('Compressed=False');
  FConnection.Params.Add('Encrypted=False');
  FConnection.Params.Add('ConnectTimeout=60');
  FConnection.Connected := True;

  HelperLogger.WriteInLog(tlDebug, 'Connectado com sucesso ao banco de dados');
end;

constructor TMySqlDBConnection.Create(AConfiguracaoDB: TConfiguracaoDataBase);
begin
  FDataBaseName := AConfiguracaoDB.DataBaseName;
  FUser := AConfiguracaoDB.UserName;
  FPassWord := AConfiguracaoDB.PassWord;
  FHostName := AConfiguracaoDB.HostName;

  ConnectDataBase;
end;

end.

program ServidorAplicacaoConsole;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uSocketServidor in 'Comunicacao\uSocketServidor.pas',
  uAtributosClasse in '..\Shared\Estrutura\uAtributosClasse.pas',
  uCustomHeader in '..\Shared\Estrutura\uCustomHeader.pas',
  uCustomClass in '..\Shared\Estrutura\uCustomClass.pas',
  uClienteHeader in '..\Shared\Classes\Header\uClienteHeader.pas',
  uClienteClass in '..\Shared\Classes\Classe\uClienteClass.pas',
  uCustomDBConnection in 'BancoDeDados\uCustomDBConnection.pas',
  uMySqlDBConnection in 'BancoDeDados\uMySqlDBConnection.pas',
  uConfiguracao in 'Cofigurações\uConfiguracao.pas',
  Unit1 in 'Unit1.pas' {Form1},
  uHelperLogger in '..\Shared\HelperLog\uHelperLogger.pas',
  uCustomDispatcher in '..\Shared\uCustomDispatcher.pas',
  uRouterDispatcher in 'uRouterDispatcher.pas';

procedure teste;
var
  LConfiguracao: TConfiguracaoDataBase;
  LConexao: TMySqlDBConnection;
begin
  LConfiguracao := TConfiguracaoDataBase.Create(carFileConfig);
  try
  LConexao := TMySqlDBConnection.Create(LConfiguracao);
  except
    on e: Exception do
      HelperLogger.WriteInLog(tlError, E.Message);
  end;
end;

begin
  try
    HelperLogger := THelperLogger.Create;
    Teste;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

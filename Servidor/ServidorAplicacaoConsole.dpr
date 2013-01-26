program ServidorAplicacaoConsole;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  uSocketServidor in 'Comunicacao\uSocketServidor.pas',
  uAtributosClasse in '..\Shared\Estrutura\uAtributosClasse.pas',
  uCustomHeader in '..\Shared\Estrutura\uCustomHeader.pas',
  uCustomClass in '..\Shared\Estrutura\uCustomClass.pas',
  uClienteHeader in '..\Shared\Classes\Header\uClienteHeader.pas',
  uClienteClass in '..\Shared\Classes\Classe\uClienteClass.pas',
  uCustomDBConnection in 'BancoDeDados\uCustomDBConnection.pas',
  uMySqlDBConnection in 'BancoDeDados\uMySqlDBConnection.pas',
  uConfiguracao in 'Cofigurações\uConfiguracao.pas',
  uHelperLogger in '..\Shared\HelperLog\uHelperLogger.pas',
  uCustomDispatcher in '..\Shared\uCustomDispatcher.pas',
  uRouterDispatcher in 'uRouterDispatcher.pas',
  uAdoDBConection in 'BancoDeDados\uAdoDBConection.pas',
  uPoolConnection in 'BancoDeDados\uPoolConnection.pas',
  uCustomDBQuery in 'BancoDeDados\uCustomDBQuery.pas',
  uAdoDBQuery in 'BancoDeDados\uAdoDBQuery.pas',
  uRouter in 'Comunicacao\uRouter.pas';

procedure teste;
var
  LDBQuery: TAdoDBQuery;
begin
  ListaPool := TListPoolConection.Create;
  try
  LDBQuery :=TAdoDBQuery.Create;
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

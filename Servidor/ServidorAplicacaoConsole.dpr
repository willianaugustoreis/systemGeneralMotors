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
  uSQLServerDBConnection in 'BancoDeDados\uSQLServerDBConnection.pas',
  uCustomDBQuery in 'BancoDeDados\uCustomDBQuery.pas';

begin
  try
    while True do
    begin

    end;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

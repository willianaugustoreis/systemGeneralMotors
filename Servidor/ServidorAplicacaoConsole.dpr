program ServidorAplicacaoConsole;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uSocketServidor in 'Comunicacao\uSocketServidor.pas',
  uAtributosClasse in '..\Shared\Estrutura\uAtributosClasse.pas',
  uCustomClass in '..\Shared\Estrutura\uCustomClass.pas',
  uLayerDBClass in '..\Shared\Estrutura\uLayerDBClass.pas';

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

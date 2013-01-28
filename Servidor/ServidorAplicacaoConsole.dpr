program ServidorAplicacaoConsole;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Generics.Collections,
  classes,
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
  uRouter in 'Comunicacao\uRouter.pas',
  superobject in '..\superobject.pas',
  uCustomMVC in 'MVC\uCustomMVC.pas',
  uDomains in '..\Shared\uDomains.pas';

procedure Teste;
var
  LCliente: TClienteClass;
  LStream, LResponse: TMemorystream;
  LRouter: TCustomDispatcher;
  LClassController, LMethod: Tstring50;
//  LControllerTClienteClass: TControllerTClienteClass;
begin
  LRouter := TCustomDispatcher.Create;
//  LControllerTClienteClass := TControllerTClienteClass.Create;

  ListaPool := TListPoolConection.Create;
  MVCList := TDictionary<string,TCustomClass>.Create;
//  MVCList.Add(LCliente.ClassName, LControllerTClienteClass);

  LCliente := TClienteClass.Create;
  LCliente.Id := -1;
  LCliente.Nome := 'Tesste';
  LCliente.Enredeco := 'TE';
  LStream := TMemoryStream.Create;
  LResponse := TMemoryStream.Create;
  LClassController := 'TController'+LCliente.ClassName;

  LStream.Write(LClassController, SizeOf(LClassController));
  LMethod:='SaveObject';
  LStream.Write(LMethod, SizeOf(LMethod));
  LCliente.ToStream(LStream);

  LRouter.ProcessMessage(LStream,LResponse);
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

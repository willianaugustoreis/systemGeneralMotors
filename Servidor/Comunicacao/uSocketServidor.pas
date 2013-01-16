unit uSocketServidor;

interface
uses
  IdTCPServer, IdContext, IdCompressionIntercept, IdComponent, IdGlobal, IdStack,
  Classes, IdException, IdExceptionCore;

type
  TSocketServidor = class(TObject)
  strict private
    FAtiva: Boolean;
    FSocket: TIdTCPServer;
    FIdServerCompressionIntercept: TIdServerCompressionIntercept;
    function GetStream(AContext: TIdContext; AZip: Boolean = True): TMemoryStream;
    procedure SendStream(AContext: TIdContext; var AStream: TMemoryStream; AZip: Boolean = true);

    procedure OnChangeStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure SocketExecute(AContext: TIdContext);
    procedure SocketConnect(AContext: TIdContext);
  public
    constructor Create(APorta: Integer);
    destructor Destroy; override;
  end;

var
  SocketServidor: TSocketServidor;
implementation

uses
  SysUtils;

{ TSocketServidor }

constructor TSocketServidor.Create(APorta: Integer);
begin
  FSocket := TIdTCPServer.Create(nil);
  FSocket.OnStatus := OnChangeStatus;

  FSocket.DefaultPort := APorta;
  FSocket.OnExecute := SocketExecute;
  FIdServerCompressionIntercept := TIdServerCompressionIntercept.Create(nil);
  FIdServerCompressionIntercept.CompressionLevel := 5;
  FSocket.Intercept := FIdServerCompressionIntercept;

  FSocket.OnConnect := SocketConnect;

  // GBP: não pode usar o TIdSchedulerOfThreadPool, ele tráva se as conexões dos clientes forem fechadas muito rapidamente
  // FSocket.Scheduler := TIdSchedulerOfThreadPool.Create(nil);
  // TIdSchedulerOfThreadPool(FSocket.Scheduler).PoolSize := 20;
  FSocket.Active := True;
  FAtiva := True;
end;

destructor TSocketServidor.Destroy;
begin
  FAtiva := False;

  try
    FSocket.Active := False;
  except
    on E: exception do
//      Logger.Error('TComunicacaoCliente.Destroy: %s', [E.Message]);
  end;

  if FSocket.Scheduler <> nil then
    FSocket.Scheduler.Free;

  FreeAndNil(FSocket);
  FreeAndNil(FIdServerCompressionIntercept);
end;

function TSocketServidor.GetStream(AContext: TIdContext; AZip: Boolean): TMemoryStream;
begin
  try
    AContext.Connection.IOHandler.CheckForDataOnSource();
    try
      FSocket.IOHandler.BeginWork(wmRead);
      Result := TMemoryStream.Create;
      AContext.Connection.IOHandler.ReadStream(Result);
      Result.Position := 0;

//      if (AZip) and(not IsHostFromInternalNetwork(AContext.Connection.Socket.Binding.PeerIP)) then
//        DecompressLZMAStreamToStream(Result);

    finally
      FSocket.IOHandler.EndWork(wmRead);
    end;
  except
    on E: EIdSocketError do;
    on E: EIdEndOfStream do;
    on E: EIdConnClosedGracefully do;
    on E: EIdReadTimeout do;
    on E: exception do
//      Logger.Error('TComunicacaoCliente.GetStream: %s %s ', [E.Message, e.ClassName]);
  end;
end;

procedure TSocketServidor.OnChangeStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
//  case AStatus of
//    hsResolving:Logger.Debug('[hsResolving] Socket = %s', [AStatusText]);
//    hsConnecting:Logger.Debug('[hsConnecting] Socket = %s', [AStatusText]);
//    hsConnected:Logger.Debug('[hsConnected] Socket = %s', [AStatusText]);
//    hsDisconnecting:Logger.Debug('[hsDisconnecting] Socket = %s', [AStatusText]);
//    hsDisconnected:Logger.Debug('[hsDisconnected] Socket = %s', [AStatusText]);
//    hsStatusText:Logger.Debug('[hsStatusText] Socket = %s', [AStatusText]);
//    ftpTransfer:Logger.Debug('[ftpTransfer] Socket = %s', [AStatusText]);
//    ftpReady:Logger.Debug('[ftpReady] Socket = %s', [AStatusText]);
//    ftpAborted:Logger.Debug('[ftpAborted] Socket = %s', [AStatusText]);
//  end;
end;

procedure TSocketServidor.SendStream(AContext: TIdContext; var AStream: TMemoryStream; AZip: Boolean);
var
  LRetorno: string;
begin
  if (AContext = nil) or (AContext.Connection = nil) or (AContext.Connection.IOHandler = nil) then
    Exit;

  AStream.Position := 0;

//  if AZip then
//  begin
//    if not IsHostFromInternalNetwork(AContext.Connection.Socket.Binding.PeerIP) then
//      if AStream.Size > 0 then
//        CompressStreamToLZMA(AStream);
//  end;

  AStream.Position := 0;
  AContext.Connection.IOHandler.Write(AStream, AStream.Size, True);
  LRetorno := AContext.Connection.IOHandler.ReadLn;
end;

procedure TSocketServidor.SocketConnect(AContext: TIdContext);
begin
  AContext.Connection.Socket.MaxLineLength := -1;
  AContext.Connection.Socket.ReadTimeout := 10000;
end;

procedure TSocketServidor.SocketExecute(AContext: TIdContext);
const
  TEXTO = 'TEXT';
  TEXTO_SIZE = SizeOf(TEXTO);
var
  LStreamCliente: TMemoryStream;
  LStreamResponse: TMemoryStream;
  LStringStream: TStringStream;
  LResponse: TMemoryStream;
//  LRouter: TRouter;
begin
  LStreamCliente := nil;
  LStringStream := nil;
  LStreamResponse := nil;
  LResponse := nil;

//  LRouter := TRouter.Create;
  try
  try
    if not FAtiva then
      Exit;

    LStreamCliente := GetStream(AContext, False);
    if LStreamCliente = nil then
      Exit;

    if LStreamCliente.Size = 0 then
      Exit;

    LStreamCliente.Position := 0;
//    LRouter.Process(LStreamCliente, LStreamResponse);
    SendStream(AContext, LStreamResponse, False);

  except
    on E: EIdSocketError do
    begin
      AContext.Connection.Disconnect;
    end;
    on E: EIdEndOfStream do;
    on E: EIdConnClosedGracefully do;
    on E: Exception do
    begin
      AContext.Connection.Disconnect;
    end;
  end;
  finally
//    FreeAndNil(LRouter);
    if Assigned(LStreamCliente) then
      FreeAndNil(LStreamCliente);

    if Assigned(LStringStream) then
      FreeAndNil(LStringStream);

    if Assigned(LStreamResponse) then
      FreeAndNil(LStreamResponse);

    if Assigned(LResponse) then
      FreeAndNil(LResponse);
  end;
end;

end.

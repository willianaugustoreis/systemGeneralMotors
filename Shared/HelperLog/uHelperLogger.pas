unit uHelperLogger;

interface

uses
  SysUtils, Classes, Windows;

type

  TTypeLog = (
    tlDebug,
    tlWarning,
    tlError,
    tlInfo
  );

  THelperLogger = class
  strict private
    FPathLogs: string;
    FTextFile: TextFile;
    procedure CreateNewLog(AFileName: string);
  public
    constructor Create;

    procedure WriteInLog(ATypeLog: TTypeLog; AMensagem: string);
  end;

var
  HelperLogger: THelperLogger;

implementation


{ THelperLogger }

constructor THelperLogger.Create;
begin
  FPathLogs := ExtractFilePath(ParamStr(0)) + '\Logs';
  if not DirectoryExists(FPathLogs) then
    CreateDir(FPathLogs);

  if not FileExists(FPathLogs + '\'+ FormatDateTime('dd.mm.yyyy', Now) + '.txt') then
    CreateNewLog(FPathLogs + '\'+ FormatDateTime('dd.mm.yyyy', Now) + '.txt');

  AssignFile(FTextFile, FPathLogs + '\'+ FormatDateTime('dd.mm.yyyy', Now) + '.txt');
  Append(FTextFile);

  Writeln(FTextFile, '---------------------------------------------------------');
  WriteInLog(tlInfo, 'Iniciando sistema');
  Writeln(FTextFile, '---                                                  ---');
end;

procedure THelperLogger.CreateNewLog(AFileName: string);
var
  LLog: TStringList;
begin
  LLog := TStringList.Create;
  try
    LLog.SaveToFile(AFileName);
  finally
    FreeAndNil(LLog);
  end;
end;

procedure THelperLogger.WriteInLog(ATypeLog: TTypeLog; AMensagem: string);
var
  LMensagemCompleta: string;
begin
  case ATypeLog of
    tlDebug: LMensagemCompleta := 'DEBUG | ';
    tlWarning: LMensagemCompleta := 'WARN | ';
    tlError: LMensagemCompleta := 'ERROR | ';
    tlInfo: LMensagemCompleta := 'INFO | ';
  end;

  LMensagemCompleta := LMensagemCompleta + IntToStr(GetCurrentThreadId)+ ' | ' + FormatDateTime('hh:nn:ss', Now) + ' | '
  + AMensagem;

  Writeln(FTextFile, LMensagemCompleta);
end;

end.

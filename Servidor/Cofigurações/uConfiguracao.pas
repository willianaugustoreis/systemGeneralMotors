unit uConfiguracao;

interface

uses Rtti, uCustomClass, uAtributosClasse;

type
  {$RTTI INHERIT}
  TConfiguracaoArmazenagem=(
  carDataBase,
  carFileConfig
  );

  TConfiguracao = class(TCustomBase)
  strict private
    procedure LoadConfigDataBase;
    procedure LoadConfigFileConfig;
  public
    constructor Create(AConfiguracaoArmazenagem: TConfiguracaoArmazenagem);
  end;

  [TAttrDBTable('DATABASE')]
  TConfiguracaoDataBase = class(TConfiguracao)
  protected
  [TAttrDBField('DATABASENAME')]
  FDataBaseName: string;
  [TAttrDBField('USER')]
  FUserName: string;
  [TAttrDBField('PASSWORD')]
  FPassWord: string;
  [TAttrDBField('HOSTNAME')]
  FHostName: string;
  public
    property DataBaseName: string read FDataBaseName write FDataBaseName;
    property UserName: string read FUserName write FUserName;
    property PassWord: string read FPassWord write FPassWord;
    property HostName: string read FHostName write FHostName;
  end;
implementation

uses IniFiles, SysUtils, TypInfo;
{ TConfiguracao }

constructor TConfiguracao.Create(
  AConfiguracaoArmazenagem: TConfiguracaoArmazenagem);
begin
  case AConfiguracaoArmazenagem of
    carDataBase: LoadConfigDataBase;
    carFileConfig: LoadConfigFileConfig;
  end;

  end;
procedure TConfiguracao.LoadConfigDataBase;
begin
end;

procedure TConfiguracao.LoadConfigFileConfig;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  LCustomAttribute: TCustomAttribute;
  LFileIni: TIniFile;
  LArquivoIni, LString: string;
  LInteger, iField: Integer;
  LFloat: Double;
begin
  LArquivoIni := ExtractFilePath(ParamStr(0))+ 'config.ini';

  if not FileExists(LArquivoIni) then
    Exit;

  LFileIni := TIniFile.Create(LArquivoIni);
  FTableName := GetTableName;

  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(ClassType);
  LRttiFields := LRttiType.GetFields;

  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
    begin
      if (LCustomAttribute is TAttrDBField) then
      begin
        case LRttiField.FieldType.TypeKind of
          tkInteger:
          begin
            LInteger := LFileIni.ReadInteger(FTableName, TAttrDBField(LCustomAttribute).FieldName, -1);
            LFileIni.WriteInteger(FTableName, TAttrDBField(LCustomAttribute).FieldName, LInteger);
            LRttiField.SetValue(Self, LInteger);
          end;

          tkFloat:
          begin
            LFloat := LFileIni.ReadFloat(FTableName, TAttrDBField(LCustomAttribute).FieldName, -1);
            LFileIni.WriteFloat(FTableName, TAttrDBField(LCustomAttribute).FieldName, LFloat);
            LRttiField.SetValue(Self, LFloat);
          end;

          tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
          begin
            LString := LFileIni.ReadString(FTableName, TAttrDBField(LCustomAttribute).FieldName, '');
            LFileIni.WriteString(FTableName, TAttrDBField(LCustomAttribute).FieldName, LString);
            LRttiField.SetValue(Self, LString);
          end;
        end;

        Break;
      end;
    end;
  end;
end;

end.

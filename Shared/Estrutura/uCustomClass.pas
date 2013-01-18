unit uCustomClass;

interface
uses
  Generics.Collections, uCustomHeader, RTTI, uAtributosClasse, Classes,
  DBXJSON, DBXJSONReflect;

type
  {$RTTI INHERIT}
  {$M+}
  TCustomBase = class
    function GetTableName: string;
  end;

  tdbquery=class

  end;
  TCustomClass = class(TCustomBase)
  strict private
    FMar: TJSONMarshal;  //Serializer
    FUnMar: TJSONUnMarshal;
    function GenerateInsertSQL: string;
    function GenerateUpdateSQL: string;
    function GenerateDeleteSQL: string;

    procedure Insert(AQuery: TDBQuery);
    procedure Update(AQuery: TDBQuery);
    procedure Delete(AQuery: TDBQuery);
  public
    constructor Create;
    destructor Destroy;
    procedure Save(AQuery: TDBQuery);

    function ToStream: TMemoryStream;
    procedure PaserStream(AMemoryStream: TMemoryStream);

    function ToJson: TJSONObject;
    procedure ParseJson(AJson: TJSONObject);

  end;

implementation

uses
  SysUtils;

{ TLayerDBClass<T> }

constructor TCustomClass.Create;
begin
  FMar := TJSONMarshal.Create;  //Serializer
  FUnMar := TJSONUnMarshal.Create;
end;

procedure TCustomClass.Delete(AQuery: TDBQuery);
begin
  GenerateDeleteSQL;
end;

destructor TCustomClass.Destroy;
begin
  FreeAndNil(FMar);
  FreeAndNil(FUnMar);
end;

function TCustomClass.GenerateDeleteSQL: string;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  LCustomAttribute: TObject;
  iField: Integer;
  LCondition: string;
  LIsFirstCon: Boolean;
begin
  Result := 'delete from ' + GetTableName;
  LCondition := ' ';

  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(ClassType);
  LRttiFields := LRttiType.GetFields;

  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
    begin
      if (LCustomAttribute is TAttrDBPrimaryKey) then
      begin
        if LIsFirstCon then
        begin
          LCondition := LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey + ' = :' + LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey;
          LIsFirstCon := False;
        end
        else
        begin
          LCondition := LCondition + ', ' + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey + ' = :' + LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey;
        end;
        Break;
      end;
    end;
  end;

  Result := Result + ' ' + LCondition + ';'
end;

function TCustomClass.GenerateInsertSQL: string;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  LCustomAttribute: TObject;
  iField: Integer;
  LParams: string;
  LValues: string;
  LIsFirstParam: Boolean;
begin
  Result := 'insert into ' + GetTableName;
  LParams := '(';
  LValues := 'values (';
  LIsFirstParam := True;

  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(ClassType);
  LRttiFields := LRttiType.GetFields;

  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
      if (LCustomAttribute is TAttrDBField) then
      begin
        if LIsFirstParam then
        begin
          LParams := LParams + TAttrDBField(LCustomAttribute).FieldName;
          LValues := LValues + ':' + TAttrDBField(LCustomAttribute).FieldName;
          LIsFirstParam := False;
        end
        else
        begin
          LParams := LParams + ', ' + TAttrDBField(LCustomAttribute).FieldName;
          LValues := LValues + ', :' + TAttrDBField(LCustomAttribute).FieldName;
        end;
        Break;
      end;
  end;

  Result := Result + LParams + ') ' + LValues + ');'
end;

function TCustomClass.GenerateUpdateSQL: string;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  LCustomAttribute: TObject;
  iField: Integer;
  LParams: string;
  LCondition: string;
  LIsFirstParam, LIsFirstCon: Boolean;
begin
  Result := 'update ' + GetTableName + ' set ';
  LParams := ' ';
  LCondition := ' ';
  LIsFirstParam := True;
  LIsFirstCon := True;

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
        if LIsFirstParam then
        begin
          LParams := LParams + TAttrDBField(LCustomAttribute).FieldName + ' = :' + LParams + TAttrDBField(LCustomAttribute).FieldName;
          LIsFirstParam := False;
        end
        else
        begin
          LParams := LParams + ', ' + TAttrDBField(LCustomAttribute).FieldName + ' = :' + LParams + TAttrDBField(LCustomAttribute).FieldName;
        end;
        Break;
      end else
      begin
        if (LCustomAttribute is TAttrDBPrimaryKey) then
        begin
          if LIsFirstCon then
          begin
            LCondition := LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey + ' = :' + LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey;
            LIsFirstCon := False;
          end
          else
          begin
            LCondition := LCondition + ', ' + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey + ' = :' + LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey;
          end;
          Break;
        end
      end;
    end;
  end;

  Result := Result + LParams + ' ' + LCondition + ';'
end;

function TCustomBase.GetTableName: string;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LCustomAttribute: TCustomAttribute;
  LRttiField: TRttiField;
begin
  Result := '';
  try
    LRttiContext := TRttiContext.Create;
    LRttiType := LRttiContext.GetType(ClassType);
    for LCustomAttribute in LRttiType.GetAttributes do
      if LCustomAttribute is TAttrDBTable then
      begin
        Result := TAttrDBTable(LCustomAttribute).TableName;
        Break;
      end;
  finally
  end;
end;

procedure TCustomClass.Insert;
begin
  GenerateInsertSQL;
end;

procedure TCustomClass.ParseJson(AJson: TJSONObject);
begin
  Self := FUnMar.UnMarshal(AJson) as TCustomClass;
end;

procedure TCustomClass.PaserStream(AMemoryStream: TMemoryStream);
begin

end;

procedure TCustomClass.Save(AQuery: TDBQuery);
begin

end;

function TCustomClass.ToJson: TJSONObject;
begin
 Result := FMar.Marshal(Self) as TJSONObject;
end;

function TCustomClass.ToStream: TMemoryStream;
begin
  Result := TMemoryStream.Create;

end;

procedure TCustomClass.Update;
begin
  GenerateUpdateSQL;
end;

end.

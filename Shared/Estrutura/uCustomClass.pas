unit uCustomClass;

interface
uses
  Generics.Collections, uCustomHeader, RTTI, uAtributosClasse, Classes,
  DBXJSON, DBXJSONReflect, uCustomDBQuery;

type
  {$RTTI INHERIT}
  {$M+}

  TCustomBase = class
  protected
  FTableName: string;
  public
    function GetTableName: string;
  end;

  TMVCList<T: class, constructor> = class(TCustomBase)
  FOwnerList: TObjectList<T>;
  public
    constructor Create;
  end;

  TCustomClass = class(TCustomBase)
  strict private
    FIsTransaction: Boolean;
    FDMLQuery: TCustomDBQuery;
    FMar: TJSONMarshal;  //Serializer
    FUnMar: TJSONUnMarshal;
    function GenerateInsertSQL: string;
    function GenerateUpdateSQL: string;
    function GenerateDeleteSQL: string;

    procedure Insert(AQuery: TCustomDBQuery);
    procedure Update(AQuery: TCustomDBQuery);
    procedure Delete(AQuery: TCustomDBQuery);


    procedure InitializeDMLQuery(AQueryTransaction: TCustomDBQuery);
    procedure FinalizeDMLQuery(var AQueryTransaction: TCustomDBQuery);
  public
    constructor Create;
    destructor Destroy;
    procedure Save(AQuery: TCustomDBQuery);

    function ToStream: TMemoryStream;
    procedure PaserStream(AMemoryStream: TMemoryStream);

    function ToJson: TJSONObject;
    procedure ParseJson(AJson: TJSONObject);
  end;

implementation

uses
  SysUtils, TypInfo;

{ TLayerDBClass<T> }

constructor TCustomClass.Create;
begin
  FMar := TJSONMarshal.Create;  //Serializer
  FUnMar := TJSONUnMarshal.Create;
  FIsTransaction:= False;
end;

procedure TCustomClass.Delete(AQuery: TCustomDBQuery);
begin
  GenerateDeleteSQL;
end;

destructor TCustomClass.Destroy;
begin
  FreeAndNil(FMar);
  FreeAndNil(FUnMar);
end;

procedure TCustomClass.FinalizeDMLQuery(var AQueryTransaction: TCustomDBQuery);
begin
  if not FIsTransaction then
  begin
//    FDMLQuery.EndTransaction;
    FDMLQuery.Free;
  end;
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
  LIsFirstCon := True;
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
          LCondition := LCondition + ' AND ' + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey + ' = :' + LCondition + TAttrDBPrimaryKey(LCustomAttribute).PrimaryKey;
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

procedure TCustomClass.InitializeDMLQuery(AQueryTransaction: TCustomDBQuery);
begin
  FIsTransaction := AQueryTransaction <> nil;
  if FIsTransaction then
    FDMLQuery := AQueryTransaction
  else
  begin
//    FDMLQuery := TDBManipulation.Create;
//    FDMLQuery.BeginTransaction;
  end;
end;

procedure TCustomClass.Insert(AQuery: TCustomDBQuery);
begin
  GenerateInsertSQL;
end;

procedure TCustomClass.ParseJson(AJson: TJSONObject);
begin
  Self := FUnMar.UnMarshal(AJson) as TCustomClass;
end;

procedure TCustomClass.PaserStream(AMemoryStream: TMemoryStream);
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  iField: Integer;
  LInteger: Integer;
  LInt64: Int64;
  LFloat: Extended;
  LString: string;
begin
  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(Self.ClassType);
  LRttiFields := LRttiType.GetFields;
  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];

    case LRttiField.FieldType.TypeKind of
      tkInteger:
      begin
        AMemoryStream.Read(LInteger, SizeOf(LInteger));
        LRttiField.SetValue(Self, LInteger);
      end;
      tkInt64, tkEnumeration:
      begin
        AMemoryStream.Read(LInt64, SizeOf(LInt64));
        LRttiField.SetValue(Self, LInt64);
      end;

      tkFloat:
      begin
        AMemoryStream.Read(LFloat, SizeOf(LFloat));
        LRttiField.SetValue(Self, LFloat);
      end;

      tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
      begin
        AMemoryStream.Read(LInteger, SizeOf(LInteger));
        SetLength(LString, LInteger);
        AMemoryStream.Read(LString, LInteger);
        LRttiField.SetValue(Self, LString);
      end;
    end;
  end;
end;

procedure TCustomClass.Save(AQuery: TCustomDBQuery);
begin

end;

function TCustomClass.ToJson: TJSONObject;
begin
 Result := FMar.Marshal(Self) as TJSONObject;
end;

function TCustomClass.ToStream: TMemoryStream;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  iField: Integer;
  LInteger: Integer;
  LInt64: Int64;
  LFloat: Extended;
  LString: string;
begin
  Result := TMemoryStream.Create;
  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(Self.ClassType);
  LRttiFields := LRttiType.GetFields;
  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];

    case LRttiField.FieldType.TypeKind of
      tkInteger:
      begin
        LInteger := LRttiField.GetValue(Self).AsInteger;
        Result.Write(LInteger, SizeOf(LInteger))
      end;
      tkInt64, tkEnumeration:
      begin
        LInt64 := LRttiField.GetValue(Self).AsInt64;
        Result.Write(LInt64, SizeOf(LInt64));
      end;
      tkFloat:
      begin
        LFloat := LRttiField.GetValue(Self).AsExtended;
        Result.Write(LFloat, SizeOf(LFloat));
      end;

      tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
      begin
        LString := LRttiField.GetValue(Self).AsString;
        LInteger := Length(LString);
        Result.Write(LInteger, SizeOf(LInteger));
        Result.Write(LString, LInteger);
      end;
    end;
  end;
end;

procedure TCustomClass.Update(AQuery: TCustomDBQuery);
begin
  GenerateUpdateSQL;
end;

{ TMVCList<T> }

constructor TMVCList<T>.Create;
begin
  FOwnerList := TObjectList<T>.Create;
//  T.Create;
  FOwnerList.Add(T);
end;

end.

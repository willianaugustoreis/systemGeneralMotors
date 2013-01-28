unit uCustomMVC;

interface
uses
  uCustomClass, uCustomDBQuery, Generics.Collections, RTTI, uAtributosClasse, TypInfo;

type
  {$RTTI INHERIT}
  {$M+}
  TCustomMVC = class(TCustomClass)
  strict private
    procedure Insert; override;
    procedure Update; override;
    procedure Delete; override;

    function GenerateInsertSQL: string;
    function GenerateUpdateSQL: string;
    function GenerateDeleteSQL: string;
    function  IsNewObject: Boolean;

    procedure InitializeDMLQuery(AQueryTransaction: TCustomDBQuery);
    procedure FinalizeDMLQuery(var AQueryTransaction: TCustomDBQuery);
  private
    FIsTransaction: Boolean;
    FDMLQuery: TCustomDBQuery;
  public
    constructor Create;
    procedure Save; override;
    procedure DeleteObj; override;
  end;

//  TCustomListMVC<T: class, constructor> = class(TCustomList<TCustomClass>)
//  protected
//    FOwnerList: TObjectList<T>;
//  public
////    constructor Create;
//
////    procedure SaveObject;
////    procedure DeleteObject;
//  end;
implementation

{ TCustomMVC }

procedure TCustomMVC.Insert;
var
  LSQL: string;
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  iField: Integer;
  LCustomAttribute: TCustomAttribute;
  LIsFirstParam: Boolean;
begin
  inherited;
  LIsFirstParam := True;
  LSQL := GenerateInsertSQL;
  FDMLQuery.SetSQL(LSQL);

  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(ClassType);
  LRttiFields := LRttiType.GetFields;

  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
      if (LCustomAttribute is TAttrDBField) then
      begin
        case LRttiField.FieldType.TypeKind of
          tkInteger:
            FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

          tkInt64, tkEnumeration:
            FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

          tkFloat:
            FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

          tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
            FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
        end;
        Break;
      end;
  end;
end;

function TCustomMVC.IsNewObject: Boolean;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  LCustomAttribute: TObject;
  iField: Integer;
begin
  Result := False;

  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(Self.ClassType);
  LRttiFields := LRttiType.GetFields;

  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
    begin
      if (LCustomAttribute is TAttrDBField) and (LCustomAttribute is TAttrDBPrimaryKey)then
      begin
        case LRttiField.FieldType.TypeKind of
          tkInteger:
          if LRttiField.GetValue(Self).AsInteger = -1 then
            Result := True;

          tkInt64, tkEnumeration:
          if LRttiField.GetValue(Self).AsInt64 = -1 then
            Result := True;

          tkFloat:
          if LRttiField.GetValue(Self).AsExtended = -1 then
            Result := True;
        end;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomMVC.Save;
begin
  if IsNewObject then
    Insert
  else
    Update;
end;

constructor TCustomMVC.Create;
begin
  FIsTransaction:= False;
end;

procedure TCustomMVC.Update;
var
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  LCustomAttribute: TObject;
  iField: Integer;
  LIsFirstParam, LIsFirstCon: Boolean;
  LSQL: string;
begin
  LSQL := GenerateUpdateSQL;
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
      if (LCustomAttribute is TAttrDBField) and not (LCustomAttribute is TAttrDBPrimaryKey)then
      begin
        if LIsFirstParam then
        begin
          case LRttiField.FieldType.TypeKind of
            tkInteger:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

            tkInt64, tkEnumeration:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

            tkFloat:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

            tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
          end;
          LIsFirstParam := False;
        end
        else
        begin
          case LRttiField.FieldType.TypeKind of
            tkInteger:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

            tkInt64, tkEnumeration:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

            tkFloat:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

            tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
          end;
        end;
        Break;
      end else
      begin
        if (LCustomAttribute is TAttrDBField) and (LCustomAttribute is TAttrDBPrimaryKey) then
        begin
          if LIsFirstCon then
          begin
            case LRttiField.FieldType.TypeKind of
              tkInteger:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

              tkInt64, tkEnumeration:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

              tkFloat:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

              tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
            end;
            LIsFirstCon := False;
          end
          else
          begin
            case LRttiField.FieldType.TypeKind of
              tkInteger:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

              tkInt64, tkEnumeration:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

              tkFloat:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

              tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
                FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
            end;
          end;
          Break;
        end
      end;
    end;
  end;
end;

procedure TCustomMVC.Delete;
var
  LSQL: string;
  LRttiContext: TRttiContext;
  LRttiType: TRttiType;
  LRttiFields: TArray<TRttiField>;
  LRttiField: TRttiField;
  iField: Integer;
  LCustomAttribute: TCustomAttribute;
  LIsFirstCon: Boolean;
begin
  LSQL := GenerateDeleteSQL;
  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(ClassType);
  LRttiFields := LRttiType.GetFields;

  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
    begin
      if (LCustomAttribute is TAttrDBField) and (LCustomAttribute is TAttrDBPrimaryKey)then
      begin
        if LIsFirstCon then
        begin
          case LRttiField.FieldType.TypeKind of
            tkInteger:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

            tkInt64, tkEnumeration:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

            tkFloat:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

            tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
          end;

          LIsFirstCon := False;
        end
        else
        begin
          case LRttiField.FieldType.TypeKind of
            tkInteger:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInteger);

            tkInt64, tkEnumeration:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsInt64);

            tkFloat:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsExtended);

            tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
              FDMLQuery.SetParam(TAttrDBField(LCustomAttribute).FieldName, LRttiField.GetValue(Self).AsString);
          end;
        end;
        Break;
      end;
    end;
  end;

end;

procedure TCustomMVC.DeleteObj;
begin
  Delete;
end;

procedure TCustomMVC.InitializeDMLQuery(AQueryTransaction: TCustomDBQuery);
begin
  FIsTransaction := AQueryTransaction <> nil;
  if FIsTransaction then
    FDMLQuery := AQueryTransaction
  else
  begin
    FDMLQuery := TCustomDBQuery.Create;
    FDMLQuery.BeginTransaction;
  end;
end;

procedure TCustomMVC.FinalizeDMLQuery(var AQueryTransaction: TCustomDBQuery);
begin
  if not FIsTransaction then
  begin
    FDMLQuery.EndTransaction;
    FDMLQuery.Free;
  end;
end;

function TCustomMVC.GenerateDeleteSQL: string;
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
      if (LCustomAttribute is TAttrDBField) and (LCustomAttribute is TAttrDBPrimaryKey)then
      begin
        if LIsFirstCon then
        begin
          LCondition := LCondition + TAttrDBField(LCustomAttribute).FieldName + ' = :' + LCondition + TAttrDBField(LCustomAttribute).FieldName;
          LIsFirstCon := False;
        end
        else
        begin
          LCondition := LCondition + ' AND ' + TAttrDBField(LCustomAttribute).FieldName + ' = :' + LCondition + TAttrDBField(LCustomAttribute).FieldName;
        end;
        Break;
      end;
    end;
  end;

  Result := Result + ' ' + LCondition + ';'
end;

function TCustomMVC.GenerateInsertSQL: string;
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

function TCustomMVC.GenerateUpdateSQL: string;
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
      if (LCustomAttribute is TAttrDBField) and not (LCustomAttribute is TAttrDBPrimaryKey)then
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
        if (LCustomAttribute is TAttrDBField) and (LCustomAttribute is TAttrDBPrimaryKey) then
        begin
          if LIsFirstCon then
          begin
            LCondition := LCondition + TAttrDBField(LCustomAttribute).FieldName + ' = :' + LCondition + TAttrDBField(LCustomAttribute).FieldName;
            LIsFirstCon := False;
          end
          else
          begin
            LCondition := LCondition + ' AND ' + TAttrDBField(LCustomAttribute).FieldName + ' = :' + LCondition + TAttrDBField(LCustomAttribute).FieldName;
          end;
          Break;
        end
      end;
    end;
  end;

  Result := Result + LParams + ' ' + LCondition + ';'
end;

{ TCustomListMVC<T> }

//constructor TCustomListMVC<T>.Create;
//begin
//  FOwnerList := TObjectList<T>.Create;
//end;

//procedure TCustomListMVC<T>.DeleteObject;
//begin
//  TCustomClass(T).DeleteObj;
//end;

//procedure TCustomListMVC<T>.SaveObject;
//begin
//  TCustomClass(T).Save;
//end;

{ TCustomListMVC<T> }
end.

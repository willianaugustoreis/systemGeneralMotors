unit uCustomClass;

interface
uses Generics.Collections, uCustomHeader, RTTI, uAtributosClasse;

type
  {$RTTI INHERIT}
  {$M+}
  TCustomClass = class
  strict private
    function GetTableName: string;
    function GenerateInsertSQL: string;
    function GenerateUpdateSQL: string;
  protected
    procedure Insert; virtual;
    procedure Update; virtual;
  public
    procedure Save;virtual;abstract;
  end;

implementation

{ TLayerDBClass<T> }

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

  try
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
  finally
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
  LValues: string;
  LIsFirstParam: Boolean;
begin
  Result := 'update ' + GetTableName + ' set ';
  LParams := '(';
  LValues := 'values (';
  LIsFirstParam := True;

  try
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
  finally
  end;

  Result := Result + LParams + ') ' + LValues + ');'
end;

function TCustomClass.GetTableName: string;
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

procedure TCustomClass.Update;
begin
//
end;

end.

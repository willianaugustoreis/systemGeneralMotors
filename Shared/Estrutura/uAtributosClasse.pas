unit uAtributosClasse;
{$RTTI EXPLICIT METHODS([vcPublic, vcPublished]) PROPERTIES([vcPublic, vcPublished]) FIELDS([vcProtected, vcPublic])}
{$M+}

interface

type
  TAttrDBTable = class(TCustomAttribute)
  strict private
  FTableName: string;
  public
    constructor Create(ATableName: string);
    property TableName: string read FTableName;
  end;

  TAttrDBField = class(TCustomAttribute)
  strict private
  FFieldName: string;
  public
    constructor Create(AFieldName: string);
    property FieldName: string read FFieldName;
  end;

  TAttrDBPrimaryKey = class(TCustomAttribute)
  strict private
  FPrimaryKey: string;
  public
    constructor Create(APrimaryKey: string);

    property PrimaryKey: string read FPrimaryKey;
  end;
implementation

{ TAttrDBTable }

constructor TAttrDBField.Create(AFieldName: string);
begin
  FFieldName := AFieldName;
end;

{ TAttrDBTable }

constructor TAttrDBTable.Create(ATableName: string);
begin
  FTableName := ATableName
end;

{ TAttrDBPrimaryKey }

constructor TAttrDBPrimaryKey.Create(APrimaryKey: string);
begin
  FPrimaryKey := APrimaryKey;
end;

end.

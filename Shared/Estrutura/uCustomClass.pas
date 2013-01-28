unit uCustomClass;

interface
uses
  Generics.Collections, Classes, DBXJSON, DBXJSONReflect, DBXPlatform, superobject,
  RTTI, uAtributosClasse;

type
  {$RTTI INHERIT}
  {$M+}

  TCustomBase = class
  protected
  FTableName: string;
  public
    function GetTableName: string;
  end;

  TCustomClass = class(TCustomBase)
  protected
    procedure Insert; virtual; abstract;
    procedure Update; virtual; abstract;
    procedure Delete; virtual; abstract;
  public
    procedure Save; virtual;abstract;
    procedure DeleteObj; virtual;abstract;

    procedure ToStream(var AMemoryStream: TMemoryStream);
    procedure PaserStream(AMemoryStream: TMemoryStream);

    function ToJson: string;
    procedure ParseJson(AJson: TJSONObject);
  end;

  TCustomList<T> = class
  public
    procedure LoadAllObjects; virtual;abstract;
  end;
var
  MVCList: TDictionary<string, TCustomClass>;

implementation

uses
  SysUtils, TypInfo;



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

procedure TCustomClass.ParseJson(AJson: TJSONObject);
begin
  Self := nil;
//  Self := FUnMar.UnMarshal(AJson) as TCustomClass;
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
  LCustomAttribute: TCustomAttribute;
begin
  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(Self.ClassType);
  LRttiFields := LRttiType.GetFields;
  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];

    for LCustomAttribute in LRttiField.GetAttributes do
    begin
      if LCustomAttribute is TAttrDBField then
      begin
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
        Break;
      end;
    end;
  end;
end;

function TCustomClass.ToJson: string;
var
  LSuperRTTI: TSuperRTTIContext;
begin
  LSuperRTTI := TSuperRttiContext.Create;
// Result :=LSuperRTTI.AsJson<Self.>(Self).AsJSon
// Result := FMar.Marshal(Self).ToString;
end;

procedure TCustomClass.ToStream(var AMemoryStream: TMemoryStream);
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
  LCustomAttribute: TCustomAttribute;
begin
  LRttiContext := TRttiContext.Create;
  LRttiType := LRttiContext.GetType(Self.ClassType);
  LRttiFields := LRttiType.GetFields;
  for iField := 0 to Length(LRttiFields) - 1 do
  begin
    LRttiField := LRttiFields[iField];
    for LCustomAttribute in LRttiField.GetAttributes do
    begin
      if LCustomAttribute is TAttrDBField then
      begin
        case LRttiField.FieldType.TypeKind of
          tkInteger:
          begin
            LInteger := LRttiField.GetValue(Self).AsInteger;
            AMemoryStream.Write(LInteger, SizeOf(LInteger))
          end;
          tkInt64, tkEnumeration:
          begin
            LInt64 := LRttiField.GetValue(Self).AsInt64;
            AMemoryStream.Write(LInt64, SizeOf(LInt64));
          end;
          tkFloat:
          begin
            LFloat := LRttiField.GetValue(Self).AsExtended;
            AMemoryStream.Write(LFloat, SizeOf(LFloat));
          end;

          tkUString, tkDynArray, tkWString, tkString, tkWChar, tkChar, tkLString:
          begin
            LString := LRttiField.GetValue(Self).AsString;
            LInteger := Length(LString);
            AMemoryStream.Write(LInteger, SizeOf(LInteger));
            AMemoryStream.Write(LString, LInteger);
          end;
        end;
        Break;
      end;
    end;
  end;
  AMemoryStream.Position := 0;
end;


end.

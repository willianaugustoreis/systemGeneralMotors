unit uCustomDBConnection;

interface
uses
  SqlExpr, DB, Classes;

type
  TCustomDBConnection = class
  strict private
    procedure ConnectDataBase; virtual;abstract;
  protected
    FDataBaseName: string;
    FUser: string;
    FPassWord: string;
  public
    function GetInteger(AFieldByName: string): Integer; virtual;abstract;
    function GetFloat(AFieldByName: string): double; virtual;abstract;
    function GetString(AFieldByName: string): string; virtual;abstract;
    function GetBlob(AFieldByName: string): TMemoryStream; virtual;abstract;
    function GetLargeInt(AFieldByName: string): Int64; virtual;abstract;
    function GetDate(AFieldByName: string): TDate; virtual;abstract;
    function GetTime(AFieldByName: string): TTime; virtual;abstract;
    function GetDateTime(AFieldByName: string): TDateTime; virtual;abstract;

    procedure GetInteger(AFieldByName: string); virtual;abstract;
    procedure GetFloat(AFieldByName: string); virtual;abstract;
    procedure GetString(AFieldByName: string); virtual;abstract;
    procedure GetBlob(AFieldByName: string); virtual;abstract;
    procedure GetLargeInt(AFieldByName: string); virtual;abstract;
    procedure GetDate(AFieldByName: string); virtual;abstract;
    procedure GetTime(AFieldByName: string); virtual;abstract;
    procedure GetDateTime(AFieldByName: string); virtual;abstract;

    property DataBaseName: string read FDataBaseName write FDataBaseName;
    property User: string read FUser write FUser;
    property PassWord: string read FPassWord write FPassWord;
  end;
implementation



end.

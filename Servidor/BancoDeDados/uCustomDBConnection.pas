unit uCustomDBConnection;

interface
uses
  SqlExpr, DB;

type
  TCustomDBConnection = class
  strict private
    procedure ConnectDataBase; virtual;abstract;
  protected
    FDataBaseName: string;
    FUser: string;
    FPassWord: string;
  public


    property DataBaseName: string read FDataBaseName write FDataBaseName;
    property User: string read FUser write FUser;
    property PassWord: string read FPassWord write FPassWord;
  end;
implementation



end.

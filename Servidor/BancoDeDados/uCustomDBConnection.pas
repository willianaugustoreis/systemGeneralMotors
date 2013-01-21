unit uCustomDBConnection;

interface

type
  TCustomDBConnection = class
  strict private
    procedure ConnectDataBase; virtual;abstract;
  protected
    FHostName: string;
    FDataBaseName: string;
    FUser: string;
    FPassWord: string;
  public
    property DataBaseName: string read FDataBaseName write FDataBaseName;
    property User: string read FUser write FUser;
    property PassWord: string read FPassWord write FPassWord;
    property HostName: string read FHostName write FHostName;
  end;
implementation



end.

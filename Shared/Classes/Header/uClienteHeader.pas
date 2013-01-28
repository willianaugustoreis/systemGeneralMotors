unit uClienteHeader;

interface

uses
  uAtributosClasse, uCustomMVC;

type
  {$RTTI INHERIT}
  {$M+}
  [TAttrDBTable('CLIENTE')]
  TClienteHeader = class(TCustomMVC)
  protected
  [TAttrDBField('ID')]
  FId: integer;
  [TAttrDBField('NOME')]
  FNome: string;
  [TAttrDBField('ENDERECO')]
  FEndereco: string;
  public
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Enredeco: string read FEndereco write FEndereco;
  end;
implementation

end.

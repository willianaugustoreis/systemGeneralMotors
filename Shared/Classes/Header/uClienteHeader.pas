unit uClienteHeader;

interface

uses
  uCustomHeader, uAtributosClasse;

type
  [TAttrDBTable('CLIENTE')]
  TClienteHeader = class(TCustomHeader)
  protected
  [TAttrDBField('ID')]
  FId: integer;
  [TAttrDBField('NOME')]
  FNome: string;
  [TAttrDBField('ENDERECO')]
  FEndereco: string;
  end;
implementation

end.

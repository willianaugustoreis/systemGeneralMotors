unit uClienteClass;

interface

uses
  uCustomClass, uClienteHeader;
type
  TClienteClass = class(TCustomClass)
  strict private
  FFields: TClienteHeader;
  protected
    procedure Insert; override;
    procedure Update; override;
  public
    constructor Create(AClienteHeader: TClienteHeader);
    procedure Save;override;

  end;
implementation

{ TClienteClass }

{ TClienteClass }

constructor TClienteClass.Create(AClienteHeader: TClienteHeader);
begin

end;

procedure TClienteClass.Insert;
begin
  inherited;

end;

procedure TClienteClass.Save;
begin

end;

procedure TClienteClass.Update;
begin
  inherited;

end;

end.

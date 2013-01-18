unit uClienteClass;

interface

uses
  uCustomClass, uClienteHeader;
type
  TClienteClass = class
  strict private
  FFields: TClienteHeader;
  protected
    procedure Insert;
    procedure Update;
  public
    constructor Create(AClienteHeader: TClienteHeader);
    procedure Save;

  end;
implementation

{ TClienteClass }

{ TClienteClass }

constructor TClienteClass.Create(AClienteHeader: TClienteHeader);
begin

end;

procedure TClienteClass.Insert;
begin

end;

procedure TClienteClass.Save;
begin

end;

procedure TClienteClass.Update;
begin

end;

end.

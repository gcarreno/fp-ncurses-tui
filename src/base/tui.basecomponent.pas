unit TUI.BaseComponent;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
;

type
{ TBaseComponent }
  TBaseComponent = class(TObject)
  private
  protected
    FWindow: PWINDOW;
    FX
  , FY
  , FWidth
  , FHeight: Integer;
    FInvalidated: Boolean;
    FName: String;
  public
    constructor Create(AX, AY, AWidth, AHeight: Integer);
    destructor Destroy; override;

    procedure Paint; virtual; abstract;
    procedure Invalidate; virtual;
    property Invalidated: Boolean
      read FInvalidated
      write FInvalidated;
    { #todo -ogcarreno : Implement Focus }
  published
    property Name: String
      read FName
      write FName;
  end;

implementation

{ TBaseComponent }

constructor TBaseComponent.Create(AX, AY, AWidth, AHeight: Integer);
begin
  FX := AX;
  FY := AY;
  FWidth := AWidth;
  FHeight := AHeight;
  FWindow:= newwin(FHeight, FWidth, FY, FX);
  keypad(FWindow, True);
end;

destructor TBaseComponent.Destroy;
begin
  if Assigned(FWindow) then
    delwin(FWindow);
  inherited Destroy;
end;

procedure TBaseComponent.Invalidate;
begin
  FInvalidated:= True;
end;

end.


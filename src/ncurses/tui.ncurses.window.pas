unit TUI.Ncurses.Window;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
;

type
{ TNCWindow }
  TNCWindow = class(TObject)
  private
    FPWINDOW: PWINDOW;
    FX,
    FY,
    FWidth,
    FHeight: Integer;
  protected
  public
    constructor Create(AX, AY, AWidth, AHeight: Integer);
    destructor Destroy; override;

    procedure MoveTo(AX, AY: Integer);
    procedure Write(const AText: String);
    procedure WriteAt(AX, AY: Integer; const AText: String);
    procedure WriteCenteredAt(AY: Integer; const AText: String);
    procedure WriteLeftAt(AY: Integer; const AText: String);
    procedure WriteRightAt(AY: Integer; const AText: String);
    procedure Border(AVType, AHType: chtype);
    procedure Refresh;
    procedure Erase;

    property PWindow: PWINDOW
      read FPWindow;
    property X: Integer
      read FX;
    property Y: Integer
      read FY;
    property WIdth: Integer
      read FWidth;
    property Height: Integer
      read FHeight;
  published
  end;

implementation

{ TNCWindow }

constructor TNCWindow.Create(AX, AY, AWidth, AHeight: Integer);
begin
  FX:= AX;
  FY:= AY;
  FWidth:= AWidth;
  FHeight:= FHeight;
  try
    FPWINDOW:= newwin(AHeight, AWidth, AY, AX);
    keypad(FPWindow, True);
    meta(FPWindow, True);
  except
    on E:Exception do
      WriteLn('Error creating window: ' + E.Message);
  end;
end;

destructor TNCWindow.Destroy;
begin
  if Assigned(FPWindow) then
    delwin(FPWindow);
  inherited Destroy;
end;

procedure TNCWindow.MoveTo(AX, AY: Integer);
begin
  wmove(FPWindow, AY, AX);
end;

procedure TNCWindow.Write(const AText: String);
begin
  waddstr(FPWindow, PAnsiChar(AText));
end;

procedure TNCWindow.WriteAt(AX, AY: Integer; const AText: String);
begin
  mvwaddstr(FPWindow, AY, AX, PAnsiChar(AText));
end;

procedure TNCWindow.WriteCenteredAt(AY: Integer; const AText: String);
var
  lx: Integer;
begin
  lx:= (FWidth - Length(AText)) div 2;
  mvwaddstr(FPWindow, AY, lx, PAnsiChar(AText));
end;

procedure TNCWindow.WriteLeftAt(AY: Integer; const AText: String);
begin
  wmove(FPWIndow, AY, 1);
  waddstr(FPWIndow, PAnsiChar(AText));
end;

procedure TNCWindow.WriteRightAt(AY: Integer; const AText: String);
var
  lx: Integer;
begin
  lx:= FWidth - Length(AText) - 1;
  wmove(FPWIndow, AY, lx);
  waddstr(FPWIndow, PAnsiChar(AText));
end;

procedure TNCWindow.Border(AVType, AHType: chtype);
begin
  box(FPWINDOW, AVType, AHType);
end;

procedure TNCWindow.Refresh;
begin
  wrefresh(FPWINDOW);
end;

procedure TNCWindow.Erase;
begin
  werase(FPWIndow);
end;

end.


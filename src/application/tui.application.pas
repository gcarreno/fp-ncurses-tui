unit TUI.Application;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, BaseUnix
, TUI.Form
;

type
{ TApplication }
  TApplication = class(Tobject)
  private
    FInitialized: Boolean;
    FHasColor: Boolean;
    FTitle: String;
    FWidth, FHeight: Integer;

  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize;
    procedure Run;

    procedure DoResize(AOldWidth, AOldHeight, ANewWidth, ANewHeight: Integer);
    procedure SetTimeout(ATimeout: Integer);
    procedure SetNoDelay(AEnabled: Boolean);
    procedure SetCursorVisibility(AVisible: Boolean);

    property Title: String
      read FTitle
      write FTitle;
    property Height: Integer
      read FHeight
      write FHeight;
    property Width: Integer
      read FWidth
      write FWidth;
  published
  end;

var
  Application: TApplication;

implementation

uses
  initc
;

const
  LC_ALL = 6;

// Needed to solve some UTF8 shenanigans
procedure setlocale(cat : integer; p : pchar); cdecl; external clib;

procedure HandleResize(sig: cint); cdecl;
var
  NewHeight: Integer = 0;
  NewWidth: Integer = 0;
begin
  if sig = SIGWINCH then
  begin
    getmaxyx(stdscr, NewHeight, NewWidth);
    if (Application.Width <> NewWidth) or (Application.Height <> NewHeight) then
    begin
      Application.DoResize(Application.Width, Application.Height, NewWidth, NewHeight);
    end;
  end;
end;

{ TApplication }

constructor TApplication.Create;
begin
  // Because UTF8, of course
  setlocale(LC_ALL, '');
  // Initialize ncurses
  initscr;
  FInitialized := True;

  // Common ncurses settings
  cbreak;                     // Disable line buffering
  noecho;                     // Don't echo pressed keys
  keypad(stdscr, TRUE);       // Enable function keys
  { #note -ogcarreno : Still unsure this should not be optional }
  SetCursorVisibility(False); // Disable cursor
  { #note -ogcarreno : Not sure about these }
  //SetTimeout(6);
  //SetNoDelay(True);

  if has_colors then
  begin
    start_color;
    use_default_colors;
    FHasColor:= True;
    { #todo -ogcarreno : Register default theme }
    //init_pair(1, COLOR_WHITE, -1);
  end;

  getmaxyx(stdscr, FHeight, FWidth);

  // Enable DoResize detection
  FpSignal(SIGWINCH, @HandleResize);

  FTitle:= '';
end;

destructor TApplication.Destroy;
begin
  // Terminate ncurses
  if FInitialized then
    endwin();
  inherited Destroy;
end;

procedure TApplication.Initialize;
begin
  //erase;
  refresh;
end;

procedure TApplication.Run;
begin
  { #todo -ogcarreno : Implement the message system loop here }
  getch;
end;

procedure TApplication.DoResize(AOldWidth, AOldHeight, ANewWidth,
  ANewHeight: Integer);
begin
  // Store new size
  FHeight:= ANewHeight;
  FWidth:= ANewWidth;
  { #todo -ogcarreno : Implement Resize }
end;

procedure TApplication.SetTimeout(ATimeout: Integer);
begin
  timeout(ATimeout);
end;

procedure TApplication.SetNoDelay(AEnabled: Boolean);
begin
  nodelay(stdscr, AEnabled);
end;

procedure TApplication.SetCursorVisibility(AVisible: Boolean);
begin
  if AVisible then
    curs_set(1)
  else
    curs_set(0);
end;

initialization

  Application:= TApplication.Create;

finalization

  Application.Free;

end.


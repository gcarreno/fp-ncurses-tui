unit TUI.BaseComponent;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.Message
;

type
{ TBorderStyle }
  TBorderStyle = (bsNone, bsSingleLine, bsDoubleLine);

{ TBaseComponent }
  TBaseComponent = class(TObject)
  private
  protected
    FWindow: PWINDOW;
    FX
  , FY
  , FWidth
  , FHeight: LongInt;
    FHasColor: Boolean;
    FInvalidated: Boolean;
    FIsFocused: Boolean;
    FCanFocus: Boolean;
    FBorderStyle: TBorderStyle;
    FName: String;

    procedure Paint; virtual;
  public
    constructor Create(AName: String; AX, AY, AWidth, AHeight: Integer);
    destructor Destroy; override;

    procedure HandleMessage(AMessage: TMessage); virtual;
    procedure Invalidate;

    procedure MoveTo(AX, AY: LongInt);
    procedure WriteText(const Text: String);
    procedure WriteTextAt(AX, AY: LongInt; const Text: String);
    procedure WriteTextCentered(AY: LongInt; const Text: String);
    procedure Border;

    property Invalidated: Boolean
      read FInvalidated;
    property CanFocus: Boolean
      read FCanFocus;
    property IsFocused: Boolean
      read FIsFocused;
  published
    property X: LongInt
      read FX;
    property Y: LongInt
      read FY;
    property Width: LongInt
      read FWidth;
    property Height: LongInt
      read FHeight;
    property Name: String
      read FName
      write FName;
  end;

implementation

uses
  TUI.Application
;

{ TBaseComponent }

constructor TBaseComponent.Create(AName: String; AX, AY, AWidth,
  AHeight: Integer);
begin
  FX := AX;
  FY := AY;
  FWidth := AWidth;
  FHeight := AHeight;
  FWindow:= newwin(FHeight, FWidth, FY, FX);
  FInvalidated:= True;
  FCanFocus:= True;
  FName:= AName;
  keypad(FWindow, True);
  meta(FWindow, True);
end;

destructor TBaseComponent.Destroy;
begin
  if Assigned(FWindow) then
    delwin(FWindow);
  inherited Destroy;
end;

procedure TBaseComponent.Paint;
begin
  if FInvalidated then
    FInvalidated:= False;
end;

procedure TBaseComponent.HandleMessage(AMessage: TMessage);
begin
  Application.Debug(Format('Base HandleMessage: %s -------------------', [
    TMessage.MessageTypeToStr(AMessage.MessageType)
  ]));
  if AMessage.MessageType = mtRefresh then
    Paint;
end;

procedure TBaseComponent.Invalidate;
begin
  FInvalidated:= True;
end;

procedure TBaseComponent.WriteText(const Text: String);
begin
  waddstr(FWindow, PChar(Text));
end;

procedure TBaseComponent.WriteTextAt(AX, AY: LongInt; const Text: String);
begin
  mvwaddstr(FWindow, AY, AX, PChar(Text));
end;

procedure TBaseComponent.WriteTextCentered(AY: LongInt; const Text: String);
var
  lx: LongInt;
begin
  lx:= (FWidth - Length(Text)) div 2;
  mvwaddstr(FWindow, AY, lx, PChar(Text));
end;

procedure TBaseComponent.Border;
begin
  case FBorderStyle of
    bsNone:
    begin
      // Do nothing and silence the warning
    end;
    bsSingleLine:
    begin
      //box(FWindow, ACS_VLINE, ACS_HLINE);
      box(FWindow, 0, 0);
    end;
    bsDoubleLine: begin
      { #todo -ogcarreno : This needs a ton more investigation }
      //wborder(FWindow,
      //  DL_HLINE, DL_HLINE,
      //  DL_VLINE, DL_VLINE,
      //  DL_TL, DL_TR,
      //  DL_BL, DL_BR);
    end;
  end;
end;

procedure TBaseComponent.MoveTo(AX, AY: LongInt);
begin
  wmove(FWindow, AY, AX);
end;

end.


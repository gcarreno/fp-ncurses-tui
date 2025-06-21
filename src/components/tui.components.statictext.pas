unit TUI.Components.StaticText;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.Message
, TUI.BaseComponent
;

type
{ TStaticText }
  TStaticText = class(TBaseComponent)
  private
    FParent: TObject;
    FCaption: String;
  protected
    procedure Paint; override;
  public
    constructor Create(const AName, ACaption: String;AX, AY: LongInt;
      AParent: TObject; AHasColor: Boolean);
    destructor Destroy; override;

    procedure HandleMessage(AMessage: TMessage); override;
  published
    property Caption: String
      read FCaption
      write FCaption;
  end;

implementation

uses
  TUI.Application
, TUI.Form
;

{ TStaticText }

constructor TStaticText.Create(const AName, ACaption: String; AX, AY: LongInt;
  AParent: TObject; AHasColor: Boolean);
begin
  FParent:= AParent;
  FX:= (FParent as TForm).x + AX;
  FY:= (FParent as TForm).x + AY;
  FWidth:= Length(ACaption);
  FHeight:= 1;
  FName:= AName;
  FCaption:= ACaption;
  FHasColor:= AHasColor;
  FCanFocus:= False;
  FIsFocused:= False;
  FInvalidated:= True;
  inherited Create(AName, FX, FY, FWidth, 1);
end;

destructor TStaticText.Destroy;
begin
  inherited Destroy;
end;

procedure TStaticText.HandleMessage(AMessage: TMessage);
begin
  Application.Debug(Format('Label HandleMessage: %s -------------------', [
    TMessage.MessageTypeToStr(AMessage.MessageType)
  ]));
  case AMessage.MessageType of
    mtRefresh: Invalidate;
  otherwise
  end;
  inherited HandleMessage(AMessage);
end;

procedure TStaticText.Paint;
begin
  if not FInvalidated then
    exit;
  Application.Debug('---- Label Paint');
  werase(FWindow);
  WriteTextAt(0, 0, FCaption);
  wrefresh(FWindow);
  inherited Paint;
end;

end.


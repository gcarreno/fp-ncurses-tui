unit TUI.Components.StaticText;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.BaseTypes
, TUI.Core.Message
;

type
{ TStaticText }
  TStaticText = class(TBaseComponent)
  private
    FCaption: String;
  protected
  public
    procedure Initialize; override;

    procedure HandleMessage(AMessage: TMessage); override;
    procedure Paint; override;

    procedure Focus; override;
    procedure Blur; override;
  published
    property Caption: String
      read FCaption
      write FCaption;
  end;

implementation

{ TStaticText }

procedure TStaticText.Initialize;
begin
  { #note -ogcarreno : This will contain ncurses window setup if I ever
                       decide to make components in a window }
end;

procedure TStaticText.HandleMessage(AMessage: TMessage);
begin
  FParent.Debug(Format('TStaticText.HandleMessage(%s)',[
    TMessage.MessageTypeToStr(AMessage)
  ]));
  case AMessage.MessageType of
    mtFocus:
    begin
      Focus;
    end;
    mtBlur:
    begin
      Blur;
    end;
    mtMouse:
    begin
      if not FIsFocused then
      begin
        Focus;
      end;
      { #todo -ogcarreno : Cycle through the components to determine if it's
                           been clicked }
    end;
    mtRefresh: Paint;
  otherwise
    // Silence the warning
  end;
end;

procedure TStaticText.Paint;
begin
  FParent.Debug('TStaticText.Paint');
  if not FInvalidated then
    exit;
  FParent.Window.WriteAt(FX, FY, FCaption);
end;

procedure TStaticText.Focus;
begin
  if not FIsFocused then
  begin
    FIsFocused:= True;
    Invalidate;
  end;
end;

procedure TStaticText.Blur;
begin
  if FIsFocused then
  begin
    FIsFocused:= False;
    Invalidate;
  end;
end;

end.


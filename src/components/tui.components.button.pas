unit TUI.Components.Button;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, TUI.BaseTypes
, TUI.Core.Message
;

type
{ TButton }
  TButton = class(TBaseComponent)
  private
    FCaption: String;
  protected
    FOnCLick: TNotifyEvent;
  public
    procedure Initialize; override;

    procedure HandleMessage(AMessage: TMessage); override;
    procedure Paint; override;
    procedure Focus; override;
    procedure Blur; override;

    property OnCLick: TNotifyEvent
      read FOnCLick
      write FOnCLick;
  published
    property Caption: String
      read FCaption
      write FCaption;
  end;

implementation

uses
  ncurses
;

const
  cCaptionFormat = '[ %s ]';

  { TButton }

procedure TButton.Initialize;
begin
  { #note -ogcarreno : This will contain ncurses window setup if I ever
                       decide to make components in a window }
end;

procedure TButton.HandleMessage(AMessage: TMessage);
begin
  FParent.Debug(Format('TButton.HandleMessage(%s)',[
    TMessage.MessageTypeToStr(AMessage)
  ]));
  case AMessage.MessageType of
    mtMouse:
    begin
      if Assigned(FOnCLick) then
        FOnClick(Self);
    end;
    mtRefresh: Paint;
  otherwise
    // Silence the warning
  end;
end;

procedure TButton.Paint;
begin
  FParent.Debug('TButton.Paint');
  if not FInvalidated then
    exit;
  FParent.Window.WriteAt(FX, FY, Format(cCaptionFormat, [FCaption]));
end;

procedure TButton.Focus;
begin
  //
end;

procedure TButton.Blur;
begin
  //
end;

end.


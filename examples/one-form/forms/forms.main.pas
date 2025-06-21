unit Forms.Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.BaseComponent
, TUI.Form
, TUI.Message
;

type
{ TfrmMain }
  TfrmMain = class(TForm)
  private
  protected
    procedure Paint; override;
  public
    constructor Create(AHasColor: Boolean);

    procedure HandleMessage(AMessage: TMessage); override;
  published
  end;

var
  frmMain: TfrmMain;

implementation

uses
  TUI.Application
;

{ TfrmMain }

constructor TfrmMain.Create(AHasColor: Boolean);
begin
  FX:= 2;
  FY:= 2;
  FWidth:= 35;
  FHeight:= 5;
  FBorderStyle:= bsSingleLine;
  FCaption:= 'Main Form';
  inherited Create('frmMain', AHasColor);
end;

procedure TfrmMain.Paint;
begin
  Application.Debug(FName + 'Paint');
  WriteTextAt(2, 1, 'This is ' + FName);
  WriteLineCentered(3, 'Focus me and press [Q] to exit');
  inherited Paint;
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
var
  message: TMessage;
begin
  Application.Debug('frmMain HandleMessage');
  inherited HandleMessage(AMessage);
  case AMessage.MessageType of
    mtKey:
    begin
      if (AMessage.WParam = Ord('Q')) or (AMessage.WParam = Ord('q')) then
        Application.Terminate;
    end;
    mtMouse:
    begin
      if not FIsFocused then
      begin
        message:= TMessage.Create(
          mtFocus,
          nil,
          Self,
          0,
          0,
          nil
        );
        Application.PostMessage(message);
      end;
      { #todo -ogcarreno : Cycle through the components to determine if it's been clicked }
    end;
  otherwise
    // Silence the warning
  end;
end;

end.


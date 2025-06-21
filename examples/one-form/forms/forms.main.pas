unit Forms.Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.BaseComponent
, TUI.Message
, TUI.Form
, TUI.Components.StaticText
;

type
{ TfrmMain }
  TfrmMain = class(TForm)
  private
    FLabel: TStaticText;
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
  FWidth:= 45;
  FHeight:= 15;
  FBorderStyle:= bsSingleLine;
  FCaption:= 'Main Form';

  inherited Create('frmMain', AHasColor);

  FLabel:= TStaticText.Create(
    'lblHello1',
    'Label: lblHello1',
    2,
    4,
    Self,
    Application.HasColor);
  FComponents.Add(FLabel);
  FLabel:= TStaticText.Create(
    'lblHello2',
    'Label: lblHello2',
    2,
    5,
    Self,
    Application.HasColor);
  FComponents.Add(FLabel);
end;

procedure TfrmMain.Paint;
begin
  Application.Debug(FName + 'Paint: ' + FName);
  inherited Paint;

  //werase(FWindow);
  if FIsFocused then
    WriteTextAt(FWidth - 11, FHeight-1, '[Focus: Y]')
  else
    WriteTextAt(FWidth - 11, FHeight-1, '[Focus: N]');

  WriteTextCentered(2, 'This is ' + FName);
  WriteTextCentered(FHeight-2, 'Focus me and press [Q] to exit');
  { #note -ogcarreno : For the time being, this needs to be here.
                       Neede a solution to put it elsewehere }
  wrefresh(FWindow);
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
        Invalidate;
      end;
      { #todo -ogcarreno : Cycle through the components to determine if it's been clicked }
    end;
  otherwise
    // Silence the warning
  end;
end;

end.


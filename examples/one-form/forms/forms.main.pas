unit Forms.Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.Core.Form
, TUI.Core.Message
;

type
{ TfrmMain }
  TfrmMain = class(TForm)
  private
    //FLabel: TStaticText;
  protected
  public
    procedure Initialize; override;
    procedure HandleMessage(AMessage: TMessage); override;
    procedure Paint; override;
  published
  end;

var
  frmMain: TfrmMain;

implementation

{ TfrmMain }

procedure TfrmMain.Initialize;
begin
  FX:= 2;
  FY:= 2;
  FWidth:= 45;
  FHeight:= 15;
  FBorderStyle:= bsSingleLine;
  FName:= 'frmMain';
  FCaption:= 'Main Form';
  CreateWindow(FX, FY, FWidth, FHeight);
  //FLabel:= TStaticText.Create(
  //  'lblHello1',
  //  'Label: lblHello1',
  //  2,
  //  4,
  //  Self,
  //  Application.HasColor);
  //FComponents.Add(FLabel);
  //FLabel:= TStaticText.Create(
  //  'lblHello2',
  //  'Label: lblHello2',
  //  2,
  //  5,
  //  Self,
  //  Application.HasColor);
  //FComponents.Add(FLabel);
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
var
  message: TMessage;
begin
  FParent.Debug(Format('TfrmMain.HandleMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
  inherited HandleMessage(AMessage);
  case AMessage.MessageType of
    mtKey:
    begin
      if (AMessage.WParam = Ord('Q')) or (AMessage.WParam = Ord('q')) then
        FParent.Terminate;
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
        FParent.PostMessage(message);
        Invalidate;
      end;
      { #todo -ogcarreno : Cycle through the components to determine if it's been clicked }
    end;
  otherwise
    // Silence the warning
  end;
end;

procedure TfrmMain.Paint;
begin
  inherited Paint;

  { #todo -ogcarreno : Remove this code, or move it }
  if FIsFocused then
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: Y]')
  else
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: N]');

  FWindow.WriteCenteredAt(2, 'This is ' + FName);
  FWindow.WriteCenteredAt(FHeight-2, 'Focus me and press [Q] to exit');
  { #note -ogcarreno : For the time being, this needs to be here.
                       Neede a solution to put it elsewehere }
  FWindow.Refresh;
end;

end.


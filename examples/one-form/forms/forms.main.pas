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
  FX:= 0;
  FY:= 0;
  FWidth:= COLS - 1;
  FHeight:= LINES - 3;
  FBorderStyle:= bsSingleLine;
  FName:= 'frmMain';
  FCaption:= 'Main Form';
  CreateWindow(FX, FY, FWidth, FHeight);
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
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
  otherwise
    // Silence the warning
  end;
end;

procedure TfrmMain.Paint;
begin
  inherited Paint;

  {$IFDEF DEBUG}
  if FIsFocused then
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: Y]')
  else
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: N]');
  {$ENDIF}

  FWindow.WriteCenteredAt(2, 'This is ' + FName);
  FWindow.WriteCenteredAt(FHeight-2, 'Focus me and press [Q] to exit');

  { #note -ogcarreno : If you do anything here you have to call this}
  FWindow.Refresh;
end;

end.


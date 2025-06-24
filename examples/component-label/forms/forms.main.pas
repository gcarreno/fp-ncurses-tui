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

uses
  TUI.Components.StaticText
;

{ TfrmMain }

procedure TfrmMain.Initialize;
var
  FLabel: TStaticText;
begin
  FParent.Debug('TfrmMain.Initialize');
  FX:= 0;
  FY:= 0;
  FWidth:= COLS - 1;
  FHeight:= LINES - 3;
  FBorderStyle:= bsSingleLine;
  FName:= 'frmMain';
  FCaption:= 'Main Form';
  CreateWindow(FX, FY, FWidth, FHeight);

  FParent.Debug('  Create 1');
  FLabel:= TStaticText.Create(Self);
  FLabel.Initialize;
  FLabel.Name:= 'lblHello1';
  FLabel.Caption:= 'Label: lblHello1';
  FLabel.X:= 2;
  FLabel.Y:= 2;
  FLabel.Width:= Length(FLabel.Caption);
  FLabel.Height:= 1;
  AddComponent(FLabel);
  FParent.Debug('  Create 2');
  FLabel:= TStaticText.Create(Self);
  FLabel.Initialize;
  FLabel.Name:= 'lblHello2';
  FLabel.Caption:= 'Label: lblHello2';
  FLabel.X:= 2;
  FLabel.Y:= 4;
  FLabel.Width:= Length(FLabel.Caption);
  FLabel.Height:= 1;
  AddComponent(FLabel);
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
begin
  inherited HandleMessage(AMessage);

  FParent.Debug(Format('TfrmMain.HandleMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
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
  FParent.Debug('TfrmMain.Paint');
  {$IFDEF DEBUG}
  if FIsFocused then
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: Y]')
  else
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: N]');
  {$ENDIF}

  FWindow.WriteCenteredAt(FHeight-2, 'Focus me and press [Q] to exit');

  { #note -ogcarreno : If you do anything here you have to call this}
  FWindow.Refresh;
end;

end.


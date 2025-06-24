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
    procedure OnClick(Sender: TObject);
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
  TUI.Components.Button
;

{ TfrmMain }

procedure TfrmMain.OnClick(Sender: TObject);
begin
  FParent.Terminate;
end;

procedure TfrmMain.Initialize;
var
  button: TButton;
begin
  FX:= 2;
  FY:= 2;
  FWidth:= 45;
  FHeight:= 15;
  FBorderStyle:= bsSingleLine;
  FName:= 'frmMain';
  FCaption:= 'Main Form';
  CreateWindow(FX, FY, FWidth, FHeight);

  button:= TButton.Create(Self);
  button.Name:= 'Button1';
  button.Caption:='Quit';
  button.X:= 3;
  button.Y:= 13;
  button.Width:= Length(Format('[ %s ]', [button.Caption]));
  button.Height:= 1;
  button.OnCLick:= @OnClick;
  AddComponent(button);
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
begin
  inherited HandleMessage(AMessage);
  FParent.Debug(Format('TfrmMain.HandleMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
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

  { #note -ogcarreno : If you do anything here you have to call this}
  FWindow.Refresh;
end;

end.


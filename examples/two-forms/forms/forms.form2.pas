unit Forms.Form2;

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
{ TForm2 }
  TForm2 = class(TForm)
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
  Form2: TForm2;

implementation

{ TForm1 }

procedure TForm2.Initialize;
begin
  FX:= COLS div 2;
  FY:= 0;
  FWidth:= COLS div 2;
  FHeight:= LINES -2;
  FBorderStyle:= bsSingleLine;
  FName:= 'Form2';
  FCaption:= 'Form Two';
  CreateWindow(FX, FY, FWidth, FHeight);
end;

procedure TForm2.HandleMessage(AMessage: TMessage);
begin
  FParent.Debug(Format('TfrmMain.HandleMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));

  inherited HandleMessage(AMessage);
end;

procedure TForm2.Paint;
begin
  inherited Paint;

  {$IFDEF DEBUG}
  if FIsFocused then
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: Y]')
  else
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: N]');
  {$ENDIF}

  FWindow.WriteCenteredAt(2, 'This is ' + FName);

  { #note -ogcarreno : If you do anything here you have to call this}
  FWindow.Refresh;
end;

end.


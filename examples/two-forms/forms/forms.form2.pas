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
  FX:= 47;
  FY:= 2;
  FWidth:= 45;
  FHeight:= 15;
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

  { #todo -ogcarreno : Remove this code, or move it }
  if FIsFocused then
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: Y]')
  else
    FWindow.WriteAt(FWidth - 11, FHeight-1, '[Focus: N]');

  FWindow.WriteCenteredAt(2, 'This is ' + FName);
  { #note -ogcarreno : For the time being, this needs to be here.
                       Neede a solution to put it elsewehere }
  FWindow.Refresh;
end;

end.


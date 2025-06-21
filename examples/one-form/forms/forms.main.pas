unit Forms.Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.Form
, TUI.Message
;

type
{ TfrmMain }
  TfrmMain = class(TForm)
  private
    procedure Paint; override;
  protected
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
{$IFDEF DEBUG}
  FX:= 32;
{$ELSE}
  FX:= 2;
{$ENDIF}
  FY:= 2;
  FWidth:= 35;
  FHeight:= 5;
  FBorderStyle:= bsSingleLine;
  FCaption:= 'Main Form';
  inherited Create(AHasColor);
end;

procedure TfrmMain.Paint;
begin
  inherited Paint;
  Application.Debug('frmMain Paint');
  WriteTextAt(2, 1, 'This is frmMain');
  MoveTo(5, 3);
  WriteText('Press [ESC] to exit');
  wrefresh(FWindow);
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
begin
  Application.Debug('frmMain HandleMessage');
  inherited HandleMessage(AMessage);
  case AMessage.MessageType of
    mtKey:
    begin
      if AMessage.WParam = 27 then
        Application.Terminate;
    end;
  otherwise
    // Silence the warning
  end;
end;

end.


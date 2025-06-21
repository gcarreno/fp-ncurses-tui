unit Forms.Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.Form
;

type
{ TfrmMain }
  TfrmMain = class(TForm)
  private
  protected
  public
    procedure Paint; override;
  published
  end;

var
  frmMain: TfrmMain;

implementation

{ TfrmMain }

procedure TfrmMain.Paint;
begin
  inherited Paint;
  WriteTextAt(2, 1, 'This is frmMain');
  MoveTo(5, 3);
  WriteText('Press any key to exit');
  wrefresh(FWindow);
end;

end.


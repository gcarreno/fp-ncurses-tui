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
    constructor Create(AHasColor: Boolean);

    procedure Paint; override;
  published
  end;

var
  frmMain: TfrmMain;

implementation

{ TfrmMain }

constructor TfrmMain.Create(AHasColor: Boolean);
begin
  FX:= 1;
  FY:= 1;
  FWidth:= 35;
  FHeight:= 5;
  FBorderStyle:= bsSingleLine;
  inherited Create(AHasColor);
end;

procedure TfrmMain.Paint;
begin
  inherited Paint;
  WriteTextAt(2, 1, 'This is frmMain');
  MoveTo(5, 3);
  WriteText('Press any key to exit');
  wrefresh(FWindow);
end;

end.


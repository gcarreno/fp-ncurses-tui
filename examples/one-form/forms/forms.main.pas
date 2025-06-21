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
  FX:= 2;
  FY:= 2;
  FWidth:= 35;
  FHeight:= 5;
  FBorderStyle:= bsSingleLine;
  inherited Create(AHasColor);
end;

procedure TfrmMain.Paint;
begin
  inherited Paint;
  Application.Debug('frmMain Paint');
  WriteTextAt(2, 1, 'This is frmMain');
  MoveTo(5, 3);
  WriteText('Press any key to exit');
  wrefresh(FWindow);
end;

procedure TfrmMain.HandleMessage(AMessage: TMessage);
begin
  Application.Debug('frmMain HandleMessage');
  inherited HandleMessage(AMessage);
  case AMessage.MessageType of
    mtKey:
    begin
      Application.Terminate;
    end;
    //mtRefresh:
    //begin
    //  { #note -ogcarreno : This needs to be handled at the Base level }
    //  Paint;
    //end;
  otherwise
    // Silence the warning
  end;
end;

end.


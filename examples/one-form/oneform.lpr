program OneForm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  TUI.Application,
  TUI.Form,
  Forms.Main
  { you can add units after this };

var
  frmMain: TfrmMain;

begin
  Application.Title:= 'One Form';
  Application.Initialize;

  { #note -ogcarreno : Temp form handling, before list of Forms implemented }
  frmMain:= TfrmMain.Create(1, 1, 35, 5, bsSingleLine);
  //frmMain:= TForm.Create(1, 1, 35, 5);
  try
    frmMain.WriteTextAt(1, 1, 'This is frmMain talking');
    frmMain.MoveTo(15, 2);
    frmMain.WriteText('Treta');
    frmMain.Paint;

    Application.Run;

  finally
    frmMain.Free;
  end;

end.


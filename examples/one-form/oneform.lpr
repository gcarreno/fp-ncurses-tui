program OneForm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  TUI.BaseTypes,
  TUI.Application,
  TUI.Form,
  Forms.Main
  { you can add units after this };

begin
  Application.Title:= 'One Form';
  Application.Initialize;
  frmMain:= TfrmMain.Create(Application.HasColor);
  Application.AddForm(frmMain);
  Application.Run;

end.


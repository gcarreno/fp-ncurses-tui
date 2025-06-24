program componentlabel;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  TUI.Core.Application,
  Forms.Main;

begin
  Application.Title:= 'One Form';
  Application.Initialize;
  frmMain:= TfrmMain.Create(Application);
  Application.AddForm(frmMain);
  Application.Run;
end.


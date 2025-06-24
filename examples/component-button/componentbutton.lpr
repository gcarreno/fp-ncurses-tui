program ComponentButton;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  TUI.Core.Application,
  Forms.Main;

begin
  Application.Title:= 'Component Button';
  Application.Initialize;
  frmMain:= TfrmMain.Create(Application);
  Application.AddForm(frmMain);
  Application.Run;
end.


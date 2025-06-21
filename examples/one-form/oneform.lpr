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

  { #todo -ogcarreno : Consider the `LCL` approach of `CreateForm` }
  frmMain:= TfrmMain.Create(1, 1, 35, 5, Application.HasColor, bsSingleLine);

  Application.AddForm(frmMain);
  Application.Run;

end.


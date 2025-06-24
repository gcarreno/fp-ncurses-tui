program TwoForms;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  TUI.Core.Application,
  Forms.Form1,
  Forms.Form2;

begin
  Application.Title:= 'One Form';
  Application.Initialize;
  Form1:= TForm1.Create(Application);
  Form2:= TForm2.Create(Application);
  Application.AddForm(Form1);
  Application.AddForm(Form2);
  Application.Run;
end.


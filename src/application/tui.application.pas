unit TUI.Application;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, Contnrs
, BaseUnix
, TUI.Message
, TUI.BaseComponent
, TUI.Form
;

type
{ TApplication }
  TApplication = class(Tobject)
  private
    FInitialized: Boolean;
    FHasColor: Boolean;
    FTitle: String;
    FWidth, FHeight: Integer;

    FMessages: TFPObjectList;

    FFocusedForm: TForm;
    FForms: TFPObjectList;

    FQuit: Boolean;

    FDebug: TStringList;
    procedure ProcessMessages;

  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure Debug(AMessage: String);
    procedure Initialize;
    procedure Run;

    procedure DoResize(AOldWidth, AOldHeight, ANewWidth, ANewHeight: Integer);
    procedure RedrawAllForms;
    procedure SetTimeout(ATimeout: Integer);
    procedure SetNoDelay(AEnabled: Boolean);
    procedure SetCursorVisibility(AVisible: Boolean);
    function PollInput(out AMessage: TMessage): Boolean;
    procedure PostMessage(const AMessage: TMessage);
    function GetMessage(out AMessage: TMessage): Boolean;
    procedure DispatchMessage(const AMessage: TMessage);
    procedure Terminate;

    //procedure CreateForm(InstanceClass: TFormClass; out Reference);
    function AddForm(AForm: TForm): Integer;


    property HasColor: Boolean
      read FHasColor;
    property Title: String
      read FTitle
      write FTitle;
    property Height: Integer
      read FHeight
      write FHeight;
    property Width: Integer
      read FWidth
      write FWidth;
  published
  end;

var
  Application: TApplication;

implementation

uses
  initc
;

const
  LC_ALL = 6;

// Needed to solve some UTF8 shenanigans
function setlocale(cat : integer; p : pchar):PChar; cdecl; external clib;

procedure HandleResize(sig: cint); cdecl;
var
  NewHeight: Integer = 0;
  NewWidth: Integer = 0;
begin
  if sig = SIGWINCH then
  begin
    getmaxyx(stdscr, NewHeight, NewWidth);
    if (Application.Width <> NewWidth) or (Application.Height <> NewHeight) then
    begin
      Application.DoResize(Application.Width, Application.Height, NewWidth, NewHeight);
      Application.RedrawAllForms;
    end;
  end;
end;

{ TApplication }

procedure TApplication.Debug(AMessage: String);
begin
{$IFDEF DEBUG}
  FDebug.Append(AMessage);
  waddstr(stdscr, PChar(AMessage + LineEnding));
{$ENDIF}
end;

procedure TApplication.ProcessMessages;
var
  message: TMessage;
begin
  Debug('Process Messages');
  // Dispatch all queued messages
  Debug('Before GetMessage');
  while GetMessage(message) do
  begin
    Debug(Format('Loop: %s, %d', [ TMessage.MessageTypeToStr(message.MessageType), message.WParam]));
    DispatchMessage(message);
    message.Free;
  end;
  Debug('After GetMessage');
end;

constructor TApplication.Create;
begin
  FTitle:= '';
  FMessages:= TFPObjectList.Create(True);
  FForms:= TFPObjectList.Create(True);
  FFocusedForm:= nil;
  FQuit:= False;

  FDebug:= TStringList.Create;

end;

destructor TApplication.Destroy;
begin
  FMessages.Free;
  FForms.Free;
  // Terminate ncurses
  if FInitialized then
    endwin();

  WriteLn(FDebug.Text);
  FDebug.Free;

  inherited Destroy;
end;

procedure TApplication.Initialize;
var
  loc: PChar;
begin
  // Because UTF8, of course
  loc:= setlocale(LC_ALL, '');
  Debug('LC_ALL: ' + String(loc));
  // Initialize ncurses
  initscr;
  FInitialized := True;

  // Common ncurses settings
  cbreak;               // Disable line buffering
  noecho;               // Don't echo pressed keys
  keypad(stdscr, TRUE); // Enable function keys
  meta(stdscr, TRUE);   // ?

  { #note -ogcarreno : Still unsure this should not be optional }
  SetCursorVisibility(False); // Disable cursor
  { #note -ogcarreno : Not sure about these }
  //SetTimeout(6);
  //SetNoDelay(True);

  if has_colors then
  begin
    start_color;
    use_default_colors;
    FHasColor:= True;
    { #todo -ogcarreno : Register default theme }
    //init_pair(1, COLOR_WHITE, -1);
  end;

  getmaxyx(stdscr, FHeight, FWidth);

  // Enable DoResize detection
  FpSignal(SIGWINCH, @HandleResize);
  //erase;
  refresh;
end;

procedure TApplication.Run;
var
  message: TMessage;
begin
  while not FQuit do
  begin
    // Redraw everything
    RedrawAllForms;

    // Poll input and post as message
    if PollInput(message) then
    begin
      PostMessage(message);
    end;

    ProcessMessages;

    napms(10);
  end;
end;

procedure TApplication.DoResize(AOldWidth, AOldHeight, ANewWidth,
  ANewHeight: Integer);
begin
  // Store new size
  FHeight:= ANewHeight;
  FWidth:= ANewWidth;
  { #todo -ogcarreno : Implement Resize }
end;

procedure TApplication.RedrawAllForms;
var
  index: Integer;
  message: TMessage;
begin
  Debug('RedrawAllForms');
  for index:= 0 to Pred(FForms.Count) do
  begin
    if (FForms[index] as TForm).Invalidated then
    begin
      message:= TMessage.Create(
        mtRefresh,
        nil,
        (FForms[index] as TForm),
        0,
        0,
        nil
      );
      PostMessage(message);
    end;
  end;
  ProcessMessages;
end;

procedure TApplication.SetTimeout(ATimeout: Integer);
begin
  timeout(ATimeout);
end;

procedure TApplication.SetNoDelay(AEnabled: Boolean);
begin
  nodelay(stdscr, AEnabled);
end;

procedure TApplication.SetCursorVisibility(AVisible: Boolean);
begin
  if AVisible then
    curs_set(1)
  else
    curs_set(0);
end;

function TApplication.PollInput(out AMessage: TMessage): Boolean;
var
  Key: Integer;
begin
  Key := getch;
  Result := Key <> ERR;
  if Result then
  begin
    AMessage:= TMessage.Create(
      mtkey,
      nil,
      FFocusedForm,
      Key,
      0,
      nil
    );
    Debug(Format('Poll: %s, %d', [TMessage.MessageTypeToStr(AMessage.MessageType), AMessage.WParam]));
  end;
end;

procedure TApplication.PostMessage(const AMessage: TMessage);
begin
  FMessages.Add(AMessage);
  Debug(Format('Post(%d): %s, %d', [
    FMessages.Count,
    TMessage.MessageTypeToStr(AMessage.MessageType),
    AMessage.WParam]));
end;

function TApplication.GetMessage(out AMessage: TMessage): Boolean;
begin
  Result:= FMessages.Count > 0;
  if Result then
  begin
    AMessage:= (FMessages[0] as TMessage).Copy;
    Debug(Format('Get: %s, %d', [TMessage.MessageTypeToStr(AMessage.MessageType), AMessage.WParam]));
    FMessages.Delete(0);
  end;
end;

procedure TApplication.DispatchMessage(const AMessage: TMessage);
begin
  Debug(Format('Dispatch: %s, %d', [TMessage.MessageTypeToStr(AMessage.MessageType), AMessage.WParam]));
  if Assigned(AMessage.Target) and (AMessage.Target is TBaseComponent) then
  begin
    Debug('Dispatch target');
    TBaseComponent(AMessage.Target).HandleMessage(AMessage);
  end
  else
  begin
    Debug('Dispatch else');
  end;
end;

procedure TApplication.Terminate;
begin
  FQuit:= True;
end;

function TApplication.AddForm(AForm: TForm): Integer;
var
  focus: TMessage;
begin
  Result:= FForms.Add(AForm);
  FFocusedForm:= AForm;
  focus:= TMessage.Create(mtFocus, nil, FFocusedForm, 0, 0, nil);
  PostMessage(focus);
  { #todo -ogcarreno : Do we need this? }
  //ProcessMessages;
end;

//procedure TApplication.CreateForm(InstanceClass: TFormClass; out Reference);
//var
//  Instance: TForm;
//  ok: Boolean;
//begin
//  // Allocate the instance, without calling the constructor
//  Instance := TForm(InstanceClass.NewInstance);
//  // set the Reference before the constructor is called, so that
//  // events and constructors can refer to it
//  TForm(Reference) := Instance;
//
//  ok:= False;
//  try
//    Instance.Create(FHasColor);
//    FForms.Add(Instance);
//    ok:= True;
//  finally
//    if not ok then
//    begin
//      TForm(Reference):= nil;
//    end;
//  end;
//end;

initialization

  Application:= TApplication.Create;

finalization

  Application.Free;

end.


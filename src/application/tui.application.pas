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

    function WindowAt(AX, AY: LongInt): TForm;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure Debug(AMessage: String);
    procedure ProcessMessages;
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

procedure HandleSIgnals(sig: cint); cdecl;
begin
  case sig of
    SIGINT:  Application.Terminate;
    SIGKILL: Application.Terminate;
  end;
end;

{ TApplication }

function TApplication.WindowAt(AX, AY: LongInt): TForm;
var
  index: Integer;
  form: TForm;
begin
  Result:= nil;
  for index:= Pred(FForms.Count) downto 0 do
  begin
    form:= (FForms[index] as TForm);
    if (form.X <= AX) and ((form.X + form.Width) >= AX) and
       (form.Y <= AY) and ((form.Y + form.Height) >= AY) then
    begin
      result:= form;
      break;
    end;
  end;
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

procedure TApplication.Debug(AMessage: String);
begin
{$IFDEF DEBUG}
  FDebug.Append(AMessage);
//  waddstr(stdscr, PChar(AMessage + LineEnding));
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
  keypad(stdscr, True); // Enable function keys
  meta(stdscr, True);   // ?
  mousemask(ALL_MOUSE_EVENTS or REPORT_MOUSE_POSITION, nil);

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

  // Enable Signal Handling
  FpSignal(SIGINT,  @HandleSIgnals);
  FpSignal(SIGKILL, @HandleSIgnals);

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
  ProcessMessages;
  if Assigned(FFocusedForm) then
    mvwaddstr(stdscr, LINES-1, 0, PChar(
      Format('Focus: %s          ', [FFocusedForm.Name])
    ))
  else
    mvwaddstr(stdscr, LINES-1, 0, PChar('Focus: None          '));

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
  key: LongInt;
  event: MEVENT;
  return: LongInt;
begin
  key := getch;

  case key of
    ERR: Result:= False;
    KEY_MOUSE:
    begin
      return:= getmouse(@event);
      if return = OK then
      begin
        AMessage:= TMessage.Create(
          mtMouse,
          nil,
          WindowAt(event.x, event.y),
          event.bstate,
          event.y shl 16 or event.x,
          nil
        );
        Result:= True;
      end
      else
      begin
        Result:= False;
      end;
      Debug(Format('Poll: %s, %d', [TMessage.MessageTypeToStr(AMessage.MessageType), AMessage.WParam]));
    end;
    otherwise
    begin
      { #note -ogcarreno : Until the other events are complete, default to mtKey }
      AMessage:= TMessage.Create(
        mtkey,
        nil,
        FFocusedForm,
        key,
        0,
        nil
      );
      Result:= True;
      Debug(Format('Poll: %s, %d', [TMessage.MessageTypeToStr(AMessage.MessageType), AMessage.WParam]));
    end;
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
var
  message: TMessage;
begin
  Debug(Format('Dispatch: %s, %d', [TMessage.MessageTypeToStr(AMessage.MessageType), AMessage.WParam]));
  if Assigned(AMessage.Target) and (AMessage.Target is TBaseComponent) then
  begin
    Debug('Dispatch target');
    TBaseComponent(AMessage.Target).HandleMessage(AMessage);
    case AMessage.MessageType of
      mtMouse:
      begin
        if AMessage.Target is TForm then
          FFocusedForm:= TForm(AMessage.Target);
      end;
      otherwise
    end;
  end
  else
  begin
    Debug('Dispatch no target');
    case AMessage.MessageType of
      mtMouse:
      begin
        message:= TMessage.Create(
          mtBlur,
          nil,
          FFocusedForm,
          0,
          0,
          nil
        );
        PostMessage(message);
        FFocusedForm:= nil;
      end;
      otherwise
    end;
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


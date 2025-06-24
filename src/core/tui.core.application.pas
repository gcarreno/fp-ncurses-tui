unit TUI.Core.Application;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, Contnrs
, BaseUnix
, TUI.BaseTypes
, TUI.Core.Message
, TUI.Core.Form
;

type
{ TApplication }
  TApplication = class(TBaseApplication)
  private
    FInitialized: Boolean;
    FHasColor: Boolean;
    FFocusedForm: TForm;
    FQuit: Boolean;

    procedure SetCursorVisible(AValue: Boolean);

    function WindowAt(AX, AY: Integer): TForm;

    function PollInput(out AMessage: TMessage): Boolean;
    function GetMessage(out AMessage: TMessage): Boolean;
    procedure DispatchMessage(const AMessage: TMessage);
  protected
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Initialize; override;
    procedure Run; override;
    procedure Terminate; override;

    function  AddForm(AForm: TBaseForm): Integer;
    procedure RedrawAllForms;
    procedure ProcessMessages;
    procedure PostMessage(const AMessage: TMessage); override;

    property HasColor: Boolean
      read FHasColor;
    property CursorVisible: Boolean
      read FCursorVisible
      write SetCursorVisible;
  published
  end;

var
  Application: TApplication;

implementation
uses
  clocale
, ncurses
;

procedure HandleResize(sig: cint); cdecl;
var
  NewHeight: Integer = 0;
  NewWidth: Integer = 0;
begin
  if sig = SIGWINCH then
  begin
    getmaxyx(stdscr, NewHeight, NewWidth);
    { #todo -ogcarreno : This needs to be uncommented }
    //if (Application.Width <> NewWidth) or (Application.Height <> NewHeight) then
    //begin
    //  Application.DoResize(Application.Width, Application.Height, NewWidth, NewHeight);
    //  Application.RedrawAllForms;
    //end;
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

procedure TApplication.SetCursorVisible(AValue: Boolean);
begin
  if FCursorVisible=AValue then Exit;
  FCursorVisible:=AValue;
  if FCursorVisible then
    curs_set(1)
  else
    curs_set(0);
end;

function TApplication.WindowAt(AX, AY: Integer): TForm;
var
  index: Integer;
  form: TForm;
begin
  //Debug(Format('TApplication.WindowAt(%d, %d)', [AX, AY]));
  Result:= nil;
  //Debug(Format('  FForms.Count: %d', [FForms.Count]));
  for index:= Pred(FForms.Count) downto 0 do
  begin
    //Debug(Format('  Index: %d', [index]));
    form:= (FForms[index] as TForm);
    if (form.X <= AX) and ((form.X + form.Width) >= AX) and
       (form.Y <= AY) and ((form.Y + form.Height) >= AY) then
    begin
      //Debug('  Got Form');
      Result:= form;
      break;
    end;
  end;
end;

procedure TApplication.Initialize;
begin
  Debug('TApplication.Initialize');
  // Initialize ncurses
  initscr;
  FInitialized := True;

  // Common ncurses settings
  cbreak;               // Disable line buffering
  noecho;               // Don't echo pressed keys
  keypad(stdscr, True); // Enable function keys
  meta(stdscr, True);   // ?
  mousemask(ALL_MOUSE_EVENTS or REPORT_MOUSE_POSITION, nil);
  //timeout(10);

  if FCursorVisible then
    curs_set(1)
  else
    curs_set(0);

  if has_colors then
  begin
    start_color;
    use_default_colors;
    FHasColor:= True;
  end;

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
  Debug('TApplication.Run');
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
  end;
end;

function TApplication.AddForm(AForm: TBaseForm): Integer;
begin
  Result:= FForms.Add(AForm);
  AForm.Initialize;
  if Assigned(FFocusedForm) then
    PostMessage(TMessage.CreateBlur(FFocusedForm));
  PostMessage(TMessage.CreateFocus(AForm));
  FFocusedForm:= TForm(AForm);
  ProcessMessages;
end;


procedure TApplication.RedrawAllForms;
var
  index: Integer;
  message: TMessage;
  {$IFDEF DEBUG}
  version: String;
  {$ENDIF}
begin
  Debug('TApplication.RedrawAllForms');
  for index:= 0 to Pred(FForms.Count) do
  begin
    message:= TMessage.CreateRefresh(nil, FForms[index] as TForm);
    PostMessage(message);
  end;
  ProcessMessages;
  {$IFDEF DEBUG}
  version:= curses_version;
  mvwaddstr(stdscr, LINES-1, COLS-Length(version), PAnsiChar(version));
  if Assigned(FFocusedForm) then
    mvwaddstr(stdscr, LINES-1, 0, PAnsiChar(
      Format('Focus: %s          ', [FFocusedForm.Name])
    ))
  else
    mvwaddstr(stdscr, LINES-1, 0, PAnsiChar('Focus: None          '));
  {$ENDIF}
end;

procedure TApplication.ProcessMessages;
var
  message: TMessage;
begin
  Debug('TApplication.ProcessMessages');
  // Dispatch all queued messages
  while GetMessage(message) do
  begin
    DispatchMessage(message);
    message.Free;
  end;
end;

function TApplication.PollInput(out AMessage: TMessage): Boolean;
var
  key: Integer;
  event: MEVENT;
  return: Integer;
  form: TForm;
begin
  Debug('TApplication.PollInput');
  key := getch;

  case key of
    ERR: Result:= False;
    KEY_MOUSE:
    begin
      //Debug('  KEY_MOUSE'); Result:= False;
      return:= getmouse(@event);
      if return = OK then
      begin
        form:= WindowAt(event.x, event.y);
        PostMessage(TMessage.CreateBlur(FFocusedForm));
        if Assigned(form) and (FFocusedForm <> form) then
        begin
          FFocusedForm:= form;
        end
        else
          FFocusedForm:= nil;

        AMessage:= TMessage.CreateMouse(
          nil,
          form,
          event.bstate,
          event.y shl 16 or event.x
        );
        Result:= True;
      end
      else
      begin
        Result:= False;
      end;
    end;
    otherwise
    begin
    Debug('  Otherwise(key)');
      { #note -ogcarreno : Until the other events are complete, default to mtKey }
      AMessage:= TMessage.CreateKey(
        nil,
        FFocusedForm,
        key
      );
      Result:= True;
    end;
  end;

  napms(10);
end;

procedure TApplication.PostMessage(const AMessage: TMessage);
begin
  Debug(Format('TApplication.PostMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
  FMessages.Add(AMessage);
end;

function TApplication.GetMessage(out AMessage: TMessage): Boolean;
begin
  Debug('TApplication.GetMessage');
  try
    //Debug('  Testing count > 0');
    Result:= FMessages.Count > 0;
    //Debug(Format('  Result: %b', [Result]));
    if Result then
    begin
      //Debug(Format('  FMessages.Count: %d', [FMessages.Count]));
      AMessage:= (FMessages[0] as TMessage).Copy;
      Debug(Format('  AMessage: %s',
        [TMessage.MessageTypeToStr(Amessage)]));
      FMessages.Delete(0);
      //Debug(Format('  FMessages.Count: %d', [FMessages.Count]));
    end;
  except
    on E:Exception do
      Debug('  ERROR: ' + E.Message);
  end;
end;

procedure TApplication.DispatchMessage(const AMessage: TMessage);
//var
//  message: TMessage;
begin
  Debug(Format('TApplication.DispatchMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
  try
    if Assigned(AMessage.Target) {and (AMessage.Target is TForm)} then
    begin
      if AMessage.Target is TForm then
      begin
        Debug('  Target is TForm');
        TForm(AMessage.Target).HandleMessage(AMessage);
      end;
      if AMessage.Target is TBaseComponent then
      begin
        Debug('  Target is TBaseComponent');
        TBaseComponent(AMessage.Target).HandleMessage(AMessage);
      end;
      case AMessage.MessageType of
        mtMouse:
        begin
          FFocusedForm:= TForm(AMessage.Target);
        end;
        otherwise
          // Silence the warning
      end;
    end
    else
    begin
      Debug('  Target is NULL');
    end;
  except
    on E:Exception do
      Debug('  ERROR: ' + E.Message);
  end;
end;

constructor TApplication.Create;
begin
  inherited Create;
  // Nothing to do yest
end;

destructor TApplication.Destroy;
begin
  if FInitialized then
    endwin;
  inherited Destroy;
end;

procedure TApplication.Terminate;
begin
  FQuit:= True;
end;

initialization

  Application:= TApplication.Create;

finalization

  Application.Free;

end.


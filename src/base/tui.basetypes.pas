unit TUI.BaseTypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, Contnrs
, ncurses
, TUI.Ncurses.Window
, TUI.Core.Message
;

type
{ Forward }
  TBaseApplication = class;
  TBaseForm = class;
  TBaseComponent = class;

{ TBaseApplication }
  TBaseApplication = class(TObject)
  private
  protected
    FTitle: String;
    FCursorVisible: Boolean;
    FMessages: TFPObjectList;
    FForms: TFPObjectList;
    { #todo -ogcarreno : This needs to go away, eventually }
    {$IFDEF DEBUG}
    FDebug: TStringList;
    {$ENDIF}

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Initialize; virtual; abstract;
    procedure Run; virtual; abstract;
    procedure Terminate; virtual; abstract;

    procedure PostMessage(const AMessage: TMessage); virtual; abstract;


    procedure Debug(const AMessage: String);
  published
    property Title: String
      read FTitle
      write FTitle;
  end;


{ TBaseForm }
  TBaseForm = class(TObject)
  private
  protected
    FParent: TBaseApplication;
    FWindow: TNCWindow;
    FComponents: TFPObjectList;
    FInvalidated: Boolean;
    FIsFocused: Boolean;
    procedure CreateWindow(AX, AY, AWidth, AHeight: Integer);

  public
    constructor Create(AOwner: TBaseApplication);
    destructor Destroy; override;

    procedure Initialize; virtual; abstract;

    procedure Focus; virtual; abstract;
    procedure Blur; virtual; abstract;

    function AddComponent(AComponent: TBaseComponent): Integer;
    procedure Invalidate;
  published
  end;

{ TBaseComponent }
  TBaseComponent = class(TObject)
  private
  protected
    FParent: TBaseForm;
    FWindow: TNCWindow;
  public
    constructor Create(AOwner: TBaseForm);
    destructor Destroy; override;

    procedure Initialize; virtual; abstract;
  published
  end;

implementation

{ TBaseApplication }

constructor TBaseApplication.Create;
begin
  FMessages:= TFPObjectList.Create(True);
  FForms:= TFPObjectList.Create(True);
  FCursorVisible:= False;
{$IFDEF DEBUG}
  FDebug:= TStringList.CReate;
{$ENDIF}
end;

destructor TBaseApplication.Destroy;
begin

{$IFDEF DEBUG}
  WriteLn('---- Debug -----');
  WriteLn(FDebug.Text);
  FDebug.Free;
{$ENDIF}

  FMessages.Free;
  FForms.Free;
  inherited Destroy;
end;

procedure TBaseApplication.Debug(const AMessage: String);
begin
{$IFDEF DEBUG}
  FDebug.Append(AMessage);
//  waddstr(stdscr, PChar(AMessage + LineEnding));
{$ENDIF}
end;

{ TBaseForm }

procedure TBaseForm.CreateWindow(AX, AY, AWidth, AHeight: Integer);
begin
  FWindow:= TNCWindow.Create(AX, AY, AWidth, AHeight);
end;


constructor TBaseForm.Create(AOwner: TBaseApplication);
begin
  FParent:= AOwner;
  FWindow:= nil;
  FComponents:= TFPObjectList.Create(True);
  FInvalidated:= False;
  FIsFocused:= False;
end;

destructor TBaseForm.Destroy;
begin
  if Assigned(FWindow) then
    FWindow.Free;
  FComponents.Free;
  inherited Destroy;
end;

function TBaseForm.AddComponent(AComponent: TBaseComponent): Integer;
begin
  Result:= FComponents.Add(AComponent);
end;

procedure TBaseForm.Invalidate;
begin
  FInvalidated:= True;
end;

{ TBaseComponent }

constructor TBaseComponent.Create(AOwner: TBaseForm);
begin
  FParent:= AOwner;
  FWindow:= nil;
end;

destructor TBaseComponent.Destroy;
begin
  if Assigned(FWindow) then
    FWindow.Free;
  inherited Destroy;
end;

end.



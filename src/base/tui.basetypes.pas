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
    procedure SetName(AValue: String);
  protected
    FParent: TBaseApplication;
    FWindow: TNCWindow;
    FComponents: TFPObjectList;
    FInvalidated: Boolean;
    FIsFocused: Boolean;
    FName: String;
    FCaption: String;
    procedure CreateWindow(AX, AY, AWidth, AHeight: Integer);
  public
    constructor Create(AOwner: TBaseApplication);
    destructor Destroy; override;

    procedure Initialize; virtual; abstract;

    procedure Focus; virtual; abstract;
    procedure Blur; virtual; abstract;

    function AddComponent(AComponent: TBaseComponent): Integer;
    procedure Invalidate;

    procedure Debug(const AMessage: String);

    property Window: TNCWindow
      read FWindow;
  published
    property Name: String
      read FName
      write SetName;
  end;

{ TBaseComponent }
  TBaseComponent = class(TObject)
  private
  protected
    FParent: TBaseForm;
    //FWindow: TNCWindow;
    FInvalidated: Boolean;
    FIsFocused: Boolean;
    FX,
    FY,
    FWidth,
    FHeight: Integer;
    FName: String;
  public
    constructor Create(AOwner: TBaseForm);
    destructor Destroy; override;

    procedure Initialize; virtual; abstract;
    procedure Paint; virtual; abstract;
    procedure HandleMessage(AMessage: TMessage); virtual; abstract;

    procedure Focus; virtual; abstract;
    procedure Blur; virtual; abstract;
    procedure Invalidate;
  published
    property X: Integer
      read FX
      write FX;
    property Y: Integer
      read FY
      write FY;
    property Width: Integer
      read FWidth
      write FWidth;
    property Height: Integer
      read FHeight
      write FHeight;
    property Name: String
      read FName
      write FName;
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

procedure TBaseForm.SetName(AValue: String);
begin
  if FName=AValue then Exit;
  FName:=AValue;
  Invalidate;
end;


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
  AComponent.Invalidate;
  AComponent.Initialize;
end;

procedure TBaseForm.Invalidate;
begin
  FInvalidated:= True;
end;

procedure TBaseForm.Debug(const AMessage: String);
begin
  FParent.Debug(AMessage);
end;

{ TBaseComponent }

constructor TBaseComponent.Create(AOwner: TBaseForm);
begin
  FParent:= AOwner;
  //FWindow:= nil;
  FInvalidated:= False;
  FIsFocused:= False;
end;

destructor TBaseComponent.Destroy;
begin
  //if Assigned(FWindow) then
  //  FWindow.Free;
  inherited Destroy;
end;

procedure TBaseComponent.Invalidate;
begin
  FInvalidated:= True;
end;

end.



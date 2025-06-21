unit TUI.Form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, Contnrs
, ncurses
, TUI.BaseComponent
, TUI.Message
;

type
{ TForm }
  TForm = class(TBaseComponent)
  private
  protected
    FCaption: String;

    FComponents: TFPObjectList;
    FFocusedComponent: TBaseComponent;

    procedure Paint; override;
  public
    constructor Create(const AName: String;AHasColor: Boolean);
    destructor Destroy; override;

    procedure HandleMessage(AMessage: TMessage); override;
    function AddComponent(AComponent: TBaseComponent): Integer;
    function ComponentAt(AX, AY: LongInt): TBaseComponent;

  published
    property Caption: String
      read FCaption
      write FCaption;
  end;

  TFormClass= class of TForm;

implementation

uses
  TUI.Application
;

const
  cCaptionFormat = '[%s]';

//const
//  DL_HLINE: chtype = 205; // ═
//  DL_VLINE: chtype = 186; // ║
//  DL_TL: chtype    = 201; // ╔
//  DL_TR: chtype    = 187; // ╗
//  DL_BL: chtype    = 200; // ╚
//  DL_BR: chtype    = 188; // ╝

  //DL_HLINE = '═';
  //DL_VLINE = '║';
  //DL_TL = '╔';
  //DL_TR = '╗';
  //DL_BL = '╚';
  //DL_BR = '╝';

{ TForm }

constructor TForm.Create(const AName: String; AHasColor: Boolean);
begin
  inherited Create(AName, FX, FY, FWidth, FHeight);
  FName:= AName;
  FHasColor:= AHasColor;
  FComponents:= TFPObjectList.Create(True);
  FFocusedComponent:= nil;
end;

destructor TForm.Destroy;
begin
  FComponents.Free;
  inherited Destroy;
end;

procedure TForm.HandleMessage(AMessage: TMessage);
begin
  inherited HandleMessage(AMessage);
  case AMessage.MessageType of
    mtFocus:
    begin
      FIsFocused:= True;
      Invalidate;
    end;
    mtBlur:
    begin
      FIsFocused:= False;
      Invalidate;
    end;
  otherwise
    // Silence the warning
  end;
  Application.Debug(Format('Form IsFocused: %b', [FIsFocused]));
end;

function TForm.AddComponent(AComponent: TBaseComponent): Integer;
begin
  Result:= FComponents.Add(AComponent);
  FFocusedComponent:= AComponent;
end;

function TForm.ComponentAt(AX, AY: LongInt): TBaseComponent;
var
  index: Integer;
  component: TBaseComponent;
begin
  Result:= nil;
  for index:= Pred(FComponents.Count) downto 0 do
  begin
    component:= (FComponents[index] as TBaseComponent);
    if (component.X <= AX) and ((component.X + component.Width) >= AX) and
       (component.Y <= AY) and ((component.Y + component.Height) >= AY) then
    begin
      Result:= component;
      break;
    end;
  end;
end;

procedure TForm.Paint;
var
  index: Integer;
  refresh: TMessage;
begin
  if not FInvalidated then
    exit;
  Application.Debug('TForm Paint');
  { #todo -ogcarreno : Implement form painting and maybe children
    ( Loop through Invalidate? ) }

  werase(FWindow);
  Border;

  // Caption
  if FBorderStyle <> bsNone then
  begin
    if  (Length(FName) > 0) then
      WriteTextCentered(0, Format(cCaptionFormat, [FName]));
    if  (Length(FCaption) > 0) then
      WriteTextCentered(0, Format(cCaptionFormat, [FCaption]));
  end;
  wrefresh(FWindow);

  for index:= 0 to Pred(FComponents.Count) do
  begin
    refresh:= TMessage.Create(
      mtRefresh,
      Self,
      FComponents[index],
      0,
      0,
      nil
    );
    Application.PostMessage(refresh);
  end;

  inherited Paint;
end;

end.


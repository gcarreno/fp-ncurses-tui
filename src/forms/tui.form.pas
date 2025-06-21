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
    FHasColor: Boolean;

    FComponents: TFPObjectList;
    FFocusedComponent: TBaseComponent;

    procedure Paint; override;
  public
    constructor Create(const AName: String;AHasColor: Boolean);
    destructor Destroy; override;

    procedure HandleMessage(AMessage: TMessage); override;
    function AddComponent(AComponent: TBaseComponent): Integer;

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
  Application.Debug(Format('IsFocused: %b', [FIsFocused]));
end;

function TForm.AddComponent(AComponent: TBaseComponent): Integer;
begin
  Result:= FComponents.Add(AComponent);
  FFocusedComponent:= AComponent;
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
  //if has_colors then
  //  wbkgd(FWindow, COLOR_PAIR(1));

  Border;

  if FIsFocused then
    mvwaddstr(FWindow, FHeight-1, FWidth-11, PChar('[Focus: Y]'))
  else
    mvwaddstr(FWindow, FHeight-1, FWidth-11, PChar('[Focus: N]'));
  // Caption
  if FBorderStyle <> bsNone then
  begin
    if  (Length(FName) > 0) then
      WriteLineCentered(0, Format(cCaptionFormat, [FName]));
    if  (Length(FCaption) > 0) then
      WriteLineCentered(0, Format(cCaptionFormat, [FCaption]));
  end;

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
  Application.ProcessMessages;

  inherited Paint;
  wrefresh(FWindow);
end;

end.


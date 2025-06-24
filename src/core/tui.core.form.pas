unit TUI.Core.Form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, TUI.BaseTypes
, TUI.Core.Message
;

type
{ TBorderStyle }
  TBorderStyle = (bsNone, bsSingleLine, bsDoubleLine);

  { TForm }
  TForm = class(TBaseForm)
  private
    procedure SetBorderStyle(AValue: TBorderStyle);
    procedure SetCaption(AValue: String);

    function ComponentAt(AX, AY: Integer): TBaseComponent;
  protected
    FX,
    FY,
    FWidth,
    FHeight: Integer;
    FBorderStyle: TBorderStyle;

    procedure Border;
  public
    procedure HandleMessage(AMessage: TMessage); virtual;

    procedure Paint; virtual;

    procedure Focus; override;
    procedure Blur; override;

  published
    property X: Integer
      read FX;
    property Y: Integer
      read FY;
    property WIdth: Integer
      read FWidth;
    property Height: Integer
      read FHeight;
    property BorderStyle: TBorderStyle
      read FBorderStyle
      write SetBorderStyle;
    property Caption: String
      read FCaption
      write SetCaption;
  end;

implementation

uses
  ncurses
;

const
  cCaptionFormat = '[%s]';

{ TForm }

procedure TForm.SetBorderStyle(AValue: TBorderStyle);
begin
  if FBorderStyle=AValue then Exit;
  FBorderStyle:=AValue;
  Border;
end;

procedure TForm.SetCaption(AValue: String);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
  Invalidate;
end;

function TForm.ComponentAt(AX, AY: Integer): TBaseComponent;
var
  index: Integer;
  component: TBaseComponent;
begin
  //Debug(Format('TForm.ComponentAt(%d, %d)', [AX, AY]));
  Result:= nil;
  //Debug(Format('  FForms.Count: %d', [FForms.Count]));
  for index:= Pred(FComponents.Count) downto 0 do
  begin
    //Debug(Format('  Index: %d', [index]));
    component:= (FComponents[index] as TBaseComponent);
    if (component.X <= AX) and ((component.X + component.Width) >= AX) and
       (component.Y <= AY) and ((component.Y + component.Height) >= AY) then
    begin
      //Debug('  Got Component');
      Result:= component;
      break;
    end;
  end;
end;

procedure TForm.Border;
begin
  case FBorderStyle of
    bsNone:
    begin
      // Do nothing and silence the warning
    end;
    bsSingleLine:
    begin
      FWindow.Border(ACS_VLINE, ACS_HLINE);
      //FPWindow.Box(0, 0);
    end;
    bsDoubleLine: begin
      { #todo -ogcarreno : This needs a ton more investigation }
      //wborder(FWindow,
      //  DL_HLINE, DL_HLINE,
      //  DL_VLINE, DL_VLINE,
      //  DL_TL, DL_TR,
      //  DL_BL, DL_BR);
    end;
  end;
end;

procedure TForm.HandleMessage(AMessage: TMessage);
var
  index: Integer;
  component: TBaseComponent;
  mouse_x, mouse_y: Integer;
begin
  FParent.Debug(Format('TForm.HandleMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
  case AMessage.MessageType of
    mtFocus:
    begin
      Focus;
    end;
    mtBlur:
    begin
      Blur;
    end;
    mtMouse:
    begin
      if not FIsFocused then
      begin
        Focus;
      end;
      { #todo -ogcarreno : Cycle through the components to determine if it's been clicked }
      for index:= 0 to Pred(FComponents.Count) do
      begin
        mouse_x:= AMessage.LParam and $00FF - FWindow.X;
        mouse_y:= AMessage.LParam shr 16 - FWindow.Y;
        component:= ComponentAt(mouse_x, mouse_y);
        if Assigned(component) then
          (FComponents[index] as TBaseComponent).HandleMessage(Amessage);
      end;
    end;
    mtRefresh: Paint;
  otherwise
    // Silence the warning
  end;
end;

procedure TForm.Paint;
var
  index: Integer;
  refresh: TMessage;
begin
  FParent.Debug('TForm.Paint');
  if not FInvalidated then
    exit;

  FParent.Debug('  Erasing');
  FWindow.Erase;
  FParent.Debug('  Border');
  Border;

  FParent.Debug('  Caption');
  // Caption
  if FBorderStyle <> bsNone then
  begin
    if  (Length(FName) > 0) then
      FWindow.WriteCenteredAt(0, Format(cCaptionFormat, [FName]));
    if  (Length(FCaption) > 0) then
      FWindow.WriteCenteredAt(0, Format(cCaptionFormat, [FCaption]));
  end;

  FParent.Debug('  Components');
  for index:= 0 to Pred(FComponents.Count) do
  begin
    FParent.Debug(Format('  Component(%d): %s', [index, TBaseComponent(FComponents[index]).Name]));
    (FComponents[index] as TBaseComponent).Paint;
  end;
  FWindow.Refresh;
end;

procedure TForm.Focus;
begin
  if not FIsFocused then
  begin
    FIsFocused:= True;
    Invalidate;
  end;
end;

procedure TForm.Blur;
begin
  if FIsFocused then
  begin
    FIsFocused:= False;
    Invalidate;
  end;
end;

end.


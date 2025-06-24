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
    procedure SetName(AValue: String);
  protected
    FX,
    FY,
    FWidth,
    FHeight: Integer;
    FBorderStyle: TBorderStyle;
    FName: String;
    FCaption: String;

    procedure Border;
  public
    procedure HandleMessage(AMessage: TMessage); virtual;

    procedure Paint; virtual;

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
    property Name: String
      read FName
      write SetName;
    property Caption: String
      read FCaption
      write SetCaption;
  published
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

procedure TForm.SetName(AValue: String);
begin
  if FName=AValue then Exit;
  FName:=AValue;
  Invalidate;
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
begin
  FParent.Debug(Format('TForm.HandleMessage(%s)',
    [TMessage.MessageTypeToStr(AMessage)]));
  case AMessage.MessageType of
    mtFocus:
    begin
      if not FIsFocused then
      begin
        FIsFocused:= True;
        Invalidate;
      end;
    end;
    mtBlur:
    begin
      if FIsFocused then
      begin
        FIsFocused:= False;
        Invalidate;
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
  //FParent.Debug('TForm.Paint');
  if not FInvalidated then
    exit;

  //FParent.Debug('  Erasing');
  FWindow.Erase;
  //FParent.Debug('  Border');
  Border;

  //FParent.Debug('  Caption');
  // Caption
  if FBorderStyle <> bsNone then
  begin
    if  (Length(FName) > 0) then
      FWindow.WriteCenteredAt(0, Format(cCaptionFormat, [FName]));
    if  (Length(FCaption) > 0) then
      FWindow.WriteCenteredAt(0, Format(cCaptionFormat, [FCaption]));
  end;
  FWindow.Refresh;

  //FParent.Debug('  Components');
  for index:= 0 to Pred(FComponents.Count) do
  begin
    refresh:= TMessage.CreateRefresh(Self, FComponents[index]);
    FParent.PostMessage(refresh);
  end;
end;

end.


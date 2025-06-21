unit TUI.Form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, ncurses
, TUI.BaseComponent
, TUI.Message
;

type
{ TBorderStyle }
  TBorderStyle = (bsNone, bsSingleLine, bsDoubleLine);

{ TForm }
  TForm = class(TBaseComponent)
  private
  protected
    FCaption: String;
    FHasColor: Boolean;
    FBorderStyle: TBorderStyle;
  public
    constructor Create(AHasColor: Boolean);
    destructor Destroy; override;

    procedure Paint; override;
    procedure WriteText(const Text: String);
    procedure WriteTextAt(AX, AY: Integer; const Text: String);
    procedure MoveTo(AX, AY: Integer);
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

constructor TForm.Create(AHasColor: Boolean);
begin
  inherited Create(FX, FY, FWidth, FHeight);
  FHasColor:= AHasColor;
  FInvalidated:= True;
  { #todo -ogcarreno : Implement component list creation }
end;

destructor TForm.Destroy;
begin
  { #todo -ogcarreno : Implement component list destruction }
  inherited Destroy;
end;

procedure TForm.Paint;
begin
  { #todo -ogcarreno : Implement form painting and maybe children
    ( Loop through Invalidate? ) }
  //if has_colors then
  //  wbkgd(FWindow, COLOR_PAIR(1));

  case FBorderStyle of
    bsNone:
    begin
      // Do nothing and silence the warning
    end;
    bsSingleLine:
    begin
      //box(FWindow, ACS_VLINE, ACS_HLINE);
      box(FWindow, 0, 0);
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

  if FInvalidated then
    FInvalidated:= False;
  wrefresh(FWindow);
end;

procedure TForm.WriteText(const Text: String);
begin
  waddstr(FWindow, PChar(Text));
end;

procedure TForm.WriteTextAt(AX, AY: Integer; const Text: String);
begin
  mvwaddstr(FWindow, AY, AX, PChar(Text));
end;

procedure TForm.MoveTo(AX, AY: Integer);
begin
  wmove(FWindow, AY, AX);
end;

end.


unit TUI.BaseTypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
, Contnrs
, ncurses
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
    FForms: TFPObjectList;
  public
    constructor Create;
    destructor Destroy; Override;

    function AddForm(AForm: TBaseForm): Integer;

    procedure Initialize; virtual; abstract;
    procedure Run; virtual; abstract;
  published
  end;


{ TBaseForm }
  TBaseForm = class(TObject)
  private
  protected
    FParent: TBaseApplication;
    FWindow: PWINDOW;
    FComponents: TFPObjectList;
  public
    constructor Create(AOwner: TBaseApplication);
    destructor Destroy; override;

    function AddComponent(AComponent: TBaseComponent): Integer;

    procedure Initialize; virtual; abstract;
  published
  end;

{ TBaseComponent }
  TBaseComponent = class(TObject)
  private
  protected
    FParent: TBaseForm;
    FWindow: PWINDOW;
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
  FForms:= TFPObjectList.Create(True);
end;

destructor TBaseApplication.Destroy;
begin
  FForms.Free;
  inherited Destroy;
end;

function TBaseApplication.AddForm(AForm: TBaseForm): Integer;
begin
  Result:= FForms.Add(AForm);
end;

{ TBaseForm }

constructor TBaseForm.Create(AOwner: TBaseApplication);
begin
  FParent:= AOwner;
  FComponents:= TFPObjectList.Create(True);
end;

destructor TBaseForm.Destroy;
begin
  FComponents.Free;
  inherited Destroy;
end;

function TBaseForm.AddComponent(AComponent: TBaseComponent): Integer;
begin
  Result:= FComponents.Add(AComponent);
end;

{ TBaseComponent }

constructor TBaseComponent.Create(AOwner: TBaseForm);
begin
  FParent:= AOwner;
end;

destructor TBaseComponent.Destroy;
begin
  inherited Destroy;
end;

end.



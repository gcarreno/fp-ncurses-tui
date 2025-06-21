unit TUI.Message;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
, SysUtils
;

type
{ TMessageType }
  TMessageType = (
    mtNone,
    mtKey,     // Key pressed
    mtMouse,   // Mouse event
    mtResize,  // Resize event
    mtCustom,  // Just in case
    mtRefresh, // Triggers a repaint
    mtClick,   // Click event
    mtFocus,   // For future form focus
    mtBlur,    // For future form focus
    mtApplicationQuit  // Self explanatory
  );
{ TMessage }
  TMessage = class(TObject)
  private
    FMessageType: TMessageType;
    FSender: TObject;
    FTarget: TObject;
    FWParam: Int64;
    FLParam: Int64;
    FData: Pointer;
  protected
  public
    constructor Create(
      AMessageType: TMessageType;
      ASender: TObject;
      ATarget: TObject;
      AWParam: Int64;
      ALParam: Int64;
      AData: Pointer);
    destructor Destroy; override;

    function Copy: TMessage;

    property MessageType: TMessageType
      read FMessageType;
    property Sender: TObject
      read FSender;
    property Target: TObject
      read FTarget;
    property WParam: Int64
      read FWParam;
    property LParam: Int64
      read FLParam;
    property Data: Pointer
      read FData;
  published
  end;

implementation

{ TMessage }

constructor TMessage.Create(
  AMessageType: TMessageType;
  ASender: TObject;
  ATarget: TObject;
  AWParam: Int64;
  ALParam: Int64;
  AData: Pointer);
begin
  FMessageType:= AMessageType;
  FSender:= ASender;
  FTarget:= ATarget;
  FWParam:= AWParam;
  FLParam:= ALParam;
  FData:= AData;
end;

destructor TMessage.Destroy;
begin
  inherited Destroy;
end;

function TMessage.Copy: TMessage;
begin
  Result:= TMessage.Create(
    FMessageType,
    FSender,
    FTarget,
    FWParam,
    FLParam,
    FData
  );
end;

end.


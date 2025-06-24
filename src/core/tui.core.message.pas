unit TUI.Core.Message;

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
    // mtMouseClick, mtMouseDown, mtMouseUp, mtMouseMove, // For the future
    mtResize,  // Resize event
    mtRefresh, // Triggers a repaint
    mtClick,   // Click event
    mtFocus,   // For future form focus
    mtBlur,    // For future form focus
    mtCustom,  // Just in case
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

    class function MessageTypeToStr(AMessage: TMessage): String;
    class function CreateKey(ASender, ATarget: TObject; AKey: Integer): TMessage;
    class function CreateMouse(ASender, ATarget: TObject; AWParam, ALParam: Int64): TMessage;
    class function CreateRefresh(ASender, ATarget: TObject): TMessage;
    class function CreateFocus(ATarget: TObject): TMessage;
    class function CreateBlur(ATarget: TObject): TMessage;

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

class function TMessage.MessageTypeToStr(AMessage: TMessage): String;
begin
  case AMessage.MessageType of
  mtNone:    Result:= 'mtNone';
  mtKey:     Result:= 'mtKey';
  mtMouse:   Result:= 'mtMouse';
  mtResize:  Result:= 'mtResize';
  mtRefresh: Result:= 'mtRefresh';
  mtClick:   Result:= 'mtClick';
  mtFocus:   Result:= 'mtFocus';
  mtBlur:    Result:= 'mtBlur';
  mtCustom:  Result:= 'mtCustom';
  mtApplicationQuit: Result:= 'mtNone';
  end;
end;

class function TMessage.CreateKey(ASender, ATarget: TObject;
  AKey: Integer): TMessage;
begin
  Result:= TMessage.Create(
    mtKey,
    ASender,
    ATarget,
    AKey,
    0,
    nil
  );
end;

class function TMessage.CreateMouse(ASender, ATarget: TObject; AWParam,
  ALParam: Int64): TMessage;
begin
  Result:= TMessage.Create(
    mtMouse,
    ASender,
    ATarget,
    AWParam,
    ALParam,
    nil
  );
end;

class function TMessage.CreateRefresh(ASender, ATarget: TObject): TMessage;
begin
  Result:= TMessage.Create(
    mtRefresh,
    ASender,
    ATarget,
    0,
    0,
    nil
  );
end;

class function TMessage.CreateFocus(ATarget: TObject): TMessage;
begin
  Result:= TMessage.Create(
    mtFocus,
    nil,
    ATarget,
    0,
    0,
    nil
  );
end;

class function TMessage.CreateBlur(ATarget: TObject): TMessage;
begin
  Result:= TMessage.Create(
    mtBlur,
    nil,
    ATarget,
    0,
    0,
    nil
  );
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


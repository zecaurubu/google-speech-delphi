{*******************************************************}
{                                                       }
{       Google Speech Component(0.1)                    }
{                                                       }
{       ∞Ê»®À˘”– (C) 2012 pathletboy                    }
{                                                       }
{       Contact pathletboy(at)gmail.com                 }
{*******************************************************}
unit uGoogleSpeech;

interface
uses
  SysUtils, Classes, IdHTTP, uLkJSON;

const
  VERSION = '0.1';
  AUTHOR = 'pathletboy';
  //post url,need append the language code like "zh-CN"
  POST_URL = 'http://www.google.com.hk/speech-api/v1/recognize?xjerr=1&client=chromium&lang=';
  DEFAULT_LANG = 'zh-CN';
type
  TGoogleSpeech = class(TComponent)
  private
    FHttp: TIdHTTP;
    FLang: string;
    FURL: string;
    FRate: Integer;
    procedure SetRate(const Value: Integer);
    procedure SetLang(const Value: string);
    function GetAuthor: string;
    function GetVersion: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //convert flac to string
    function Convert(const stream: TStream): string;
  published
    property Lang: string read FLang write SetLang;
    property Rate: Integer read FRate write SetRate;
    property Version: string read GetVersion;
    property Author: string read GetAuthor;
  end;
procedure Register;
implementation

procedure Register;
begin
  RegisterComponents('Goolge Speech', [TGoogleSpeech]);
end;

{ TGoogleSpeech }

function TGoogleSpeech.Convert(const stream: TStream): string;
var
  ret: string;
  js: TlkJSONobject;
begin
  try
    ret := FHttp.Post(FURL, stream);
    js := TlkJSON.ParseText(ret) as TlkJSONobject;
    try
      Result := js.Field['hypotheses'].Child[0].Field['utterance'].Value;
    finally
      js.Free;
    end;
  except
    Result := '';
  end;
end;

constructor TGoogleSpeech.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttp := TIdHTTP.Create(nil);
  FLang := DEFAULT_LANG;
  FRate := 16000;
  FHttp.Request.ContentType := 'audio/x-flac; rate=16000';
  FURL := POST_URL + DEFAULT_LANG;
end;

destructor TGoogleSpeech.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TGoogleSpeech.GetAuthor: string;
begin
  Result := AUTHOR;
end;

function TGoogleSpeech.GetVersion: string;
begin
  Result := VERSION;
end;

procedure TGoogleSpeech.SetLang(const Value: string);
begin
  FURL := POST_URL + Value;
  FLang := Value;
end;

procedure TGoogleSpeech.SetRate(const Value: Integer);
begin
  FHttp.Request.ContentType := 'audio/x-flac; rate=' + IntToStr(Value);
  FRate := Value;
end;

end.


unit StrUtil;

interface

uses
  SysUtils;

type
  TStringArray = array of string;

function Occurs(const str: string; c: char): integer; overload;
function Occurs(const str: string; const substr: string): integer; overload;
function AnsiOccurs(const str: string; const substr: string): integer;

function Split(const str: string; const separator: string = ','): TStringArray;
function AnsiSplit(const str: string; const separator: string = ','): TStringArray;

implementation

function Occurs(const str: string; c: char): integer;
var
  p: PChar;
begin
  Result := 0;
  p := PChar(Pointer(str));
  while p <> nil do
  begin
    p := StrScan(p, c);
    if p <> nil then
    begin
      inc(Result);
      inc(p);
    end;
  end;
end;

function Occurs(const str: string; const substr: string): integer;
var
  p, q: PChar;
  n: integer;
begin
  Result := 0;
  n := Length(substr);
  if n = 0 then exit;
  q := PChar(Pointer(substr));
  p := PChar(Pointer(str));
  while p <> nil do
  begin
    p := StrPos(p, q);
    if p <> nil then
    begin
      inc(Result);
      inc(p, n);
    end;
  end;
end;

function AnsiOccurs(const str: string; const substr: string): integer;
var
  p, q: PChar;
  n: integer;
begin
  Result := 0;
  n := Length(substr);
  if n = 0 then exit;
  q := PChar(Pointer(substr));
  p := PChar(Pointer(str));
  while p <> nil do
  begin
    p := AnsiStrPos(p, q);
    if p <> nil then
    begin
      inc(Result);
      inc(p, n);
    end;
  end;
end;

function Split(const str: string; const separator: string): TStringArray;
var
  i, n: integer;
  p, q, s: PChar;
begin
  SetLength(Result, Occurs(str, separator)+1);
  p := PChar(str);
  s := PChar(separator);
  n := Length(separator);
  i := 0;
  repeat
    q := StrPos(p, s);
    if q = nil then q := StrScan(p, #0);
    SetString(Result[i], p, q - p);
    p := q + n;
    inc(i);
  until q^ = #0;
end;

function AnsiSplit(const str: string; const separator: string): TStringArray;
var
  i, n: integer;
  p, q, s: PChar;
begin
  SetLength(Result, AnsiOccurs(str, separator)+1);
  p := PChar(str);
  s := PChar(separator);
  n := Length(separator);
  i := 0;
  repeat
    q := AnsiStrPos(p, s);
    if q = nil then q := AnsiStrScan(p, #0);
    SetString(Result[i], p, q - p);
    p := q + n;
    inc(i);
  until q^ = #0;
end;

end.

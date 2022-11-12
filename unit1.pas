unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, sevenzip7;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var i: Integer;
begin
  with CreateOutArchive(CLSID_CFormat7z) do
 begin
   AddFile('7z.dll', 'Name In Archive.dll');
   SaveToFile('archive.7z');
 end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var i: Integer;
    Guid: TGuid;
    Filename: String;
begin
  if not OpenDialog1.Execute then Exit;

  Filename := OpenDialog1.Filename;

  Guid := DetectFormat(Filename);
  if IsEqualGUID(Guid, CLSID_CFormat_Unsupported) then begin
    ShowMessage('Unsupported');
    Exit;
  end;

  with CreateInArchive(Guid) do begin
   OpenFile(Filename);
   for i := 0 to NumberOfItems - 1 do
    if not ItemIsFolder[i] then
      Memo1.Lines.Add(
        ItemPath[i] + ' == ' + GetItemCRC(i) +
        ItemComment[i] +IntToStr(GetItemPackSize(i)) + ' ' +
        FormatDateTime('YYYY-MM-DD', GetItemModDate(i))
        );
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var Guid: TGuid;
    i: Integer;
    str: TStringStream;
    S: String;
begin
  if not OpenDialog1.Execute then Exit;


  Guid := DetectFormat(OpenDialog1.Filename);

  if IsEqualGUID(Guid, CLSID_CFormat_Unsupported) then begin
    ShowMessage('Unsupported');
    Exit;
  end;

  S := '';
  Str := TStringStream.Create(S);

  with CreateInArchive(Guid) do
  begin
   OpenFile(OpenDialog1.Filename);
   for i := 0 to NumberOfItems - 1 do
     if not ItemIsFolder[i] then begin
       ExtractItem(i, str, false);
       break;
     end;
  end;

  S := Str.DataString;

  str.free;

  Memo1.Lines.Text := S;
end;


end.


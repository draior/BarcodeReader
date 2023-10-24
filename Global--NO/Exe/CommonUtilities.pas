unit CommonUtilities;

interface

uses Windows, SysUtils, Registry, Classes, db, Dialogs, ComObj, Forms, Controls, Graphics;

const
  xlWBATWorksheet       = -4167;

resourcestring
  err_CantConnectToXLS  = 'Не може да се установи връзка с MS Excel!';
  err_FileAccessDenied  = 'Непозволен достъп до файл %s!';
  err_FileSaveError     = 'Грешка при запис на файл  %s!';
  msg_FileName          = 'Въведете име на файл';
  msg_DataSaveSuccess   = 'Данните са записани успешно !';

//Common functions and procedures
procedure SetOptionState(const Path, Option: String; Value: Variant);
function GetOptionState(const Path, Option: String; const VT: Integer): Variant;
function RemoveLastFolder(FullPath : string) : string;
function CompressFileName(FileName : string) : string;
function ProcessString(Source : string; SearchFor, ReplaceWith : char): string;
function FormatBGDate(const D : string) : string;
procedure GetFileNames(RootPath, FileExt : string; InsertInto : TStrings);
function StripFromFilePath(FileName, PathToStrip : string) : string;
function Convert6toDate(char6Date : string) : string;
function Convert4toTime(char4Time : string) : string;
function ClearWhereStatement(FullSQLStatement : string) : string;

function DeleteFromStr(Str : string; FromPos, Length : integer) : string;
function RepeatPos(SubStr, Str : string; Times : byte) : integer;
function ChangeSeparator(Str, CurrentSeparator, NewSeparator : string) : string;
function GetFieldsCount(Line, Separator : string) : word;
function GetField(Line, Separator : string; Index : word) : string;
function GetIndexOf(Line, Separator, FieldValue : string; ExactMatch: Boolean = True) : word;
function GetFieldOrderIndex(Line, Separator, FieldValue : string) : word;


function ExtractRealCondition(lcSQLString: string): string;
function GetValuesOf(lcStr: string): string;
function GetWhereClause(lcStr: string): string;

function ExportToXLS(CDS: TDataSet; ListName: string; ExportLine: boolean = true; ShowExcel: boolean = True): boolean;
procedure ExportLineToXLS(XLSheet: variant; CDS: TDataSet; lcRow: LongInt);
function GetDayOfWeekAsString(ADate: TDateTime): String;

implementation

function GetOptionState(const Path, Option: String; const VT: Integer): Variant;
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey(Path, False)
    then begin
      case VT of
        varBoolean: Result := ReadString(Option) = '1';
        varInteger: try
                      Result := ReadInteger(Option);
                    except
                      Result := -1;
                    end;
        varString:  Result := ReadString(Option);
      end
    end
    else begin
      case VT of
        varBoolean: Result := False;
        varInteger: Result := -1;
        varString:  Result := '';
        else Result := null;
      end;
    end;
    Free;
  end;
end;


procedure SetOptionState(const Path, Option: String; Value: Variant);
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    OpenKey(Path, True);
    case VarType(Value) of
      varBoolean: if Value then WriteString(Option, '1')
                           else WriteString(Option, '0');
      varInteger: WriteInteger(Option, Value);
      varString:  WriteString(Option, Value);
    end; //case
    Free;
  end;
end;

//Hristo
function ExtractRealCondition(lcSQLString: string): string;
begin
  if Pos('WHERE', UPPERCASE(lcSQLString)) <> 0
    then Result := Copy(lcSQLString, Pos('WHERE', UPPERCASE(lcSQLString)),
      Length(lcSQLString) - Pos('WHERE', UPPERCASE(lcSQLString)) + 1)
    else Result := ' ';
end;

function GetValuesOf(lcStr: string): string;
begin
  if pos('=', lcStr) > 0 then Result := Copy(lcStr, Pos('=', lcStr) + 1, Length(lcStr) - Pos('=', lcStr) + 1)
    else Result := '';
end;

function GetWhereClause(lcStr: string): string;
begin
  if Pos('WHERE', UPPERCASE(lcStr)) <> 0
    then Result := Copy(lcStr, Pos('WHERE', UPPERCASE(lcStr)) + 5,
      Length(lcStr) - Pos('WHERE', UPPERCASE(lcStr)) + 1)
    else Result := ' ';
end;

{*****************************************************************************
* funkcia RemoveLastFolder - premahwa poslednata direktoria ot patia
*   parametri:
*       FullPath - patia ot koito shte se premahwa.
*   wrashtana stoinost:
*       wrashta patia bez poslednata direktoria w slu4ai na uspeh
*       ili palnia pat w protiwen slu4ai
*  primer:
*       NewPath := RemoveLastFolder('c:\temp\tmp'); //NewPath = 'c:\temp\'
*       NewPath := RemoveLastFolder('c:\temp\dir1\'); //NewPath = 'c:\temp\'
*       NewPath := RemoveLastFolder('temp\'); //NewPath = 'temp\'
*****************************************************************************}
function RemoveLastFolder(FullPath : string) : string;
var
  i : word;
begin
  Result := FullPath;
  i := length(FullPath);
  if FullPath[i] = '\' then dec(i);
  while (FullPath[i] <> '\') and (i > 0) do dec(i);
  if i > 0 then setlength(Result, i);
end;

{*****************************************************************************
* funkcia CompressFileName - premahwa interwalite ot imeto na fail
*   parametri
*       FileName - ime na fail.
*   wrashtana stoinost
*       wrashta podadenia parametar, no s otstraneni interwali ' '
* primer
*       FileName := CompressFileName('my file 1'); //FileName = 'myfile1';
*****************************************************************************}
function CompressFileName(FileName : string) : string;
var
  i, j, n : word;
begin
  j := 1; n := length(FileName);
  Result := FileName;
  for i := 1 to n do
    if FileName[i] <> ' ' then begin
      Result[j] := FileName[i];
      inc(j);
    end;
  setlength(result, j - 1);
end;

{*****************************************************************************
* funkcia ProcessString - obrabotwa string, kato zamenia wsi4ki sreshtania na
* daden simwol s drug simwol
*   parametri
*       Source - obrabotwan String;
*       SearchFor - simwol koito shte bade zamenian;
*       ReplaceWith - simwol s koito shte se zamenia.
*   wrashtana stoinost
*       wrashta obrabotenia string
* primer
*       Str := ProcessString('my file 1', ' ', '_'); //Str = 'my_file_1';
*****************************************************************************}
function ProcessString(Source : string; SearchFor, ReplaceWith : char): string;
var
  i, n : word;
begin
  n := length(Source);
  Result := Source;
  for i := 1 to n do
    if Source[i] = SearchFor then Result[i] := ReplaceWith
end;

function FormatBGDate(const D: String): String;
begin
  Result := D;
  if Length(Result) > 0 then
    while (not (Result[Length(Result)] in ['0'..'9'])) and (Length(Result) > 1) do
      Delete(Result, Length(Result), 1);
end;

function StripFromFilePath(FileName, PathToStrip : string) : string;
var
  n : word;
begin
  n := length(PathToStrip);
  Result := Copy(FileName, n + 1, length(FileName) - n);
end;

{************************************************************************
* ReverseStrings - obrashta podredbata na stringowete w daden StringList
*   parametri - StringList-a koito shte se obrabotwa.
* primer:    StrLst (predi)      StrLst (sled)
*               string1             string3
*               string2             string2
*               string3             string1
************************************************************************}
procedure ReverseStrings(Strings : TStrings);
var
  i, n, p : integer;
  Tmp     : string;
begin
  p := Strings.Count; n := p div 2; i := 0;
  while i < n do begin
    Tmp := Strings.Strings[i];
    Strings.Strings[i] := Strings.Strings[p - i - 1];
    Strings.Strings[p - i - 1] := Tmp;
    inc(i);
  end;
end;

procedure GetFileNames(RootPath, FileExt : string; InsertInto : TStrings);
var
  SearchRec : TSearchRec;
begin
  if FindFirst(RootPath + '*.*', faAnyFile, SearchRec) = 0 then begin
    if (SearchRec.Attr and faDirectory > 0) and
       (SearchRec.Name <> '.') and (SearchRec.Name <> '..')
    then
         GetFileNames(RootPath + SearchRec.Name + '\', FileExt, InsertInto)
    else
      if ((SearchRec.Name <> '.') and (SearchRec.Name <> '..')) and
         ((UPPERCASE(ExtractFileExt(SearchRec.Name)) =
         ('.' + UPPERCASE(FileExt))) or (FileExt = '*'))
      then
        InsertInto.Add(RootPath + SearchRec.Name);
    while FindNext(SearchRec) = 0 do
    begin
      if (SearchRec.Attr and faDirectory > 0) and
         (SearchRec.Name <> '.') and (SearchRec.Name <> '..')
      then
         GetFileNames(RootPath + SearchRec.Name + '\', FileExt, InsertInto)
      else
        if ((SearchRec.Name <> '.') and (SearchRec.Name <> '..')) and
           ((UPPERCASE(ExtractFileExt(SearchRec.Name)) =
           ('.' + UPPERCASE(FileExt))) or (FileExt = '*'))
        then
          InsertInto.Add(RootPath + SearchRec.Name);
    end; //while FindNext(SearchRec)...
    FindClose(SearchRec);
    ReverseStrings(InsertInto);
  end; //if FindFirst(RootPath + '*.*',...
end;

{****************************************************************************
* Convert6toDate - konvertira string ot 6 char-a w string predstawiasht data
* formata e DDMMYY, a wrashtanata data e DD.MM.20YY
* primer:
*    Convert6toDate('121201') // = '12.12.2001'
*    Convert6toDate('121299') // = '12.12.2099'
*    Convert6toDate('123201') // = '12.32.2001'
*    Convert6toDate('12121900') // = ''
****************************************************************************}
function Convert6toDate(char6Date : string) : string;
begin
  if length(char6Date) = 6 then
    Result := char6Date[1] + char6Date[2] + '.' +
              char6Date[3] + char6Date[4] + '.20' +
              char6Date[5] + char6Date[6]
  else Result := '';
end;

{***************************************************************************
* Convert4toTime - konvertira string ot 4 char-a w string predstawiasht 4as
* formata e HHMM, a wrashtania 4as e HH:MM
* primer:
*    Convert4toTime('1212') // = '12:12'
*    Convert4toTime('2969') // = '29:69'
*    Convert4toTime('123201') // = ''
***************************************************************************}
function Convert4toTime(char4Time : string) : string;
begin
  if length(char4Time) = 4 then
    Result := char4Time[1] + char4Time[2] + ':' +
              char4Time[3] + char4Time[4]
  else Result := '';
end;

{***************************************************************************
* ClearWhereStatement - Otstraniawa Where klauzata ot daden SQL string
* primer:
*    ClearWhereStatement('select * from TBL1 where FLD1='asd'')
*               // = 'select * from TBL1'
*    ClearWhereStatement('select * from TBL1')
*               // = 'select * from TBL1'
***************************************************************************}
function ClearWhereStatement(FullSQLStatement : string) : string;
var
  p : word;
begin
  Result := FullSQLStatement;
  p := pos(' WHERE', UPPERCASE(FullSQLStatement));
  if p > 0 then
    setlength(Result, p - 1);
end;


//string process functions
{***************************************************************************
* funkcia DeleteFromStr - iztrivawa 4ast ot string
*   parametri
*       Str     - String-a ot koito shte se premahwa;
*       FromPos - ot koia pozicia da se premahne;
*       Length  - kolko simwola da se premahnat;
*   wra6tana stoinost - wra6ta obrabotenia String, pri neuspeh prazen niz ''
* primer:
* str1 := DeleteFromStr('String1', 4, 3); //str = 'Str1'
* str1 := DeleteFromStr('String1', 4, 5); //str = ''
***************************************************************************}
function DeleteFromStr(Str : string; FromPos, Length : integer) : string;
var j, n : integer;
begin
  n := system.length(Str);
  if (FromPos + Length - 1) > n then Result := ''
  else begin
    Result := Str;
    for j := FromPos + Length to n do
      Result[j-Length] := Result[j];
    setlength(Result, n - Length);
  end;
end;

{***************************************************************************
* funkcia RepeatPos - namira poziciata na n-toto powtroenie na podniz w niz
*   parametri
*       SubStr - String-a za koito 6te se tarsi;
*       Str    - String-a w koito 6te se tarsi;
*       Times  - poziciata na koe powtorenie shte se warne;
*   wra6tana stoinost - wra6ta poziciata na n-toto powtorenie na podniza
*       w niza ili 0 w slu4ai na neuspeh;
* primer:
* i := RepeatPos('Str', 'String1Str2Str3', 3); //i = 12
* i := RepeatPos('String', 'String1Str2Str3', 3); //i = 0;
***************************************************************************}
function RepeatPos(SubStr, Str : string; Times : byte) : integer;
var
  TmpStr : string;
  i, p, n : integer;
begin
  if Times > 0 then begin
    TmpStr := Str;
    p := pos(SubStr, TmpStr); n := Times - 1; i := p;
    TmpStr := copy(TmpStr, p + length(SubStr),
                   length(TmpStr) - p - length(SubStr) + 1);
    while (n > 0) and (p <> 0) do begin
      p := pos(SubStr, TmpStr); dec(n);
      if p <> 0 then inc(i, p + length(SubStr) - 1)
      else i := 0;
      TmpStr := copy(TmpStr, p + length(SubStr),
                     length(TmpStr) - p - length(SubStr) + 1);
    end;
    Result := i;
  end
  else Result := 0;
end;

function ChangeSeparator(Str, CurrentSeparator, NewSeparator : string) : string;
var
  j, n : word;
  TmpStr  : string;
begin
  TmpStr := Str;
  Result := '';
  while TmpStr <> '' do begin
    n := length(TmpStr) + 1;
    j := pos(CurrentSeparator, TmpStr);
    if j > 0 then begin
      Result := Result + copy(TmpStr, 1, j - 1) + NewSeparator;
      inc(j, length(CurrentSeparator));
      TmpStr := copy(TmpStr, j, n - j);
    end
    else begin
      Result := Result + TmpStr;
      TmpStr := '';
    end;
  end;
end;

function GetFieldsCount(Line, Separator : string) : word;
var i      : word;
    TmpStr : string;
begin
  TmpStr := Line;
  Result := 0; i := 1;
  while (i > 0) and (length(TmpStr) >= length(Separator)) do begin
    inc(Result);
    i := pos(Separator, TmpStr);
    TmpStr := copy(TmpStr, i + length(Separator),
                   length(TmpStr) - i - length(Separator) + 1);
  end;
end;

function GetField(Line, Separator : string; Index : word) : string;
var i, j : word;
begin
  Result := '';
  if Index <= GetFieldsCount(Line, Separator) then begin
     i := RepeatPos(Separator, Line, Index - 1);
     j := RepeatPos(Separator, Line, Index);
     if i > 0 then i := i + length(Separator) else i := 1;
     if j = 0 then j := length(Line) + 1;
     Result := copy(Line, i, j - i);
  end;
end;

function GetIndexOf(Line, Separator, FieldValue : string; ExactMatch: Boolean = True) : word;
var
  i, n : word;
begin
  i := 1;
  n := GetFieldsCount(Line, Separator) + 1;
  while (i <= n) and
        (( ExactMatch and (Trim(GetField(Line + Separator, Separator, i)) <> Trim(FieldValue)) ) or
         ( (not ExactMatch) and (Pos(Trim(FieldValue), Trim(GetField(Line + Separator, Separator, i))) = 0) ) )

  do Inc(i);
  if i > n then Result := 0
  else Result := i;
end;

function GetFieldOrderIndex(Line, Separator, FieldValue : string) : word;
var
  i, n : word;
  SField : String;
  P : Integer;
begin
  i := 1;
  n := GetFieldsCount(Line, Separator) + 1;

  FieldValue := Trim(FieldValue);
  while (i <= n) do
  begin
    SField := Trim(GetField(Line + Separator, Separator, i));
    P := Pos(FieldValue, SField);
    if (P > 0) and ( (P + Length(FieldValue) - 1 = Length(SField)) or (SField[P + Length(FieldValue)] = ' ') ) then
       Break
    else
      Inc(i);
  end;

  if i > n then Result := 0
  else Result := i;
end;

function ExportToXLS(CDS: TDataSet; ListName: string; ExportLine: boolean = true; ShowExcel: boolean = True): boolean;
var D: TSaveDialog;
    XL: Variant;
    XLSheet: Variant;
    i, r: integer;
    BM : TBookmark;
begin
  Result := true;
  if (not CDS.Active) or (CDS.RecordCount = 0) then
  begin
    Result := False;
    Exit;
  end;
  try
    XL:= CreateOleObject('Excel.Application');
  except
    on E: EOleSysError do
    begin
      Result := False;
      MessageDlg(err_CantConnectToXLS, mtError, [mbOK], E.HelpContext);
      Exit;
    end;
  end;
  D := TSaveDialog.Create(nil);
  D.DefaultExt := 'xls';
  D.Filter := 'Microsoft Excel Files (*.xls)|*.xls|All Files (*.*)|*.*';
  D.Options := D.Options + [ofOverwritePrompt, ofPathMustExist ];
  D.Title := msg_FileName;
  if D.Execute then
  begin
    try
      CDS.DisableControls;
      Application.ProcessMessages;
      Screen.Cursor := crHourglass;
      XL.Workbooks.Add(xlWBatWorkSheet);
      if  Length(ListName) > 30 then
        System.Delete(ListName, 31, Length(ListName) - 30);
      XL.Workbooks[1].WorkSheets[1].Name := ListName;
      XLSheet := XL.Workbooks[1].WorkSheets[1];
      XL.Visible := ShowExcel;
      //Export title information
      r := 0;
      for i := 0 to CDS.FieldCount - 1 do
      begin
        Application.ProcessMessages;
        //Exclude the ID Fields
        if (UPPERCASE( Copy( CDS.Fields[i].FieldName, Length( CDS.Fields[i].FieldName ) - 1, 2 ) ) <> 'ID')
        then begin
          XLSheet.Cells[1, r + 1] := CDS.Fields[i].DisplayLabel;
          XLSheet.Cells[1, r + 1].Font.Bold := True;
          XLSheet.Cells[1, r + 1].Font.Color := clBlue;
          XLSheet.Cells[1, r + 1].Interior.ColorIndex := 15; //25% Grayed
          inc(r);
        end;
      end;
      //Export Data
      if ExportLine then
      begin
        ExportLineToXLS(XLSheet, CDS, 2);
      end
      else begin
        with CDS do
        begin
          BM := GetBookmark;
          First;
          for i := 0 to RecordCount - 1 do
          begin
            ExportLineToXLS(XLSheet, CDS, i + 2);
            Application.ProcessMessages;
            Next;
          end;
          GotoBookmark(BM);
          FreeBookmark(BM);
        end;
      end;
      try
        if not VarIsEmpty(XL) then
        begin
          XL.Columns.AutoFit;
          XL.DisplayAlerts := False;
          XLSheet.SaveAs(D.FileName);
          //XL.Quit;
          Application.BringToFront;
          Screen.ActiveForm.Refresh;
          ShowMessage(msg_DataSaveSuccess);
        end;
        Screen.Cursor := crDefault;
      except
        on E : Exception do
        begin
          Screen.Cursor := crDefault;
          if Pos('Cannot acces', E.Message) > 0 then
            MessageDlg(Format(err_FileAccessDenied, [D.FileName]), mtError, [mbOK], 0)
          else
            MessageDlg(Format(err_FileSaveError, [D.FileName]), mtError, [mbOK], 0);
        end;
      end;
    finally
      //XL.Quit;
      D.Free;
      CDS.EnableControls;
      Screen.Cursor := crDefault;
    end;
  end
  else Result := False;
end;

procedure ExportLineToXLS(XLSheet: variant; CDS: TDataSet; lcRow: LongInt);
var i: integer;
    lcValue: variant;
    r: Integer;
begin
  r := 0;
  for i := 0 to CDS.FieldCount - 1 do
  begin
    if (UPPERCASE(Copy(CDS.Fields[i].FieldName, Length(CDS.Fields[i].FieldName) - 1 ,2)) <> 'ID')
    then begin
      case CDS.Fields[i].DataType of
        ftFloat:        lcValue := CDS.Fields[i].DisplayText;
        ftString:       lcValue := '''' + CDS.Fields[i].Value;
        ftBlob, ftMemo: lcValue := CDS.Fields[i].AsString;
        ftDate, ftTime,
        ftDateTime:     lcValue := CDS.Fields[i].DisplayText;
        ftInteger:      lcValue := CDS.Fields[i].Value;
        else            lcValue := CDS.Fields[i].Value;
      end; //case
      XLSheet.Cells[lcRow, r + 1] := lcValue;
      inc(r);
    end;
  end;
end;

function GetDayOfWeekAsString(ADate: TDateTime): String;
begin
  try
    case DayOfWeek(ADate) of
      1: Result := 'Понеделник';
      2: Result := 'Вторник';
      3: Result := 'Сряда';
      4: Result := 'Четвъртък';
      5: Result := 'Петък';
      6: Result := 'Събота';
      7: Result := 'Неделя';
      else Result := '';
    end;
  except
    Result := '';
  end;
end;

end.

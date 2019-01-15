unit proj2;

{$mode objfpc}{$H+}
{$codepage UTF8}
{$I-}


// public  - - - - - - - - - - - - - - - - - - - - - - - - -
interface

USES cwstring, crt, useful, SysUtils;

CONST alphabet : widestring = 'abcdefghijklmnopqrstuvwxyzàâéèêëîïôùûüÿæœç-ø' ;
Type lineOfProbas = array[1..44] of real;
Type tableOfProba = array[1..44] of lineOfProbas;


procedure p2_main(n,s:integer;path:string);
procedure resetTable(var table:tableOfProba);
procedure child_updateTable(var probas:tableOfProba;words:linesOfFile);
procedure updateTable(filepath:string);
function readLine(line:widestring):lineOfProbas;
function readTable:tableOfProba;
function genLetter(letter:UnicodeString;probas:tableOfProba):UnicodeString;
function genWord(minsize:integer;probas:tableOfProba):widestring;


// private - - - - - - - - - - - - - - - - - - - - - - - - -
implementation

procedure p2_main(n,s:integer;path:string);
var table:tableOfProba; i:integer;
Begin
    if s=1 then s:=2;
    if path<>'' then
        begin
        writeln('Mise à jour de la table...');
        updateTable(path);
        writeln('Mise à jour de la table terminée');
        end;
    randomize;
    table:=readTable;
    for i:=1 to n do
        writeln(genWord(s,table))
end;

procedure resetTable(var table:tableOfProba);
var i,j:integer;
begin
for i:=1 to length(table) do
    for j:=1 to length(table[i]) do
        table[i][j] := 0.0; ;
end;

procedure child_updateTable(var probas:tableOfProba;words:linesOfFile);
var c,i,j:integer;
    w,w2:widestring;
begin
    for w in words do
        begin
        w2 := 'ø'+w+'ø';
        for c:=1 to length(w2)-1 do
            for i:=1 to length(alphabet) do
                if alphabet[i]=w2[c] then
                    for j:=1 to length(alphabet) do
                        if w2[c+1]=alphabet[j] then probas[i,j] := probas[i,j]+1.0 ;
                ;
            ;
        ;
    end;
end;

procedure updateTable(filepath:string);
var i:integer;
    r,sum:real;
    words:linesOfFile;
    probas:tableOfProba;
    fic:TextFile;
    lprobas:lineOfProbas;
begin
    resetTable(probas);
    sum := 0;
    assign(fic,'letters.csv');
    Rewrite(fic);
    for i:=1 to round(675000/length(words)) do begin
        words := readFile(filepath,i*length(words));
        child_updateTable(probas,words);
        end;
    for lprobas in probas do
        begin
        sum := 0;
        for r in lprobas do
            sum := sum+r ;
        for r in lprobas do begin
            if sum<>0 then write(fic,FloatToStr(round2(r/sum,100000))+',')
            else write(fic,'0.0,') ;
            end;
        writeln(fic,'');
        end;
    close(fic)
end;

function readLine(line:widestring):lineOfProbas;
var r:real;numb:string;c:char;probas:lineOfProbas;i:integer;
begin
    i := 1;
    numb := '';
    for c in line do
        if c<>',' then
            numb := numb+c
        else
            begin
            r := StrToFloat(numb);
            numb :='';
            probas[i] := r;
            i := i+1;
            end;
    Exit(probas);
end;

function readTable:tableOfProba;
var i:integer;
    fic:TextFile;
    line:widestring;
    probas:tableOfProba;
begin
    assign(fic,'letters.csv');
    try
        reset(fic);
        i := 1;
        while not eof(fic) do
            begin
            readln(fic,line);
            probas[i] := readLine(line);
            i := i+1;
            end;
        close(fic);
        Exit(probas);
    except on E: EInOutError do writeln('File handling error occurred. Details: ', E.Message);
    end;
end;


function genLetter(letter:UnicodeString;probas:tableOfProba):UnicodeString;
var p,r,s:real;i:integer;line:lineOfProbas;
begin
i := indexInString(alphabet,letter);
//writeln('i:',i,' letter:',letter);
if i<1 then Exit('ø') ;
p := 0.0;
s := 0.0;
r := (random(99999)+1)/100000;
line := probas[i];
i := 0;
for p in line do
    begin
    //writeln(' s:',s,' r:',r,' p:',p,' i:',i);
    if s>=r then Exit(alphabet[i]);
    s := s+p;
    i := i+1;
    end;
Exit('ø');
end;

function genWord(minsize:integer;probas:tableOfProba):widestring;
var mot,final:widestring;i:integer;
begin
    mot := 'ø';
    minsize := minsize+3;
    final := '';
    //writeln('word: ',mot,' lastChar:',mot[length(mot)],' minsize:',minsize);
    while (length(mot)<minsize) or (mot[length(mot)]<>'ø') do
        begin
        mot := mot + genLetter(mot[length(mot)],probas);
        if length(mot)>2 then
            if (mot[length(mot)]='ø') and (mot[length(mot)-1]='ø') then delete(mot,length(mot),1) ;
        //writeln('word: ',mot,' lastChar:',mot[length(mot)],' minsize:',minsize)
        end;
    for i:=2 to length(mot)-1 do
        if mot[i]<>'ø' then begin
            final := final+mot[i];
            end;
    Exit(final);
end;


end.

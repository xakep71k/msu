{
Методы сортировки (зачетный проект)
}
{$R+}
const MAX_CATS = 100;
type CatType = record
	name: string; { кличка }
	breed: string; { порода }
	rating: array[1..5] of integer; { пять оценок от 0 до 5 }
	weight: integer; { вес в граммах }
end;
CatsType = array[1..MAX_CATS] of CatType;


procedure readCat(var fileReadFrom: text; var cat: CatType);
var i: integer;
space: char;
kg, gramm: integer;
begin
	readln(fileReadFrom, cat.name);
	readln(fileReadFrom, cat.breed);
	readln(fileReadFrom, cat.weight);
	for i := 1 to 5 do
	begin
		read(fileReadFrom, cat.rating[i], space);
	end;
	readln(fileReadFrom);
	readln(fileReadFrom);
end;

procedure readCats(var fileReadFrom: text; var cats: CatsType; maxCats: integer);
var i: integer;
begin
	for i:= 1 to maxCats do
	begin
		readCat(fileReadFrom, cats[i]);
	end;
end;

var breedFile: textfile;
catsFile, catsFile2: textfile;
cats: CatsType;
i, j, w1, w2: integer;
arr: array[1..75] of string;
index: array[1..75] of integer;
randomIndex: integer;
s, line1, line2, line3, line4: string;
ch: char;
begin
	randomize;
	Assign(breedFile, 'breeds.txt');
	Reset(breedFile);
	Assign(catsFile, 'f_n_initial.txt');
	Reset(catsFile);
	{for i:= 1 to 75 do
	begin
		readln(breedFile, arr[i]);
		index[i] := i;
	end;
	for i:= 1 to 100 do
	begin
		readln(catsFile, cats[i].name);
		for j := 1 to 5 do
		begin
			cats[i].rating[j] := random(5);
		end;
		cats[i].weight := random(17 * 1000 - 7000) + 7000;
	end;
	for i:= 1 to 75 do
	begin
		randomIndex := random(75 - i) + i;
		cats[i].breed := arr[index[randomIndex]];
		index[randomIndex] := index[i];
	end;
	for i:= 1 to 25 do
	begin
		randomIndex := random(75 - i) + i;
		cats[i + 75].breed := arr[index[randomIndex]];
		index[randomIndex] := index[i];
	end;
	Assign(catsFile2, 'f_n_initial.txt');
	Rewrite(catsFile2);
	for i:= 1 to 100 do
	begin
		writeln(catsFile2, cats[i].name);
		writeln(catsFile2, cats[i].breed);
		writeln(catsFile2, cats[i].weight);
		for j := 1 to 5 do write(catsFile2, cats[i].rating[j], ' ');
		writeln(catsFile2);
		writeln(catsFile2);
	end;
	Close(catsFile2);}
	readCats(catsFile, cats, MAX_CATS);
	for i:= 1 to MAX_CATS do
	begin
		writeln(cats[i].name);
		writeln(cats[i].breed);
		writeln(cats[i].weight);
		for j := 1 to 5 do write(cats[i].rating[j], ' ');
		writeln();
		writeln();
	end;
end.



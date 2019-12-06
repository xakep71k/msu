{
Методы сортировки (зачетный проект).
Бубнов Александр.
Номер студенческого билета 02190738.
Виды сортировки:
	1. Простой выбор.
	2. Шелла.
	3. Простое слияние.
Данные:
	Участники выставки кошек: имя животного, порода, пол, вес в формате К кг Г гр (например, 5 кг 600 гр). Упорядочить список участников по возрастанию веса.

}
{$R+}
const MAX_CATS = 100;
INITIAL_FILE = 'f_n_initial.txt';
SORT_UP_FILE = ' f_n_up.txt';
SORT_DOWN_FILE = 'f_n_down.txt';
SORT_UP_DOWN_FILE = 'f_n_up_and_down.txt';
SORT_RANDOM_FILE = 'f_n_random.txt';
THREE_DIGITS_STUDENT_NUMBER = 738;

type CatType = record
	name: string; { кличка }
	breed: string; { порода }
	rating: array[1..5] of integer; { пять оценок от 0 до 5 }
	sumRating: integer; { суммарное число оценок }
	weight: integer; { вес в граммах }
end;
CatsType = array[1..MAX_CATS] of CatType;
OperationsCounterType = record
	swapOps, compareOps :integer;
end;
CatsTypePtr = ^CatsType;

procedure writeOpsCounter(title: string; var opsCounter :OperationsCounterType);
begin
	writeln(title, 'число перестановок - ', opsCounter.swapOps, ', число сравнений - ', opsCounter.compareOps);
end;

procedure clearOpsCounter(var opsCounter :OperationsCounterType);
begin
	opsCounter.compareOps := 0;
	opsCounter.swapOps := 0;
end;

function less(var cat1, cat2: CatType):boolean;
begin
	less := cat1.sumRating < cat2.sumRating;
end;

function more(var cat1, cat2: CatType):boolean;
begin
	more := cat1.sumRating > cat2.sumRating;
end;

procedure readCat(var fileReadFrom: text; var cat: CatType);
var i: integer;
space: char;
begin
	readln(fileReadFrom, cat.name);
	readln(fileReadFrom, cat.breed);
	readln(fileReadFrom, cat.weight);
	cat.sumRating := 0;
	for i := 1 to 5 do
	begin
		read(fileReadFrom, cat.rating[i], space);
		cat.sumRating := cat.sumRating + cat.rating[i];
	end;
	readln(fileReadFrom);
	readln(fileReadFrom);
end;

procedure readCats(var fileReadFrom: text; var cats: CatsType; maxCats: integer);
var i: integer;
begin
	for i:= 1 to maxCats do
	begin
		if EOF(fileReadFrom) then
		begin
			Writeln('Нет запрошенного количества объектов');
			exit;
		end;
		readCat(fileReadFrom, cats[i]);
	end;
end;

procedure writeCat(var fileWriteTo: text; var cat: CatType);
var i: integer;
begin
	writeln(fileWriteTo, 'Имя:              ', cat.name);
	writeln(fileWriteTo, 'Порода:           ', cat.breed);
	writeln(fileWriteTo, 'Вес:              ', cat.weight div 1000, ' кг ', cat.weight mod 1000, ' гр');
	Write(fileWriteTo, 'Оценки:           ');
	for i := 1 to 5 do
	begin
		write(fileWriteTo, cat.rating[i], ' ');
	end;
	writeln(fileWriteTo);
	writeln(fileWriteTo, 'Суммарная оценка: ', cat.sumRating);
	writeln(fileWriteTo);
end;

procedure writeCats(var fileReadFrom: text; var cats: CatsType; maxCats: integer);
var i: integer;
begin
	for i:= 1 to maxCats do
	begin
		writeCat(fileReadFrom, cats[i]);
	end;
end;

procedure writeProjectTasksNumers(studentID: integer);
begin
	writeln('Простая сортировка: ', abs((studentID + 546) mod 5) + 1);
	writeln('Сложная сортировка: ', abs((studentID + 212) mod 4) + 6);
	writeln('Входные данные:     ', abs((studentID + 123) mod 11) + 1);
	writeln();
end;

procedure writeCatsRating(var cats: CatsType; maxCats: integer);
var i: integer;
begin
	for i := 1 to maxCats do
	begin
		Write(cats[i].sumRating, ' ');
	end;
	Writeln();
end;

procedure openForRead(var fd: text; name: string);
begin
	assign(fd, name);
	reset(fd);
end;

procedure openForWrite(var fd: text; name: string);
begin
	assign(fd, name);
	Rewrite(fd);
end;

procedure writeCats2File(var cats: CatsType; maxCats: integer; fileName: string);
var fileDesc: text;
begin
	openForWrite(fileDesc, fileName);
	writeCats(fileDesc, cats, maxCats);
	Close(fileDesc);
end;

function getIndexMinElement(var cats: CatsType; starti, endi, step: integer; var opsCounters: OperationsCounterType): integer;
var i, minElementIndex :integer;
begin
	minElementIndex := starti;
	i := starti;
	while i <= endi do begin
		opsCounters.compareOps := opsCounters.compareOps  + 1;
		if more(cats[minElementIndex], cats[i]) then begin
			minElementIndex := i;
		end;
		i := i + step;
	end;	
	getIndexMinElement := minElementIndex;
end;

procedure swapElements(var cat1, cat2: CatType; var opsCounters: OperationsCounterType);
var tmp :CatType;
begin
	tmp := cat1;
	cat1 := cat2;
	cat2 := tmp;
	opsCounters.swapOps := opsCounters.swapOps + 1;
end;

procedure sortSelection(var cats: CatsType; step, maxCats: integer; var opsCounters: OperationsCounterType; demo: integer);
var i, indexMinElement: integer;
begin
	i := 1;
	while i <= maxCats-1 do begin
		indexMinElement := getIndexMinElement(cats, i, maxCats, step, opsCounters);
		swapElements(cats[indexMinElement], cats[i], opsCounters);
		if demo = 1 then begin
			writeCatsRating(cats, maxCats);
		end;
		i := i + step;
	end;
end;

procedure sortShell(var cats: CatsType; maxCats: integer; var opsCounters: OperationsCounterType; demo: integer);
var k: integer;
begin
	k := maxCats;
	repeat begin
		k := k div 2;
		sortSelection(cats, k, maxCats, opsCounters, demo);
	end until k < 2;
end;

function findSortedSequenceFromEnd(var cats: CatsType; starti, endi: integer): integer;
var i: integer;
begin
	{
		Использую while вместо for, так как мне нужно знать номер итерации.
		В for это значение после выхода может быть неопределено.
	}
	i := starti;
	endi := endi + 1;
	while i >= endi do
	begin
		if more(cats[i - 1], cats[i]) then break;
		i := i - 1;
	end;
	findSortedSequenceFromEnd := i;
end;

function findSortedSequenceFromBegin(var cats: CatsType; starti, endi: integer): integer;
var i: integer;
begin
	{
		Использую while вместо for, так как мне нужно знать номер итерации.
		В for это значение после выхода может быть неопределено.
	}
	i := starti;
	endi := endi - 1;
	while i <= endi do
	begin
		if more(cats[i], cats[i + 1]) then break;
		i := i + 1;
	end;
	findSortedSequenceFromBegin := i;
end;

procedure merge(var catsTo: CatsType; starti1, endi1, starti2, endi2: integer; var catsFrom: CatsType; var i: integer);
begin
	writeln('-- index ', starti1, ' ', endi1, ' ', starti2, ' ', endi2);
	while (endi2 <= starti2) or (starti1 <= endi1) do
	begin
		writeln('-- ', catsFrom[starti1].sumRating, ' ', catsFrom[endi2].sumRating);
		if (endi2 > starti2) or less(catsFrom[starti1], catsFrom[endi2]) then
		begin
			catsTo[i] := catsFrom[starti1];
			starti1 := starti1 + 1;
		end else begin
			catsTo[i] := catsFrom[endi2];
			endi2 := endi2 + 1;
		end;
		i := i + 1;
	end;
end;

procedure sortMerge(
	var catsResult: CatsTypePtr;
	var cats1, cats2: CatsType;
	maxCats: integer;
	var opsCounters: OperationsCounterType;
	demo: integer);
var starti1, starti2, endi1, endi2, currenti: integer;
catsHelper, catsTmp: CatsTypePtr;
begin
	catsResult := @cats1;
	catsHelper := @cats2;
	starti1 := 1;
	endi1 := maxCats;
	starti2 := maxCats;
	currenti := 1;
	while true do
	begin
		endi1 := findSortedSequenceFromBegin(catsResult^, starti1, endi1);
		if endi1 >= maxCats then break;
		endi2 := findSortedSequenceFromEnd(catsResult^, starti2, endi1);
		writeln('start merge');
		merge(catsHelper^, starti1, endi1, starti2, endi2, catsResult^, currenti);
		starti1 := endi1 + 1;
		endi1 := endi2 - 1;
		starti2 := endi1;
	end;
	catsResult := catsHelper;
end;

procedure shuffleCats(var cats: CatsType; maxCats: integer);
var randomIndex, i: integer;
tmp: CatType;
begin
	for i:= 1 to maxCats do
	begin
		randomIndex := random(maxCats - i) + i;
		tmp := cats[i];
		cats[i] := cats[randomIndex];
		cats[randomIndex] := tmp;
	end;
end;

var fileDesc: text;
catsSortSelection, catsSortShell, catsRandom, catsSortMerge1, catsSortMerge2: CatsType;
catsSortMerge: CatsTypePtr;
demo: integer;
opsCounterSortSelection, opsCounterSortShell, opsCounterSortMerge :OperationsCounterType;
begin
	writeProjectTasksNumers(THREE_DIGITS_STUDENT_NUMBER);
	randomize;
	{ инициализация переменных }
	demo := 0;
	clearOpsCounter(opsCounterSortSelection);
	clearOpsCounter(opsCounterSortShell);
	clearOpsCounter(opsCounterSortMerge);

	{ инициализация котов }
	openForRead(fileDesc, INITIAL_FILE);
	readCats(fileDesc, catsSortSelection, MAX_CATS);
	Close(fileDesc);
	catsSortShell := catsSortSelection;
	catsSortMerge1 := catsSortSelection;
	catsRandom := catsSortSelection;

	{ сортировка }
	sortSelection(catsSortSelection, 1, MAX_CATS, opsCounterSortSelection, demo);
	sortShell(catsSortShell, MAX_CATS, opsCounterSortShell, demo);
	writeCatsRating(catsSortMerge1, 10);
	sortMerge(catsSortMerge, catsSortMerge1, catsSortMerge2, 10, opsCounterSortShell, demo);

	{writeCatsRating(catsSortSelection, MAX_CATS);
	writeCatsRating(catsSortShell, MAX_CATS);}
	writeCatsRating(catsSortMerge^, 10);
	writeOpsCounter('Сортировка простым выбором: ', opsCounterSortSelection);
	writeOpsCounter('Сортировка методом Шелла: ', opsCounterSortShell);
	writeOpsCounter('Сортировка слиянием: ', opsCounterSortShell);
	shuffleCats(catsRandom, MAX_CATS);
	writeCats2File(catsRandom, MAX_CATS, SORT_RANDOM_FILE);
end.



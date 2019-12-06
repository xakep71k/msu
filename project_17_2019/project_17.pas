{
Методы сортировки (зачетный проект).
Бубнов Александр.
Номер студенческого билета 02190738.
Виды сортировки:
	1. Простой выбор.
	2. Шелла.
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
THREE_DIGITS_STUDENT_NUMBER = 748;

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
catsSortedSelection, catsSortedShell, catsRandom: CatsType;
demo: integer;
opsCounterSortSelection, opsCounterSortShell :OperationsCounterType;
begin
	{writeProjectTasksNumers(THREE_DIGITS_STUDENT_NUMBER);}
	randomize;
	{ инициализация переменных }
	demo := 0;
	clearOpsCounter(opsCounterSortSelection);
	clearOpsCounter(opsCounterSortShell);

	{ инициализация котов }
	openForRead(fileDesc, INITIAL_FILE);
	readCats(fileDesc, catsSortedSelection, MAX_CATS);
	Close(fileDesc);
	catsSortedShell := catsSortedSelection;
	catsRandom := catsSortedSelection;

	{ сортировка }
	sortSelection(catsSortedSelection, 1, MAX_CATS, opsCounterSortSelection, demo);
	sortShell(catsSortedShell, MAX_CATS, opsCounterSortShell, demo);

	writeCatsRating(catsSortedSelection, MAX_CATS);
	writeCatsRating(catsSortedShell, MAX_CATS);
	writeOpsCounter('Сортировка простым выбором: ', opsCounterSortSelection);
	writeOpsCounter('Сортировка методом Шелла: ', opsCounterSortShell);
	shuffleCats(catsRandom, MAX_CATS);
	writeCats2File(catsRandom, MAX_CATS, SORT_RANDOM_FILE);
end.



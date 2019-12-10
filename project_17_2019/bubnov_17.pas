{
Методы сортировки (зачетный проект).
Бубнов Александр.
Номер студенческого билета 02190738.
Виды сортировки:
	- Простой выбор.
	- Простое слияние.
Данные:
	Участники выставки кошек:
		имя животного,
		порода,
		пол,
		вес в формате К кг Г гр (например, 5 кг 600 гр).
	Упорядочить список участников по возрастанию веса.
}
{$R+}
Uses math;

const MAX_CATS = 100;
INITIAL_FILE = 'f_n_initial.txt';
SORT_UP_FILE = 'f_n_up.txt';
SORT_DOWN_FILE = 'f_n_down.txt';
SORT_UP_DOWN_FILE = 'f_n_up_and_down.txt';
SORT_RANDOM_FILE = 'f_n_random.txt';
LAST_3_DIGITS_STUDENT_NUMBER = 738;

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
WriteCatsProcedure = procedure(var fileReadFrom: text; var cats: CatsType; maxCats: integer);

procedure writeSummary(title: string; filename: string; maxCats: integer; var opsCounter :OperationsCounterType);
begin
	writeln(title, 'Имя файла - ', fileName, ', всего элементов - ', maxCats, ', число перестановок - ', opsCounter.swapOps, ', число сравнений - ', opsCounter.compareOps);
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
	writeln(fileWriteTo, cat.name);
	writeln(fileWriteTo, cat.breed);
	writeln(fileWriteTo, cat.weight);
	for i := 1 to 5 do
	begin
		write(fileWriteTo, cat.rating[i], ' ');
	end;
	writeln(fileWriteTo);
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

procedure writeCatsDown(var fileReadFrom: text; var cats: CatsType; maxCats: integer);
var i: integer;
begin
	for i:= maxCats downto 1 do
	begin
		writeCat(fileReadFrom, cats[i]);
	end;
end;

{ запись котов: нечётные элементы упорядочены по убыванию, чётные - по возрастанию }
procedure writeCatsUpDown(var fileReadFrom: text; var cats: CatsType; maxCats: integer);
var i, j: integer;
begin
	i := 1;
	if (maxCats mod 2) = 0 then j := maxCats else j := maxCats - 1;
	while (i <= maxCats) or (j >=1 ) do begin
		if i <= maxCats then begin
			writeCat(fileReadFrom, cats[i]);
			i := i + 2;
		end;
		if j >= 1 then begin 
			writeCat(fileReadFrom, cats[j]);
			j := j - 2;
		end;
	end;
end;

{ выдаёт по номеру студенческого номера заданий }
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

procedure writeCatsRating(cats: CatsTypePtr; maxCats: integer);
begin
	writeCatsRating(cats^, maxCats);
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

procedure writeCats2File(var cats: CatsType; maxCats: integer; fileName: string; writeCatsProc: WriteCatsProcedure);
var fd: text;
begin
	openForWrite(fd, fileName);
	writeCatsProc(fd, cats, maxCats);
	Close(fd);
end;

procedure readCatsFromFile(var cats: CatsType; maxCats: integer; fileName: string);
var fd: text;
begin
	openForRead(fd, fileName);
	readCats(fd, cats, maxCats);
	Close(fd);
end;

function findMinElement(var cats: CatsType; starti, endi: integer; var opsCounters: OperationsCounterType): integer;
var i, minElementIndex :integer;
begin
	minElementIndex := starti;
	for i := starti to endi do begin
		Inc(opsCounters.compareOps);
		if more(cats[minElementIndex], cats[i]) then begin
			minElementIndex := i;
		end;
	end;	
	findMinElement := minElementIndex;
end;

procedure swapElements(var cat1, cat2: CatType; var opsCounters: OperationsCounterType);
var tmp :CatType;
begin
	tmp := cat1;
	cat1 := cat2;
	cat2 := tmp;
	Inc(opsCounters.swapOps);
end;


procedure clearRating(var arr: CatsType);
var i: integer;
begin
	for i := Low(arr) to High(arr) do
	begin
		arr[i].sumRating := -1;
	end;
end;

procedure clearRating(var arr: CatsTypePtr);
begin
	clearRating(arr^);
end;

{
Выдержка из http://arch32.cs.msu.su/semestr2/%C1%EE%F0%E4%E0%F7%E5%ED%EA%EE%E2%E0%20%C5.%C0.%2C%20%CF%E0%ED%F4%B8%F0%EE%E2%20%C0.%C0.%20%C7%E0%E4%E0%ED%E8%FF%20%EF%F0%E0%EA%F2%E8%EA%F3%EC%E0.%202%20%F1%E5%EC%E5%F1%F2%F0.pdf страница 29.
Сортировка посредством простого выбора.
В массиве X1, ..., Xn отыскивается минимальный элемент. Найденный элемент меняется местами с первым элементом массива. Затем так же обрабатывается подмассив X2, ..., Xn. Когда обработан подмассив Xn-1, Xn, сортировка оканчивается.
}
procedure sortSelection(var cats: CatsType; maxCats: integer; var opsCounters: OperationsCounterType; demo: integer);
var i, indexMinElement: integer;
begin
	if demo = 1 then begin
		writeln(#10, 'Сортировка простым выбором');
	end;
	for i := 1 to maxCats - 1 do begin
		indexMinElement := findMinElement(cats, i, maxCats, opsCounters);
		swapElements(cats[indexMinElement], cats[i], opsCounters);
		if demo = 1 then begin
			writeCatsRating(cats, maxCats);
		end;
	end;
end;

procedure copyFromTo(var catsTo, catsFrom: CatsType; var mergeIndex, starti: integer);
begin
	catsTo[mergeIndex] := catsFrom[starti];
	starti := starti + 1;
	mergeIndex := mergeIndex + 1;
end;

procedure merge(
	var catsTo, catsFrom: CatsType;
	var mergeIndex: integer;
	start1, end1, start2, end2: integer;
	var opsCounters: OperationsCounterType);
var i: integer;
begin
	{ [start1, end1] и [start2, end2] отрезки, см. sortSimpleMerge() }

	{ производим слияние сразу из двух отрезков учитываю отсортированный порядок }
	while (start1 < end1) and (start2 < end2) do
	begin
		if less(catsFrom[start1], catsFrom[start2]) then begin
			copyFromTo(catsTo, catsFrom, mergeIndex, start1);
		end else begin
			copyFromTo(catsTo, catsFrom, mergeIndex, start2);
		end;
		Inc(opsCounters.compareOps);
		Inc(opsCounters.swapOps);
	end;

	{ производим слияние оставшихся элементов }
	{ из левого отрезка }
	for i := start1 to end1 - 1 do
	begin
		copyFromTo(catsTo, catsFrom, mergeIndex, start1);
		Inc(opsCounters.swapOps);
	end;
	{ производим слияние оставшихся элементов }
	{ из правого отрезка }
	for i := start2 to end2 - 1 do
	begin
		copyFromTo(catsTo, catsFrom, mergeIndex, start2);
		Inc(opsCounters.swapOps);
	end;
end;

{
Выдержка из http://arch32.cs.msu.su/semestr2/%C1%EE%F0%E4%E0%F7%E5%ED%EA%EE%E2%E0%20%C5.%C0.%2C%20%CF%E0%ED%F4%B8%F0%EE%E2%20%C0.%C0.%20%C7%E0%E4%E0%ED%E8%FF%20%EF%F0%E0%EA%F2%E8%EA%F3%EC%E0.%202%20%F1%E5%EC%E5%F1%F2%F0.pdf страница 31.
Сортировка слиянием.
Основная идея такой сортировки — разделить последовательность на уже упорядоченные подпоследовательности (назовем их «отрезками») и затем объединять эти отрезки во всё более длинные упорядоченные отрезки, пока не получится единая упорядоченная последовательность. Отметим, что при этом необходима дополнительная память (массив Y[1..n]).
Простое слияние.
Считается, что в начале отрезки состоят только из одного элемента, они сливаются в отрезки из двух элементов (из X1 и X2, из X3 и X4, ...), которые переносятся в массив Y. На втором этапе соседние двухэлементные отрезки (Y1, Y2 и Y3, Y4; Y5, Y6 и Y7, Y8; ...) объединяются в отрезки из 4 элементов, которые записываются в массив X. На третьем этапе строятся отрезки из 8 элементов, которые заносятся в массив Y, и т.д.
}
procedure sortSimpleMerge(
	var arrResult: CatsTypePtr;
	var arr1, arr2: CatsType;
	maxCats: integer;
	var opsCounters: OperationsCounterType;
	demo: integer);
var start1, start2, end1, end2, mergeIndex, step: integer;
arrHelper, ptrTmp: CatsTypePtr;
begin
	{ [start1, end1] и [start2, end2] отрезки }
	{
		arr1, arr2 - вспомогательные массивы.
		Первый изначально содержит данные для сортировка.
		Второй используется как дополнительный для слияния.
		Затем они меняются местами.
	}
	{ mergeIndex - индекс в массиве куда происходит слияние отрезков }
	if demo = 1 then begin
		writeln(#10, 'Сортировка простым слиянием');
	end;
	arrResult := @arr1;
	arrHelper := @arr2;
	step := 1; { шаг сортировки, который в последствие каждый раз удваивается }
	while step < maxCats do begin
		{ меняем вспомогательный массив с основым местами, }
		{ из вспомогательного мы вычитываем отрезки, в основой мы производим слияние }
		ptrTmp := arrHelper; arrHelper := arrResult; arrResult := ptrTmp;

		mergeIndex := 1;
		{ инициализируем границы отрезков [start1, end1], [start2, end2] }
		start1 := 1; end1 := start1 + step;
		start2 := end1; end2 := start2 + step;
		if demo = 1 then begin
			clearRating(arrResult);
			writeCatsRating(arrHelper, maxCats);
		end;
		while start1 <= maxCats do { производим слияние всех отрезков }
		begin
			merge(
				arrResult^,             { куда происходит слияние }
				arrHelper^,             { откуда происходит слияние }
				mergeIndex,             { индекс массива куда происходит слияние }
				start1,                 { начало первого отрезка }
				Min(end1, maxCats + 1), { конец первого отрезка }
				start2,                 { начало второго отрезка }
				Min(end2, maxCats + 1), { конец второго отрезка }
				opsCounters);

			{ пререходим к следующей паре отрезков }
			start1 := end2; end1 := start1 + step;
			start2 := end1; end2 := start2 + step;
			if demo = 1 then begin
				writeCatsRating(arrResult, maxCats);
			end;
		end;
		step := step * 2;
	end;
end;

procedure shuffleCats(var cats: CatsType; maxCats: integer);
var randomIndex, i: integer;
tmp: CatType;
begin
	for i:= 1 to maxCats do
	begin
		{ выбираем случайный индекс из диапазона [i, maxCats] }
		randomIndex := random(maxCats - i) + i;

		{ переставляем его на место i }
		tmp := cats[i];
		cats[i] := cats[randomIndex];
		cats[randomIndex] := tmp;
	end;
end;

function isDemo(): integer;
begin
	if (ParamCount() = 1) and (ParamStr(1) = '1') then isDemo := 1
	else isDemo := 0;
end;

procedure sortSelectionAndPrintResult(fileName: string; maxCats: integer; demo: integer);
var cats: CatsType;
opsCounter: OperationsCounterType;
begin
	clearOpsCounter(opsCounter);
	readCatsFromFile(cats, maxCats, fileName);
	sortSelection(cats, maxCats, opsCounter, demo);
	writeSummary('Сортировка простым выбором: ', fileName, maxCats, opsCounter);
end;

procedure sortSimpleMergeAndPrintResult(fileName: string; maxCats: integer; demo: integer);
var catsBuf1, catsBuf2: CatsType;
cats: CatsTypePtr;
opsCounter: OperationsCounterType;
begin
	clearOpsCounter(opsCounter);
	readCatsFromFile(catsBuf1, maxCats, fileName);
	sortSimpleMerge(cats, catsBuf1, catsBuf2, maxCats, opsCounter, demo);
	writeSummary('Сортировка слиянием: ', fileName, maxCats, opsCounter);
end;

procedure writeHelp();
begin
	writeln('неверное количество аргументов, варианты запуска');
	writeln(ParamStr(0), ' -gen', ' генерит нужные файлы');
	writeln(ParamStr(0), ' -sort <имя файла> -n <количество котов>', ' запускает два алгоритма сортировки с N элементами');
	Halt;
end;

var fd: text;
cats, catsRandom: CatsType;
demo: integer;
opsCounter:OperationsCounterType;
files: array[1..5] of string;
j: integer;
key: string;
maxCats, err: integer;
fileName: string;
begin
	writeProjectTasksNumers(LAST_3_DIGITS_STUDENT_NUMBER);
	demo := 0;
	if ParamCount() = 0 then writeHelp();
	if (ParamCount() = 1) and (ParamStr(1) = '-gen') then begin
		randomize;
		{ инициализация переменных }
		clearOpsCounter(opsCounter);

		{ инициализация котов }
		readCatsFromFile(cats, MAX_CATS, INITIAL_FILE);
		catsRandom := cats;

		{ сортировка }
		sortSelection(cats, MAX_CATS, opsCounter, 0);
		shuffleCats(catsRandom, MAX_CATS);

		{ запись в файл }
		writeCats2File(catsRandom, MAX_CATS, SORT_RANDOM_FILE, @writeCats);
		writeCats2File(cats, MAX_CATS, SORT_UP_FILE, @writeCats);
		writeCats2File(cats, MAX_CATS, SORT_DOWN_FILE, @writeCatsDown);
		writeCats2File(cats, MAX_CATS, SORT_UP_DOWN_FILE, @writeCatsUpDown);
	end else if(ParamCount() = 4) and (ParamStr(1) = '-sort') and (ParamStr(3) = '-n') then begin
		fileName := ParamStr(2);
		Val(ParamStr(4), maxCats, err);
		if err <> 0 then begin
			Writeln('Ошибка конвертации числа указанного в -n: ', err);
		end;
		sortSelectionAndPrintResult(fileName, maxCats, demo);
		sortSimpleMergeAndPrintResult(fileName, maxCats, demo);
	end else writeHelp();
end.


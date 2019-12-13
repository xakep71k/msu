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
MAX_ACTIONS = 5;

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
SortCatsProcedure = procedure(var fileReadFrom: string; maxCats: integer; var opsCounter: OperationsCounterType);

procedure writeSummary(title: string; filename: string; maxCats: integer; var opsCounter :OperationsCounterType);
begin
	writeln(title, 'Имя файла - ', fileName, ', всего элементов - ', maxCats, ', число сравнений - ', opsCounter.compareOps, ', число перестановок - ', opsCounter.swapOps);
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
		if i <> indexMinElement then begin
			swapElements(cats[indexMinElement], cats[i], opsCounters);
		end;
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

procedure genFiles();
var cats, catsRandom: CatsType;
opsCounter:OperationsCounterType;
begin
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
end;

procedure sort(fileName: string; maxCats, demo: integer);
begin
	sortSelectionAndPrintResult(fileName, maxCats, demo);
	sortSimpleMergeAndPrintResult(fileName, maxCats, demo);
end;

procedure sortCatsSelection(var fileReadFrom: string; maxCats: integer; var opsCounter: OperationsCounterType);
var cats: CatsType;
begin
	readCatsFromFile(cats, maxCats, fileReadFrom);
	sortSelection(cats, maxCats, opsCounter, 0);
end;

procedure sortCatsSimpleMerge(var fileReadFrom: string; maxCats: integer; var opsCounter: OperationsCounterType);
var catsBuf1, catsBuf2: CatsType;
catsPtr: CatsTypePtr;
begin
	readCatsFromFile(catsBuf1, maxCats, fileReadFrom);
	sortSimpleMerge(catsPtr, catsBuf1, catsBuf2, maxCats, opsCounter, 0);
end;

procedure writeTable(var fd: text; sort: SortCatsProcedure);
var files: array[1..MAX_ACTIONS] of string;
maxCats: array[1..MAX_ACTIONS] of integer;
opsCounters: array[1..MAX_ACTIONS] of OperationsCounterType;
sep: string;
i, j, mean: integer;
begin
	files[1] := INITIAL_FILE;
	files[2] := SORT_UP_FILE;
	files[3] := SORT_DOWN_FILE;
	files[4] := SORT_UP_DOWN_FILE;
	files[5] := SORT_RANDOM_FILE;
	maxCats[1] := 10;
	maxCats[2] := 20;
	maxCats[3] := 50;
	maxCats[4] := 75;
	maxCats[5] := 100;
	writeln('Последовательность');
	for i := 1 to MAX_ACTIONS do begin
		writeln(i, ' - ', files[i]);
	end;
	sep := '-------------------------------------------------------------------------';
	writeln(fd, sep);
	writeln(fd, '| n     ', '|  параметр   | номер последовательности     | среднее значение |');
	write(fd, '|       ', '|             |');
	for i := 1 to MAX_ACTIONS do begin
		write(i:5);
	end;
	writeln(fd, '     |                  |');
	writeln(fd, sep);
	for i := 1 to MAX_ACTIONS do begin
		for j := 1 to MAX_ACTIONS do begin
			clearOpsCounter(opsCounters[j]);
			sort(files[j], maxCats[i], opsCounters[j]);
		end;
		write(fd, '| ', maxCats[i]:3, '   | сравнение   | ');
		mean := 0;
		for j := 1 to MAX_ACTIONS do begin
			write(fd, ' ', opsCounters[j].compareOps:4);
			Inc(mean, opsCounters[j].compareOps);
		end;
		mean := mean div MAX_ACTIONS;
		writeln(fd, '    |', mean:10, '        |');
		write(fd, '|       ', '| перемещение | ');
		mean := 0;
		for j := 1 to MAX_ACTIONS do begin
			write(fd, ' ', opsCounters[j].swapOps:4);
			Inc(mean, opsCounters[j].swapOps);
		end;
		mean := mean div MAX_ACTIONS;
		writeln(fd, '    |', mean:10, '        |');
		writeln(fd, sep);
	end;
end;

procedure writeHelp();
begin
	writeln('!!!Неверное количество аргументов!!!');
       	writeln('Варианты запуска:');
	writeln(#10, '(1) Печатает номера заданий. Номер студенческого опционален. Если не указан, то печатает задания по моему студенческому.');
	writeln(ParamStr(0), ' -tasks [номер студенческого или три его цифры]');
	writeln(#10, '(2) Генерит нужные файлы');
	writeln(ParamStr(0), ' -gen');
	writeln(#10, '(3) Запускает два алгоритма сортировки с N элементами. -demo опциональный параметр.');
	writeln(ParamStr(0), ' -sort <имя файла> -n <количество котов> [-demo 1|0]');
	writeln(#10, '(4) Генерит таблицу');
	writeln(ParamStr(0), ' -table');
	Halt;
end;

var studentIDStr: string;
maxCats, err: integer;
demo, studentID: integer;
begin
	randomize;
	if ((ParamCount() = 1) or (ParamCount() = 2)) and (ParamStr(1) = '-tasks') then
	begin
		if ParamCount() = 2 then
		begin
			studentIDStr := ParamStr(2);
			if Length(studentIDStr) < 3 then
			begin
				Writeln('Номер студенческого должен быть выше трёх цифр');
				Halt;
			end;
			{ берём три последнии цифры }
			studentIDStr := Copy(studentIDStr, Length(studentIDStr) - 2, 3);
			Val(studentIDStr, studentID, err);
			if err <> 0 then begin
				Writeln('Ошибка конвертации студенческого: ', ParamStr(2));
			end;
		end else
		begin
			studentID := LAST_3_DIGITS_STUDENT_NUMBER;
		end;
		writeProjectTasksNumers(studentID);
	end else if (ParamCount() = 1) and (ParamStr(1) = '-gen') then
	begin
		genFiles();
	end else if((ParamCount() = 4) or (ParamCount() = 6)) and (ParamStr(1) = '-sort') and (ParamStr(3) = '-n') then
	begin
		Val(ParamStr(4), maxCats, err);
		if err <> 0 then begin
			Writeln('Ошибка конвертации числа указанного в -n: ', err);
		end;
		if (ParamCount() = 6) and (ParamStr(6) = '1') then  begin
			demo := 1;
		end else begin
			demo := 0;
		end;
		sort(ParamStr(2), maxCats, demo);
	end else if (ParamCount() = 1) and (ParamStr(1) = '-table') then begin
		writeln('Таблица сортировки выбором');
		writeTable(stdout, @sortCatsSelection);
		writeln();
		writeln('Таблица сортировки простым слиянием');
		writeTable(stdout, @sortCatsSimpleMerge);
	end else writeHelp();
end.


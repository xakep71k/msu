{
Все методы сортировки.
}
const MAX_ELEMENTS = 10;
type
	ElementType = integer;
	ElementsVectorType = array[1..MAX_ELEMENTS] of ElementType;
	OperationsCounterType = record
		swapOps, compareOps :integer;
	end;
ElementsVectorTypePtr = ^ElementsVectorType;

procedure clearOpsCounter(var opsCounter :OperationsCounterType);
begin
	opsCounter.compareOps := 0;
	opsCounter.swapOps := 0;
end;

procedure printOpsCounter(var opsCounter :OperationsCounterType);
begin
	writeln('Число перестановок - ', opsCounter.swapOps, ', число сравнений - ', opsCounter.compareOps);
end;

function less(var x,y :ElementType):boolean;
begin
	less := x < y;
end;

function more(var x,y :ElementType):boolean;
begin
	more := x > y;
end;

procedure printElement(element :ElementType);
begin
	write(element:3);
end;

procedure printElementsVector(var arr :ElementsVectorType);
var i :integer;
begin
	for i := 1 to MAX_ELEMENTS do begin
		printElement(arr[i]);
		write(' ');
	end;
	writeln();
end;

procedure fillElementsVector(var arr:ElementsVectorType);
var i:integer;
begin
	for i := 1 to MAX_ELEMENTS do begin
		arr[i] := random(20 * 10);
		arr[i] := MAX_ELEMENTS - i;
	end;
end;

function getIndexMinElement(var arr :ElementsVectorType; starti, endi :integer; var opsCounters :OperationsCounterType): integer;
var i, minElementIndex :integer;
begin
	minElementIndex := starti;
	for i := starti to endi do begin
		opsCounters.compareOps := opsCounters.compareOps  + 1;
		if more(arr[minElementIndex], arr[i]) then begin
			minElementIndex := i;
		end;
	end;	
	getIndexMinElement := minElementIndex;
end;

procedure swapElements(var arr :ElementsVectorType; i, j :integer; var opsCounters :OperationsCounterType);
var tmp :ElementType;
begin
	tmp := arr[i];
	arr[i] := arr[j];
	arr[j] := tmp;
	opsCounters.swapOps := opsCounters.swapOps + 1;
end;

procedure sortBinaryInsertion(var arr :ElementsVectorType; var opsCounters :OperationsCounterType; demo :integer);
var i, j, middleIndex, insIndex :integer;
begin
	for i := 2 to MAX_ELEMENTS do begin
		middleIndex := i div 2;
		opsCounters.compareOps := opsCounters.compareOps  + 1;
		if less(arr[middleIndex], arr[i]) then begin
			insIndex := i;
			{ текущий элемент больше среднего, идём направо }
			for j := i - 1 downto middleIndex + 1 do begin { ищем место для текущего элемента в правой части }
				opsCounters.compareOps := opsCounters.compareOps + 1;
				if more(arr[j], arr[i]) then begin
					insIndex := j;
				end else break;
			end;
		end else begin
			insIndex := middleIndex;
			{ текущий элемент меньше среднего, идём налево }
			for j := middleIndex - 1 downto 1 do begin { ищем место для текущего элемента в левой части }
				opsCounters.compareOps := opsCounters.compareOps  + 1;
				if less(arr[i], arr[j]) then begin
					insIndex := j;
				end else break;
			end;
		end;
		{ ставим элемент в найденное место insIndex }
		for j := i downto insIndex + 1 do begin 
			swapElements(arr, j, j-1, opsCounters);
			if demo = 1 then begin
				printElementsVector(arr);
			end;
		end;
		if demo = 1 then begin
			writeln();
		end;
	end;
end;

procedure sortInsertion(var arr :ElementsVectorType; var opsCounters :OperationsCounterType; demo :integer);
var i, j, insIndex :integer;
begin
	for i := 2 to MAX_ELEMENTS do begin
		insIndex := i;
		for j := i - 1 downto 1 do begin
			opsCounters.compareOps := opsCounters.compareOps  + 1;
			if more(arr[j], arr[insIndex]) then begin
				swapElements(arr, j, insIndex, opsCounters);
				insIndex := j;
				if demo = 1 then begin
					printElementsVector(arr);
				end;
			end else break;
		end;
	end;
end;

procedure sortBubble(var arr :ElementsVectorType; var opsCounters :OperationsCounterType; demo :integer);
var i, j :integer;
begin
	for i:= 1 to MAX_ELEMENTS - 1 do begin
		for j := 1 to MAX_ELEMENTS - i do begin
			opsCounters.compareOps := opsCounters.compareOps  + 1;
			if more(arr[j], arr[j+1]) then begin
				swapElements(arr, j, j+1, opsCounters);
				if demo = 1 then begin
					printElementsVector(arr);
				end;
			end;
		end;
	end;
end;

procedure sortShuttle(var arr :ElementsVectorType; var opsCounters :OperationsCounterType; demo :integer);
var i, j, k, max :integer;
begin
	i := 2;
	while i <= MAX_ELEMENTS do begin
		for j := i to MAX_ELEMENTS do begin
			opsCounters.compareOps := opsCounters.compareOps  + 1;
			if more(arr[j-1], arr[j]) then begin
				for k := j downto 2 do begin { возвращаемcя обратно }
					opsCounters.compareOps := opsCounters.compareOps  + 1;
					if less(arr[k], arr[k-1]) then begin
						swapElements(arr, k, k-1, opsCounters);
						if demo = 1 then begin
							printElementsVector(arr);
						end;
					end else begin
						i := k - 1;
					end;
				end;
				break
			end;
		end;
		i := i + 1
	end;
end;

procedure sortSelection(var arr :ElementsVectorType; var opsCounters :OperationsCounterType; demo :integer);
var i, indexMinElement :integer;
begin
	for i := 1 to MAX_ELEMENTS-1 do begin
		indexMinElement := getIndexMinElement(arr, i, MAX_ELEMENTS, opsCounters);
		opsCounters.compareOps := opsCounters.compareOps  + 1;
		if (i <> indexMinElement) then begin
			swapElements(arr, indexMinElement, i, opsCounters);
			if demo = 1 then begin
				printElementsVector(arr);
			end;
		end;
	end;
end;

function findSortedSequenceFromEnd(var arr: ElementsVectorType; starti, endi: integer): integer;
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
		if more(arr[i - 1], arr[i]) then break;
		i := i - 1;
	end;
	findSortedSequenceFromEnd := i;
end;

function findSortedSequenceFromBegin(var arr: ElementsVectorType; starti, endi: integer): integer;
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
		if more(arr[i], arr[i + 1]) then break;
		i := i + 1;
	end;
	findSortedSequenceFromBegin := i;
end;

procedure merge(var arrTo: ElementsVectorType; starti1, endi1, starti2, endi2: integer; var arrFrom: ElementsVectorType; var i: integer);
begin
	writeln('-- index ', starti1, ' ', endi1, ' ', starti2, ' ', endi2);
	while (endi2 <= starti2) or (starti1 <= endi1) do
	begin
		if (endi2 > starti2) or less(arrFrom[starti1], arrFrom[endi2]) then
		begin
			arrTo[i] := arrFrom[starti1];
			starti1 := starti1 + 1;
		end else begin
			arrTo[i] := arrFrom[endi2];
			endi2 := endi2 + 1;
		end;
		i := i + 1;
	end;
end;

procedure sortMerge(
	var result: ElementsVectorTypePtr;
	var arr1, arr2: ElementsVectorType;
	maxCats: integer;
	var opsCounters: OperationsCounterType;
	demo: integer);
var starti1, starti2, endi1, endi2, currenti: integer;
arrHelper, ptrTmp: ElementsVectorTypePtr;
begin
	result := @arr1;
	arrHelper := @arr2;
	starti1 := 1;
	endi1 := maxCats;
	starti2 := maxCats;
	currenti := 1;
	while true do
	begin
		endi1 := findSortedSequenceFromBegin(result^, starti1, endi1);
		if endi1 >= maxCats then break;
		endi2 := findSortedSequenceFromEnd(result^, starti2, endi1);
		writeln('start merge');
		merge(arrHelper^, starti1, endi1, starti2, endi2, result^, currenti);
		starti1 := endi1 + 1;
		endi1 := endi2 - 1;
		starti2 := endi1;
		break;
	end;
	result := arrHelper;
end;

var
demo :integer;
elementsOrig, sortedElements :ElementsVectorType;
opsCounter :OperationsCounterType;
arr1, arr2: ElementsVectorType;
arrSortMerge: ElementsVectorTypePtr;
begin
	randomize;
	{write('Выберите демо режим, 1 - демо, 0 - нет: ');}
	demo := 0;
	{read(demo);}
	if (demo <> 1) and (demo <> 0) then begin
		writeln('Должно быть 0 или 1');
		exit
	end;
	write('ДЕМО РЕЖИМ ');
	if demo = 1 then
	begin
		writeln('ВКЛЮЧЁН');
	end else begin
		writeln('ВЫКЛЮЧЕН');
	end;
	fillElementsVector(elementsOrig);
	writeln('Всего элементов в массиве: ', MAX_ELEMENTS);

	writeln(#10, '=== (1) Сортировка слиянием ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	arr1 := elementsOrig;
	sortMerge(arrSortMerge, arr1, arr2, MAX_ELEMENTS, opsCounter, demo);
	printElementsVector(arrSortMerge^);

	exit;

	writeln(#10, '=== (1) Сортировка простыми вставками ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	sortedElements := elementsOrig;
	sortInsertion(sortedElements, opsCounter, demo);
	printElementsVector(sortedElements);
	printOpsCounter(opsCounter);

	writeln(#10, '=== (2) Сортировка бинарными вставками ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	sortedElements := elementsOrig;
	sortBinaryInsertion(sortedElements, opsCounter, demo);
	printElementsVector(sortedElements);
	printOpsCounter(opsCounter);

	writeln(#10, '=== (3) Сортировка методом пузырька ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	sortedElements := elementsOrig;
	sortBubble(sortedElements, opsCounter, demo);
	printElementsVector(sortedElements);
	printOpsCounter(opsCounter);

	writeln(#10, '=== (4) Сортировка челночная ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	sortedElements := elementsOrig;
	sortShuttle(sortedElements, opsCounter, demo);
	printElementsVector(sortedElements);
	printOpsCounter(opsCounter);

	writeln(#10, '=== (5) Сортировка простым выбором ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	sortedElements := elementsOrig;
	sortSelection(sortedElements, opsCounter, demo);
	printElementsVector(sortedElements);
	printOpsCounter(opsCounter);
end.



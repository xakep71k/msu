{
Все методы сортировки.
}
const MAX_ELEMENTS = 20;
type
	ElementType = integer;
	ElementsVectorType = array[1..MAX_ELEMENTS] of ElementType;
	OperationsCounterType = record
		swapOps, compareOps :integer;
	end;


procedure clearOpsCounter(var opsCounter :OperationsCounterType);
begin
	opsCounter.compareOps := 0;
	opsCounter.swapOps := 0;
end;

procedure printOpsCounter(var opsCounter :OperationsCounterType);
begin
	writeln('Число перестановок - ', opsCounter.swapOps, ', число сравнений - ', opsCounter.compareOps);
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
		arr[i] := MAX_ELEMENTS - i;
		arr[i] := random(20 * 10);
	end;
end;

function getIndexMinElement(var arr :ElementsVectorType; starti, endi :integer; var opsCounters :OperationsCounterType): integer;
var i, minElementIndex :integer;
begin
	minElementIndex := starti;
	for i := starti to endi do begin
		opsCounters.compareOps := opsCounters.compareOps  + 1;
		if arr[minElementIndex] > arr[i] then begin
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
		if demo = 1 then begin
			writeln('arr[', i, '] = ', arr[i]);
		end;
		if arr[middleIndex] < arr[i] then begin
			insIndex := i;
			{ текущий элемент больше среднего, идём направо }
			for j := i - 1 downto middleIndex + 1 do begin { ищем место для текущего элемента в правой части }
				opsCounters.compareOps := opsCounters.compareOps + 1;
				if arr[j] > arr[insIndex] then begin
					swapElements(arr, j, insIndex, opsCounters);
					insIndex := j;
					if demo = 1 then begin
						printElementsVector(arr);
					end;
				end else break;
			end;
		end else begin
			{ текущий элемент меньше среднего, идём налево }
			for j := i downto middleIndex + 1 do begin { двигаем текущий элемент за средний начания справа }
				swapElements(arr, j, j-1, opsCounters);
				if demo = 1 then begin
					printElementsVector(arr);
				end;
			end;
			insIndex := middleIndex;
			for j := middleIndex - 1 downto 1 do begin { ищем место для текущего элемента в левой части }
				opsCounters.compareOps := opsCounters.compareOps  + 1;
				if arr[insIndex] < arr[j] then begin
					swapElements(arr, j, insIndex, opsCounters);
					insIndex := j;
					if demo = 1 then begin
						printElementsVector(arr);
					end;
				end else break;
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
			if arr[j] > arr[insIndex] then begin
				swapElements(arr, j, insIndex, opsCounters);
				insIndex := j;
				if demo = 1 then begin
					printElementsVector(arr);
				end;
			end else break;
		end;
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

var
demo :integer;
elementsOrig, sortedElements :ElementsVectorType;
opsCounter :OperationsCounterType;
begin
	randomize;
	write('Выберите демо режим, 1 - демо, 0 - нет: ');
	read(demo);
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

	writeln(#10, '=== (5) Сортировка простым выбором ===');
	printElementsVector(elementsOrig); if demo = 1 then writeln();
	clearOpsCounter(opsCounter);
	sortedElements := elementsOrig;
	sortSelection(sortedElements, opsCounter, demo);
	printElementsVector(sortedElements);
	printOpsCounter(opsCounter);
end.

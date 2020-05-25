include console.inc

.data
PopulationNum db 1
IterationMaxNum dd 0
MutationChance db 10 ; в процентах
IterationCounter dd 0

; порядок A3 - A1 имеет значение, он используется в calcEquation
A3 db 1
A2 db 1
A1 db 1
D db ?

Float struc
	decimal db 0
	fract db 0
Float ends

Solution struc
	x1 db 0 
	x2 db 0
	x3 db 0
	score Float<>; значение целевой функции F_i
	chance Float<>; шанс распространить гены F_i/F_ср
Solution ends

PopulationMaxNum equ 10
solutions Solution PopulationMaxNum dup(<>); текущие решения
parentOffsets dd PopulationMaxNum dup(0); хранит смещения в массиве solutions - решений, которые будут родителями


;
; Временное хранилище частей генов при одноточечном скрещивании
;
x1LeftPart db PopulationMaxNum dup(0)
x1RightPart db PopulationMaxNum dup(0)
x2LeftPart db PopulationMaxNum dup(0)
x2RightPart db PopulationMaxNum dup(0)
x3LeftPart db PopulationMaxNum dup(0)
x3RightPart db PopulationMaxNum dup(0)

.code

; Переводит десятичное число во float делением на 100.
; В качестве параметра принимает указатель на float и десятичное число
convertDec2Float proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

decimalVal equ dword ptr[ebp+8]
floatPtr equ dword ptr[ebp+12]

	mov edx, 0
	mov eax, decimalVal
	mov ecx, 100
	div ecx
		
	mov ebx, floatPtr
	mov (Float ptr[ebx]).decimal, al
	mov (Float ptr[ebx]).fract, dl
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*2
convertDec2Float endp

; Переводит float в десятичное число умножением на 100.
; В качестве параметра принимает указатель на float, ответ возращает в eax
convertFloat2Dec proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
float1Ptr equ dword ptr[ebp+8]

	mov ebx, float1Ptr
	movzx ecx, (Float ptr[ebx]).decimal
	
	mov eax, 100
	mul ecx
	
	movzx ecx, (Float ptr[ebx]).fract
	add eax, ecx
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
convertFloat2Dec endp

; Делит два float и в первый параметр записывает результ.
; В качестве параметров ожидает два указателя на структуру Float
divFloat proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

float1Ptr equ dword ptr[ebp+8]
float2Ptr equ dword ptr[ebp+12]

	push float1Ptr
	call convertFloat2Dec
	mov ecx, 100
	mul ecx
	push eax

	push float2Ptr
	call convertFloat2Dec
	push eax

; делим float1/float2

	pop ecx
	pop eax
	mov edx, edx
	div ecx
	
	push float1Ptr
	push eax
	call convertDec2Float

	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*2
divFloat endp

; Делит float на десятичное число размером в байт.
; Принимает указатель на float и десятичное число. Результат записыват параметр float.
divFloatByDec proc
	push ebp
	mov ebp, esp
	sub esp, 4
	push eax
	push ebx
	push ecx
	push edx

decimalVal equ byte ptr[ebp+12]
floatPtr equ dword ptr[ebp+8]
tmpFloatPtr equ ebp-4

	mov bl, decimalVal
	lea eax, [tmpFloatPtr]

	mov (Float ptr[eax]).decimal, bl
	mov (Float ptr[eax]).fract, 0
	
	push eax
	push floatPtr
	call divFloat
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*2
divFloatByDec endp

; Складывает два Float и в первый параметр кладём результ.
; В качестве параметров ожидает два указателя на структуру Float
addFloat proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
float1Ptr equ dword ptr[ebp+8]
float2Ptr equ dword ptr[ebp+12]

	push float1Ptr
	call convertFloat2Dec
	push eax
	
	push float2Ptr
	call convertFloat2Dec
	pop ecx
	
	add eax, ecx
	
	push float1Ptr
	push eax
	call convertDec2Float
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	
	ret 4*2
addFloat endp

; вычисляет A1*x1 + A2*x2 + A3*x3  = D
; Возврат:
; ah - 0 - не было переполнения, иначе было переполнение и результат не верен
; al - результат D
calcEquation proc
	push ebp
	mov ebp, esp
	push ecx
	push ebx
	push edx

; проходим все x1 - x3 и A1 - A3 в цикле, умножая и складывая
	mov ecx, 3
	xor ebx, ebx
@calc:
	xor ax, ax
	mov al, byte ptr[offset A3 + ecx - 1]
	mul byte ptr[ebp + 4 + ecx*4]
	jo @overflow
	
	add bl, al
	jc @overflow
loop @calc
	mov al, bl
@overflow:
	mov ah, cl

	pop edx
	pop ebx
	pop ecx
	pop ebp
	ret 3*4
calcEquation endp

calcResidual proc
	push ebp
	mov ebp, esp
	push ecx
	push ebx
	push edx
	
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call calcEquation
	
	cmp ah, 0
	jne @answer_not_correct
	movzx ecx, al
	push ecx
	movzx ecx, D
	push ecx
	call subAbs
@answer_not_correct:
	
	pop edx
	pop ebx
	pop ecx
	pop ebp
	ret 3*4
calcResidual endp

printSolution proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

printOnlyX equ dword ptr[ebp+12]
solutionPtr equ ebp+8

	mov eax, [solutionPtr]
	movzx ecx, (Solution ptr[eax]).x3
	push ecx
	movzx ecx, (Solution ptr[eax]).x2
	push ecx
	movzx ecx, (Solution ptr[eax]).x1
	push ecx

	pop ecx
	outnum ecx,,03u, "x_1 = "
	pop ecx
	outnum ecx,,03u, " | x_2 = "
	pop ecx
	outnum ecx,,03u, " | x_3 = "
	
	mov ecx, printOnlyX
	cmp ecx, 0
	jne @skip
	outstr " | целевое значение = "
	
	mov eax, [solutionPtr]
	lea ebx, (Solution ptr [eax]).score
	push ebx
	call printFloat
	
	outstr " | скрещивание = "
	mov eax, [solutionPtr]
	lea ebx, (Solution ptr [eax]).chance
	push ebx
	call printFloat
	
	mov eax, [solutionPtr]
	movzx ecx, (Solution ptr[eax]).x1
	push ecx
	movzx ecx, (Solution ptr[eax]).x2
	push ecx
	movzx ecx, (Solution ptr[eax]).x3
	push ecx
	call calcResidual
	and ah, 1
	
	outstr " | невязка = "
	outnum al,,03u,
	outstr " | переполнение = "
	outnum ah,,u,
	
@skip:
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*2
printSolution endp

printSolutionln proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push [ebp+12]
	push [ebp+8]
	call printSolution
	newline
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*2
printSolutionln endp

printSolutions proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov ecx, [ebp+8]; size
	mov eax, [ebp+12]; pointer 
@repeat:
	push [ebp+16]
	push eax
	call printSolutionln
	add eax, sizeof Solution
loop @repeat

	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*3
printSolutions endp

printAllSolutions proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	
	push 0
	lea ebx, solutions
	push ebx
	movzx ebx, PopulationNum
	push ebx
	call printSolutions

	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printAllSolutions endp

printNewSolutions proc
		push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	
	push 1
	lea ebx, solutions
	push ebx
	movzx ebx, PopulationNum
	push ebx
	call printSolutions

	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printNewSolutions endp

printChosenParents proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	mov ebx, 0
	movzx ecx, PopulationNum
@repeat:
	mov eax, parentOffsets[ebx]
	cmp eax, 0
	je @continue
	push 0
	push eax
	call printSolutionln
	add ebx, 4
@continue:
	loop @repeat
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printChosenParents endp

printFloat proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	mov eax, [ebp+8]
	xor ecx, ecx
	mov cl, (Float ptr[eax]).fract
	push ecx
	
	xor ecx, ecx
	mov cl, (Float ptr[eax]).decimal
	push ecx
	
	pop ecx
	outnum ecx,,03u
	pop ecx
	outnum ecx,,02u, ","
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printFloat endp

printFloatln proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push [ebp+8]
	call printFloat
	newline
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printFloatln endp

;
; возвращает в eax 0 - если не найдено подходящих решение
; или адрес решения
IsAnswerReady proc
	push ebp
	mov ebp, esp
	push ecx
	push ebx
	push edx
	
	movzx ecx, PopulationNum
	lea ebx, solutions

; ah - 0 - не было переполнения, иначе было переполнение и результат не верен
; al - результат D

@repeat:
	movzx edx, (Solution ptr[ebx]).x1
	push edx
	movzx edx, (Solution ptr[ebx]).x2
	push edx
	movzx edx, (Solution ptr[ebx]).x3
	push edx
	call calcEquation
	movzx edx, al

	cmp ah, 0
	jne @continue
	cmp al, D
	mov eax, ebx
	je @stop
@continue:
	add ebx, sizeof Solution
	loop @repeat
	mov eax, 0
@stop:
	
	pop edx
	pop ebx
	pop ecx
	pop ebp
	ret
IsAnswerReady endp

; Функция вычитает из большего меньшее, что бы получилось не отрицательное значение
; Принимает два аргумента размером в байт.
; Результат в al
subAbs proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
val1 equ byte ptr[ebp+8]
val2 equ byte ptr[ebp+12]
	
	movzx eax, val1
	movzx ebx, val2
	
	cmp eax, ebx
	ja @sub
	xchg eax, ebx
@sub:
	sub eax, ebx
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4*2
subAbs endp

; Целевая функция. Определяет насколько решение близко к ответу и присваивает за это очки. Чем больше очков, тем ближе к ответу. Максимум 255.
; Принимает указатели на Solution в Solution score возвращает ответ.
calcFitnessScore proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

solutionPtr equ dword ptr[ebp+8]

	mov eax, solutionPtr
	movzx ebx, (Solution ptr[eax]).x1
	push ebx
	movzx ebx, (Solution ptr[eax]).x2
	push ebx
	movzx ebx, (Solution ptr[eax]).x3
	push ebx
	call calcResidual
	cmp ah, 0
	mov ecx, 255
	jne @answer_not_correct
	movzx ecx, al
@answer_not_correct:

; прибавляется единица, так как далее будет происходить деление, а на ноль делить нельзя
	cmp ecx, 255
	je @skip_inc
	inc ecx
@skip_inc:

	;outintln ecx,,"calcFitnessScore ecx = "

	mov ebx, solutionPtr
	lea ebx, (Solution ptr[ebx]).score
	
	mov (Float ptr[ebx]).decimal, 255
	mov (Float ptr[ebx]).fract, 0
	
	push ecx
	push ebx
	call divFloatByDec
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
calcFitnessScore endp

calcAllFitnessScore proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	movzx ecx, PopulationNum
	lea eax, solutions
@repeat:
	push eax
	call calcFitnessScore
	add eax, sizeof Solution
	loop @repeat
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
calcAllFitnessScore endp

; высчитывает среднее значение целевых значений.
; Принимает в качестве аргумента указатель куда будет записан ответ.
; Массив значений берёт отсюда solutions в глобальной переменной.
; А количество от сюда PopulationNum
calcFintessScoreAverage proc
	push ebp
	mov ebp, esp
	sub esp, 4
	push eax
	push ebx
	push ecx
	push edx
floatPtr equ ebp+8
tmpFloatPtr equ ebp-4
	
	movzx ecx, PopulationNum
	cmp ecx, 0
	je @end
	mov eax, [floatPtr]
	
	mov (Float ptr[eax]).decimal, 0
	mov (Float ptr[eax]).fract, 0
	
	mov ebx, offset solutions
@repeat:
	push ecx
	lea edx, (Solution ptr [ebx]).score
	add ebx, sizeof Solution
	
	lea eax, [tmpFloatPtr]
	
	mov ch, (Float ptr[edx]).decimal
	mov (Float ptr[eax]).decimal, ch
	mov ch, (Float ptr[edx]).fract
	mov (Float ptr[eax]).fract, ch
	
	movzx ecx, PopulationNum
	
	push ecx
	push eax
	call divFloatByDec
	
	mov edx, [floatPtr]
	push eax
	push edx
	call addFloat

	pop ecx
	loop @repeat
	
@end:
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
calcFintessScoreAverage endp

; Высчитвает шанс на распространение генов.
; Принимает F_ср типа указателя на Float.
; Записывает результат в solutions поле chance
calcChanceSpreadGens proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
floatPtr equ ebp+8

	movzx ecx, PopulationNum
	cmp ecx, 0
	je @end
	
	mov eax, [floatPtr]
	mov ebx, offset solutions

@repeat:
	push ecx
	lea edx, (Solution ptr [ebx]).chance
	lea ecx, (Solution ptr [ebx]).score
	add ebx, sizeof Solution

	push ebx
	mov bl, (Float ptr [ecx]).decimal
	mov (Float ptr [edx]).decimal, bl
	mov bl, (Float ptr [ecx]).fract
	mov (Float ptr [edx]).fract, bl
	pop ebx

	push eax
	push edx
	call divFloat
	
	pop ecx
	loop @repeat
	
@end:
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
calcChanceSpreadGens endp

printStr proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov eax, dword ptr[ebp+8]
	outstr eax
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printStr endp

printStrLn proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov eax, dword ptr[ebp+8]
	push eax
	call printStr
	newline
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printStrLn endp

printIntLn proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov eax, dword ptr[ebp+8]
	outintln eax
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printIntLn endp

printBits proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov al, byte ptr[ebp+8]
	outnum al,,b,
	add esp, 4; bugfix, outnum не возвращает стэк в исходное положение
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printBits endp

printBitsLn proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	push dword ptr[ebp+8]
	call printBits
	newline
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printBitsLn endp

printSpace proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	outstr " "
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printSpace endp

printGensX1 proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	movzx ecx, PopulationNum
	mov edx, 0
@repeat:
	mov ah, x1LeftPart[edx]
	mov al, x1RightPart[edx]
	
	movzx ebx, ah
	push ebx
	call printBits
	call printSpace
	
	movzx ebx, al
	push ebx
	call printBits
	call printSpace
	
	movzx ebx, al
	or bl, ah
	push ebx
	call printIntLn
	
	inc edx
	loop @repeat
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printGensX1 endp

;
; генерирует случайные числа в диапозоне [startVal; endVal]
; результат в eax
rand proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx

startVal equ dword ptr[ebp+12]
endVal equ dword ptr[ebp+8]

	mov eax, endVal
	sub eax, startVal
	inc eax
	
    invoke nrandom, eax
	
	add eax, startVal
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4*2
rand endp

; выбирает родителей будущих решений из массива solutions по полям chance
; и кладёт индексы будущих родителей в parentOffsets
chooseParents proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	
	movzx ecx, PopulationNum
	lea eax, solutions
	mov esi, 0
	mov edi, 0
;
; отбираем решения, где (F_i/F_ср) >= 1, то есть те, где decimal часть > 0
;
@repeat:
	push ecx

	lea edx, (Solution ptr [eax]).chance
	movzx ecx, (Float ptr [edx]).decimal
	cmp ecx, 0
	je @continue

	
@add_parent:
	mov parentOffsets[esi], eax
	add esi, 4
	inc edi
	loop @add_parent
	
@continue:
	add eax, sizeof Solution
	pop ecx
	loop @repeat
	
;
; отбираем решения, где fract часть > 0
;
	push ebp
	mov ebp, esp
	movzx ecx, PopulationNum
	lea eax, solutions
	mov edx, 0

@repeat_:
	lea ebx, (Solution ptr [eax]).chance
	movzx ebx, (Float ptr [ebx]).decimal
	lea ebx, (Solution ptr [eax]).chance
	movzx ebx, (Float ptr [ebx]).fract
	
	inc ebx
	add edx, ebx
	xchg ecx, ebx
	
@fill_array:
	push eax
	loop @fill_array
	
	mov ecx, ebx
	add eax, sizeof Solution
	loop @repeat_
	
; случайным образом выбираем родителя по его доле fract
	movzx ecx, PopulationNum
	sub ecx, edi
	jz @end
	
@_repeat:
	push 1
	push edx
	call rand
	push edx
	mov edx, 0
	mov edi, 4
	mul edi
	mov ebx, ebp
	sub ebx, eax
	mov ebx, [ebx]
	mov parentOffsets[esi], ebx
	add esi, 4
	pop edx
	loop @_repeat
@end:

	mov esp, ebp
	pop ebp

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
chooseParents endp

generateRandomMask proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
	push 1
	push 7
	call rand
	mov cl, al
	
	mov eax, 0
	mov al, -1
	shl al, cl
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret
generateRandomMask endp

; разделяет ген на две части
; по методу одноклеточного скрещивания
; пареметры: маска и ген (x1 или x2 или x3)
splitGen proc
	push ebp
	mov ebp, esp
maskX equ byte ptr[ebp+8]
gen equ byte ptr[ebp+12]
	push ebx
	push ecx
	push edx
	
	mov eax, 0
	mov ah, maskX
	mov al, ah
	not al
	and ah, gen
	and al, gen
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4*2
splitGen endp

; разделяет гены из хромосом, для дальнейшего скрещивания
splitGens proc
	push ebp
	mov ebp, esp
	sub esp, 4*3
maskX1 equ byte ptr[ebp-4]
maskX2 equ byte ptr[ebp-8]
maskX3 equ byte ptr[ebp-12]
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	call generateRandomMask
	mov maskX1, al
	call generateRandomMask
	mov maskX2, al
	call generateRandomMask
	mov maskX3, al
	
	movzx ecx, PopulationNum
	lea edx, parentOffsets
	mov esi, 0

@repeat:
	;
	; разделяем ген x1 по методу одноклеточного скрещивании
	;
	mov eax, [edx]
	movzx eax, (Solution ptr [eax]).x1
	push eax
	movzx eax, maskX1
	push eax
	call splitGen
	mov x1LeftPart[esi], ah
	mov x1RightPart[esi], al
	
	;
	; разделяем ген x2 по методу одноклеточного скрещивании
	;
	mov eax, [edx]
	movzx eax, (Solution ptr [eax]).x2
	push eax
	movzx eax, maskX2
	push eax
	call splitGen
	mov x2LeftPart[esi], ah
	mov x2RightPart[esi], al
	
	;
	; разделяем ген x3 по методу одноклеточного скрещивании
	;
	mov eax, [edx]
	movzx eax, (Solution ptr [eax]).x3
	push eax
	movzx eax, maskX3
	push eax
	call splitGen
	mov x3LeftPart[esi], ah
	mov x3RightPart[esi], al
	
	add edx, 4
	inc esi
	loop @repeat
		
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
splitGens endp

shuffleByteArray proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	
arrSize equ dword ptr[ebp+8]
arrPtr equ dword ptr[ebp+12]

	mov ecx, arrSize
	cmp ecx, 1
	jbe @end
	dec ecx
	
	mov esi, arrSize
	sub esi, 2 ; индекс на предпоследний элемент
	mov edx, arrPtr ; указатель на начало массива
	mov ebx, arrSize
	dec ebx
	add ebx, edx; ebx указатель на конец массива
@repeat:
	push ecx
	
	push 0
	push esi
	call rand
	add eax, edx
	mov cl, byte ptr[ebx]
	mov ch, byte ptr[eax]
	
	mov byte ptr[eax], cl
	mov byte ptr[ebx], ch
	dec ebx
	dec esi
	pop ecx
	loop @repeat
@end:

	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4*2
shuffleByteArray endp

shuffleGens proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	lea eax, x1LeftPart
	movzx ebx, PopulationNum
	push eax
	push ebx
	call shuffleByteArray
	
	lea eax, x1RightPart
	movzx ebx, PopulationNum
	push eax
	push ebx
	call shuffleByteArray
	
	lea eax, x2LeftPart
	movzx ebx, PopulationNum
	push eax
	push ebx
	call shuffleByteArray
	
	lea eax, x2RightPart
	movzx ebx, PopulationNum
	push eax
	push ebx
	call shuffleByteArray
	
	lea eax, x3LeftPart
	movzx ebx, PopulationNum
	push eax
	push ebx
	call shuffleByteArray
	
	lea eax, x3RightPart
	movzx ebx, PopulationNum
	push eax
	push ebx
	call shuffleByteArray

	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
shuffleGens endp

concatGenX proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
	mov edx, [ebp+8]; left gen
	mov ebx, [ebp+12]; right gen
	mov ecx, [ebp+16]; index
	
	add edx, ecx
	add ebx, ecx
	
	
	xor eax, eax
	mov al, byte ptr[edx]
	or al, byte ptr[ebx]
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4*3
concatGenX endp

concatGenX1 proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
	mov ecx, [ebp+8]; index
	lea eax, x1LeftPart
	lea ebx, x1RightPart
	
	push ecx
	push ebx
	push eax
	call concatGenX
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
concatGenX1 endp

concatGenX2 proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
	mov ecx, [ebp+8]; index
	lea eax, x2LeftPart
	lea ebx, x2RightPart
	
	push ecx
	push ebx
	push eax
	call concatGenX
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
concatGenX2 endp

concatGenX3 proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
	mov ecx, [ebp+8]; index
	lea eax, x3LeftPart
	lea ebx, x3RightPart
	
	push ecx
	push ebx
	push eax
	call concatGenX
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
concatGenX3 endp

xorBit proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx

digit equ byte ptr[ebp+8]
bitNumber equ byte ptr[ebp+12]

	xor eax, eax
	movzx ecx, bitNumber
	dec ecx
	mov ah, digit
	shr ah, cl
	mov dh, ah
	and dh, 1
	xor dh, 1
	shr ah, 1
	shl ah, 1
	or ah, dh
	shl ah, cl
	mov al, digit
	mov ecx, 9
	sub cl, bitNumber
	shl al, cl
	shr al, cl
	
	or al, ah
	mov ah, 0
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4*2
xorBit endp

mutateGen proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx

gen equ dword ptr[ebp+8]

	xor eax, eax
	push 1
	push 100
	call rand
	movzx ebx, MutationChance
	cmp eax, ebx
	mov eax, gen
	ja @skip_mutation

	push 1
	push 8
	call rand
	
	push eax
	push gen
	call xorBit
	
@skip_mutation:
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
mutateGen endp

bornNewSolutions proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	movzx ecx, PopulationNum
	mov eax, 0
	mov ebx, 0
	lea edx, solutions
@repeat:
	push ebx
	call concatGenX1
	push eax
	call mutateGen
	mov (Solution ptr [edx]).x1, al
	
	push ebx
	call concatGenX2
	push eax
	call mutateGen
	mov (Solution ptr [edx]).x2, al
	
	push ebx
	call concatGenX3
	push eax
	call mutateGen
	mov (Solution ptr [edx]).x3, al
	
	inc ebx
	add edx, sizeof Solution
	loop @repeat
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
bornNewSolutions endp

inputX proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
.data
fmt_x db "x%d ",0
.code
numberX equ dword ptr[ebp+8]

@repeat:
	outstr "введите "
	mov ebx, esp
	push numberX
	push offset fmt_x
	call crt_printf
	mov esp, ebx
	outstr "в диапозоне [0; 255]: "
	
	inint eax
	
	jc @repeat
	jz @repeat
	js @repeat
	
	cmp eax, 255
	ja @repeat
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
inputX endp

printIndividialTitle proc
.data
fmt_ind db "%d: ",10,0
.code
	outstr "решение "
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov ebx, esp
	push [ebp+8]
	push offset fmt_ind
	call crt_printf
	mov esp, ebx
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 4
printIndividialTitle endp

inputIndividuals proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	movzx ecx, PopulationNum
	lea ebx, solutions
	mov edx, 1

@repeat:
	push edx
	call printIndividialTitle
	
	push 1
	call inputX
	
	mov (Solution ptr[ebx]).x1, al
	
	push 2
	call inputX
	mov (Solution ptr[ebx]).x2, al
	
	push 3
	call inputX
	mov (Solution ptr[ebx]).x3, al
	
	add ebx, sizeof Solution
	inc edx
	loop @repeat

	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputIndividuals endp

inputPopulationNum proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
.data
fmt_popnum db "[4; %u]: ",0
.code
@repeat:
	
	outstr "введите количество решений в диапозоне "
	mov ebx, esp
	push PopulationMaxNum
	push offset fmt_popnum
	call crt_printf
	mov esp, ebx
	
	inint eax
	jc @repeat
	jz @repeat
	js @repeat
	
	cmp eax, PopulationMaxNum
	ja @repeat
	
	cmp eax, 4
	jb @repeat
	
	mov PopulationNum, al
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputPopulationNum endp

inputA proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
.data
fmt_a db "A%d ",0
.code
numberA equ dword ptr[ebp+8]

@repeat:
	outstr "введите "
	mov ebx, esp
	push numberA
	push offset fmt_a
	call crt_printf
	mov esp, ebx
	outstr "в диапозоне [0; 255]: "
	
	inint eax
	
	jc @repeat
	jz @repeat
	js @repeat
	
	cmp eax, 255
	ja @repeat
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
inputA endp

inputEquationParams proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	push 1
	call inputA
	mov A1, al
	
	push 2
	call inputA
	mov A2, al
	
	push 3
	call inputA
	mov A3, al
	
	call inputD
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputEquationParams endp

inputD proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

@repeat:
	outstr "введите D: "
	
	inint eax
	
	jc @repeat
	jz @repeat
	js @repeat
	
	cmp eax, 255
	ja @repeat
	
	mov D, al
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputD endp

generateRandomInput proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov IterationMaxNum, -1
	
	mov A1, 1
	mov A2, 1
	mov A3, 1
	
	push 0
	push 255
	call rand
	mov D, al
	
	push 4
	push 10
	call rand
	mov PopulationNum, al
	
	push 10
	push 100
	call rand
	mov MutationChance, al
	
	movzx ecx, PopulationNum
	lea ebx, solutions

@repeat:
	push 1
	push 255
	call rand
	mov (Solution ptr[ebx]).x1, al
	
	push 1
	push 255
	call rand
	mov (Solution ptr[ebx]).x2, al
	
	push 1
	push 255
	call rand
	mov (Solution ptr[ebx]).x3, al
	
	add ebx, sizeof Solution
	loop @repeat
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
generateRandomInput endp

printStrEquatation proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	outnum A1,,u,
	outstr "*x_1 + "
	outnum A2,,u,
	outstr "*x_2 + "
	outnum A3,,u,
	outstr "*x_3 = "
	outnum D,,u,
	newline
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printStrEquatation endp


pressAnyKey proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	ReadKey
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
pressAnyKey endp

inputMutation proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
@repeat:
	outstr "введите шанс мутации в % [0; 100]: "
	inint eax
	
	jc @repeat
	jz @repeat
	js @repeat
	
	cmp eax, 100
	ja @repeat
	
	mov MutationChance, al
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputMutation endp

inputIterationMax proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
@repeat:
	outstr "введите максимальное число итераций [1; 4294967295]: "
	inint eax
	
	jc @repeat
	jz @repeat
	js @repeat
	cmp eax, 0
	je @repeat
	
	mov IterationMaxNum, eax
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputIterationMax endp

inputManaulAllParams proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	call inputPopulationNum
	call inputEquationParams
	call inputMutation
	call inputIndividuals
	call inputIterationMax
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
inputManaulAllParams endp

printAllParams proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	outnumln PopulationNum,,u,"количество решений: "
	outnumln MutationChance,,u,"шанс мутации в %: "
	call printNewSolutions
	call printStrEquatation
	outnumln IterationMaxNum,,u,"максимальное количество итераций: "
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
printAllParams endp

inManualOrRandom proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	
@repeat:
	outstr "ручной ввод параметров - 0, случайные параметры - 1: "
	inint eax
	jc @repeat
	jz @repeat
	js @repeat
	cmp eax, 1
	ja @repeat
	
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret
inManualOrRandom endp

initPopulation proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	call inManualOrRandom
	cmp eax, 0
	je @manual
	jmp @random_
	
@random_:
	call generateRandomInput
	jmp @end
@manual:
	call inputManaulAllParams
@end:
	call printAllParams
	outstr "что бы продолжить нажмите любую клавишу ..."
	call pressAnyKey
	newline
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
initPopulation endp

.data
averageFloatPtr Float<>

.code
start:
	;
	; Инициализируем начальное значение случайного числа текущим временем
	;
	rdtsc
	invoke nseed, eax
	
	lea ebx, [averageFloatPtr]

	call initPopulation
	
	call IsAnswerReady
	cmp eax, 0
	jne @solution_found

.data
curSolTitle db "текущие решения:",0
newSolTitle db "новые решения:",0
.code
@repeat:
	mov edx, IterationCounter
	cmp edx, IterationMaxNum
	jae @solution_not_found
	
	inc IterationCounter
	
	call calcAllFitnessScore
	push ebx
	call calcFintessScoreAverage
	
	push ebx
	call calcChanceSpreadGens
	call chooseParents
	call splitGens
	call shuffleGens
	
	push offset curSolTitle
	call printStrLn
	call printAllSolutions
	
	call bornNewSolutions
	
	push offset newSolTitle
	call printStrLn
	call printNewSolutions
	
	call IsAnswerReady
	cmp eax, 0
	jne @solution_found

	loop @repeat
@solution_not_found:

	outstrln "нет подходящих решений"
	call printStrEquatation
	movzx eax, D
	outintln eax,,"D = "
	exit

@solution_found:
	outstrln "решение найдено!"
	call printStrEquatation
	push 1
	push eax
	call printSolutionln
	movzx eax, D
	outintln eax,,"D = "
	outintln IterationCounter,,"пройдено количество итераций = "
	exit
end start

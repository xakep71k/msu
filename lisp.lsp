; http://recyclebin.ru/BMK/LISP/PosobieLisp.pdf
; https://rextester.com/l/common_lisp_online_compiler

; стр 59 (1)
; Составить функцию (RemoveLast L), удаляющую из списка последний элемент.
; Например: (RemoveLast '(A (S D) E (Q))) => (A (S D) E)
(defun RemoveLast (L)
    (reverse (cdr (reverse L))))

(print (RemoveLast '(a b c)))
(print (RemoveLast '(A (S D) E (Q))))

; стр 59 (2)
; Определить функцию-предикат (OneLevel L), которая проверяет, является ли список-аргумент одноуровневым списком:
; (OneLevel '(A B C)) => T,(OneLevel '((A) B C)) => NIL
(defun OneLevel (L)
    (cond
        ((eq L NIL) T)
        ((atom (car L)) (OneLevel (cdr L)))
        (T NIL)
    )
)

(print (OneLevel '(a b c)))
(print (OneLevel '(a b (c))))

; стр 59 (3)
; Запрограммировать функцию (Bubl N A) с двумя вычисляемыми аргументами – числом N и атомом A.
; Функция строит списокглубины N; на самом глубоком уровне элементом списка является A,
; а на любом другом уровне список состоит из одного элемента. Например:(Bubl 3 5)=>(((5))).
(defun Bubl (a b)
    (cond
        ((<= a 0) b)
        (T (Bubl (- a 1) (list b)))
    )
)

(print (Bubl 3 5))

; стр 59 (4)
; Определить функцию (LastAtom L), выбирающую последний от начала списка (невзирая на скобки)
; атом списка: (LastAtom '(((5) A))) => A
(defun LastAtom (L)
    (cond
        ((atom L) L)
        ((cdr L) (LastAtom (cdr L)))
        (T (LastAtom (car L)))
    )
)

(print (LastAtom '(((A)) (B))))
(print (LastAtom '(((5) A))))

; стр 61 (1)
; Определить функцию (Depth L), вычисляющую глубину списка L,
; т.е. максимальное количество уровней в нём. Например:
; (Depth '(((A (5) 8) B (K))(G (C)))) => 4
(defun Depth (L)
    (cond
        ((atom L) 0)
        (T (let ((x (+ 1 (Depth (car L)))) (y (Depth (cdr L))))
               (cond 
                   ((< x y) y)
                   (T x)
               )
           )
        )
    )
)

(print (Depth '(C (B) ((A))) ))
(print (Depth '(((A (5) 8) B (K))(G (C)))))

; стр 61 (2)
; Составить функцию (MySubst A L E), заменяющуюв произвольном списочном выражении L на всех его уровнях все вхождения атома А на выражение Е.
; Например: (MySubst 'Q '(Q (B (Q)) C ((Q) 8))) '(A Z)) => ((A Z) (B ((A Z))) C (((A Z)) 8)
(defun MySubst (A L E)
    (cond 
        ((equal A L) E)
        ((atom L) L)
        (T (let ((x (MySubst A (car L) E)) (y (MySubst A (cdr L) E)))
               (append (list x) y)
           )
        )
    )
)

(print (MySubst '(NIL) '((NIL) D) 'C))
(print (MySubst 'Q '(Q (B (Q)) C ((Q) 8)) '(A Z)))

; стр 61 (3)
; Определить функцию-предикат (OnlyZ L), которая вырабатывает Т в том случае, если в списке L
; на всех его уровнях встречается только атом Z, иначе вырабатывает NIL.
; Например: (OnlyZ '((Z (Z ()) Z) () Z) )=> T, (OnlyZ '((Z (Z ()) 8) () Z))=> NIL.
(defun OnlyZ (L)
    (cond
        ((equal 'Z L) T)
        ((atom L) NIL)
        (T (let ((x (car L)) (y (cdr L)))
               (cond
                   ((null x) (OnlyZ y))
                   ((and y (not (equal '(NIL) y))) (and (OnlyZ x) (OnlyZ y)))
                   (T (OnlyZ x))
               )
           )
        )
    )
)

(print (OnlyZ '((Z (Z ()) Z) () Z)))
(print (OnlyZ '((Z (Z ()) 8) () Z)))

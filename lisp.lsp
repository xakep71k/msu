; Составить функцию (RemoveLast L),  удаляющую  из  списка последний элемент.
; Например:  (RemoveLast '(A (S D) E (Q))) => (A (S D) E
(defun RemoveLast (L)
    (reverse (cdr (reverse L))))

(print (RemoveLast '(a b c)))

; Определить  функцию-предикат (OneLevel L), которая  проверяет, является ли список-аргумент одноуровневым списком:
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

; Запрограммироватьфункцию (Bubl N A) с двумя вычисляемыми аргументами – числом N и атомом A.
; Функция строит списокглубины N; на самом глубоком уровне элементом списка является A,
; а на любом другом уровне список состоит из одного элемента. Например:(Bubl 3 5)=>(((5))).
(defun Bubl (a b)
    (cond
        ((<= a 0) b)
        (T (Bubl (- a 1) (list b)))
    )
)

(print (Bubl 3 5))

; Определить  функцию (LastAtom L), выбирающую последний от начала списка (невзирая на скобки)
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

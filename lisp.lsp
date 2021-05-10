; пособие http://recyclebin.ru/BMK/LISP/PosobieLisp.pdf
; онлайн компилятор https://rextester.com/l/common_lisp_online_compiler

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
     (let ((x (OnlyZ_ L)))
         (cond
             ((equal x '(NIL)) NIL)
             (T x)
         )
     )
)

(defun OnlyZ_ (L)
    (cond
        ((equal 'Z L) T)
        ((atom L) NIL)
        (T (let ((x (car L)) (y (cdr L)))
                   (cond
                       ((and (null x) (null y)) '(NIL))
                       ((null x) (OnlyZ_ y))
                       ((null y) (OnlyZ_ x))
                       (T (let ((a (OnlyZ_ x)) (b (OnlyZ_ y)))
                               (cond
                                   ((and (equal T a) (equal '(NIL) b)) T)
                                   ((and (equal '(NIL) a) (equal T b)) T)
                                   ((and a b) T)
                                   (T NIL)
                               )
                          )
                       )
                   )
               )
        )
    )
)

(print (OnlyZ '(() () (())) ))
(print (OnlyZ '(Z (())) ))
(print (OnlyZ '(Z 9)))
(print (OnlyZ '((Z ((())) Z) () Z)))
(print (OnlyZ '((Z (Z ()) Z) () Z)))
(print (OnlyZ '((Z (Z ()) 8) () Z)))

; упрощение выражений (c операциями +,-,/,*). 
; Выражение a+b+b*(c+0)*b+(b+f)*0
; можно представить лисповским списком:
; (+ a b (* b (+ c 0) b) (*(+ b f ) 0) )
; Нужно написать функцию (возможно с вспомогательными функциями) simplify,  которая упрощает выражение. Например, исходному выражению будет эквивалентно
; a+b+b*c*b , что на Лиспе выглядит как
; (+ a b (* b  c  b) )
(defun skipSumSubZero (L1 L2)
    (cond
        ((null L2) L1)
        (T (let ((item (car L2)) (tail (cdr L2)))
             (cond
                 ((equal item '0) (skipSumSubZero L1 tail))
                 ((atom item) (skipSumSubZero (append L1 (list item)) tail))
                 (T (let ((expr (CalcExpr item)))
                     (cond
                         ((null expr) L1)
                         ((equal expr 0) (skipSumSubZero L1 tail))
                         (T (skipSumSubZero (append L1 (list expr)) tail))
                     )
                 ))
             )
        ))
    )
)

(defun skipMulZero (L1 L2)
    (cond
        ((null L2) L1)
        (T (let ((item (car L2)) (tail (cdr L2)))
             (cond
                 ((equal item '0) NIL)
                 ((atom item) (skipMulZero (append L1 (list item)) tail))
                 (T (let ((expr (CalcExpr item)))
                     (cond
                         ((null expr) L1)
                         ((equal expr 0) NIL)
                         (T (skipMulZero (append L1 (list expr)) tail))
                     )
                 ))
             )
        ))
    )
)

(defun SimplifyExpr (L)
    (let ((sign (car L)) (expr (cdr L)))
         (cond
             ((or (equal sign '+) (equal sign '-))
                 (let ((result (skipSumSubZero () expr)))
                      (cond
                          ((<= (length L) 1) (error "Выражение должно сождерать более одного символа"))
                          ((atom result) result)
                          (T (append (list sign) result))
                      )
                 )
             )
             ((equal sign '*)
                 (let ((result (skipMulZero () expr)))
                      (cond
                          ((<= (length L) 2) (error "Выражение должно сождерать более двух символов"))
                          ((atom result) result)
                          (T (append (list sign) result))
                      )
                 )
             )
         )
    )
)

(defun RedundantBrackets (L1 L2)
    (cond
        ((null L2) L1)
        (T (let ((item (car L2)) (tail (cdr L2)))
                (cond
                    ((and (null L1) (equal (length tail) 1))
                        (cond
                            ((equal item '-)
                                (cond
                                    ((atom (car tail)) L2)
                                    (T (append L1 (append (list item) (RedundantBrackets () (car tail)))))
                                )
                            )
                            (T
                                (cond
                                    ((atom (car tail)) (car tail))
                                    (T (RedundantBrackets () (car tail)))
                                )
                            )
                        )
                    )
                    ((atom item) (RedundantBrackets (append L1 (list item)) tail))
                    (T (RedundantBrackets (append L1 (list (RedundantBrackets () item))) tail))
                )
            )
        )
    )
)

(defun CalcExpr (L)
    (let ((expr (RedundantBrackets () (SimplifyExpr L))))
        (cond
            ((null expr) 0)
            (T expr)
        )
    )
)

(print (CalcExpr '(+ 0 0)))
(print (CalcExpr '(+ 0 (- 0 a))))
(print (calcExpr '(+ a b (* b (+ c 0) b) (*(+ b f ) 0) )))
(print (CalcExpr '(* a (+ 0 (* 0 b) c))))
(print (CalcExpr '(* (+ c 0) b) ))
;(print (CalcExpr '(* a)))


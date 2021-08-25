package mylang

import (
	"mylang/internal/app/mylang/lex"
)

type _Parser struct {
	poliz   []_Lex
	deepS   int
	cType   lex.Type
	curLex  _Lex
	cVal    int
	cStrVal string
	scanner <-chan _Lex
	stInt   IntStack
	stLex   TypeLexStack
}

func MakeParser(filename string) _Parser {
	return _Parser{
		scanner: MakeScanner(filename),
		stInt:   make(IntStack, 0),
		stLex:   make(TypeLexStack, 0),
	}
}

func (p *_Parser) analyze() []_Lex {
	p.nextLex()
	p.Program()
	if p.cType != lex.FIN {
		fatalError("FIN expected but found %v %v", p.cType, p.cStrVal)
	}
	return p.poliz
}

func (p *_Parser) nextLex() {
	curLex, eof := <-p.scanner
	if !eof {
		fatalError("unexpected EOF during parsing")
	}
	p.curLex = curLex
	p.cType = curLex.Type()
	p.cVal = curLex.Value()
	p.cStrVal = curLex.StrValue()
}

func (p *_Parser) Program() {
	if p.cType != lex.PROGRAM {
		fatalError("not program lex: %v %v", p.cType, p.cStrVal)
	}

	indexMainLabel := len(p.poliz)
	p.poliz = append(p.poliz, _MakeDefaultLex())
	p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_GO, 0, "go to main"))

	p.nextLex()
	for p.cType == lex.FUNCTION {
		p.FuncExtract()
		if p.cType != lex.SEMICOLON {
			fatalError("not semicolon lex: %v", p.cType)
		}
		p.nextLex()
	}

	// тут объявления переменных
	p.poliz[indexMainLabel] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "main label")
	if p.cType == lex.VAR {
		p.VarDeclaration()
		if p.cType != lex.SEMICOLON {
			fatalError("not semicolon lex: %v", p.cType)
		}
		p.nextLex()
	}

	// логика программы
	p.B()
}

func (p *_Parser) VarDeclaration() int {
	countsVar := 0
	if p.cType != lex.VAR {
		fatalError("not var lex: %v", p.cType)
	}

	p.nextLex()
	countsVar += p.VarExtract()

	for p.cType == lex.COMMA {
		p.nextLex()
		countsVar += p.VarExtract()
	}
	return countsVar
}

func (p *_Parser) VarExtract() int {
	countVars := 1
	if p.cType != lex.ID {
		fatalError("not ID lex: %v", p.cType)
	}
	p.stInt.Push(p.cVal)
	p.nextLex()

	for p.cType == lex.COMMA {
		countVars++
		p.nextLex()
		if p.cType != lex.ID {
			fatalError("not ID lex: %v", p.cType)
		}
		p.stInt.Push(p.cVal)
		p.nextLex()
	}

	if p.cType != lex.COLON {
		fatalError("not COLON1 lex: %v %v", p.cType, p.cStrVal)
	}
	p.nextLex()

	if p.cType == lex.INT {
		p.dec(lex.INT)
		p.nextLex()
	} else if p.cType == lex.BOOL {
		p.dec(lex.BOOL)
		p.nextLex()
	} else {
		fatalError("unknown type lex1: %v", p.cType, p.cStrVal)
	}

	return countVars
}

// FuncExtract = W
// W -> function (var D, {D}): [int | bool] B
func (p *_Parser) FuncExtract() {
	p.nextLex()
	if p.cType != lex.ID {
		fatalError("not ID lex: %v", p.cType)
	}

	identFunc := TID.PopBack()
	if TID.DeclareFunc(*identFunc, len(p.poliz)) {
		fatalError("function already exists: %v", identFunc.Name())
	}

	TID.PushFunc(identFunc.Name())
	ifunc := TID.TopFunc()
	p.nextLex()

	if p.cType != lex.LPAREN {
		fatalError("not LPARENT: %v", p.cType)
	}

	// параметры функции
	p.nextLex()
	varsCount := 0
	if p.cType != lex.RPAREN {
		varsCount = p.VarDeclaration()
		if p.cType != lex.RPAREN {
			fatalError("not RPAREN: %v", p.cType)
		}
	}

	for i := TID.Size() - 1; i >= TID.Size()-varsCount; i-- {
		ifunc.pushArg(TID.ICurTID(i))
		p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_ADDRESS, i, "addr func arg"))
		p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_INIT_FUNC_ARG, 0, "init func arg"))
	}
	p.nextLex()

	if p.cType != lex.COLON {
		fatalError("not COLON2 lex: %v %v", p.cType, p.cStrVal)
	}

	p.nextLex()
	if p.cType != lex.BOOL && p.cType != lex.INT {
		fatalError("not BOOL && not INT: %v", p.cType)
	}

	ifunc.setReturnLex(p.curLex)
	p.FuncDeclareRetVar(ifunc)

	p.nextLex()
	if p.cType == lex.VAR {
		p.VarDeclaration()
		if p.cType != lex.SEMICOLON {
			fatalError("not SEMICOLON: %v", p.cType)
		}
		p.nextLex()
	}

	p.B()
	p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_RETURN_FUNC, 0, "return from function"))
	TID.PopFunc()
}

func (p *_Parser) FuncDeclareRetVar(ifunc *_IdentFunc) {
	index := putIdent(ifunc.Name())
	TID.ICurTID(index).SetRet()
	p.stInt = append(p.stInt, index)
	p.dec(ifunc.ReturnLex().Type())
	ifunc.setReturnVar(index)
	p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_ADDRESS, index, ""))
}

func (p *_Parser) B() {
	if p.cType == lex.BEGIN {
		p.nextLex()
		p.deepS = 0
		p.S()
		for p.cType == lex.SEMICOLON {
			p.deepS = 0
			p.nextLex()
			p.S()
		}
		if p.cType == lex.END {
			p.nextLex()
		} else {
			fatalError("not END: %v", p.cType)
		}

		return
	}

	fatalError("not BEGIN: %v %v", p.cType, p.cStrVal)
}

// логические конструкции
func (p *_Parser) S() {
	var pl0, pl1, pl2, pl3 int
	p.deepS++

	if p.cType == lex.IF {
		p.nextLex()
		p.E()
		p.eq_bool()
		pl2 = len(p.poliz)
		p.poliz = append(p.poliz, _MakeDefaultLex())
		p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_FGO, 0, "POLIZ_FGO"))
		if p.cType != lex.THEN {
			fatalError("not THEN: %v", p.cType)
		}
		p.nextLex()
		p.S()

		pl3 = len(p.poliz)
		p.poliz = append(p.poliz, _MakeDefaultLex())
		p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_GO, 0, "POLIZ_GO"))

		if p.cType == lex.ELSE {
			p.poliz[pl2] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "POLIZ_LABEL")
			p.nextLex()
			p.S()
		} else {
			p.poliz[pl2] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "POLIZ_LABEL")
		}
		p.poliz[pl3] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "POLIZ_LABEL")
	} else if p.cType == lex.CASE {
		p.case_of()
	} else if p.cType == lex.WHILE {
		pl0 = len(p.poliz)
		p.nextLex()
		p.E()
		p.eq_bool()
		pl1 = len(p.poliz)
		p.poliz = append(p.poliz, _MakeDefaultLex())
		p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_FGO, 0, ""))
		if p.cType == lex.DO {
			p.nextLex()
			p.S()
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_LABEL, pl0, ""))
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_GO, 0, ""))
			p.poliz[pl1] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "")
		} else {
			fatalError("unknown type lex2: %v", p.cType, p.cStrVal)
		}
	} else if p.cType == lex.READ {
		p.nextLex()
		if p.cType == lex.LPAREN {
			p.nextLex()
			if p.cType == lex.ID {
				p.check_id_in_read()
				p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_ADDRESS, p.cVal, p.cStrVal))
				p.nextLex()
			} else {
				fatalError("not ID: %v", p.cType)
			}

			if p.cType == lex.RPAREN {
				p.nextLex()
				p.poliz = append(p.poliz, _MakeLex(lex.READ, 0, ""))
			} else {
				fatalError("not RPAREN: %v", p.cType)
			}
		} else {
			fatalError("not LPAREN: %v", p.cType)
		}
	} else if p.cType == lex.WRITE || p.cType == lex.WRITELN {
		lexWrite := p.cType
		p.nextLex()
		if p.cType != lex.LPAREN {
			fatalError("not LPAREN: %v", p.cType)
		}
		p.nextLex()
		p.E()
		if p.cType != lex.RPAREN {
			fatalError("not RPAREN: %v", p.cType)
		}
		p.nextLex()
		p.poliz = append(p.poliz, _MakeLex(lexWrite, 0, ""))
	} else if p.cType == lex.ID {
		oldCVal := p.cVal
		oldCStrVal := p.cStrVal
		funcIdent := TID.FindFunc(oldCStrVal)
		p.nextLex()
		if funcIdent != nil && funcIdent.Type() == lex.FUNCTION && p.cType == lex.LPAREN {
			p.callFunc(oldCStrVal)
		} else {
			p.check_id(oldCVal)
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_ADDRESS, oldCVal, "POLIZ_ADDRESS"))
			if p.cType != lex.ASSIGN {
				fatalError("not ASSIGN: %v", p.cType)
			}
			p.nextLex()
			p.E()
			p.eq_type()
			p.poliz = append(p.poliz, _MakeLex(lex.ASSIGN, 0, "LEX_ASSING"))
		}
	} else {
		p.B()
	}
}

func (p *_Parser) callFunc(funcName string) {
	if p.deepS == 1 {
		fatalError("return value of function %s() not used", funcName)
	}

	ifunc := TID.FindFunc(funcName)
	if ifunc == nil || ifunc.Type() != lex.FUNCTION {
		fatalError("function not declared: %s", funcName)
	}

	p.nextLex()
	rparent_found := false
	returnIndexLabel := len(p.poliz)
	p.poliz = append(p.poliz, _MakeDefaultLex())
	if ifunc.sizeArgs() != 0 {
		i := ifunc.sizeArgs() - 1
		for ; !rparent_found && i >= 0; i-- {
			p.E()
			t := p.stLex.Pop()
			if ifunc.IArgs(i).Type() != t {
				fatalError("wrong type of arg")
			}
			rparent_found = p.cType == lex.RPAREN
			p.nextLex()
		}
		if i >= 0 || !rparent_found {
			fatalError("wrong number of args in function '%v'", ifunc.Name())
		}
	} else {
		if p.cType != lex.RPAREN {
			fatalError("not RPARENT: %v", p.cType)
		}
		p.nextLex()
	}

	p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_CALL_FUNC, ifunc.Value(), ifunc.Name()))
	p.poliz[returnIndexLabel] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "return label")
}

func (p *_Parser) E() {
	p.deepS++
	p.E1()
	if p.cType == lex.EQ || p.cType == lex.LSS || p.cType == lex.GTR || p.cType == lex.LEQ || p.cType == lex.GEQ || p.cType == lex.NEQ {
		p.stLex = append(p.stLex, p.cType)
		p.nextLex()
		p.E1()
		p.check_op()
	}
}

func (p *_Parser) E1() {
	p.T()
	for p.cType == lex.PLUS || p.cType == lex.MINUS || p.cType == lex.OR {
		p.stLex = append(p.stLex, p.cType)
		p.nextLex()
		p.T()
		p.check_op()
	}
}

func (p *_Parser) T() {
	p.F()
	for p.cType == lex.TIMES || p.cType == lex.SLASH || p.cType == lex.AND {
		p.stLex = append(p.stLex, p.cType)
		p.nextLex()
		p.F()
		p.check_op()
	}
}

func (p *_Parser) F() {
	if p.cType == lex.ID {
		identFunc := TID.FindFunc(p.cStrVal)
		if identFunc != nil && identFunc.Type() == lex.FUNCTION {
			funcName := p.cStrVal
			p.nextLex()
			if p.cType != lex.LPAREN {
				fatalError("not LPAREN: %v", p.cType)
			}
			p.callFunc(funcName)
			p.stLex.Push(TID.FindFunc(funcName).ReturnLex().Type())
		} else {
			p.check_id(p.cVal)
			p.poliz = append(p.poliz, _MakeLex(lex.ID, p.cVal, "LEX_ID F()"))
			p.nextLex()
		}
	} else if p.cType == lex.NUM {
		p.stLex = append(p.stLex, lex.INT)
		p.poliz = append(p.poliz, p.curLex)
		p.nextLex()
	} else if p.cType == lex.TRUE {
		p.stLex = append(p.stLex, lex.BOOL)
		p.poliz = append(p.poliz, _MakeLex(lex.TRUE, 1, "true"))
		p.nextLex()
	} else if p.cType == lex.FALSE {
		p.stLex = append(p.stLex, lex.BOOL)
		p.poliz = append(p.poliz, _MakeLex(lex.FALSE, 1, "false"))
		p.nextLex()
	} else if p.cType == lex.NOT {
		p.nextLex()
		p.F()
		p.check_not()
	} else if p.cType == lex.LPAREN {
		p.nextLex()
		p.E()
		if p.cType == lex.RPAREN {
			p.nextLex()
		} else {
			fatalError("not RPARENT: %v\n", p.cType)
		}
	} else {
		fatalError("unknown type lex3: %v", p.cType, p.cStrVal)
	}
}

func (p *_Parser) dec(ltype lex.Type) {

	for len(p.stInt) != 0 {
		i := p.stInt.Pop()
		if TID.ICurTID(i).Declare() {
			fatalError("twice")
		}
		TID.ICurTID(i).PutDeclare()
		TID.ICurTID(i).putType(ltype)
	}
}

func (p *_Parser) check_const_case_type(caseType lex.Type) {
	if caseType == lex.BOOL {
		switch p.cType {
		case lex.FALSE, lex.TRUE:
		default:
			fatalError("wrong const type of case: must be true/false: %v", p.cType)
		}
	} else if caseType == lex.INT {
		switch p.cType {
		case lex.NUM:
		default:
			fatalError("wrong const type of case: must be num: %v", p.cType)
		}
	} else {
		fatalError("wrong case type: %v", p.cType)
	}
}

func (p *_Parser) get_case_val() int {
	switch p.cType {
	case lex.TRUE:
		return 1
	case lex.FALSE:
		return 0
	default:
		return p.cVal
	}
}

func (p *_Parser) case_of() {
	var labels IntStack
	consts := make(map[int]bool)

	// забираем выражение внутри скобок case(<выражение>)
	p.nextLex()
	p.E()

	if p.cType == lex.OF {
		// все константы дожны быть одного типа с выражением case(<выражение>)
		caseType := p.stLex.Top()
		p.nextLex()
		for {
			constLexes := make([]_Lex, 0)
			// забираем все константы, разделённые запятой, одной ветки до знака :
			for {
				p.check_const_case_type(caseType)

				// проверяем была ли константа уже упомянута
				if _, found := consts[p.cVal]; found {
					fatalError("case/of has duplicate branch")
				}
				consts[p.cVal] = true

				constLexes = append(constLexes, _MakeLex(p.cType, p.get_case_val(), p.cStrVal))

				p.nextLex()
				if p.cType != lex.COMMA {
					break
				}
				// забираем следующую константу
				p.nextLex()
			}

			// формируем условия для выполенния ветки: добавляем сравнение с каждой константой
			for _, it := range constLexes {
				p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_DUP, 0, "dup"))
				p.poliz = append(p.poliz, it)
				p.poliz = append(p.poliz, _MakeLex(lex.NEQ, 0, "case NEQ"))
				labels.Push(len(p.poliz))
				p.poliz = append(p.poliz, _MakeDefaultLex()) // адрес тела ветки
				p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_FGO, 0, "FGO"))
			}

			if len(constLexes) == 0 {
				fatalError("not constants specified")
			}

			// ни одно из условий не выполнено, идём к следующей ветки
			pl1 := len(p.poliz)
			p.poliz = append(p.poliz, _MakeDefaultLex())
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_GO, 0, "GO"))

			// заполняем пропущенные адреса на тело ветки case of
			for i := 0; i < len(constLexes); i++ {
				p.poliz[labels.Top()] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "POLIZ_LABEL to case branch")
				_ = labels.Pop()
			}

			// пропускаем символ :
			if p.cType != lex.COLON {
				fatalError("not COLON3 lex: %v %v", p.cType, p.cStrVal)
			}

			// тело ветки case/of
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_DEL_ARG, 0, "pop value of dup"))
			p.nextLex()
			p.S()

			// сюда запишется адрес выхода из ветки
			labels.Push(len(p.poliz))
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_LABEL, 0, "BREAK CASE"))
			p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_GO, 0, "GO"))

			p.poliz[pl1] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "NEXT BRANCH")
			if p.cType == lex.END {
				break
			}
		}

		if len(consts) == 0 {
			fatalError("case/of must have at least one const")
		}

		// помечаем последнюю метку, если мы на неё попали, значит ни одна ветка не сработала
		p.poliz = append(p.poliz, _MakeLex(lex.POLIZ_FAIL, 0, "branch of case not found"))

		// заполняем LABEL'ы верными адресами для выхода из тела веток case'а
		for len(labels) != 0 {
			p.poliz[labels.Top()] = _MakeLex(lex.POLIZ_LABEL, len(p.poliz), "BREAK CASE")
			_ = labels.Pop()
		}

		p.nextLex()
	} else {
		fatalError("not OF: %v", p.cType)
	}
}

func (p *_Parser) check_id(addr int) {
	if TID.ICurTID(addr).Declare() {
		p.stLex.Push(TID.ICurTID(addr).Type())
		return
	}
	fatalError("check_id: not declared %v %v", TID.ICurTID(addr).Name(), TID.ICurTID(addr).ID())
}

func (p *_Parser) check_op() {
	t := lex.INT
	r := lex.BOOL
	t2 := p.stLex.Pop()
	op := p.stLex.Pop()
	t1 := p.stLex.Pop()

	if op == lex.PLUS || op == lex.MINUS || op == lex.TIMES || op == lex.SLASH {
		r = lex.INT
	}
	if op == lex.OR || op == lex.AND {
		t = lex.BOOL
	}
	if t1 == t2 && t1 == t {
		p.stLex.Push(r)
	} else {
		fatalError("wrong types are in operation")
	}
	p.poliz = append(p.poliz, _MakeLex(op, 0, "op"))
}

func (p *_Parser) check_not() {
	if p.stLex.Top() != lex.BOOL {
		fatalError("wrong type is in not")
	}
	p.poliz = append(p.poliz, _MakeLex(lex.NOT, 0, "LEX_NOT"))
}

func (p *_Parser) eq_type() {
	t := p.stLex.Pop()
	if t != p.stLex.Top() {
		fatalError("wrong types are in :=")
	}
	_ = p.stLex.Pop()
}

func (p *_Parser) eq_bool() {
	if p.stLex.Top() != lex.BOOL {
		fatalError("expression is not boolean")
	}
	_ = p.stLex.Pop()
}

func (p *_Parser) check_id_in_read() {
	if !TID.ICurTID(p.cVal).Declare() {
		fatalError("check_id_in_read: not declared %v %v", TID.ICurTID(p.cVal).Name(), TID.ICurTID(p.cVal).ID())
	}
}

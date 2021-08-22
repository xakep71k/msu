package mylang

import (
	"fmt"
	"mylang/internal/app/mylang/lex"
)

func executePolize(poliz []_Lex) {
	args := MakeIntStack()
	identsStack := MakeMapIntIdentStack()
	identsStack.PushEmptyItem()

	var i, j, index int
	size := len(poliz)

	for index < size {
		idents := identsStack.Top()
		pc_el := poliz[index]
		switch ltype := pc_el.Type(); ltype {
		case lex.TRUE, lex.FALSE, lex.NUM, lex.POLIZ_ADDRESS, lex.POLIZ_LABEL:
			args.Push(pc_el.Value())
		case lex.ID:
			i = pc_el.Value()
			if !idents[i].Assign() {
				fatalError("POLIZ: not assigned: name '%s'", idents[i].ID)
			}

			args.Push(idents[i].Value())
		case lex.NOT:
			i = args.Pop()
			var v int
			if i == 0 {
				v = 1
			}
			args.Push(v)
		case lex.OR:
			i = args.Pop()
			j = args.Pop()
			var v int
			if i != 0 || j != 0 {
				v = 1
			}
			args.Push(v)
		case lex.AND:
			i = args.Pop()
			j = args.Pop()
			var v int
			if i != 0 && j != 0 {
				v = 1
			}
			args.Push(v)
		case lex.POLIZ_CALL_FUNC:
			index = pc_el.Value() - 1
			identsStack.PushEmptyItem()
		case lex.POLIZ_GO:
			i = args.Pop()
			index = i - 1
		case lex.POLIZ_RETURN_FUNC:
			j = args.Pop()
			if !idents[j].Assign() {
				fatalError("return value not assigned: %s", TID.ICurTID(j).Name())
			}
			i = args.Pop()
			index = i - 1
			args.Push(idents[j].Value())
			_ = identsStack.Pop()
		case lex.POLIZ_DUP:
			args.Push(args.Top())
		case lex.POLIZ_FGO:
			i = args.Pop()
			j = args.Pop()
			if j == 0 {
				index = i - 1
			}
		case lex.WRITE:
			j = args.Pop()
			fmt.Print(j)
		case lex.WRITELN:
			j = args.Pop()
			fmt.Println(j)
		case lex.READ:
			var k int
			i = args.Pop()
			if TID.ICurTID(i).Value() == int(lex.INT) {
				fmt.Printf("Input int value for %s\n", TID.ICurTID(i).Name())
				fmt.Scanf("%d", &k)
			} else if TID.ICurTID(i).Value() == int(lex.BOOL) {
				var str string
				for {
					fmt.Printf("Input boolean value (true or false) for '%s'\n", TID.ICurTID(i).Name())
					fmt.Scan("%s", &str)
					if str != "true" && str != "false" {
						fmt.Println("Error in input:true/false")
						continue
					}
					if str == "true" {
						k = 1
					} else {
						k = 0
					}
					break
				}
			} else {
				panic(fmt.Sprintf("unknown type %d", TID.ICurTID(i).Value()))
			}

			newIdent := idents[i]
			if !idents[i].Assign() {
				newIdent = TID.ICurTID(i)
			}
			newIdent.putValue(k)
			idents[i] = newIdent

		case lex.PLUS:
			i = args.Pop()
			j = args.Pop()
			args.Push(i + j)

		case lex.TIMES:
			i = args.Pop()
			j = args.Pop()
			args.Push(i * j)

		case lex.MINUS:
			i = args.Pop()
			j = args.Pop()
			args.Push(j - i)

		case lex.SLASH:
			i = args.Pop()
			j = args.Pop()
			if i == 0 {
				fatalError("POLIZ:divide by zero")
			}
			args.Push(j / i)

		case lex.EQ:
			i = args.Pop()
			j = args.Pop()
			if i == j {
				args.Push(1)
			} else {
				args.Push(0)
			}

		case lex.LSS:
			i = args.Pop()
			j = args.Pop()
			if i < j {
				args.Push(1)
			} else {
				args.Push(0)
			}

		case lex.GTR:
			i = args.Pop()
			j = args.Pop()
			if i > j {
				args.Push(1)
			} else {
				args.Push(0)
			}

		case lex.LEQ:
			i = args.Pop()
			j = args.Pop()
			if i <= j {
				args.Push(1)
			} else {
				args.Push(0)
			}

		case lex.GEQ:
			i = args.Pop()
			j = args.Pop()
			if i >= j {
				args.Push(1)
			} else {
				args.Push(0)
			}

		case lex.NEQ:
			i = args.Pop()
			j = args.Pop()
			if i != j {
				args.Push(1)
			} else {
				args.Push(0)
			}

		case lex.ASSIGN:
			i = args.Pop()
			j = args.Pop()
			newIdent := idents[j]
			newIdent.putValue(i)
			idents[j] = newIdent

		case lex.POLIZ_INIT_FUNC_ARG:
			j = args.Pop()
			i = args.Pop()
			newIdent := idents[j]
			newIdent.putValue(i)
			idents[j] = newIdent
		case lex.POLIZ_FAIL:
			fatalError(pc_el.StrValue())

		case lex.POLIZ_DEL_ARG:
			_ = args.Pop()

		default:
			fatalError("POLIZ: unexpected elem: %v\n", pc_el.Type())
		}

		index++
	}

	if len(args) != 0 {
		fatalError("executer: args stack not empty")
	}
}

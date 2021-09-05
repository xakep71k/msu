use crate::lex;
use std::collections::HashMap;

pub fn execute_poliz(poliz: Vec<crate::lex::Lex>) {
    let mut args: Vec<i32> = Vec::new();
    let mut identsStack: Vec<HashMap<i32, crate::ident::Ident>> = Vec::new();
    identsStack.push(HashMap::new());

    let (mut i, mut j, mut index) = (0, 0, 0);
    let size = poliz.len();

    while index < size {
        let idents = identsStack.last().unwrap();
        let pc_el = &poliz[index];
        match pc_el.kind() {
            lex::Kind::TRUE
            | lex::Kind::FALSE
            | lex::Kind::NUM
            | lex::Kind::POLIZ_ADDRESS
            | lex::Kind::POLIZ_LABEL => {
                args.push(pc_el.value());
            }
            lex::Kind::ID => {
                i = pc_el.value();
                let ident = idents.get(&i).unwrap();
                if !ident.assign() {
                    eprintln!("POLIZ: not assigned: name '{}'", ident.id());
                    std::process::exit(1);
                }

                args.push(ident.value());
            }
            lex::Kind::NOT => {
                let i = args.pop().unwrap();
                let v = if i == 0 { 1 } else { 0 };
                args.push(v);
            }
            lex::Kind::OR => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                let v = if i != 0 || j != 0 { 1 } else { 0 };
                args.push(v);
            }
            lex::Kind::AND => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                let v = if i != 0 && j != 0 { 1 } else { 0 };
                args.push(v);
            }
            lex::Kind::POLIZ_CALL_FUNC => {
                index = (pc_el.value() - 1) as usize;
                identsStack.push(HashMap::new());
            }
            lex::Kind::POLIZ_GO => {
                i = args.pop().unwrap();
                index = (i - 1) as usize;
            }
            lex::Kind::POLIZ_RETURN_FUNC => {
                j = args.pop().unwrap();
                let ident = idents.get(&j).unwrap();
                if !ident.assign() {
                    eprintln!("return value not assigned: {}", TID.ICurTID(j).name());
                    std::process::exit(1);
                }
                i = args.pop().unwrap();
                index = (i - 1) as usize;
                args.push(ident.value());
                identsStack.pop();
            }
            default => {
                eprintln!("POLIZ: unexpected elem: {:?}", default);
                std::process::exit(1);
            }
        }
    }
    /*
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
            if TID.ICurTID(i).Type() == lex.INT {
                fmt.Printf("Input int value for %s\n", TID.ICurTID(i).Name())
                fmt.Scanf("%d", &k)
            } else if TID.ICurTID(i).Type() == lex.BOOL {
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
                panic(fmt.Sprintf("unknown type %d %v", TID.ICurTID(i).Value(), TID.ICurTID(i).Type()))
            }

            newIdent := idents[i]
            if !idents[i].Assign() {
                newIdent = *TID.ICurTID(i)
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
            if j < i {
                args.Push(1)
            } else {
                args.Push(0)
            }

        case lex.GTR:
            i = args.Pop()
            j = args.Pop()
            if j > i {
                args.Push(1)
            } else {
                args.Push(0)
            }

        case lex.LEQ:
            i = args.Pop()
            j = args.Pop()
            if j <= i {
                args.Push(1)
            } else {
                args.Push(0)
            }

        case lex.GEQ:
            i = args.Pop()
            j = args.Pop()
            if j >= i {
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
    */
}

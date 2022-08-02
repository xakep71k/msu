package impl

import "fmt"

type Interpreter struct {
	parser      *Parser
	globalScope map[string]any
}

func NewInterpreter(parser *Parser) *Interpreter {
	return &Interpreter{
		parser:      parser,
		globalScope: make(map[string]any),
	}
}

func (intr *Interpreter) Interpret() (any, error) {
	tree, err := intr.parser.Parse()

	if err != nil {
		return nil, err
	}

	fmt.Printf("%+v\n", tree)

	return intr.visit(tree), nil
}

func (intr *Interpreter) visit(node AST) any {
	switch n := node.(type) {
	case BinOp:
		return intr.visit_BinOp(n)
	case Num:
		return intr.visit_Num(n)
	case UnaryOp:
		return intr.visit_UnaryOp(n)
	case Compound:
		return intr.visit_Compound(n)
	case Assign:
		return intr.visit_Assign(n)
	case Var:
		return intr.visit_Var(n)
	case VarDecl:
		return intr.visit_VarDecl(n)
	case Type:
		return intr.visit_Type(n)
	case NoOp:
		return intr.visit_NoOp(n)
	default:
		panic("unknown type node")
	}
}

func (intr *Interpreter) visit_BinOp(node BinOp) any {
	switch node.Op.Type {
	case PLUS:
		return intr.visit(node.Left).(int) + intr.visit(node.Right).(int)
	case MINUS:
		return intr.visit(node.Left).(int) - intr.visit(node.Right).(int)
	case MUL:
		return intr.visit(node.Left).(int) * intr.visit(node.Right).(int)
	case DIV:
		return intr.visit(node.Left).(int) / intr.visit(node.Right).(int)
	default:
		panic("unknown op")
	}

}

func (intr *Interpreter) visit_Num(node Num) any {
	return node.Value
}

func (intr *Interpreter) visit_UnaryOp(node UnaryOp) any {
	op := node.Op.Type
	if op == "+" {
		return intr.visit(node.Expr)
	} else if op == "-" {
		return -intr.visit(node.Expr).(int)
	}

	panic("invalid operation")
}

func (intr *Interpreter) visit_Compound(cmp Compound) any {
	for _, node := range cmp.Children {
		intr.visit(node)
	}

	return nil
}

func (intr *Interpreter) visit_Assign(node Assign) any {
	varName := node.left.Value.(string)
	intr.globalScope[varName] = intr.visit(node.right)

	return nil
}

func (intr *Interpreter) visit_Var(node Var) any {
	varName := node.Value.(string)
	val := intr.globalScope[varName]

	if val == nil {
		panic("name error")
	}

	return val
}

func (intr *Interpreter) visit_NoOp(node NoOp) any {
	return nil
}

func (intr *Interpreter) visit_VarDecl(node VarDecl) any {
	return nil
}

func (intr *Interpreter) visit_Type(node Type) any {
	return nil
}

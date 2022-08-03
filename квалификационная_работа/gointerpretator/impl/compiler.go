package impl

import "fmt"

type Compiler struct {
	globalScope map[string]any
}

func NewCompiler() *Compiler {
	return &Compiler{
		globalScope: make(map[string]any),
	}
}

func (intr *Compiler) Compile(tree AST) (any, error) {
	fmt.Printf("%+v\n", tree)

	return intr.visit(tree), nil
}

func (intr *Compiler) visit(node AST) any {
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
	case Print:
		return intr.visit_Print(n)
	case NoOp:
		return intr.visit_NoOp(n)
	default:
		panic("unknown type node")
	}
}

func (intr *Compiler) visit_BinOp(node BinOp) any {
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

func (intr *Compiler) visit_Num(node Num) any {
	return node.Value
}

func (intr *Compiler) visit_UnaryOp(node UnaryOp) any {
	op := node.Op.Type
	if op == "+" {
		return intr.visit(node.Expr)
	} else if op == "-" {
		return -intr.visit(node.Expr).(int)
	}

	panic("invalid operation")
}

func (intr *Compiler) visit_Compound(cmp Compound) any {
	for _, node := range cmp.Children {
		intr.visit(node)
	}

	return nil
}

func (intr *Compiler) visit_Assign(node Assign) any {
	varName := node.left.Value
	intr.globalScope[varName] = intr.visit(node.right)

	return nil
}

func (intr *Compiler) visit_Var(node Var) any {
	varName := node.Value
	val := intr.globalScope[varName]

	if val == nil {
		panic("name error")
	}

	return val
}

func (intr *Compiler) visit_NoOp(node NoOp) any {
	return nil
}

func (intr *Compiler) visit_VarDecl(node VarDecl) any {
	return nil
}

func (intr *Compiler) visit_Type(node Type) any {
	return nil
}

func (intr *Compiler) visit_Print(node Print) any {
	return nil
}

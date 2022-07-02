package impl

func Visit(node AST) any {
	switch n := node.(type) {
	case BinOp:
		return visit_BinOp(n)
	case Num:
		return visit_Num(n)
	default:
		panic("unknown type node")
	}
}

func visit_BinOp(node BinOp) any {
	switch node.Op.Type {
	case PLUS:
		return Visit(node.Left).(int) + Visit(node.Right).(int)
	case MINUS:
		return Visit(node.Left).(int) - Visit(node.Right).(int)
	case MUL:
		return Visit(node.Left).(int) * Visit(node.Right).(int)
	case DIV:
		return Visit(node.Left).(int) / Visit(node.Right).(int)
	default:
		panic("unknown op")
	}

}

func visit_Num(node Num) any {
	return node.Value
}

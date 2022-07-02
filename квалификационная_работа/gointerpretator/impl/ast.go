package impl

type AST interface {
}

type BinOp struct {
	Left  AST
	Token Token
	Op    Token
	Right AST
}

type Num struct {
	Token Token
	Value any
}

func MakeBinOp(left AST, op Token, right AST) BinOp {
	return BinOp{left, op, op, right}
}

func MakeNum(token Token) Num {
	return Num{token, token.Value}
}

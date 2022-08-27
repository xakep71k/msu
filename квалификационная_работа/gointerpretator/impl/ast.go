package impl

type AST interface {
}

type BinOp struct {
	Left  AST
	Token Token
	Op    Token
	Right AST
}

func MakeBinOp(left AST, op Token, right AST) BinOp {
	return BinOp{left, op, op, right}
}

type BoolOp struct {
	Left  AST
	Token Token
	Op    Token
	Right AST
}

func MakeBoolOp(left AST, op Token, right AST) BoolOp {
	return BoolOp{left, op, op, right}
}

type Num struct {
	Token Token
	Value any
}

func MakeNum(token Token) Num {
	return Num{token, token.Value}
}

type UnaryOp struct {
	Token Token
	Op    Token
	Expr  AST
}

func MakeUnaryOp(tok Token, ast AST) UnaryOp {
	return UnaryOp{tok, tok, ast}
}

type Compound struct {
	Children []AST
}

func MakeCompound(children []AST) Compound {
	return Compound{children}
}

type Assign struct {
	Left  Var
	Op    Token
	Right AST
}

func MakeAssign(left Var, op Token, right AST) Assign {
	return Assign{left, op, right}
}

type Var struct {
	Tok   Token
	Value string
}

func MakeVar(tok Token) Var {
	return Var{tok, tok.Value.(string)}
}

type VarDecl struct {
	Var  Var
	Type Type
}

func MakeVarDecl(v Var, t Type) VarDecl {
	return VarDecl{v, t}
}

type Type struct {
	Tok   Token
	Value string
}

func MakeType(tok Token) Type {
	return Type{tok, tok.Value.(string)}
}

type NoOp struct{}

func MakeNoOp() NoOp {
	return NoOp{}
}

type Print struct {
	Var Var
}

func MakePrint(tok Token) Print {
	return Print{
		Var: MakeVar(tok),
	}
}

type ForLoop struct {
	Assign   Assign
	BoolExpr BoolOp
	Expr     Assign
	Body     Compound
}

func MakeForLoop(assign Assign, boolBinOp BoolOp, expr Assign, comp Compound) ForLoop {
	return ForLoop{
		Assign:   assign,
		BoolExpr: boolBinOp,
		Expr:     expr,
		Body:     comp,
	}
}

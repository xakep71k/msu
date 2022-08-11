package impl

import (
	"errors"
	"fmt"
)

var (
	ErrInvalidSyntax = errors.New("invalid syntax")
)

type Parser struct {
	lex       *Lexer
	currToken Token
}

func NewParser(lex *Lexer) *Parser {
	t, err := lex.NextToken()

	if err != nil {
		panic(err)
	}

	return &Parser{
		lex:       lex,
		currToken: t,
	}
}

func (p *Parser) Parse() (AST, error) {
	node, err := p.program()
	if err != nil {
		return nil, err
	}

	if p.currToken.Type != EOF {
		fmt.Println("unexpected EOF")
		return nil, ErrInvalidSyntax
	}

	return node, nil
}

func (p *Parser) eat(tokenType string) error {
	if p.currToken.Type == tokenType {
		var err error
		p.currToken, err = p.lex.NextToken()
		if err != nil {
			return err
		}
		return nil
	}

	fmt.Println("unexpected token", p.currToken)
	return ErrInvalidSyntax
}

func (p *Parser) program() (AST, error) {
	if err := p.main(); err != nil {
		return nil, err
	}

	node, err := p.compoundStatement()
	if err != nil {
		return nil, err
	}

	return node, nil
}

func (p *Parser) main() error {
	if err := p.eat("func"); err != nil {
		return err
	}

	currToken := p.currToken
	if err := p.eat(ID); err != nil {
		return err
	}

	if currToken.Value.(string) != "main" {
		return ErrInvalidSyntax
	}

	if err := p.eat(LPARENT); err != nil {
		return err
	}

	if err := p.eat(RPARENT); err != nil {
		return err
	}

	if p.currToken.Type == NEWLINE {
		_ = p.eat(NEWLINE)
	}

	return nil
}

func (p *Parser) compoundStatement() (Compound, error) {
	if err := p.eat(BEGIN); err != nil {
		return Compound{}, err
	}

	if err := p.eat(NEWLINE); err != nil {
		return Compound{}, err
	}

	nodes, err := p.statementList()

	if err != nil {
		return Compound{}, err
	}

	if err := p.eat(END); err != nil {
		return Compound{}, err
	}

	if err := p.eat(NEWLINE); err != nil {
		return Compound{}, err
	}

	root := MakeCompound(nodes)

	return root, nil
}

func (p *Parser) statementList() ([]AST, error) {
	node, err := p.statement()

	if err != nil {
		return nil, err
	}

	results := []AST{node}

	for p.currToken.Type == NEWLINE {
		p.eat(NEWLINE)
		node, err := p.statement()

		if err != nil {
			return nil, err
		}

		results = append(results, node)
	}

	return results, nil
}

func (p *Parser) statement() (AST, error) {
	var node AST
	var err error

	/* compund statement не поддерживается в связи
	с отсутствием стека
	if p.currToken.Type == BEGIN {
		node, err = p.compoundStatement()

		if err != nil {
			return nil, err
		}
	} else */if p.currToken.Type == ID {
		node, err = p.assignmentStatement()
		if err != nil {
			return nil, err
		}
	} else if p.currToken.Type == VAR {
		node, err = p.declarations()
		if err != nil {
			return nil, err
		}
	} else if p.currToken.Type == PRINTLN {
		if err := p.eat(PRINTLN); err != nil {
			return nil, err
		}

		node, err = p.println()
		if err != nil {
			return nil, err
		}
	} else if p.currToken.Type == FORLOOP {
		if err := p.eat(FORLOOP); err != nil {
			return nil, err
		}

		assign, err := p.assignmentStatement()
		if err != nil {
			return nil, err
		}

		if err := p.eat(SEMI); err != nil {
			return nil, err
		}

		boolExpr, err := p.boolExpr()
		if err != nil {
			return nil, err
		}

		if err := p.eat(SEMI); err != nil {
			return nil, err
		}

		expr, err := p.assignmentStatement()
		if err != nil {
			return nil, err
		}

		compound, err := p.compoundStatement()
		if err != nil {
			return nil, err
		}

		return MakeForLoop(
			assign,
			boolExpr,
			expr,
			compound,
		), nil
	} else {
		node = p.empty()
	}

	return node, nil
}

func (p *Parser) println() (Print, error) {
	if err := p.eat(LPARENT); err != nil {
		return Print{}, err
	}

	tok := p.currToken
	if err := p.eat(ID); err != nil {
		return Print{}, err
	}

	if err := p.eat(RPARENT); err != nil {
		return Print{}, err
	}

	return MakePrint(tok), nil
}

func (p *Parser) assignmentStatement() (Assign, error) {
	left, err := p.variable()

	if err != nil {
		return Assign{}, err
	}

	token := p.currToken

	if err := p.eat(ASSIGN); err != nil {
		return Assign{}, err
	}

	right, err := p.expr()

	if err != nil {
		return Assign{}, nil
	}

	return MakeAssign(left, token, right), nil
}

func (p *Parser) variable() (Var, error) {
	node := MakeVar(p.currToken)
	if err := p.eat(ID); err != nil {
		return Var{}, err
	}

	return node, nil
}

func (p *Parser) declarations() (VarDecl, error) {
	if err := p.eat(VAR); err != nil {
		return VarDecl{}, err
	}

	varDecl, err := p.variableDeclaration()
	if err != nil {
		return VarDecl{}, err
	}

	return varDecl, nil
}

func (p *Parser) variableDeclaration() (VarDecl, error) {
	varNode := MakeVar(p.currToken)

	if err := p.eat(ID); err != nil {
		return VarDecl{}, err
	}

	typeSpec, err := p.typeSpec()
	if err != nil {
		return VarDecl{}, err
	}

	return MakeVarDecl(varNode, typeSpec), nil
}

func (p *Parser) typeSpec() (Type, error) {
	token := p.currToken

	if p.currToken.Type == INTEGER {
		if err := p.eat(INTEGER); err != nil {
			return Type{}, err
		}
	} else if err := p.eat(FLOAT32); err != nil {
		return Type{}, err
	}

	return MakeType(token), nil
}

func (p *Parser) empty() NoOp {
	return MakeNoOp()
}

func (p *Parser) boolExpr() (BinOp, error) {
	left, err := p.expr()
	if err != nil {
		return BinOp{}, err
	}

	token := p.currToken

	switch token.Type {
	case LESS:
		if err := p.eat(LESS); err != nil {
			return BinOp{}, err
		}
	}

	right, err := p.expr()
	if err != nil {
		return BinOp{}, err
	}

	return MakeBinOp(left, token, right), nil
}

func (p *Parser) expr() (AST, error) {
	node, err := p.term()
	if err != nil {
		return BinOp{}, err
	}

	for p.currToken.Type == PLUS || p.currToken.Type == MINUS {
		token := p.currToken

		switch token.Type {
		case PLUS:
			if err := p.eat(PLUS); err != nil {
				return BinOp{}, err
			}
		case MINUS:
			if err := p.eat(MINUS); err != nil {
				return BinOp{}, err
			}
		}

		right, err := p.term()
		if err != nil {
			return BinOp{}, err
		}

		node = MakeBinOp(node, token, right)
	}

	return node, nil
}

func (p *Parser) term() (AST, error) {
	node, err := p.factor()
	if err != nil {
		return nil, err
	}

	for p.currToken.Type == MUL || p.currToken.Type == DIV {
		token := p.currToken
		switch token.Type {
		case MUL:
			if err := p.eat(MUL); err != nil {
				return BinOp{}, err
			}
		case DIV:
			if err := p.eat(DIV); err != nil {
				return BinOp{}, err
			}
		}

		right, err := p.factor()
		if err != nil {
			return BinOp{}, err
		}
		node = MakeBinOp(node, token, right)
	}

	return node, nil
}

func (p *Parser) factor() (AST, error) {
	token := p.currToken

	switch token.Type {
	case PLUS:
		if err := p.eat(PLUS); err != nil {
			return nil, err
		}

		expr, err := p.factor()

		if err != nil {
			return nil, err
		}

		return MakeUnaryOp(token, expr), nil
	case MINUS:
		if err := p.eat(MINUS); err != nil {
			return nil, err
		}

		expr, err := p.factor()

		if err != nil {
			return nil, err
		}

		return MakeUnaryOp(token, expr), nil
	case INTEGER_CONST:
		if err := p.eat(INTEGER_CONST); err != nil {
			return nil, err
		}

		return MakeNum(token), nil
	case FLOAT32_CONST:
		if err := p.eat(FLOAT32_CONST); err != nil {
			return nil, err
		}

		return MakeNum(token), nil
	case ID:
		if err := p.eat(ID); err != nil {
			return nil, err
		}

		return MakeVar(token), nil
	case LPARENT:
		if err := p.eat(LPARENT); err != nil {
			return nil, err
		}

		node, err := p.expr()
		if err != nil {
			return nil, err
		}

		if err := p.eat(RPARENT); err != nil {
			return nil, err
		}

		return node, nil
	}

	fmt.Println("unknown token:", p.currToken)
	return nil, ErrInvalidSyntax
}

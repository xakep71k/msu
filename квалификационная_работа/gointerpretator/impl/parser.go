package impl

import "errors"

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

	return ErrInvalidSyntax
}

func (p *Parser) program() (AST, error) {
	node, err := p.compoundStatement()
	if err != nil {
		return nil, err
	}

	return node, nil
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

	if p.currToken.Type == BEGIN {
		node, err = p.compoundStatement()

		if err != nil {
			return nil, err
		}
	} else if p.currToken.Type == ID {
		node, err = p.assignmentStatement()
		if err != nil {
			return nil, err
		}
	} else {
		node = p.empty()
	}

	return node, nil
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

func (p *Parser) empty() NoOp {
	return MakeNoOp()
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
	case INTEGER:
		if err := p.eat(INTEGER); err != nil {
			return nil, err
		}

		return MakeNum(token), nil
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

	return nil, ErrInvalidSyntax
}

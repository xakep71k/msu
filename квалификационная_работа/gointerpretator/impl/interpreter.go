package impl

import (
	"errors"
)

var (
	ErrInvalidSyntax error = errors.New("invalid syntax")
)

type Interpreter struct {
	currentToken Token
	lexer        *Lexer
}

func NewInterpreter(lexer *Lexer) (*Interpreter, error) {
	token, err := lexer.NextToken()
	if err != nil {
		return nil, err
	}
	return &Interpreter{
		lexer:        lexer,
		currentToken: token,
	}, nil
}

func (r *Interpreter) eat(ttype string) error {
	if r.currentToken.Type != ttype {
		return ErrInvalidSyntax
	}

	var err error
	r.currentToken, err = r.lexer.NextToken()
	return err
}

func (r *Interpreter) factor() (AST, error) {
	token := r.currentToken
	if token.Type == INTEGER {
		if err := r.eat(INTEGER); err != nil {
			return 0, err
		}

		return MakeNum(token), nil
	} else if token.Type == LPARENT {
		if err := r.eat(LPARENT); err != nil {
			return 0, err
		}

		node, err := r.Expr()
		if err != nil {
			return 0, err
		}

		if err := r.eat(RPARENT); err != nil {
			return 0, err
		}

		return node, nil
	}

	return nil, ErrInvalidSyntax
}

func (r *Interpreter) term() (AST, error) {
	node, err := r.factor()
	if err != nil {
		return nil, err
	}

	for r.currentToken.Type == MUL || r.currentToken.Type == DIV {
		token := r.currentToken
		switch token.Type {
		case MUL:
			if err := r.eat(MUL); err != nil {
				return nil, err
			}
		case DIV:
			if err := r.eat(DIV); err != nil {
				return nil, err
			}
		}

		right, err := r.factor()
		if err != nil {
			return nil, err
		}
		node = MakeBinOp(node, token, right)
	}

	return node, nil
}

func (r *Interpreter) Expr() (AST, error) {
	node, err := r.term()
	if err != nil {
		return 0, err
	}

	for r.currentToken.Type == PLUS || r.currentToken.Type == MINUS {
		token := r.currentToken

		switch token.Type {
		case PLUS:
			if err := r.eat(PLUS); err != nil {
				return 0, err
			}
		case MINUS:
			if err := r.eat(MINUS); err != nil {
				return 0, err
			}
		}

		right, err := r.term()
		if err != nil {
			return nil, err
		}
		node = MakeBinOp(node, token, right)
	}

	return node, nil
}

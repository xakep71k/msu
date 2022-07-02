package impl

import (
	"strconv"
	"unicode"
)

type Lexer struct {
	currentChar rune
	pos         int
	text        []rune
}

func NewLexer(text string) *Lexer {
	lexer := &Lexer{
		text: []rune(text),
		pos:  -1,
	}

	lexer.advance()

	return lexer
}

func (r *Lexer) NextToken() (Token, error) {
	for r.currentChar != -1 {
		if unicode.IsSpace(r.currentChar) {
			r.skipWhitespaces()
			continue
		}

		if unicode.IsDigit(r.currentChar) {
			return MakeToken(INTEGER, r.integer()), nil
		}

		switch r.currentChar {
		case '+':
			r.advance()
			return MakeToken(PLUS, r.currentChar), nil
		case '-':
			r.advance()
			return MakeToken(MINUS, r.currentChar), nil
		case '*':
			r.advance()
			return MakeToken(MUL, r.currentChar), nil
		case '/':
			r.advance()
			return MakeToken(DIV, r.currentChar), nil
		case '(':
			r.advance()
			return MakeToken(LPARENT, r.currentChar), nil
		case ')':
			r.advance()
			return MakeToken(RPARENT, r.currentChar), nil
		}

		return Token{}, ErrInvalidSyntax
	}

	return MakeToken(EOF, nil), nil
}

func (r *Lexer) skipWhitespaces() {
	for r.currentChar != -1 && unicode.IsSpace(r.currentChar) {
		r.advance()
	}
}

func (r *Lexer) advance() {
	r.pos += 1

	if r.pos >= len(r.text) {
		r.currentChar = -1
	} else {
		r.currentChar = r.text[r.pos]
	}
}

func (r *Lexer) integer() int {
	intRunes := make([]rune, 0)

	for unicode.IsDigit(r.currentChar) {
		intRunes = append(intRunes, r.currentChar)
		r.advance()
	}

	i, err := strconv.ParseInt(string(intRunes), 10, 32)
	if err != nil {
		panic(err)
	}

	return int(i)
}

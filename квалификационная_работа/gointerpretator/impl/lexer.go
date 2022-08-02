package impl

import (
	"strconv"
	"unicode"
)

var REVERSED_KEYWORDS = map[string]Token{
	"{":   MakeToken(BEGIN, "{"),
	"}":   MakeToken(END, "}"),
	"var": MakeToken(VAR, "var"),
	"int": MakeToken(INT, "int"),
}

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

func (r *Lexer) advance() {
	r.pos += 1

	if r.pos >= len(r.text) {
		r.currentChar = -1
	} else {
		r.currentChar = r.text[r.pos]
	}
}

func (r *Lexer) peek() rune {
	peek_pos := r.pos + 1
	if peek_pos >= len(r.text) {
		return -1
	}

	return r.text[peek_pos]
}

func (r *Lexer) skipWhitespaces() {
	for r.currentChar != -1 && IsSpace(r.currentChar) {
		r.advance()
	}
}

func IsSpace(r rune) bool {
	switch r {
	case ' ', '\t', '\r':
		return true
	default:
		return false
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

func (r *Lexer) NextToken() (Token, error) {
	for r.currentChar != -1 {
		if IsSpace(r.currentChar) {
			r.skipWhitespaces()
			continue
		}

		if unicode.IsDigit(r.currentChar) {
			return MakeToken(INTEGER, r.integer()), nil
		}

		if unicode.IsLetter(r.currentChar) {
			return r.id(), nil
		}

		if r.currentChar == '/' && r.peek() == '/' {
			r.advance()
			r.advance()
			r.skipComments()
			continue
		}

		currentChar := r.currentChar
		switch r.currentChar {
		case '=':
			r.advance()
			return MakeToken(ASSIGN, currentChar), nil
		case '\n':
			r.advance()
			return MakeToken(NEWLINE, currentChar), nil
		case '{':
			r.advance()
			return MakeToken(BEGIN, currentChar), nil
		case '}':
			r.advance()
			return MakeToken(END, currentChar), nil
		case '+':
			r.advance()
			return MakeToken(PLUS, currentChar), nil
		case '-':
			r.advance()
			return MakeToken(MINUS, currentChar), nil
		case '*':
			r.advance()
			return MakeToken(MUL, currentChar), nil
		case '/':
			r.advance()
			return MakeToken(DIV, currentChar), nil
		case '(':
			r.advance()
			return MakeToken(LPARENT, currentChar), nil
		case ')':
			r.advance()
			return MakeToken(RPARENT, currentChar), nil
		}

		return Token{}, ErrInvalidSyntax
	}

	return MakeToken(EOF, nil), nil
}

func (r *Lexer) id() Token {
	result := make([]rune, 0)
	for r.currentChar != -1 && unicode.IsLetter(r.currentChar) {
		result = append(result, r.currentChar)
		r.advance()
	}

	name := string(result)

	tok, ok := REVERSED_KEYWORDS[name]
	if ok {
		return tok
	}

	return MakeToken(ID, name)
}

func (r *Lexer) skipComments() {
	for r.currentChar != '\n' {
		r.advance()
	}
	r.advance()
}

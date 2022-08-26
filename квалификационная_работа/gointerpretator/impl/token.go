package impl

import "fmt"

const (
	INT64         = "INT64"
	FORLOOP       = "for"
	FLOAT64       = "FLOAT64"
	INT64_CONST   = "INT64_CONST"
	FLOAT64_CONST = "FLOAT64_CONST"
	PLUS          = "PLUS"
	MINUS         = "MINUS"
	MUL           = "MUL"
	DIV           = "DIV"
	LPARENT       = "("
	RPARENT       = ")"
	ID            = "ID"
	ASSIGN        = "ASSIGN"
	NEWLINE       = "NEWLINE"
	BEGIN         = "{"
	END           = "}"
	VAR           = "VAR"
	FUNC          = "func"
	PRINTLN       = "Println"
	LESS          = "<"
	MORE          = ">"
	SEMI          = ";"
	EOF           = "EOF"
)

type Token struct {
	Type  string
	Value any
}

func MakeToken(Type string, Value any) Token {
	return Token{Type, Value}
}

func (t *Token) String() string {
	return fmt.Sprintf("Token(%v, %v)", t.Type, t.Value)
}

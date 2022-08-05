package impl

import "fmt"

const (
	INTEGER       = "INTEGER"
	FORLOOP       = "for"
	FLOAT32       = "FLOAT32"
	INTEGER_CONST = "INTEGER_CONST"
	FLOAT32_CONST = "FLOAT32_CONST"
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

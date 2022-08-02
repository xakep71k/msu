package impl

import "fmt"

const (
	INTEGER = "INTEGER"
	PLUS    = "PLUS"
	MINUS   = "MINUS"
	MUL     = "MUL"
	DIV     = "DIV"
	LPARENT = "("
	RPARENT = ")"
	ID      = "ID"
	ASSIGN  = "ASSIGN"
	NEWLINE = "NEWLINE"
	BEGIN   = "{"
	END     = "}"
	VAR     = "VAR"
	FLOAT32 = "FLOAT32"
	EOF     = "EOF"
)

type Token struct {
	Type  string
	Value interface{}
}

func MakeToken(Type string, Value interface{}) Token {
	return Token{Type, Value}
}

func (t *Token) String() string {
	return fmt.Sprintf("Token(%v, %v)", t.Type, t.Value)
}

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
	FUNC    = "func"
	PRINTLN = "Println"
	FLOAT32 = "FLOAT32"
	EOF     = "EOF"
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

package impl

const (
	INTEGER string = "INTEGER"
	PLUS    string = "PLUS"
	MINUS   string = "MINUS"
	MUL     string = "MUL"
	DIV     string = "DIV"
	LPARENT string = "LPARENT"
	RPARENT string = "RPARENT"
	EOF     string = "EOF"
)

type Token struct {
	Type  string
	Value interface{}
}

func MakeToken(Type string, Value interface{}) Token {
	return Token{Type, Value}
}

package mylang

import "mylang/internal/app/mylang/lex"

type _Lex struct {
	_Type     lex.Type
	_Value    int
	_ValueStr string
}

func _MakeLex(ltype lex.Type, value int, valueStr string) _Lex {
	return _Lex{
		_Type:     ltype,
		_Value:    value,
		_ValueStr: valueStr,
	}
}

func _MakeDefaultLex() _Lex {
	return _MakeLex(lex.NULL, 0, "")
}

func (l _Lex) Value() int {
	return l._Value
}

func (l _Lex) StrValue() string {
	return l._ValueStr
}

func (l _Lex) Type() lex.Type {
	return l._Type
}

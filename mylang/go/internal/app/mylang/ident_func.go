package mylang

import "mylang/internal/app/mylang/lex"

type _IdentFunc struct {
	_Ident
	_Args      []*_Ident
	_ReturnLex _Lex
	_ReturnVar int
}

func MakeIdentFunc(name string, address int) _IdentFunc {
	newIdent := _IdentFunc{}
	newIdent._Name = name
	newIdent.putValue(address)
	newIdent.putType(lex.FUNCTION)
	return newIdent
}

func (ident *_IdentFunc) pushArg(arg *_Ident) {
	ident._Args = append(ident._Args, arg)
}

func (ident *_IdentFunc) sizeArgs() int {
	return len(ident._Args)
}

func (ident *_IdentFunc) setReturnLex(lx _Lex) {
	ident._ReturnLex = lx
}

func (ident *_IdentFunc) ReturnLex() _Lex {
	return ident._ReturnLex
}

func (ident *_IdentFunc) IArgs(i int) *_Ident {
	return ident._Args[i]
}

func (ident *_IdentFunc) setReturnVar(i int) {
	ident._ReturnVar = i
}

func (ident *_IdentFunc) ReturnVar() int {
	return ident._ReturnVar
}

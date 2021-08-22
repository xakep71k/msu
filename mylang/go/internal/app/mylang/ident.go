package mylang

import "mylang/internal/app/mylang/lex"

type _Ident struct {
	_Name    string
	_Declare bool
	_Type    lex.Type
	_Assign  bool
	_ID      string
	_Ret     bool
	_Value   int
}

func MakeIdent(name string) _Ident {
	return _Ident{
		_Name: name,
	}
}

func (ident *_Ident) setID(id string) {
	ident._ID = id
}

func (ident _Ident) ID() string {
	return ident._ID
}

func (ident _Ident) Name() string {
	return ident._Name
}

func (ident _Ident) Declare() bool {
	return ident._Declare
}

func (ident *_Ident) PutDeclare() {
	ident._Declare = true
}

func (ident _Ident) Assign() bool {
	return ident._Assign
}

func (ident _Ident) Value() int {
	return ident._Value
}

func (ident *_Ident) putValue(v int) {
	ident._Assign = true
	ident._Value = v
}

func (ident *_Ident) putType(t lex.Type) {
	ident._Type = t
}

func (ident *_Ident) Ret() bool {
	return ident._Ret
}

func (ident *_Ident) SetRet() {
	ident._Ret = true
}

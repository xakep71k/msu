package mylang

import "mylang/internal/app/mylang/lex"

type IntStack []int
type RuneStack []rune
type MapIntIdentStack []map[int]_Ident
type LexStack []_Lex
type TypeLexStack []lex.Type

func MakeIntStack() IntStack {
	return make(IntStack, 0)
}

func MakeMapIntIdentStack() MapIntIdentStack {
	return make(MapIntIdentStack, 0)
}

func MakeLexStack() LexStack {
	return make(LexStack, 0)
}

func MakeTypeLexStack() TypeLexStack {
	return make(TypeLexStack, 0)
}

func (sp *IntStack) Pop() int {
	s := *sp
	v := s[len(s)-1]
	*sp = s[:len(s)-1]
	return v
}

func (sp *IntStack) Push(v int) {
	*sp = append(*sp, v)
}

func (s IntStack) Top() int {
	return s[len(s)-1]
}

func (sp *MapIntIdentStack) Pop() map[int]_Ident {
	s := *sp
	v := s[len(s)-1]
	*sp = s[:len(s)-1]
	return v
}

func (sp *MapIntIdentStack) Push(v map[int]_Ident) {
	*sp = append(*sp, v)
}

func (sp *MapIntIdentStack) PushEmptyItem() {
	*sp = append(*sp, map[int]_Ident{})
}

func (s MapIntIdentStack) Top() map[int]_Ident {
	return s[len(s)-1]
}

func (sp *LexStack) Pop() _Lex {
	s := *sp
	v := s[len(s)-1]
	*sp = s[:len(s)-1]
	return v
}

func (sp *LexStack) Push(v _Lex) {
	*sp = append(*sp, v)
}

func (s LexStack) Top() _Lex {
	return s[len(s)-1]
}

func (sp *TypeLexStack) Pop() lex.Type {
	s := *sp
	v := s[len(s)-1]
	*sp = s[:len(s)-1]
	return v
}

func (sp *TypeLexStack) Push(v lex.Type) {
	*sp = append(*sp, v)
}

func (s TypeLexStack) Top() lex.Type {
	return s[len(s)-1]
}

func (sp *RuneStack) Pop() rune {
	s := *sp
	v := s[len(s)-1]
	*sp = s[:len(s)-1]
	return v
}

func (sp *RuneStack) Push(v rune) {
	*sp = append(*sp, v)
}

func (s RuneStack) Top() rune {
	return s[len(s)-1]
}

func (s RuneStack) Size() int {
	return len(s)
}

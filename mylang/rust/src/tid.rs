use std::collections::HashMap;
use std::ops::{Index, IndexMut};

pub static TID: TIDType = TIDType { cur: Vec::new() };

pub struct TIDType {
	cur: Vec<crate::ident::Ident>,
	func_table: HashMap<String, crate::ident_func::IdentFunc>,
}

impl Index<i32> for TIDType {
	type Output = crate::ident::Ident;

	fn index(&self, index: i32) -> &Self::Output {
		&self.cur[index as usize]
	}
}

impl IndexMut<i32> for TIDType {
	fn index_mut(&mut self, index: i32) -> &mut Self::Output {
		&mut self.cur[index as usize]
	}
}

/*
type _TIDType struct {
	cur       []*_Ident
	funcTable map[string]*_IdentFunc
	funcStack []string
}

func _MakeTID() _TIDType {
	return _TIDType{
		funcStack: []string{"global"},
		cur:       make([]*_Ident, 0),
		funcTable: make(map[string]*_IdentFunc),
	}
}

func (t *_TIDType) ICurTID(i int) *_Ident {
	return t.CurTID()[i]
}

func (t *_TIDType) CurTID() []*_Ident {
	return t.cur
}

func (t *_TIDType) Push(ident _Ident) {
	t.cur = append(t.cur, &ident)
}

func (t *_TIDType) Size() int {
	return len(t.cur)
}

func (t *_TIDType) DeclareFunc(ident _Ident, address int) bool {
	name := ident.Name()
	if _, found := t.funcTable[name]; found {
		return true
	}

	newIdent := _IdentFunc{_Ident: ident}
	newIdent.putValue(address)
	newIdent.putType(lex.FUNCTION)
	t.funcTable[name] = &newIdent
	return false
}

func (t *_TIDType) TopFunc() *_IdentFunc {
	return t.funcTable[t.funcStack[len(t.funcStack)-1]]
}

func (t *_TIDType) FindFunc(name string) *_IdentFunc {
	return t.funcTable[name]
}

func (t *_TIDType) PushFunc(name string) {
	t.funcStack = append(t.funcStack, name)
}

func (t *_TIDType) PopFunc() {
	t.funcStack = t.funcStack[:len(t.funcStack)-1]
}

func (t *_TIDType) TopFuncName() string {
	return t.funcStack[len(t.funcStack)-1]
}

func (t *_TIDType) PopBack() *_Ident {
	ident := t.cur[len(t.cur)-1]
	t.cur = t.cur[:len(t.cur)-1]
	return ident
}

func putIdent(buf string) int {
	prefix := TID.TopFuncName()
	idents := TID.CurTID()
	id := prefix + buf
	for i := range idents {
		if idents[i].ID() == id {
			return i
		}
	}

	newIdent := MakeIdent(buf)
	newIdent.setID(id)
	TID.Push(newIdent)
	return TID.Size() - 1
}

*/

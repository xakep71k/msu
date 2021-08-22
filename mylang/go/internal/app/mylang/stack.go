package mylang

type IntStack []int
type MapIntIdentStack []map[int]_Ident

func MakeIntStack() IntStack {
	return make(IntStack, 0)
}

func MakeMapIntIdentStack() MapIntIdentStack {
	return make(MapIntIdentStack, 0)
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

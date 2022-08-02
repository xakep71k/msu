package impl

import "fmt"

var (
	ErrNameNodeDefined = "variable not declared"
)

type Symbol interface {
	Name() string
}

type VarSymbol struct {
	name string
	Type any
}

func (v *VarSymbol) Name() string {
	return v.name
}

func (v *VarSymbol) String() string {
	return fmt.Sprintf("<%s:%v>", v.name, v.Type)
}

func NewVarSymbol(Name string, Type any) *VarSymbol {
	return &VarSymbol{Name, Type}
}

type BuiltinTypeSymbol struct {
	name string
}

func NewBuiltinTypeSymbol(name string) *BuiltinTypeSymbol {
	return &BuiltinTypeSymbol{name}
}

func (v *BuiltinTypeSymbol) Name() string {
	return v.name
}

func (v *BuiltinTypeSymbol) String() string {
	return v.name
}

type SymbolTable struct {
	Table map[string]any
}

func MakeSymbolTable() SymbolTable {
	stable := SymbolTable{
		Table: make(map[string]any),
	}

	stable.define(NewBuiltinTypeSymbol("int"))
	return stable
}

func (st *SymbolTable) String() {
	fmt.Println("Symbols:")
	for k, v := range st.Table {
		fmt.Printf("%s: %v\n", k, v)
	}
}

func (st *SymbolTable) define(s Symbol) {
	fmt.Println("Define:", s)
	st.Table[s.Name()] = s
}

func (st *SymbolTable) lookup(name string) any {
	fmt.Println("Lookup:", name)
	return st.Table[name]
}

type SymbolTableBuilder struct {
	SymTable SymbolTable
}

func MakeSymbolTableBuilder() SymbolTableBuilder {
	return SymbolTableBuilder{MakeSymbolTable()}
}

func (stb *SymbolTableBuilder) Build(tree AST) (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = r.(error)
		}
	}()

	stb.build(tree)

	return err
}

func (stb *SymbolTableBuilder) build(node AST) {
	switch n := node.(type) {
	case BinOp:
		stb.visit_BinOp(n)
	case Num:
		stb.visit_Num(n)
	case UnaryOp:
		stb.visit_UnaryOp(n)
	case Compound:
		stb.visit_Compound(n)
	case Assign:
		stb.visit_Assign(n)
	case Var:
		stb.visit_Var(n)
	case VarDecl:
		stb.visit_VarDecl(n)
	case Type:
		stb.visit_Type(n)
	case NoOp:
		stb.visit_NoOp(n)
	default:
		panic("unknown type node")
	}
}

func (stb *SymbolTableBuilder) visit_BinOp(node BinOp) {
	stb.build(node.Left)
	stb.build(node.Right)
}

func (stb *SymbolTableBuilder) visit_Num(node Num) {
}

func (stb *SymbolTableBuilder) visit_UnaryOp(node UnaryOp) {
	stb.build(node.Expr)
}

func (stb *SymbolTableBuilder) visit_Compound(cmp Compound) {
	for _, node := range cmp.Children {
		stb.build(node)
	}
}

func (stb *SymbolTableBuilder) visit_NoOp(node NoOp) {
}

func (stb *SymbolTableBuilder) visit_VarDecl(node VarDecl) any {
	typeName := node.Type.Value
	typeSymbol := stb.SymTable.lookup(typeName)
	varName := node.Var.Value
	varSymbol := NewVarSymbol(varName, typeSymbol)
	stb.SymTable.define(varSymbol)
	return nil
}

func (stb *SymbolTableBuilder) visit_Assign(node Assign) {
	varName := node.left.Value
	varSymbol := stb.SymTable.lookup(varName)
	if varSymbol == nil {
		panic(fmt.Errorf("%s: %s", ErrNameNodeDefined, varName))
	}
}

func (stb *SymbolTableBuilder) visit_Var(node Var) {
}

func (stb *SymbolTableBuilder) visit_Type(node Type) {
}

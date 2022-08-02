package impl

import "fmt"

var (
	ErrNameNodeDefined = "name node defined"
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

func (stb *SymbolTableBuilder) Build(node AST) any {
	switch n := node.(type) {
	case BinOp:
		return stb.visit_BinOp(n)
	case Num:
		return stb.visit_Num(n)
	case UnaryOp:
		return stb.visit_UnaryOp(n)
	case Compound:
		return stb.visit_Compound(n)
	case Assign:
		return stb.visit_Assign(n)
	case Var:
		return stb.visit_Var(n)
	case VarDecl:
		return stb.visit_VarDecl(n)
	case Type:
		return stb.visit_Type(n)
	case NoOp:
		return stb.visit_NoOp(n)
	default:
		panic("unknown type node")
	}
}

func (stb *SymbolTableBuilder) visit_BinOp(node BinOp) any {
	stb.Build(node.Left)
	stb.Build(node.Right)
	return nil
}

func (stb *SymbolTableBuilder) visit_Num(node Num) any {
	return nil
}

func (stb *SymbolTableBuilder) visit_UnaryOp(node UnaryOp) any {
	return stb.Build(node.Expr)
}

func (stb *SymbolTableBuilder) visit_Compound(cmp Compound) any {
	for _, node := range cmp.Children {
		stb.Build(node)
	}

	return nil
}

func (stb *SymbolTableBuilder) visit_NoOp(node NoOp) any {
	return nil
}

func (stb *SymbolTableBuilder) visit_VarDecl(node VarDecl) any {
	typeName := node.Type.Value
	typeSymbol := stb.SymTable.lookup(typeName)
	varName := node.Var.Value
	varSymbol := NewVarSymbol(varName, typeSymbol)
	stb.SymTable.define(varSymbol)
	return nil
}

func (stb *SymbolTableBuilder) visit_Assign(node Assign) any {
	varName := node.left.Value
	varSymbol := stb.SymTable.lookup(varName)
	if varSymbol == nil {
		panic(fmt.Errorf("%s: %s", ErrNameNodeDefined, varName))
	}
	return nil
}

func (stb *SymbolTableBuilder) visit_Var(node Var) any {
	return nil
}

func (stb *SymbolTableBuilder) visit_Type(node Type) any {
	return nil
}

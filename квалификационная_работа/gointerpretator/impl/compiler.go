package impl

type Compiler interface {
	Compile(tree AST) ([]string, error)
}

package main

import (
	"fmt"
	"os"

	"gointerpretator/impl"
)

func main() {
	data, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}
	lexer := impl.NewLexer(string(data))
	parser := impl.NewParser(lexer)
	tree, err := parser.Parse()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	compiler := impl.NewCompiler()
	_, err = compiler.Compile(tree)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	symTableBuilder := impl.MakeSymbolTableBuilder()
	err = symTableBuilder.Build(tree)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}
}

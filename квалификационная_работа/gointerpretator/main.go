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
	interpreter := impl.NewInterpreter(parser)
	result, err := interpreter.Interpret()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	fmt.Printf("%+v\n", result)
}

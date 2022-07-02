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
	interpreter, err := impl.NewInterpreter(lexer)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	result, err := interpreter.Expr()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	fmt.Printf("%+v\n", result)
}

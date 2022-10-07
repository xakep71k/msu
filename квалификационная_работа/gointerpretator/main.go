package main

import (
	"fmt"
	"os"

	"gointerpretator/impl"
	"gointerpretator/um1"
	"gointerpretator/um2"
	"gointerpretator/um3"
)

func main() {
	opts := readOptsFromCLI()
	data, err := os.ReadFile(opts.SourceFile)
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

	var compiler impl.Compiler

	switch opts.MachineType {
	case "um3":
		compiler = um3.NewCompiler()
	case "um2":
		compiler = um2.NewCompiler()
	case "um1":
		compiler = um1.NewCompiler()
	default:
		fmt.Println("unknown machine type")
		os.Exit(1)
	}

	machineCode, err := compiler.Compile(tree)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	for _, line := range machineCode {
		fmt.Println(line)
	}
}

type Opts struct {
	SourceFile  string
	MachineType string
}

func readOptsFromCLI() Opts {
	if len(os.Args) != 3 {
		fmt.Println("wrong arguments")
		os.Exit(1)
	}

	opts := Opts{
		MachineType: os.Args[1],
		SourceFile:  os.Args[2],
	}

	return opts
}

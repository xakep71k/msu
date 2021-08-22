package main

import (
	"fmt"
	"mylang/internal/app/mylang"
	"os"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s <source file>\n", os.Args[0])
		return
	}

	mylang.RunInterprepeter(os.Args[1])
}

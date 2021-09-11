package mylang

import (
	"fmt"
	"time"
)

func RunInterprepeter(sourceFile string) {
	startA := time.Now()
	parser := MakeParser(sourceFile)
	poliz := parser.analyze()
	durationA := time.Since(startA)

	startE := time.Now()
	executePolize(poliz)
	durationE := time.Since(startE)
	fmt.Printf("Analyzed: time difference = %v\n", durationA)//.Microseconds())
	fmt.Printf("Executed: time difference = %v\n", durationE)//.Microseconds())
}

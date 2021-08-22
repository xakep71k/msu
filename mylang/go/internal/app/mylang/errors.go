package mylang

import (
	"fmt"
	"os"
)

func fatalError(format string, a ...interface{}) {
	fmt.Fprintf(os.Stderr, format+"\n", a...)
	os.Exit(1)
}

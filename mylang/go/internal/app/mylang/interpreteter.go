package mylang

func RunInterprepeter(sourceFile string) {
	parser := MakeParser(sourceFile)
	poliz := parser.analyze()
	executePolize(poliz)
}

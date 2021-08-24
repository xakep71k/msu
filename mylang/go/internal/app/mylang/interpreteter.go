package mylang

func RunInterprepeter(sourceFile string) {
	parser := MakeParser()
	poliz := parser.analyze()
	executePolize(poliz)
}

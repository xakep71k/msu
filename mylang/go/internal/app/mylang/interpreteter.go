package mylang

func RunInterprepeter(sourceFile string) {
	poliz := MakeParser().analyze()
	executePolize(poliz)
}

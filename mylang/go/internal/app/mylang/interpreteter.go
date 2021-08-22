package mylang

func RunInterprepeter(sourceFile string) {
	poliz := parser{}.analyze()
	executePolize(poliz)
}

package mylang

type _Parser struct {
}

func MakeParser() _Parser {
	return _Parser{}
}

func (p _Parser) analyze() []_Lex {
	return nil
}

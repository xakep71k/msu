package mylang

import (
	"bufio"
	"bytes"
	"io"
	"mylang/internal/app/mylang/lex"
	"os"
	"unicode"
)

type _Scanner struct {
	char  chan rune
	close func()
}

func MakeScanner(filename string) <-chan _Lex {
	file, err := os.Open(filename)
	if err != nil {
		fatalError("%s: %v", filename, err)
	}

	result := make(chan _Lex)
	char := make(chan rune)
	go func() {
		reader := bufio.NewReader(file)
		r, _, err := reader.ReadRune()
		if err != nil {
			if err == io.EOF {
				close(char)
			} else {
				fatalError("reading failed: %v", err)
			}
		}
		char <- r
	}()
	scanner := _Scanner{
		char:  char,
		close: func() { _ = file.Close() },
	}

	go func() {
		l := scanner.ScanLex()
		if l.Type() == lex.FIN {
			close(result)
		}
	}()
	return result
}

var TW = []string{
	"",
	"and",
	"begin",
	"bool",
	"do",
	"else",
	"end",
	"if",
	"false",
	"int",
	"not",
	"or",
	"program",
	"read",
	"then",
	"true",
	"var",
	"while",
	"write",
	"writeln",
	"case",
	"of",
	"function",
}

var TD = []string{
	"",
	";",
	",",
	":",
	":=",
	"(",
	")",
	"=",
	"<",
	">",
	"+",
	"-",
	"*",
	"/",
	"<=",
	"!=",
	">=",
}

func look(str string, list []string) int {
	for i := 0; i < len(list); i++ {
		if list[i] == str {
			return i
		}
	}
	return 0
}

func (s _Scanner) ScanLex() _Lex {
	const (
		H = iota
		IDENT
		NUMB
		COM
		ALE
		NEQ
	)

	CS := H
	var d rune
	var j int
	var buf bytes.Buffer
	var c rune

	for {
		var ok bool
		c, ok = <-s.char
		if !ok {
			return _MakeLex(lex.FIN, 0, "")
		}

		switch CS {
		case H:
			if unicode.IsSpace(c) {
				continue
			} else if unicode.IsLetter(c) {
				buf.WriteRune(c)
				CS = IDENT
			} else if unicode.IsDigit(c) {
				d = c - rune('0')
				CS = NUMB
			} else if c == '{' {
				CS = COM
			} else if c == ':' || c == '<' || c == '>' {
				buf.WriteRune(c)
				CS = ALE
			} else if c == '!' {
				buf.WriteRune(c)
				CS = NEQ
			} else {
				buf.WriteRune(c)
				str := buf.String()
				j = look(str, TD)
				if j != 0 {
					return _MakeLex(lex.Type(j+int(lex.FIN)), j, str)
				}
				fatalError("appropriate lexem not found")
			}

		case IDENT:
			if unicode.IsLetter(c) || unicode.IsDigit(c) {
				buf.WriteRune(c)
			} else {
				str := buf.String()
				j = look(str, TD)
				if j != 0 {
					return _MakeLex(lex.Type(j), j, str)
				}
				return _MakeLex(lex.ID, j, str)
			}

		case NUMB:
			if unicode.IsDigit(c) {
				d = d*10 + (c - '0')
			} else {
				return _MakeLex(lex.NUM, int(d), string(c))
			}

		case COM:
			if c == '}' {
				CS = H
			} else if c == '{' {
				fatalError("unexepected {")
			}

		case ALE:
			str := buf.String()
			j = look(str, TD)
			if c == '=' {
				buf.WriteRune(c)
			}
			return _MakeLex(lex.Type(j+int(lex.FIN)), j, str)

		case NEQ:
			str := buf.String()
			j = look(str, TD)
			if c == '=' {
				buf.WriteRune(c)
				return _MakeLex(lex.NEQ, j, str)
			}

			fatalError("unexpected NEQ")
		}
	}
}

package mylang

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"io"
	"mylang/internal/app/mylang/lex"
	"os"
	"unicode"
)

type _Scanner struct {
	char  chan rune
	unget RuneStack
}

func MakeScanner(filename string) <-chan _Lex {
	file, err := os.Open(filename)
	if err != nil {
		fatalError("%v", err)
	}

	result := make(chan _Lex)
	char := make(chan rune)
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		reader := bufio.NewReader(file)
		defer close(char)
		for {
			r, _, err := reader.ReadRune()
			if err != nil {
				if err == io.EOF {
					return
				} else {
					fatalError("reading failed: %v", err)
				}
			}
			select {
			case char <- r:
			case <-ctx.Done():
				return
			}
		}
	}()
	scanner := _Scanner{
		char:  char,
		unget: make(RuneStack, 0),
	}

	go func() {
		for {
			l := scanner.ScanLex()
			result <- l
			if l.Type() == lex.FIN {
				close(result)
				cancel()
				_ = file.Close()
				return
			}
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
	"@",
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

func (s *_Scanner) ScanLex() _Lex {
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
		if s.unget.Size() == 0 {
			c = <-s.char
		} else {
			c = s.unget.Pop()
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
			} else if c == '@' {
				return _MakeLex(lex.FIN, 0, "FIN")
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
				s.unget.Push(c)
				str := buf.String()
				j = look(str, TW)
				if j != 0 {
					return _MakeLex(lex.Type(j), j, str)
				}
				j = putIdent(str)
				return _MakeLex(lex.ID, j, str)
			}

		case NUMB:
			if unicode.IsDigit(c) {
				d = d*10 + (c - '0')
			} else {
				s.unget.Push(c)
				return _MakeLex(lex.NUM, int(d), fmt.Sprint(d))
			}

		case COM:
			if c == '}' {
				CS = H
			} else if c == '@' || c == '{' {
				fatalError("unexepected {")
			}

		case ALE:
			var str string
			if c == '=' {
				buf.WriteRune(c)
				str = buf.String()
				j = look(str, TD)
			} else {
				str = buf.String()
				s.unget.Push(c)
				j = look(str, TD)
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

package lex

type Type int

const (
	NULL Type = iota
	AND
	BEGIN
	BOOL
	DO
	ELSE
	END
	IF
	FALSE
	INT
	NOT
	OR
	PROGRAM
	READ
	THEN
	TRUE
	VAR
	WHILE
	WRITE
	WRITELN
	CASE
	OF
	FUNCTION
	FIN
	SEMICOLON
	COMMA
	COLON
	ASSIGN
	LPAREN
	RPAREN
	EQ
	LSS
	GTR
	PLUS
	MINUS
	TIMES
	SLASH
	LEQ
	NEQ
	GEQ
	NUM
	ID
	POLIZ_LABEL
	POLIZ_FAIL
	POLIZ_ADDRESS
	POLIZ_GO
	POLIZ_FGO
	POLIZ_DUP
	POLIZ_DEL_ARG
	POLIZ_CALL_FUNC
	POLIZ_RETURN_FUNC
	POLIZ_INIT_FUNC_ARG
)

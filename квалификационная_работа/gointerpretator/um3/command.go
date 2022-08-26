package um3

const (
	CMD_STOP        = "001F"
	CMD_ADD_FLOAT   = "0001"
	CMD_ADD_INT     = "000B"
	CMD_PRINT_FLOAT = "000F"
	CMD_PRINT_INT   = "0010"
)

type _Arg struct {
	Arg string
}

type _Addr struct {
	Addr string
}

type _Command struct {
	OpCode string
	Arg1   any
	Arg2   any
	Arg3   any
}

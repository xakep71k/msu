package um2

const (
	CMD_MOVE         = "0000"
	CMD_STOP         = "001f"
	CMD_ADD_FLOAT    = "0001"
	CMD_ADD_INT      = "000b"
	CMD_PRINT_FLOAT  = "000f"
	CMD_PRINT_INT    = "0010"
	CMD_SUB_INT      = "000c"
	CMD_COND_JUMP_GT = "0015"
	CMD_COND_JUMP_LT = "0016"
	CMD_COND_JUMP_EQ = "0017"
	CMD_JUMP         = "0009"
	// CMD_COND_JUMP             = "0013"
	// CMD_CAST_INT64_TO_FLOAT64 = "0014"
	// CMD_DIV_FLOAT64           = "0004"
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
}

type _JumpOutAddr struct {
}

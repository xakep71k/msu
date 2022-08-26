package um3

const (
	FLOAT32_VAR = iota
	INT32_VAR
	FLOAT32_CONST
	INT32_CONST
)

type _VarMeta struct {
	Type int
	Addr string
}

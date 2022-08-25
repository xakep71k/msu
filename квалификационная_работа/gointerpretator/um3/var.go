package um3

const (
	VAR = iota
	FLOAT_CONST
	INT_CONST
)

type _VarMeta struct {
	Type int
	Addr string
}

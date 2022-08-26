package um3

const (
	FLOAT64_VAR = iota
	INT64_VAR
	FLOAT64_CONST
	INT64_CONST
)

type _VarMeta struct {
	Type  int
	Addr  string
	Key   string
	Value any
}

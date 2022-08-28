package um3

import (
	"fmt"
	"gointerpretator/impl"
	"math"

	"github.com/google/uuid"
)

type Compiler struct {
	commands    []_Command
	vars        map[string]_VarMeta
	zeroAddress string
}

func NewCompiler() *Compiler {
	c := &Compiler{
		vars: make(map[string]_VarMeta),
	}

	c.zeroAddress = uuid.New().String()
	c.vars[fmt.Sprintf("%016x", 0)] = _VarMeta{
		Type: INT64_CONST,
		Addr: c.zeroAddress,
	}
	return c
}

func (comp *Compiler) Compile(tree impl.AST) (cmds []string, err error) {
	// fmt.Printf("%+v\n", tree)
	// fmt.Println(comp.vars)

	// defer func() {
	// 	if r := recover(); r != nil {
	// 		err = errors.New(r.(string))
	// 	}
	// }()

	comp.buildMachineCode(tree)
	comp.appendStopCommand()
	addrs := comp.packVariablesAsCommands()
	comp.replaceAddresses(addrs, len(comp.commands))
	comp.prependMetaHeader()
	cmds = comp.convertCommands2String()

	return
}

func (comp *Compiler) prependMetaHeader() {
	comp.commands = append([]_Command{{
		OpCode: "03",
		Arg1:   _Arg{},
		Arg2:   _Arg{},
		Arg3:   _Arg{},
	}}, comp.commands...)
}

func (comp *Compiler) appendStopCommand() {
	comp.commands = append(comp.commands, _Command{
		OpCode: CMD_STOP,
		Arg1:   _Arg{Arg: "0000"},
		Arg2:   _Arg{Arg: "0000"},
		Arg3:   _Arg{Arg: "0000"},
	})
}

func (comp *Compiler) convertCommands2String() (res []string) {
	for _, cmd := range comp.commands {
		line := fmt.Sprintf(
			"%s %s %s %s",
			cmd.OpCode,
			cmd.Arg1.(_Arg).Arg,
			cmd.Arg2.(_Arg).Arg,
			cmd.Arg3.(_Arg).Arg,
		)
		res = append(res, line)
	}

	return
}

func (comp *Compiler) replaceAddresses(addrs map[string]int, until int) {
	makeArgFromAddr := func(arg any) any {
		switch v := arg.(type) {
		case _Addr:
			return _Arg{Arg: fmt.Sprintf("%04x", addrs[v.Addr])}
		default:
			return v
		}
	}

	for i := range comp.commands[:until] {
		comp.commands[i].Arg1 = makeArgFromAddr(comp.commands[i].Arg1)
		comp.commands[i].Arg2 = makeArgFromAddr(comp.commands[i].Arg2)
		comp.commands[i].Arg3 = makeArgFromAddr(comp.commands[i].Arg3)
	}
}

func (comp *Compiler) packVariablesAsCommands() map[string]int {
	addrs := make(map[string]int)

	for k, v := range comp.vars {
		command := _Command{}

		if v.Type == FLOAT64_VAR || v.Type == INT64_VAR {
			command.OpCode = "0000"
			command.Arg1 = _Arg{Arg: "0000"}
			command.Arg2 = _Arg{Arg: "0000"}
			command.Arg3 = _Arg{Arg: "0000"}
		} else {
			command.OpCode = k[:4]
			command.Arg1 = _Arg{Arg: k[4:8]}
			command.Arg2 = _Arg{Arg: k[8:12]}
			command.Arg3 = _Arg{Arg: k[12:16]}
		}
		addrs[v.Addr] = len(comp.commands)
		comp.commands = append(comp.commands, command)
	}

	return addrs
}

func (comp *Compiler) buildMachineCode(node impl.AST) any {
	switch n := node.(type) {
	case impl.BinOp:
		return comp.visit_BinOp(n)
	case impl.Num:
		return comp.visit_Num(n)
	case impl.UnaryOp:
		return comp.visit_UnaryOp(n)
	case impl.Compound:
		return comp.visit_Compound(n)
	case impl.Assign:
		return comp.visit_Assign(n)
	case impl.Var:
		return comp.visit_Var(n)
	case impl.VarDecl:
		return comp.visit_VarDecl(n)
	case impl.Type:
		return comp.visit_Type(n)
	case impl.Print:
		return comp.visit_Print(n)
	case impl.NoOp:
		return comp.visit_NoOp(n)
	case impl.ForLoop:
		return comp.visit_ForLoop(n)
	default:
		return nil
		//panic("unknown type node")
	}
}

func (comp *Compiler) visit_BinOp(node impl.BinOp) any {
	left := comp.buildMachineCode(node.Left).(_VarMeta)
	right := comp.buildMachineCode(node.Right).(_VarMeta)
	tmpVar := uuid.New().String()
	varMeta := _VarMeta{
		Key:  tmpVar,
		Addr: uuid.New().String(),
	}

	switch node.Op.Type {
	case impl.PLUS:
		cmd := _Command{
			Arg1: _Addr{varMeta.Addr},
			Arg2: _Addr{left.Addr},
			Arg3: _Addr{right.Addr},
		}

		switch left.Type {
		case INT64_VAR, INT64_CONST:
			switch right.Type {
			case INT64_VAR, INT64_CONST:
				varMeta.Type = INT64_VAR
				cmd.OpCode = CMD_ADD_INT
			default:
				panic("not supported type1")
			}

		case FLOAT64_VAR, FLOAT64_CONST:
			switch right.Type {
			case FLOAT64_VAR, FLOAT64_CONST:
				varMeta.Type = FLOAT64_VAR
				cmd.OpCode = CMD_ADD_FLOAT
			default:
				panic("not supported type3")
			}
		default:
			panic("not supported type2")
		}

		comp.commands = append(comp.commands, cmd)
	// case impl.MINUS:
	// 	return comp.buildMachineCode(node.Left).(int) - comp.buildMachineCode(node.Right).(int)
	// case MUL:
	// return intr.visit(node.Left).(int) * intr.visit(node.Right).(int)
	case impl.DIV:
		switch left.Type {
		case FLOAT64_VAR, FLOAT64_CONST:
			switch right.Type {
			case INT64_VAR, INT64_CONST:
				right = comp.castINT642FLOAT64(right)
			case FLOAT64_VAR, FLOAT64_CONST:
			default:
				panic("not supported type1")
			}

			cmd := _Command{
				OpCode: CMD_DIV_FLOAT64,
				Arg1:   _Addr{varMeta.Addr},
				Arg2:   _Addr{left.Addr},
				Arg3:   _Addr{right.Addr},
			}
			comp.commands = append(comp.commands, cmd)
		default:
			panic("not supported type2")
		}
	// return intr.visit(node.Left).(int) / intr.visit(node.Right).(int)
	default:
		panic("unknown op")
	}

	comp.vars[tmpVar] = varMeta
	return varMeta
}

func (comp *Compiler) castINT642FLOAT64(v _VarMeta) _VarMeta {
	switch v.Type {
	case FLOAT64_VAR, FLOAT64_CONST:
		panic("only int32")
	}

	tmpVar := uuid.New().String()
	tmpVarMeta := _VarMeta{
		Type: FLOAT64_VAR,
		Key:  tmpVar,
		Addr: uuid.New().String(),
	}
	comp.vars[tmpVar] = tmpVarMeta

	cmd := _Command{
		OpCode: CMD_CAST_INT64_TO_FLOAT64,
		Arg1:   _Addr{tmpVarMeta.Addr},
		Arg2:   _Arg{"0000"},
		Arg3:   _Addr{v.Addr},
	}

	comp.commands = append(comp.commands, cmd)

	return tmpVarMeta
}

func (comp *Compiler) visit_Num(node impl.Num) _VarMeta {
	return comp.addNum(node.Value, uuid.New().String())
}

func (comp *Compiler) addNum(value any, addr string) _VarMeta {
	switch v := value.(type) {
	case float64:
		f := math.Float64bits(v)
		s := fmt.Sprintf("%016x", f)
		if _, ok := comp.vars[s]; !ok {
			comp.vars[s] = _VarMeta{
				Type:  FLOAT64_CONST,
				Addr:  addr,
				Key:   s,
				Value: v,
			}
		}
		return comp.vars[s]
	case int64:
		s := fmt.Sprintf("%016x", uint64(v))
		if _, ok := comp.vars[s]; !ok {
			comp.vars[s] = _VarMeta{
				Type:  INT64_CONST,
				Addr:  addr,
				Key:   s,
				Value: v,
			}
		}
		return comp.vars[s]
	default:
		panic("unsupported type")
	}
}

func (comp *Compiler) visit_UnaryOp(node impl.UnaryOp) any {
	op := node.Op.Type
	if op == impl.PLUS {
		return comp.buildMachineCode(node.Expr)
	} else if op == impl.MINUS {
		varMeta := comp.buildMachineCode(node.Expr).(_VarMeta)
		delete(comp.vars, varMeta.Key)
		switch v := varMeta.Value.(type) {
		case float64:
			varMeta.Value = -v
		case int64:
			varMeta.Value = -v
		}
		return comp.addNum(varMeta.Value, varMeta.Key)
	}

	panic(fmt.Sprintf("invalid operation %s", op))
}

func (comp *Compiler) visit_Compound(cmp impl.Compound) any {
	for _, node := range cmp.Children {
		comp.buildMachineCode(node)
	}

	return nil
}

func (comp *Compiler) visit_Assign(node impl.Assign) any {
	cmd := _Command{
		Arg1: _Addr{comp.vars[node.Left.Value].Addr},
		Arg2: _Addr{comp.zeroAddress},
	}

	varMeta := comp.buildMachineCode(node.Right).(_VarMeta)
	cmd.Arg3 = _Addr{varMeta.Addr}

	switch varMeta.Type {
	case FLOAT64_CONST, FLOAT64_VAR:
		cmd.OpCode = CMD_ADD_FLOAT
	case INT64_CONST, INT64_VAR:
		cmd.OpCode = CMD_ADD_INT
	}

	comp.commands = append(comp.commands, cmd)

	return nil
}

func (comp *Compiler) visit_Var(node impl.Var) _VarMeta {
	varName := node.Value
	val, ok := comp.vars[varName]

	if !ok {
		panic("name error")
	}

	return val
}

func (comp *Compiler) visit_NoOp(node impl.NoOp) any {
	return nil
}

func (comp *Compiler) visit_VarDecl(node impl.VarDecl) any {
	m := _VarMeta{
		Addr: node.Var.Value,
	}

	switch node.Type.Tok.Type {
	case impl.FLOAT64:
		m.Type = FLOAT64_VAR
	case impl.INT64:
		m.Type = INT64_VAR
	}

	comp.vars[node.Var.Value] = m
	return nil
}

func (comp *Compiler) visit_Type(node impl.Type) any {
	return nil
}

func (comp *Compiler) visit_Print(node impl.Print) any {
	varMeta := comp.visit_Var(node.Var)

	cmd := _Command{
		Arg1: _Addr{varMeta.Addr},
		Arg2: _Arg{fmt.Sprintf("%04x", 1)},
		Arg3: _Arg{fmt.Sprintf("%04x", 0)},
	}

	switch varMeta.Type {
	case FLOAT64_CONST, FLOAT64_VAR:
		cmd.OpCode = CMD_PRINT_FLOAT
	case INT64_CONST, INT64_VAR:
		cmd.OpCode = CMD_PRINT_INT
	default:
		panic(fmt.Sprintf("unknown var type %d", varMeta.Type))
	}
	comp.commands = append(comp.commands, cmd)

	return nil
}

func (comp *Compiler) visit_BoolOp(node impl.BoolOp) int {
	left := comp.buildMachineCode(node.Left).(_VarMeta)
	right := comp.buildMachineCode(node.Right).(_VarMeta)

	switch left.Type {
	case INT64_CONST, INT64_VAR:
		switch right.Type {
		case INT64_CONST, INT64_VAR:
			tmpVar := uuid.New().String()
			varMeta := _VarMeta{
				Type: INT64_VAR,
				Key:  tmpVar,
				Addr: uuid.New().String(),
			}
			comp.vars[tmpVar] = varMeta

			cmd := _Command{
				OpCode: CMD_SUB_INT,
				Arg1:   _Addr{varMeta.Addr},
				Arg2:   _Addr{left.Addr},
				Arg3:   _Addr{right.Addr},
			}

			comp.commands = append(comp.commands, cmd)
		default:
			panic("not supported")
		}
	default:
		panic("not supported")
	}

	nextAddress := fmt.Sprintf("%04x", len(comp.commands)+1)
	cmd := _Command{
		OpCode: CMD_COND_JUMP,
		Arg1:   _Arg{nextAddress},
		Arg2:   _Arg{nextAddress},
		Arg3:   _Arg{nextAddress},
	}

	switch node.Op.Type {
	case impl.LESS:
		cmd.Arg3 = _JumpOutAddr{}
	}

	comp.commands = append(comp.commands, cmd)
	return len(comp.commands) - 1
}

func (comp *Compiler) visit_ForLoop(node impl.ForLoop) any {
	comp.visit_Assign(node.Assign)
	startLoopIndex := len(comp.commands)
	jumpOutIndex := comp.visit_BoolOp(node.BoolExpr)
	comp.visit_Compound(node.Body)
	comp.visit_Assign(node.Expr)
	comp.appendCondJump(startLoopIndex)
	comp.correctJumpOutAddr(jumpOutIndex, len(comp.commands))
	return nil
}

func (comp *Compiler) appendCondJump(index int) {
	comp.commands = append(comp.commands, _Command{
		OpCode: CMD_JUMP,
		Arg1:   _Arg{"0000"},
		Arg2:   _Arg{fmt.Sprintf("%04x", index)},
		Arg3:   _Arg{"0000"},
	})
}

func (comp *Compiler) correctJumpOutAddr(cmdJumpIndex int, outIndex int) {
	cmd := comp.commands[cmdJumpIndex]

	correct := func(arg any) any {
		switch v := arg.(type) {
		case _JumpOutAddr:
			return _Arg{fmt.Sprintf("%04x", outIndex)}
		default:
			return v
		}
	}

	cmd.Arg1 = correct(cmd.Arg1)
	cmd.Arg2 = correct(cmd.Arg2)
	cmd.Arg3 = correct(cmd.Arg3)

	comp.commands[cmdJumpIndex] = cmd
}

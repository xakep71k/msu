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
	c.vars[fmt.Sprintf("%016d", 0)] = _VarMeta{
		Type: INT64_CONST,
		Addr: c.zeroAddress,
	}
	return c
}

func (comp *Compiler) Compile(tree impl.AST) ([]string, error) {
	// fmt.Printf("%+v\n", tree)
	comp.visit(tree)
	// fmt.Println(comp.vars)

	comp.appendStopCommand()
	addrs := comp.packVariablesAsCommands()
	comp.replaceAddresses(addrs, len(comp.commands))
	comp.prependMetaHeader()

	return comp.convertCommands2String(), nil
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
	for i := range comp.commands[:until] {
		switch v := comp.commands[i].Arg1.(type) {
		case _Addr:
			comp.commands[i].Arg1 = _Arg{Arg: fmt.Sprintf("%04x", addrs[v.Addr])}
		}

		switch v := comp.commands[i].Arg2.(type) {
		case _Addr:
			comp.commands[i].Arg2 = _Arg{Arg: fmt.Sprintf("%04x", addrs[v.Addr])}
		}

		switch v := comp.commands[i].Arg3.(type) {
		case _Addr:
			comp.commands[i].Arg3 = _Arg{Arg: fmt.Sprintf("%04x", addrs[v.Addr])}
		}
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

func (comp *Compiler) visit(node impl.AST) any {
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
	// switch node.Op.Type {
	// case PLUS:
	// 	return intr.visit(node.Left).(int) + intr.visit(node.Right).(int)
	// case MINUS:
	// 	return intr.visit(node.Left).(int) - intr.visit(node.Right).(int)
	// case MUL:
	// 	return intr.visit(node.Left).(int) * intr.visit(node.Right).(int)
	// case DIV:
	// 	return intr.visit(node.Left).(int) / intr.visit(node.Right).(int)
	// default:
	// 	panic("unknown op")
	// }
	return nil
}

func (comp *Compiler) visit_Num(node impl.Num) _VarMeta {
	switch v := node.Value.(type) {
	case float64:
		f := math.Float64bits(v)
		s := fmt.Sprintf("%016x", f)
		if _, ok := comp.vars[s]; !ok {
			comp.vars[s] = _VarMeta{
				Type: FLOAT64_CONST,
				Addr: uuid.New().String(),
			}
		}
		return comp.vars[s]
	case int64:
		s := fmt.Sprintf("%016x", v)
		if _, ok := comp.vars[s]; !ok {
			comp.vars[s] = _VarMeta{
				Type: INT64_CONST,
				Addr: uuid.New().String(),
			}
		}
		return comp.vars[s]
	default:
		panic("unsupported type")
	}
}

func (comp *Compiler) visit_UnaryOp(node impl.UnaryOp) any {
	op := node.Op.Type
	if op == "+" {
		return comp.visit(node.Expr)
	} else if op == "-" {
		return -comp.visit(node.Expr).(int)
	}

	panic("invalid operation")
}

func (comp *Compiler) visit_Compound(cmp impl.Compound) any {
	for _, node := range cmp.Children {
		comp.visit(node)
	}

	return nil
}

func (comp *Compiler) visit_Assign(node impl.Assign) any {
	cmd := _Command{
		Arg1: _Addr{comp.vars[node.Left.Value].Addr},
		Arg2: _Addr{comp.zeroAddress},
	}

	varMeta := comp.visit(node.Right).(_VarMeta)
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
		Arg2: _Arg{fmt.Sprintf("%04d", 1)},
		Arg3: _Arg{fmt.Sprintf("%04d", 0)},
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

func (comp *Compiler) visit_ForLoop(node impl.ForLoop) any {
	comp.visit(node.Assign)
	return nil
}

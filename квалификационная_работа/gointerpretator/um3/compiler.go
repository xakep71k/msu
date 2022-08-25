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
		Type: INT_CONST,
		Addr: c.zeroAddress,
	}
	return c
}

func (comp *Compiler) Compile(tree impl.AST) ([]string, error) {
	// fmt.Printf("%+v\n", tree)
	comp.visit(tree)
	// fmt.Println(comp.vars)

	addrs := comp.packVarsAsCommands()
	comp.replaceAddresses(addrs, len(comp.commands))

	return comp.convertCommands2String(), nil
}

func (comp *Compiler) convertCommands2String() (res []string) {
	for _, cmd := range comp.commands {
		line := fmt.Sprintf(
			"%s %s %s",
			cmd.OpCode,
			cmd.Arg1.(_Arg).Arg,
			cmd.Arg2.(_Arg).Arg,
		)
		res = append(res, line)
	}

	return
}

func (comp *Compiler) replaceAddresses(addrs map[string]int, until int) {
	for i := range comp.commands[:until] {
		switch v := comp.commands[i].Arg1.(type) {
		case _Addr:
			comp.commands[i].Arg1 = _Arg{Arg: fmt.Sprintf("%06x", addrs[v.Addr])}
		}

		switch v := comp.commands[i].Arg2.(type) {
		case _Addr:
			comp.commands[i].Arg2 = _Arg{Arg: fmt.Sprintf("%06x", addrs[v.Addr])}
		}
	}
}

func (comp *Compiler) packVarsAsCommands() map[string]int {
	addrs := make(map[string]int)

	for k, v := range comp.vars {
		command := _Command{}

		if v.Type == VAR {
			command.OpCode = "0000"
			command.Arg1 = _Arg{Arg: "000000"}
			command.Arg2 = _Arg{Arg: "000000"}
		} else {
			command.OpCode = k[:4]
			command.Arg1 = _Arg{Arg: k[4:10]}
			command.Arg2 = _Arg{Arg: k[10:16]}
		}
		comp.commands = append(comp.commands, command)
		addrs[v.Addr] = len(comp.commands)
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
	// case impl.ForLoop:
	// 	return intr.visit_ForLoop(n)
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

func (comp *Compiler) visit_Num(node impl.Num) any {
	switch v := node.Value.(type) {
	case float32:
		f := math.Float32bits(v)
		s := fmt.Sprintf("%016x", f)
		if _, ok := comp.vars[s]; !ok {
			comp.vars[s] = _VarMeta{
				Type: FLOAT_CONST,
				Addr: uuid.New().String(),
			}
		}
		return _Addr{comp.vars[s].Addr}
	case int32:
		k := fmt.Sprintf("%016x", v)
		if _, ok := comp.vars[k]; !ok {
			comp.vars[k] = _VarMeta{
				Type: INT_CONST,
				Addr: uuid.New().String(),
			}
		}
		return _Addr{comp.vars[k].Addr}
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
		OpCode: "000B",
		Arg1:   _Addr{comp.zeroAddress},
	}

	cmd.Arg2 = comp.visit(node.Right)

	comp.commands = append(comp.commands, cmd)

	return nil
}

func (comp *Compiler) visit_Var(node impl.Var) any {
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
	comp.vars[node.Var.Value] = _VarMeta{
		Type: VAR,
		Addr: node.Var.Value,
	}
	return nil
}

func (comp *Compiler) visit_Type(node impl.Type) any {
	return nil
}

func (comp *Compiler) visit_Print(node impl.Print) any {
	return nil
}

func (comp *Compiler) visit_ForLoop(node impl.ForLoop) any {
	return nil
}

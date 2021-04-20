#include "executer.h"
#include "ident.h"
#include "parser.h"
#include <stack>
#include <iostream>
#include <vector>
#include "tid.h"
#include "error.h"

void Executer::execute(std::vector<Lex> &poliz)
{
    Lex pc_el;
    std::stack<int> args;
    std::stack<std::map<int, Ident>> identsStack;
    identsStack.push(std::map<int, Ident>());

    int i, j, index = 0, size = poliz.size();
    while (index < size)
    {
        std::map<int, Ident> &idents = identsStack.top();
        pc_el = poliz[index];
        const type_of_lex type = pc_el.get_type();
        switch (type)
        {
        case POLIZ_DECLARE_VAR:
        {
            i = pc_el.get_value();
            const Ident &ident = idents[i];
            if (ident.get_declare())
            {
                throw "POLIZ: variable already declared";
            }
            idents[i] = TID[i];
            if (idents[i].get_ret())
            {
                args.push(i);
            }
        }
        break;
        case LEX_TRUE:
        case LEX_FALSE:
        case LEX_NUM:
        case POLIZ_ADDRESS:
        case POLIZ_LABEL:
            args.push(pc_el.get_value());
            break;
        case LEX_ID:
            i = pc_el.get_value();

            if (!idents[i].get_declare())
            {
                THROW_ERROR << "POLIZ: not declared: name '" << idents[i].get_id();
            }
            if (!idents[i].get_assign())
            {
                THROW_ERROR << "POLIZ: not assigned: name '" << idents[i].get_id();
            }

            args.push(idents[i].get_value());
            break;

        case LEX_NOT:
            from_st(args, i);
            args.push(!i);
            break;

        case LEX_OR:
            from_st(args, i);
            from_st(args, j);
            args.push(j || i);
            break;

        case LEX_AND:
            from_st(args, i);
            from_st(args, j);
            args.push(j && i);
            break;

        case POLIZ_CALL_FUNC:
            index = pc_el.get_value() - 1;
            identsStack.push(std::map<int, Ident>());
            break;

        case POLIZ_GO:
            from_st(args, i);
            index = i - 1;
            break;

        case POLIZ_RETURN_FUNC:
            from_st(args, j);
            from_st(args, i);
            index = i - 1;
            if (!idents[j].get_assign())
            {
                throw std::runtime_error("return value not assigned");
            }
            args.push(idents[j].get_value());
            identsStack.pop();
            break;

        case POLIZ_DUP:
            args.push(args.top());
            break;

        case POLIZ_FGO:
            from_st(args, i);
            from_st(args, j);
            if (!j)
            {
                index = i - 1;
            }
            break;

        case LEX_WRITE:
            from_st(args, j);
            std::cout << j;
            break;

        case LEX_WRITELN:
            from_st(args, j);
            std::cout << j << std::endl;
            break;

        case LEX_READ:
            int k;
            from_st(args, i);
            if (TID[i].get_type() == LEX_INT)
            {
                std::cout << "Input int value for " << TID[i].get_name() << std::endl;
                std::cin >> k;
            }
            else
            {
                std::string j;
                while (1)
                {
                    std::cout << "Input boolean value (true or false) for '" << TID[i].get_type() << "'" << std::endl;
                    std::cin >> j;
                    if (j != "true" && j != "false")
                    {
                        std::cout << "Error in input:true/false" << std::endl;
                        continue;
                    }
                    k = (j == "true") ? 1 : 0;
                    break;
                }
            }
            idents[i].put_value(k);
            break;

        case LEX_PLUS:
            from_st(args, i);
            from_st(args, j);
            args.push(i + j);
            break;

        case LEX_TIMES:
            from_st(args, i);
            from_st(args, j);
            args.push(i * j);
            break;

        case LEX_MINUS:
            from_st(args, i);
            from_st(args, j);
            args.push(j - i);
            break;

        case LEX_SLASH:
            from_st(args, i);
            from_st(args, j);
            if (!i)
            {
                args.push(j / i);
                break;
            }
            else
                throw "POLIZ:divide by zero";

        case LEX_EQ:
            from_st(args, i);
            from_st(args, j);
            args.push(i == j);
            break;

        case LEX_LSS:
            from_st(args, i);
            from_st(args, j);
            args.push(j < i);
            break;

        case LEX_GTR:
            from_st(args, i);
            from_st(args, j);
            args.push(j > i);
            break;

        case LEX_LEQ:
            from_st(args, i);
            from_st(args, j);
            args.push(j <= i);
            break;

        case LEX_GEQ:
            from_st(args, i);
            from_st(args, j);
            args.push(j >= i);
            break;

        case LEX_NEQ:
            from_st(args, i);
            from_st(args, j);
            args.push(j != i);
            break;

        case LEX_ASSIGN:
            from_st(args, i);
            from_st(args, j);
            idents[j].put_value(i);
            break;

        case POLIZ_INIT_FUNC_ARG:
            from_st(args, j);
            from_st(args, i);
            idents[j].put_value(i);
            break;

        case POLIZ_FAIL:
            throw std::runtime_error(pc_el.get_str_value());

        case POLIZ_DEL_ARG:
            args.pop();
            break;

        default:
            THROW_ERROR << "POLIZ: unexpected elem: " << pc_el.get_type();
        } //end of switch
        ++index;
    }; //end of while

    if (args.size() != 0)
    {
        throw std::logic_error("executer: args stack not empty");
    }
}

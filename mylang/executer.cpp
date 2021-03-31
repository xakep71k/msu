#include "executer.h"
#include "ident.h"
#include "parser.h"
#include <stack>
#include <iostream>
#include <sstream>
#include <vector>

extern std::vector<Ident> TID;

void Executer::execute(std::vector<Lex> &poliz)
{
    Lex pc_el;
    std::stack<int> args;
    int i, j, index = 0, size = poliz.size();
    while (index < size)
    {
        pc_el = poliz[index];
        const type_of_lex type = pc_el.get_type();
        switch (type)
        {
        case LEX_TRUE:
        case LEX_FALSE:
        case LEX_NUM:
        case POLIZ_ADDRESS:
        case POLIZ_LABEL:
            args.push(pc_el.get_value());
            break;

        case LEX_ID:
            i = pc_el.get_value();
            if (TID[i].get_assign())
            {
                args.push(TID[i].get_value());
                break;
            }
            else
                throw "POLIZ: indefinite identifier";

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

        case POLIZ_GO:
            from_st(args, i);
            index = i - 1;
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
                    std::cout << "Input boolean value (true or false) for " << TID[i].get_name() << std::endl;
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
            TID[i].put_value(k);
            TID[i].put_assign();
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
            TID[j].put_value(i);
            TID[j].put_assign();
            break;

        case POLIZ_FAIL:
            throw std::runtime_error(pc_el.get_str_value());

        case POLIZ_DEL_ARG:
            args.pop();
            break;

        default:
            std::ostringstream os;
            os << "POLIZ: unexpected elem: " << pc_el.get_type();
            throw std::runtime_error(os.str());
        } //end of switch
        ++index;
    }; //end of while

    if (args.size() != 0)
    {
        throw std::logic_error("executer: args stack not empty");
    }
    //std::cout << "Finish of executing!!!" << std::endl;
}
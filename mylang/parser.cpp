#include "parser.h"
#include <iostream>
#include <vector>
#include "ident.h"
#include <string>
#include <algorithm>

extern std::vector<Ident> TID;

std::ostream &operator<<(std::ostream &s, Lex l)
{
    std::string t;
    if (l.t_lex <= LEX_OF)
        t = Scanner::TW[l.t_lex];
    else if (l.t_lex >= LEX_FIN && l.t_lex <= LEX_GEQ)
        t = Scanner::TD[l.t_lex - LEX_FIN];
    else if (l.t_lex == LEX_NUM)
        t = "NUMB";
    else if (l.t_lex == LEX_ID)
        t = TID[l.v_lex].get_name();
    else if (l.t_lex == POLIZ_LABEL)
        t = "Label";
    else if (l.t_lex == POLIZ_ADDRESS)
        t = "Addr";
    else if (l.t_lex == POLIZ_GO)
        t = "!";
    else if (l.t_lex == POLIZ_FGO)
        t = "!F";
    else
        throw l;
    s << '(' << t << ',' << l.v_lex << ");" << std::endl;
    return s;
}

void Parser::analyze()
{
    gl();
    P();
    if (c_type != LEX_FIN)
    {
        throw curr_lex;
    }
}

void Parser::P()
{
    if (c_type == LEX_PROGRAM)
    {
        gl();
    }
    else
    {
        throw curr_lex;
    }

    // тут объявления переменных
    /*
    program
    var <имя>: int|bool[, <имя>: int|bool];
    */
    D1();
    if (c_type == LEX_SEMICOLON)
    {
        gl();
    }
    else
    {
        throw curr_lex;
    }

    // логика программы
    B();
}

void Parser::D1()
{
    if (c_type == LEX_VAR)
    {
        gl();
        D();
        while (c_type == LEX_COMMA)
        {
            gl();
            D();
        }
    }
    else
    {
        throw curr_lex;
    }
}

void Parser::D()
{
    if (c_type != LEX_ID)
    {
        throw curr_lex;
    }
    else
    {
        st_int.push(c_val);
        gl();
        while (c_type == LEX_COMMA)
        {
            gl();
            if (c_type != LEX_ID)
            {
                throw curr_lex;
            }
            else
            {
                st_int.push(c_val);
                gl();
            }
        }
        if (c_type != LEX_COLON)
        {
            throw curr_lex;
        }
        else
        {
            gl();
            if (c_type == LEX_INT)
            {
                dec(LEX_INT);
                gl();
            }
            else if (c_type == LEX_BOOL)
            {
                dec(LEX_BOOL);
                gl();
            }
            else
            {
                throw curr_lex;
            }
        }
    }
}

void Parser::B()
{
    if (c_type == LEX_BEGIN)
    {
        gl();
        S();
        while (c_type == LEX_SEMICOLON)
        {
            gl();
            S();
        }
        if (c_type == LEX_END)
        {
            gl();
        }
        else
        {
            throw curr_lex;
        }
    }
    else
    {
        throw curr_lex;
    }
}

// логические конструкции
void Parser::S()
{
    int pl0, pl1, pl2, pl3;

    if (c_type == LEX_IF)
    {
        gl();
        E();
        eq_bool();
        pl2 = poliz.size();
        poliz.push_back(Lex());
        poliz.push_back(Lex(POLIZ_FGO, 0, "POLIZ_FGO"));
        if (c_type == LEX_THEN)
        {
            gl();
            S();

            if (c_type == LEX_ELSE)
            {
                pl3 = poliz.size();
                poliz.push_back(Lex());
                poliz.push_back(Lex(POLIZ_GO, 0, "POLIZ_GO"));

                gl();
                S();
                poliz[pl3] = Lex(POLIZ_LABEL, poliz.size(), "POLIZ_LABEL");
            }
            poliz[pl2] = Lex(POLIZ_LABEL, poliz.size(), "POLIZ_LABEL");
        }
        else
        {
            throw curr_lex;
        }
    } //end if
    else if (c_type == LEX_CASE)
    {
        case_of();
    }
    else if (c_type == LEX_WHILE)
    {
        pl0 = poliz.size();
        gl();
        E();
        eq_bool();
        pl1 = poliz.size();
        poliz.push_back(Lex());
        poliz.push_back(Lex(POLIZ_FGO));
        if (c_type == LEX_DO)
        {
            gl();
            S();
            poliz.push_back(Lex(POLIZ_LABEL, pl0));
            poliz.push_back(Lex(POLIZ_GO));
            poliz[pl1] = Lex(POLIZ_LABEL, poliz.size());
        }
        else
            throw curr_lex;
    } //end while
    else if (c_type == LEX_READ)
    {
        gl();
        if (c_type == LEX_LPAREN)
        {
            gl();
            if (c_type == LEX_ID)
            {
                check_id_in_read();
                poliz.push_back(Lex(POLIZ_ADDRESS, c_val));
                gl();
            }
            else
                throw curr_lex;
            if (c_type == LEX_RPAREN)
            {
                gl();
                poliz.push_back(Lex(LEX_READ));
            }
            else
                throw curr_lex;
        }
        else
            throw curr_lex;
    } //end read
    else if (c_type == LEX_WRITE || c_type == LEX_WRITELN)
    {
        const type_of_lex lex_write = c_type;
        gl();
        if (c_type == LEX_LPAREN)
        {
            gl();
            E();
            if (c_type == LEX_RPAREN)
            {
                gl();
                poliz.push_back(Lex(lex_write));
            }
            else
                throw curr_lex;
        }
        else
            throw curr_lex;
    } //end write
    else if (c_type == LEX_ID)
    {
        check_id();
        poliz.push_back(Lex(POLIZ_ADDRESS, c_val, "POLIZ_ADDRESS"));
        gl();
        if (c_type == LEX_ASSIGN)
        {
            gl();
            E();
            eq_type();
            poliz.push_back(Lex(LEX_ASSIGN, 0, "LEX_ASSIGN"));
        }
        else
        {
            throw curr_lex;
        }
    } //assign-end
    else
    {
        B();
    }
}

void Parser::E()
{
    E1();
    if (c_type == LEX_EQ || c_type == LEX_LSS || c_type == LEX_GTR ||
        c_type == LEX_LEQ || c_type == LEX_GEQ || c_type == LEX_NEQ)
    {
        st_lex.push(c_type);
        gl();
        E1();
        check_op();
    }
}

void Parser::E1()
{
    T();
    while (c_type == LEX_PLUS || c_type == LEX_MINUS || c_type == LEX_OR)
    {
        st_lex.push(c_type);
        gl();
        T();
        check_op();
    }
}

void Parser::T()
{
    F();
    while (c_type == LEX_TIMES || c_type == LEX_SLASH || c_type == LEX_AND)
    {
        st_lex.push(c_type);
        gl();
        F();
        check_op();
    }
}

void Parser::F()
{
    if (c_type == LEX_ID)
    {
        check_id();
        poliz.push_back(Lex(LEX_ID, c_val, "LEX_ID"));
        gl();
    }
    else if (c_type == LEX_NUM)
    {
        st_lex.push(LEX_INT);
        poliz.push_back(curr_lex);
        gl();
    }
    else if (c_type == LEX_TRUE)
    {
        st_lex.push(LEX_BOOL);
        poliz.push_back(Lex(LEX_TRUE, 1, "true"));
        gl();
    }
    else if (c_type == LEX_FALSE)
    {
        st_lex.push(LEX_BOOL);
        poliz.push_back(Lex(LEX_FALSE, 0, "false"));
        gl();
    }
    else if (c_type == LEX_NOT)
    {
        gl();
        F();
        check_not();
    }
    else if (c_type == LEX_LPAREN)
    {
        gl();
        E();
        if (c_type == LEX_RPAREN)
            gl();
        else
            throw curr_lex;
    }
    else
        throw curr_lex;
}

////////////////////////////////////////////////////////////////

void Parser::dec(type_of_lex type)
{
    int i;
    while (!st_int.empty())
    {
        from_st(st_int, i);
        if (TID[i].get_declare())
            throw "twice";
        else
        {
            TID[i].put_declare();
            TID[i].put_type(type);
        }
    }
}

void Parser::check_const_case_type(type_of_lex case_type)
{
    if (case_type == LEX_BOOL)
    {
        switch (c_type)
        {
        case LEX_FALSE:
            break;
        case LEX_TRUE:
            break;
        default:
            std::ostringstream os;
            os << "wrong const type of case: must be true/false: " << c_type;
            throw std::runtime_error(os.str());
        }
    }
    else if (case_type == LEX_INT)
    {
        switch (c_type)
        {
        case LEX_NUM:
            break;
        default:
            std::ostringstream os;
            os << "wrong const type of case: must be num: " << c_type;
            throw std::runtime_error(os.str());
        }
    }
    else
    {
        throw "wrong case type";
    }
}

int Parser::get_case_val()
{
    switch(c_type) {
        case LEX_TRUE:
        return 1;
        case LEX_FALSE:
        return 0;
        default:
        return c_val;
    }
}

void Parser::case_of()
{
    int pl0, pl1, pl2;
    std::stack<int> labels;
    
    pl0 = poliz.size();
    // забираем выражение внутри скобок case(<выражение>)
    gl();
    E();

    if (c_type == LEX_OF)
    {
        // все константы дожны быть одного типа с выражением case(<выражение>)
        const type_of_lex case_type = st_lex.top();
        std::set<int> consts;

        pl1 = poliz.size();
        gl();
        for(;;)
        {
            // берём константу <константа>:
            check_const_case_type(case_type);

            // проверяем была ли она уже добавлена
            auto result = consts.insert(c_val);
            if (!result.second)
            {
                throw "case/of has duplicate branch";
            }

            // добавляем сравнение с константой
            poliz.push_back(Lex(c_type, get_case_val(), c_str_val));
            poliz.push_back(Lex(LEX_EQ, 0, "case EQ"));

            // аналогично LEX_IF, если условие в case не совпадает
            // с константой, то идём дальше
            pl2 = poliz.size();
            poliz.push_back(Lex());
            poliz.push_back(Lex(POLIZ_FGO, 0, "FGO"));

            // пропускаем символ :
            gl();
            if (c_type != LEX_COLON)
            {
                throw curr_lex;
            }

            // тело ветки case/of
            gl();
            S();
            
            // сюда запишется адрес выхода из ветки
            poliz.push_back(Lex(POLIZ_LABEL, -1, "BREAK CASE"));
            labels.push(poliz.size());
            poliz.push_back(Lex(POLIZ_GO, 0, "GO"));

            // если ветка не подходит, то идём к следующей
            poliz[pl2] = Lex(POLIZ_LABEL, poliz.size(), "POLIZ_LABEL");
            
            if(c_type == LEX_END)
            {
                break;
            }

            // повторяем выражение из case(<выражение>)
            std::vector<Lex> tmp;
            tmp.assign(poliz.begin()+pl0, poliz.begin()+pl1);
            poliz.insert(poliz.end(), tmp.begin(), tmp.end());
        }

        if (consts.size() == 0)
        {
            throw "case/of must have at least one const";
        }

        // заполняем LABEL'ы верными адресами для выхода из тела веток case'а
        while(!labels.empty()) {
            poliz[labels.top()] = Lex(POLIZ_LABEL, poliz.size(), "BREAK CASE");
            labels.pop();
        }

        gl();
    }
    else
    {
        throw curr_lex;
    }
}

void Parser::check_id()
{
    if (TID[c_val].get_declare())
        st_lex.push(TID[c_val].get_type());
    else
        throw "not declared";
}

void Parser::check_op()
{
    type_of_lex t1, t2, op, t = LEX_INT, r = LEX_BOOL;

    from_st(st_lex, t2);
    from_st(st_lex, op);
    from_st(st_lex, t1);

    if (op == LEX_PLUS || op == LEX_MINUS || op == LEX_TIMES || op == LEX_SLASH)
        r = LEX_INT;
    if (op == LEX_OR || op == LEX_AND)
        t = LEX_BOOL;
    if (t1 == t2 && t1 == t)
        st_lex.push(r);
    else
        throw "wrong types are in operation";
    poliz.push_back(Lex(op, 0, "op"));
}

void Parser::check_not()
{
    if (st_lex.top() != LEX_BOOL)
        throw "wrong type is in not";
    else
        poliz.push_back(Lex(LEX_NOT, 0, "LEX_NOT"));
}

void Parser::eq_type()
{
    type_of_lex t;
    from_st(st_lex, t);
    if (t != st_lex.top())
        throw "wrong types are in :=";
    st_lex.pop();
}

void Parser::eq_bool()
{
    if (st_lex.top() != LEX_BOOL)
        throw "expression is not boolean";
    st_lex.pop();
}

void Parser::check_id_in_read()
{
    if (!TID[c_val].get_declare())
        throw "not declared";
}
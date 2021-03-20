#ifndef __LEX_H__
#define __LEX_H__

#include <iostream>

enum type_of_lex
{
    LEX_NULL,
    LEX_AND,
    LEX_BEGIN,
    LEX_WRITE,
    LEX_FIN,
    LEX_SEMICOLON,
    LEX_COMMA,
    LEX_GEQ,
    LEX_NUM,
    LEX_NEQ,
    LEX_ID,
    POLIZ_LABEL,
    POLIZ_ADDRESS,
    POLIZ_GO,
    POLIZ_FGO
};

class Lex
{
    type_of_lex t_lex;
    int v_lex;

public:
    Lex(type_of_lex t = LEX_NULL, int v = 0)
    {
        t_lex = t;
        v_lex = v;
    }
    type_of_lex get_type() const { return t_lex; }
    int get_value() const { return v_lex; }
    friend std::ostream &operator<<(std::ostream &s, Lex l)
    {
        s << '(' << l.t_lex << ',' << l.v_lex << ");";
        return s;
    }
};

#endif

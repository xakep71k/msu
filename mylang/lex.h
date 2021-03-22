#ifndef __LEX_H__
#define __LEX_H__

#include <iostream>
#include <sstream>
#include <string>

enum type_of_lex
{
    LEX_NULL,
    LEX_AND,
    LEX_BEGIN,
    LEX_WRITE,
    LEX_NUM,
    LEX_NEQ,
    LEX_ID,
    LEX_PROGRAM,
    POLIZ_LABEL,
    POLIZ_ADDRESS,
    POLIZ_GO,
    POLIZ_FGO,
    /* order from LEX_FIN to the latest enum item make sense, see Scanner::get_lex() H-state */
    LEX_FIN,
    LEX_SEMICOLON,
    LEX_COMMA,
    LEX_COLON,
    LEX_ASSIGN,
    LEX_LEFT_BRACKET,
    LEX_RIGH_BRACKET,
    LEX_EQ,
    LEX_LE,
    LEX_GE,
    LEX_PLUS,
    LEX_MINUS,
    LEX_ASTERISK,
    LEX_SLASH,
    LEX_LEQ,
    LEX_GEQ,
};

class Lex
{
    type_of_lex t_lex;
    int v_lex;
    std::string s_lex;

public:
    Lex(type_of_lex t = LEX_NULL, int v = 0, const std::string &s = ""):
        t_lex(t),
        v_lex(v),
        s_lex(s)
    {
    }
    type_of_lex get_type() const { return t_lex; }
    int get_value() const { return v_lex; }
    friend std::ostream &operator<<(std::ostream &s, Lex l)
    {
        s << '(' << l.t_lex << ',' << l.v_lex << ", \"" << l.get_str_value() << "\"" <<  ");";
        return s;
    }

    const std::string &get_str_value() const
    {
        return s_lex;
    }
};

#endif

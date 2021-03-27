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
    LEX_BOOL,
    LEX_DO,
    LEX_ELSE,
    LEX_END,
    LEX_IF,
    LEX_FALSE,
    LEX_INT,
    LEX_NOT,
    LEX_OR,
    LEX_PROGRAM,
    LEX_READ,
    LEX_THEN,
    LEX_TRUE,
    LEX_VAR,
    LEX_WHILE,
    LEX_WRITE,
    LEX_WRITELN,
    LEX_CASE,
    LEX_OF,
    LEX_FIN,
    LEX_SEMICOLON,
    LEX_COMMA,
    LEX_COLON,
    LEX_ASSIGN,
    LEX_LPAREN,
    LEX_RPAREN,
    LEX_EQ,
    LEX_LSS,
    LEX_GTR,
    LEX_PLUS,
    LEX_MINUS,
    LEX_TIMES,
    LEX_SLASH,
    LEX_LEQ,
    LEX_NEQ,
    LEX_GEQ,
    LEX_NUM,
    LEX_ID,
    POLIZ_LABEL,
    POLIZ_LATEST_CASE_LABEL,
    POLIZ_ADDRESS,
    POLIZ_GO,
    POLIZ_FGO
};

class Lex
{
    type_of_lex t_lex;
    int v_lex;
    std::string s_lex;

public:
    Lex(type_of_lex t = LEX_NULL, int v = 0, const std::string &s = "") : t_lex(t),
                                                                          v_lex(v),
                                                                          s_lex(s)
    {
    }
    type_of_lex get_type() const { return t_lex; }
    // value - для переменной это index в std::vector<Ident> TID;
    int get_value() const { return v_lex; }
    friend std::ostream & operator<< ( std::ostream &s, Lex l );

    const std::string &get_str_value() const
    {
        return s_lex;
    }
};

#endif

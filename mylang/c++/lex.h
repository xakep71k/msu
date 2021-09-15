#ifndef __LEX_H__
#define __LEX_H__

#include <iostream>
#include <sstream>
#include <string>

enum type_of_lex
{
    LEX_NULL, // 0
    LEX_AND,
    LEX_BEGIN, // 2
    LEX_BOOL,
    LEX_DO, // 4
    LEX_ELSE,
    LEX_END, // 6
    LEX_IF,
    LEX_FALSE, // 8
    LEX_INT,
    LEX_NOT, // 10
    LEX_OR,
    LEX_PROGRAM, // 12
    LEX_READ,
    LEX_THEN, // 14
    LEX_TRUE,
    LEX_VAR, //16
    LEX_WHILE,
    LEX_WRITE, // 18
    LEX_WRITELN,
    LEX_CASE, // 20
    LEX_OF,
    LEX_FUNCTION, // 22
    LEX_FIN,
    LEX_SEMICOLON, // 24
    LEX_COMMA,
    LEX_COLON, // 26
    LEX_ASSIGN,
    LEX_LPAREN, // 28
    LEX_RPAREN,
    LEX_EQ, // 30
    LEX_LSS,
    LEX_GTR, // 32
    LEX_PLUS,
    LEX_MINUS, // 34
    LEX_TIMES,
    LEX_SLASH, // 36
    LEX_LEQ,
    LEX_NEQ, //38
    LEX_GEQ,
    LEX_NUM, // 40
    LEX_ID,
    POLIZ_LABEL, // 42
    POLIZ_FAIL,
    POLIZ_ADDRESS, // 44
    POLIZ_GO,
    POLIZ_FGO, // 46
    POLIZ_DUP,
    POLIZ_DEL_ARG, // 48
    POLIZ_CALL_FUNC,
    POLIZ_RETURN_FUNC, // 50
    POLIZ_INIT_FUNC_ARG
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
    friend std::ostream &operator<<(std::ostream &s, Lex l);

    const std::string &get_str_value() const
    {
        return s_lex;
    }
};

#endif

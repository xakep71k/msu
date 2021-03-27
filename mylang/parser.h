#ifndef __PARSER_H__
#define __PARSER_H__

#include <stack>
#include "scanner.h"
#include "lex.h"
#include <vector>
#include <set>


template <class T, class T_EL>
void from_st ( T & st, T_EL & i ) {
    i = st.top(); st.pop();
}

class Parser
{
    Lex curr_lex;
    type_of_lex c_type;
    int c_val;
    std::string c_str_val;
    Scanner scan;
    std::stack<int> st_int;
    std::stack<type_of_lex> st_lex;
    void P();
    void D1();
    void D();
    void B();
    void S();
    void E();
    void E1();
    void T();
    void F();
    void dec(type_of_lex type);
    void check_id();
    void check_op();
    void case_of();
    int get_case_val();
    void check_const_case_type(type_of_lex case_type);
    void check_not();
    void eq_type();
    void eq_bool();
    void check_id_in_read();
    void gl()
    {
        curr_lex = scan.get_lex();
        c_type = curr_lex.get_type();
        c_val = curr_lex.get_value();
        c_str_val = curr_lex.get_str_value();
    }

public:
    std::vector<Lex> poliz;
    Parser(const char *program) : scan(program) {}
    void analyze();
};

#endif
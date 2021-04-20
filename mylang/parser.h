#ifndef __PARSER_H__
#define __PARSER_H__

#include <stack>
#include "scanner.h"
#include "lex.h"
#include "ident_func.h"
#include <vector>
#include <set>


template <class T, class T_EL>
void from_st ( T & st, T_EL & i ) {
    i = st.top(); st.pop();
}

class Parser
{
    int deep_S;
    Lex curr_lex;
    type_of_lex c_type;
    int c_val;
    std::string c_str_val;
    Scanner scan;
    std::stack<int> st_int;
    std::stack<type_of_lex> st_lex;
    void Program();
    int VarDeclaration();
    int VarExtract();
    void callFunc(const std::string &func_name);
    void FuncExtract();
    void FuncDeclareRetVar(IdentFunc &func);
    void B();
    void S();
    void E();
    void E1();
    void T();
    void F();
    void dec(type_of_lex type);
    void check_id(int);
    void check_op();
    void case_of();
    void repeat_case(int pl0, int pl1);
    int get_case_val();
    void check_const_case_type(type_of_lex case_type);
    void check_not();
    void eq_type();
    void eq_bool();
    void check_id_in_read();
    void get_next_lex()
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
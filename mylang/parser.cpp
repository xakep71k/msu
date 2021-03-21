#include "parser.h"
#include <iostream>
#include "assert.h"

void Parser::analyze()
{
    gl();
    P();
    if (c_type != LEX_FIN)
        throw curr_lex;
    for (Lex l : poliz)
        std::cout << l;
    std::cout << std::endl
              << "Yes!!!" << std::endl;
}

void Parser::P()
{
    if (c_type == LEX_PROGRAM)
        gl();
    else
        throw curr_lex;
    D1();
    if (c_type == LEX_SEMICOLON)
        gl();
    else
        throw curr_lex;
    B();
}

void Parser::D1()
{
    assert("TODO: implement");
}

void Parser::B()
{
    assert("TODO: implement");
}
#ifndef __IDENT_H__
#define __IDENT_H__

#include <string>
#include "lex.h"

class Ident
{
    std::string name;
    bool declare;
    type_of_lex type;
    bool assign;
    int value;

public:
    Ident() : declare(false),
              assign(false)
    {
    }
    Ident(const std::string &n) : name(n),
                                  declare(false),
                                  assign(false)
    {
    }

    bool operator==(const std::string &s) const { return name == s; }
    const char *get_name() { return name.c_str(); }
    bool get_declare() { return declare; }
    void put_declare() { declare = true; }
    type_of_lex get_type() { return type; }
    void put_type(type_of_lex t) { type = t; }
    bool get_assign() { return assign; }
    void put_assign() { assign = true; }
    int get_value() { return value; }
    void put_value(int v) { value = v; }
};

int put(const std::string &buf);

#endif
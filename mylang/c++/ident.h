#ifndef __IDENT_H__
#define __IDENT_H__

#include <string>
#include <vector>
#include <map>
#include "lex.h"

class Ident
{
    std::string name;
    bool declare;
    type_of_lex type;
    bool assign;
    int value;
    std::string id_;
    bool ret;

public:
    Ident() : declare(false),
              assign(false),
              ret(false)
    {
    }
    
    bool operator==(const std::string &s) const
    {
        return id_ == s;
    }

    Ident(const std::string &n) : name(n),
                                  declare(false),
                                  assign(false),
                                  ret(false)
    {
    }

    void set_id(const std::string &id)
    {
        id_ = id;
    }

    const std::string &get_id()
    {
        return id_;
    }

    const std::string &get_name() const
    {
        return name;
    }
    bool get_declare() const
    {
        return declare;
    }
    void put_declare()
    {
        declare = true;
    }
    type_of_lex get_type() const
    {
        return type;
    }
    void put_type(type_of_lex t)
    {
        type = t;
    }
    bool get_assign() const
    {
        return assign;
    }
    int get_value() const
    {
        return value;
    }
    void put_value(int v)
    {
        value = v;
        assign = true;
    }

    bool get_ret() const
    {
        return ret;
    }

    void set_ret()
    {
        ret = true;
    }
};

int put(const std::string &buf);

#endif
#ifndef __TID_H__
#define __TID_H__

#include <map>
#include <string>
#include <vector>
#include <stack>
#include "ident.h"

class TIDType
{
    std::vector<Ident> cur_tid_;
    std::map<std::string, Ident> func_table_;

public:
    TIDType()
    {
    }

    Ident &operator[](int i)
    {
        return cur_tid()[i];
    }

    void push_back(const Ident &ident)
    {
        cur_tid().push_back(ident);
    }

    Ident pop_back()
    {
        Ident ident = cur_tid().back();
        cur_tid().pop_back();
        return ident;
    }

    operator std::vector<Ident> &()
    {
        return cur_tid();
    }

    std::vector<Ident> &cur_tid()
    {
        return cur_tid_;
    }

    bool declare_func(const Ident &ident, int address)
    {
        const std::string &name = ident.get_name();
        if (func_table_.find(name) == func_table_.end())
        {
            return true;
        }
        func_table_[name] = ident;
        func_table_[name].put_value(address);
        return false;
    }

    const Ident &find_func(const std::string &name)
    {
        return func_table_[name];
    }
};

extern TIDType TID;

#endif
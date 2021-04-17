#ifndef __TID_H__
#define __TID_H__

#include <map>
#include <string>
#include <vector>
#include <stack>
#include "ident.h"
#include "ident_func.h"

class TIDType
{
    std::vector<Ident> cur_tid_;
    std::map<std::string, IdentFunc> func_table_;
    std::stack<std::string> func_stack_;

public:
    TIDType()
    {
        func_stack_.push("global");
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

    size_t size() const
    {
        return cur_tid().size();
    }

    std::vector<Ident> &cur_tid()
    {
        return cur_tid_;
    }

    const std::vector<Ident> &cur_tid() const
    {
        return cur_tid_;
    }

    bool declare_func(const Ident &ident, int address)
    {
        const std::string &name = ident.get_name();
        if (func_table_.find(name) != func_table_.end())
        {
            return true;
        }
        func_table_[name] = ident;
        func_table_[name].put_value(address);
        return false;
    }

    IdentFunc &top_func()
    {
        return func_table_[func_stack_.top()];
    }

    const Ident &find_func(const std::string &name)
    {
        return func_table_[name];
    }

    void push_func(const std::string &name)
    {
        func_stack_.push(name);
    }

    void pop_func()
    {
        func_stack_.pop();
    }

    const std::string &top_func_name() const
    {
        return func_stack_.top();
    }
};

extern TIDType TID;

#endif
#ifndef __IDENT_FUNC_H__
#define __IDENT_FUNC_H__

#include "ident.h"
#include <vector>

class IdentFunc : public Ident
{
    std::vector<Ident> args_;
    Lex return_lex_;
    int return_var_;

public:
    IdentFunc()
    {
    }

    IdentFunc(const Ident &ident) : Ident(ident)
    {
    }

    void push_arg(const Ident &ident)
    {
        args_.push_back(ident);
    }

    size_t size_args() const
    {
        return args_.size();
    }

    void set_return_lex(const Lex &lex)
    {
        return_lex_ = lex;
    }

    const Lex &get_return_lex() const
    {
        return return_lex_;
    }

    const Ident &operator[](int i) const
    {
        return args_[i];
    }

    void set_return_var(int i)
    {
        return_var_ = i;
    }

    int get_return_var() const
    {
        return return_var_;
    }
};

#endif
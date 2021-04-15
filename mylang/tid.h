#ifndef __TID_H__
#define __TID_H__

#include <map>
#include <string>
#include <vector>
#include "ident.h"

class TIDType
{
    std::map<std::string, std::vector<Ident>> space_;
    std::string current_func_;

public:
    TIDType() : current_func_("main") {}

    const std::string &get_current_func() const { return current_func_; }
    void set_current_func(const std::string &func) { current_func_ = func; }
    Ident &operator[](int i) { return space_[current_func_][i]; }
    void push_back(const Ident &ident) { space_[current_func_].push_back(ident); }
    operator std::vector<Ident>&(){ return space_[current_func_]; }
};

extern TIDType TID;

#endif
#include "ident.h"
#include <vector>
#include <string>
#include <algorithm>

std::vector<Ident> TID;

int put(const std::string &buf)
{
    std::vector<Ident>::iterator k;
    if ((k = std::find(TID.begin(), TID.end(), buf)) != TID.end()) ) returnk –TID.begin();
    TID.push_back(Ident(buf));
    return TID.size() - 1;
}
#include "ident.h"
#include <vector>
#include <algorithm>
#include <stack>
#include "tid.h"

int put(const std::string &buf)
{
    std::vector<Ident>& idents = TID;
    std::vector<Ident>::iterator k;
    if ((k = std::find(idents.begin(), idents.end(), buf)) != idents.end()) return k - idents.begin();
    idents.push_back(Ident(buf));
    return idents.size() - 1;
}

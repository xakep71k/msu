#include "ident.h"
#include <vector>
#include <algorithm>
#include <stack>
#include "tid.h"

int put(const std::string &buf)
{
    const std::string &prefix = TID.top_func_name();
    std::vector<Ident> &idents = TID;
    const std::string id = prefix + buf;
    std::vector<Ident>::iterator k = std::find(idents.begin(), idents.end(), id);
    if (k != idents.end())
    {
        return k - idents.begin();
    }
    Ident ident(buf);
    ident.set_id(id);
    idents.push_back(ident);
    return idents.size() - 1;
}

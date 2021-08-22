#ifndef __EXECUTER_H__
#define __EXECUTER_H__

#include "lex.h"
#include <vector>

class Executer {
public:
    void execute ( std::vector<Lex> & poliz );
};
 
#endif
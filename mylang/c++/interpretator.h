#ifndef __INTERPRETATOR_H__
#define __INTERPRETATOR_H__

#include "parser.h"
#include "executer.h"

class Interpretator {
    Parser   pars;
    Executer E;
public:
    Interpretator ( const char* program ): pars (program) {}
    void     interpretation ();
};
 
void Interpretator::interpretation () {
    pars.analyze ();
    E.execute ( pars.poliz );
}

#endif
#ifndef __INTERPRETATOR_H__
#define __INTERPRETATOR_H__

#include "parser.h"
#include "executer.h"
#include <chrono>

class Interpretator {
    Parser   pars;
    Executer E;
public:
    Interpretator ( const char* program ): pars (program) {}
    void     interpretation ();
};
 
void Interpretator::interpretation () {
    std::chrono::steady_clock::time_point beginA = std::chrono::steady_clock::now();
    pars.analyze ();
    std::chrono::steady_clock::time_point endA = std::chrono::steady_clock::now();

    std::chrono::steady_clock::time_point beginE = std::chrono::steady_clock::now();
    E.execute ( pars.poliz );
    std::chrono::steady_clock::time_point endE = std::chrono::steady_clock::now();

    std::cout << "Analyzed: time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(endA - beginA).count() << "[µs]" << std::endl;
    std::cout << "Executed: time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(endE - beginE).count() << "[µs]" << std::endl;
}

#endif

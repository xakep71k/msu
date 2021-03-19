#include "ident.h"
#include "lex.h"
#include "scanner.h"
#include <stdexcept>
#include <iostream>

int main()
{
    try
    {
        Scanner scanner("adasfd");
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << std::endl;
    }
    return 0;
}
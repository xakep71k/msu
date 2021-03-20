#include "ident.h"
#include "lex.h"
#include "scanner.h"
#include <stdexcept>
#include <iostream>

int main()
{
    try
    {
        Scanner scanner("myprogram.txt");
    }
    catch(char c) 
    {
        std::cerr << "unexcepted character " << c << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << std::endl;
    }
    return 0;
}
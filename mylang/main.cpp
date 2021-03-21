#include "ident.h"
#include "lex.h"
#include "scanner.h"
#include <stdexcept>
#include <iostream>
#include "parser.h"

int main()
{
    try
    {
        Scanner scanner("example_program.txt");
        for (Lex lex = scanner.get_lex(); lex.get_type() != LEX_FIN; lex = scanner.get_lex())
        {
            std::cout << lex << std::endl;
        }
    }
    catch (char c)
    {
        std::cerr << "unexcepted character " << c << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << std::endl;
    }
    return 0;
}
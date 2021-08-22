#include "ident.h"
#include "lex.h"
#include "scanner.h"
#include <stdexcept>
#include <iostream>
#include "parser.h"
#include "interpretator.h"

int main(int argc, char**argv)
{
    if(argc != 2)
    {
        std::cerr << "Usage: " << argv[0] << " <pascal source code>\n";
        return 1;
    }
    try
    {
        Interpretator I(argv[1]);
        I.interpretation();
    }
    catch (char c)
    {
        std::cout << "unexpected symbol " << c << std::endl;
        return 1;
    }
    catch (Lex l)
    {
        std::cout << "unexpected lexeme" << l << std::endl;
        return 1;
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << std::endl;
    }
    catch (const char *source)
    {
        std::cout << source << std::endl;
        return 1;
    }
    return 0;
}
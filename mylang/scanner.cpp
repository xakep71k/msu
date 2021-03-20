#include "scanner.h"
#include <cctype>
#include "ident.h"
#include "lex.h"

const char *Scanner::TW[] = {
    "and",
    "begin",
    "bool",
    "do",
    "else",
    "end",
    "if",
    "false",
    "int",
    "not",
    "or",
    "program",
    "read",
    "then",
    "true",
    "var",
    "while",
    "write",
    NULL};

const char *Scanner::TD[] = {
    ";",
    "@",
    ",",
    ":",
    ":=",
    "(",
    ")",
    "=",
    "<",
    ">",
    "+",
    "-",
    "*",
    "/",
    "<=",
    ">=",
    NULL};

Lex Scanner::get_lex()
{
    enum state
    {
        H,
        IDENT,
        NUMB,
        COM,
        ALE,
        NEQ
    };
    state CS = H;
    std::string buf;
    int d, j;
    for (;;)
    {
        const char c = gc();
        // обработать EOF
        switch (CS)
        {
        case H:
            if (isspace(c))
            {
                continue;
            }
            else if (isalpha(c))
            {
                buf.push_back(c);
                CS = IDENT;
            }
            else if (isdigit(c))
            {
                d = c - '0';
                CS = NUMB;
            }
            else if (c == '{')
            {
                CS = COM;
            }
            else if (c == ':' || c == '<' || c == '>')
            {
                buf.push_back(c);
                CS = ALE;
            }
            else if (c == '@')
            {
                return Lex(LEX_FIN);
            }
            else if (c == '!')
            {
                buf.push_back(c);
                CS = NEQ;
            }
            else
            {
                buf.push_back(c);
                if ((j = look(buf, TD)))
                    return Lex((type_of_lex)(j + (int)LEX_FIN), j);
                else
                    throw c;
                break;
            case IDENT:
                if (isalpha(c) || isdigit(c))
                {
                    buf.push_back(c);
                }
                else
                {
                    ungc(c);
                    if (j = look(buf, TW))
                        return Lex((type_of_lex)j, j);
                    else
                    {
                        j = put(buf);
                        return Lex(LEX_ID, j);
                    }
                    break;
                case NUMB:
                    if (isdigit(c))
                    {
                        d = d * 10 + (c - '0');
                    }
                    else
                    {
                        ungc(c);
                        return Lex(LEX_NUM, d);
                    }
                    break;
                case COM:
                    if (c == '}')
                    {
                        CS = H;
                    }
                    else if (c == '@' || c == '{')
                        throw c;
                    break;
                case ALE:
                    if (c == '=')
                    {
                        buf.push_back(c);
                        j = look(buf, TD);
                        return Lex((type_of_lex)(j + (int)LEX_FIN), j);
                    }
                    else
                    {
                        ungc(c);
                        j = look(buf, TD);
                        return Lex((type_of_lex)(j + (int)LEX_FIN), j);
                    }
                    break;
                case NEQ:
                    if (c == '=')
                    {
                        buf.push_back(c);
                        j = look(buf, TD);
                        return Lex(LEX_NEQ, j);
                    }
                    else
                        throw '!';
                    break;
                }
            }
        }
    }
}
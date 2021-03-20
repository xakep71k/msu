#ifndef __SCANNER_H__
#define __SCANNER_H__

#include <cstdio>
#include <string>
#include <cerrno>
#include <stdexcept>
#include <cstring>
#include "lex.h"

class Scanner
{
    FILE *fp;
    char c;
    int look(const std::string &buf, const char **list)
    {
        int i = 0;
        while (list[i])
        {
            if (buf == list[i])
                return i;
            i++;
        }
        return 0;
    }
    void gc()
    {
        c = fgetc(fp);
        if (ferror(fp))
        {
            throw std::runtime_error(strerror(errno));
        }
    }
    bool eof()
    {
        return std::feof(fp);
    }

public:
    static const char *TW[], *TD[];
    Scanner(const std::string &program)
    {
        fp = fopen(program.c_str(), "r");
        if (!fp)
        {
            const std::string err_msg = program + std::string(": ") + strerror(errno);
            throw std::runtime_error(err_msg.c_str());
        }
    }
    Lex get_lex();
};

#endif

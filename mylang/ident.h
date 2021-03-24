#ifndef __IDENT_H__
#define __IDENT_H__

#include <string>
#include "lex.h"

class Ident {
    std::string      name;
    bool        declare;
    type_of_lex type;
    bool        assign;
    int          value;
public:
    Ident():declare(false), assign(false) { 
    }
    bool operator== ( const std::string& s ) const { 
        return name == s; 
    }
    Ident ( const std::string &n ): name(n), declare(false), assign(false) {
    }
    std::string get_name () const { 
      return name; 
    }
    bool get_declare () const { 
      return declare; 
    }
    void put_declare () { 
      declare   = true; 
    }
    type_of_lex get_type () const { 
      return type; 
    }
    void put_type ( type_of_lex t ) { 
      type      = t; 
    }
    bool get_assign () const { 
      return assign; 
    }
    void put_assign () { 
      assign    = true; 
    }
    int  get_value () const { 
      return value; 
    }
    void put_value ( int v ) { 
      value     = v; 
    }
};

int put(const std::string &buf);

#endif
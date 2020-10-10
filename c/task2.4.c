/*
 * написать double str2double(const char* str) не используя вспомогательные функции
 */

#include <stdio.h>
#include <stdlib.h>

#define MAX_BUF_SIZE 4097
#define MAX_BUF_SIZE_STR "4097"

double str2double(const char* str);
void error(const char* msg);

int main() {
    int len;
    char buf[MAX_BUF_SIZE];
    while(EOF != scanf("%"MAX_BUF_SIZE_STR"s%n", buf, &len)) {
        if(len == MAX_BUF_SIZE) {
            error("cannot read so big string");
        }
        printf("%.10g\n", str2double(buf));
    }
    return EXIT_SUCCESS;
}

int isfloatsign(char ch) {
    switch(ch) {
        case 'F':
        case 'f':
        case 'L':
        case 'l':
            return 1;
    }
    return 0;
}

typedef struct {
    double value;
    int counter;
} Digit;

int myisdigit(int ch) {
    return ch >= '0' && ch <= '9';
}


int eofstring(const char* str) {
    while(isfloatsign(*str)) {
        ++str;
    }
    return *str == 0;
}

//
// extracting number until not digit character and representing it as a decimal value
// 
Digit extractNumber(const char* str) {
    Digit digit = {0};
    while(!eofstring(str) && myisdigit(*str)) {
       digit.value = digit.value * 10 + *str - '0';
       digit.counter++;
       ++str;
    }
    return digit;
}

void error(const char* msg) {
    fprintf(stderr, "%s\n", msg);
    exit(EXIT_FAILURE);
}

double str2double(const char* str) {
    int depth;
    int isMantisaPositive = 0;
    Digit result = {0}, afterDot = {0}, mantisa = {0};


    //
    // extracting before dot
    //

    result = extractNumber(str);
    str += result.counter;


    //
    // extracting after dot
    //

    if(*str == '.') {
        ++str;
        afterDot = extractNumber(str);
        str += afterDot.counter;
        for(depth = 1; afterDot.counter; --afterDot.counter) {
            depth *= 10;
        }
        result.value += afterDot.value / depth;
    }

    //
    // extracting mantisa
    //

    if(*str == 'e' || *str == 'E') {
        ++str;

        if(*str == '-') {
            isMantisaPositive = 0;
            ++str;
        } else {
            isMantisaPositive = 1;
            if(*str == '+') {
                ++str;
            }
        }

        mantisa = extractNumber(str);
        str += mantisa.counter;

        if(mantisa.counter == 0) {
            error("mantisa is zero");
        }

        for(depth = 1; mantisa.value; --mantisa.value) {
            depth *= 10;
        }

        if(isMantisaPositive) {
            result.value *= depth;
        } else {
            result.value /= depth;
        }
    }

    //
    // checking for wrong format
    //

    if(!eofstring(str)) {
        error("wrong float constant format");
    }

    return result.value;
}


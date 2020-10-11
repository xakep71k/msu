/*
 * написать double str2double(const char* str) не используя вспомогательные функции
 */

#include <stdio.h>
#include <stdlib.h>
#include <float.h>

#define MAX_BUF_SIZE 256
#define MAX_BUF_SIZE_STR "256"
#define MAX_NUMBER_LEN 100
#define MAX_MATISSA 300

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


typedef struct {
    double value;
    int counter;
} Number;

/*
 * вспомогательные функции
 */
int isFloatSign(char ch);
int isDigit(int ch);
int eofString(const char* str);
Number extractNumber(const char* str);

double str2double(const char* str) {
    int isMantissaPositive = 0;
    Number result = {0}, afterDot = {0}, mantissa = {0};

    /*
     * чтение чисел до знака точка
     */
    result = extractNumber(str);
    str += result.counter;


    /*
     * чтение чисел после знака точка
     */
    if(*str == '.') {
        ++str;
        afterDot = extractNumber(str);
        str += afterDot.counter;
        for(; afterDot.counter; --afterDot.counter) {
            afterDot.value /= 10;
        }
        result.value += afterDot.value;
    }

    /*
     * чтение мантиссы
     */
    if(*str == 'e' || *str == 'E') {
        ++str;

        if(*str == '-') {
            isMantissaPositive = 0;
            ++str;
        } else {
            isMantissaPositive = 1;
            if(*str == '+') {
                ++str;
            }
        }

        mantissa = extractNumber(str);
        str += mantissa.counter;

        if(mantissa.counter == 0) {
            error("mantissa not specified");
        }

        if(mantissa.value > MAX_MATISSA) {
            error("too big mantissa");
        }

        for(; mantissa.value; --mantissa.value) {
            if(isMantissaPositive) {
                result.value *= 10;
            } else {
                result.value /= 10;
            }
        }

    }

    /*
     * проверка на неверный формат
     */
    if(!eofString(str)) {
        error("wrong float constant format");
    }

    if(result.value < DBL_MIN || result.value > DBL_MAX) {
        error("double type out of limits");
    }

    return result.value;
}

int isFloatSign(char ch) {
    switch(ch) {
        case 'F':
        case 'f':
        case 'L':
        case 'l':
            return 1;
    }
    return 0;
}


int isDigit(int ch) {
    return ch >= '0' && ch <= '9';
}

int eofString(const char* str) {
    while(isFloatSign(*str)) {
        ++str;
    }
    return *str == 0;
}

/*
 * извлечение числа из строки до символа, который неявляется числом
 */ 
Number extractNumber(const char* str) {
    Number number = {0};
    while(!eofString(str) && isDigit(*str)) {
       number.value = number.value * 10 + *str - '0';
       number.counter++;
       if(number.counter > MAX_NUMBER_LEN) {
           error("too long number");
       }
       ++str;
    }
    return number;
}

void error(const char* msg) {
    fprintf(stderr, "%s\n", msg);
    exit(EXIT_FAILURE);
}


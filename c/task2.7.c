#include <stdio.h>
#include <math.h>
#include <setjmp.h>

jmp_buf begin;
char curlex;
void getlex(void);
int expr(void);
int add(void);
int sub(void);
int mult(void);
int next(void);
int div(void);
int mypow(void);
void error();

int main() {
    int result;
    setjmp(begin);
    printf("==>");
    getlex();
    result = expr();
    if(curlex != '\n') {
        error();
    }
    printf("\n%d\n", result);
    return 0;
}

void getlex()
{
    while ((curlex=getchar()) == ' ');
}

void error(void)
{
    printf("\nОШИБКА!\n");
    //while(getchar() != '\n');
    longjmp(begin, 1);
}

int expr() {
    int e = add();
    while (curlex == '+') {
        getlex();
        e += add();
    }
    return e;
}

int add() {
    int a = sub();
    while (curlex == '-') {
        getlex();
        a -= sub();
    }
    return a;
}

int sub() {
    int a = div();
    int b;
    while (curlex == '/') {
        getlex();
        b = div();
        if(b == 0) {
            error();
        }
        a /= b;
    }
    return a;
}

int div() {
    int a = mypow();
    while (curlex == '*') {
        getlex();
        a *= mypow();
    }
    return a;
}

int mypow() {
    int b;
    int a = next();
    if(curlex == '^') {
        getlex();
        b = mypow();
        if(b < 0) {
            error();
        }
        a = (int)pow(a, b);
    }
    return a;
}

int next()
{
    int m;
    switch(curlex){
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            m = curlex - '0';
            break;
        case '(':
            getlex();
            m = expr();
            if (curlex == ')') {
                break;
            }
        default:
            error();
    }
    getlex(); 
    return m;
}

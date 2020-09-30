/*
 * task 2.2.1 По схеме Горнера.
 * a_0 - свободный член, вводится в конце.
 * Первым вводится a_n * x^n.
 * Нельзя использовать массивы и указатели.
 */
#include <stdio.h>
#include <stdlib.h>

#define MAX_DEEP 1000

typedef struct {
    double res;
    double x;
} ResT;

ResT CalcHornerMethod(double x, int deep);

int main() {
    double x = 0;
    ResT res = {0};
    int ret = scanf("%lf", &x);

    if(ret != 1) {
        fputs("incorrect input\n", stderr);
        return EXIT_FAILURE;
    }

    res = CalcHornerMethod(x, 0);
    printf("%.10f\n", res.res);
    return EXIT_SUCCESS;
}

ResT CalcHornerMethod(double x, int deep) {
    double an = 0;
    int ret = 0;
    ResT res = {0};

    if(deep >= MAX_DEEP) {
        fputs("max deep recursion reached\n", stderr);
        exit(EXIT_SUCCESS);
    }

    ret = scanf("%lf", &an);
    if(ret == EOF) {
        return res;
    }
    if(ret != 1) {
        fputs("incorrect input\n", stderr);
        exit(EXIT_FAILURE);
    }

    res = CalcHornerMethod(x, deep+1);
    if(res.x == 0) {
        res.x = 1;
    } else {
        res.x *= x;
    }
    res.res += res.x * an;
    return res;
}

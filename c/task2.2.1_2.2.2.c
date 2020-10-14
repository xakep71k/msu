/*
 * task 2.2.1 По схеме Горнера.
 * task 2.2.2 Производная от многочлена.
 * a_0 - свободный член, вводится в конце.
 * Первым вводится a_n * x^n.
 * Нельзя использовать массивы и указатели.
 */
#include <stdio.h>
#include <stdlib.h>

int main() {
    double x = 0, ai = 0, result = 0, derivative = 0;
    int ret = scanf("%lf", &x);

    if(ret != 1) {
        fputs("incorrect input\n", stderr);
        return EXIT_FAILURE;
    }

    while(1) {
           ret = scanf("%lf", &ai);
           if(ret == EOF) {
               break;
           }

           if(ret != 1) {
               fputs("incorrect input\n", stderr);
               return EXIT_FAILURE;
           }

           derivative = derivative * x + result;
           result = ai + x * result;
    }

    printf("polynomial = %.10f\n", result);
    printf("derivative = %.10f\n", derivative);
    return EXIT_SUCCESS;
}


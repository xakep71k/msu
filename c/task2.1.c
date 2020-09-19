#include <stdio.h>
#include <stdlib.h>

double mysqrt(double eps, double num);
double myabs(double x);

int main() {
    int res = 0;
    double eps = 0.01, x = 0;

    res = scanf("%lf", &eps);
    if(res != 1) {
        return EXIT_FAILURE;
    }

    while(1) {
        res = scanf("%lf", &x);
        if(res == EOF) {
            return EXIT_SUCCESS;
        }
        if(res != 1) {
            return EXIT_FAILURE;
        }
        printf("%.10f\n", mysqrt(eps, x));
    }

    return EXIT_SUCCESS;
}

double myabs(double x) {
    if(x < 0) {
        return -x;
    }
    return x;
}

double mysqrt(double eps, double x) {
    double xnext = 1, xprev = 1;
    do {
        xprev = xnext;
        xnext = (xprev + x/xprev)/2;
    } while(myabs(xnext - xprev) > eps);
    return xnext;
}

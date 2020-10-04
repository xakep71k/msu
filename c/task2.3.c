/*
 * task 2.3 
 * описать итеративную и рекурсивнюу версии функции для вычисления
 * i-ого члена последовательности Фибоначчи.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MAX_I 93

uint64_t recursion(int i) {
    if(i <= 1) {
        return i;
    }
    return recursion(i - 1) + recursion(i - 2);
}

uint64_t iteration(int i) {
    uint64_t f_0 = 0, f_1 = 1, f_i;
    int k;
    if(i <= 1) {
        return i;
    }
    for(k = 2; k <= i ; ++k) {
        f_i = f_0 + f_1;
        f_0 = f_1;
        f_1 = f_i;
    }
    return f_i;
}

int main() {
    int i;
    if(1 != scanf("%d", &i) || i < 0 || i > MAX_I) {
        fprintf(stderr, "incorrect input, value must be in range [0; %u]\n", MAX_I);
        return EXIT_FAILURE;
    }
    printf("%lu\n", iteration(i));
    printf("%lu\n", recursion(i));
}

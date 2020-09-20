#include <stdio.h>

int countBits(unsigned int x);
void printBits(unsigned int x);
void countAndPrintResult(unsigned int x);

int main() {
    countAndPrintResult(-1);
    countAndPrintResult(0b10101010101010101010101010101010);
    countAndPrintResult(0b10000000000000000000000000000001);
    countAndPrintResult(0b10000000000000011000000000000001);
    return 0;
}

int countBits(unsigned int x) {
    int c = 0;
    while(x) {
        if(x&1) {
            c++;
        }
        x >>= 1;
    }
    return c;
}

void printBits(unsigned int x) {
    const int size = sizeof(x)*8;
    const unsigned int leftBit = (unsigned int)(-1) << (size-1);
    int i;
    for(i = 0; i < size; ++i) {
        if(x&leftBit) {
            printf("1");
        } else {
            printf("0");
        }
        x <<= 1;
    }
}

void countAndPrintResult(unsigned int x) {
    printBits(x);
    printf(", count = %d\n", countBits(x));
}


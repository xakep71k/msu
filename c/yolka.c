#include <stdio.h>
#include <stdlib.h>

void printChars(char c, int length);
void printLine(int starsLength, int fullLength);
void printTreePart(int heightPart, int maxWidth);

int main(int c, char**opts) {
    int countTreePart;
    int i;
    int height;
    if(c != 2) {
        printf("%s <n>\n", opts[0]);
        return EXIT_FAILURE;
    }

    if (1 != sscanf(opts[1], "%d", &countTreePart)) {
        puts("wrong number");
        return EXIT_FAILURE;
    }
    if(countTreePart < 0) {
        puts("the number cannot be negative");
        return EXIT_FAILURE;
    }
    if(countTreePart > 100) {
        puts("parts of tree cannot be more then 100");
        return EXIT_FAILURE;
    }

    const int maxWidth = 1+(countTreePart)*2;
    for(i = 0, height = 2; i < countTreePart; ++i, ++height) {
        printTreePart(height, maxWidth);
    }
    return EXIT_SUCCESS;
}

void printChars(char c, int length) {
    int i;
    for(i = 0; i < length; ++i) {
        printf("%c", c);
    }
}

void printLine(int starsLength, int fullLength) {
    const int padding = (fullLength-starsLength)/2;
    printChars(' ', padding);
    printChars('*', starsLength);
    printChars(' ', padding);
    puts("");
}

void printTreePart(int height, int maxWidth) {
    int starsCount;
    for(starsCount = 1; height; height--, starsCount += 2){
        printLine(starsCount, maxWidth);
    }
}

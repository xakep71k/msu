/*
 * написать double str2double(const char* str) не используя вспомогательные функции
 */

#include <stdio.h>
#include <stdlib.h>

#define MAX_BUF_SIZE 4097
#define MAX_BUF_SIZE_STR "4097"

int main() {
    int len;
    char buf[MAX_BUF_SIZE];
    while(EOF != scanf("%"MAX_BUF_SIZE_STR"s%n", buf, &len)) {
        if(len == MAX_BUF_SIZE) {
            fputs("cannot read so big string\n", stderr);
            return EXIT_FAILURE;
        }
        puts(buf);
    }
    return EXIT_SUCCESS;
}

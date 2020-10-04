/*
 * написать double str2double(const char* str) не используя вспомогательные функции
 */

#include <stdio.h>
#define MAX_BUF_SIZE 4096
#define MAX_BUF_SIZE_STR "4096"

int main() {
    char buf[MAX_BUF_SIZE];
    /*
    while(fgets(buf, MAX_BUF_SIZE, stdin) != NULL) {
        puts(buf);
    }
    */
    scanf("%"MAX_BUF_SIZE_STR"s", buf);
    puts(buf);
    return 0;
}

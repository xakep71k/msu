#include <stdio.h>
#include <stdio.h>

int main () {
    //
    // сколько байт отведено для типов
    //
    printf("short=%lu, int=%lu, long=%lu, float=%lu, double=%lu, long double=%lu\n", 
        sizeof(short),
        sizeof(int),
        sizeof(long),
        sizeof(float),
        sizeof(double),
        sizeof(long double));
    
    //
    // типа char signed или unsigned
    //
    if((char)-1 < 0) {
        puts("char is sign");
    } else {
        puts("char is unsign");
    }
    return 0;
}

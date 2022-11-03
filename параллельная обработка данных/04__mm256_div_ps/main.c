#include <stdio.h>
#include <immintrin.h>

//
// программа делит один вектор на другой с помощью SIMD инструкции
//
int main()
{
    __m256 float_vec_0 = _mm256_set_ps(1, 2, 3, 4, 5, 6, 7, 8); // один вектор
    __m256 float_vec_1 = _mm256_set_ps(9, 10, 11, 12, 13, 14, 15, 16); // другой

    __m256 float_result = _mm256_div_ps(float_vec_0, float_vec_1); // деление векторов

    float *ret = (float*) &float_result;
    printf(
        "ret: %f, %f, %f, %f, %f, %f, %f, %f\n",
        ret[0],
        ret[1],
        ret[2],
        ret[3],
        ret[4],
        ret[5],
        ret[6],
        ret[7]);

    return 0;
}
#include <time.h>
#include <stdlib.h>

#define MATRIX_N_SIZE 2
#define MATRIX_M_SIZE 2

void initMatrixWithRandom(float matrix[MATRIX_M_SIZE][MATRIX_N_SIZE]) {
    int k = 1;
    for (int i = 0; i < MATRIX_M_SIZE; i++) {
        for (int j = 0; j < MATRIX_M_SIZE; j++) {
            matrix[i][j] = k;
            k++;
        }
    }
}

int multiplyMatrix(float matrix1[MATRIX_M_SIZE][MATRIX_N_SIZE], float matrix2[MATRIX_M_SIZE][MATRIX_N_SIZE]) {
    int countOps = 0;
    for (int i = 0; i < MATRIX_M_SIZE; i++) {
    
    }
    return countOps;
}

int main() {
    float matrix1[MATRIX_M_SIZE][MATRIX_N_SIZE];
    float matrix2[MATRIX_M_SIZE][MATRIX_N_SIZE];

    srand(time(NULL));
    multiplyMatrix(matrix1, matrix2);
    return 0;
}

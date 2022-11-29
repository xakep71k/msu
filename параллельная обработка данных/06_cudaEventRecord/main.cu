#include <cuda.h>
#include <stdio.h>
//
// Программа фиксирует два события с помощью cudaEventRecord и выводит время между ними
//

__global__ void kernel() {}

int main()
{
    // Создаем события
    cudaEvent_t event1, event2;
    cudaEventCreate(&event1);
    cudaEventCreate(&event2);

    // Фиксируем события до и после запуска kernel
    cudaEventRecord(event1, 0); // 0 - поток по умолчанию
    dim3 grid(3,2,1), block(4,3,1);
    kernel<<<grid, block>>>();
    cudaEventRecord(event2, 0);

    // Синхронизируем события
    cudaEventSynchronize(event1); // Не обязательно
    cudaEventSynchronize(event2); // Дожидаеся когда будет выполнено

    // Вычисляем время между cudaEventRecord
    float dt_ms;
    cudaEventElapsedTime(&dt_ms, event1, event2);
    printf("%f\n", dt_ms);

    return 0;
}

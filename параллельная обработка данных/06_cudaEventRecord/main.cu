#include <cuda.h>
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
    kernel<<<1,1>>>();
    cudaEventRecord(event2, 0);

    // Синхронизируем события
    cudaEventSynchronize(event1); // Не обязательно
    cudaEventSynchronize(event2); // Дожидаеся когда будет выполнено

    // Вычисляем время между cudaEventRecord
    float dt_ms;
    cudaEventElapsedTime(&dt_ms, event1, event2);

    return 0;
}

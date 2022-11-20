#include <stdio.h>
#include <string.h>
#include <mpi.h>

//
// программа демонстрирует пример испольования MPI_Cancel
// программа пораждает процессы, которые отправляют главному процессу Hello, World!
// и сразу происходит отмена запроса, в результате мы получаем None
// запуск программы make run 

int main (int argc, char **argv)
{
    int myid, numprocs, source; // id процессов
    MPI_Status status; // Для статуса
    char message[100]; // Буфер для первого сообщения
    char message2[100]; // Буфер для второго сообщения
    MPI_Request request; // Обьявляем запрос
    MPI_Init (&argc, &argv); // Стартуем MPI

    MPI_Comm_rank (MPI_COMM_WORLD, &myid);
    MPI_Comm_size (MPI_COMM_WORLD, &numprocs);

    if (myid != 0)
    {
        strcpy(message, "Hello World!"); // Иницилизируем первое сообщение
        strcpy(message2, "Hello World!"); // Второе
        MPI_Send(message, strlen(message) + 1, MPI_CHAR, 0, 99, MPI_COMM_WORLD); // Отправляем первое
        MPI_Isend(message2, strlen(message2) + 1, MPI_CHAR, 0, 99, MPI_COMM_WORLD, &request); // Отправляем второе
    }
    else
    {
        for (source = 1; source < numprocs; source++)
        {
            MPI_Recv(message, 100, MPI_CHAR, source, 99, MPI_COMM_WORLD, &status); // Получаем первое сообщение
            printf("Process %d recive %s from process %d\n", myid, message, source); // Выводим результат
            strcpy(message2, "None"); // Очищаем буфер второго сообщения чтобы не выводить мусор
            MPI_Irecv(message2, 100, MPI_CHAR, source, 99, MPI_COMM_WORLD, &request); // Получаем второе
            MPI_Cancel(&request); // Отменяем запрос
            printf("MPI_Cancel works\n");
            printf("Process %d recive %s from process %d\n", myid, message2, source); // Выводим результат
            printf("-----");
        }
    }

    MPI_Finalize();

    return 0;
}

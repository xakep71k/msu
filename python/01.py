# -*- coding: utf-8 -*-

#
# Написать программу, вычисляющую НОД двух целых чисел
# https://ru.wikipedia.org/wiki/Алгоритм_Евклида
#
def euclidean_algorithm(a, b):
    if a < b:
        tmp = b
        b = a
        a = tmp
    if a % b == 0:
        return b
    return euclidean_algorithm(a - b, a)

#
# Реализовать алгоритм "решето эратосфена". На вход подается натуральное число N,
# необходимо вывести на печать все простые числа не превосходящие данное.
# https://ru.wikipedia.org/wiki/Решето_Эратосфена
#
def sieve_of_eratosthenes(n):
    if n <= 1:
        return []
    n += 1
    numbers = [1] * (n)

    for i in range(2, my_abs(n)):
        if numbers[i] == 0:
            continue
        for j in range(i, (n/i)+1):
            if i*j > n-1:
                break
            numbers[i*j] = 0

    return [i for i in range(2,n) if numbers[i] != 0]

# Поиск корня из натурального числа.
# Необходимо реализовать алгоритм поиска корня из натурального числа с заданной точностью.
# На входе 2 параметра N- число и e- точность, с которой необходимо вычислить корень.
# Пример: my_sqrt(2, 0.01) возвращает 1.41
def my_abs(n):
    if n < 0:
        return -n
    return n

def my_sqrt(n, eps):
    x = 1.0
    while True:
        nx = (x + n / x) / 2.0
        if my_abs(x - nx) < eps:
            break
        x = nx
    return x

if __name__ == '__main__': 
    assert euclidean_algorithm(48, 36) == euclidean_algorithm(36, 48)
    assert euclidean_algorithm(48, 36) == 12
    assert sieve_of_eratosthenes(1) == []
    assert sieve_of_eratosthenes(50) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    assert my_abs(1.41 - my_sqrt(2, 0.01)) < 0.01
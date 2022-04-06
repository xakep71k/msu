# -*- coding: utf-8 -*-
import re
import sys

# Дана последовательность целых чисел, заканчивающаяся числом 0. Выведите эту последовательность в обратном порядке.
# При решении этой задачи нельзя пользоваться массивами и прочими динамическими структурами данных. Рекурсия вам поможет.
def reverse_order(seq):
    if len(seq) == 0:
        return []
    if len(seq) == 1:
        return [seq[0]]
    return reverse_order(seq[1:]) + [seq[0]]

# Во входном файле записано два целых числа, которые могут быть разделены пробелами и концами строк. 
# Выведите в выходной файл их сумму.
# Указание. Считайте весь файл в строковую переменную при помощи метода read() и разбейте ее на части при помощи метода split().
def sum_to_file(filename_in, filename_out):
    f = open(filename_in, "r")
    content = f.read().strip()
    f.close()

    two_numbers = re.split(" |\n", content)
    res = int(two_numbers[0]) + int(two_numbers[1])
    f = open(filename_out, "w")
    print(res)
    f.write(str(res))
    f.close()

# Во входном файле записана одна текстовая строка, возможно, содержащая пробелы. Выведите эту строку в обратном порядке.
# Строка во входном файле заканчивается символом конца строки '\n'.
def reverse_str(filename):
    f = open(filename, "r")
    content = f.read().strip()
    print(content[::-1])

# Выведите все строки данного файла в обратном порядке. Для этого считайте список всех строк при помощи метода readlines().
# Последняя строка входного файла обязательно заканчивается символом '\n'.
def reverse_each_str(filename):
    with open(filename) as f:
        for line in f:
            print(line.strip()[::-1])


# В выходной файл выведите все строки наибольшей длины из входного файла, не меняя их порядок.
# В данной задаче удобно считать список строк входного файла целиком при помощи метода readlines
def max_strings(filename_in, filename_out):
    with open(filename_in, 'r') as f:
        max_len = 0
        for line in f:
            cur_len = len(line.strip())
            if max_len < cur_len:
                max_len = cur_len

    with open(filename_in, 'r') as f:
        out = open(filename_out, 'a')
        for line in f:
            cur_len = len(line.strip())
            if max_len == cur_len:
                out.write(line)
        out.close()

                


if __name__ == '__main__':
    assert reverse_order([1, 2, 3, 4]) == [4, 3, 2, 1]
    sum_to_file(sys.argv[1], sys.argv[2])
    reverse_str(sys.argv[3])
    reverse_each_str(sys.argv[4])
    max_strings(sys.argv[5], sys.argv[6])


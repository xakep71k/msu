# -*- coding: utf-8 -*-

#
# Дан одномерный массив числовых значений, насчитывающий N элементов.
# Определить, имеются ли в массиве два подряд идущих нуля.
#
def check_if_zeros_in_row(aa):
    count_zeros = 0
    for a in aa:
        if a == 0:
            count_zeros +=1
        else:
            count_zeros = 0
        if count_zeros == 2:
            return True
    return False

#
# Дан одномерный массив числовых значений, насчитывающий N элементов.
# Вместо каждого элемента с нулевым значением поставить сумму двух предыдущих элементов массива.
#
def sum_instead_zero(aa):
    i = 0
    while i < len(aa):
        if aa[i] == 0:
            j = i - 2
            if j < 0:
                j = 0
            aa[i] = sum(aa[j:i])
        i += 1

    return aa

# Дан одномерный массив числовых значений, насчитывающий N элементов.
# Исключить из массива элементы, принадлежащие промежутку [B; C].
def exclude_interval(arr, a, b):
    new_arr = arr[0:a] + arr[b+1:len(arr)]
    return new_arr
        
#
# Дан одномерный массив числовых значений, насчитывающий N элементов.
# Добавить к элементам массива такой новый элемент,
# чтобы сумма элементов с положительными значениями стала бы равна модулю
# суммы элементов с отрицательными значениями.
#
def append_balanced_item(aa):
    pos_sum = 0
    neg_sum = 0
    for a in aa:
        if a < 0:
            neg_sum += a
        else:
            pos_sum += a
    all_sum = neg_sum + pos_sum

    if all_sum != 0:
        aa.append(-all_sum)
    return aa


if __name__ == '__main__':
    assert check_if_zeros_in_row([]) == False
    assert check_if_zeros_in_row([1, 2, 3]) == False
    assert check_if_zeros_in_row([1, 2, 3, 0, 0]) == True
    assert check_if_zeros_in_row([1, 2, 3, 4, 0]) == False
    assert check_if_zeros_in_row([1, 0, 3, 4, 0]) == False

    assert sum_instead_zero([1, 2, 3]) == [1, 2, 3]
    assert sum_instead_zero([1, 2, 3, 0]) == [1, 2, 3, 5]
    assert sum_instead_zero([0, 2, 3]) == [0, 2, 3]
    assert sum_instead_zero([1, 0, 3]) == [1, 1, 3]

    assert exclude_interval([1, 2, 3, 4, 5, 6], 2, 4) == [1, 2, 6]
    assert exclude_interval([1, 2, 3, 4, 5, 6], 0, 0) == [2, 3, 4, 5, 6]
    assert exclude_interval([1, 2, 3, 4, 5, 6], 5, 5) == [1, 2, 3, 4, 5]

    assert append_balanced_item([1, 2, 3]) == [1, 2, 3, -6]
    assert append_balanced_item([1, -1]) == [1, -1]
    assert append_balanced_item([0]) == [0]
    assert append_balanced_item([1, -2]) == [1, -2, 1]


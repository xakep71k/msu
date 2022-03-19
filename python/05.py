# -*- coding: utf-8 -*-

# Даны два словаря: dictionary_1 = {'a': 300, 'b': 400} и dictionary_2 = {'c': 500, 'd': 600}.
# Объедините их в один при помощи встроенных функций языка Python.
def concat_dicts(a, b):
    c = dict()
    c.update(a)
    c.update(b)
    return c

# Дан словарь с числовыми значениями. Необходимо их все перемножить и вывести на экран.
def mul_dicts_values(a):
    res = 1
    for k, v in a.items():
        print(k, v)
        res *= v
    
    if len(a) == 0:
        res = 0

    print(res)
    return res

# Создайте словарь, в котором ключами будут числа от 1 до 10, а значениями эти же числа, возведенные в куб.
def cube_dict():
    res = dict()
    for i in range(1, 11):
        res[i] = i*i*i
    return res

# Даны два списка одинаковой длины.
# Необходимо создать из них словарь таким образом, чтобы элементы первого списка были ключами,
# а элементы второго — соответственно значениями нашего словаря.
def dict_from_lists(a, b):
    assert len(a) == len(b)
    return { a[i] : b[i] for i in range(len(a)) }

if __name__ == '__main__':
    assert concat_dicts({'a': 300, 'b': 400},  {'c': 500, 'd': 600}) == {'a': 300, 'b': 400, 'c': 500, 'd': 600}
    assert mul_dicts_values({'a': 300, 'b': 400}) == 120000
    assert cube_dict() == {1: 1, 2: 8, 3: 27, 4: 64, 5: 125, 6: 216, 7: 343, 8: 512, 9: 729, 10: 1000}
    assert dict_from_lists(['a', 'b'], [300, 400]) == {'a': 300, 'b': 400}

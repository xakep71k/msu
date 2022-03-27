# -*- coding: utf-8 -*-

# Задача 1.
# Из входной строки удалить все пробелы и определить, является ли новая строка палиндроном. 
# Если строка — палиндром, удалить из неё все повторяющиеся символы, если нет, то напечатать перевёрнутую строку.
def palindrome(s):
    s = s.replace(" ", "")
    reversed_s = s[::-1]
    if s == reversed_s:
        return "".join(dict.fromkeys(s))
    print(reversed_s)
    return reversed_s

# Задача 2. 
# 1. Из входной строки определить 3 наиболее часто встречаемых символа в ней. 
# 2. Пробелы нужно игнорировать (не учитывать при подсчете). 
# 3. Для выведения результатов вычислений требуется написать функцию top3(str)
# 4. Итог работы функции top3 —строка следующего вида: символ – количество раз, символ – количество раз... например       ‘a-5, m-3, h-1’
def top3(s):
    d = dict()
    for char in s:
        if char == ' ':
            continue
        if char in d:
            d[char] += 1
        else:
            d[char] = 1
    tups = d.items()
    sorted_tups = sorted(tups, key=lambda tup: tup[1], reverse=True)
    result = []
    for item in sorted_tups:
        if len(result) == 3:
            break
        result.append("{} - {}".format(item[0], item[1]))

    result = ", ".join(result)
    print(result)
    return result


if __name__ == '__main__':
    assert palindrome("a b   c c b a") == "abc"
    assert palindrome("abc") == "cba"
    assert top3("abcddefa") == "a - 2, d - 2, b - 1"


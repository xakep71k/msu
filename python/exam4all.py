# 1. задание
# Строки в Питоне сравниваются на основании значений символов.
# Требуется создать класс RealString в котором реализовать сравнение строк по количеству входящих в них символов.
# Сравнивать между собой можно как объекты класса, так и обычные строки с экземплярами класса RealString.
# Реализовать метод isPalindrom(), возвращающий True или False в зависимости от того, является ли слово палиндромом
class RealString:
    def __init__(self, s):
        self.s = s

    def __lt__(self, o):
        s = str(o)
        return len(self.s) < len(s)

    def __gt__(self, o):
        s = str(o)
        return len(self.s) > len(s)

    def __le__(self, o):
        s = str(o)
        return len(self.s) <= len(s)

    def __ge__(self, o):
        s = str(o)
        return len(self.s) >= len(s)

    def __eq__(self, o):
        s = str(o)
        return len(self.s) == len(s)

    def __ne__(self, o):
        s = str(o)
        return len(self.s) != len(s)

    def __str__(self):
        return self.s

# 2. задание:
# Реализовать класс Real_text. Элементом которого является список из элементов RealString.
# Реализовать в этом классе конструктор чтения слов из файла.
# Реализовать метод + сумма двух экземпляров,т.е. Real_text =Real_text+ Real_text.
# Реализовать метод сохранения Real_text в файл. Не забываем  слова сохранять через пробел.
class Real_text:
    def __init__(self, filename):
        self.strings = list()
        if len(filename) != 0:
            with open(filename,'r') as file:
                for line in file:
                    for word in line.split():
                        self.strings.append(RealString(word))

    def	__add__(self, o):
        strings = self.strings + o.strings
        new = Real_text("")
        new.strings = strings
        return new

if __name__ == '__main__':
    import sys

    rstring = RealString('abc')
    assert rstring <= 'abc'
    assert rstring >= 'abc'
    assert rstring == 'abc'
    assert rstring < 'abcd'
    assert rstring > 'ab'
    assert rstring <= 'abcd'
    assert rstring >= 'ab'
    assert rstring != 'a'
    assert rstring <= RealString('abc')
    assert rstring >= RealString('abc')
    assert rstring == RealString('abc')
    assert rstring < RealString('abcd')
    assert rstring > RealString('ab')
    assert rstring <= RealString('abcd')
    assert rstring >= RealString('ab')
    assert rstring != RealString('a')

    text1 = Real_text(sys.argv[1])
    text2 = Real_text(sys.argv[2])

    print("text1:", ' '.join(map(str, text1.strings)))
    print("text2:", ' '.join(map(str, text2.strings)))

    text3 = text1 + text2
    print("text3:", ' '.join(map(str, text3.strings)))

    assert text3.strings == text1.strings + text2.strings

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

    def isPalindrom(self):
        i = 0
        j = len(self.s) - 1

        while i < j:
            if self.s[i] != self.s[j]:
                return False
            i += 1
            j -= 1

        return True

# 2. задание:
# Реализовать класс Real_text. Элементом которого является список из элементов RealString.
# Реализовать в этом классе конструктор чтения слов из файла.
# Реализовать метод + сумма двух экземпляров,т.е. Real_text =Real_text+ Real_text.
# Реализовать метод сохранения Real_text в файл. Не забываем  слова сохранять через пробел.
class Real_text:
    def __init__(self, filename=None):
        self.strings = list()
        if filename:
            with open(filename,'r') as file:
                for line in file:
                    for word in line.split():
                        self.strings.append(RealString(word))

    def	__add__(self, o):
        strings = self.strings + o.strings
        new = Real_text()
        new.strings = strings
        return new

    def save_to_file(self, filename):
        with open(filename, 'w') as f:
            f.write(str(self))

    def __str__(self):
        return ' '.join(map(str, self.strings))

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
    assert not (rstring <= 'ab')
    assert not (rstring >= 'abcd')
    assert not (rstring == '1')
    assert not (rstring < '2')
    assert not (rstring > 'abcd')
    assert not (rstring != 'abc')
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

    assert not rstring.isPalindrom()
    assert RealString('abcba').isPalindrom()

    print("text1:", str(text1))
    print("text2:", str(text2))

    text3 = text1 + text2
    print("text3:", str(text3))

    assert text3.strings == text1.strings + text2.strings

    text3.save_to_file(sys.argv[3])

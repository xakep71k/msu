# -*- coding: utf-8 -*-

#
# Реализовать класс Tlist:
#

#
# операторы  << и >> осуществляют циклический сдвиг массива влево и вправо соответственно. 
#
class Tlist:
    def __init__(self, vec, p):
        vec = list(vec)
        i = 0
        reverse = False
        result = list()

        while i < len(vec):
            tmp = vec[i: i+p]
            tmp.sort(reverse=reverse)
            result.extend(tmp)
            i += p
            reverse = not reverse

        self.vec = result

    def __rshift__(self, other):
        while other != 0:
            self._rshift()
            other -= 1

    def __lshift__(self, other):
        while other != 0:
            self._lshift()
            other -= 1

    def _rshift(self):
        if len(self.vec) == 0:
            return

        next_item = self.vec[0]
        i = 1
        while i < len(self.vec):
            tmp = self.vec[i]
            self.vec[i] = next_item
            next_item = tmp
            i += 1
        self.vec[0] = next_item


    def _lshift(self):
        if len(self.vec) == 0:
            return
        
        last = len(self.vec) - 1
        prev_item = self.vec[last]
        i = last - 1
        while i >= 0:
            tmp = self.vec[i]
            self.vec[i] = prev_item
            prev_item = tmp
            i -= 1

        self.vec[last] = prev_item

    def ispol(self, vec):
        i = 0
        j = len(vec) - 1
        vec = list(vec)

        while i < j:
            if vec[i] != vec[j]:
                return False
            i += 1
            j -= 1

        return True

if __name__ == '__main__':
    obj = Tlist('batyfghpoiuy',3)
    assert obj.vec == ['a', 'b', 't', 'y', 'g', 'f', 'h', 'o', 'p', 'y', 'u', 'i']
    obj >> 1
    assert obj.vec == ['i', 'a', 'b', 't', 'y', 'g', 'f', 'h', 'o', 'p', 'y', 'u']
    obj << 1
    assert obj.vec == ['a', 'b', 't', 'y', 'g', 'f', 'h', 'o', 'p', 'y', 'u', 'i']

    assert obj.ispol("aba") == True
    assert obj.ispol("abba") == True
    assert obj.ispol("abbaa") == False

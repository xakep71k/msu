# -*- coding: utf-8 -*-

#
# операторы  << и >> осуществляют циклический сдвиг массива влево и вправо соответственно. 
#
class TList:
    def __init__(self, vec):
        self.vec = vec

    def __rshift__(self, other):
        while other != 0:
            self.rshift()
            other -= 1

    def __lshift__(self, other):
        while other != 0:
            self.lshift()
            other -= 1

    def rshift(self):
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


    def lshift(self):
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

if __name__ == '__main__':
    objTList = TList([0, 1, 2, 3, 4, 5, 6])
    objTList >> 2
    assert objTList.vec == [5, 6, 0, 1, 2, 3, 4]

    objTList << 2
    assert objTList.vec == [0, 1, 2, 3, 4, 5, 6]


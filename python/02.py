# -*- coding: utf-8 -*-

# За день машина проезжает n километров. Сколько дней нужно, чтобы проехать маршрут длиной m километров?
def car_days(n, m):
    return m/n

# Улитка ползет по вертикальному шесту высотой h метров, поднимаясь за день на a метров, а за ночь спускаясь на b метров. На какой день улитка доползет до вершины шеста?
def snail(a, b, h):
    if b > a:
        return -1
    a -= b
    return h/b

# Даны значения двух моментов времени, принадлежащих одним и тем же суткам: часы, минуты и секунды для каждого из моментов времени. 
# Известно, что второй момент времени наступил не раньше первого. Определите, сколько секунд прошло между двумя моментами времени.
def delta_time(h1, m1, s1, h2, m2, s2):
    time1 = h1 * 60 * 60 + m1 * 60 + s1
    time2 = h2 * 60 * 60 + m2 * 60 + s2
    return time1 - time2

# Парты
# За каждой партой может сидеть два учащихся. Известно количество учащихся в каждом из трех классов.
# Выведите наименьшее число парт, которое нужно приобрести для них.
def desks(people_count1, people_count2, people_count3):
    return (people_count1 + people_count2 + people_count3 + 1)/2

if __name__ == '__main__': 
    assert car_days(600, 6000) == 10
    assert snail(10, 20, 100) == -1
    assert snail(20, 10, 100) == 10
    assert delta_time(13,0,0,12,0,0) == 60 * 60
    assert delta_time(12,01,0,12,0,0) == 60
    assert desks(7,2,20) == 15
    assert desks(1,1,1) == 2

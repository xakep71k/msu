package main

import (
	"fmt"
	"math/big"
	"math/rand"
	"time"
)

const MSIZE = 5000

func main() {
	// создаём две матрицы с рандомным числами типа float64
	m1 := newMatrixWithRandom()
	m2 := newMatrixWithRandom()

	// и третью матрицу для записывания туда результата
	result := newMatrix()

	// засекаем время умножения матрица
	start := time.Now()
	multiplyMatrix(m1, m2, result)
	// останавливаем тамйер
	elapsed := big.NewFloat(float64(time.Since(start) / time.Second))

	// количестов операция для умножения матриц заранее известно
	// это countOps = 2*MSIZE^3
	countOps := big.NewInt(0).Exp(big.NewInt(MSIZE), big.NewInt(3), nil)
	countOps = big.NewInt(0).Mul(countOps, big.NewInt(2))

	// считаем Флопсы
	// делим количество операций / время в секундах
	gflops := big.NewFloat(0).Quo(big.NewFloat(0).SetInt(countOps), elapsed)
	fmt.Println(gflops.String())
}

func multiplyMatrix(m1, m2, result [][]float64) {
	for i := 0; i < MSIZE; i++ {
		for j := 0; j < MSIZE; j++ {
			for k := 0; k < MSIZE; k++ {
				result[i][j] += m1[i][k] * m2[k][j]
			}
		}
	}
}

func newMatrixWithRandom() [][]float64 {
	m := make([][]float64, MSIZE)

	for i := 0; i < len(m); i++ {
		m[i] = make([]float64, MSIZE)
		for j := 0; j < len(m[0]); j++ {
			m[i][j] = rand.Float64()
		}
	}

	return m
}

func newMatrix() [][]float64 {
	m := make([][]float64, MSIZE)
	for i := 0; i < len(m); i++ {
		m[i] = make([]float64, MSIZE)
	}

	return m
}

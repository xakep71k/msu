package main

import (
	"fmt"
	"math/rand"
)

const MSIZE = 2000

func main() {
	fmt.Println("begin init matrix")
	m1 := newMatrixWithRandom()
	m2 := newMatrixWithRandom()
	result := newMatrix()
	fmt.Println("end init matrix")
	countOps := multiplyMatrix(m1, m2, result)
	// fmt.Println(m1)
	// fmt.Println(m2)
	// fmt.Println(result)
	fmt.Println(countOps)
}

func multiplyMatrix(m1, m2, result [][]float64) int64 {
	var countOps int64

	for i := 0; i < MSIZE; i++ {
		for j := 0; j < MSIZE; j++ {
			for k := 0; k < MSIZE; k++ {
				result[i][j] += m1[i][k] * m2[k][j]
				countOps += 2
			}
		}
	}

	return countOps
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

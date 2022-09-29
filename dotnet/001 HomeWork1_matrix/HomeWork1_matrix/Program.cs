using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HomeWork1_matrix
{
    internal class Program
    {
        const int M1 = 1000, N1 = 1000;
        const int M2 = N1, N2 = 1000;

        static void Main(string[] args)
        {
            MatrixType1();
            MatrixType2();
            Console.WriteLine("\npress ENTER to continue");
            Console.ReadLine();
        }

        static void MatrixType2()
        {
            Console.WriteLine("=== Array[][] ===");
            double[][] matrix1 = createMatrix2(M1, N1);
            double[][] matrix2 = createMatrix2(M2, N2);
            double[][] matrix3 = createMatrix2(M1, N2);
            initMatrixWithRandom2(matrix1);
            initMatrixWithRandom2(matrix2);
            Stopwatch sw = Stopwatch.StartNew();
            multiplyMatrix2(matrix1, matrix2, matrix3);
            sw.Stop();
            double seconds = sw.ElapsedMilliseconds / 1000.0;
            Console.WriteLine("spent time " + seconds + " secs");

            try
            {
                checked
                {
                    ulong opsCount = (ulong)matrix1.Length * (ulong)matrix2[0].Length * (ulong)matrix1[0].Length * 2;
                    Console.WriteLine("ops count {0}", opsCount);
                    Console.WriteLine("Gflops {0}", opsCount / seconds / 1000000000);
                }
            }
            catch (OverflowException)
            {
                Console.WriteLine("matrix type2: operation counter too big");
            }
            //printMatrix2("matrix1", matrix1);
            //printMatrix2("matrix2", matrix2);
            //printMatrix2("matrix3", matrix3);
        }

        static void multiplyMatrix2(double[][] m1, double[][] m2, double[][] result)
        {
            for (int i = 0; i < m1.Length; i++)
            {
                for (int j = 0; j < m2[0].Length; j++)
                {
                    for (int k = 0; k < m1[i].Length; k++)
                    {
                        result[i][j] += m1[i][k] * m2[k][j];
                    }
                }
            }
        }

        static double[][] createMatrix2(int m, int n)
        {
            double[][] matrix = new double[m][];
            for (int i = 0; i < matrix.Length; i++)
            {
                matrix[i] = new double[n];
            }
            return matrix;
        }

        static void initMatrixWithRandom2(double[][] m)
        {
            Random random = new Random();
            for (int i = 0; i < m.Length; i++)
            {
                for (int j = 0; j < m[i].Length; j++)
                {
                    m[i][j] = random.NextDouble();
                    //m[i][j] = 1;
                }
            }
        }

        static void printMatrix2(String title, double[][] m)
        {
            Console.WriteLine("{0}:", title);
            for (int i = 0; i < m.Length; i++)
            {
                for (int j = 0; j < m[i].Length; j++)
                {
                    Console.Write("{0:0.00} ", m[i][j]);
                }
                Console.WriteLine("");
            }
        }

        static void MatrixType1()
        {
            Console.WriteLine("=== Array[,] ===");
            double[,] matrix1 = createMatrix1(M1, N1);
            double[,] matrix2 = createMatrix1(M2, N2);
            double[,] matrix3 = createMatrix1(M1, N2);
            initMatrixWithRandom1(matrix1);
            initMatrixWithRandom1(matrix2);
            Stopwatch sw = Stopwatch.StartNew();
            multiplyMatrix1(matrix1, matrix2, matrix3);
            sw.Stop();
            double seconds = sw.ElapsedMilliseconds / 1000.0;
            Console.WriteLine("spent time " + seconds + " secs");
            try
            {
                checked
                {
                    ulong opsCount = (ulong)matrix1.GetLength(0) * (ulong)matrix2.GetLength(1) * (ulong)matrix1.GetLength(1) * 2;
                    Console.WriteLine("ops count {0}", opsCount);
                    Console.WriteLine("Gflops {0}", opsCount / seconds / 1000000000);
                }
            }
            catch (OverflowException)
            {
                Console.WriteLine("matrix type1: operation counter too big");
            }
            //printMatrix1("matrix1", matrix1);
            //printMatrix1("matrix2", matrix2);
            //printMatrix1("matrix3", matrix3);
        }

        static void multiplyMatrix1(double[, ] m1, double[,] m2, double[,] result)
        {
            for (int i = 0; i < m1.GetLength(0); i++)
            {
                for (int j = 0; j < m2.GetLength(1); j++)
                {
                    for (int k = 0; k < m1.GetLength(1); k++)
                    {
                        result[i, j] += m1[i, k] * m2[k, j];
                    }
                }
            }
        }

        static double[,] createMatrix1(int m, int n)
        {
            return new double[m, n];
        }

        static void initMatrixWithRandom1(double[,] m)
        {
            Random random = new Random();
            for (int i = 0; i < m.GetLength(0); i++)
            {
                for (int j = 0; j < m.GetLength(1); j++)
                {
                    m[i, j] = random.NextDouble();
                    //m[i, j] = 1;
                }
            }
        }

        static void printMatrix1(String title, double[,] m)
        {
            Console.WriteLine("{0}:", title);
            for (int i = 0; i < m.GetLength(0); i++)
            {
                for (int j = 0; j < m.GetLength(1); j++)
                {
                    Console.Write("{0:0.00} ", m[i, j]);
                }
                Console.WriteLine("");
            }
        }

    }
}

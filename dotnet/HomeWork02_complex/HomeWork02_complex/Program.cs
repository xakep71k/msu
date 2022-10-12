namespace HomeWork02_complex
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(new MyComplex(0, 0));
            Console.WriteLine(new MyComplex(-1, -1));
            Console.WriteLine(new MyComplex(1, 2).GetHashCode());
            Console.WriteLine(new MyComplex(2, 1).GetHashCode());
            Console.WriteLine(new MyComplex(1, 2) + new MyComplex(3, 4));
            Console.WriteLine(new MyComplex(1, 2) - new MyComplex(3, 4));
            Console.WriteLine(new MyComplex(1, 2) * new MyComplex(3, 4));
            Console.WriteLine(new MyComplex(1, 2) / new MyComplex(3, 4));
            Console.WriteLine("Arg: {0}", new MyComplex(1, 2).Arg);
            Console.WriteLine("Abs: {0}", new MyComplex(1, 2).Abs);
            Console.WriteLine(new MyComplex(1, 2) == new MyComplex(1, 2));
            Console.WriteLine(new MyComplex(1, 2) != new MyComplex(1, 2));
            MyComplex mc1 = 12;
            Console.WriteLine(mc1);
            Console.WriteLine(MyComplex.FromArgAndAbs(2.136, 1.107));
        }
    }
}
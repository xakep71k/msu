using System.Security.Cryptography.X509Certificates;

namespace HomeWork02._2
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Body3D[] bodies = { new Cuboid(1, 2, 3), new Ball(3), new Tetrahedron(4) };
            for (int i = 0; i < bodies.Length; i++)
            {
                Console.WriteLine("{0}, volume: {1}", bodies[i], bodies[i].Volume());
            }
        }
    }

    public abstract class Body3D
    {
        public abstract double Volume();
    }

    public class Cuboid : Body3D
    {
        public Cuboid(double a, double b, double c)
        {
            this.A = a;
            this.B = b;
            this.C = c;
        }
        public override double Volume() { return A*B*C; }
        public override string ToString()
        {
            return "Cuboid: a = " + this.A + ", b = " + this.B + ", c = " + this.C;
        }

        public double A
        {
            get;set;
        }
        public double B
        {
            get; set;
        }
        public double C
        {
            get; set;
        }


    }

    public class Ball : Body3D
    {
        public Ball(double r)
        {
            this.R = r;
        }
        public override double Volume() { return (4/3)*Math.PI*Math.Pow(this.R, 3); }
        public override string ToString()
        {
            return "Ball: r = " + this.R;
        }

        public double R
        {
            get;set;
        }
    }

    public class Tetrahedron: Body3D
    {
        public Tetrahedron(double a)
        {
            this.A = a;
        }
        public override double Volume() { return (1/12.0)*Math.Pow(this.A, 3)*Math.Sqrt(2); }

        public override string ToString()
        {
            return "Tetrahedron: a = " + this.A;
        }

        public double A
        {
            get; set;
        }

    }
}
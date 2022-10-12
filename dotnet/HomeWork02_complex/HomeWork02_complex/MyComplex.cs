using System;

public class MyComplex
{
    public static MyComplex FromArgAndAbs(double abs, double argz)
    {
        return new MyComplex(abs * Math.Cos(argz), abs * Math.Sin(argz));

    }

    public MyComplex(double real, double imaginary)
    {
        this.Real = real;
        this.Imaginary = imaginary;
    }

    public MyComplex(int real) : this(real, 0)
    {
    }

    public static implicit operator MyComplex(double d)
    {
        return new MyComplex(d, 0);
    }

    public static explicit operator double(MyComplex c)
    {
        return c.Real;
    }

    public static MyComplex operator +(MyComplex c1, MyComplex c2)
    {
        return new MyComplex(c1.Real + c2.Real, c1.Imaginary + c2.Imaginary);
    }

    public static MyComplex operator *(MyComplex c1, MyComplex c2)
    {
        return new MyComplex(c1.Real * c2.Real - c1.Imaginary * c2.Imaginary, c1.Imaginary * c2.Real + c1.Real * c2.Imaginary);
    }

    public static MyComplex operator -(MyComplex c1, MyComplex c2)
    {
        return new MyComplex(c1.Real - c2.Real, c1.Imaginary - c2.Imaginary);
    }

    public static MyComplex operator /(MyComplex c1, MyComplex c2)
    {
        return new MyComplex(
            (c1.Real * c2.Real + c1.Imaginary * c2.Imaginary) / (Math.Pow(c1.Imaginary, 2) + Math.Pow(c2.Imaginary, 2)),
            (c1.Imaginary * c2.Real - c1.Real * c2.Imaginary) / (Math.Pow(c1.Imaginary, 2) + Math.Pow(c2.Imaginary, 2))
        );
    }

    public override int GetHashCode()
    {
        return (this.Real.GetHashCode() + this.Imaginary).GetHashCode();
    }

    public override string ToString()
    {
        if (this.Real == 0 && this.Imaginary == 0)
        {
            return "0";
        }

        if (this.Real == 0)
        {
            return this.Imaginary.ToString() + "i";
        }

        if (this.Imaginary == 0)
        {
            return this.Real.ToString();
        }

        string s = this.Real.ToString();

        if (this.Imaginary > 0)
        {
            s += "+";
        }

        return s + this.Imaginary.ToString() + "i";
    }

    public double Abs
    {
        get { return Math.Sqrt(Math.Pow(Real, 2) + Math.Pow(Imaginary, 2)); }
    }

    public double Arg
    {
        get
        {
            if (this.Real == 0)
            {
                return 0;
            }

            return Math.Atan(this.Imaginary / this.Real);
        }
    }

    public double Real
    {
        get; set;
    }

    public double Imaginary
    {
        get; set;
    }
}

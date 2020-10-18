#include <iostream>
#include <stdexcept>

class Body
{
public:
    virtual int Area() const = 0;
    virtual ~Body() {}
};

class Box : public Body
{
public:
    friend Box operator+(const Box &box1, const Box &box2);

    Box() : m_width(0),
            m_height(0),
            m_length(0)
    {
    }

    Box(int width) : m_width(width),
                     m_height(width),
                     m_length(width)
    {
        if (m_width < 0)
        {
            throw std::runtime_error("width invalid");
        }
    }

    Box(int width, int height) : m_width(width),
                                 m_height(height),
                                 m_length(width)
    {
        if (width < 0)
        {
            throw std::runtime_error("width invalid");
        }

        if (height < 0)
        {
            throw std::runtime_error("height invalid");
        }
    }

    Box(int width, int height, int length) : m_width(width),
                                             m_height(height),
                                             m_length(length)
    {
        if (width < 0)
        {
            throw std::runtime_error("width invalid");
        }

        if (height < 0)
        {
            throw std::runtime_error("height invalid");
        }

        if (length < 0)
        {
            throw std::runtime_error("length invalid");
        }
    }

    Box(const Box &box) : m_width(box.m_width),
                          m_height(box.m_height),
                          m_length(box.m_length)
    {
    }

    Box &operator=(const Box &box)
    {
        this->m_width = box.GetWidth();
        this->m_height = box.GetHeight();
        this->m_length = box.GetLength();
        return *this;
    }

    int GetHeight() const { return m_height; }
    int GetWidth() const { return m_width; }
    int GetLength() const { return m_length; }

    void SetHeight(int height) { m_height = height; }
    void SetWidth(int width) { m_width = width; }
    void SetLength(int length) { m_length = length; }

    // a++
    Box operator++(int)
    {
        Box box(*this);
        this->operator++();
        return box;
    }

    // ++a
    Box &operator++()
    {
        this->m_width++;
        this->m_height++;
        this->m_length++;
        return *this;
    }

    // a--
    Box operator--(int)
    {
        Box box(*this);
        this->operator--();
        return box;
    }

    // --a
    Box &operator--()
    {
        if (m_width - 1 < 0)
        {
            throw std::runtime_error("width invalid");
        }

        if (m_height - 1 < 0)
        {
            throw std::runtime_error("height invalid");
        }

        if (m_length - 1 < 0)
        {
            throw std::runtime_error("length invalid");
        }

        this->m_width--;
        this->m_height--;
        this->m_length--;
        return *this;
    }

    virtual int Area() const
    {
        return m_width * m_length + 2 * m_length * m_height + 2 * m_width * m_height;
    }

    virtual ~Box()
    {
        //std::cout << "~Box()" << std::endl;
    }

    std::ostream &write(std::ostream &os) const
    {
        std::cout << "width = " << m_width << ", height = " << m_height << ", length = " << m_length;
        return os;
    }

private:
    int m_width;
    int m_height;
    int m_length;
};

Box operator+(const Box &box1, const Box &box2)
{
    Box result(box1);
    result.m_height += box2.m_height;
    result.m_width += box2.m_width;
    result.m_length += box2.m_length;
    return result;
}

class WBox : virtual public Box
{
public:
    WBox(int width, int height, int length, int winHeight, int winWidth) : Box(width, height, length),
                                                                           m_winHeight(winHeight),
                                                                           m_winWidth(winWidth)
    {
        if (winHeight < 0 || winHeight > height)
        {
            throw std::runtime_error("window height invalid");
        }

        if (winWidth < 0 || winWidth > width)
        {
            throw std::runtime_error("window width invalid");
        }
    }

    virtual int Area() const
    {
        return Box::Area() - m_winHeight * m_winWidth;
    }

    virtual ~WBox()
    {
        //std::cout << "~WBox()" << std::endl;
    }

    // a++
    WBox operator++(int)
    {
        WBox box(*this);
        this->operator++();
        return box;
    }

    // ++a
    WBox &operator++()
    {
        Box::operator++();
        this->m_winHeight++;
        this->m_winWidth++;
        return *this;
    }

    // a--
    WBox operator--(int)
    {
        WBox box(*this);
        this->operator--();
        return box;
    }

    // --a
    WBox &operator--()
    {
        if (m_winHeight - 1 < 0)
        {
            throw std::runtime_error("window width invalid");
        }

        if (m_winWidth - 1 < 0)
        {
            throw std::runtime_error("window height invalid");
        }

        Box::operator--();

        this->m_winHeight--;
        this->m_winWidth--;
        return *this;
    }

    std::ostream &write(std::ostream &os) const
    {
        Box::write(os);
        std::cout << ", window width = " << m_winWidth << ", window height = " << m_winHeight;
        return os;
    }

private:
    int m_winHeight;
    int m_winWidth;
};

class HBox : virtual public Box
{
public:
    HBox(
        int width,
        int height,
        int length,
        int coverHeight) : Box(width, height, length),
                           m_coverHeight(coverHeight)
    {
    }

    // a++
    HBox operator++(int)
    {
        HBox box(*this);
        this->operator++();
        return box;
    }

    // ++a
    HBox &operator++()
    {
        Box::operator++();
        this->m_coverHeight++;
        return *this;
    }

    // a--
    HBox operator--(int)
    {
        HBox box(*this);
        this->operator--();
        return box;
    }

    // --a
    HBox &operator--()
    {
        if (m_coverHeight - 1 < 0)
        {
            throw std::runtime_error("cover height invalid");
        }

        Box::operator--();

        this->m_coverHeight--;
        return *this;
    }

    virtual int Area() const
    {
        return Box::Area() + 2 * GetWidth() * GetLength() + 2 * GetWidth() * GetHeight() + 2 * GetLength() * GetHeight();
    }

    virtual ~HBox()
    {
        //std::cout << "~HBox()" << std::endl;
    }

    std::ostream &write(std::ostream &os) const
    {
        Box::write(os);
        std::cout << ", cover height = " << m_coverHeight;
        return os;
    }

    int GetCoverHeight() const
    {
        return m_coverHeight;
    }

private:
    int m_coverHeight;
};

class WHBox : WBox, HBox
{
public:
    WHBox(
        int width,
        int height,
        int length,
        int winHeight,
        int winWidth,
        int coverHeight) : Box(width, height, length),
                           WBox(width, height, length, winHeight, winWidth),
                           HBox(width, height, length, coverHeight)
    {
    }

    // a++
    WHBox operator++(int)
    {
        WHBox box(*this);
        this->operator++();
        return box;
    }

    // ++a
    WHBox &operator++()
    {
        WBox::operator++();
        Box::operator--();
        HBox::operator++();
        return *this;
    }

    // a--
    WHBox operator--(int)
    {
        WHBox box(*this);
        this->operator--();
        return box;
    }

    // --a
    WHBox &operator--()
    {
        WBox::operator--();
        Box::operator++();
        HBox::operator--();
        return *this;
    }

    virtual int Area() const
    {
        return WBox::Area() + HBox::Area() - Box::Area();
    }

    virtual ~WHBox()
    {
        //std::cout << "~WHBox()" << std::endl;
    }

    std::ostream &write(std::ostream &os) const
    {
        WBox::write(os);
        std::cout << ", cover height = " << GetCoverHeight();
        return os;
    }
};

std::ostream &operator<<(std::ostream &os, const Box &box)
{
    return box.write(os);
}

std::ostream &operator<<(std::ostream &os, const HBox &box)
{
    return box.write(os);
}

std::ostream &operator<<(std::ostream &os, const WBox &box)
{
    return box.write(os);
}

std::ostream &operator<<(std::ostream &os, const WHBox &box)
{
    return box.write(os);
}

int main()
{
    WHBox whbox(5, 6, 7, 2, 2, 3);
    std::cout << "orig: " << whbox << std::endl;
    std::cout << "--- postfix inc" << std::endl;
    std::cout << whbox++ << std::endl;
    std::cout << "--- after inc\n" << whbox << std::endl;

    std::cout << whbox-- << std::endl;
    std::cout << "--- after dec\n" << whbox << std::endl;

    std::cout << "--- prefix inc" << std::endl;
    std::cout << ++whbox << std::endl;
    std::cout << "--- after inc\n" << whbox << std::endl;

    std::cout << "area: " << whbox.Area() << std::endl;
    std::cout << "area expected: 527" << std::endl;

    Box boxDefault;
    std::cout << "--- box default ctor\n" << boxDefault << std::endl;
    Box box1(12);
    std::cout << "--- box ctor with width\n" << box1 << std::endl;
    std::cout << "--- box area: " << box1.Area() << " expected: 720" << std::endl;
    Box box2(12, 13);
    std::cout << "--- box ctor with width height\n" << box2 << std::endl;
    Box box3(12, 13, 14);
    std::cout << "--- box ctor with width height length\n" << box3 << std::endl;
    return 0;
}

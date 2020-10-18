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
        std::cout << "~Box()" << std::endl;
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
        std::cout << "~WBox()" << std::endl;
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

    virtual int Area() const
    {
        return Box::Area() + 2 * GetWidth() * GetLength() + 2 * GetWidth() * GetHeight() + 2 * GetLength() * GetHeight();
    }

    virtual ~HBox()
    {
        std::cout << "~HBox()" << std::endl;
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
        int coverHeight) : WBox(width, height, length, winHeight, winWidth),
                           HBox(width, height, length, coverHeight)
    {
    }

    virtual int Area() const
    {
        return WBox::Area() + HBox::Area() - Box::Area();
    }

    virtual ~WHBox()
    {
        std::cout << "~WHBox()" << std::endl;
    }
};

int main()
{
    return 0;
}

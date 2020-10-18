#include <iostream>
#include <algorithm>
#include <stdexcept>

template <class T>
class MyStack
{
public:
    MyStack() : m_size(1), m_index(0), m_storage(new T[m_size])
    {
    }

    MyStack(const MyStack &stack) : m_size(stack.m_size),
                                    m_index(stack.m_index),
                                    m_storage(new T[m_size])
    {
        std::copy(stack.m_storage, stack.m_storage + stack.m_size, m_storage);
    }

    const MyStack &operator=(const MyStack &stack)
    {
        delete[] m_storage;
        m_index = stack.m_index;
        m_size = stack.m_size;
        std::copy(stack.m_storage, stack.m_storage + stack.m_size, m_storage);
    }

    void Push(const T &t)
    {
        if (m_index == m_size)
        {
            realloc(m_size * 2);
        }

        m_storage[m_index] = t;
        ++m_index;
    }

    T Pop()
    {
        if (Size() == 0)
        {
            throw std::runtime_error("stack empty");
        }

        --m_index;
        return m_storage[m_index];
    }

    size_t Size() const
    {
        return m_index;
    }

    size_t Capacity() const
    {
        return m_size;
    }

    ~MyStack()
    {
        delete[] m_storage;
    }

private:
    void realloc(size_t newsize)
    {
        if (newsize < m_size)
        {
            throw std::runtime_error("wrong size");
        }

        T *newstorage = new T[newsize];
        std::copy(m_storage, m_storage + m_size, newstorage);

        delete[] m_storage;
        m_storage = newstorage;
        m_size = newsize;
    }

    size_t m_size;
    size_t m_index;
    T *m_storage;
};

template <class T>
void PrintStackInfo(const MyStack<T> &stack)
{
    std::cout << "size = " << stack.Size() << ", capacity = " << stack.Capacity() << std::endl;
}

template <class T>
void TestMyStack(const char *title)
{
    std::cout << "============== " << std::endl;
    std::cout << "============== " << title << std::endl;
    std::cout << "============== " << std::endl;
    T arr[] = {10, 11, 12, 13, 14};

    MyStack<T> stack;
    

    std::cout << std::endl << "==== pushing:" << std::endl;
    for (int i = 0; i < sizeof(arr) / sizeof(T); ++i)
    {
        std::cout << "push " << arr[i] << std::endl;
        stack.Push(arr[i]);
        PrintStackInfo(stack);
    }

    MyStack<T> newstack(stack); 

    std::cout << std::endl << "==== poping:" << std::endl;
    for (int i = 0; i < sizeof(arr) / sizeof(T); ++i)
    {
        std::cout << "pop " << stack.Pop() << std::endl;
        PrintStackInfo(stack);
    }

    try
    {
        stack.Pop();
    }
    catch (const std::exception &e)
    {
        std::cerr << "error: " << e.what() << std::endl;
    }

    std::cout << std::endl << "==== poping copy of stack:" << std::endl;
    for (int i = 0; i < sizeof(arr) / sizeof(T); ++i)
    {
        std::cout << "pop " << newstack.Pop() << std::endl;
        PrintStackInfo(newstack);
    }
}

int main()
{
    TestMyStack<int>("test for int");
    TestMyStack<float>("test for float");
    return 0;
}
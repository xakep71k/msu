#include <memory>

class SStackImpl;
typedef std::shared_ptr<SStackImpl> SStackImplP;

class SStack {
    public:
        SStack(const char*);
        SStack(const SStack &);
        ~SStack();

        SStack &operator=(const SStack &);
        SStack &operator+=(const SStack &);
        SStack operator+(const SStack &) const;
        SStack operator+(const char*) const;
        SStack operator-(const char*) const;
        const char* operator[](int) const;

        int length() const;

   private:
        SStackImplP m_impl;
};


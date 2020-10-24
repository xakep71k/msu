#ifndef __SSTACK_H__
#define __SSTACK_H__

#include <memory>
#include <string>

class RuntimeError : public std::runtime_error {
    public:
        RuntimeError(const std::string &msg):
               std::runtime_error(msg) {
       }
};


class SStackImpl;
typedef std::shared_ptr<SStackImpl> SStackImplP;

class SStack {
    public:
        SStack();
        SStack(const char*);
        SStack(const SStack &);
        ~SStack();

        void push(const char *s);
        char *pop();
        const char *peek();

        SStack &operator=(const SStack &);
        SStack &operator+=(const SStack &);
        SStack operator+(const SStack &) const;
        char *operator-(char*);
        operator char*() const;

        size_t length() const;
        size_t capacity() const;

        bool contains(const char*, bool ignoreSpaces=false);

        void write(std::ostream& os) const;

   private:
        SStackImplP m_impl;
};

inline std::ostream& operator<<(std::ostream& os, const SStack& stack) {
    stack.write(os);
    return os;
}

inline void operator>>(const char *s, SStack& stack) {
    stack.push(s);
}

#endif

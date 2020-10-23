#include "sstack.h"

class SStackImpl {
    public:
        int length;
};


SStack::SStack(const char*):m_impl(new SStackImpl) {
}

SStack::SStack(const SStack &stack):m_impl(new SStackImpl(*m_impl)) {
}

SStack::~SStack(){
}

SStack &SStack::operator=(const SStack &stack) {
    *m_impl = *stack.m_impl;
    return *this;
}

SStack &SStack::operator+=(const SStack &stack) {
    return *this;
}

SStack SStack::operator+(const SStack &stack) const {
    SStack newstack(*this);
    return newstack;
}

SStack SStack::operator+(const char*) const {
    SStack newstack(*this);
    return newstack;
}

SStack SStack::operator-(const char*) const {
    SStack newstack(*this);
    return newstack;
}

int SStack::length() const {
    return m_impl->length;
}

const char* SStack::operator[](int) const {
    return NULL;
}


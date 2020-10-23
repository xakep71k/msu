#include "sstack.h"
#include <algorithm>
#include <stdexcept>

class RuntimeError : public std::runtime_error {
    public:
};

class SStackImpl {
    public:
        int index;
        int length;
        const char** storage;

        SStackImpl():length(0), storage(nullptr){
            realloc(1);
        }

        SStackImpl(const SStackImpl &impl) {
            realloc(impl.length);
            std::copy(storage, storage + impl.index, impl.storage);
            index = impl.index;
        }

        SStackImpl &operator=(const SStackImpl &impl) {
            realloc(impl.length);
            std::copy(storage, storage + impl.index, impl.storage);
            index = impl.index;

            return *this;
        }

        void realloc(int newlen) {
            const char **newstorage = new const char*[newlen];
            std::copy(newstorage, newstorage + index, newstorage);

            delete []storage;
            storage = newstorage;
            length = newlen;
        }
};


SStack::SStack(const char*):
    m_impl(new SStackImpl) {
}

SStack::SStack(const SStack &stack):
    m_impl(new SStackImpl(*m_impl)) {
}

SStack::~SStack(){
    delete []m_impl->storage;
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


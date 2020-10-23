#include "sstack.h"
#include <algorithm>
#include <stdexcept>
#include <cstring>
#include <iostream>

class SStackImpl {
    public:
        int index;
        int length;
        char** storage;

        SStackImpl(): index(0), length(0), storage(nullptr){
            realloc(1);
        }

        SStackImpl(const SStackImpl &impl) {
            index = 0;
            realloc(impl.length);
            for(int i = 0; i < impl.index; ++i) {
                int len = strlen(impl.storage[i]);
                char *s = new char[len+1];
                std::copy(impl.storage[i], impl.storage[i]+len, s);
                s[len] = 0;
                storage[i] = s;
            }
            index = impl.index;
        }

        SStackImpl &operator=(const SStackImpl &impl) {
            realloc(impl.length);
            std::copy(storage, storage + impl.index, impl.storage);
            index = impl.index;

            return *this;
        }

        void push(const char *s) {
            if (index == length)
            {
                realloc(length * 2);
            }

            const int len = strlen(s);
            char *newstr = new char[len+1];
            std::copy(s, s+len, newstr);
            newstr[len] = 0;
            storage[index] = newstr;
            ++index;
        }

        char *pop() {
            if (index == 0)
            {
                throw RuntimeError("stack empty");
            }

            --index;
            return storage[index];
        }

        const char *peek() {
            if (index == 0)
            {
                throw RuntimeError("stack empty");
            }

            return storage[index-1];
        }

        void realloc(int newlen) {
            char **newstorage = new char*[newlen];
            std::copy(storage, storage + std::min(index, newlen), newstorage);

            delete []storage;
            storage = newstorage;
            length = newlen;
        }
};


SStack::SStack(): m_impl(new SStackImpl) {
}

SStack::SStack(const char *s): m_impl(new SStackImpl) {
        m_impl->push(s);
}

SStack::SStack(const SStack &stack):
    m_impl(new SStackImpl(*stack.m_impl)) {
}

SStack::~SStack(){
    delete []m_impl->storage;
}

void SStack::push(const char *s) {
    m_impl->push(s);
}

char *SStack::pop() {
    return m_impl->pop();
}

const char *SStack::peek() {
    return m_impl->peek();
}

SStack &SStack::operator=(const SStack &stack) {
    *m_impl = *stack.m_impl;
    return *this;
}

SStack &SStack::operator+=(const SStack &stack) {
    for(int i = 0; i < stack.length(); ++i) {
        this->push(stack.m_impl->storage[i]);
    }
    return *this;
}

SStack SStack::operator+(const SStack &stack) const {
    SStack newstack(*this);
    for(int i = 0; i < stack.length(); ++i) {
        newstack.push(stack.m_impl->storage[i]);
    }
    return newstack;
}

char *SStack::operator-(char *s) {
    const char *tmp = pop();
    std::copy(tmp, tmp + strlen(tmp) + 1, s);
    delete []tmp;
    return s;
}

int SStack::length() const {
    return m_impl->index;
}

int SStack::capacity() const {
    return m_impl->length;
}


SStack::operator char*() const {
    int maxlen = 1;
    for(int i = 0; i < m_impl->index; ++i) {
        maxlen += strlen(this->m_impl->storage[i]) + 1;
    }

    char *res = new char[maxlen];
    char *tmp = res;

    for(int i = 0; i < m_impl->index; ++i) {
        const char *s = this->m_impl->storage[i];
        int len = strlen(s);
        std::copy(s, s+len, tmp);
        tmp = tmp + len;
        tmp[0] = '\n';
        ++tmp;
    }

    return res;
}

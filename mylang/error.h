#ifndef _ERROR_H_
#define _ERROR_H_

#include <stdexcept>
#include <sstream>
#include <iostream>

class Error : public std::exception
{
    std::ostringstream stream_;
    mutable std::string msg_;

public:
    template <typename Type>
    Error &operator<<(const Type &value)
    {
        stream_ << value;
        return *this;
    }

    Error() {}
    Error(const Error &e)
    {
        stream_ << e.stream_.str();
    }

    const char *what() const throw()
    {
        msg_ = stream_.str();
        return msg_.c_str();
    }
};

#define THROW_ERROR() throw Error() << __FILE__ << ":" << __LINE__ << " "
#endif
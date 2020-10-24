#include "sstack.h"
#include <memory>
#include <iostream>
#include <cstring>

int main() {
    const char *s = "строка1";
    std::cout << "положили строку через конструктор: '" << s << "'\n";
    SStack stack1(s);

    s = stack1;
    std::cout << "cast 2 char*:\n" << s;
    delete []s;

    s = "строка2";
    std::cout << "положили строку push: '" << s << "'\n";
    stack1.push(s);

    s = stack1;
    std::cout << "cast 2 char*:\n" << s;
    delete []s;

    SStack stack2;
    stack2.push("строка3");
    stack2.push("строка4");
    stack2.push("строка5");

    s = stack2;
    std::cout << "положили 3 строки в новый стэк:\n" << s;
    delete []s;

    s = stack2.pop();
    std::cout << "убрали строку из нового стэка: '" << s << "'\n";
    delete []s;

    s = stack2;
    std::cout << "что лежит в новом стеэке:\n" << s;
    delete []s;

    char *res = new char[strlen(stack2.peek()) + 1];
    stack2 - res;
    std::cout << "убрали строку из нового стэка operator-: '" << res << "'\n";
    delete []res;

    s = stack2;
    std::cout << "что лежит в новом стеэке:\n" << s;
    delete []s;

    std::cout << "создали новый стэк из предыдущего\n";
    SStack stack3(stack2);
    stack3 += stack1;

    s = stack3;
    std::cout << "что лежит в новом стеэке:\n" << s;
    delete []s;

    std::cout << "создали новый стэк из всех предыдущих\n";
    SStack stack4 = stack3 + stack2 + stack1;
    s = stack4;
    std::cout << "что лежит в новом стеэке:\n" << s;
    delete []s;

    std::cout << "присвоили последнему стэку первый\n";
    stack4 = stack1;
    s = stack4;
    std::cout << "что лежит в новом стеэке:\n" << s;
    delete []s;

    s = stack1;
    std::cout << "что лежит в первом стеэке:\n" << s;
    delete []s;

    std::cout << "положили в стэк строку с пробелом 'abc '\n";
    stack4.push("abc ");
    std::cout << "теперь стэк содержит\n";
    std::cout << stack4;
    
    std::cout << "проверяем лежит ли эта строка используя строку ' abc ' и 'abc', игнорирем пробелы\n";
    std::cout << std::boolalpha;
    std::cout << stack4.contains(" abc ", true) << std::endl;
    std::cout << stack4.contains(" abc ", true) << std::endl;

    std::cout << "проверяем лежит ли эта строка в стэке, используя строку ' abc ' и 'abc', не игнорируем пробелы\n";
    std::cout << stack4.contains(" abc ") << std::endl;
    std::cout << stack4.contains(" abc ") << std::endl;

    std::cout << "создали пустой стэк и попытались вытащить от туда элемент\n";
    SStack stack5;

    try {
        stack5.pop();
    } catch(const std::exception &e) {
        std::cout << "ERROR: " << e.what() << std::endl;
    }

    std::cout << "создали ещё новый стэк и положили туда 10 одинаковых слов\n";
    SStack stack6;

    for(int i = 0; i < 10; ++i) {
        "слово" >> stack6;
    }

    std::cout << "печатаем стэк с 10 словами\n" << stack6;

    return 0;
}

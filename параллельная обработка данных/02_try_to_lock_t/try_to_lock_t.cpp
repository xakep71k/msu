#include <iostream>
#include <vector>
#include <thread>
#include <mutex>
 
std::mutex mtx;

void print_star() {
    std::unique_lock<std::mutex> lck(mtx, std::try_to_lock);
    
    if (lck) { // печатаем звёздочку, если удалось захватить мьютекс
        std::cout << '*';
    } else { // иначе х
        std::cout << 'x';
    }
}

int main() {
    std::vector<std::thread> threads;

    // создаём 100 потоков
    // каждый будет бороться за мьютекс
    for (int i = 0; i < 100; i++) {
        threads.emplace_back(print_star);
    }

    for (auto &x: threads) {
        x.join();
    }

    return 0;
}
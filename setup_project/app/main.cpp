#include <iostream>
#include <windows.h>

int main() {
    MessageBox(NULL, "Добро пожаловать в Advertisement Test Database!", "XADV-SQL", MB_OK | MB_ICONINFORMATION);
    std::cout << "Advertisement Test Database v1.0" << std::endl;
    std::cout << "Press any key to exit..." << std::endl;
    std::cin.get();
    return 0;
}

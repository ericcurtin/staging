#include <string>
#include <iostream>

int main() {
  std::string local("this is a test");
  std::string ref(local);  // created from a ref to local
  std::cout << "Before clear: " << local.capacity() << '\n';
  local.clear();
  std::cout << "After clear:  " << local.capacity() << '\n';
}


#include <string>
#include <iostream>

using std::string;
using std::cout;

int main() {
  string local("this is a test");
  string ref(local);  // created from a ref to local
  cout << (int*)local.data() << ' ' << (int*)ref.data() << '\n';
  cout << "local cap: " << local.capacity() << " ref cap: " << ref.capacity() << "\n";
  local.clear();
  cout << (int*)local.data() << ' ' << (int*)ref.data() << '\n';
  cout << "local cap: " << local.capacity() << " ref cap: " << ref.capacity() << "\n";
}


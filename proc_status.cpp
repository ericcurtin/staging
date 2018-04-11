#include "proc_status.hpp"

#include <iostream>

using std::cout;

int main() {
  cout << proc_status("VmRSS") << '\n';
  cout << heap_usage() << '\n';

  return 0;
}

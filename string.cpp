#include <string>
#include <iostream>
#include <openssl/crypto.h>

using std::string;
using std::cout;

void printStr(const string& str) {
  cout <<"capacity: " << str.capacity() << " string: ";
  for (size_t i = 0; i < str.capacity(); ++i) {
    const char cha = str[i];
    if (cha) {
      cout << str[i];
    }
    else {
      cout << "\\0";
    }
  }
  cout << "\n";
}

void cleanse(string& str) {
  str.clear();
  printStr(str);
  OPENSSL_cleanse(&str[0], str.capacity());
  printStr(str);
}

int main() {
  string a = "";
  printStr(a);
  a = "hi";
  printStr(a);
  a = "highest";
  printStr(a);
  a = "hi";
  printStr(a);
  cleanse(a);
}


#include <string>
#include <fstream>
#include <iostream>
#include <sstream>

using std::string;
using std::ifstream;
using std::stringstream;
using std::ostringstream;

string human(const string& val_str) {
  stringstream ss;
  ss << val_str;
  double val;
  ss >> val;

  ostringstream oss;
  if (val > 1048575) {
    oss << val / 1048576 << " GB";
  } else if (val > 1023) {
    oss << val / 1024 << " MB";
  } else {
    oss << val << " kB";
  }

  return oss.str();
}

string proc_status(const string& s) {
  ifstream ifs("/proc/self/status");
  string key;
  string val;
  while (ifs >> key >> val) {
    if (key == s + ':') {
      return human(val);
    }
  }

  return "";
}

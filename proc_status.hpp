#include <fstream>
#include <sstream>
#include <map>

using std::string;
using std::ifstream;
using std::stringstream;
using std::istringstream;
using std::ostringstream;
using std::map;
using std::hex;

string human(const unsigned long long val) {
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
  for (string line; getline(ifs, line);) {
    istringstream iss(line);
    string key;
    unsigned long long val;
    if (iss >> key >> val) {
      if (key == s + ':') {
        return human(val);
      }
    }
  }

  return "";
}

string heap_usage() {
  map<string, unsigned long long> heap;
  ifstream ifs("/proc/self/maps");
  for (string line; getline(ifs, line);) {
    stringstream ss(line);
    string address, permissions, offset, device, inode, pathname;
    if (ss >> address >> permissions >> offset >> device >> inode >> pathname) {
      const int pos = address.find('-');

      ss.clear();
      string tmp = address.substr(0, pos);
      stringstream ss;
      ss << hex << tmp;
      unsigned long long start_val;
      ss >> start_val;

      ss.clear();
      tmp = address.substr(pos + 1, address.size());
      ss << hex << tmp;
      unsigned long long end_val;
      ss >> end_val;

      heap[pathname] += end_val - start_val;
    }
  }

  ostringstream oss;
  for (map<string, unsigned long long>::const_iterator it = heap.begin();
       it != heap.end(); ++it) {
    oss << it->first << ' ' << human(it->second) << '\n';
  }

  return oss.str();
}

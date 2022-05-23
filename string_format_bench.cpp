#include <bits/stdc++.h>
#include <sys/time.h>
#include <algorithm>

static int stringAppendfImplHelper(char* buf,
                                   size_t bufsize,
                                   const char* format,
                                   va_list args) {
  va_list args_copy;
  va_copy(args_copy, args);
  int bytes_used = vsnprintf(buf, bufsize, format, args_copy);
  va_end(args_copy);
  return bytes_used;
}

static void stringAppendfImpl(std::string& output,
                              const char* format,
                              va_list args) {
  // Very simple; first, try to avoid an allocation by using an inline
  // buffer.  If that fails to hold the output string, allocate one on
  // the heap, use it instead.
  //
  // It is hard to guess the proper size of this buffer; some
  // heuristics could be based on the number of format characters, or
  // static analysis of a codebase.  Or, we can just pick a number
  // that seems big enough for simple cases (say, one line of text on
  // a terminal) without being large enough to be concerning as a
  // stack variable.
  std::array<char, 128> inline_buffer;

  int bytes_used = stringAppendfImplHelper(inline_buffer.data(),
                                           inline_buffer.size(), format, args);
  if (bytes_used < 0) {
    fprintf(stderr,
            "Invalid format string; snprintf returned negative "
            "with format string: %s\n",
            format);
  }

  if (static_cast<size_t>(bytes_used) < inline_buffer.size()) {
    output.append(inline_buffer.data(), size_t(bytes_used));
    return;
  }

  // Couldn't fit.  Heap allocate a buffer, oh well.
  std::unique_ptr<char[]> heap_buffer(new char[size_t(bytes_used + 1)]);
  int final_bytes_used = stringAppendfImplHelper(
      heap_buffer.get(), size_t(bytes_used + 1), format, args);

  // We don't keep the trailing '\0' in our output string
  output.append(heap_buffer.get(), size_t(final_bytes_used));
}

static void stringVAppendf(std::string& output,
                           const char* format,
                           va_list ap) {
  stringAppendfImpl(output, format, ap);
}

// Basic declarations; allow for parameters of strings and string
// pieces to be specified.
static void stringAppendf(std::string &output, const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  stringVAppendf(output, format, ap);
  va_end(ap);
}

static int stringAppendfImplHelper2(char* buf,
                                    size_t bufsize,
                                    const char* format,
                                    va_list args) {
  va_list args_copy;
  va_copy(args_copy, args);
  int bytes_used = vsnprintf(buf, bufsize, format, args_copy);
  va_end(args_copy);
  return bytes_used;
}

static void stringAppendfImpl2(std::string& output,
                               const char* format,
                               va_list args) {
  // Very simple; first, try to write 128 bytes, if that's too small, resize the
  // std::string to be as large as needs be (as it will be known after the first
  // snprintf parse). Shrink to appropriate size on exit.
  //
  // It is hard to guess the proper size of this buffer; some
  // heuristics could be based on the number of format characters, or
  // static analysis of a codebase.  Or, we can just pick a number
  // that seems big enough for simple cases (say, one line of text on
  // a terminal) without being large enough to be concerning as a
  // stack variable.
  const size_t write_point = output.size();
  output.resize(write_point + 127);

  const int bytes_used =
      stringAppendfImplHelper2(&output[write_point], 128, format, args);
  if (bytes_used < 0) {
    output.resize(write_point);
    fprintf(stderr,
            "Invalid format string; snprintf returned negative "
            "with format string: %s\n",
            format);
  }

  output.resize(write_point + bytes_used);
  if (bytes_used < 128) {
    return;
  }

  // Couldn't fit. Rewrite again, now that we have resized sufficiently.
  stringAppendfImplHelper(&output[write_point], bytes_used + 1, format, args);
}

static void stringVAppendf2(std::string& output,
                            const char* format,
                            va_list ap) {
  stringAppendfImpl2(output, format, ap);
}

// Basic declarations; allow for parameters of strings and string
// pieces to be specified.
static void stringAppendf2(std::string &output, const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  stringVAppendf2(output, format, ap);
  va_end(ap);
}

#define STRING_PRINTF(str, ...)                         \
  do {                                                  \
    const int size = snprintf(NULL, 0, __VA_ARGS__);    \
    const size_t write_point = str.size();              \
    str.resize(write_point + size);                     \
    snprintf(&str[write_point], size + 1, __VA_ARGS__); \
  } while (0)

#define STRING_PRINTF2(str, ...)                                    \
  do {                                                              \
    const size_t write_point = str.size();                          \
    str.resize(write_point + 127);                                  \
    const int size = snprintf(&str[write_point], 128, __VA_ARGS__); \
    str.resize(write_point + size);                                 \
    if (size < 128) {                                               \
      break;                                                        \
    }                                                               \
                                                                    \
    snprintf(&str[write_point], size + 1, __VA_ARGS__);             \
  } while (0)

static double epoch() {
  struct timeval tv;

  gettimeofday(&tv, 0);

  return tv.tv_sec + (tv.tv_usec / 1000000.0d);
}

int main() {
  double start = epoch();
  int limit = 2000000;
  std::string folly;
  for (int i = 0; i < limit; ++i) {
    stringAppendf(folly, "%s %d %f %s %d %f %s %d %f %s %d %f %s %d %f", "hdja",
                  22, 32.2, "djksa", 23, 32.23, "dsah", 32, 32.32, "hjdsa", 21,
                  21.21, "kjdwqs", 213, 23.321);
  }
  printf("%s", folly.c_str());
  fprintf(stderr, "folly: %f seconds\n", epoch() - start);

  start = epoch();
  std::string folly2;
  for (int i = 0; i < limit; ++i) {
    stringAppendf2(folly2, "%s %d %f %s %d %f %s %d %f %s %d %f %s %d %f",
                   "hdja", 22, 32.2, "djksa", 23, 32.23, "dsah", 32, 32.32,
                   "hjdsa", 21, 21.21, "kjdwqs", 213, 23.321);
  }
  printf("%s", folly2.c_str());
  fprintf(stderr, "folly2: %f seconds\n", epoch() - start);

  start = time(0);
  std::string string_printf;
  for (int i = 0; i < limit; ++i) {
    STRING_PRINTF(string_printf, "%s %d %f %s %d %f %s %d %f %s %d %f %s %d %f",
                  "hdja", 22, 32.2, "djksa", 23, 32.23, "dsah", 32, 32.32,
                  "hjdsa", 21, 21.21, "kjdwqs", 213, 23.321);
  }
  printf("%s", string_printf.c_str());
  fprintf(stderr, "string_printf: %f seconds\n", epoch() - start);

  start = time(0);
  std::string string_printf2;
  for (int i = 0; i < limit; ++i) {
    STRING_PRINTF2(string_printf2,
                   "%s %d %f %s %d %f %s %d %f %s %d %f %s %d %f", "hdja", 22,
                   32.2, "djksa", 23, 32.23, "dsah", 32, 32.32, "hjdsa", 21,
                   21.21, "kjdwqs", 213, 23.321);
  }
  printf("%s", string_printf2.c_str());
  fprintf(stderr, "string_printf2: %f seconds\n", epoch() - start);

  start = time(0);
  std::string to_string;
  for (int i = 0; i < limit; ++i) {
    to_string +=
        "hdja"
        " " +
        std::to_string(22) + " " + std::to_string(32.2) + " " + "djksa" + " " +
        std::to_string(23) + " " + std::to_string(32.23) + " " + "dsah" + " " +
        std::to_string(32) + " " + std::to_string(32.32) + " " + "hjdsa" + " " +
        std::to_string(21) + " " + std::to_string(21.21) + " " + "kjdwqs" +
        " " + std::to_string(213) + " " + std::to_string(23.321);
  }
  printf("%s", to_string.c_str());
  fprintf(stderr, "to_string: %f seconds\n", epoch() - start);

  start = time(0);
  std::ostringstream oss;
  for (int i = 0; i < limit; ++i) {
    oss << "hdja"
        << " " << 22 << " " << 32.2 << " "
        << "djksa"
        << " " << 23 << " " << 32.23 << " "
        << "dsah"
        << " " << 32 << " " << 32.32 << " "
        << "hjdsa"
        << " " << 21 << " " << 21.21 << " "
        << "kjdwqs"
        << " " << 213 << " " << 23.321;
  }
  printf("%s", oss.str().c_str());
  fprintf(stderr, "ostringstream: %f seconds\n", epoch() - start);
}

#include <errno.h>
#include <stdio.h>
#include <sys/file.h>
#include <string>

#define FOPEN_FILENO_FLOCK(mode, lock, ret) \
  FILE* f = file_fopen(file.c_str(), mode); \
  const int fd = file_fileno(f);            \
  if (fd == -1) {                           \
    return ret;                             \
  }                                         \
  file_flock(fd, lock);

#define FUNLOCK_FCLOSE()   \
  file_flock(fd, LOCK_UN); \
  file_fclose(f);

void file_print_error(const std::string& out) {
  fprintf(stderr, "%s failed with %d", out.c_str(), errno);
}

FILE* file_fopen(const std::string& file, const std::string& mode) {
  FILE* f = fopen(file.c_str(), mode.c_str());
  if (!f) {
    file_print_error("fopen");
  }

  return f;
}

int file_fileno(FILE* f) {
  const int ret = fileno(f);
  if (ret == -1) {
    file_print_error("fileno");
  }

  return ret;
}

int file_flock(const int fd, const int operation) {
  const int ret = flock(fd, operation);
  if (ret) {
    file_print_error("flock");
  }

  return ret;
}

int file_fseek(FILE* stream, const long offset, const int whence) {
  const int ret = fseek(stream, offset, whence);
  if (ret) {
    file_print_error("fseek");
  }

  return ret;
}

long file_ftell(FILE* stream) {
  const long ret = ftell(stream);
  if (ret == -1) {
    file_print_error("ftell");
  }

  return ret;
}

size_t file_fread(std::string& str, FILE* stream) {
  char* buf = new char(str.size());
  const size_t ret = fread(buf, str.size(), 1, stream);
  if (ret != str.size()) {
    file_print_error("fread");
  }
  str = std::string(buf, str.size());
  delete (buf);

  return ret;
}

int file_fclose(FILE* stream) {
  const int ret = fclose(stream);
  if (!ret) {
    file_print_error("fclose");
  }

  return ret;
}

size_t file_fwrite(const std::string& str, FILE* stream) {
  const size_t ret = fwrite(str.c_str(), 1, str.size(), stream);
  if (ret != str.size()) {
    file_print_error("fwrite");
  }

  return ret;
}

int file_fprintf(FILE* stream, const std::string& str) {
  const size_t ret = fprintf(stream, "%s", str.c_str());
  if (ret != str.size()) {
    file_print_error("fprintf");
  }

  return ret;
}

std::string file_read(const std::string& file) {
  FOPEN_FILENO_FLOCK("r", LOCK_SH, "");
  file_fseek(f, 0, SEEK_END);
  const long len = file_ftell(f);
  file_fseek(f, 0, SEEK_SET);
  std::string buf("", len);
  file_fread(buf, f);
  FUNLOCK_FCLOSE();

  return buf;
}

void file_write(const std::string& file, const std::string& data) {
  FOPEN_FILENO_FLOCK("w", LOCK_EX, );
  file_fwrite(data, f);
  FUNLOCK_FCLOSE();
}

void file_append(const std::string& file, const std::string& data) {
  FOPEN_FILENO_FLOCK("a", LOCK_EX, );
  file_fprintf(f, data);
  FUNLOCK_FCLOSE();
}

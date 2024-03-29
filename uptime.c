#include <fcntl.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int uptime(float* up, float* elapsed) {
  int fd;
  const char* filename = "/proc/uptime";
  char buf[32];
  int n;
  if ((fd = open(filename, O_RDONLY)) == -1) {
    fputs("Error: /proc must be mounted\n", stderr);
    fflush(NULL);
    return 102;
  }

  lseek(fd, 0L, SEEK_SET);
  if ((n = read(fd, buf, sizeof buf - 1)) < 0) {
    perror(filename);
    fflush(NULL);
    return 103;
  }

  buf[n] = '\0';

  char* savelocale = strdup(setlocale(LC_NUMERIC, NULL));
  setlocale(LC_NUMERIC, "C");
  if (sscanf(buf, "%f", up) < 1) {
    setlocale(LC_NUMERIC, savelocale);
    free(savelocale);
    fputs("bad data in /proc/uptime\n", stderr);
    return 104;
  }

  static float init_time = 0;
  if (init_time) {
    *elapsed = *up - init_time;
  } else {
    init_time = *up;
    *elapsed = 0;
  }

  setlocale(LC_NUMERIC, savelocale);
  free(savelocale);
  return 0;
}

#define PRINT_UPTIME()                                                     \
  do {                                                                     \
    float up;                                                              \
    float elapsed;                                                         \
    uptime(&up, &elapsed);                                                 \
    printf("%.2f (%.2f), %s at %s:%d\n", up, elapsed, __PRETTY_FUNCTION__, \
           __FILE__, __LINE__);                                            \
  } while (0)

int main() {
  for (int i = 0; i < 10; ++i) {
    PRINT_UPTIME();
    sleep(1);
  }

  return 0;
}

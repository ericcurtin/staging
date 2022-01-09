#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>

int main() {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  unsigned long long msSinceEpoch =
    (unsigned long long)(tv.tv_sec) * 1000000 +
    (unsigned long long)(tv.tv_usec);

  while (1) {
    gettimeofday(&tv, NULL);
    unsigned long long msSinceEpoch1 =
      (unsigned long long)(tv.tv_sec) * 1000000 +
      (unsigned long long)(tv.tv_usec);
    printf("\r%.2f", (msSinceEpoch1 - msSinceEpoch) / 1000000.0);
    fflush(stdout);
    usleep(100000);
  }

  return 0;
}


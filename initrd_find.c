#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define QX(...)                                                                  \
  do {                                                                           \
    char* str;                             \
    if (asprintf(&str, __VA_ARGS__) < 0) { \
      perror("");                          \
      break;                               \
    }                                      \
                                           \
    char* out = qx(str);                                                         \
    printf("MESSAGE=ERIC: %s:%d '%s': '%s\n'", __PRETTY_FUNCTION__, __LINE__, str, out, NULL); \
    free(out);                                                                   \
    free(str);                                                                   \
  } while (0)

static char* qx(const char* cmd) {
  int stdout_fds[2];
  if (pipe(stdout_fds) == -1) {
    printf("MESSAGE=pipe(%p)", stdout_fds, NULL);
    return NULL;
  }

  const pid_t pid = fork();
  if (!pid) {
    close(stdout_fds[0]);
    dup2(stdout_fds[1], 1);
    dup2(stdout_fds[1], 2);

    close(stdout_fds[1]);

    execl("/bin/sh", "sh", "-c", cmd, (char *) NULL);
    exit(0);
  }

  close(stdout_fds[1]);

  int buf_size = 4096;
  char* out = malloc(buf_size);
  ssize_t tot_r = 0;
  ssize_t r = 0;
  do {
    r = read(stdout_fds[0], out + tot_r, buf_size - tot_r - 1);
    if (r <= 0) {
      break;
    }

    tot_r += r;
    if (buf_size - tot_r - 1 <= 0) {
      buf_size *= 2;
      out = realloc(out, buf_size);
    }
  } while (r > 0 || !errno || errno == EAGAIN || errno == EINTR);

  out[tot_r] = 0;
  close(stdout_fds[0]);

  int ret, status;
  do {
    ret = waitpid(pid, &status, 0);
  } while (ret == -1 && errno == EINTR);

  return out;
}

int main() {
  QX("traverse() { for file in \"$1\"/*; do if [ -d \"${file}\" ]; then ls -ld ${file}; traverse \"${file}\"; fi done }; traverse \"$PWD\"");
  return 0;
}



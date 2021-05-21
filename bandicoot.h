#include <ctype.h>
#include <dlfcn.h>
#include <errno.h>
#include <execinfo.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/uio.h>
#include <sys/wait.h>
#include <unistd.h>

static char* qx(char** cmd, int inc_stderr) {
  int stdout_fds[2];
  pipe(stdout_fds);

  int stderr_fds[2];
  if (!inc_stderr) {
    pipe(stderr_fds);
  }

  const pid_t pid = fork();
  if (!pid) {
    close(stdout_fds[0]);
    dup2(stdout_fds[1], 1);
    if (inc_stderr) {
      dup2(stdout_fds[1], 2);
    }

    close(stdout_fds[1]);

    if (!inc_stderr) {
      close(stderr_fds[0]);
      dup2(stderr_fds[1], 2);
      close(stderr_fds[1]);
    }

    execvp(*cmd, cmd);
    exit(0);
  }

  close(stdout_fds[1]);

  const int buf_size = 4092;
  char* out = malloc(buf_size * 2);
  int out_size = buf_size;
  int i = 0;
  do {
    const ssize_t r = read(stdout_fds[0], &out[i], buf_size);
    if (r > 0) {
      i += r;
    }

    if (out_size - i <= buf_size) {
      out_size *= 2;
      out = realloc(out, out_size);
    }
    printf("errno %d\n", errno);
  } while (errno == EAGAIN || errno == EINTR);

  close(stdout_fds[0]);

  if (!inc_stderr) {
    close(stderr_fds[1]);
    do {
      printf("read2\n");
      const ssize_t r = read(stderr_fds[0], &out[i], buf_size);

      if (r > 0) {
        i += r;
      }

      if (out_size - i <= buf_size) {
        out_size *= 2;
        out = realloc(out, out_size);
      }

    } while (errno == EAGAIN || errno == EINTR);

    close(stderr_fds[0]);
  }

  int r, status;
  do {
    r = waitpid(pid, &status, 0);
  } while (r == -1 && errno == EINTR);

  out[i] = 0;

  return out;
}

static char* bt(void) {
  const size_t max = 64;
  void* array[max];
  char** strings;
  char* out = 0;

  const int size = backtrace(array, max);
  strings = backtrace_symbols(array, size);
  if (strings != NULL) {
    for (int i = 1; i < size; i++) {
      char* argv[7];
      argv[0] = "addr2line";
      argv[1] = "-p";
      argv[2] = "-f";
      argv[3] = "-e";
      int j = 0;
      char str_cpy[2048];  // string length limitation here
      strcpy(str_cpy, strings[i]);
#ifdef ERICDEMANGLE
      //      printf("ERICDEBUG(before addr2line): %s\n", str_cpy);

      argv[4] = strings[i] + j;
      for (; strings[i][j] != '('; ++j) {
      }

      strings[i][j] = 0;
      for (; strings[i][j] != '+'; ++j) {
      }
      ++j;

      argv[5] = strings[i] + j;
      for (; strings[i][j] != ')'; ++j) {
      }

      strings[i][j] = 0;
      argv[6] = 0;

      char* to_cat = qx(argv, 1);
#else
      char* to_cat = "??";
      out = malloc(8192);
      out = "";
#endif
      
      //      printf("ERICDEBUG(after addr2line): %s\n", to_cat);
      if (out) {
        if (strstr(to_cat, "??")) {
          strcat(out, str_cpy);
          strcat(out, "\n");
        } else {
          strcat(out, to_cat);
        }

#ifdef ERICDEMANGLE
        free(to_cat);
#endif
      } else {
        out = to_cat;  // assumes this first allocated piece of memory from qx
                       // is big enough
        if (strstr(to_cat, "??")) {
          strcpy(out, str_cpy);
          strcat(out, "\n");
        }
      }
    }
  }

  free(strings);

  return out;
}

#if 0
int main() {
  char* out = bt();
  printf("%s", out);
  free(out);

  return 0;
}
#endif


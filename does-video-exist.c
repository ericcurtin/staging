#include <dirent.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

static bool dev_video_exists() {
  const char name[] = "/dev/";
  DIR* folder = opendir(name);
  if (!folder) {
    return false;
  }

  for (struct dirent* res; (res = readdir(folder));) {
    if (!memcmp(res->d_name, "video", 5)) {
      return true;
    }
  }

  closedir(folder);

  return false;
}

int main() {
  bool ret;
  for (int i = 0; !(ret = dev_video_exists()) && i < 40; ++i) {
    usleep(10000);
  }

  return ret;
}


#include <blkid/blkid.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
  const char* read = NULL;
  blkid_cache cache;

  // Open the cache
  blkid_get_cache(&cache, read);
  blkid_probe_all(cache);

  const char* type = strtok(argv[1], "=");
  const char* value = strtok(NULL, "=");

  // Iterate over all devices
  printf("%s\n", blkid_dev_devname(blkid_find_dev_with_tag(cache, type, value)));
//  blkid_dev_iterate iter = blkid_dev_iterate_begin(cache);
  
//  find_blk_dev(argv[1], argv[2], &iter);

  // Clean up
//  blkid_dev_iterate_end(iter);
  blkid_put_cache(cache);

  return 0;
}

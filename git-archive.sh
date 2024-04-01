#!/bin/bash

set -e

git submodule update --init
git ls-files --recurse-submodules | tar cJaf ~/rpmbuild/SOURCES/libostree-2023.4.tar.xz --xform s:^:libostree-2023.4/: --verbatim-files-from -T-


#!/bin/bash

set -ex

this_pkg=$(basename $PWD)

rm -rf ~/rpmbuild/SRPMS/*
rm -rf ~/rpmbuild/RPMS/*
find ~/rpmbuild/ -type f | grep spec | xargs rm -rf
rpmlint $this_pkg.spec
rpmbuild -bs $this_pkg.spec
rpmlint ~/rpmbuild/SRPMS/$this_pkg*.src.rpm
rpmbuild -bb $this_pkg.spec
rpmlint ~/rpmbuild/RPMS/*/$this_pkg*.rpm || true

this_srpm=$(ls -t ~/rpmbuild/SRPMS/ | tail -n1)

this_tar="$PWD/$1"
cp $this_pkg.spec ~/git/fedpkg/$this_pkg/
cd ~/git/fedpkg/$this_pkg

copr-cli build $this_pkg ~/rpmbuild/SRPMS/$this_srpm

echo "Please 'cd ~/git/fedpkg/$this_pkg' and commit the spec"

read


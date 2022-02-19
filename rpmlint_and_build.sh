#!/bin/bash

set -e

rm -rf /home/curtine/rpmbuild/SRPMS/*
rm -rf /home/curtine/rpmbuild/RPMS/*
find /home/curtine/rpmbuild/ -type f | grep spec | xargs rm -rf
rpmlint $1.spec
rpmbuild -bs $1.spec
rpmlint SRPMS/$1*.src.rpm
rpmbuild -bb $1.spec
rpmlint RPMS/*/$1*.rpm


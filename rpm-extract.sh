#!/bin/bash

set -ex

rpm2cpio $1 | cpio -idmv


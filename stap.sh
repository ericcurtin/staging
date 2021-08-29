#!/bin/bash

#set -e

prog="$(which $1)"
stap_prog="$(which para-callgraph.stp)"
echo "sudo stap $stap_prog \"process(\"$prog\").function(\"*\")\" -c $prog"
sudo stap $stap_prog "process(\"$prog\").function(\"*\")" -c $prog


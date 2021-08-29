#!/bin/bash

set -e
trap 'ec=$?; if [ $ec -ne 0 ]; then echo "exit $? due to '\$previous_command'"; fi' EXIT
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

#i=0
#find . -name "*.c" | xargs ag -n "connect\(" | grep -v dpdk | grep -v _connect | grep -v disconnect | while read line; do
find . -name "*.c" | xargs ag "NVME_TCP_PDU_RECV_STATE_AWAIT_PDU_PSH" | ag "nvmf_tcp_qpair_set_recv_state" | grep -v dpdk | grep -v _listen | while read line; do
  file=$(echo $line | awk -F: '{printf $1"\n"}')
  lineno=$(echo $line | awk -F: '{printf $2"\n"}')
#  lineno=$((lineno-1))

#  echo "sed -i \"${lineno}i$1\""
  if [ "$file" == "$last_file" ]; then
    i=$((i+1))
  else
    i=0
  fi

  lineno=$((i+lineno))

  sed -i "${lineno}i$1" $file

  last_file="$file"
  last_lineno="$lineno"
done


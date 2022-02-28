#!/bin/bash

set -e

for i in 192.168.1.0 10.42.0.220 10.42.0.220; do
  sudo timeout 8 nmap --host-timeout 1s -sS -p 22 $i/24 &
done | grep report

wait


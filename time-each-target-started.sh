#!/bin/bash

for i in $(systemctl list-units --type target | grep "\.target" | awk '{print $1}'); do
  systemd-analyze critical-chain $i | grep $i
done


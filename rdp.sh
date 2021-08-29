#!/bin/bash

set -e

if [ -n "$1" ]; then
  host="$1"
else
  read -p "RDP host: " host
fi

file="/media/work/media/sf_c/Users/curtie2/dns_cache.dat"
if line_in_file=$(grep -i "$host" "$file"); then
  label=$(echo "$line_in_file" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
  host=$(echo "$line_in_file" | awk '{print $NF}')
else
  label=$(echo "$host" | tr '[:upper:]' '[:lower:]')
  host=$(ssh curtie2@work "$host")
fi

for port in {3389..4389}; do
  if ! lsof -i:$port > /dev/null; then
    break;
  fi
done

echo "ssh -fNL $port:$host:3389 curtie2@work"
ssh -fNL $port:$host:3389 curtie2@work
file="$HOME/.local/share/remmina/group_rdp_quick-connect_$label.remmina"
cp ~/git/group_rdp_quick-connect_port.remmina "$file"
sed -i "s/host/127.0.0.1/g" $file
sed -i "s/port/$port/g" $file

echo "label: $label"
echo "host: $host"
echo "port: $port"

remmina -c "$file"


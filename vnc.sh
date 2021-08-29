#!/bin/bash

set -e

get_ip() {
  host=$(ssh curtie2@work "$label")
}

if [ -n "$1" ]; then
  host="$1"
else
  read -p "VNC host: " host
fi

file="/media/work/media/sf_c/Users/curtie2/dns_cache.dat"
label=$(echo "$host" | tr '[:upper:]' '[:lower:]')
if line_in_file=$(grep -i "$host" "$file"); then
  echo "line_in_file: $line_in_file"
  hostname=$(echo "$line_in_file" | awk '{printf $2"\n"}' | head -n1)
  if ! [[ $host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    get_ip
  fi
else
  get_ip
fi

for port in {5900..6900}; do
  if ! lsof -i:$port > /dev/null; then
    break;
  fi
done

echo "ssh -fNL $port:$host:5900 curtie2@work"
ssh -fNL $port:$host:5900 curtie2@work
file="$HOME/.local/share/remmina/group_rdp_quick-connect_$label.remmina"
cp ~/git/group_vnc_quick-connect_port.remmina "$file"
sed -i "s/host/127.0.0.1/g" $file
sed -i "s/port/$port/g" $file

echo "label: '$label'"
echo "hostname: '$hostname'"
echo "hostip: '$host'"
echo "port: '$port'"

remmina -c "$file"


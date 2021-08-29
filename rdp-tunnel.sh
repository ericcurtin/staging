#!/bin/sh
 
scriptname="$(basename $0)"
 
if [ $# -lt 3 ] 
 then
    echo "Usage: $scriptname start | stop  RDP_NODE_IP  SSH_NODE_IP SSH_LOCAL_PORT"
    exit
fi
 
case "$1" in
 
start)
 
  echo "Starting tunnel to $3"
  ssh -M -S ~/.ssh/$scriptname.${4:-3389}.control -fnNT -L ${4:-3389}:$2:3389 $3
  ssh -S ~/.ssh/$scriptname.${4:-3389}.control -O check $3
  ;;
 
stop)
  echo "Stopping tunnel to $3"
  ssh -S ~/.ssh/$scriptname.${4:-3389}.control -O exit $3 
 
 ;;
 
*)
  echo "Did not understand your argument, please use start|stop"
  ;;
 
esac


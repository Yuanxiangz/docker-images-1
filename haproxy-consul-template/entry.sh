#!/bin/bash
set -x

CONSUL_CONFIG=${1:-/etc/consul-template}

/usr/local/bin/filterproxy -l :$PORT_8050 -r localhost:$PORT_8051 &

# Start consul-template service
/usr/local/bin/consul-template -config=$CONSUL_CONFIG &

# Naive check runs checks once a minute to see if either of the processes exited.
# The container exits with an error if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  p1=$( ps aux  | grep filterproxy | grep -v grep |awk '{ print $2 }');
  p2=$( ps aux  | grep haproxy | grep -v grep |awk '{ print $2 }');
  # If the above greps find process PID's greater then 0,it means processes are running
  # Otherwise script exited
  if [ $p1 -ne 0 -o $p2 -ne 0 ]; then
    echo "processes are  running"
  else
     echo "processes are not running"
     exit 1
  fi
done

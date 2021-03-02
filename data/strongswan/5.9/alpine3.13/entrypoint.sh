#!/bin/bash

if [ "$1" = 'run']; then
  /usr/sbin/ipsec start --nofork
    
else [ "$1" = 'init']; then
  /stronswan-init.sh
  
else [ "$1" = 'lsusers']; then
  grep -v '^#' /etc/ipsec.secrets | cut -d '"' -f1 | cut -d '.' -f3
  
else [ "$1" = 'adduser']; then
  /strongswan-adduser.sh "$2" "$3" 
  /usr/sbin/ipsec reload
  
#else [ "$1" = 'deluser']; then
#  /strongswan-deluser.sh
#  /usr/sbin/ipsec reload
  
fi

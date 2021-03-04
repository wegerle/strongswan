#!/bin/bash

if [ "$1" = 'run' ]; then
  /usr/sbin/ipsec start --nofork
    
elif [ "$1" = 'strongswan-init' ]; then
  /strongswan-init
  
elif [ "$1" = 'strongswan-lsusers' ]; then
  grep -v '^#' /etc/ipsec.secrets | cut -d '"' -f1 | cut -d '.' -f3
  
elif [ "$1" = 'strongswan-useradd' ]; then
  /strongswan-useradd "$2" "$3" 
  /usr/sbin/ipsec reload
  
#elif [ "$1" = 'strongswan-userdel' ]; then
#  /strongswan-userdel
#  /usr/sbin/ipsec reload
  
fi

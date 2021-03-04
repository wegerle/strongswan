#!/bin/bash

if [ "$1" = 'run' ]; then
  /usr/sbin/ipsec start --nofork
    
elif [ "$1" = 'strongswan-init' ]; then
  /strongswan-init.sh
  
elif [ "$1" = 'strongswan-lsusers' ]; then
  /strongswan-lsusers.sh
  
elif [ "$1" = 'strongswan-useradd' ]; then
  /strongswan-useradd.sh "$2" "$3"
  
#elif [ "$1" = 'strongswan-userdel' ]; then
#  /strongswan-userdel.sh
#  /usr/sbin/ipsec reload
  
fi

#!/bin/bash
CONFIG_DIR=/etc/ipsec.d
TUNNEL_EXIST=0

if [ ! -n "${STRONGSWAN_HOSTNAME}" ]; then
  echo "The value for STRONGSWAN_HOSTNAME is missing."
  exit 0
fi

#Check if Username is empty or system in not initialized
if [ -n "$1" ] && [ -n "$2" ]; then

  
  #Check container IP-Address
  LEFT=$(ifconfig eth0 | grep "inet addr" | cut -d ":" -f2 | cut -d " " -f1)
  
  DOMAIN_NAME=$(echo ${STRONGSWAN_HOSTNAME} | cut -d "." -f2)
  TLD=$(echo ${STRONGSWAN_HOSTNAME} | cut -d "." -f3)
  LEFTID="$1"."$DOMAIN_NAME"."$TLD"
  RIGHTID="$2"."$DOMAIN_NAME"."$TLD"
  LEFTSUBNET
  RIGHTSUBNET
  
  echo ""
  echo "You must now define the Subnet for the left side!"
  echo "The subnet must be defined with the CIDR notation"
  echo ""
  read -p "Example: 10.10.10.0/24   :"
  echo ""

  #Check if username exist
  if [ "$(grep -wo $1 /etc/ipsec.secrets)" != "$1" ] && [ "$(grep -wo $2 /etc/ipsec.secrets)" != "$2" ]; then
    #Check if password field is empty
    if [ -n "$3" ]; then
      PSK_PASSWORD=$3
    else
      echo "No Password entered"
      read -p "Should a password be generated? - (y/N): " generated
      if [ "$generated" = 'y' ]; then
        PSK_PASSWORD=$(pwgen -sB 64 1)
      else
        echo "Abort - No user added"
        TUNNEL_EXIST=1
        exit 0
      fi
    fi
  elif [ "$(grep -wo $1 /etc/ipsec.secrets)" = "$1" ] && [ "$(grep -wo $2 /etc/ipsec.secrets)" != "$2" ]; then
    echo ""
    echo "Abort - leftid exist"
    echo ""
  elif [ "$(grep -wo $2 /etc/ipsec.secrets)" = "$2" ] && [ "$(grep -wo $1 /etc/ipsec.secrets)" != "$1" ]; then
    echo ""
    echo "Abort - right exist"
    echo ""
  else
    echo ""
    echo "Abort - leftid and right exist"
    echo ""
    TUNNEL_EXIST=1
  fi
  
  #Check if tunnel is not existing and password field is not empty
  if [ $TUNNEL_EXIST -eq 0  ] && [ -n $PSK_PASSWORD ]; then  
    
    PSK_PASSWORD_BASE64=$(echo $PSK_PASSWORD | base64)
    echo "@$LEFTID @$RIGHTID: PSK 0s$PSK_PASSWORD" >> /etc/ipsec.secrets
    
    echo ""                               >> /etc/ipsec.conf
    echo "conn rw-psk-$RIGHTID"           >> /etc/ipsec.conf
    echo "  left=$LEFT"                   >> /etc/ipsec.conf
    echo "  leftid=@$LEFTID"              >> /etc/ipsec.conf
    echo "  leftsubnet=$LEFTSUBNET"       >> /etc/ipsec.conf
    echo "  leftfirewall=yes"             >> /etc/ipsec.conf
    echo "  right=%any"                   >> /etc/ipsec.conf
    echo "  rightid=@$RIGHTID"            >> /etc/ipsec.conf
    echo "  rightsubnet=$RIGHTSUBNET"     >> /etc/ipsec.conf
    echo "  authby=secret"                >> /etc/ipsec.conf
    echo "  auto=add"                     >> /etc/ipsec.conf
    echo ""                               >> /etc/ipsec.conf
    
    #Print the password if is generated
    if [ "$generated" = 'y' ]; then
      echo ""
      echo "##################################################################################"
      echo "#                           The value for the PSK is:                            #"
      echo "#                                                                                #"
      echo "#        $PSK_PASSWORD        #"
      echo "#                                                                                #"
      echo "##################################################################################"
      echo "##################################################################################"
      echo ""
      echo "leftid=$LEFTID"
      echo ""
      echo "rightid=$RIGHTID"
      echo ""
      echo "Is added with the generated password."
      echo ""
    else
      echo ""
      echo "leftid=$LEFTID"
      echo ""
      echo "rightid=$RIGHTID"
      echo ""
      echo "Is added with the given password."
      echo ""
    fi

    #Reload the vpn to activate the new user
    /usr/sbin/ipsec reload
      
  fi
elif [ -n "$1" ]; then
  echo "The value for leftid is missing."
elif [ -n "$2" ]; then
  echo "The value for rightid is missing."
else
  echo "The value for leftid and rightid is missing."
  echo "Abort - No user added"
fi
  
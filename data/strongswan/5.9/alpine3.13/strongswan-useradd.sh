#!/bin/bash
CONFIG_DIR=$CONFIG_DIR

if [ ! -n "${STRONGSWAN_CA_C}" ]; then
  echo "The value for STRONGSWAN_CA_C is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_CA_O}" ]; then
  echo "The value for STRONGSWAN_CA_O is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_HOSTNAME}" ]; then
  echo "The value for STRONGSWAN_HOSTNAME is missing."
  exit 0
fi

#Cheick if Username is empty
if [ -n "$1" ]; then

  #Check if username exist
  if [ grep -qw "$1" /etc/ipsec.secrets ]; then
    #Check if password is empty
    if [ -n "$2" ]; then
      CLIENT_PASSWORD=$2
    else
      echo "No Password entered"
      read -p "Should a password be generated? - (y/N)" generated
      if [ "$generated" = 'y' ]; then
        CLIENT_PASSWORD=$(pwgen -ysBv 15﻿)        
        echo "########################################"
        echo "#   The password for the ne user is:   #"
        echo "#                                      #"
        echo "#            $CLIENT_PASSWORD           #"
        echo "#                                      #"
        echo "########################################"
      else
        echo "Abort - No user added"
        exit 0
      fi
    fi
  else
    echo "Abort - User exist"
  fi
  
  if [ ! grep -qw "$1" /etc/ipsec.secrets  ] && [-n $CLIENT_PASSWORD]; then  
    DOMAIN_NAME=$(echo ${STRONGSWAN_HOSTNAME} | cut -d "." -f2)
    TLD=$(echo ${STRONGSWAN_HOSTNAME} | cut -d "." -f3)
    CLIENT_CN="$1"@"$DOMAIN_NAME"."$TLD"
    
    if [ "${STRONGSWAN_CLIENT_KEY_TYPE}" = 'RSA2048' ]; then
      pki --gen --type rsa --size 2048 --outform pem > $CONFIG_DIR/private/"$1"_Key.pem
      
    elif [ "${STRONGSWAN_CLIENT_KEY_TYPE}" = 'RSA3072' ]; then
      pki --gen --type rsa --size 3072 --outform pem > $CONFIG_DIR/private/"$1"_Key.pem
      
    elif [ "${STRONGSWAN_CLIENT_KEY_TYPE}" = 'RSA4096' ]; then
      pki --gen --type rsa --size 4096 --outform pem > $CONFIG_DIR/private/"$1"_Key.pem
      
    elif [ "${STRONGSWAN_CLIENT_KEY_TYPE}" = 'ECDSA256' ]; then
      pki --gen --type ecdsa --size 256 --outform pem > $CONFIG_DIR/private/"$1"_Key.pem
      
    elif [ "${STRONGSWAN_CLIENT_KEY_TYPE}" = 'ECDSA384' ]; then
      pki --gen --type ecdsa --size 384 --outform pem > $CONFIG_DIR/private/"$1"_Key.pem
      
    elif [ "${STRONGSWAN_CLIENT_KEY_TYPE}" = 'ECDSA521' ]; then
      pki --gen --type ecdsa --size 521 --outform pem > $CONFIG_DIR/private/"$1"_Key.pem
    fi
    
    echo \"$CLIENT_CN\"" : EAP \""\"$CLIENT_PASSWORD\""\"" >> /etc/ipsec.secrets
    
    pki --issue --in $CONFIG_DIR/private/"$1"_Key.pem --type priv --cacert $CONFIG_DIR/cacerts/caCert.pem --cakey $CONFIG_DIR/private/caKey.pem \
          --dn "C=${STRONGSWAN_CA_C}, CN=$CLIENT_CN, O=${STRONGSWAN_CA_O}" --san=\"$CLIENT_CN\" --outform pem > $CONFIG_DIR/certs/"$1"_Cert.pem
          
    openssl pkcs12 -export -inkey $CONFIG_DIR/private/"$1"_Key.pem -in $CONFIG_DIR/certs/"$1"_Cert.pem -name \"$CLIENT_CN\" -certfile $CONFIG_DIR/cacerts/caCert.pem \
                   -caname \"$CA_CN\" -out $CONFIG_DIR/"$1"_Cert.p12 -p \"$CLIENT_PASSWORD\"
  fi
else
  echo "The value for client username is missing."
  echo "Abort - No user added"
fi
  
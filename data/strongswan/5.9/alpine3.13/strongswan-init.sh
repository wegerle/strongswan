#!/bin/bash
CONFIG_DIR=/etc/ipsec.d

if [ ! -n "${STRONGSWAN_CA_C}" ]; then
  echo "The value for STRONGSWAN_CA_C is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_CA_CN}" ]; then
  echo "The value for STRONGSWAN_CA_CN is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_CA_O}" ]; then
  echo "The value for STRONGSWAN_CA_O is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_CA_SAN}" ]; then
  echo "The value for STRONGSWAN_CA_SAN is missing."
  exit 0
fi

if [ -n "${STRONGSWAN_CA_KEY_TYPE}" ]; then
  for dir in \
          "$CONFIG_DIR/aacerts" \
          "$CONFIG_DIR/acerts" \
          "$CONFIG_DIR/cacerts" \
          "$CONFIG_DIR/certs" \
          "$CONFIG_DIR/crls" \
          "$CONFIG_DIR/ocspcerts" \
          "$CONFIG_DIR/private"
  do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
  done
  
  if [ ! -f "/etc/ipsec.secrets" ]; then
    touch /etc/ipsec.secrets
    
    if [ "${STRONGSWAN_CA_KEY_TYPE}" = 'RSA2048' ]; then
      pki --gen --type rsa --size 2048 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type rsa --size 2048 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": RSA serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_CA_KEY_TYPE}" = 'RSA3072' ]; then
      pki --gen --type rsa --size 3072 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type rsa --size 3072 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": RSA serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_CA_KEY_TYPE}" = 'RSA4096' ]; then
      pki --gen --type rsa --size 4096 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type rsa --size 4096 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": RSA serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_CA_KEY_TYPE}" = 'ECDSA256' ]; then
      pki --gen --type ecdsa --size 256 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type ecdsa --size 256 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": ECDSA  serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_CA_KEY_TYPE}" = 'ECDSA384' ]; then
      pki --gen --type ecdsa --size 384 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type ecdsa --size 384 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": ECDSA  serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_CA_KEY_TYPE}" = 'ECDSA521' ]; then
      pki --gen --type ecdsa --size 521 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type ecdsa --size 521 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": ECDSA  serverKey.pem" >> /etc/ipsec.secrets
    fi
    
    pki --self --in $CONFIG_DIR/private/caKey.pem \
        --dn "C=${STRONGSWAN_CA_C}, CN=${STRONGSWAN_CA_CN}, O=${STRONGSWAN_CA_O}" \
        --ca --outform pem > $CONFIG_DIR/cacerts/caCert.pem
    
    pki --issue --in $CONFIG_DIR/private/serverKey.pem --type priv --cacert $CONFIG_DIR/cacerts/caCert.pem --cakey $CONFIG_DIR/private/caKey.pem \
        --dn "C=${STRONGSWAN_CA_C}, CN=${STRONGSWAN_CA_CN}, O=${STRONGSWAN_CA_O}" \
        --san="${STRONGSWAN_CA_SAN}" --flag serverAuth --flag ikeIntermediate --outform pem > $CONFIG_DIR/certs/serverCert.pem
        
    echo ""
    echo "caKey, caCert, serverKey and serverCert are successfully created."
    echo ""
    
    /usr/sbin/ipsec reload
    
  else
    echo "Abort - /etc/ipsec.secrets is not empty"
  fi
else
  echo "The value for STRONGSWAN_CA_KEY_TYPE is missing."
  exit 0
fi

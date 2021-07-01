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
if [ ! -n "${STRONGSWAN_SERVER_C}" ]; then
  echo "The value for STRONGSWAN_SERVER_C is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_SERVER_O}" ]; then
  echo "The value for STRONGSWAN_SERVER_O is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_SERVER_CN}" ]; then
  echo "The value for STRONGSWAN_SERVER_CN is missing."
  exit 0
fi
if [ ! -n "${STRONGSWAN_SERVER_SAN}" ]; then
  echo "The value for STRONGSWAN_SERVER_SAN is missing."
  exit 0
fi

#Create the config folder if is missing
if [ -n "${STRONGSWAN_KEY_TYPE}" ]; then
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
  
  #Check if the system is uninitialized
  if [ ! -f "$CONFIG_DIR/private/caKey.pem" ] &&  [ ! -f "$CONFIG_DIR/private/serverKey.pem" ]; then
  
    #Create the ipsec.secrets file if is missing
    if [ ! -f "/etc/ipsec.secrets" ]; then
      touch /etc/ipsec.secrets
    fi 
  
    #Check if STRONGSWAN_CLIENT_KEY_TYPE has a allowed value
    if [ "${STRONGSWAN_KEY_TYPE}" = 'RSA2048' ]; then
      pki --gen --type rsa --size 2048 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type rsa --size 2048 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": RSA serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_KEY_TYPE}" = 'RSA3072' ]; then
      pki --gen --type rsa --size 3072 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type rsa --size 3072 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": RSA serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_KEY_TYPE}" = 'RSA4096' ]; then
      pki --gen --type rsa --size 4096 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type rsa --size 4096 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": RSA serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_KEY_TYPE}" = 'ECDSA256' ]; then
      pki --gen --type ecdsa --size 256 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type ecdsa --size 256 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": ECDSA  serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_KEY_TYPE}" = 'ECDSA384' ]; then
      pki --gen --type ecdsa --size 384 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type ecdsa --size 384 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": ECDSA  serverKey.pem" >> /etc/ipsec.secrets
      
    elif [ "${STRONGSWAN_KEY_TYPE}" = 'ECDSA521' ]; then
      pki --gen --type ecdsa --size 521 --outform pem > $CONFIG_DIR/private/caKey.pem
      pki --gen --type ecdsa --size 521 --outform pem > $CONFIG_DIR/private/serverKey.pem
      echo ": ECDSA  serverKey.pem" >> /etc/ipsec.secrets
      
    else
      echo "Abort - The value for STRONGSWAN_CLIENT_KEY_TYPE is wrong"
      exit 0
    fi
    
    
    pki --self --in $CONFIG_DIR/private/caKey.pem \
        --dn "C=${STRONGSWAN_CA_C}, CN=${STRONGSWAN_CA_CN}, O=${STRONGSWAN_CA_O}" \
        --ca --outform pem > $CONFIG_DIR/cacerts/caCert.pem
        
    
    
    pki --issue --in $CONFIG_DIR/private/serverKey.pem --type priv --cacert $CONFIG_DIR/cacerts/caCert.pem --cakey $CONFIG_DIR/private/caKey.pem \
        --dn "C=${STRONGSWAN_SERVER_C}, CN=${STRONGSWAN_SERVER_CN}, O=${STRONGSWAN_SERVER_O}" \
        --san="${STRONGSWAN_SERVER_SAN}" --flag serverAuth --flag ikeIntermediate --outform pem > $CONFIG_DIR/certs/serverCert.pem
    
    
    chmod 640 $CONFIG_DIR/private/caKey.pem
    chmod 640 $CONFIG_DIR/private/serverKey.pem
    chmod 640 $CONFIG_DIR/cacerts/caCert.pem
    chmod 640 $CONFIG_DIR/certs/serverCert.pem
        
    echo ""
    echo "caKey, caCert, serverKey and serverCert are successfully created."
    echo ""
    
        
    #Create the ipsec.secrets file if is missing
    if [ ! -f "/etc/ipsec.conf" ]; then
      touch /etc/ipsec.conf
    fi
    
    #Check container IP-Address
    LEFT=$(ifconfig eth0 | grep "inet addr" | cut -d ":" -f2 | cut -d " " -f1)
    
    echo "conn rw-eap-win"                            >> /etc/ipsec.conf
    echo "  left=$LEFT"                               >> /etc/ipsec.conf
    echo "  leftsubnet=$LEFTSUBNET"                   >> /etc/ipsec.conf
    echo "  leftid=@${STRONGSWAN_SERVER_CN}"          >> /etc/ipsec.conf
    echo "  leftcert=serverCert.pem"                  >> /etc/ipsec.conf
    echo "  leftauth=pubkey"                          >> /etc/ipsec.conf 
    echo "  leftfirewall=yes"                         >> /etc/ipsec.conf
    echo "  right=%any"                               >> /etc/ipsec.conf
    echo "  rightauth=eap-mschapv2"                   >> /etc/ipsec.conf
    echo "  rightsendcert=never"                      >> /etc/ipsec.conf
    echo "  eap_identity=%any"                        >> /etc/ipsec.conf
    echo "  rightsubnet=$RIGHTSUBNET"                 >> /etc/ipsec.conf
    echo "  rightsourceip=$RIGHTSUBNET # virtual IP"  >> /etc/ipsec.conf
    echo "  auto=add"                                 >> /etc/ipsec.conf
    
    /usr/sbin/ipsec reload
    
  else
    echo "Abort - The system is initialized"
  fi
else
  echo "The value for STRONGSWAN_KEY_TYPE is missing."
  exit 0
fi

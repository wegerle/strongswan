#!/bin/bash
CONFIG_DIR=/etc/ipsec.d
CLIENT_EXIST=0

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
if [ ! -n "${STRONGSWAN_CLIENT_KEY_TYPE}" ]; then
  echo "The value for STRONGSWAN_CLIENT_KEY_TYPE is missing."
  exit 0
fi

#Check if Username is empty or system in not initialized
if [ -n "$1" ] && [ -f $CONFIG_DIR/cacerts/caCert.pem ] && [ -f $CONFIG_DIR/private/caKey.pem ]; then

  DOMAIN_NAME=$(echo ${STRONGSWAN_HOSTNAME} | cut -d "." -f2)
  TLD=$(echo ${STRONGSWAN_HOSTNAME} | cut -d "." -f3)
  CLIENT_CN="$1"@"$DOMAIN_NAME"."$TLD"

  #Check if username exist
  if [ "$(grep -wo $1 /etc/ipsec.secrets)" != "$1" ]; then
    #Check if password field is empty
    if [ -n "$2" ]; then
      CLIENT_PASSWORD=$2
    else
      echo "No Password entered"
      read -p "Should a password be generated? - (y/N)" generated
      if [ "$generated" = 'y' ]; then
        CLIENT_PASSWORD=$(pwgen -sB 15 1)
      else
        echo "Abort - No user added"
        CLIENT_EXIST=1
        exit 0
      fi
    fi
  else
    echo "Abort - User exist"
    CLIENT_EXIST=1
  fi
  
  #Check if user is not existing and password field is not empty
  if [ $CLIENT_EXIST -eq 0  ] && [ -n $CLIENT_PASSWORD ]; then  
    #Check if STRONGSWAN_CLIENT_KEY_TYPE has a allowed value
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
      
    else
      echo "Abort - The value for STRONGSWAN_CLIENT_KEY_TYPE is wrong"
      exit 0
    fi
    
    #Check if private key is generated
    if [ -f $CONFIG_DIR/private/"$1"_Key.pem ]; then
      CLIENT_PASSWORD_BASE64=$(echo $CLIENT_PASSWORD | base64)
      echo "$CLIENT_CN : EAP \"0s$CLIENT_PASSWORD_BASE64\"" >> /etc/ipsec.secrets
      
      pki --issue --in $CONFIG_DIR/private/"$1"_Key.pem --type priv --cacert $CONFIG_DIR/cacerts/caCert.pem --cakey $CONFIG_DIR/private/caKey.pem \
            --dn "C=${STRONGSWAN_CA_C}, CN=$CLIENT_CN, O=${STRONGSWAN_CA_O}" --san=\"$CLIENT_CN\" --outform pem > $CONFIG_DIR/certs/"$1"_Cert.pem
      
      openssl pkcs12 -export -inkey $CONFIG_DIR/private/"$1"_Key.pem -in $CONFIG_DIR/certs/"$1"_Cert.pem -name \"$CLIENT_CN\" -certfile $CONFIG_DIR/cacerts/caCert.pem \
                    -caname \"$CA_CN\" -out $CONFIG_DIR/"$1".p12 -passout pass:$CLIENT_PASSWORD
      
      #Print the password if is generated
      if [ "$generated" = 'y' ]; then
        echo ""
        echo "#################################################"
        echo "#  The password for the user and the pkcs12 is: #"
        echo "#                                               #"
        echo "#                $CLIENT_PASSWORD                #"
        echo "#                                               #"
        echo "#################################################"
        echo ""
      else
        echo "The user is added with the given password."
        echo "This password is also used for the pkcs12 file."
      fi
      
      #Reload the vpn to activate the new user
      /usr/sbin/ipsec reload
      
    else
      echo "Abort - The private key for the client: $1 is missing."
    fi
  fi
elif [ ! -f $CONFIG_DIR/cacerts/caCert.pem ] && [ ! -f $CONFIG_DIR/private/caKey.pem ]; then
  echo "Abort - System is not initialized"
else
  echo "The value for client username is missing."
  echo "Abort - No user added"
fi
  
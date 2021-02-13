FROM alpine:3.13

ENV STRONGSWAN 5.9.1

RUN apk --update add \
  build-base \
  bash \
  ca-certificates \
  curl \
  curl-dev \
  ip6tables \
  iproute2 \
  iptables-dev \
  openssl \
  openssl-dev \
  && mkdir /tmp/strongswan-${STRONGSWAN} \
  && curl -Lo /tmp/strongswan-${STRONGSWAN}.tar.bz2 https://download.strongswan.org/strongswan-${STRONGSWAN}.tar.bz2 \
  && tar --strip-components=1 -C /tmp/strongswan-${STRONGSWAN} -xjf /tmp/strongswan-${STRONGSWAN}.tar.bz2 \
  && cd /tmp/strongswan-${STRONGSWAN} \
  && ./configure --prefix=/usr \
    --sysconfdir=/etc \
    --libexecdir=/usr/lib \
    --with-ipsecdir=/usr/lib/strongswan \
    --enable-af-alg \
    --enable-ccm \
    --enable-aesni \
    --enable-chapoly \
    --enable-cmd \
    --enable-curl \
    --enable-dhcp \
    --enable-eap-dynamic \
    --enable-eap-identity \
    --enable-eap-md5 \
    --enable-eap-mschapv2 \
    --enable-eap-radius \
    --enable-eap-tls \
    --enable-farp \
    --enable-files \
    --enable-gcm \
    --enable-md4 \
    --enable-newhope \
    --enable-ntru \
    --enable-openssl \
    --enable-sha3 \
    --enable-shared \
    --disable-aes \
    --disable-des \
    --disable-gmp \
    --disable-hmac \
    --disable-ikev1 \
    --disable-md5 \
    --disable-rc2 \
    --disable-sha1 \
    --disable-sha2 \
    --disable-static \
  && make \
  && make install \
  && cd .. && rm -rf /tmp/strongswan-${STRONGSWAN} \
  && apk del  build-base curl-dev openssl-dev \
  && rm -rf /var/chace/apk/*
   
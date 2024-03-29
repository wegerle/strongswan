FROM alpine:3.14

ENV STRONGSWAN 5.9.4
ENV DOCKER_RUNNING=1

#---------------------------------------------
# Update image and install additional packages
#---------------------------------------------
RUN \
  DEV_PACKAGES="build-base curl-dev openssl-dev" && \
  apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  ip6tables \
  iproute2 \
  iptables-dev \
  openssl \
  pwgen \
  $DEV_PACKAGES && \
  mkdir /tmp/strongswan-${STRONGSWAN} && \
  curl -Lo /tmp/strongswan-${STRONGSWAN}.tar.bz2 https://download.strongswan.org/strongswan-${STRONGSWAN}.tar.bz2 && \
  tar --strip-components=1 -C /tmp/strongswan-${STRONGSWAN} -xjf /tmp/strongswan-${STRONGSWAN}.tar.bz2 && \
  cd /tmp/strongswan-${STRONGSWAN} && \
  ./configure --prefix=/usr \
    --sysconfdir=/etc \
    --libexecdir=/usr/lib \
    --with-ipsecdir=/usr/lib/strongswan \
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
    --disable-static && \
  \
  make && \
  make install && \
  \
  cd .. && rm -rf /tmp/strongswan-${STRONGSWAN} && \
  apk del  $DEV_PACKAGES
 
#---------------------------------------------
# Expose Ports
#---------------------------------------------
# 500/udp  - Internet Key Exchange (IKE)
# 4500/udp - NAT Traversal
#---------------------------------------------
EXPOSE 500/udp \
       4500/udp

COPY *.sh /
RUN chmod 755 /*.sh && \

    echo 'if [ "${DOCKER_RUNNING}" -eq 1 ]; then' >> /root/.bashrc && \
    echo "  alias vpn-init='/entrypoint.sh strongswan-init'" >> /root/.bashrc && \
    echo "  alias vpn-lsusers='/entrypoint.sh strongswan-lsusers'" >> /root/.bashrc && \
    echo "  alias vpn-add-eap='/entrypoint.sh strongswan-add-eap'" >> /root/.bashrc && \
    echo "  alias vpn-add-keyauth='/entrypoint.sh strongswan-add-keyauth'" >> /root/.bashrc && \
    echo "  alias vpn-add-psk='/entrypoint.sh strongswan-add-psk'" >> /root/.bashrc && \
    echo "fi" >> /root/.bashrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
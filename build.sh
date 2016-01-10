#!/bin/bash
set -e
git clone https://github.com/firehol/netdata.git /netdata.git
cd /netdata.git

# add netdata user

getent group netdata > /dev/null || groupadd -r netdata
getent passwd netdata > /dev/null || useradd -r -g netdata -c netdata -s /sbin/nologin -d / netdata

# install netdata under usr/local

NETDATA_PREFIX=/usr/local

# build

./autogen.sh

./configure \
    --prefix="${NETDATA_PREFIX}/usr" \
    --sysconfdir="${NETDATA_PREFIX}/etc" \
    --localstatedir="${NETDATA_PREFIX}/var" \
    --with-zlib --with-math --with-user=netdata \
    CFLAGS="-O3"

# create folders

mkdir -p ${NETDATA_PREFIX}/usr/share/netdata/web
mkdir -p ${NETDATA_PREFIX}/etc/netdata
mkdir -p ${NETDATA_PREFIX}/var/cache/netdata
mkdir -p ${NETDATA_PREFIX}/var/log/netdata

touch ${NETDATA_PREFIX}/etc/netdata/netdata.conf

# build

make

# install

make install

# fix permissions

chown -R netdata.netdata ${NETDATA_PREFIX}/usr/share/netdata/web
chown -R netdata.netdata ${NETDATA_PREFIX}/etc/netdata
chown -R netdata.netdata ${NETDATA_PREFIX}/var/cache/netdata
chown -R netdata.netdata ${NETDATA_PREFIX}/var/log/netdata

# some permissions (make install will setuid root to below location)

chown root.root ${NETDATA_PREFIX}/usr/libexec/netdata/plugins.d/apps.plugin
chmod 4755 ${NETDATA_PREFIX}/usr/libexec/netdata/plugins.d/apps.plugin


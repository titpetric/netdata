#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive

# some mirrors have issues, i skipped httpredir in favor of an eu mirror

echo "deb http://ftp.nl.debian.org/debian/ jessie main" > /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list

# install dependencies for build

apt-get -qq update
apt-get -y install zlib1g-dev uuid-dev libmnl-dev gcc make curl git autoconf autogen automake pkg-config netcat-openbsd jq
apt-get -y install autoconf-archive lm-sensors nodejs python python-mysqldb python-yaml
apt-get -y install ssmtp mailutils apcupsd fping

# fetch netdata

git clone https://github.com/firehol/netdata.git /netdata.git
cd /netdata.git
TAG=$(</git-tag)
if [ ! -z "$TAG" ]; then
	echo "Checking out tag: $TAG"
	git checkout tags/$TAG
else
	echo "No tag, using master"
fi

# use the provided installer

./netdata-installer.sh --dont-wait --dont-start-it

# removed hack on 2017/1/3
#chown root:root /usr/libexec/netdata/plugins.d/apps.plugin
#chmod 4755 /usr/libexec/netdata/plugins.d/apps.plugin

# remove build dependencies

cd /
rm -rf /netdata.git

dpkg -P zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config
apt-get -y autoremove
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# symlink access log and error log to stdout/stderr

ln -sf /dev/stdout /var/log/netdata/access.log
ln -sf /dev/stdout /var/log/netdata/debug.log
ln -sf /dev/stderr /var/log/netdata/error.log

FROM debian:jessie

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq -y install zlib1g-dev gcc make git autoconf autogen automake pkg-config

ADD build.sh /build.sh
ADD run.sh /run.sh
RUN chmod +x /run.sh /build.sh; sync; sleep 1; /build.sh

WORKDIR /

ENTRYPOINT ["/run.sh"]

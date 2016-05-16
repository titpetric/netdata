FROM debian:jessie

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update

ADD build.sh /build.sh

RUN chmod +x /run.sh /build.sh; sync; sleep 1; /build.sh

WORKDIR /

ENV NETDATA_PORT 19999
EXPOSE $NETDATA_PORT

ENTRYPOINT ["/usr/sbin/netdata", "-nd", "-ch", "/host", "-p", "${NETDATA_PORT}"]

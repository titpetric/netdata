FROM debian:jessie

ADD build.sh /build.sh

RUN chmod +x /build.sh && sync && sleep 1 && /build.sh

WORKDIR /

ENV NETDATA_PORT 19999
EXPOSE $NETDATA_PORT

CMD /usr/sbin/netdata -D -s /host -p ${NETDATA_PORT}

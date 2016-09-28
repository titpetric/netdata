FROM debian:jessie

ADD run.sh /run.sh
ADD build.sh /build.sh

RUN chmod +x /run.sh /build.sh && sync && sleep 1 && /build.sh

WORKDIR /

ENV NETDATA_PORT 19999
EXPOSE $NETDATA_PORT

ENTRYPOINT ["/run.sh"]

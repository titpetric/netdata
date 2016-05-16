FROM debian:jessie

ADD build.sh /build.sh
ADD run.sh /run.sh

RUN /build.sh

WORKDIR /

ENV NETDATA_PORT 19999
EXPOSE $NETDATA_PORT

ENTRYPOINT ["/run.sh"]

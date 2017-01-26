FROM debian:jessie

ADD scripts/build.sh /build.sh
RUN chmod +x /build.sh && sync && sleep 1 && /build.sh

WORKDIR /
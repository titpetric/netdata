FROM debian:jessie

ADD git-tag /git-tag

ADD scripts/build.sh /build.sh
ADD scripts/run.sh /run.sh

RUN chmod +x /run.sh /build.sh && sync && sleep 1 && /build.sh

WORKDIR /

ENV NETDATA_PORT=19999 SSMTP_TLS=YES SSMTP_SERVER=smtp.gmail.com SSMTP_PORT=587 SSMTP_HOSTNAME=localhost
EXPOSE $NETDATA_PORT

VOLUME /etc/netdata/override

ENTRYPOINT ["/run.sh"]

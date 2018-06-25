FROM debian:stretch

ADD git-tag /git-tag

ADD scripts/build.sh /build.sh
ADD scripts/run.sh /run.sh

RUN chmod +x /run.sh /build.sh && sync && sleep 1 && /build.sh

WORKDIR /

ENV NETDATA_PORT=19999 SMTP_TLS=on SMTP_STARTTLS=on SMTP_SERVER=smtp.gmail.com SMTP_PORT=587 SMTP_FROM=localhost
EXPOSE $NETDATA_PORT

VOLUME /etc/netdata/override

ENTRYPOINT ["/run.sh"]

FROM titpetric/netdata-build

ADD scripts/run.sh /run.sh

RUN chmod +x /run.sh && sync && sleep 1

WORKDIR /

ENV NETDATA_PORT=19999 SSMTP_TLS=YES SSMTP_SERVER=smtp.gmail.com SSMTP_PORT=587 SSMTP_HOSTNAME=localhost
EXPOSE $NETDATA_PORT

ENTRYPOINT ["/run.sh"]

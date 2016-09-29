#!/bin/bash

# set up ssmtp
if [[ $SSMTP_TO ]] && [[ $SSMTP_USER ]] && [[ $SSMTP_PASS ]]; then
cat << EOF > /etc/ssmtp/ssmtp.conf
root=$SSMTP_TO
mailhub=$SSMTP_SERVER:$SSMTP_PORT
AuthUser=$SSMTP_USER
AuthPass=$SSMTP_PASS
UseSTARTTLS=$SSMTP_TLS
hostname=$SSMTP_HOSTNAME
FromLineOverride=NO
EOF

cat << EOF > /etc/ssmtp/revaliases
netdata:netdata@$SSMTP_HOSTNAME:$SSMTP_SERVER:$SSMTP_PORT
EOF
fi

if [[ $# -gt 0 ]] ; then
        exec "$@"
        exit
fi

exec /usr/sbin/netdata -D -u root -s /host -p ${NETDATA_PORT}

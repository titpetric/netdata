#!/bin/bash

# fix permissions due to netdata running as root
chown root:root /usr/share/netdata/web/ -R
echo -n "" > /usr/share/netdata/web/version.txt

# set up ssmtp
if [[ $SSMTP_TO ]]; then
cat << EOF > /etc/ssmtp/ssmtp.conf
root=$SSMTP_TO
mailhub=$SSMTP_SERVER:$SSMTP_PORT
UseSTARTTLS=$SSMTP_TLS
hostname=$SSMTP_HOSTNAME
FromLineOverride=NO
EOF

cat << EOF > /etc/ssmtp/revaliases
netdata:netdata@$SSMTP_HOSTNAME:$SSMTP_SERVER:$SSMTP_PORT
root:netdata@$SSMTP_HOSTNAME:$SSMTP_SERVER:$SSMTP_PORT
EOF
fi

if [[ $SSMTP_USER ]]; then
cat << EOF >> /etc/ssmtp/ssmtp.conf
AuthUser=$SSMTP_USER
EOF
fi

if [[ $SSMTP_PASS ]]; then
cat << EOF >> /etc/ssmtp/ssmtp.conf
AuthPass=$SSMTP_PASS
EOF
fi

if [[ $SLACK_WEBHOOK_URL ]]; then
	sed -i -e "s@SLACK_WEBHOOK_URL=\"\"@SLACK_WEBHOOK_URL=\"${SLACK_WEBHOOK_URL}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $SLACK_CHANNEL ]]; then
	sed -i -e "s@DEFAULT_RECIPIENT_SLACK=\"\"@DEFAULT_RECIPIENT_SLACK=\"${SLACK_CHANNEL}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $DISCORD_WEBHOOK_URL ]]; then
	sed -i -e "s@DISCORD_WEBHOOK_URL=\"\"@DISCORD_WEBHOOK_URL=\"${DISCORD_WEBHOOK_URL}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $DISCORD_RECIPIENT ]]; then
	sed -i -e "s@DEFAULT_RECIPIENT_DISCORD=\"\"@DEFAULT_RECIPIENT_DISCORD=\"${DISCORD_RECIPIENT}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $TELEGRAM_BOT_TOKEN ]]; then
	sed -i -e "s@TELEGRAM_BOT_TOKEN=\"\"@TELEGRAM_BOT_TOKEN=\"${TELEGRAM_BOT_TOKEN}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $TELEGRAM_CHAT_ID ]]; then
	sed -i -e "s@DEFAULT_RECIPIENT_TELEGRAM=\"\"@DEFAULT_RECIPIENT_TELEGRAM=\"${TELEGRAM_CHAT_ID}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $PUSHBULLET_ACCESS_TOKEN ]]; then
	sed -i -e "s@PUSHBULLET_ACCESS_TOKEN=\"\"@PUSHBULLET_ACCESS_TOKEN=\"${PUSHBULLET_ACCESS_TOKEN}\"@" /etc/netdata/health_alarm_notify.conf
fi

if [[ $PUSHBULLET_DEFAULT_EMAIL ]]; then
	sed -i -e "s#DEFAULT_RECIPIENT_PUSHBULLET=\"\"#DEFAULT_RECIPIENT_PUSHBULLET=\"${PUSHBULLET_DEFAULT_EMAIL}\"#" /etc/netdata/health_alarm_notify.conf
fi

if [[ $NETDATA_IP ]]; then
	NETDATA_ARGS="${NETDATA_ARGS} -i ${NETDATA_IP}"
fi

# on a client netdata set this destination to be the [PROTOCOL:]HOST[:PORT] of the
# central netdata, and give an API_KEY that is secret and only known internally
# to the netdata clients, and netdata central
if [[ $NETDATA_STREAM_DESTINATION ]] && [[ $NETDATA_STREAM_API_KEY ]]; then
	cat << EOF > /etc/netdata/stream.conf
[stream]
	enabled = yes
	destination = $NETDATA_STREAM_DESTINATION
	api key = $NETDATA_STREAM_API_KEY
EOF
fi

# set 1 or more NETADATA_API_KEY_ENABLE env variables, such as NETDATA_API_KEY_ENABLE_1h213ch12h3rc1289e=1
# that matches the API_KEY that you used on the client above, this will enable the netdata client
# node to communicate with the netdata central
if printenv | grep -q 'NETDATA_API_KEY_ENABLE_'; then
	printenv | grep -oe 'NETDATA_API_KEY_ENABLE_[^=]\+' | sed 's/NETDATA_API_KEY_ENABLE_//' | xargs -n1 -I{} echo '['{}$']\n\tenabled = yes' >> /etc/netdata/stream.conf
fi

# exec custom command
if [[ $# -gt 0 ]] ; then
        exec "$@"
        exit
fi

if [[ -d "/fakenet/" ]]; then
	echo "Running fakenet config reload in background"
	( sleep 10 ; curl -s http://localhost:${NETDATA_PORT}/netdata.conf | sed -e 's/# filename/filename/g' | sed -e 's/\/host\/proc\/net/\/fakenet\/proc\/net/g' > /etc/netdata/netdata.conf ; pkill -9 netdata ) &
	/usr/sbin/netdata -D -u root -s /host -p ${NETDATA_PORT}
	# add some artificial sleep because netdata might think it can't bind to $NETDATA_PORT
	# and report things like "netdata: FATAL: Cannot listen on any socket. Exiting..."
	sleep 1
fi

for f in /etc/netdata/override/*; do
  cp -a $f /etc/netdata/
done

# main entrypoint
exec /usr/sbin/netdata -D -u root -s /host -p ${NETDATA_PORT} ${NETDATA_ARGS} "$@"

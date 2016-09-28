#!/bin/bash
if [[ $# -gt 0 ]] ; then
	echo "Running custom cmd"
	exec "$@"
	exit
fi
echo "Running netdata"
exec /usr/sbin/netdata -D -s /host -p ${NETDATA_PORT}

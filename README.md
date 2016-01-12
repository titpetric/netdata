# netdata

Dockerfile for building and running a netdata deamon for your host instance.

Netdata monitors your server with thoughts of performance and memory usage, providing detailed insight into
very recent server metrics. It's nice, and now it's also dockerized.

More info about project: https://github.com/firehol/netdata

# Using

```
docker run -d --cap-add SYS_PTRACE --name netdata -v /proc:/host/proc:ro -v /sys:/host/sys:ro -p 19999:19999 titpetric/netdata
```

Open a browser on http://server:19999/ and watch how your server is doing.

# Some explanation is in order

Docker needs to run with the SYS_PTRACE capability. Without it, the mapped host/proc filesystem
is not fully readable to the netdata deamon, more specifically the "apps" plugin:

```
16-01-12 07:58:16: ERROR: apps.plugin: Cannot process /host/proc/1/io (errno 13, Permission denied)
```

See the following link for more details: https://github.com/docker/docker/issues/6607

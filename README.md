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

Docker needs to run with the SYS_PTRACE capability. From what I understand, this enables access to the
proc filesystem, which handles things like environment. Netdata passes environment variables to plugins,
which then in turn read them to function correctly.

Without the SYS_PTRACE capability, the environment variables don't get passed from the netdata daemon,
to the apps.plugin and other plugins. In this case it means that apps.plugin is reading info from `/proc`
location, instead of the mapped volume `/host/proc`.

This might change in the future.

See the following links for more details:

1. https://github.com/firehol/netdata/issues/43#issuecomment-170585700
2. https://github.com/docker/docker/issues/6607#issuecomment-48932490

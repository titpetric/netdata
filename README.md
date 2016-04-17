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

# Environment variables

It's possible to pass a NETDATA_PORT environment variable with -e, to start up netdata on a different port.

```
docker run -e NETDATA_PORT=80 [...]
```

# Some explanation is in order

Docker needs to run with the SYS_PTRACE capability. Without it, the mapped host/proc filesystem
is not fully readable to the netdata deamon, more specifically the "apps" plugin:

```
16-01-12 07:58:16: ERROR: apps.plugin: Cannot process /host/proc/1/io (errno 13, Permission denied)
```

See the following link for more details: [/proc/1/environ is unavailable in a container that is not priviledged](https://github.com/docker/docker/issues/6607)

# Limitations

In addition to the above requirements and limitations, monitoring the complete network interface list of
the host is not possible from within the Docker container. If you're running netdata and want to graph
all the interfaces available on the host, you will have to use `--net=host` mode.

See the following link for more details: [network interfaces missing when mounting proc inside a container](https://github.com/docker/docker/issues/13398)

# Additional notes

Netdata provides monitoring via a plugin architecture. This plugin supports many projects that don't
provide data over the `/proc` filesystem. When you're running netdata in the container, you will have
difficulty providing many of these paths to the netdata container.

I'm not saying it's not possible - I'm saying that it's not easy, and it might not be worth the time.

If you're using the docker version, you should use it for two reasons:

1. Limited requirements: You only care about the system~~/network~~ metrics which are available in `/proc`,
2. Evaluation: You'd like to run netdata in an isolated environment before you decide to go "all in".

What I can tell you is that it's very stable, and snappy. Godspeed!
# netdata

Dockerfile for building and running a netdata deamon for your host instance.

Netdata monitors your server with thoughts of performance and memory usage, providing detailed insight into
very recent server metrics. It's nice, and now it's also dockerized.

More info about project: https://github.com/firehol/netdata

# Using

```
docker run -d --cap-add SYS_PTRACE \
           -v /proc:/host/proc:ro \
           -v /sys:/host/sys:ro \
           -p 19999:19999 titpetric/netdata
```

Open a browser on http://server:19999/ and watch how your server is doing.

# Getting emails on alarms

Netdata supports forwarding alarms to an email address. You can set up sSMTP by setting the following ENV variables:

- SSMTP_TO - This is the address alarms will be delivered to.
- SSMTP_SERVER - This is your SMTP server. Defaults to smtp.gmail.com.
- SSMTP_PORT - This is the SMTP server port. Defaults to 587.
- SSMTP_USER - This is your username for the SMTP server.
- SSMTP_PASS - This is your password for the SMTP server. Use an app password if using Gmail.
- SSMTP_TLS - Use TLS for the connection. Defaults to YES.
- SSMTP_HOSTNAME - The hostname mail will come from. Defaults to localhost.

For example, using gmail:

```
-e SSMTP_TO=user@gmail.com -e SSMTP_USER=user -e SSMTP_PASS=password
```

Alternatively, if you already have s sSMTP config, you can use that config with:

~~~
-v /path/to/config:/etc/ssmtp
~~~

See the following link for details on setting up sSMTP: [SSMTP - ArchWiki](https://wiki.archlinux.org/index.php/SSMTP)

# Monitoring docker container metrics

Netdata supports fetching container data from `docker.sock`. You can forward it to the netdata container with:

~~~
-v /var/run/docker.sock:/var/run/docker.sock
~~~

This will allow netdata to resolve container names.

> Note: forwarding docker.sock exposes the administrative docker API. If due to some security issue access has been obtained to the container, it will expose full docker API, allowing to stop, create or delete containers, as well as download new images in the host. 
>
> TL;DR If you care about security, consider forwarding a secure docker socket with [docker-proxy-acl](https://github.com/titpetric/docker-proxy-acl)

# Monitoring docker notes on some systems (Debian jessie)

On debian jessie only 'cpu' and 'disk' metrics show up under individual docker containers. To get the memory metric, you will have to add `cgroup_enable=memory swapaccount=1` to `/etc/default/grub`, appending the `GRUB_CMDLINE_LINUX_DEFAULT` variable:

~~~
$ cat /etc/default/grub  | grep GRUB_CMDLINE_LINUX_DEFAULT
GRUB_CMDLINE_LINUX_DEFAULT="quiet cgroup_enable=memory swapaccount=1"
~~~

After rebooting your linux instance, the memory accounting subsystem of the kernel will be enabled. Netdata will pick up additional metrics for the containers when it starts.

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

## Work-around

I provided a script called `fakenet.sh` which provides a copy of the `/proc/net` filesystem. You
should start this script before you start the netdata container. You can do it like this:

~~~
wget https://raw.githubusercontent.com/titpetric/netdata/master/fakenet.sh
chmod a+x fakenet.sh
nohup ./fakenet.sh > /dev/null 2>&1 &
~~~

Using the above command, the fakenet script will start in the background and will keep running
there. You can use other tools like `screen` or `tmux` to provide similar capability.

The script fills out the `/dev/shm/fakenet` location, which you must mount into the container.
You *must* mount it into `/fakenet/proc/net` exactly with the option like this:

~~~
-v /dev/shm/fakenet:/fakenet/proc/net
~~~

The script refreshes network information about every 250ms (four times per second). The interval
may be increased to give better accuracy of netdata, but CPU usage will also increase. Because
of this, the data is not very accurate and some spikes and valleys will occur because of a
shifting window between when the reading was taken (fakeproc) and between when the reading was
read by netdata. This means the margin for error is whatever data can be collected in ~250ms.

While the solution might not fit everybody, it's security-positive because the netdata container
can only inspect the fake proc/net location, and can't actually access any of the networks because
it runs on a private LAN / custom network which is managed and firewalled by docker. You may
even open access via application, like a nginx reverse proxy where you can add authentication etc.

Pro/con list:

* + network isolation stays in tact
* + all network device metrics are available
* - one more service to provide fakenet
* - accuracy vs. cpu use is a trade-off

# Additional notes

Netdata provides monitoring via a plugin architecture. This plugin supports many projects that don't
provide data over the `/proc` filesystem. When you're running netdata in the container, you will have
difficulty providing many of these paths to the netdata container.

What you do get (even with the docker version) is:

* Host CPU statististics 
* Host Network I/O, QoS
* Host Disk I/O
* Applications monitoring
* Container surface metrics (cpu/disk per name)

You will not get detailed application metrics (mysql, etc.) from other containers or from the host if running netdata in a container. It may be possible to get *some* of those metrics, but it might not be easy, and most likely not worth it. For most detailed metrics, netdata needs to share the same environment as the application server it monitors. This means it would need to run either in the same container (not even remotely practical), or in the same virtual machine (no containers).

What I can tell you is that it's very stable, and snappy. Godspeed!

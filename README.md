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

# Tags

There are a limited amount of tags available, generally for the recent versions. You can pull:

* `titpetric/netdata:1.5`
* `titpetric/netdata:1.4`

The tags include builds of netdata, with the same tag in upstream. If there's some need to add older tags, you may
use the provided `/releases` folder as reference, and add new tags as a PR. The `latest` tag is in line with the
upstream and is occasionally prone to failure. As far as older tags go - they will inevitably lack some new features
but should provide a more stable version to run.

> Developers note: new tags are not added automatically which means there might be some delay between when a new
> release of netdata is available and when a new tag is available on docker hub - to add a new release yourself, the procedure is as follows:
>
> 1. fork netdata repo,
> 2. run /update-releases.sh,
> 3. commit, push and submit a PR to `titpetric/netdata`
>
> When you will submit a PR, I will also add the new version to the docker hub and thank you profusely :).

# Limiting IP netdata listens to

By default netdata listens to 0.0.0.0 (any address). You might want to change this if you're running netdata in `--net=host` mode. You can pass the following environment variable:

- NETDATA_IP - the IP that netdata should listen to, e.g. `127.0.0.1` for localhost only.

# Passing custom netdata options

If you need to pass some custom options to netdata, you can pass the following environment variable:

- NETDATA_ARGS - for example if you don't want to use NETDATA_IP above, you can pass `-e NETDATA_ARGS="-i 127.0.0.1" for same effect.

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

# Getting alarms in slack

Netdata supports sending alerts to slack via webhooks. You can set that up by setting the following ENV variables:

- SLACK_WEBHOOK_URL - This is your incoming slack webhook
- SLACK_CHANNEL - This is the default channel that alerts will get sent to

For example:

```
-e SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXX -e SLACK_CHANNEL=alerts
```

# Getting alarms in Telegram

Netdata supports sending alerts to Telegram via token and chat ID. You can set that up by setting the following ENV variables:
For more details about Telegram alerts, see [this page - GitHub](https://github.com/firehol/netdata/wiki/health-monitoring#telegramorg-messages)

- TELEGRAM_BOT_TOKEN - This is your bot token
- TELEGRAM_CHAT_ID - This is the chat ID

For example:

```
-e TELEGRAM_BOT_TOKEN=22624413:AAGy12TkSMBYVBTe4lQt3BfUYvUs5h7I1jn -e TELEGRAM_CHAT_ID=137165138
```

# Getting alarms in Pushbullet

Netdata supports sending alerts to Pushbullet via API token. You can set that up by setting the following ENV variables:
More details about Pushbullet alerts are provided [here - GitHub](https://github.com/firehol/netdata/wiki/health-monitoring#pushbulletcom-push-notifications)

- PUSHBULLET_ACCESS_TOKEN - This is your API token
- PUSHBULLET_DEFAULT_EMAIL - This is the default email that alerts will get sent to if there is not a Pushbullet account attached to it

For example:

```
-e PUSHBULLET_ACCESS_TOKEN=o.l8VuizWhXgbERf2Q78ghtzb1LDCYvbSD -e PUSHBULLET_DEFAULT_EMAIL=your.email@gmail.com
```

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
nohup ./fakenet.sh >/dev/null 2>&1 &
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

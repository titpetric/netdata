# netdata

Dockerfile for building and running a netdata deamon for your host instance.

Netdata monitors your server with thoughts of performance and memory usage, providing detailed insight into
very recent server metrics. It's nice, and now it's also dockerized.

# Using

```
docker run -d --name netdata -v /proc:/host/proc:ro -v /sys:/host/sys:ro -p 19999:19999 titpetric/netdata
```

Open a browser on http://server:19999/ and watch how your server is doing.
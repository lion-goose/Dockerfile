### With other customizations
Besides `PASSWORD`, the image also defines the following environment variables that you can customize:
* `SERVER_ADDR`: the IP/domain to bind to, defaults to `0.0.0.0`
* `SERVER_ADDR_IPV6`: the IPv6 address to bind to, defaults to `::0`
* `METHOD`: encryption method to use, defaults to `aes-256-gcm`
* `TIMEOUT`: defaults to `300`
* `DNS_ADDRS`: DNS servers to redirect NS lookup requests to, defaults to `8.8.8.8,8.8.4.4`
* `TZ`: Timezone, defaults to `UTC`

Additional arguments supported by `ss-server` can be passed with the environment variable `ARGS`, for instance to start in verbose mode:
```bash
$ docker run -e ARGS=-v -p 8388:8388 -p 8388:8388/udp -d --restart always shadowsocks/shadowsocks-libev:latest
```

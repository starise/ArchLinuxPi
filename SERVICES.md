# Services

Instructions and notes to run and configure included services.

## AdGuard Home

For AdGuard Home installation to run correctly, it is required to open the port `3000` instead of the standard port `80` in Traefik. Edit this line in `services.yml`:

```yaml
traefik.http.services.adguard-home.loadbalancer.server.port=3000
```

Then run the installer opening the URL of the service (eg: adguard.example.com) and following the instructions. When the installation ends, just reset the port number to `80` and restart.

### Docker LAN subnet issue

For some reason, I found on Traefik that AdGuard service receives the wrong IP address from the wrong subnet (192.168.x.x instead of 172.x.x.x as any other Docker service). This causes the host to be unreachable. To resolve the issue we need to force Docker use a specific range.

Setup `/etc/docker/daemon.json` or `~/.config/docker/daemon.json` like this:

```json
{
    "default-address-pools": [
        {"base":"172.16.0.0/16","size":24},
        {"base":"172.20.0.0/16","size":24}
    ]
}
```

Restart Docker and services and the IP assigned to the container should be now correct.

### Conflicts with systemd-resolved

When `systemd-resolved` daemon is running, Docker will fail to bind on port 53. Because the daemon is listening on 127.0.0.53:53, we have to disable DNSStubListener [following the official instructions](https://hub.docker.com/r/adguard/adguardhome#resolved-daemon) of the image.

## Gerbera - UPnP Media Server

UPnP relies on having clients and servers able to communicate via IP Multicast. The default docker bridge network setup does not support multicast. [The easiest way](https://hub.docker.com/r/gerbera/gerbera) to achieve this is to use `network_mode: host` for the service. Anyway, using this strategy, it's not possible to redirect the port `49494` inside Docker via Traefik. In order to achieve this, [it's necessary](https://stackoverflow.com/a/60047840) to use a static configuration file (`/etc/traefik/rules.toml`) and enable the file provider to read this file.

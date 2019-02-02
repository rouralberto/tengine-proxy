# tengine-proxy
Automated Tengine proxy for Docker containers with Let’s Encrypt Certificates.

This solution gets the inspiration from `neilpang/nginx`. Instead of using Nginx, it sports an improved fork called *Tengine*, which is Nginx with super-powers.

## Libraries
- Tengine as proxy server
- `docker-gen` to gather metadata from other containers
- Forego to run the services
- `acme.sh` to manage the SSL certificates

## Usage
### docker run
In the simplest of usages, just run `$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro roura/tengine-proxy`.

### docker-compose
If you want to run it with `docker-compose` alongside another project:
```
version: '3.7'

services:
  proxy:
    image: roura/tengine-proxy
    network_mode: bridge
    container_name: proxy
    restart: on-failure
    ports:
    - 80:80
    volumes:
    - /var/run/docker.sock:/tmp/docker.sock:ro
    - ./proxy/certs:/etc/nginx/certs
    - ./proxy/acme:/acmecerts
    - ./proxy/conf.d:/etc/nginx/conf.d
  web:
    image: httpd
    network_mode: bridge
    container_name: httpd
    restart: on-failure
    environment:
      VIRTUAL_HOST: httpd.docker
```

## Options
### Virtual Hosting
Set `VIRTUAL_HOST` as environment variable on the containers you want proxied, like `VIRTUAL_HOST: sub.domain.org`. If the container can be called using multiple hostnames, just separate them with a comma.

If your application runs in a port other than *80*, then set the `VIRTUAL_PORT` variable to the port.

### Auto-SSL Management
Set `ENABLE_ACME: 'true'` if your host is Internet-reachable and the proxy will manage the certificates and the renewals for you using Let's Encrypt.
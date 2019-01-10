# Pleroma-Docker (Unofficial)

[Pleroma](https://pleroma.social/) is a selfhosted social network that uses OStatus/ActivityPub.

This repository dockerizes it for easier deployment.

<hr>

```cpp
#include <LICENSE>

/*
 * This repository comes with ABSOLUTELY NO WARRANTY
 *
 * I am not responsible for burning servers, angry users, fedi drama,
 * thermonuclear war, or you getting fired because your boss saw your NSFW posts.
 * Please do some research if you have any concerns about included
 * features or the software used by this script ***before*** using it.
 *
 * You are choosing to use this setup, and if you point the finger at me for
 * messing up your instance, I will laugh at you.
 */
```

<hr>

## Alternatives

If this setup is a bit overwhelming there are a lot of other great dockerfiles
or guides from the community. A few are linked below. This list is not exhaustive and not ordered.

- [Angristan/dockerfiles/pleroma](https://github.com/Angristan/dockerfiles/tree/master/pleroma)
- [RX14/iscute.moe](https://github.com/RX14/kurisu.rx14.co.uk/blob/master/services/iscute.moe/pleroma/Dockerfile)
- [rysiek/docker-pleroma](https://git.pleroma.social/rysiek/docker-pleroma)

## Docs

### Prerequisites

- 1-2GB of free HDD space (yeah it sucks, Alpine Linux soontm)
- `m4` and `awk` in remotely recent versions
- `curl` or `wget` if you want smarter build caches and commands like `./pleroma mod`
- `jq` and `dialog` if you want to use `./pleroma mod`
- Bash 4.0+ (fancy scripting stuff)
- Docker 18.06.0+ and docker-compose 1.22.0-rc1+ (We need compose file format 3.7+ for `init:`)

### Installation

- Clone this repository
- Create a `config.exs` and `.env` file
- Run `./pleroma build` and `./pleroma up`
- Profit!

### Updates

Run `./pleroma build` again and start the updated image with `./pleroma up`.

You don't need to stop your pleroma server for either of those commands.

### Maintenance

Pleroma maintenance is usually done with mix tasks.
You can run these tasks in your running pleroma server using `./pleroma mix [task] [arguments...]`.
If you need to fix some bigger issues you can also spawn a shell with `./pleroma enter`.

### Customization

Add your customizations (and their folder structure) to `custom.d/`.
They will be mounted and symlinked into the right place when the container starts.
You can even replace/patch pleroma’s code with this, because the project is recompiled at startup if needed.

In general: Prepending `custom.d/` to pleroma’s customization guides should work all the time.<br>
Check them out in the official pleroma wiki.

For example: A custom thumbnail now goes into `custom.d/priv/static/instance/thumbnail.jpeg` instead of `priv/static/instance/thumbnail.jpeg`.

### Patches

Works exactly like customization, but we have a neat little helper here.

Use `./pleroma mod [regex]` to mod any file that ships with pleroma, without having to type the complete path.<br>

### Configuration

All the pleroma options that you put into your `*.secret.exs` now go into `config.exs`.

`.env` stores config values that need to be known at orchestration time.<br>
They should be self-explaining but here's some bonus info on important ones:

#### Data Storage (`DOCKER_DATADIR`)

A folder that will be bind-mounted into the container.<br>
This is where pleroma and postgres will store their data.

#### Database (`SCRIPT_DEPLOY_POSTGRES`)

Values: `true` / `false`

By default pleroma-docker deploys a postgresql container and links it to pleroma’s container as a zero-config data store.
If you already have a postgres database or want to host it on a physically different machine, set this value to `false`.
Make sure to edit the `config :pleroma, Pleroma.Repo` variables when doing that.

#### Reverse Proxy (`SCRIPT_USE_PROXY`)

Values: `traefik` / `nginx` / `manual`

Pleroma is usually run behind a reverse-proxy.<br>
Pleroma-docker gives you multiple options here.

##### Traefik

In traefik-mode we will generate a pleroma container with traefik-compatible labels.
These will be picked up at runtime to dynamically create a reverse-proxy configuration.
This should 'just work' if `watch=true` and `exposedByDefault=false` are set in the `[docker]` section of your `traefik.conf`.
SSL will also 'just work' once you add a matching `[[acme.domains]]` entry in there.

##### NGINX

In nginx-mode we will generate a bare nginx container that is linked to pleroma.
The nginx container is absolutely unmodified and expects to be configured by you.
The nginx file in [Pleroma's Repository](https://git.pleroma.social/pleroma/pleroma/blob/develop/installation/pleroma.nginx) is a good starting point.

We will mount your configs like this:
```txt
custom.d/server.nginx -> /etc/nginx/nginx.conf
custom.d/vhost.nginx -> /etc/nginx/conf.d/pleroma.conf
```

To reach your pleroma container from inside nginx use `proxy_pass http://pleroma:4000;`.

Set `SCRIPT_PORT_HTTP` and `SCRIPT_PORT_HTTPS` to the ports you want to listen on.<br>
Specify the ip to bind to in `SCRIPT_BIND_IP`. These values are required.

The container only listens on `SCRIPT_PORT_HTTPS` if `SCRIPT_ENABLE_SSL` is `true`.

##### Apache / httpd

Just like nginx-mode this starts an unmodified apache server that expects to be configured by you.<br>
Again [Pleroma's Config](https://git.pleroma.social/pleroma/pleroma/blob/develop/installation/pleroma-apache.conf) is a good starting point.

We will mount your configs like this:
```
custom.d/server.httpd -> /usr/local/apache2/conf/httpd.conf
custom.d/vhost.httpd -> /usr/local/apache2/conf/extra/httpd-vhosts.conf
```

To reach your pleroma container from inside apache use `ProxyPass [loc] http://pleroma:4000/`.

Again setting `SCRIPT_PORT_HTTP`, `SCRIPT_PORT_HTTPS` and `SCRIPT_BIND_IP` is required.

The container only listens on `SCRIPT_PORT_HTTPS` if `SCRIPT_ENABLE_SSL` is `true`.

##### Manual

In manual mode we do not create any reverse proxy for you.
You'll have to figure something out on your own.

If `SCRIPT_BIND_IN_MANUAL` is `true` we will forward `pleroma:4000` to `${SCRIPT_BIND_IP}:${SCRIPT_PORT_HTTP}`.

**Pleroma's internal SSL implementation is currently not supported.**

#### SSL (`SCRIPT_ENABLE_SSL`)

Values: `true` / `false`

If you want to use SSL with your Apache or NGINX containers you'll need a
certificate. Certificates need to be placed into `custom.d` and will be
bind-mounted into the server's container at runtime.

We will mount your certs like this:
```
custom.d/ssl.crt -> /ssl/ssl.crt
custom.d/ssl.key -> /ssl/ssl.key
```

You can reference them in Apache like this:
```apache
<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile "/ssl/ssl.crt"
    SSLCertificateKeyFile "/ssl/ssl.key"
</VirtualHost>
```

And in NGINX like this:
```nginx
listen 443 ssl;
ssl_certificate     /ssl/ssl.crt;
ssl_certificate_key /ssl/ssl.key;
```

In traefik-mode and manual-mode these files and the `SCRIPT_ENABLE_SSL` value are ignored.

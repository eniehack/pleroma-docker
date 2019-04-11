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

## In the Wild

My own instance is managed by this script.<br>
Take a look at [hosted/pleroma](https://glitch.sh/hosted/pleroma) if you get stuck or need some inspiration.

Does your instance use pleroma-docker?<br>
Let me know and I'll add you to this list.

## Docs

These docs assume that you have at least a basic understanding
of the pleroma installation process and common docker commands.

If you have questions about Pleroma head over to https://docs-develop.pleroma.social/.<br>
For help with docker check out https://docs.docker.com/.

### Prerequisites

- ~500mb of free HDD space
- `m4` and `awk` in remotely recent versions
- `git` if you want smart build caches
- `curl`, `jq`, and `dialog` if you want to use `./pleroma mod`
- Bash 4.0+ (fancy scripting stuff)
- Docker 18.06+ and docker-compose 1.22+

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

For example: `/pleroma mix pleroma.user new sn0w ...`

### Customization

Add your customizations (and their folder structure) to `custom.d/`.<br>
They will be copied into the right place when the container starts.<br>
You can even replace/patch pleroma’s code with this,
because the project is recompiled at startup if needed.

In general: Prepending `custom.d/` to pleroma’s customization guides should work all the time.<br>
Check them out in the official pleroma wiki.

For example: A custom thumbnail now goes into `custom.d/` + `priv/static/instance/thumbnail.jpeg`.

### Patches

Works exactly like customization, but we have a neat little helper here.

Use `./pleroma mod [regex]` to mod any file that ships with pleroma, without having to type the complete path.

### Configuration

All the pleroma options that you usually put into your `*.secret.exs` now go into `config.exs`.

`.env` stores config values that need to be known at orchestration time.<br>
They should be self-explaining but here's some bonus info on important ones:

#### Data Storage (`DOCKER_DATADIR`)

A folder that will be bind-mounted into the container.<br>
This is where pleroma and postgres will store their data.

#### Database (`SCRIPT_DEPLOY_POSTGRES`)

Values: `true` / `false`

By default pleroma-docker deploys a postgresql container and links it to pleroma’s container as a zero-config data store.
If you already have a postgres database or want to host it on a physically different machine, set this value to `false`.
Make sure to edit the `config :pleroma, Pleroma.Repo` variables in `config.exs` when doing that.

#### Reverse Proxy (`SCRIPT_USE_PROXY`)

Values: `traefik` / `nginx` / `apache` / `manual`

Pleroma is usually run behind a reverse-proxy.<br>
Pleroma-docker gives you multiple options here.

##### Manual

In manual mode we do not create any reverse proxy for you.<br>
You'll have to figure something out on your own.

If `SCRIPT_BIND_IN_MANUAL` is `true` we will forward `pleroma:4000` to `${SCRIPT_BIND_IP}:${SCRIPT_PORT_HTTP}`.

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

## Attribution

Thanks to [Angristan](https://github.com/Angristan/dockerfiles/tree/master/pleroma) and [RX14](https://github.com/RX14/kurisu.rx14.co.uk/blob/master/services/iscute.moe/pleroma/Dockerfile) for their dockerfiles, which served as an inspiration for the early versions of this script.

The current version is based on the [official wiki guides](https://git.pleroma.social/pleroma/pleroma/tree/develop/docs/installation).<br>
Thanks to all people who contributed to those.

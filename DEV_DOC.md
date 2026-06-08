# DEV_DOC

## Goal

This document explains how to set up, build, launch, and maintain the mandatory
Inception stack from scratch.

## Prerequisites

- a Linux virtual machine
- Docker Engine installed
- Docker Compose available through `docker compose`
- permission to write inside `/home/mohel-am/data`
- the local domain `mohel-am.42.fr` mapped to the VM IP address in `/etc/hosts`

Example `/etc/hosts` entry for local testing inside the VM:

```txt
127.0.0.1 mohel-am.42.fr
```

## Repository Layout

- `Makefile`: main entrypoint for building and managing the stack
- `srcs/.env`: non-secret environment variables
- `srcs/docker-compose.yml`: service, network, volume, and secret definitions
- `srcs/requirements/mariadb`: MariaDB image files
- `srcs/requirements/wordpress`: WordPress and `php-fpm` image files
- `srcs/requirements/nginx`: NGINX and TLS image files
- `secrets/`: local secret files not meant to be committed

## Configuration Files And Secrets

### Environment Variables

`srcs/.env` stores non-secret settings such as:

- domain name
- database name and database username
- WordPress usernames and emails
- host paths for persistent data
- certificate subject fields

Subject rule reminder: `WP_ADMIN_USER` must not contain `admin` or `administrator`.

### Secret Files

Create or update these files before the first launch:

- `secrets/db_root_password.txt`
- `secrets/db_password.txt`
- `secrets/credentials.txt`

`secrets/credentials.txt` must contain:

```txt
WP_ADMIN_PASSWORD=...
WP_USER_PASSWORD=...
```

`make up` checks that all required secret files exist and are non-empty before starting.

## Build And Launch

From the repository root:

```sh
make
```

What happens:

- the Makefile creates `/home/mohel-am/data/mariadb`
- the Makefile creates `/home/mohel-am/data/wordpress`
- Docker Compose builds the three custom images
- Docker Compose starts the containers in detached mode

To rebuild images without starting:

```sh
make build
```

## Management Commands

Start existing containers:

```sh
make start
```

Stop running containers:

```sh
make stop
```

Remove containers and network:

```sh
make down
```

Show logs:

```sh
make logs
```

Show service status:

```sh
make ps
```

Remove containers, images, and named volumes declared by Compose:

```sh
make fclean
```

## Persistent Data

The mandatory persistent data is stored on the host in:

- `/home/mohel-am/data/mariadb`
- `/home/mohel-am/data/wordpress`

These paths are referenced from `srcs/.env` and are attached through Docker named
volumes declared in `srcs/docker-compose.yml`. The data remains available after a
container restart or image rebuild unless it is explicitly removed.

## Service Notes

### MariaDB

- initialized by `mariadb-init.sh`
- creates the WordPress database and database user on first startup only
- stores its database files in `/var/lib/mysql`

### WordPress

- waits for MariaDB before configuration
- copies WordPress into the persistent website volume on first startup
- generates `wp-config.php` automatically
- installs the site and creates the required users through `wp-cli`

### NGINX

- generates a self-signed TLS certificate on first startup
- renders the virtual host configuration from a template using `DOMAIN_NAME`
- proxies PHP requests to `wordpress:9000`

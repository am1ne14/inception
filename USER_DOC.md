# USER_DOC

## Overview

This stack provides three services:

- `nginx`: receives HTTPS requests on port `443`
- `wordpress`: runs the WordPress application through `php-fpm`
- `mariadb`: stores the WordPress database

The services are connected through an internal Docker network. Only NGINX is exposed
to the outside.

## Start And Stop The Project

From the repository root:

```sh
make
```

To stop the running containers:

```sh
make stop
```

To remove the containers and network:

```sh
make down
```

To restart the whole stack:

```sh
make restart
```

## Access The Website And The Administration Panel

Make sure the local domain points to the machine running Docker:

```txt
mohel-am.42.fr
```

Then open these URLs in a browser:

- Website: `https://mohel-am.42.fr`
- Administration panel: `https://mohel-am.42.fr/wp-admin`

The TLS certificate is self-signed, so the browser may display a security warning on
the first visit. Accept the warning to continue.

## Locate And Manage Credentials

Credentials are stored in the local `secrets/` directory:

- `secrets/db_root_password.txt`: MariaDB root password
- `secrets/db_password.txt`: WordPress database user password
- `secrets/credentials.txt`: WordPress admin and standard user passwords

If a password is changed, restart the stack after checking that the current database
state matches the new value. For a fresh installation, changing the files before the
first `make` is the safest approach.

## Check That The Services Are Running Correctly

To list the containers:

```sh
make ps
```

To read the logs:

```sh
make logs
```

To confirm the HTTPS entrypoint responds:

```sh
curl -k https://mohel-am.42.fr
```

To confirm persistence, restart the project and verify that the WordPress site and its
content still exist.

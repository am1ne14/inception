*This project has been created as part of the 42 curriculum by mohel-am*

# Inception

## Description

Inception is a system administration project focused on Docker and service isolation.
The goal is to build a small web infrastructure inside a virtual machine using Docker
Compose and custom Docker images only. The mandatory stack in this repository contains
three services:

- NGINX as the single public HTTPS entrypoint on port `443`
- WordPress with `php-fpm`
- MariaDB for the WordPress database

The project also uses two persistent Docker named volumes:

- one for the MariaDB data
- one for the WordPress files

## Project Description

This repository contains a mandatory-only implementation of the Inception subject.
Each service is built from its own Dockerfile based on Debian Bookworm, which is the
penultimate stable Debian release required by the subject. The services communicate
through a dedicated Docker bridge network, and the persistent data is stored on the
host inside `/home/mohel-am/data`.

### Sources Included In The Project

- Debian packages installed during image build
- WordPress downloaded from `wordpress.org` during the WordPress image build
- `wp-cli` downloaded during the WordPress image build
- custom service scripts and configuration files written for this repository

### Main Design Choices

- Only the mandatory services are implemented
- NGINX is the only published service and exposes only `443`
- WordPress and MariaDB stay private on the internal Docker network
- Credentials are stored in Docker secrets instead of hardcoded Dockerfiles
- The WordPress and MariaDB storages use Docker named volumes mapped to
  `/home/mohel-am/data`

### Required Comparisons

#### Virtual Machines vs Docker

A virtual machine emulates a full operating system with its own kernel-level isolation,
while Docker containers share the host kernel and isolate processes at the application
level. For Inception, Docker is lighter, faster to start, and better suited for running
multiple cooperating services inside one VM.

#### Secrets vs Environment Variables

Environment variables are convenient for non-sensitive configuration such as hostnames,
ports, and email addresses. Docker secrets are better for passwords because they are
mounted as files at runtime and are easier to keep out of the Git repository.

#### Docker Network vs Host Network

A Docker bridge network isolates the services while still letting them communicate by
service name such as `mariadb` and `wordpress`. Host networking would remove that
isolation and is explicitly forbidden by the subject.

#### Docker Volumes vs Bind Mounts

Docker named volumes are managed by Docker and are the required storage mechanism for
the mandatory WordPress and MariaDB data. Bind mounts map a host path directly into a
container and are not allowed for these mandatory persistent storages.

## Instructions

### Prerequisites

- a Linux virtual machine with Docker and Docker Compose installed
- the domain `mohel-am.42.fr` mapped to the VM IP address in `/etc/hosts`
- the directories `/home/mohel-am/data/mariadb` and `/home/mohel-am/data/wordpress`
  available, or created automatically by the Makefile
- valid secret values written in:
  - `secrets/db_root_password.txt`
  - `secrets/db_password.txt`
  - `secrets/credentials.txt`

### Build And Run

From the repository root:

```sh
make
```

Useful commands:

```sh
make up
make down
make restart
make logs
make ps
```

Once the stack is running, open:

- `https://mohel-am.42.fr`
- `https://mohel-am.42.fr/wp-admin`

## Resources

- Docker documentation: `https://docs.docker.com/`
- Docker Compose specification: `https://docs.docker.com/compose/`
- NGINX documentation: `https://nginx.org/en/docs/`
- MariaDB documentation: `https://mariadb.com/kb/en/documentation/`
- PHP-FPM documentation: `https://www.php.net/manual/en/install.fpm.php`
- WordPress documentation: `https://wordpress.org/documentation/`
- WP-CLI documentation: `https://developer.wordpress.org/cli/commands/`

### How AI Was Used

AI was used as a development assistant for:

- turning the subject constraints into an implementation plan
- drafting Dockerfiles, shell entrypoint scripts, and configuration files
- checking the mandatory scope so no bonus service was added
- helping structure the required documentation files

Every generated part was reviewed, adapted to the subject requirements, and kept only
when it was fully understood and consistent with the project rules.

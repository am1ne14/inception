FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb-init.sh /usr/local/bin/mariadb-init.sh

RUN chmod +x /usr/local/bin/mariadb-init.sh \
	&& mkdir -p /run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql

ENTRYPOINT ["/usr/local/bin/mariadb-init.sh"]

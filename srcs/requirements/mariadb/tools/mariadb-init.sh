#!/bin/sh

set -eu

DB_ROOT_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_root_password)"
DB_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_password)"

escape_sql() {
	printf "%s" "$1" | sed "s/'/''/g"
}

DB_ROOT_PASSWORD_ESCAPED="$(escape_sql "${DB_ROOT_PASSWORD}")"
DB_PASSWORD_ESCAPED="$(escape_sql "${DB_PASSWORD}")"

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

	/usr/sbin/mariadbd \
		--user=mysql \
		--skip-networking \
		--socket=/run/mysqld/mysqld.sock &

	mariadb_pid="$!"
	attempts=0
	while ! mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
		attempts=$((attempts + 1))
		if [ "${attempts}" -ge 60 ]; then
			echo "MariaDB temporary server did not start in time." >&2
			kill "${mariadb_pid}" 2>/dev/null || true
			exit 1
		fi
		sleep 1
	done

	mariadb --socket=/run/mysqld/mysqld.sock <<-EOF
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD_ESCAPED}';
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD_ESCAPED}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOF

	mariadb-admin --socket=/run/mysqld/mysqld.sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown
	wait "${mariadb_pid}" || true
fi

exec /usr/sbin/mariadbd --user=mysql --console

#!/bin/sh

set -eu

DB_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(grep '^WP_ADMIN_PASSWORD=' /run/secrets/wp_credentials | cut -d'=' -f2- | tr -d '\r\n')"
WP_USER_PASSWORD="$(grep '^WP_USER_PASSWORD=' /run/secrets/wp_credentials | cut -d'=' -f2- | tr -d '\r\n')"
WP_ADMIN_USER_LOWER="$(printf "%s" "${WP_ADMIN_USER}" | tr '[:upper:]' '[:lower:]')"

case "${WP_ADMIN_USER_LOWER}" in
	*admin* | *administrator*)
		echo "WP_ADMIN_USER must not contain admin or administrator." >&2
		exit 1
		;;
esac

generate_salt() {
	php -r 'echo bin2hex(random_bytes(64));'
}

mkdir -p /run/php /var/www/html
chown -R www-data:www-data /run/php /var/www/html

attempts=0
while ! mariadb-admin ping \
	--host="${MYSQL_HOST}" \
	--port="${MYSQL_PORT}" \
	--user="${MYSQL_USER}" \
	--password="${DB_PASSWORD}" \
	--silent >/dev/null 2>&1; do
	attempts=$((attempts + 1))
	if [ "${attempts}" -ge 60 ]; then
		echo "MariaDB is not reachable from the WordPress container." >&2
		exit 1
	fi
	sleep 2
done

if [ ! -f /var/www/html/wp-load.php ]; then
	cp -a /usr/src/wordpress/. /var/www/html/
fi

cd /var/www/html

if [ ! -f wp-config.php ]; then
	wp config create \
		--allow-root \
		--path=/var/www/html \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="${MYSQL_HOST}:${MYSQL_PORT}" \
		--skip-salts

	wp config set WP_HOME "https://${DOMAIN_NAME}" --allow-root
	wp config set WP_SITEURL "https://${DOMAIN_NAME}" --allow-root
	wp config set AUTH_KEY "$(generate_salt)" --allow-root
	wp config set SECURE_AUTH_KEY "$(generate_salt)" --allow-root
	wp config set LOGGED_IN_KEY "$(generate_salt)" --allow-root
	wp config set NONCE_KEY "$(generate_salt)" --allow-root
	wp config set AUTH_SALT "$(generate_salt)" --allow-root
	wp config set SECURE_AUTH_SALT "$(generate_salt)" --allow-root
	wp config set LOGGED_IN_SALT "$(generate_salt)" --allow-root
	wp config set NONCE_SALT "$(generate_salt)" --allow-root
fi

if ! wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then
	wp core install \
		--allow-root \
		--path=/var/www/html \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email
fi

if ! wp user get "${WP_USER}" --allow-root --path=/var/www/html >/dev/null 2>&1; then
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--allow-root \
		--path=/var/www/html \
		--role=author \
		--user_pass="${WP_USER_PASSWORD}"
fi

chown -R www-data:www-data /var/www/html

exec /usr/sbin/php-fpm8.2 -F

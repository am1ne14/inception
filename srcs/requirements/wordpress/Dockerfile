FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	php-fpm \
	php-cli \
	php-mysql \
	php-curl \
	php-gd \
	php-mbstring \
	php-xml \
	php-zip \
	php-intl \
	mariadb-client \
	curl \
	ca-certificates \
	tar \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://wordpress.org/wordpress-6.9.4.tar.gz -o /tmp/wordpress.tar.gz \
	&& mkdir -p /usr/src \
	&& tar -xzf /tmp/wordpress.tar.gz -C /usr/src \
	&& rm -f /tmp/wordpress.tar.gz \
	&& curl -fsSL https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar -o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp \
	&& mkdir -p /var/www/html /run/php \
	&& chown -R www-data:www-data /var/www/html /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wordpress-init.sh /usr/local/bin/wordpress-init.sh

RUN chmod +x /usr/local/bin/wordpress-init.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-init.sh"]

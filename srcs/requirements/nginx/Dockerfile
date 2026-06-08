FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl \
	gettext-base \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/default.conf.template /etc/nginx/templates/default.conf.template
COPY tools/nginx-init.sh /usr/local/bin/nginx-init.sh

RUN chmod +x /usr/local/bin/nginx-init.sh \
	&& mkdir -p /etc/ssl/private /etc/ssl/certs

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-init.sh"]

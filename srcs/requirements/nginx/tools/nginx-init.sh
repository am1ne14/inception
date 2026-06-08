#!/bin/sh

set -eu

SSL_CERT=/etc/ssl/certs/inception.crt
SSL_KEY=/etc/ssl/private/inception.key

mkdir -p /etc/ssl/private /etc/ssl/certs

envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template > /etc/nginx/sites-available/default
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

if [ ! -f "${SSL_CERT}" ] || [ ! -f "${SSL_KEY}" ]; then
	openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 \
		-keyout "${SSL_KEY}" \
		-out "${SSL_CERT}" \
		-subj "/C=${CERTS_COUNTRY}/ST=${CERTS_STATE}/L=${CERTS_LOCALITY}/O=${CERTS_ORGANIZATION}/OU=${CERTS_ORG_UNIT}/CN=${DOMAIN_NAME}/emailAddress=${CERTS_EMAIL}"
fi

exec nginx -g 'daemon off;'

#!/usr/bin/env bash

set -eux

# true is shell command and always return 0
# false always return 1
if [ -z "${CODESPACES}" ] ; then
	SITE_HOST="http://localhost:8080"
else
	SITE_HOST="https://${CODESPACE_NAME}-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

PLUGIN_DIR=/workspaces/openid-connect-generic

# Attempt to make ipv4 traffic have a higher priority than ipv6.
sudo sh -c "echo 'precedence ::ffff:0:0/96 100' >> /etc/gai.conf"

# Install Composer dependencies.
cd "${PLUGIN_DIR}"
COMPOSER_ALLOW_XDEBUG=0 COMPOSER_MEMORY_LIMIT=-1 composer install

# Install NPM dependencies.
cd "${PLUGIN_DIR}"
if [ ! -d "node_modules" ]; then
	npm ci
fi

# Setup the WordPress environment.
cd "/app"
echo "Setting up WordPress at $SITE_HOST"
wp core install --url="$SITE_HOST" --title="OpenID Connect Development" --admin_user="admin" --admin_email="admin@example.com" --admin_password="password" --skip-email

echo "Done!"

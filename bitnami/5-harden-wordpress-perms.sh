#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

WEB_SITE_ROOT="/opt/bitnami/apps/wordpress/htdocs"

pushd $WEB_SITE_ROOT &> /dev/null

chown -R bitnami:bitnami .
chown -R bitnami:daemon wp-content/uploads
chown -R bitnami:daemon wp-content/themes
chown -R bitnami:daemon wp-content/plugins
chown -R bitnami:daemon wp-content/upgrade


popd &> /dev/null

echo "INFO: Done"


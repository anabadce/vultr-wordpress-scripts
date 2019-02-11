#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Defining known defaults
if [[ -d /opt/bitnami/apps/wordpress/htdocs ]]; then
    WEB_USER=daemon
    LOCAL_USER=bitnami
    SITE_PATH=/opt/bitnami/apps/wordpress/htdocs
else
    WEB_USER=nginx
    LOCAL_USER=root
    SITE_PATH=/var/www/html
fi

if [[ -z $1 ]]; then
    echo "Usage: $(basename "$0") SITE_PATH"
    echo "Example: $(basename "$0") /var/www/html"
    echo
    echo "Running using default Wordpress location in $SITE_PATH"
else
    SITE_PATH=$1
fi

# Relaxing permissions
echo "INFO: Changing file ownership to $WEB_USER"
chown -R $WEB_USER:$WEB_USER $SITE_PATH

echo "INFO: Done"


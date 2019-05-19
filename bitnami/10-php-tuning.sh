#!/bin/bash -e

# Setting up cron jobs for updates and so on...

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

PHP_PATH=/opt/bitnami/php/etc/php.ini

# ======== php.ini ========

if [[ -f "$PHP_PATH" ]] ; then
    echo "INFO: Found php.ini, changing..."

    sed -i.bak "s/;extension=apcu.so/extension=apcu.so/" "$PHP_PATH"
    sed -i.bak -E "s/.*max_input_vars\ =\ .*/max_input_vars = 3000/" "$PHP_PATH"
    sed -i.bak -E "s/expose_php.*/expose_php = Off/" "$PHP_PATH"

    /opt/bitnami/ctlscript.sh restart php-fpm
else
    echo "ERROR: cannot find php.ini in $PHP_PATH ..."
    exit 1
fi

echo "INFO: Done"


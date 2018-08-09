#!/bin/bash -e

PHP_INI=/etc/php.ini

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

PHP_VERSION=$(rpm -qa | grep php | grep common | cut -d '-' -f 1 | sort -u)

yum install -y "$PHP_VERSION-pecl-apcu"
yum install -y "$PHP_VERSION-soap"


# ========= PHP =============
sed -i.bak "s/expose_php = On/expose_php = Off/" $PHP_INI
service php-fpm restart



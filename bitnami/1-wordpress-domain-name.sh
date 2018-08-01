#!/bin/bash -e

# https://docs.bitnami.com/bch/apps/wordpress/#how-to-change-the-wordpress-domain-name

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

if [[ -z $1 ]]; then
    echo "Usage: $(basename "$0") DOMAIN_NAME"
    exit 1
else
    DOMAIN_NAME=$1
fi

PROTOCOL="https"
WORDPRESS_CONFIG="/opt/bitnami/apps/wordpress/htdocs/wp-config.php"

echo "INFO: Editing $WORDPRESS_CONFIG"

sed -i -E "s/^define\('WP_SITEURL.*/define('WP_SITEURL', '$PROTOCOL:\/\/$DOMAIN_NAME\/');/" $WORDPRESS_CONFIG
sed -i -E "s/^define\('WP_HOME.*/define('WP_HOME', '$PROTOCOL:\/\/$DOMAIN_NAME\/');/" $WORDPRESS_CONFIG

cat $WORDPRESS_CONFIG | grep $DOMAIN_NAME

echo "INFO: Done"


#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

WEB_SITE_ROOT="/opt/bitnami/apps/wordpress/htdocs"

echo "INFO: Setting up Wordpress file permissions..."

pushd $WEB_SITE_ROOT &> /dev/null

chown -R bitnami:bitnami .
chown bitnami:daemon wp-config.php
chmod 640 wp-config.php
chown -R bitnami:daemon wp-content/uploads
chown -R bitnami:daemon wp-content/themes
chown -R bitnami:daemon wp-content/plugins
chown -R bitnami:daemon wp-content/upgrade

popd &> /dev/null

# https://docs.bitnami.com/general/apps/wordpress/#how-to-disable-the-wordpress-cron-script
WP_CONFIG=/opt/bitnami/apps/wordpress/htdocs/wp-config.php
CRON_DISABLE="define('DISABLE_WP_CRON', true);"
AFTER_LINE="DB_COLLATE"

if grep --quiet "$CRON_DISABLE" "$WP_CONFIG"; then
    echo "INFO: Already found DISABLE_WP_CRON in WP_CONFIG, skipping..."
else
    echo "INFO: Adding DISABLE_WP_CRON to WP_CONFIG..."
    sed -i "/$AFTER_LINE/a $CRON_DISABLE" $WP_CONFIG
fi

echo "INFO: Adding cron job for wp-cron.php..."

echo '0 * * * * daemon /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/php/bin/php -q wp-cron.php" &>/dev/null ' > /etc/cron.d/5-wp-cron 

# Blocking /wp-cron.php and /xmlrpc.php in Apache

APACHE_CONF="/opt/bitnami/apache2/conf/bitnami/bitnami.conf"
START_LINE="SSLCertificateKeyFile"

LINE1="RewriteEngine On"
LINE2="RewriteRule ^/wp-cron.php$ - [R=403,L]"
LINE3="RewriteRule ^/xmlrpc.php$  - [R=403,L]"

if grep --quiet "$START_LINE" "$APACHE_CONF"; then

    if grep --quiet -E "wp-cron|xmlrpc" "$APACHE_CONF"; then
        echo "INFO: Rewrite config already added"
    else
        echo "INFO: Adding Rewrite rules"
        sed -i.bak "/$START_LINE/a $LINE1\n$LINE2\n$LINE3" $APACHE_CONF
        /opt/bitnami/ctlscript.sh restart apache
    fi
else
    echo "ERROR: Cannot find START_LINE"
fi

grep -E "wp-cron|xmlrpc" $APACHE_CONF

echo "INFO: Done"


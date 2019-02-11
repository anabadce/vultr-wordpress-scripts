#!/bin/bash -e

# https://docs.bitnami.com/bch/apps/wordpress/#how-to-force-https-redirection-with-apache

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

APACHE_CONF="/opt/bitnami/apache2/conf/bitnami/bitnami.conf"
START_LINE="<VirtualHost _default_:80>"

LINE1="RewriteEngine On"
LINE2="RewriteCond %{HTTPS} !=on"
LINE3="RewriteRule ^/(.*) https://$DOMAIN_NAME/\$1 [R,L]"

if grep --quiet "$START_LINE" "$APACHE_CONF"; then

    if grep --quiet "$LINE3" "$APACHE_CONF"; then
        echo "INFO: HTTPS redirect config already added"
    else
        echo "INFO: Adding HTTPS redirect"
        sed -i.bak "/$START_LINE/a $LINE1\n$LINE2\n$LINE3" $APACHE_CONF
        /opt/bitnami/ctlscript.sh restart apache
    fi
else
    echo "ERROR: Cannot find START_LINE"
    
fi

cat $APACHE_CONF | grep -i https

echo "INFO: Done"


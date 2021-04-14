#!/bin/bash -e

# https://docs.bitnami.com/bch/apps/wordpress/#how-to-enable-https-support-with-ssl-certificates

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

if [[ -z $2 ]]; then
    echo "Usage: $(basename "$0") DOMAIN_NAME EMAIL"
    exit 1
else
    DOMAIN_NAME=$1
    EMAIL=$2
fi

WEB_SERVER_CONFIG="/opt/bitnami/apache2/conf/bitnami/bitnami.conf"
WEB_SITE_ROOT="/opt/bitnami/apps/wordpress/htdocs"

pushd ~ &> /dev/null

if [[ -f /usr/bin/certbot ]]; then
    echo "INFO: Found certbot, skipping install"
else
    apt update
    apt install snapd -y
    snap install core; snap refresh core
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
fi

LE_CERT=/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem
LE_KEY=/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem

if [[ -f $LE_CERT ]]; then
    echo "INFO: Found $LE_CERT, skipping new cert request"
else
    if [[ $DOMAIN_NAME = www.* ]]; then
        DOMAIN_NAME_NO_WWW=$(echo $DOMAIN_NAME | cut -d '.' -f 2-)
        certbot certonly \
        --email $EMAIL \
        --webroot \
        -w $WEB_SITE_ROOT \
        -d $DOMAIN_NAME -d $DOMAIN_NAME_NO_WWW \
        --agree-tos \
        -n
    else
        certbot certonly \
        --email $EMAIL \
        --webroot \
        -w $WEB_SITE_ROOT \
        -d $DOMAIN_NAME \
        --agree-tos \
        -n
    fi
fi

if grep --quiet letsencrypt $WEB_SERVER_CONFIG ; then
    echo "INFO: Found letsencrypt paths in $WEB_SERVER_CONFIG, skipping Apache configure"
else
    echo "INFO: Updating $WEB_SERVER_CONFIG ..."
    sed -i.bak -E "s|SSLCertificateFile\ .*|SSLCertificateFile \"$LE_CERT\"|" "$WEB_SERVER_CONFIG"
    sed -i.bak -E "s|SSLCertificateKeyFile\ .*|SSLCertificateKeyFile \"$LE_KEY\"|" "$WEB_SERVER_CONFIG"

    /opt/bitnami/ctlscript.sh restart apache
fi

popd &> /dev/null

cat $WEB_SERVER_CONFIG | grep $DOMAIN_NAME

echo "INFO: Done"

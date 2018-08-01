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

WEB_SERVER_CONFIG="/opt/bitnami/apps/wordpress/htdocs/wp-config.php"
WEB_SITE_ROOT="/opt/bitnami/apps/wordpress/htdocs"

pushd ~ &> /dev/null
if [[ -f certbot-auto ]]; then
    echo "INFO: certbot-auto aready installed"
else
    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto
    ./certbot-auto certonly \
        --email $EMAIL \
        --webroot \
        -w $WEB_SITE_ROOT \
        -d $DOMAIN_NAME \
        --agree-tos \
        -n

    LE_CERT=/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem
    LE_KEY=/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem

   # sed -i.bak -E "s|ssl_certificate\ .*|ssl_certificate $LE_CERT;|" "$NGINX_CONF_HTTPS"
   # sed -i.bak -E "s|ssl_certificate_key\ .*|ssl_certificate_key $LE_KEY;|" "$NGINX_CONF_HTTPS"

   # service nginx restart
fi

popd &> /dev/null

cat $WEB_SERVER_CONFIG | grep $DOMAIN_NAME

echo "INFO: Done"


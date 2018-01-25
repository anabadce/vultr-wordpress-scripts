#!/bin/bash -e

NGINX_CONF=/etc/nginx/conf.d/wordpress_https.conf

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

DIRNAME=$(dirname "$0")
pushd $DIRNAME

# ======== SWAP ========

if [[ -f /etc/cron.d/swap ]]; then
    echo "INFO: swap already configured"
else
    SWAPKB=524288
    dd if=/dev/zero of=/swapfile bs=1024 count=$SWAPKB
    mkswap /swapfile
    chown root:root /swapfile
    chmod 0600 /swapfile
    swapon /swapfile
    # Enable at boot
    echo "@reboot root /sbin/swapon /swapfile" > /etc/cron.d/swap
    echo "INFO: swap configued in /swapfile"
fi

# ======== Backups ========

chmod +x $DIRNAME/create_backup.sh
if [[ -f /etc/cron.d/create_backup ]]; then
    echo "INFO: backup script already configured"
else
    echo "@daily root $DIRNAME/create_backup.sh" > /etc/cron.d/create_backup
fi

# ======== SSL ============

pushd ~
if [[ -f certbot-auto ]]; then
    echo "INFO: certbot-auto aready installed"
else
    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto
    ./certbot-auto certonly --email admin@$DOMAIN_NAME --webroot -w /var/www/html -d $DOMAIN_NAME -d www.$DOMAIN_NAME

    LE_CERT=/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem
    LE_KEY=/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem

    sed -i.bak -E "s|ssl_certificate\ .*|ssl_certificate $LE_CERT;|" "$NGINX_CONF"
    sed -i.bak -E "s|ssl_certificate_key\ .*|ssl_certificate_key $LE_KEY;|" "$NGINX_CONF"

    service nginx restart
fi

popd

# ======== Password for wp-admin ======
# TODO
# comment auth part in vim /etc/nginx/conf.d/wordpress_https.conf

popd


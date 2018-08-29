#!/bin/bash -e

NGINX_CONF_HTTP=/etc/nginx/conf.d/wordpress_http.conf
NGINX_CONF_HTTPS=/etc/nginx/conf.d/wordpress_https.conf

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

if [[ -z $1 ]]; then
    echo "Usage: $(basename "$0") DOMAIN_NAME"
    exit 1
else
    DOMAIN_NAME=$1
    DOMAIN_NO_WWW=$(echo $DOMAIN_NAME | sed -E 's/www\.(.*)/\1/')
fi

DIRNAME=$(dirname "$0")
pushd $DIRNAME

# ======== CRON Function ========

function setup_cron () {
    SCRIPT_NAME=$1
    CRON_REPEAT=$2
    SCRIPT_PATH=$(dirname $(pwd))
    chmod +x $SCRIPT_PATH/${SCRIPT_NAME}.sh
    if [[ -f /etc/cron.d/$SCRIPT_NAME ]]; then
        echo "INFO: cron.d $SCRIPT_NAME script already configured."
    else
        echo "$CRON_REPEAT root $SCRIPT_PATH/${SCRIPT_NAME}.sh" > /etc/cron.d/1-$SCRIPT_NAME
        echo "INFO: cron.d script to run $CRON_REPEAT $SCRIPT_PATH/${SCRIPT_NAME}.sh"
    fi
}

# ======== SWAP ========

if [[ -f /etc/cron.d/1-swap ]]; then
    echo "INFO: swap already configured"
else
    SWAPKB=524288
    dd if=/dev/zero of=/swapfile bs=1024 count=$SWAPKB
    mkswap /swapfile
    chown root:root /swapfile
    chmod 0600 /swapfile
    swapon /swapfile
    # Enable at boot
    echo "@reboot root /sbin/swapon /swapfile" > /etc/cron.d/1-swap
    echo "INFO: swap configued in /swapfile"
fi

# ======== Backups ========

SCRIPT_NAME="create_backup"
CRON_REPEAT="@daily"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ======== wordpress update ========

SCRIPT_NAME="wordpress-cli-update"
CRON_REPEAT="@weekly"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ======== server update ========

SCRIPT_NAME="server-update"
CRON_REPEAT="@weekly"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ======== certbot update ========

SCRIPT_NAME="certbot-update"
CRON_REPEAT="@weekly"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ========= Nginx ===========

/bin/cp -f ./nginx/wordpress_http.conf $NGINX_CONF_HTTP
/bin/cp -f ./nginx/wordpress_https.conf $NGINX_CONF_HTTPS
sed -i.bak "s/DOMAIN_NAME/$DOMAIN_NAME/" $NGINX_CONF_HTTP

# ======== SSL ============

pushd ~ &> /dev/null
if [[ -f certbot-auto ]]; then
    echo "INFO: certbot-auto aready installed"
else
    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto
    if [[ "$DOMAIN_NAME" = "$DOMAIN_NAME_NO_WWW" ]]; then
        ./certbot-auto certonly --email admin@$DOMAIN_NAME_NO_WWW --webroot -w /var/www/html -d $DOMAIN_NAME
    else
        ./certbot-auto certonly --email admin@$DOMAIN_NAME_NO_WWW --webroot -w /var/www/html -d $DOMAIN_NAME_NO_WWW -d $DOMAIN_NAME
    fi
fi

LE_CERT=/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem
LE_KEY=/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem

sed -i.bak -E "s|ssl_certificate\ .*|ssl_certificate $LE_CERT;|" "$NGINX_CONF_HTTPS"
sed -i.bak -E "s|ssl_certificate_key\ .*|ssl_certificate_key $LE_KEY;|" "$NGINX_CONF_HTTPS"

service nginx restart

popd &> /dev/null

# ========= PostFix =========

echo "INFO: Disabling IPv6 in Postfix"
sed -i.bak -E "s/inet_protocols\ .*/inet_protocols = ipv4/" /etc/postfix/main.cf
echo "INFO: Setting up Postfix domain"
sed -i.bak "s/#myorigin = \$mydomain/myorigin = $DOMAIN_EMAIL_NO_WWW/" /etc/postfix/main.cf
service postfix restart

# ========= Log Folder =====
mkdir -p /opt/logs
chmod 777 /opt/logs

popd



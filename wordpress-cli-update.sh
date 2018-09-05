#!/bin/bash -e

LOG_FILE=/opt/logs/wordpress-cli-update.sh.txt
WP_CLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

mkdir -p /opt/logs
echo $(date) > $LOG_FILE

# Defining known defaults
if [[ -d /opt/bitnami/apps/wordpress/htdocs/wp-content/upgrade ]]; then
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

DIRNAME=$(dirname "$0")
pushd $DIRNAME &> /dev/null

# Relaxing permissions
echo "INFO: Changing file ownership to $WEB_USER"
chown -R $WEB_USER:$WEB_USER $SITE_PATH

# Wordpress CLI check
WP_PATH=$(which wp)
if [[ -z $WP_PATH ]]; then
    echo "WARN: wp command not found, installing..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    php wp-cli.phar --info
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    WP_PATH=/usr/local/bin/wp
else
    echo "INFO: Found wordpress CLI"
fi

# Updating Wordpress

echo "$(date) : Updating wordpress" > $LOG_FILE

pushd $SITE_PATH > $LOG_FILE

# Upgrade using WP_CLI
sudo -H -u $WEB_USER bash -c "$WP_PATH core update" &>> $LOG_FILE
sudo -H -u $WEB_USER bash -c "$WP_PATH plugin update --all" &>> $LOG_FILE
sudo -H -u $WEB_USER bash -c "$WP_PATH theme update --all" &>> $LOG_FILE

# Hardening permissions
echo "INFO: Hardening permissions using ownership $LOCAL_USER and $WEB_USER"
chown -R $LOCAL_USER:$LOCAL_USER .
find . -type d -exec chmod 775 {} \;
find . -type f -exec chmod 664 {} \;

chown -R $LOCAL_USER:$WEB_USER wp-content/uploads
find wp-content/uploads -type d -exec chmod 775 {} \;
find wp-content/uploads -type f -exec chmod 664 {} \;

chown -R $LOCAL_USER:$WEB_USER wp-config.php
chmod 640 wp-config.php

popd &> /dev/null

# Done
echo "INFO: Done, check logs in $LOG_FILE"

popd &> /dev/null



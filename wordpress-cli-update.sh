#!/bin/bash -e

WEB_USER=nginx
WP_CLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
LOG_FILE=/tmp/wordpress-cli-update.sh.txt

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

if [[ -z $1 ]]; then
    echo "Usage: $(basename "$0") SITE_PATH"
    echo "Example: $(basename "$0") /var/www/html"
    echo
    echo "Running using default Wordpress location in /var/www/html..."
    SITE_PATH=/var/www/html
else
    SITE_PATH=$1
fi

DIRNAME=$(dirname "$0")
pushd $DIRNAME

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

pushd $SITE_PATH
sudo -H -u $WEB_USER bash -c "$WP_PATH core update" &>> $LOG_FILE
sudo -H -u $WEB_USER bash -c "$WP_PATH plugin update --all" &>> $LOG_FILE
sudo -H -u $WEB_USER bash -c "$WP_PATH theme update --all" &>> $LOG_FILE
popd

echo "INFO: Done, check logs in $LOG_FILE"
popd


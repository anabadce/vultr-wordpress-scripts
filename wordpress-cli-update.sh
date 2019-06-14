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
if [[ -d /opt/bitnami/apps/wordpress/htdocs ]]; then
    WEB_USER=daemon
    LOCAL_USER=bitnami
    SITE_PATH=/opt/bitnami/apps/wordpress/htdocs
    PATH="/home/bitnami/bin:/home/bitnami/.local/bin:/opt/bitnami/apps/wordpress/bin:/opt/bitnami/varnish/bin:/opt/bitnami/sqlite/bin:/opt/bitnami/php/bin:/opt/bitnami/mysql/bin:/opt/bitnami/apache2/bin:/opt/bitnami/common/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
else
    WEB_USER=nginx
    LOCAL_USER=root
    SITE_PATH=/var/www/html
    PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
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
echo "INFO: calling relax-permissions.sh"
./relax-permissions.sh

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

popd &> /dev/null

# Hardening permissions
echo "INFO: Hardening permissions..."
./harden-permissions.sh

# Done
echo "INFO: Done, check logs in $LOG_FILE"

popd &> /dev/null

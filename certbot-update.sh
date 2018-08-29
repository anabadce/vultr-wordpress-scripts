#!/bin/bash -e

LOG_FILE=/opt/logs/certbot-update.txt
CERTBOT_BITNAMI=/home/bitnami/certbot-auto
CERTBOT_VULT=/root/certbot-auto
APACHE_BIN=/opt/bitnami/apache2/bin

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

mkdir -p $(dirname $LOG_FILE) 

echo $(date) > $LOG_FILE

if [[ -d $APACHE_BIN ]]; then
    echo "INFO: Found bitnami Apache2"
    $CERTBOT_BITNAMI renew -n &>> $LOG_FILE
    
    echo "INFO: reloading bitnami Apache2" 
    pushd $APACHE_BIN 
    ./apachectl -k graceful &>> $LOG_FILE
    popd
else
    echo "INFO: Assuming Vulr Nginx"
    $CERTBOT_VULT renew -n &>> $LOG_FILE

    echo "INFO: reloading Nginx"
    /sbin/service nginx reload &>> $LOG_FILE
fi

echo "INFO: Done, see logs in $LOG_FILE"


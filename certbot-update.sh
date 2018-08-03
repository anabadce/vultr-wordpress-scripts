#!/bin/bash -e

LOG_FILE=/opt/logs/certbot-update.txt

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

pushd ~ &> /dev/null

mkdir -p $(dirname $LOG_FILE) 

echo $(date) > $LOG_FILE

./certbot-auto renew -n &>> $LOG_FILE

if [[ -d /opt/bitnami/apache2 ]]; then
    echo "INFO: reloading bitnami Apache2" 
    apachectl -k graceful $>> $LOG_FILE
else
    echo "INFO: reloading Nginx"
    /sbin/service nginx reload &>> $LOG_FILE
fi


popd &> /dev/null

echo "INFO: Done, see logs in $LOG_FILE"

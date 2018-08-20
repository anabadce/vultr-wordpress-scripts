#!/bin/bash -e

LOG_FILE=/opt/logs/server-update.sh.txt

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

mkdir -p /opt/logs

echo $(date) > $LOG_FILE

PATH=/opt/bitnami/apps/wordpress/bin:/opt/bitnami/varnish/bin:/opt/bitnami/sqlite/bin:/opt/bitnami/php/bin:/opt/bitnami/mysql/bin:/opt/bitnami/apache2/bin:/opt/bitnami/common/bin:/opt/bitnami/apps/wordpress/bin:/opt/bitnami/varnish/bin:/opt/bitnami/sqlite/bin:/opt/bitnami/php/bin:/opt/bitnami/mysql/bin:/opt/bitnami/apache2/bin:/opt/bitnami/common/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

if grep --quiet Ubuntu /etc/issue; then

    apt-get update &>> $LOG_FILE
    apt-get upgrade -y &>> $LOG_FILE

else

    yum update -y &>> $LOG_FILE

fi

echo "INFO: Done, see logs in $LOG_FILE"

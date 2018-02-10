#!/bin/bash -e

LOG_FILE=/tmp/$0.txt

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

echo $(date) > $LOG_FILE

/root/certbot-auto renew -n &>> $LOG_FILE

echo "INFO: Done, see logs in /tmp/$0.txt"

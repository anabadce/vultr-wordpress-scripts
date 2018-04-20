#!/bin/bash -e

LOG_FILE=/opt/logs/server-update.sh.txt

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

echo $(date) > $LOG_FILE

yum update -y &>> $LOG_FILE

echo "INFO: Done, see logs in $LOG_FILE"

#!/bin/bash -e

LOG_FILE=/opt/logs/server-update.sh.txt

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

echo $(date) > $LOG_FILE

if grep --quiet Ubuntu /etc/issue; then

    apt-get update &>> $LOG_FILE
    apt-get upgrade -y &>> $LOG_FILE

else

    yum update -y &>> $LOG_FILE

fi

echo "INFO: Done, see logs in $LOG_FILE"

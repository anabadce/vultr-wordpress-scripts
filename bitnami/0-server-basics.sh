#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

if [[ -z $1 ]]; then
    echo "Usage: $(basename "$0") NEW_HOSTNAME"
    exit 1
else
    NEW_HOSTNAME=$1
fi

hostnamectl set-hostname $NEW_HOSTNAME

if grep $NEW_HOSTNAME /etc/hosts; then
    echo "INFO: /etc/hosts already updated"
else
    echo "INFO: Adding new host to /etc/hosts"
    echo "127.0.0.1 $NEW_HOSTNAME" >> /etc/hosts
fi

echo "INFO: Done"


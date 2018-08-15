#!/bin/bash -e

# Enables local server to send emails

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# ========= PostFix =========

debconf-set-selections <<< "postfix postfix/mailname string $(hostname)"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y postfix

echo "INFO: Disabling IPv6 in Postfix"
sed -i.bak -E "s/inet_protocols\ .*/inet_protocols = ipv4/" /etc/postfix/main.cf

echo "INFO: Listening localhost only in Postfix"
sed -i.bak -E "s/inet_interfaces\ .*/inet_interfaces = localhost/" /etc/postfix/main.cf

# Check
cat /etc/postfix/main.cf | grep -E "(interfaces|protocols)"

service postfix restart

echo "INFO: Done"


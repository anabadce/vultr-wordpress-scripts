#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

yum install fail2ban -y

# ssh
echo "[sshd]" > /etc/fail2ban/jail.d/ssh.local
echo "enabled = true" >> /etc/fail2ban/jail.d/ssh.local

service fail2ban restart > /dev/null
service fail2ban status

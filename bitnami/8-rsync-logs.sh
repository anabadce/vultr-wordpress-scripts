#!/bin/bash -e

# Rsync to server that can process logs

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

LOGSERVER=ks4.abadcer.com
LOGSERVER_USER=logsync
CRON_FILE=/etc/cron.d/8-rsync-logs
APACHE_CONFIG=/opt/bitnami/apache2/conf/httpd.conf
APACHE_LOGS=/opt/bitnami/apache2/logs/

# Make Apache2 logs more verbose

sed -i.bak -E "s|\ +CustomLog \"logs/access_log\".*|  CustomLog \"logs/access_log\" combined|" "$APACHE_CONFIG"
/opt/bitnami/ctlscript.sh restart apache

# Generate SSH key pair
if [[ -f /root/.ssh/id_rsa.pub ]]; then
    echo "INFO: Found KEY in /root"
else
    ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
fi

# Trust signatures
ssh-keyscan $LOGSERVER >> /root/.ssh/known_hosts
sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts

# Add cron
echo "*/5 * * * * root /usr/bin/rsync $APACHE_LOGS $LOGSERVER_USER@$LOGSERVER:/\$(hostname) -vr" > $CRON_FILE

# Report done
echo "INFO: Key to allow in log server $LOGSERVER user $LOGSERVER_USER:"
cat "/root/.ssh/id_rsa.pub"
echo "INFO: Cron job:"
cat $CRON_FILE
echo "INFO: Done"


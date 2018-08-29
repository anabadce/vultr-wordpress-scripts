#!/bin/bash -e

# Rsync to server that can process logs

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

LOGSERVER=ks4.abadcer.com
LOGSERVER_USER=logsync
CRON_LOGS=/etc/cron.d/8-rsync-logs
CRON_BACKUPS=/etc/cron.d/8-rsync-backups
LOGS_PATH=/opt/bitnami/apache2/logs/
BACKUPS_PATH=/root/backups
APACHE_CONFIG=/opt/bitnami/apache2/conf/httpd.conf

# Make Apache2 logs more verbose

if [[ -f $APACHE_CONFIG ]]; then
    sed -i.bak -E "s|\ +CustomLog \"logs/access_log\".*|  CustomLog \"logs/access_log\" combined|" "$APACHE_CONFIG"
    /opt/bitnami/ctlscript.sh restart apache
fi

# Generate SSH key pair
if [[ -f /root/.ssh/id_rsa.pub ]]; then
    echo "INFO: Found KEY in /root"
else
    ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
fi

# Trust signatures
ssh-keyscan $LOGSERVER >> /root/.ssh/known_hosts
sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts

# Add cron for logs
echo "*/5 * * * * root /usr/bin/rsync $LOGS_PATH --include '*log' --exclude '*' $LOGSERVER_USER@$LOGSERVER:/\$(hostname) -vr > /dev/null" > $CRON_LOGS

# Add cron for backups
echo "@daily root /usr/bin/rsync $BACKUPS_PATH $LOGSERVER_USER@$LOGSERVER:/\$(hostname)/backups -vr --delete > /dev/null" > $CRON_BACKUPS

# Report done
echo "INFO: Key to allow in log server $LOGSERVER user $LOGSERVER_USER:"
cat "/root/.ssh/id_rsa.pub"
echo "INFO: Cron job:"
cat $CRON_LOGS $CRON_BACKUPS
echo "INFO: Done"


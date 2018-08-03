#!/bin/bash -e

BACKUP_PATH='/root/backups'
TIMESTAMP=$(date +%F-%a-%H.%M)
USER='root'

if [[ -d /opt/bitnami/mysql/bin ]];then
    MYSQLDUMP='/opt/bitnami/mysql/bin/mysqldump'
    MYSQL='/opt/bitnami/mysql/bin/mysql'
    WEB_ROOT='/opt/bitnami/apps/wordpress/'
    MYSQL_PASS="-p$(cat /home/bitnami/bitnami_application_password)"
else
    MYSQLDUMP='/usr/bin/mysqldump'
    MYSQL='/usr/bin/mysql'
    WEB_ROOT='/var/www'
fi

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Preparing folder
if [[ -d $BACKUP_PATH ]]; then
  echo "INFO: Folder $BACKUP_PATH already exists"
else
  echo "INFO: Creating folder $BACKUP_PATH"
  mkdir -p "$BACKUP_PATH"
fi

# Compressing files

/bin/tar czf "$BACKUP_PATH/$TIMESTAMP-UTC-var-www.tar.gz" "$WEB_ROOT"

# Backing up DB

DATABASES=$($MYSQL -u$USER $MYSQL_PASS --execute="show databases;" | grep -E "wp|bitnami")

for DB in $DATABASES;
do
  echo mysqldumping $DB
  $MYSQLDUMP --hex-blob -u$USER $MYSQL_PASS $DB | gzip > "$BACKUP_PATH/$TIMESTAMP-UTC-$DB.sql.gz"
done

# Clean old files

find $BACKUP_PATH -maxdepth 1 -mtime +7 -type f -delete


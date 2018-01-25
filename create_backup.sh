#!/bin/bash -e

BACKUP_PATH=/root/backups
TIMESTAMP=$(date +%F-%a-%H.%M)
USER='root'
MYSQLDUMP='/usr/bin/mysqldump'
MYSQL='/usr/bin/mysql'

# Preparing folder

mkdir -p $BACKUP_PATH

# Compressing files

/bin/tar czf "$BACKUP_PATH/$TIMESTAMP-UTC-var-www.tar.gz" /var/www

# Backing up DB

DATABASES=$($MYSQL -u$USER --execute="show databases;" | grep "wp")

for DB in $DATABASES;
do
  echo mysqldumping $DB
  $MYSQLDUMP --hex-blob -u$USER $DB | gzip > $BACKUP_PATH/$TIMESTAMP-UTC-$DB.sql.gz
done

# Clean old files

find $BACKUP_PATH -mtime +7 -type f -delete


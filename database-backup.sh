#!/bin/bash
set -o errexit
set -o pipefail

# Required Variables
TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`


MARIADB_USER=root
MARIADB_PASSWORD=
MARIADB_BACKUPCMD=/usr/bin/mariabackup
BACKUP_BASE=/root/backup
BACKUP_NAME=mariadb
BACKUP_DIR=$BACKUP_BASE/$BACKUP_NAME
S3_BUCKET=
S3_FOLDER=

# Run Required Checks

if [ "$EUID" != "0" ]; then
   echo "$0 must be run as root" >&2
   exit 1
fi

# Do backup
echo "Starting backup"
echo "Backing up to $BACKUP_FOLDER"
$MARIADB_BACKUPCMD --backup --user=$MARIADB_USER --password=$MARIADB_PASSWORD --target-dir=$BACKUP_DIR  

# Prepare backup
$MARIADB_BACKUPCMD --prepare --user=$MARIADB_USER --password=$MARIADB_PASSWORD --target-dir=$BACKUP_DIR 

# Compress backup
cd $BACKUP_BASE
tar -zcvf $BACKUP_NAME.tar.gz $BACKUP_NAME 

# Upload to s3
s3cmd put $BACKUP_BASE/$BACKUP_NAME.tar.gz s3://$S3_BUCKET/$S3_FOLDER/$BACKUP_NAME-$TIMESTAMP.tar.gz

# Prep for next backup
rm -rf $BACKUP_DIR
rm $BACKUP_BASE/$BACKUP_NAME.tar.gz
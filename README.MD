# mariabackup-s3

To use setup s3cmd, fill in the variables in database-backup.sh, and then schedule with cron.

You can optionally use the lifecycle_policy file that is included to automatically expire backups in S3.
 >s3cmd setlifecycle lifecycle_policy.xml s3://yourbucket
 
 This will expire every file in the bucket so use with care.
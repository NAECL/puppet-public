#!/bin/bash

# This script performs backups of the wordpress database, and directory under /var/www.
# To restore use the restore_wordpress_backup.sh script.
# Since the tarfiles are incremental backups, if you want to install them manually, untar all the backups related
# to a particular snar file, in order oldest first, using the command - tar zx --listed-incremental=/dev/null -f <file>
#
# E.g.
#
# tar zx --listed-incremental=/dev/null -f tar_file1
# tar zx --listed-incremental=/dev/null -f tar_file2
# tar zx --listed-incremental=/dev/null -f tar_file3
# tar zx --listed-incremental=/dev/null -f tar_file4
# tar zx --listed-incremental=/dev/null -f tar_file5
# tar zx --listed-incremental=/dev/null -f tar_file6
# tar zx --listed-incremental=/dev/null -f tar_file7
#

export JAVA_HOME=/usr/lib/jvm/jre
export EC2_HOME=/opt/aws/apitools/ec2
export PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/root/bin:/usr/local/bin
export HOME=/root

. /etc/build_custom_config

if [ "${BACKUP_BUCKET}" = "ignore" ]
then
    echo "Info: BACKUP_BUCKET Set to ignore"
    exit 0
fi

if [ "${ENVIRONMENT}" = "" ]
then
    echo "Error: ENVIRONMENT Not defined!"
    exit 1
fi

if [ $# -ne 2 ]
then
	echo "Error: Needs Site and DB Name as an argument"
	exit 1
else
	site=$1
	dbName=$2
fi

weekStamp=$(date '+%Y%V')
dayStamp=$(date '+%Y%V%u')
region=eu-west-2
backupDir=/var/lib/siteBackups/${site}
mkdir -p ${backupDir}
dbBackup=${dbName}.${dayStamp}.sql.gz
siteBackup=${site}.${dayStamp}.tar.gz
incFile=${backupDir}/${site}.${weekStamp}.snar
stateFile=${backupDir}/${site}.state

date '+%Y%m%d %H:%M:%S Backup Running' > ${stateFile}

date "+%Y%m%d %H:%M:%S Starting Site Backup to s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${siteBackup}"
tar -zc --listed-incremental=${incFile} -C /var/www -f - ${site} | aws --region ${region} s3 cp - s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${siteBackup}
if [ $? -ne 0 ]
then
    date '+%Y%m%d %H:%M:%S Site Backup Failed'
    exit 1
fi

date "+%Y%m%d %H:%M:%S Starting DB Backup to s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${dbBackup}"
mysqldump ${dbName} | gzip -c | aws --region ${region} s3 cp - s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${dbBackup}
if [ $? -ne 0 ]
then
    date '+%Y%m%d %H:%M:%S DB Backup Failed'
    exit 1
fi

date '+%Y%m%d %H:%M:%S Backup OK' > ${stateFile}

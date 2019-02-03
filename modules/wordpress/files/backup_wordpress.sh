#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/jre
export EC2_HOME=/opt/aws/apitools/ec2
export PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/root/bin
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

# Sync the state file before has effect of creating the directory if needed.
date '+%Y%m%d %H:%M:%S Starting First AWS Sync'
aws --region ${region} s3 sync ${backupDir} s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/ >/dev/null 2>&1
if [ $? -ne 0 ]
then
    date '+%Y%m%d %H:%M:%S Sync to AWS Failed'
    exit 1
fi

cd /var/www
date "+%Y%m%d %H:%M:%S Starting Site Backup to s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${siteBackup}"
tar -zc --listed-incremental=${incFile} -f - ${site} | aws --region ${region} s3 cp - s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${siteBackup}
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

date '+%Y%m%d %H:%M:%S Starting Final AWS Sync'
aws --region ${region} s3 sync ${backupDir} s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/ >/dev/null 2>&1
if [ $? -ne 0 ]
then
    date '+%Y%m%d %H:%M:%S Transfer to AWS Failed'
    exit 1
else
    date '+%Y%m%d %H:%M:%S Transfer to AWS OK - Finished Backups'
fi

date '+%Y%m%d %H:%M:%S Backup OK' > ${stateFile}
echo -e "\n\n"

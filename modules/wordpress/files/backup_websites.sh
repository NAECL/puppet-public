#!/bin/bash
logfile=/var/log/backup_wordpress.log.$(date '+%Y%m')
exec >> ${logfile}
exec 2>&1

lockdir=/usr/local/puppetbuild/locks

for lockfile in ${lockdir}/*.dbcreated.lck
do
    read site db < ${lockfile}
    date "+%Y%m%d %H:%M:%S Backing up ${site} ${db}"
    /usr/local/bin/backup_wordpress.sh ${site} ${db}
done


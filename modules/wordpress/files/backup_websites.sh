#!/bin/bash
logfile=/var/log/backup_wordpress.log.$(date '+%Y%m')
exec >> ${logfile}
exec 2>&1

builddir=/usr/local/buildfiles

for buildfile in ${builddir}/backup_*_website
do
    if [ ${buildfile} != ${builddir}'/backup_*_website' ]
    then
        read site db < ${buildfile}
        date "+%Y%m%d %H:%M:%S Backing up ${site} ${db}"
        /usr/local/bin/backup_wordpress.sh ${site} ${db}
    fi
done


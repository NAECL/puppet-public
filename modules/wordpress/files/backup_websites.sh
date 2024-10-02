#!/bin/bash
logfile=/var/log/backup_wordpress.log.$(date '+%Y%m')
exec >> ${logfile}
exec 2>&1

builddir=/usr/local/buildfiles
backupdir=/var/lib/siteBackups
failures=0

for buildfile in ${builddir}/backup_*_website
do
    if [ ${buildfile} != ${builddir}'/backup_*_website' ]
    then
        read site db < ${buildfile}
        echo -e "\n\n"
        date "+%Y%m%d %H:%M:%S Backing Up ${site} ${db}"
        /usr/local/bin/backup_wordpress.sh ${site} ${db}
        if [ $? -ne 0 ]
        then
            failures=1
            date "+%Y%m%d %H:%M:%S Failed To Back Up ${site} ${db}"
        else
            date "+%Y%m%d %H:%M:%S Backed Up ${site} ${db}"
        fi
    fi
done

if [ ${failures} -eq 0 ]
then
    date '+%Y%m%d %H:%M:%S Wordpress Backups Succeeded' > ${backupdir}/Wordpress_Backup_Result
fi

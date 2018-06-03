#!/bin/bash
logfile=/var/log/watermark_websites.log.$(date '+%Y%m')
exec >> ${logfile}
exec 2>&1

lockdir=/usr/local/puppetbuild/locks

for lockfile in ${lockdir}/*.dbcreated.lck
do
	read site db < ${lockfile}
	date "+%Y%m%d %H:%M:%S Watermarking photos in ${site}"
    /usr/local/bin/watermarkSite.sh ${site}
done


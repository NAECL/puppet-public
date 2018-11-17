#!/bin/bash
#
# To get a cert run 
#
# certbot --apache certonly
#
# Ensure that you only pick one cert at a time

logfile=/var/log/certbot_renew.log.$(date '+%Y%m')

date >> ${logfile} 2>&1
/usr/bin/env certbot renew >> ${logfile} 2>&1
echo >> ${logfile} 2>&1

#!/bin/bash

logfile=/var/log/certbot_renew.log.$(date '+%Y%m')

date >> ${logfile} 2>&1
/bin/certbot renew >> ${logfile} 2>&1
echo >> ${logfile} 2>&1

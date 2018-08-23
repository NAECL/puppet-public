#!/bin/bash

export PATH=/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin
logfile=/var/log/package_update.log.$(date '+%m')
reboot=false

. /etc/build_custom_config

date >> ${logfile}
if [ "${UPDATE_METHOD}" = "yum" ]
then
    yum check-update >> ${logfile} 2>&1
    if [ $? -ne 0 ]
    then
        yum update -y >> ${logfile} 2>&1
        if [ "${REBOOT_AFTER_UPDATE}" == "true" ]
        then
            REBOOT=true
        else
            echo "Warning: NOT Rebooting after applying patches" >> ${logfile} 2>&1
        fi
    fi
else
    /usr/bin/apt-get update >> ${logfile} 2>&1
    /usr/bin/apt-get upgrade -y >> ${logfile} 2>&1
    # need some logic to test if reboot is required, for now reboot always
    if [ "${REBOOT_AFTER_UPDATE}" == "true" ]
    then
        REBOOT=true
    fi
fi

if [ "${REBOOT}" == "true" ]
then
    echo "Info: Rebooting after applying patches" >> ${logfile} 2>&1
    date >> ${logfile}
    echo -e "\n\n" >> ${logfile}
    init 6
else
    date >> ${logfile}
    echo -e "\n\n" >> ${logfile}
fi

#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

id=$(id -u)

if [ "${id}" -ne 0 ]
then
    logger -t "$0" "Error: This script must be run as root"
    exit 1
fi

if [ $# -ne 1 ]
then
    logger -t "$0" "Error: This script needs a service name as an argument"
    exit 1
fi

service=${1}

logger -t "$0" "Info: Checking ${service} service is running"

service ${service} status >/dev/null 2>&1
if [ $? -ne 0 ]
then
    logger -t "$0" "Warning: ${service} not running, restarting"
    service ${service} stop >/dev/null 2>&1
    service ${service} start >/dev/null 2>&1
    sleep 10
    service ${service} status >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        logger -t "$0" "Error: ${service} restart failed"
        exit 1
    else
        logger -t "$0" "Info: ${service} restart succeeded"
    fi
fi


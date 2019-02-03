#!/bin/bash

# Quick check if a file exists and report warning or critical with age of file and any contents of first line
# $0 /path/file w
#

utils=/usr/local/nagios/libexec/custom/utils.sh

if [ ! -r ${utils} ]
then
	echo "Unknown: Unable to find config file ${utils}"
	exit 3
else
	. ${utils}
fi


ALERT_LEVEL=${STATE_CRITICAL}
FILENAME=$1
FILECOUNT=$(/bin/ls -l ${FILENAME} 2>/dev/null|/usr/bin/wc -l)

if [ "$FILECOUNT" -gt 0 ]; then

        FILE_AGE=$(/usr/bin/stat -c '%y' ${FILENAME}|/bin/cut -d'.' -f1)
        CONTENT=$(/usr/bin/head -1 ${FILENAME})

        if [ "$2" == "c" -o "$2" == "-c" ]; then
                ALERT_LEVEL=${STATE_CRITICAL}
        elif [ "$2" == "w" -o "$2" == "-w" ]; then
                ALERT_LEVEL=${STATE_WARNING}
        elif [ "$2" == "n" -o "$2" == "-n" ]; then
                ALERT_LEVEL=${STATE_OK}
        else
                ALERT_LEVEL=${STATE_CRITICAL}
        fi

        /bin/echo "File found. Report=[${CONTENT}]. Mod=[${FILE_AGE}].|found=1;;;;"
        exit ${ALERT_LEVEL}
else
        /bin/echo "OK: No file found.|found=0;;;;"
        exit ${STATE_OK}
fi

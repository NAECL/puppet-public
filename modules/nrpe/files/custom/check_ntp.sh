#!/bin/bash
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

utils=/usr/local/nagios/libexec/custom/utils.sh

if [ ! -r ${utils} ]
then
	echo "Unknown: Unable to find config file ${utils}"
	exit 3
else
	. ${utils}
fi

WARN_ERRORS=0
UNKNOWN_ERRORS=0

if [ ! -r /etc/ntp.conf ]
then
	echo "Warning: Unable to read from /etc/ntp.conf"
	exit ${STATE_WARNING}
fi

servers=$(awk '/^server/ {print $2}' /etc/ntp.conf)

if [ "${servers}" = "" ]
then
	echo "Warning: No NTP Servers Defined"
	exit ${STATE_WARNING}
fi

for server in ${servers}
do
	echo -e "Checking NTP Server ${server}: \c"
	${pluginDir}/check_ntp_time -H ${server} -w 5 -c 1
	retVal=$?
	if [ ${retVal} -eq ${STATE_CRITICAL} ]
	then
		# We only want warning on NTP, yellow is enough
		WARN_ERRORS=1
	elif [ ${retVal} -eq ${STATE_WARNING} ]
	then
		WARN_ERRORS=1
	elif [ ${retVal} -eq ${STATE_UNKNOWN} ]
	then
		UNKNOWN_ERRORS=1
	fi
done

# Finally check that ntpd is actually running
/sbin/service ntpd status >/dev/null 2>&1
if [ $? -ne 0 ]
then
	WARN_ERRORS=1
fi

if [ ${WARN_ERRORS} -eq 1 ]
then
	/usr/bin/sudo /usr/local/nagios/libexec/sudoScripts/reset_ntpd
	exit ${STATE_WARNING}
fi

if [ ${UNKNOWN_ERRORS} -eq 1 ]
then
	exit ${STATE_UNKNOWN}
fi

exit ${STATE_OK}

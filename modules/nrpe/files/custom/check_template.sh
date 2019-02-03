#!/bin/bash
#
# A template for a nagios check, can be used to base other checks on
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/admintools

utils=/usr/local/nagios/libexec/custom/utils.sh

if [ ! -r ${utils} ]
then
	echo "Unknown: Unable to find config file ${utils}"
	exit 3
else
	. ${utils}
fi

CRIT_ERRORS=0
WARN_ERRORS=0
UNKNOWN_ERRORS=0


# This next bit is overkill, but works well in a loop if checking more than 1 thing
#
echo -e "Checking Something \c"
/path/to/a/check/command
retVal=$?
if [ ${retVal} -eq ${STATE_CRITICAL} ]
then
	CRIT_ERRORS=1
elif [ ${retVal} -eq ${STATE_WARNING} ]
then
	WARN_ERRORS=1
elif [ ${retVal} -eq ${STATE_UNKNOWN} ]
then
	UNKNOWN_ERRORS=1
fi


# Once checks are done, exit with the most important status
#
if [ ${CRIT_ERRORS} -eq 1 ]
then
	exit ${STATE_CRITICAL}
fi

if [ ${WARN_ERRORS} -eq 1 ]
then
	exit ${STATE_WARNING}
fi

if [ ${UNKNOWN_ERRORS} -eq 1 ]
then
	exit ${STATE_UNKNOWN}
fi

exit ${STATE_OK}


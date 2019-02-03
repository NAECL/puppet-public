#!/bin/bash
#
# Place holder for a required check, echo out the input, and exit with a warning

utils=/usr/local/nagios/libexec/custom/utils.sh

if [ ! -r ${utils} ]
then
	echo "Unknown: Unable to find config file ${utils}"
	exit 3
else
	. ${utils}
fi

echo $*
exit ${STATE_WARNING}

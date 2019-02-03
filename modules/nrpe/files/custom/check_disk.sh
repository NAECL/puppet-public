#!/bin/bash
#
# Wrapper for check_disk check, used to add functionality
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

mkdir -p /usr/local/nagios/locks >/dev/null 2>&1

CRIT_ERRORS=0
WARN_ERRORS=0
UNKNOWN_ERRORS=0
w=""
c=""
p=""
W=""
K=""
type=""
partition=""
checkUnchecked=0

# Process Command line args Populate the variables to pass straight to /usr/local/nagios/libexec/check_disk
#

while getopts ":hw:c:p:W:K:U" nextarg  >/dev/null 2>&1
do
        case $nextarg in
                "h")    /usr/local/nagios/libexec/check_disk --help
			exit 0
                        ;;
                "U")    checkUnchecked=1
                        ;;
                "w")    w="-w ${OPTARG}"
			type=disk
                        ;;
                "c")    c="-c ${OPTARG}"
			type=disk
                        ;;
                "p")    p="-p ${OPTARG}"
			partition=${OPTARG}
			partition_lock=$(echo ${partition} | sed 's#/#.#g')
			if [ "${partition_lock}" = "." ]
			then
				partition_lock=".root"
			fi
                        ;;
                "W")    W="-W ${OPTARG}"
			type=inode
                        ;;
                "K")    K="-K ${OPTARG}"
			type=inode
                        ;;
                *)      echo "Error: flag -${OPTARG} not supported or used without an argument"
                        exit 1
                        ;;
        esac
done
shift_ind=$(expr $OPTIND - 1)
shift $shift_ind

if [ ${checkUnchecked} -eq 1 ]
then
	now=$(date '+%s')
	PARTITIONS=$(mount | awk '/^\/dev/ {print $3}')
	for PART in $PARTITIONS
	do
		for type in disk inode
		do
			PARTITION_LOCK=$(echo ${PART} | sed 's#/#.#g')
			if [ "${PARTITION_LOCK}" = "." ]
			then
				PARTITION_LOCK=".root"
			fi
			PARTITION_LOCKFILE=/usr/local/nagios/locks/${type}${PARTITION_LOCK}.lck
			if [ -f ${PARTITION_LOCKFILE} ]
			then
				lockAge=$(stat -c '%Y' ${PARTITION_LOCKFILE})
				age=$(( ${now} - ${lockAge} ))
				if [ ${age} -gt 3600 ]
				then
					echo "Warning ${type} use of ${PART} has not been checked for ${age} seconds"
					WARN_ERRORS=1
				fi
			else
				echo "Warning ${type} use of ${PART} has never been checked"
				WARN_ERRORS=1
			fi
		done
	done

	if [ ${WARN_ERRORS} -eq 1 ]
	then
		exit ${STATE_WARNING}
	else
		echo "Info: All Partitions are being checked OK"
		exit ${STATE_OK}
	fi
fi

if [ "${type}" = "" -o "${partition}" = "" ]
then
	echo "Unknown: Not enough arguments specified"
	exit ${STATE_UNKNOWN}
fi

# Create a lock file for this partition. Allows checking to see if all partitions are monitored"
lockfile=/usr/local/nagios/locks/${type}${partition_lock}.lck
/bin/touch ${lockfile}
if [ $? -ne 0 ]
then
	echo "Unknown: Unable to create lock file ${lockfile} for ${partition}"
	exit ${STATE_UNKNOWN}
fi

# This next bit is overkill, but works well in a loop if checking more than 1 thing
#
/usr/lib64/nagios/plugins/check_disk ${w} ${c} ${W} ${K} ${p}
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


#!/bin/sh
################################################################################
# RCS_Ident_String
# $RCSfile: check_smb_share.sh,v $
# $Revision: 1.1.1.1 $
# $Date: 2013/01/14 14:40:16 $
# Last Changed by $Author: common $
# $State: Exp $
################################################################################

# Check for sharename on SMB with nagios
# Michael Hodges <michael@va.com.au> 2011-03-04
# Modified version of check_smb by Dave Love <fx@gnu.org>

REVISION=0.9
PROGNAME=`/bin/basename $0`

. /usr/local/nagios/libexec/utils.sh

usage () {
    echo "\
Nagios plugin to check for SAMBA Share. Use anonymous login if user name is not supplied. 

Usage:
  $PROGNAME -H <host> -s <sharename>
  $PROGNAME -H <host> -s <sharename> -u <user> -p <password>
  $PROGNAME --help
  $PROGNAME --version
"
}

help () {
    print_revision $PROGNAME $REVISION
    echo; usage; echo; support
}

if [ $# -lt 1 ]; then
    usage
    exit $STATE_UNKNOWN
fi

user="guest"
pasword=""

while test -n "$1"; do
    case "$1" in
	--help | -h)
	    help
	    exit $STATE_OK;;
	--version | -V)
	    print_revision $PROGNAME $REVISION
	    exit $STATE_OK;;
	-H)
	    shift
	    host="$1";;
	-s)
	    shift
	    share="$1";;
	-u)
	    shift
	    user="$1";;
	-p)
	    shift
	    password="$1";;
	*)
	    usage; exit $STATE_UNKNOWN;;
    esac
shift
done

stdout=$(smbclient -U"$user"%"$password" -N -L "$host" 2>&1)
sharetest=$(echo "$stdout" | grep "$share" | awk '{print $1}')

if [ "$sharetest" = "$share" ]; then
    echo "OK SMB Sharename: `echo "$stdout" | grep "$share" |head -n 1`"
    exit $STATE_OK
else
    err=`echo "$stdout" | head -n 1`
    echo "CRITICAL SMB Sharename: "$share" "$err""
    exit $STATE_CRITICAL
fi


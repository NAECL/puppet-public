#!/bin/bash -u

. /etc/build_custom_config
site=""
list=0
verbose=0
wwwDir=/var/www
region=eu-west-2
builddir=/usr/local/buildfiles
weekStamp=$(date '+%Y%V')
progname=$(basename $0)
USAGE="
${progname}: [-h|-H] [-l] [-D] [-W] [-d <datestamp>] -s <site>

    -d  Date to restore from (If not present, uses latest date in format %Y%V (YearWeek, E.g. 201904))

    -e  Environment (Overrides the default of ${ENVIRONMENT})

    -h  Show this usage

    -H  Show extended usage

    -l  List backups

    -v  Verbose Mode

    -s  Sitename of site to restore (reqd)

    -D  Only Restore Database

    -W  Only Restore www directories
"

EXTENDED_USAGE="
This is a script that restores a wordpress backup to a new site.
It uses settings from various files to find the details it needs for a restore. These files/settings are:

/etc/build_custom_config ENVIRONMENT, BACKUP_BUCKET

${builddir}/backup_{sitename}_website contains site name and database name

The backups are daily incremental backups over the course of a week. They have the name format:

    {site}.YYYYWWD.tar.gz
    {db_name}.YYYYWWD.sql.gz

The string YYYYWWD is given by using the following format for the date command %Y%V%u

The command used to copy a file from AWS is:

    aws --region ${region} s3 cp s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/{site}/{file}

This script performs restores of the wordpress database, and directory under /var/www.
Since the tarfiles are incremental backups, if you want to install them manually, untar all the backups related
to a particular snar file, in order oldest first, using the command - tar zx --listed-incremental=/dev/null -f <file>

E.g.

tar zx --listed-incremental=/dev/null -f tar_file1 -C /var/www
tar zx --listed-incremental=/dev/null -f tar_file2 -C /var/www
tar zx --listed-incremental=/dev/null -f tar_file3 -C /var/www
tar zx --listed-incremental=/dev/null -f tar_file4 -C /var/www
tar zx --listed-incremental=/dev/null -f tar_file5 -C /var/www
tar zx --listed-incremental=/dev/null -f tar_file6 -C /var/www
tar zx --listed-incremental=/dev/null -f tar_file7 -C /var/www

"

info_msg () {
    if [ ${verbose} -eq 1 ]
    then
        echo -e "Info: $1"
    fi
}

dbrestore=1
wwwrestore=1
while getopts ":d:e:Hhls:vDW" nextarg  >/dev/null 2>&1
do
    case $nextarg in
        v)      verbose=1
                ;;
        l)      list=1
                ;;
        d)      weekStamp=${OPTARG}
                ;;
        e)      ENVIRONMENT=${OPTARG}
                ;;
        h)      echo -e "${USAGE}"
                exit 0
                ;;
        H)      echo -e "${USAGE}${EXTENDED_USAGE}"
                exit 0
                ;;
        s)      site=${OPTARG}
                ;;
        D)      wwwrestore=0
                ;;
        W)      dbrestore=0
                ;;
        *)      echo -e "${USAGE}\nError: flag -${OPTARG} not supported or used without an argument"
                exit 1
                ;;
    esac
done
shift_ind=$(expr $OPTIND - 1)
shift $shift_ind

if [ "${site}" = "" ]
then
    echo -e "${USAGE}\n\nError: No Site Specified\n"
    exit 1
fi

# Set the variables we can now the site is known
dbName=$(awk '{print $2}' ${builddir}/backup_${site}_website)
listing=$(aws --region ${region} s3 ls s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/)

if [ ${list} -eq 1 ]
then
    echo -e "${listing}"
    exit 0
fi

backup_nos=$(echo -e "${listing}" |awk '{print $4}' |grep -E "${site}.${weekStamp}..tar.gz" |sed -e 's/^'${site}.${weekStamp}'//' -e 's/.tar.gz$//' |sort -n)
# Set the required db to the one matching the last backup
backup_no=$(echo ${backup_nos} | cut -d " " -f 4)
dbBackup=${dbName}.${weekStamp}${backup_no}.sql

if [ ${wwwrestore} -eq 1 ]
then
    info_msg "Restoring Website ${site} to ${wwwDir}/${site}"
    # First restore the tar backup. after checking that there is a backup to copy over the top of.
    if [ ! -d "${wwwDir}/${site}" ]
    then
        echo "Error: No existing website ${wwwDir}/${site} to restore to. Please create a blank website"
        exit 1
    fi
    if [ -d "${wwwDir}/${site}.sav" ]
    then
        echo "Error: There is an existing backup website ${wwwDir}/${site}.sav, please restore this to its original place"
        exit 1
    fi
    mv ${wwwDir}/${site} ${wwwDir}/${site}.sav

    for backup_no in ${backup_nos}
    do
        siteBackup=${site}.${weekStamp}${backup_no}.tar.gz
        info_msg "Restoring Backup File ${siteBackup}"
        aws --region ${region} s3 cp s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${siteBackup} - | tar zxf - -C ${wwwDir}
        if [ $? -ne 0 ]
        then
            echo "Error: Unable to extract ${siteBackup} from S3 backup"
            exit 1
        fi
    done

    cp ${wwwDir}/${site}.sav/wp-config.php ${wwwDir}/${site}
    if [ $? -ne 0 ]
    then
        echo "Error: Unable to copy ${wwwDir}/${site}.sav/wp-config.php"
        exit 1
    fi
fi

if [ ${dbrestore} -eq 1 ]
then
    # Now restore the database
    info_msg "Restoring Database ${dbName}"
    aws --region ${region} s3 cp s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${dbBackup}.gz /tmp >/dev/null
    if [ $? -ne 0 ]
    then
        echo -e "Error: unable to retrieve ${dbBackup}.gz from S3 to ${dbBackup}.gz"
        exit 1
    fi

    dbBackup="/tmp/${dbBackup}"
    gzip -d ${dbBackup}.gz
    if [ $? -ne 0 ]
    then
        echo -e "Error: unable to unzip ${dbBackup}.gz"
        exit 1
    fi

    echo -e "show databases;\ndrop database ${dbName};\ncreate database ${dbName};\nuse ${dbName};\nsource ${dbBackup};" | mysql >/dev/null
    if [ $? -ne 0 ]
    then
        echo "Error: Unable to restore database backup ${dbBackup}"
        rm ${dbBackup}
        exit 1
    fi
    rm ${dbBackup}
fi

info_msg "Wordpress Successfully Restored ${site}"
info_msg "Once you have checked you may want to remove the directory ${wwwDir}/${site}.sav"

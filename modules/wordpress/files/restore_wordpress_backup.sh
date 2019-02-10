#!/bin/bash -u

. /etc/build_custom_config
site=""
list=0
verbose=0
wwwDir=/var/www
region=eu-west-2
builddir=/usr/local/buildfiles
dayStamp=$(date '+%Y%V%u')
progname=$(basename $0)
USAGE="
${progname}: [-h|-H] [-l] [-d <datestamp>] -s <site>

    -d  Date to restore from (If not present, uses latest date in format %Y%V%u)

    -e  Environment (Overrides the default of ${ENVIRONMENT})

    -h  Show this usage

    -H  Show extended usage

    -l  List backups

    -v  Verbose Mode

    -s  Sitename of site to restore (reqd)
"

EXTENDED_USAGE="
This is a script that restores a wordpress backup to a new site. It uses settings from various files to find the details it needs for a restore. These files/settings are:

/etc/build_custom_config ENVIRONMENT, BACKUP_BUCKET

${builddir}/backup_{sitename}_website contains site name and database name

Command Used To Copy Is: aws --region ${region} s3 cp s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/file

"

info_msg () {
    if [ ${verbose} -eq 1 ]
    then
        echo -e "Info: $1"
    fi
}

while getopts ":d:e:Hhls:v" nextarg  >/dev/null 2>&1
do
    case $nextarg in
        v)      verbose=1
                ;;
        l)      list=1
                ;;
        d)      dayStamp=${OPTARG}
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
dbName=$(awk '{print $2}' ${builddir}/backup_${site}_website)
dbBackup=${dbName}.${dayStamp}.sql
siteBackup=${site}.${dayStamp}.tar.gz

if [ ${list} -eq 1 ]
then
    aws --region ${region} s3 ls s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/
    exit 0
fi

info_msg "Restoring Website ${site}"
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
aws --region ${region} s3 cp s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${siteBackup} - | tar zxf - -C ${wwwDir}
if [ $? -ne 0 ]
then
    echo "Error: Unable to extract ${siteBackup} from S3 backup"
    exit 1
fi
cp ${wwwDir}/${site}.sav/wp-config.php ${wwwDir}/${site}
if [ $? -ne 0 ]
then
    echo "Error: Unable to copy ${wwwDir}/${site}.sav/wp-config.php"
    exit 1
fi

# Now restore the database
info_msg "Restoring Database ${dbName}"
cd /tmp
aws --region ${region} s3 cp s3://${BACKUP_BUCKET}/wordpress/${ENVIRONMENT}/${site}/${dbBackup}.gz . >/dev/null
if [ $? -ne 0 ]
then
    echo -e "Error: unable to retrieve ${dbBackup}.gz from S3"
    exit 1
fi
gzip -d ${dbBackup}.gz
if [ $? -ne 0 ]
then
    echo -e "Error: unable to unzip ${dbBackup}.gz"
    exit 1
fi
echo -e "show databases;\ndrop database ${dbName};\ncreate database ${dbName};\nuse ${dbName};\nsource ${dbBackup};" | mysql >/dev/null
if [ $? -ne 0 ]
then
    echo "Error: Unable to restore database backup"
    rm ${dbBackup}
    exit 1
fi
rm ${dbBackup}

info_msg "Wordpress Successfully Restored ${site}"
info_msg "Once you have checked you may want to remove the directory ${wwwDir}/${site}.sav"

#!/bin/bash

webRoot=/var/www
converterScript=/usr/local/bin/watermarkFile.sh

if [ $# -ne 1 ]
then
    echo "Error: This script requires a site as an argument"
    exit 1
fi

if [ ! -x ${converterScript} ]
then
    echo "Error: Converter Script ${converterScript} Not Found"
    exit 1
fi

site=$1
siteDir=${webRoot}/${site}

if [ ! -d ${siteDir} ]
then
    echo "Error: ${site} does not exist under ${webRoot}"
    exit 1
fi

find ${webRoot}/${site}/wp-content/uploads -type f -name "*.jpeg" -exec ${converterScript} ${site} {} /usr/local/buildfiles/${site}.png \;
find ${webRoot}/${site}/wp-content/uploads -type f -name "*.jpg" -exec ${converterScript} ${site} {} /usr/local/buildfiles/${site}.png \;



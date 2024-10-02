#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Error: This script requires a site as an argument"
    exit 1
fi

site=$1
webRoot=/var/www
siteDir=${webRoot}/${site}
converterScript=/usr/local/bin/watermarkFile.sh

# Check if there is a watermark file, if not, don't watermark the site
if [ ! -f /usr/local/buildfiles/${site}.png ]
then
    echo "Info: No watermark for ${site}. Giving Up"
    exit 0
fi

if [ ! -x ${converterScript} ]
then
    echo "Error: Converter Script ${converterScript} Not Found"
    exit 1
fi

if [ ! -d ${siteDir} ]
then
    echo "Error: ${site} does not exist under ${webRoot}"
    exit 1
fi

# Watermark png, jpeg and jpg files
find ${webRoot}/${site}/wp-content/uploads -type f -iname "*.jpeg" -exec ${converterScript} ${site} {} /usr/local/buildfiles/${site}.png \;
find ${webRoot}/${site}/wp-content/uploads -type f -iname "*.jpg" -exec ${converterScript} ${site} {} /usr/local/buildfiles/${site}.png \;
find ${webRoot}/${site}/wp-content/uploads -type f -iname "*.png" -exec ${converterScript} ${site} {} /usr/local/buildfiles/${site}.png \;

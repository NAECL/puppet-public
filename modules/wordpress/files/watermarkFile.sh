#!/bin/bash -u

if [ $# -ne 3 ]
then
    echo "Error: This script requires a sitename, image file, and watermark file"
    exit 1
fi

site=$1
image=$2
watermark=$3
temp_dir=/tmp/watermarks

mkdir -p ${temp_dir}
if [ ! -d ${temp_dir} ]
then
    echo "Error Temp Dir ${temp_dir} not present"
    exit 1
fi

temp_image=/tmp/watermarks/temp_image
if [ -f ${temp_image} ]
then
    echo "Error: Previous temp image ${temp_image} still exists"
    exit 1
fi

watermarks=/var/www/${site}/.watermarks
touch ${watermarks}

# Check if it has been done
grep -q "${image}:" ${watermarks}
if [ $? -ne 0 ]
then
    echo "Watermarking ${image}"
    mv ${image} ${temp_image}
    /bin/composite -gravity south -geometry +0+10 ${watermark} ${temp_image} ${image}
    if [ $? -ne 0 ]
    then
        echo "Error: Failed to process ${image}"
        mv ${temp_image} ${image}
        exit 1
    else
        rm ${temp_image}
        echo "${image}:" >> ${watermarks}
    fi
fi

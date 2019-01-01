#!/bin/bash

if [ $# -ne 2 ]
then
    echo -e "\nError: Text And Font Scale Needed:\n\nFont scale is 1-4\n1=18 point\n2=36 point\n3=54 point\n4=72 point\n\nE.g. $0 Naecl.Com 2\n\n"
    exit 1
fi

text=$1
size=$2

# Size is factor of 18 point to be used, 1=18 point, 2=36 point etc
basepointsize=18
lengthfactor=$(( ${size} * 10 ))
pointsize=$(( ${basepointsize} * ${size} ))

lc_text=$(echo ${text} | tr '[A-Z]' '[a-z]')
watermarkFile=${lc_text}.png
length=$(echo ${text} | wc -c)
length=$(( ${length} * ${lengthfactor} ))

mask=${text}-mask-mask.jpg
convert -size ${length}x100 xc:black -font Bookman-LightItalic -pointsize ${pointsize} \
        -fill white   -annotate +24+64 "${text}" \
        -fill white   -annotate +26+66 "${text}" \
        -fill black   -annotate +25+65 "${text}" \
        ${mask}

trans_stamp=${text}-trans-stamp.png
convert -size ${length}x100 xc:transparent -font Bookman-LightItalic -pointsize ${pointsize} \
        -fill black -annotate +24+64 "${text}" \
        -fill white -annotate +26+66 "${text}" \
        -fill transparent  -annotate +25+65 "${text}" \
        ${trans_stamp}

# This line prepares a plasma jpg to be watermarked as an example
# convert -size ${length}x360 plasma: -shave 0x40 sample_source.jpg

composite -compose CopyOpacity ${mask} ${trans_stamp} ${watermarkFile}

rm ${mask} ${trans_stamp}

# To watermark a file use this command
# composite ${watermarkFile} source outfile

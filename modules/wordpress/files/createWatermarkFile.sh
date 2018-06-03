#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Error: Text Needed, E.g. Local.Com"
    exit 1
fi

text=$1
lc_text=$(echo ${text} | tr '[A-Z]' '[a-z]')
watermarkFile=${lc_text}.png
length=$(echo ${text} | wc -c)
length=$(( ${length} * 40 ))

mask=${text}-mask-mask.jpg
convert -size ${length}x100 xc:black -font Bookman-LightItalic -pointsize 72 \
        -fill white   -annotate +24+64 "${text}" \
        -fill white   -annotate +26+66 "${text}" \
        -fill black   -annotate +25+65 "${text}" \
        ${mask}

trans_stamp=${text}-trans-stamp.png
convert -size ${length}x100 xc:transparent -font Bookman-LightItalic -pointsize 72 \
        -fill black -annotate +24+64 "${text}" \
        -fill white -annotate +26+66 "${text}" \
        -fill transparent  -annotate +25+65 "${text}" \
        ${trans_stamp}

# This line prepares a plasma jpg to be watermarked as an example
# convert -size ${length}x360 plasma: -shave 0x40 sample_source.jpg

composite -compose CopyOpacity ${mask} ${trans_stamp} ${watermarkFile}

# To watermark a file use this command
# composite ${watermarkFile} source outfile

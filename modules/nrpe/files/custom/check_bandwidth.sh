#!/bin/bash

utils=/usr/local/nagios/libexec/custom/utils.sh

if [ ! -r ${utils} ]
then
	echo "Unknown: Unable to find config file ${utils}"
	exit 3
else
	. ${utils}
fi

# Determine bandwidth usage on Linux servers.

# Take a 30 second sample
usage=$(/usr/bin/vnstat -tr 30 -i eth0)
echo ${usage} | grep -o "rx [[:digit:]]*\.[[:digit:]]* ."
echo ${usage} | grep -o "tx [[:digit:]]*\.[[:digit:]]* ."
rx_val=$(echo ${usage} | grep -o "rx [[:digit:]]*\.[[:digit:]]* ." | cut -d' ' -f 2)
tx_val=$(echo ${usage} | grep -o "tx [[:digit:]]*\.[[:digit:]]* ." | cut -d' ' -f 2)
rx_type=$(echo ${usage} | grep -o "rx [[:digit:]]*\.[[:digit:]]* ." | cut -d' ' -f 3)
tx_type=$(echo ${usage} | grep -o "tx [[:digit:]]*\.[[:digit:]]* ." | cut -d' ' -f 3)

# If its kilobits, then set a multiplier of 1, otherwise assume MBits, and a multiplier of 1024
#
if [ "${rx_type}" = "k" ]
then
	rx_kb=2
else
	rx_kb=2048
fi

if [ "${tx_type}" = "k" ]
then
	tx_kb=2
else
	tx_kb=2048
fi

if [ "${rx_val}" = "" -o "${tx_val}" = "" ]
then
	echo "WARNING - Incorrect Response from vnstat"
	exit ${STATE_WARNING}
fi

# Now see how many kilobits have gone
rx_bits_int_val=$(perl -e "print int(${rx_val} * ${rx_kb})")
tx_bits_int_val=$(perl -e "print int(${tx_val} * ${tx_kb})")
rx_bytes_int_val=$(perl -e "print ${rx_bits_int_val} / 8")
tx_bytes_int_val=$(perl -e "print ${tx_bits_int_val} / 8")

# Not sure about alerting on no traffic, since the granularity of vnstat isn't up to it
# # If there were no kilobits in a minute, then alert
# if [ $tx_bits_int_val -gt 0 -o $rx_bits_int_val -gt 0 ]
# then
	# echo "OK - Bandwidth usage IN is $rx_bytes_int_val KB/Min, bandwidth usage OUT is $tx_bytes_int_val KB/Min|bw_in_kb=$rx_bytes_int_val;;;;|bw_out_kb=$tx_bytes_int_val;;;;"
	# exit ${STATE_OK}
# else 
        # echo "WARNING - Bandwidth usage IN is $rx_bytes_int_val KB/Min, bandwidth usage OUT is $tx_bytes_int_val KB/Min|bw_in_kb=$rx_bytes_int_val;;;;|bw_out_kb=$tx_bytes_int_val;;;;"
	# exit ${STATE_WARNING}
# fi

echo "OK - Bandwidth usage IN is $rx_bytes_int_val KB/Min, bandwidth usage OUT is $tx_bytes_int_val KB/Min|bw_in_kb=$rx_bytes_int_val;;;;|bw_out_kb=$tx_bytes_int_val;;;;"
exit ${STATE_OK}

#!/bin/bash

PATH=/bin:/usr/bin:/sbin:/usr/sbin
USR_BIN_PATH="/usr/bin/"
OUTPUT_PATH="check_capability.txt"
#OUTPUT_PATH="/usr/share/security-config/output/root_test/check_capability_usr.txt"


# Let's start service check whether service is root or not from here

/bin/echo "########################################"
/bin/echo "Check Capability"
/bin/echo "########################################"

for line in `find / -type f 2> /dev/null`
do
	result=`/usr/sbin/getcap $line 2> /dev/null`
	
	if [ -n "$result" ]; then
		/bin/echo $result >> $OUTPUT_PATH
	fi
	
done


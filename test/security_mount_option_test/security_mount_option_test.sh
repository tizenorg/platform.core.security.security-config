#!/bin/bash

result_dir="/usr/share/security-config/result"
result_file=$result_dir"/security_mount_option_result.csv"
chk_result=$(/bin/cat /proc/mounts | grep "/tmp" | grep "nosuid" | grep "noexec")

if [ ! -d $result_dir ]; then
    /bin/mkdir $result_dir
fi

if [ "$chk_result" = "" ]
then
	/bin/echo "Does /tmp folder have nosuid & noexec options? , NO" > $result_file
else
	/bin/echo "Does /tmp folder have nosuid & noexec options? , YES" > $result_file
fi



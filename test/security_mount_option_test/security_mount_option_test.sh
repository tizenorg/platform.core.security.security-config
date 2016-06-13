#!/bin/bash

result_dir="/usr/share/security-config/result"
log_dir="/usr/share/security-config/log"
result_file=$result_dir"/security_mount_option_test.result"
log_file=$log_dir"/security_mount_option_test.log"
chk_result=$(/bin/cat /proc/mounts | /bin/grep "/tmp" | /bin/grep "nosuid" | /bin/grep "noexec")

if [ ! -d $result_dir ]; then
    /bin/mkdir $result_dir
fi

if [ "$chk_result" = "" ]
then
	/bin/echo "Does /tmp folder have nosuid & noexec options? , NO" > $log_file
	/bin/echo "NO" > $result_file
else
	/bin/echo "Does /tmp folder have nosuid & noexec options? , YES" > $log_file
	/bin/echo "YES" > $result_file
fi



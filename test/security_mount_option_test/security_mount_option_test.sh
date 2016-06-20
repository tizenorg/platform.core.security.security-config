#!/bin/bash

result_dir="/usr/share/security-config/result"
log_dir="/usr/share/security-config/log"
result_file=$result_dir"/security_mount_option_test.result"
log_file=$log_dir"/security_mount_option_test.log"

function check_tmp
{
	chk_tmp=$(/bin/cat /proc/mounts | /bin/grep "/tmp " | /bin/grep "nosuid" | /bin/grep "noexec" | /bin/grep "nodev")
	if [ "$chk_tmp" = "" ]
	then
		/bin/echo "Does /tmp folder have noexec & nosuid & nodev options? , NO" >> $log_file
		/bin/echo "NO" > $result_file
	else
		/bin/echo "Does /tmp folder have noexec & nosuid & nodev options? , YES" >> $log_file
	fi
}

function check_dev_shm
{
	chk_dev_shm=$(/bin/cat /proc/mounts | /bin/grep "/dev/shm " | /bin/grep "nosuid" | /bin/grep "noexec" | /bin/grep "nodev")
	if [ "$chk_dev_shm" = "" ]
	then
		/bin/echo "Does /dev/shm folder have noexec & nosuid & nodev options? , NO" >> $log_file
		/bin/echo "NO" > $result_file
	else
		/bin/echo "Does /tmp folder have noexec & nosuid & nodev options? , YES" >> $log_file
	fi
}

function check_run
{
	chk_run_user=$(/bin/cat /proc/mounts | /bin/grep "/run/user/5001 " | /bin/grep "nosuid" | /bin/grep "nodev")
	if [ "$chk_run" = "" ]
	then
		/bin/echo "Does /run/user/5001 folder have noexec & nosuid & nodev options? , NO" >> $log_file
		/bin/echo "NO" > $result_file
	else
		/bin/echo "Does /run/user/5001 folder have nosuid & nodev options? , YES" >> $log_file
	fi
}

if [ ! -d $log_dir ]; then
    /bin/mkdir $log_dir
fi
if [ ! -d $result_dir ]; then
    /bin/mkdir $result_dir
fi
if [ -e $result_file ]
then
	/bin/rm $result_file
fi
if [ -e $log_file ]
then
	/bin/rm $log_file
fi

/bin/echo "YES" > $result_file
check_tmp
check_dev_shm
check_run

if [ "$(/bin/cat $result_file)" = "YES" ]
then
	/bin/rm $log_file
fi

/bin/echo "Security_mount_optione test is finished"


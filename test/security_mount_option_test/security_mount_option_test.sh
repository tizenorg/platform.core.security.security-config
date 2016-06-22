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
		/bin/echo "Does /dev/shm folder have noexec & nosuid & nodev options? , YES" >> $log_file
	fi
}

function check_run
{
	chk_run_user=$(/bin/cat /proc/mounts | /bin/grep "/run/user/5001 " | /bin/grep "noexec" | /bin/grep "nosuid" | /bin/grep "nodev")
	if [ "$chk_run_user" = "" ]
	then
		/bin/echo "Does /run/user/5001 folder have noexec & nosuid & nodev options? , NO" >> $log_file
		/bin/echo "NO" > $result_file
	else
		/bin/echo "Does /run/user/5001 folder have noexec & nosuid & nodev options? , YES" >> $log_file
	fi
}

function check_sdcard
{
	# check whether there is SDCARD
	chk_sdcard=$(/bin/cat /proc/mounts | /bin/grep "SDCard")
	if [ "$chk_sdcard" = "" ]
	then
		# there is no sdcard on target. skip this function
		return 1
	fi	

	# check SDCARD mount option
	chk_sdcard_mnt=$(/bin/cat /proc/mounts | /bin/grep "SDCard" | /bin/grep "noexec" | /bin/grep "nosuid" | /bin/grep "nodev")
	if [ "$chk_sdcard_mnt" = "" ]
	then
		/bin/echo "Does /opt/media/SDCard* folder have noexec & nosuid & nodev options? , NO" >> $log_file
		/bin/echo "NO" > $result_file
	else
		/bin/echo "Does /opt/media/SDCard* folder have noexec & nosuid & nodev options? , YES" >> $log_file
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
check_sdcard

if [ "$(/bin/cat $result_file)" = "YES" ]
then
	/bin/rm $log_file
fi

/bin/echo "Security_mount_optione test is finished"


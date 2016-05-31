#!/bin/bash

result_dir="/usr/share/security-config/result"
log_dir="/usr/share/security-config/log"
result_file=$result_dir"/smack_basic_result.csv"
log_file=$log_dir"/smack_basic_log.csv"
smackfs_path="/sys/fs/smackfs"
smack_rule_path="$smackfs_path/load2"

# check whether smackfs is mounted
function chk_smackfs_mount
{
	/bin/echo "1. smackfs mount check" >> $result_file
	result_smackfs_mount=$(/bin/cat /proc/mounts | /bin/grep "$smackfs_path")
	if [ "$result_smackfs_mount" = "" ]
	then
		/bin/echo "Is smackfs mounted? , No" >> $result_file
	else
		/bin/echo "Is smackfs mounted? , Yes" >> $result_file
	fi
}

function chk_floor_smack_rule
{
	flag=0
	/bin/echo "" >> $result_file
	/bin/echo "2. Smack rule for floor label check" >> $result_file	

	while read app_name
	do
		app_name_cut=$(/bin/echo ${app_name:4}) # cut "app_"
		rule_filtered=$(/bin/cat $smack_rule_path | grep "User::App::$app_name_cut _ l")
		if [ "$rule_filtered" = "" ]
		then
			flag=1
			/bin/echo "User::App::$app_name_cut _ l is not existed" >> $log_file
		fi
	done < <( /bin/ls /opt/var/security-manager/rules | grep "app_")

	if [ $flag -eq 0 ]
	then
		/bin/echo "Floor check pass? , Yes" >> $result_file
	else
		/bin/echo "Floor check pass? , No" >> $result_file
	fi
}



# check whether long label is supported
function chk_long_label
{
	/bin/echo "" >> $result_file
	/bin/echo "3. Long label support check" >> $result_file
	if [ -e "$smackfs_path/load2" ]
	then
		/bin/echo "Is /sys/fs/smackfs/load2 existed?, Yes" >> $result_file
	else
		/bin/echo "Is /sys/fs/smackfs/load2 existed?, No" >> $result_file
	fi
	
	if [ -e "$smackfs_path/access2" ]
	then
		/bin/echo "Is /sys/fs/smackfs/access2 existed?, Yes" >> $result_file
	else
		/bin/echo "Is /sys/fs/smackfs/access2 existed?, No" >> $result_file
	fi
}

function chk_netlabel
{
	/bin/echo "" >> $result_file
	/bin/echo "4. Netlabel support check" >> $result_file
	if [ -e "$smackfs_path/netlabel" ]
	then
		/bin/echo "Is /sys/fs/smackfs/netlabel existed?, Yes" >> $result_file
	else
		/bin/echo "Is /sys/fs/smackfs/netlabel existed?, No" >> $result_file
	fi
	
	if [ -e "$smackfs_path/ambient" ]
	then
		/bin/echo "Is /sys/fs/smackfs/ambient existed?, Yes" >> $result_file
	else
		/bin/echo "Is /sys/fs/smackfs/ambient existed?, No" >> $result_file
	fi
}

function chk_ptrace
{
	/bin/echo "" >> $result_file
	/bin/echo "5. Ptrace smack option check" >> $result_file
	ptrace_read=$(/bin/cat "$smackfs_path/ptrace")

	if [ $ptrace_read -eq 0 ]
	then
		/bin/echo "Read sys/fs/smackfs/ptrace , 0 - default" >> $result_file
	elif [ $ptrace_read -eq 1 ]
	then
		/bin/echo "Read sys/fs/smackfs/ptrace , 1 - exact" >> $result_file
	elif [ $ptrace_read -eq 2 ]
	then
		/bin/echo "Read sys/fs/smackfs/ptrace , 2 - draconian" >> $result_file
	else
		/bin/echo "Read sys/fs/smackfs/ptrace , $ptrace_read : invalid value" >> $result_file		
	fi
}

function chk_unconfined
{
	/bin/echo "" >> $result_file
	/bin/echo "6. unconfined check" >> $result_file
	if [ -e "$smackfs_path/unconfined" ]
	then
		unconfined_read=$(/bin/cat $smackfs_path/unconfined)
		if [ "$unconfined_read" = "" ]
		then
			/bin/echo "unconfied file is existed. But it is empty." >> $result_file
		else
			/bin/echo "unconfied file is existed. And it is not empty." >> $result_file
		fi
	else
		/bin/echo "unconfied file is not existed." >> $result_file
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

chk_smackfs_mount
chk_floor_smack_rule
chk_long_label
chk_netlabel
chk_ptrace
chk_unconfined



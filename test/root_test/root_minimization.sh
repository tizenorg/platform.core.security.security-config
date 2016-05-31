#!/bin/bash

# @file		root_minimization.sh
# @author	Seongwook Chung (seong.chung@samsung.com)
# @brief	Check each service file(systemd/dbus) whether it is running as root or non-root
#               Check if there is new root service

SYSTEMD_PATH="/usr/lib/systemd/system"
DBUS_PATH="/usr/share/dbus-1/system-services"
ROOT_LIST="/usr/share/security-config/test/root_test/root_daemon_list"
NON_DAEMON_LIST="/usr/share/security-config/test/root_test/non_daemon_list"
NON_ROOT_LIST="/usr/share/security-config/test/root_test/non_root_list"
EXCEPTION_LIST="/usr/share/security-config/test/root_test/exception_list"
LOG_FAILED_SERVICES="/usr/share/security-config/log/log_failed_list"
LOG_NEW_ROOT_SERVICES="/usr/share/security-config/log/log_new_root_list"
RESULT_FAILED_SERVICES="/usr/share/security-config/result/result_failed_list"
RESULT_NEW_ROOT_SERVICES="/usr/share/security-config/result/result_new_root_list"

checkNonRootList(){

	# $1 : service_name
	# $2 : service_type
	# $3 : expected uid
	# $4 : expected gid

	if [ "$2" = "systemd" ]; then
		service_path="$SYSTEMD_PATH/$1"
	elif [ "$2" = "dbus" ]; then
		service_path="$DBUS_PATH/$1"
	fi

	comment_check_user_id=0
	comment_check_group_id=0
	flag_user_id=0
	flag_group_id=0
	flag_systemd_service=0

	# check contents of service file (like fgets in C)
	for line in $(/bin/cat $service_path)
	do
		if [[ "${line}" == *User=* ]];
		then
			# Should check whether #(comment) is in front of User=
			# This makes neutralize making non-root user id
			# We don't allow this case
			if [[ "${line}" == *'#'User=* ]];
			then
				comment_check_user_id=1
			fi
			flag_user_id=1
			# Get value(user id) behind User=
			real_uid=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
		if [[ "${line}" == *Group=* ]];
		then
			# Should check whether #(comment) is in front of User=
			# This makes neutralize making non-root group id
			# We don't allow this case
			if [[ "${line}" == *'#'Group=* ]];
			then
				comment_check_group_id=1
			fi
			flag_group_id=1
			# Get value(group id) behind Group=
			real_gid=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
		if [[ "${line}" == *SystemdService=* ]];
		then
			flag_systemd_service=1
			# Get value(name of systemd service) behind SystemdService=
			systemd_service_name=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
		if [[ "${line}" == *ExecStart=* ]];
		then
			flag_exec_systemd=1
			exec_name_systemd=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
		if [[ "${line}" == *Exec=* ]];
		then	
			flag_exec_dbus=1
			exec_name_dbus=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
	done

	# If dbus service has attribute; "SystemdService", we focus on service of systemd
	# Should find "User=" and "Group=" of systemd service and extract value as new one
	if [ $flag_systemd_service -eq 1 ]; then
		comment_check_user_id=0
		comment_check_group_id=0
		flag_user_id=0
		flag_group_id=0
		/bin/echo "## SystemdService is set: $systemd_service_name"
		service_path="$SYSTEMD_PATH/$systemd_service_name"
		for line in $(/bin/cat $service_path)
		do
			if [[ "${line}" == *User=* ]];
			then
				# Should check whether #(comment) is in front of User=
				# This makes neutralize making non-root user id
				# We don't allow this case
				if [[ "${line}" == *'#'User=* ]];
				then
					comment_check_user_id=1
				fi
				flag_user_id=1
				# Get value(user id) behind User=
				real_uid=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
			fi
			if [[ "${line}" == *Group=* ]];
			then
				# Should check whether #(comment) is in front of User=
				# This makes neutralize making non-root group id
				# We don't allow this case
				if [[ "${line}" == *'#'Group=* ]];
				then
					comment_check_group_id=1
				fi
				flag_group_id=1
				# Get value(group id) behind Group=
				real_gid=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
			fi
		done
	fi

	# Exception case(e.g. pulseaudio.service / buxton2.service / org.bluetooth.share.service)
	for line in $(/bin/cat $EXCEPTION_LIST)
	do
		# awk filters 1st value from "," e.g alarm-server.service,systemd
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ $1 = $service_name ]; then
			service_type=`/bin/echo $line | /usr/bin/awk -F "," '{print $2}'`
			service_uid=`/bin/echo $line | /usr/bin/awk -F "," '{print $3}'`
			service_gid=`/bin/echo $line | /usr/bin/awk -F "," '{print $4}'`

			/bin/echo "## $1 is in exception_list"
			if [ $2 = "systemd" ]; then
				process_uid=`/bin/ps -ef | /bin/grep $exec_name_systemd | /bin/grep -v grep | /usr/bin/awk -F " " '{print $1}'`
			elif [ $2 = "dbus" ]; then 
				process_uid=`/bin/ps -ef | /bin/grep $exec_name_dbus | /bin/grep -v grep | /usr/bin/awk -F " " '{print $1}'`
			fi
			
			if [ $service_uid = $process_uid ]; then
				/bin/echo "##Success, expected uid is $service_uid, and real uid is $process_uid, it is appropriate uid"
				/bin/echo "============================================================================================" 
			else
				/bin/echo "@@Failed, expected uid is $service_uid, but real uid is $process_uid, it is not appropriate uid"
				/bin/echo "$1($2), expected uid is $service_uid, but real uid is $process_uid, it is not appropriate uid" >> $LOG_FAILED_SERVICES 
				/bin/echo "=============================================================================================" >> $LOG_FAILED_SERVICES
			fi
				return 0
		fi
	done

	# Evaluate result
	# Check comment_check_user_id/group_id and flag_user_id/group_id
	if [ $flag_user_id -eq 0 -a $flag_group_id -eq 0 ]; then
		if [ $expected_uid = "USER" -a $expected_gid = "USER" ]; then
			/bin/echo "## This service sets uid ad user logged in"
			/bin/echo "============================"
			return 0
		fi
		/bin/echo "@@Failed, There is no User= and Group="
		/bin/echo "============================"

		/bin/echo "@@$1($2), There is no User= and Group=" >> $LOG_FAILED_SERVICES
		/bin/echo "==================================================" >> $LOG_FAILED_SERVICES
	fi
	if [ $flag_user_id -eq 0 -a $flag_group_id -eq 1 ]; then
		/bin/echo "@@Failed, There is no User="
		/bin/echo "============================"

		/bin/echo "$1($2), There is no User="  >> $LOG_FAILED_SERVICES
		/bin/echo "============================" >> $LOG_FAILED_SERVICES
	fi
	if [ $flag_user_id -eq 1 -a $flag_group_id -eq 0 ]; then
		/bin/echo "@@Failed, There is no Group="
		/bin/echo "============================"

		/bin/echo "$1($2), There is no Group=" >> $LOG_FAILED_SERVICES
		/bin/echo "============================" >> $LOG_FAILED_SERVICES
	fi
	if [ $flag_user_id -eq 1 -a $flag_group_id -eq 1 ]; then
		if [ $comment_check_user_id -eq 1 -o $comment_check_group_id -eq 1 ]; then
			/bin/echo "@@Failed, Comment like '#User=' and '#Group=' is not allowed"	
			/bin/echo "============================================================"

			/bin/echo "$1($2), Comment like '#User=' and '#Group=' is not allowed" >> $LOG_FAILED_SERVICES	
			/bin/echo "============================================================" >> $LOG_FAILED_SERVICES
		else
			if [ $real_uid = $3 -a $real_gid = $4 ]; then
				/bin/echo "##Success"
				/bin/echo "##expected uid is $3, and real uid is $real_uid, it is appropriated uid"
				/bin/echo "##expected gid is $4, and real gid is $real_gid, it is appropriated gid"
				/bin/echo "=======================================================================" 
			else
				/bin/echo "@@Failed"
				/bin/echo "@@expected uid is $3, but real uid is $real_uid"
				/bin/echo "@@expected gid is $4, but real gid is $real_gid"
				/bin/echo "==============================================="

				/bin/echo "$1($2) / expected uid is $3, but real uid is $real_uid" >> $LOG_FAILED_SERVICES
				/bin/echo "$1($2) / expected gid is $4, but real gid is $real_gid" >> $LOG_FAILED_SERVICES
				/bin/echo "===============================================" >> $LOG_FAILED_SERVICES

			fi # end of if [ $real_uid = $3 -a $real_gid = $4 ]; then
		fi # end of if [ $comment_check_user_id -eq 1 -o $comment_check_group_id -eq 1 ]; then
	fi # end of if [ $flag_user_id -eq 1 -a $flag_group_id -eq 1 ]; then
}

checkWhetherNewRoot(){

	# $1 : service_name
	# $2 : service_type

	comment_check_user_id=0
	comment_check_group_id=0
	flag_user_id=0
	flag_group_id=0

	if [ "$2" = "systemd" ]; then
		service_path="$SYSTEMD_PATH/$1"
	elif [ "$2" = "dbus" ]; then
		service_path="$DBUS_PATH/$1"
	fi

	for line in $(/bin/cat $service_path)
	do
		if [[ "${line}" == *User=* ]];
		then
			# Should check whether #(comment) is in front of User=
			# This makes neutralize making non-root user id
			# We don't allow this case
			if [[ "${line}" == *'#'User=* ]];
			then
				comment_check_user_id=1
			fi
			flag_user_id=1
			# Get value(user id) behind User=
			real_uid=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
		if [[ "${line}" == *Group=* ]];
		then
			# Should check whether #(comment) is in front of User=
			# This makes neutralize making non-root group id
			# We don't allow this case
			if [[ "${line}" == *'#'Group=* ]];
			then
				comment_check_group_id=1
			fi
			flag_group_id=1
			# Get value(group id) behind Group=
			real_gid=`/bin/echo $line | /usr/bin/awk -F "=" '{print $2}'`
		fi
	done

	# Check comment_check_user_id/group_id and flag_user_id/group_id
	if [ $flag_user_id -eq 0 -a $flag_group_id -eq 0 ]; then
		/bin/echo "Service path of unknown: $service_path"
		/bin/echo "@@Failed, There is no User= and Group="
		/bin/echo "========================================"

		/bin/echo "$1($2) is new root" >> $LOG_NEW_ROOT_SERVICES
		/bin/echo "========================================" >> $LOG_NEW_ROOT_SERVICES
	fi
	if [ $flag_user_id -eq 0 -a $flag_group_id -eq 1 ]; then
		/bin/echo "Service path of unknown: $service_path"
		/bin/echo "@@Failed, There is no User="
		/bin/echo "========================================"

		/bin/echo "$1($2) is new root" >> $LOG_NEW_ROOT_SERVICES
		/bin/echo "========================================" >> $LOG_NEW_ROOT_SERVICES
	fi
	if [ $flag_user_id -eq 1 -a $flag_group_id -eq 0 ]; then
		/bin/echo "Service path of unknown: $service_path"
		/bin/echo "@@Failed, There is no Group="
		/bin/echo "========================================"

		/bin/echo "$1($2) is new root" >> $LOG_NEW_ROOT_SERVICES
		/bin/echo "========================================" >> $LOG_NEW_ROOT_SERVICES
	fi
	if [ $flag_user_id -eq 1 -a $flag_group_id -eq 1 ]; then
		if [ $comment_check_user_id -eq 1 -o $comment_check_group_id -eq 1 ]; then
			/bin/echo "@@Failed, Comment is not allowed"
			/bin/echo "============================"
			/bin/echo "$1($2) is new root" >> $LOG_NEW_ROOT_SERVICES
			/bin/echo "========================================" >> $LOG_NEW_ROOT_SERVICES
		else
			/bin/echo "Service path of unknown: $service_path"
			if [ "$real_uid" = "root" -o "$real_gid" = "root" ]; then
				/bin/echo "@@Failed, why $service_name uses root id?"
				/bin/echo "====================================================" 
				/bin/echo "$1($2) is new root" >> $LOG_NEW_ROOT_SERVICES 
			else
				/bin/echo "## Service $1 is using uid:$real_uid and gid: $real_gid" 		
				/bin/echo "====================================================" 
			fi
		fi
	fi
}

checkServiceFile(){
	# $1 : service_name
	# $2 : service_type

	# Try to find root service
	for line in $(/bin/cat $ROOT_LIST)
	do
		# awk filters 1st value from "," e.g alarm-server.service,systemd
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		# compare $1 to service_name in root_daemon_list
		if [ $1 = $service_name ]; then
			/bin/echo "## $1 is in root_daemon_list"
			/bin/echo "====================================================" 
			# stop below code lines and return success to find
			return 0
		fi
	done

	# Try to find non-daemon service
	for line in $(/bin/cat $NON_DAEMON_LIST)
	do
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ $1 = $service_name ]; then
			/bin/echo "## $1 is in non_daemon_list"
			/bin/echo "====================================================" 
			# stop below code lines and retrun success to find
			return 0
		fi
	done


	# Try to find non-root daemon service
	for line in $(/bin/cat $NON_ROOT_LIST)
	do
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ $1 = $service_name ]; then
			/bin/echo "## $1 is in non_root_list"
			# Found,
			# 1st extract service type, uid, gid from our list
			service_type=`/bin/echo $line | /usr/bin/awk -F "," '{print $2}'`
			expected_uid=`/bin/echo $line | /usr/bin/awk -F "," '{print $3}'`
			expected_gid=`/bin/echo $line | /usr/bin/awk -F "," '{print $4}'`
			# 2nd call checkNonRootList (pass service name, service type, uid, gid)
			checkNonRootList $service_name $service_type $expected_uid $expected_gid
			# If found non-Root, then should  retrun success to find
			return 0
		fi
	done

	# ## This service would be new daemon / service ##
	checkWhetherNewRoot $1 $2
 
}

## Let's start service check whether service is root or not from here
if [ -f $LOG_FAILED_SERVICES ]; then
   /bin/rm $LOG_FAILED_SERVICES
fi

if [ -f $LOG_NEW_ROOT_SERVICES ]; then
   /bin/rm $LOG_NEW_ROOT_SERVICES
fi

/bin/echo "##########################################"
/bin/echo "Below list represents system service files"
/bin/echo "##########################################"

for entry in $SYSTEMD_PATH/*
do
	service_name=`/usr/bin/basename "$entry"`
	# Should filter ".socket", "target", ".wants", ".mount", ".automount", ".path", ".slice", ".timer"	
	extension=`/bin/echo $service_name | /usr/bin/awk -F "." '{print $NF}'`
	if [ "$extension" = "service" ]; then
		checkServiceFile $service_name "systemd"
	fi
done

/bin/echo "########################################"
/bin/echo "Below list represents dbus service files"
/bin/echo "########################################"

for entry in $DBUS_PATH/*
do
	service_name=`/usr/bin/basename "$entry"`
	# Should filter ".socket", "target", ".wants", ".mount", ".automount", ".path", ".slice", ".timer"	
	extension=`/bin/echo $service_name | /usr/bin/awk -F "." '{print $NF}'`
	if [ "$extension" = "service" ]; then
		checkServiceFile $service_name "dbus"
	fi
done

if [ -f $LOG_FAILED_SERVICES ]; then
	/bin/echo "NO" > $RESULT_FAILED_SERVICES
else
	/bin/echo "YES" > $RESULT_FAILED_SERVICES
fi

if [ -f $LOG_NEW_ROOT_SERVICES ]; then
	/bin/echo "NO" > $RESULT_NEW_ROOT_SERVICES
else
	/bin/echo "YES" > $RESULT_NEW_ROOT_SERVICES
fi


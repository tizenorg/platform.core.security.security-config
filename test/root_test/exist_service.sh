#!/bin/bash

SYSTEMD_PATH="/usr/lib/systemd/system/"
DBUS_PATH="/usr/share/dbus-1/system-services/"
ROOT_LIST="/usr/share/security-config/test/root_test/root_daemon_list"
NON_DAEMON_LIST="/usr/share/security-config/test/root_test/non_daemon_list"
NON_ROOT_LIST="/usr/share/security-config/test/root_test/non_root_list"

LOG_NEW_SERVICE="/usr/share/security-config/log/root_test_new_service.log"
LOG_DELETED_DERVICE="/usr/share/security-config/log/root_test_deleted_service.log"
RESULT_NEW_SERVICE="/usr/share/security-config/result/root_test_new_service.result"
RESULT_DELETED_DERVICE="/usr/share/security-config/result/root_test_deleted_service.result"

#SYSTEMD_PATH="/home/keeho/root_minimization/systemd/system/"
#DBUS_PATH="/home/keeho/root_minimization/dbus-1/system-services/"
#ROOT_LIST="/home/keeho/root_minimization/root_daemon_list"
#NON_DAEMON_LIST="/keeho/root_minimization/non_daemon_list"
#NON_ROOT_LIST="/home/keeho/root_minimization/non_root_list"

checkServiceFile(){
	# $1 : service_name
	# $2 : service_type

	# Try to find root service

	for line in $(/bin/cat $ROOT_LIST)
	do
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ $1 = $service_name ]; then
			return 0
		fi
	done

	# Try to find non-daemon service
	for line in $(/bin/cat $NON_DAEMON_LIST)
	do
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ $1 = $service_name ]; then
			return 0
		fi
	done

	# Try to find non-root daemon service
	for line in $(/bin/cat $NON_ROOT_LIST)
	do
		service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ $1 = $service_name ]; then
			return 0
		fi
	done

	# ## This service would be new daemon / service ##
	/bin/echo "$1 is new service"
	/bin/echo $1 >> $LOG_NEW_SERVICE
}

checkList() {
	# $1 : service_name
	# $2 : service_type

	flag=0

	for line in $SYSTEMD_PATH/*
	do
		service_name=`/usr/bin/basename "$line"`
		extension=`/bin/echo $service_name | /usr/bin/awk -F "." '{printf $NF}'`
		if [ "$extension" = "service" ]; then
			if [ $1 = $service_name ]; then
				#/bin/echo "$service_name is exist in systemd"
				flag=1
				return 0;
			fi
		fi
	done

	for line in $DBUS_PATH/*

	do
		service_name=`/usr/bin/basename "$line"`
		extension=`/bin/echo $service_name | /usr/bin/awk -F "." '{printf $NF}'`
		if [ "$extension" = "service" ]; then
			if [ $1 = $service_name ]; then
				#/bin/echo "$service_name is exist in dbus"
				return 0;
			fi
		fi
	done

	if [ "$extension" = "service" ]; then
		if [ $flag -eq 0 ]; then
			/bin/echo "$1 is not exist"
			/bin/echo $1  >> $LOG_DELETED_DERVICE
		fi
	fi
}

# Let's start service check whether service is root or not from here
if [ -f $LOG_NEW_SERVICE ]; then
   /bin/rm $LOG_NEW_SERVICE
fi

if [ -f $LOG_DELETED_DERVICE ]; then
   /bin/rm $LOG_DELETED_DERVICE
fi

/bin/echo "########################################"
/bin/echo "Check New Service"
/bin/echo "########################################"

for entry in $SYSTEMD_PATH/*
do
	service_name=`/usr/bin/basename "$entry"`
	extension=`/bin/echo $service_name | /usr/bin/awk -F "." '{print $NF}'`

	if [ "$extension" = "service" ]; then
		checkServiceFile $service_name "systemd"
	fi
done

for entry in $DBUS_PATH/*
do
	service_name=`/usr/bin/basename "$entry"`
	extension=`/bin/echo $service_name | /usr/bin/awk -F "." '{print $NF}'`
	if [ "$extension" = "service" ]; then
		checkServiceFile $service_name "dbus"
	fi
done

/bin/echo "########################################"
/bin/echo "Check Delete Service"
/bin/echo "########################################"

#for entry in $(/bin/cat /home/seong/workspace/root_minimization/root_daemon_list)
for entry in $(/bin/cat $ROOT_LIST)
do
	service_name=`/bin/echo $entry | awk -F "," '{print $1}'`
	extension=`/bin/echo $entry | awk -F "," '{print $NF}'`

	checkList $service_name $extension
done

for entry in $(/bin/cat $NON_DAEMON_LIST)
do
	service_name=`/bin/echo $entry | awk -F "," '{print $1}'`
	extension=`/bin/echo $entry | awk -F "." '{print $NF}'`

	checkList $service_name $extension
done

for entry in $(/bin/cat $NON_ROOT_LIST)
do
	service_name=`/bin/echo $entry | awk -F "," '{print $1}'`
	extension=`/bin/echo $entry | awk -F "," '{print $NF}'`

	checkList $service_name $extension
done

if [ -f $LOG_NEW_SERVICE ]; then
	/bin/echo "NO" > $RESULT_NEW_SERVICE
else
	/bin/echo "YES" > $RESULT_NEW_SERVICE
fi

if [ -f $LOG_DELETED_DERVICE ]; then
	/bin/echo "NO" > $RESULT_DELETED_DERVICE
else
	/bin/echo "YES" > $RESULT_DELETED_DERVICE
fi

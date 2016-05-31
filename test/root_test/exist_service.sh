#!/bin/bash

SYSTEMD_PATH="/usr/lib/systemd/system/"
DBUS_PATH="/usr/share/dbus-1/system-services/"
ROOT_LIST="/usr/share/security-config/test/root_test/root_daemon_list"
NON_DAEMON_LIST="/usr/share/security-config/test/root_test/non_daemon_list"
NON_ROOT_LIST="/usr/share/security-config/test/root_test/non_root_list"

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
	/bin/echo $1 >> /usr/share/security-config/output/root_test/New_Service.txt
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
			/bin/echo $1  >> /usr/share/security-config/output/root_test/Deleted_Service.txt
		fi
	fi
}

# Let's start service check whether service is root or not from here

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

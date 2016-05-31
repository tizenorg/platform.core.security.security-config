#!/bin/bash

SYSTEMD_PATH="/usr/lib/systemd/system"
ROOT_LIST="/usr/share/security-config/test/capability_test/root_daemon_list"
EXCEPTION_LIST="/usr/share/security-config/test/capability_test/cap_mac_exception_list"
LOG_CAP_MAC_CHECK="/usr/share/security-config/log/log_cap_mac_check"
RESULT_CAP_MAC_CHECK="/usr/share/security-config/result/result_cap_mac_check"

checkExceptionList(){

	# $1 : service_name
	found=0

	for line in $(/bin/cat $EXCEPTION_LIST)
	do
		excepted_service_name=`/bin/echo $line | /usr/bin/awk -F "," '{print $1}'`
		if [ "$1" = "$excepted_service_name" ];then
			found=1
			break
		fi
	done

	if [ $found -eq 1 ];then
		retval="true"
	elif [ $found -eq 0 ]; then
		retval="false"
	fi
}

checkRootList() {

	if [ "$2" = "systemd" ]; then
		service_path="$SYSTEMD_PATH/$1"
	fi

	capabilities_column_max=0
	flag_capability_found=0
	flag_cap_mac_admin_enabled_found=0
	flag_cap_mac_override_enabled_found=0
	flag_cap_mac_admin_disabled_found=0
	flag_cap_mac_override_disabled_found=0

	# check contents of service file
	# We need to check whether how many "CapabilityBoundingSet=" are inside one service file

	count_array=(`/usr/bin/awk '/CapabilityBoundingSet/{print NF}' $service_path`)

	/bin/echo "@@ Service name : $1"

	#  if there is no "CapabilityBoundingSet"
	if [[ -z "${count_array[0]}" ]]; then
		/bin/echo "@@ CapabilityBoundingSet is not found"
		checkExceptionList $service_name
		if [ "$retval" == "true" ]; then
			/bin/echo "@@@@ Allowed, $1 is included in exception list"
			/bin/echo "###########################################################################"
		elif [ "$retval" == "false" ]; then
			/bin/echo "@@@@ Failed, $1 is not included in exception list"
			/bin/echo "###########################################################################"
			/bin/echo "@@ Service name : $1" >> $LOG_CAP_MAC_CHECK
			/bin/echo "@@ CapabilityBoundingSet is not found" >> $LOG_CAP_MAC_CHECK
			/bin/echo "@@@@ Failed, $1 is not included in exception list" >> $LOG_CAP_MAC_CHECK
			/bin/echo "###########################################################################" >> $LOG_CAP_MAC_CHECK
		fi
		return
	fi

	# There is only one row (only one CapabilityBoundingSet)
	if [[ ${#count_array[@]} -eq 1 ]];then
		# If size of count_array is 1, then we check the value
		# If value is zero, we conclude there is no CapabiltyBoudingSet

		flag_capability_found=1 # there is only one row in capability list
		capabilities_column_max=${count_array[0]} # how many columns in one row of capability list
		string=(`/usr/bin/awk '/CapabilityBoundingSet/{print $1}' $service_path`)
		cap_name=`/bin/echo ${string} | /usr/bin/awk -F "=" '{print $2}'`

		if [ "$cap_name" = "~CAP_MAC_ADMIN" ]; then
			flag_cap_mac_admin_disabled_found=1
		elif [ "$cap_name" = "~CAP_MAC_OVERRIDE" ]; then
			flag_cap_mac_override_disabled_found=1
		fi

		if [ $capabilities_column_max -gt 1 ]; then
			for (( cnt=2; cnt<=$capabilities_column_max; cnt++ ))
			do
				cap_name=`/usr/bin/awk '/CapabilityBoundingSet/{print $'$cnt'}' $service_path`
				if [ "$cap_name" = "CAP_MAC_ADMIN" ]; then
					flag_cap_mac_admin_enabled_found=1
				elif [ "$cap_name" = "CAP_MAC_OVERRIDE" ]; then
					flag_cap_mac_override_enabled_found=1
				fi
			done
		fi
	# There are multiple rows
	else
		# We try to find maximum number of column in multiple rows of CapabilityBoundingSet
		for (( cnt=0; cnt<${#count_array[@]}; cnt++ ))
		do
			count=${count_array[$cnt]}

			if [ $count -gt $capabilities_column_max ];then
				capabilities_column_max=$count
			fi
		done

		# We get all capabilities by traversing(visiting) column by column(1st column -> 2nd column -> ...)

		# lst column
		string=(`/usr/bin/awk '/CapabilityBoundingSet/{print $1}' $service_path`)
		for (( cnt=0; cnt<${#string[@]}; cnt++ ))
		do
			# need to remove "CapabilityBoundingSet=" via awk with delimeter; "="
			cap_name=`/bin/echo ${string[$cnt]} | /usr/bin/awk -F "=" '{print $2}'`

			if [ "$cap_name" = "~CAP_MAC_ADMIN" ]; then
				flag_cap_mac_admin_disabled_found=1
			elif [ "$cap_name" = "~CAP_MAC_OVERRIDE" ]; then
				flag_cap_mac_override_disabled_found=1
			fi
		done

		# 2nd column -> 3rd column -> ...
		for (( cnt=2; cnt<=$capabilities_column_max; cnt++ ))
		do
			cap_name=`/usr/bin/awk '/CapabilityBoundingSet/{print $'$cnt'}' $service_path`

			if [ "$cap_name" = "CAP_MAC_ADMIN" ]; then
				flag_cap_mac_admin_enabled_found=1
			elif [ "$cap_name" = "CAP_MAC_OVERRIDE" ]; then
				flag_cap_mac_override_enabled_found=1
			fi
		done

	fi

	if [ $flag_cap_mac_admin_disabled_found -eq 1 -a $flag_cap_mac_override_disabled_found -eq 1 ]; then
		/bin/echo "@@ [Success] This service specified ~CAP_MAC_ADMIN and ~CAP_MAC_OVERRIDE"
		/bin/echo "###########################################################################"
		return
	else
		if [ $flag_cap_mac_admin_disabled_found -eq 1 ]; then
			/bin/echo "@@ There is only ~CAP_MAC_ADMIN"
		elif [ $flag_cap_mac_override_disabled_found -eq 1 ]; then
			/bin/echo "@@ There is only ~CAP_MAC_OVERRIDE"
		else
			/bin/echo "@@ [Questionable] This service did not specify ~CAP_MAC_ADMIN and ~CAP_MAC_OVERRIDE"
		fi

		checkExceptionList $service_name
		if [ "$retval" == "true" ]; then
			/bin/echo "@@ Allowed, $1 is included in exception list"
			/bin/echo "###########################################################################"
		elif [ "$retval" == "false" ]; then
			/bin/echo "@@ Failed, $1 is not included in exception list"
			/bin/echo "###########################################################################"
			/bin/echo "@@ Service name : $1" >> $LOG_CAP_MAC_CHECK
			if [ $flag_cap_mac_admin_disabled_found -eq 1 ]; then
				/bin/echo "@@ There is only ~CAP_MAC_ADMIN"  >> $LOG_CAP_MAC_CHECK
			elif [ $flag_cap_mac_override_disabled_found -eq 1 ]; then
				/bin/echo "@@ There is only ~CAP_MAC_OVERRIDE" >> $LOG_CAP_MAC_CHECK
			else
				/bin/echo "@@ [Questionable] This service did not specify ~CAP_MAC_ADMIN and ~CAP_MAC_OVERRIDE" >> $LOG_CAP_MAC_CHECK
		fi
			/bin/echo "@@ Failed, $1 is not included in exception list" >> $LOG_CAP_MAC_CHECK
			/bin/echo "###########################################################################" >> $LOG_CAP_MAC_CHECK
		fi
	fi
}

# Let's start checking root daemon whether it includes both CAP_MAC_ADMIN and CAP_MAC_OVERRIDE
/bin/echo "@@ Let's start checking root daemon whether it includes both CAP_MAC_ADMIN and CAP_MAC_OVERRIDE"
/bin/echo "###########################################################################"

# If there is log/result file about previous test, then we need to remove it
if [ -f $LOG_CAP_MAC_CHECK ]; then
	/bin/rm $LOG_CAP_MAC_CHECK
fi
if [ -f $RESULT_CAP_MAC_CHECK ]; then
	/bin/rm $RESULT_CAP_MAC_CHECK
fi

for entry in $(/bin/cat $ROOT_LIST)
do
	service_name=`/bin/echo $entry | /usr/bin/awk -F "," '{print $1}'`
	extension=`/bin/echo $entry | /usr/bin/awk -F "," '{print $NF}'`

	checkRootList $service_name $extension
done

# After test, we need to decide whether this test finish well or not
# Yes: test is success
# No : test is failed
if [ -f $LOG_CAP_MAC_CHECK ]; then # there is error log in $LOG_CAP_MAC_CHECK, we assume that this test is failed
	/bin/echo "No" > $RESULT_CAP_MAC_CHECK
else # there is no logs in $LOG_CAP_MAC_CHECK(since file is not created), we assume that this test is success 
	/bin/echo "Yes" > $RESULT_CAP_MAC_CHECK
fi
